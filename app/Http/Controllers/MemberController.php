<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class MemberController extends Controller
{
    public function index(Request $request)
    {
        abort_unless($request->user()->isAdministrator(), 403);
        $request->validate(['search' => ['nullable', 'string', 'max:100'], 'page' => ['sometimes', 'integer', 'min:1']]);

        return response()->json(User::where('role', 'member')
            ->with('developmentPlan:development_plans.id,development_plans.user_id,development_plans.cycle_number,development_plans.status')
            ->withCount('developmentPlans')
            ->when($request->filled('search'), fn ($q) => $q->where('name', 'like', '%'.$request->input('search').'%'))
            ->orderBy('id')->paginate(20, ['id', 'name', 'email'])->withQueryString());
    }

    public function update(Request $request, User $member)
    {
        abort_unless($request->user()->isAdministrator(), 403);
        abort_unless($member->role->value === 'member', 404);
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255', Rule::unique('users', 'email')->ignore($member)],
            'role' => ['prohibited'], 'password' => ['prohibited'],
        ]);
        if ($data['email'] !== $member->email) {
            $member->email_verified_at = null;
        }
        $member->fill($data)->save();

        return response()->json(['data' => $member->only(['id', 'name', 'email'])]);
    }
}
