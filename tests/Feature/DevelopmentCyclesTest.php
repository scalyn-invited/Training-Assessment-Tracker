<?php

namespace Tests\Feature;

use App\Models\Assessment;
use App\Models\DevelopmentPlan;
use App\Models\Skill;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class DevelopmentCyclesTest extends TestCase
{
    use RefreshDatabase;

    private function payload(User $member, Skill $skill): array
    {
        return [
            'user_id' => $member->id,
            'key_gaps' => 'Next-cycle gap',
            'weekly_focus' => 'Next-cycle focus',
            'baselines' => [['skill_id' => $skill->id, 'score' => 30]],
        ];
    }

    public function test_completed_member_can_start_numbered_next_cycle_with_history_preserved(): void
    {
        $admin = User::factory()->administrator()->create();
        $member = User::factory()->create();
        $old = DevelopmentPlan::factory()->completed()->create([
            'user_id' => $member->id,
            'cycle_number' => 1,
            'key_gaps' => 'Historical gap',
        ]);
        $historical = Assessment::factory()->create(['development_plan_id' => $old->id]);
        Sanctum::actingAs($admin);

        $this->getJson('/api/members/eligible')
            ->assertOk()
            ->assertJsonPath('data.0.id', $member->id)
            ->assertJsonPath('data.0.development_plans_max_cycle_number', 1);

        $newId = $this->postJson('/api/plans', $this->payload($member, Skill::factory()->create()))
            ->assertCreated()
            ->assertJsonPath('data.cycle_number', 2)
            ->assertJsonPath('data.status', 'draft')
            ->json('data.id');

        $this->assertDatabaseHas('development_plans', [
            'id' => $old->id, 'cycle_number' => 1, 'status' => 'completed', 'key_gaps' => 'Historical gap',
        ]);
        $this->assertDatabaseHas('assessments', ['id' => $historical->id, 'development_plan_id' => $old->id]);
        $this->assertDatabaseHas('development_plans', ['id' => $newId, 'cycle_number' => 2, 'status' => 'draft']);
        $this->getJson('/api/members/eligible')->assertJsonCount(0, 'data');
    }

    public function test_member_sees_every_cycle_and_latest_cycle_drives_identity_summary(): void
    {
        $member = User::factory()->create();
        $first = DevelopmentPlan::factory()->completed()->create(['user_id' => $member->id, 'cycle_number' => 1]);
        $second = DevelopmentPlan::factory()->create(['user_id' => $member->id, 'cycle_number' => 2]);
        Sanctum::actingAs($member);

        $this->getJson('/api/plans')->assertOk()->assertJsonCount(2, 'data')
            ->assertJsonPath('data.0.id', $first->id)
            ->assertJsonPath('data.1.id', $second->id)
            ->assertJsonPath('data.1.cycle_number', 2);
        $this->getJson('/api/me')->assertOk()
            ->assertJsonPath('data.development_plan_id', $second->id)
            ->assertJsonPath('data.development_plan_cycle', 2)
            ->assertJsonPath('data.development_plan_status', 'draft');
    }

    public function test_only_one_unfinished_cycle_is_allowed_and_cycle_number_is_server_owned(): void
    {
        $admin = User::factory()->administrator()->create();
        $member = User::factory()->create();
        $skill = Skill::factory()->create();
        Sanctum::actingAs($admin);

        $this->postJson('/api/plans', $this->payload($member, $skill) + ['cycle_number' => 99])
            ->assertUnprocessable()->assertJsonValidationErrors('cycle_number', 'details');
        $this->postJson('/api/plans', $this->payload($member, $skill))->assertCreated();
        $this->postJson('/api/plans', $this->payload($member, $skill))->assertConflict();
        $this->assertDatabaseCount('development_plans', 1);
    }

    public function test_cycle_pair_is_database_unique(): void
    {
        $member = User::factory()->create();
        DevelopmentPlan::factory()->completed()->create(['user_id' => $member->id, 'cycle_number' => 1]);
        $this->expectException(\Illuminate\Database\UniqueConstraintViolationException::class);
        DevelopmentPlan::factory()->completed()->create(['user_id' => $member->id, 'cycle_number' => 1]);
    }
}
