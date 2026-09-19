<?php

namespace Tests\Feature;

use App\Models\DevelopmentPlan;
use App\Models\User;
use App\Models\WeeklyEntry;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AdministrationGapsTest extends TestCase
{
    use RefreshDatabase;

    public function test_draft_direction_updates_but_active_and_completed_plans_are_frozen(): void
    {
        Sanctum::actingAs(User::factory()->administrator()->create());
        $plan = DevelopmentPlan::factory()->create();
        $data = ['key_gaps' => 'Testing', 'weekly_focus' => 'Feature tests'];
        $this->patchJson("/api/plans/$plan->id", $data)->assertOk()->assertJsonPath('data.key_gaps', 'Testing');
        $this->patchJson("/api/plans/$plan->id", $data + ['status' => 'active'])->assertUnprocessable();
        foreach (['active', 'completed'] as $state) {
            $plan->update(['status' => $state]);
            $this->patchJson("/api/plans/$plan->id", $data)->assertConflict();
        }
        $this->assertDatabaseHas('development_plans', ['id' => $plan->id, 'weekly_focus' => 'Feature tests']);
    }

    public function test_members_and_self_scoring_admins_cannot_edit_plan_direction(): void
    {
        $member = User::factory()->create();
        $plan = DevelopmentPlan::factory()->create(['user_id' => $member->id]);
        Sanctum::actingAs($member);
        $this->patchJson("/api/plans/$plan->id", [])->assertForbidden();
        $member->update(['role' => 'administrator']);
        Sanctum::actingAs($member->fresh());
        $this->patchJson("/api/plans/$plan->id", [])->assertForbidden();
    }

    public function test_member_management_requires_admin_and_cannot_change_roles_or_passwords(): void
    {
        $member = User::factory()->create();
        $this->getJson('/api/members')->assertUnauthorized();
        Sanctum::actingAs($member);
        $this->getJson('/api/members')->assertForbidden();
        $this->patchJson("/api/members/$member->id", [])->assertForbidden();
        Sanctum::actingAs($admin = User::factory()->administrator()->create());
        $this->getJson('/api/members')->assertOk()->assertJsonCount(1, 'data')->assertJsonMissingPath('data.0.password');
        $data = ['name' => 'Corrected Member', 'email' => 'corrected@example.test'];
        $this->patchJson("/api/members/$member->id", $data)->assertOk()->assertJsonPath('data.name', 'Corrected Member');
        $this->assertNull($member->fresh()->email_verified_at);
        $this->patchJson("/api/members/$member->id", $data + ['role' => 'administrator'])->assertUnprocessable();
        $this->patchJson("/api/members/$member->id", $data + ['password' => 'new-password'])->assertUnprocessable();
        $this->patchJson("/api/members/$member->id", array_replace($data, ['email' => $admin->email]))->assertUnprocessable();
        $this->patchJson("/api/members/$admin->id", $data)->assertNotFound();
        $this->getJson('/api/members?search=Corrected')->assertJsonCount(1, 'data');
    }

    public function test_skill_management_round_trip_and_open_week_guard(): void
    {
        Sanctum::actingAs(User::factory()->administrator()->create());
        $id = $this->postJson('/api/skills', ['name' => 'New Skill'])->assertCreated()->json('data.id');
        $this->postJson('/api/skills', ['name' => 'New Skill'])->assertUnprocessable();
        $this->patchJson("/api/skills/$id", ['name' => 'Renamed', 'description' => 'Detail', 'is_active' => false])
            ->assertOk()->assertJsonPath('data.is_active', false);
        $this->patchJson("/api/skills/$id", ['is_active' => true])->assertOk();
        WeeklyEntry::factory()->create(['skill_id' => $id]);
        $this->patchJson("/api/skills/$id", ['is_active' => false])->assertConflict();
        Sanctum::actingAs(User::factory()->create());
        $this->postJson('/api/skills', ['name' => 'Denied'])->assertForbidden();
        $this->patchJson("/api/skills/$id", ['name' => 'Denied'])->assertForbidden();
    }
}
