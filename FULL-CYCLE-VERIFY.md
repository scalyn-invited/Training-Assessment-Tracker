# Full-cycle walkthrough

Use a new test member so existing completed plans stay untouched. No database reset or migration is needed.

1. Open /register (or Create your account on the login page). Choose a unique email and password. Registration creates a member only.
2. Sign out, then log in as your local administrator.
3. Open Development plans → Create development plan.
4. Select the unassigned member; enter key gaps and weekly focus.
5. Select one or more active skills and enter a baseline score for every selected skill. Save draft plan. All baseline scores and the plan are saved together.
6. In the draft, use Correct baseline if needed, or Add another baseline skill. Confirm the baseline review and Activate plan. Baselines now freeze.
7. Create week 1 with a baseline skill and objective.
8. Add evidence and outcome score, then Log outcome. Close week. Closed records become read-only. Repeat with the next week if needed; only one new sequential week can be created after all earlier weeks close.
9. Once all weeks are closed, enter every final score, including any retired baseline skill. Tick the confirmation and Save finals and complete plan. Submission is one transaction; the completed plan cannot reopen.
10. Read Baseline to final: each skill's baseline, final and movement, plus the average. Pending finals are not zero; movement is in score points.
11. Sign out and log in as the new member. They should see only their own plan, weekly records and comparison, with no write controls.

## Negative checks

- Blank, nonnumeric or out-of-range scores return inline validation errors. Zero is valid.
- Activation requires baseline review acknowledgement in the UI; the API independently enforces valid baselines.
- An assigned member disappears from the creation selector; duplicate API creation is rejected.
- Members cannot access the eligible-member directory or create plans.
- Frozen baseline/closed-week edits and repeat completion are rejected by the API, not just hidden in Vue.
- Slow requests disable forms and duplicate submissions are guarded.
- If a write times out, refresh before retrying: the server may already have saved it.

## Tests

Run php artisan test, npm test, npm run test:ui and npm run build from this app.
FullCycleTest uses an isolated database and covers a fresh member through completed comparison over HTTP.
Component tests cover creation, correction, acknowledgement, duplicate submissions, nested validation, final submission and read-only completion.

The schema supports numbered plan cycles while allowing only one unfinished cycle per member. A completed cycle remains immutable history, and the server assigns the next cycle number. Skill membership is represented by scored baseline rows, so every selected skill is saved with a score, not as an unscored placeholder.
Administrators now manage the catalogue at /skills: create/edit, retire/reactivate,
filter and paginate. Open-week retirement is rejected. Historical assessments
retain retired skills. No deletion is offered.

## Administration follow-up

- /members: administrator-only directory, name search, pagination, plan links and
  name/sign-in-email corrections. Roles and passwords cannot be changed here.
  Members still register themselves. Changing email clears email verification.
- Draft plan details: edit key gaps and weekly focus before activation. Active
  and completed plans reject these updates server-side.
- Browser verification on 16 September used member #10, plan #6 and week #14:
  skill creation, member name correction, draft creation/direction correction,
  activation, evidence, closure, final submission and member comparison all passed.
  Baseline 20, final 80 and movement 60 were displayed correctly after skill retirement.
  These clearly labelled local test records were retained; existing records were not reset.
