# Training Assessment Tracker

Training Assessment Tracker is a Laravel and Vue application for recording a member's development plan from baseline assessment through weekly evidence to a final comparison. It is a deliberately scoped technical demonstration project, not a long-term HR platform.

Administrators manage the skill catalogue, members, and development plans. Members can register and view only their own plan history, weekly progress, and baseline-to-final comparison.

## What it does

- Creates draft development plans with a scored baseline for every selected skill.
- Enforces the plan lifecycle: `draft` -> `active` -> `completed`.
- Records sequential weekly objectives, evidence, and outcome scores. Closed weeks and completed plans are immutable.
- Calculates per-skill and average movement from baseline to final scores without storing a derived delta.
- Preserves completed plan history and supports numbered follow-on cycles, while allowing only one unfinished cycle per member.
- Supports administrator-only skill catalogue management, member search and identity corrections, and draft-plan direction changes.
- Uses Laravel Sanctum bearer-token authentication, role/ownership policies, validated API requests, and Vue route protection.

## Technology

- Laravel 12 and PHP 8.2+
- SQLite for local development and automated tests
- Vue 3, Vue Router, Vite, and Vitest
- Laravel Sanctum and Laravel Pint

## Roles

| Role | Capabilities |
|---|---|
| Administrator | Manages skills and members; creates and progresses plans for other members; records baselines, weekly entries, and final assessments. |
| Member | Registers an account and reads only their own plans, weeks, and comparisons. |

The frontend hides controls that are not relevant to a role, but the API policies and programme rules enforce permissions and state transitions.

## Local setup

Requirements: PHP 8.2+, Composer, Node.js/npm, and the PHP SQLite extension.

```powershell
composer install
Copy-Item .env.example .env
php artisan key:generate
New-Item -ItemType File -Path database/database.sqlite -Force
php artisan migrate --seed
npm ci
npm run build
php artisan serve
```

Open `http://127.0.0.1:8000`. For frontend development, run `npm run dev` in a second terminal.

The local seed administrator is `admin@example.test` with password `password`. These credentials are only for a disposable local database; never use them in a deployed environment.

Do not run `migrate:fresh` against a database that contains work you need to retain.

## Verification

```powershell
php artisan test
npm test
npm run test:ui
npm run build
php vendor/bin/pint --test
```

The automated suite covers authentication, role and ownership rules, state transitions, atomic writes and rollback, repeat cycles, API error handling, and Vue loading, validation, duplicate-submission, and read-only states.

For an end-to-end review, follow [FULL-CYCLE-VERIFY.md](FULL-CYCLE-VERIFY.md).

## Design boundaries

- A skill is retired, not deleted, so historical assessment records remain intact.
- Baseline rows define plan membership. A skill cannot be planned without a baseline score in the current model.
- The local demo stores bearer tokens in `sessionStorage` so a session survives refreshes within a tab. A production first-party deployment should instead use Sanctum HttpOnly cookies, CSRF protection, HTTPS, and a reviewed content-security policy.
- Application rules are enforced through policies and services; privileged direct database writes can bypass those rules.

## Further reading

[TECHNICAL-NOTES.md](TECHNICAL-NOTES.md) documents the schema, API, integrity rules, comparison calculation, and deliberate exclusions.
