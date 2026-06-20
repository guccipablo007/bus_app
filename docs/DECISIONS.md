# Decisions

## D001 - Single Flutter Android app

Decision: Build one MVP Flutter Android app at `apps/mobile_app`.

Rationale: The latest `AGENTS.md` update replaces the older three-app plan. A single APK is easier to share with friends and supports role-based interfaces after login.

Consequences:

- No separate passenger app.
- No separate taxi driver app.
- No separate agency/admin dashboard app for MVP.
- Role-specific shells live inside the one mobile app.

## D002 - Backend-provided roles

Decision: The mobile app must route users using roles returned by the backend login response.

Rationale: Role permissions are security-sensitive and cannot be trusted to local hardcoded data.

Consequences:

- Login response includes `user.roles`.
- App shows `RoleRouterScreen`.
- Multi-role users see `RoleSwitchScreen`.
- Backend still enforces permissions on every protected endpoint.

## D003 - Hosted staging only for shared APK testing

Decision: The final friend-testing APK connects to a hosted HTTPS API and hosted Supabase PostgreSQL/PostGIS.

Rationale: Friends cannot depend on localhost, Docker, or the user's PC.

Consequences:

- APK uses `--dart-define=API_BASE_URL=https://YOUR-HOSTED-API-DOMAIN/api/v1`.
- APK never contains database credentials.
- Supabase is accessed only by the backend.

## D004 - No local container database

Decision: Do not use a local container database for this project.

Rationale: The current project direction says Supabase is the staging database and no local container database should be used.

Consequences:

- Do not create Docker database setup.
- Do not require Docker for development.
- Use Supabase staging and/or direct SQL tooling when database phases begin.

## D005 - Material 3 glassmorphism

Decision: Use Flutter Material 3 with a clean, modern, simple glassmorphism-inspired visual style.

Rationale: The app should feel polished and intuitive without visual clutter.

Consequences:

- Use soft gradients, translucent panels, rounded corners, subtle shadows, and strong contrast.
- Avoid noisy dashboards, tiny text, heavy animation, and low-contrast blur.

## D006 - Flutter package identity

Decision: Use Android application ID `com.cameroonbus.mobile_app` for the Phase 2 scaffold.

Rationale: It is stable, project-specific, and compatible with the one-app architecture.

## D007 - Flutter outside pnpm workspace

Decision: pnpm workspace includes only `services/*` and `packages/*`.

Rationale: Flutter manages dependencies with pub and does not need pnpm workspace membership.

## D008 - Health database state

Decision: Return `database: "not_connected"` until database connectivity is implemented.

Rationale: Reporting a database as reachable before a connection exists would be misleading. The endpoint exposes no secrets.

## D009 - pnpm dependency build allowlist

Decision: Allow only `unrs-resolver` in the pnpm `allowBuilds` map.

Rationale: Jest's resolver dependency requires its reviewed postinstall; approving all dependency build scripts would be broader than needed.

## D010 - Ordered plain SQL migrations

Decision: Use seven numerically ordered PostgreSQL SQL migrations.

Rationale: Plain SQL is portable to Supabase, reviewable without ORM tooling,
and keeps extension, table, constraint, index, and trigger ownership explicit.

## D011 - Multi-role relational model

Decision: Model roles with `roles` and `user_roles`, not `users.role`.

Rationale: One authenticated user may need multiple interfaces in the single
Flutter app. Backend role claims can be derived from active assignments.

## D012 - Database defense for taxi eligibility

Decision: Add a taxi eligibility trigger in addition to future API checks.

Rationale: The destination-bound taxi rule is critical. The database rejects
unpaid/unconfirmed bookings, wrong terminals/cities/agencies, unverified areas,
and terminal-area distances over 15 km even if an API bug occurs.

## D013 - RLS deferred for backend-only access

Decision: Do not add permissive Supabase RLS policies in Phase 3.

Rationale: Flutter must never access these tables directly. Backend guards are
mandatory; RLS will be designed only if direct Supabase Data API exposure is
later introduced.

## D014 - SQL-first idempotent seed files

Decision: Store demo data in nine ordered SQL seed files using natural keys,
`ON CONFLICT`, and targeted `NOT EXISTS` checks.

Rationale: Seeds remain reviewable, rerunnable, and independent of backend
feature implementation.

## D015 - Rolling staging trips

Decision: Generate demo departures relative to `CURRENT_DATE`.

Rationale: Fixed dates would quickly make trip search appear broken. Same-day
reruns are deduplicated by route/departure checks.

## D016 - Node pg seed runner

Decision: Prepare a Node `pg` runner rather than depend solely on `psql`.

Rationale: `psql` is unavailable on this laptop. The runner still requires an
environment-provided URL and explicit staging confirmation.

## D017 - Synthetic bcrypt demo credentials

Decision: Commit only a bcrypt hash in SQL and keep the staging plaintext in a
dedicated warning file.

Rationale: Demo authentication remains reproducible without normalizing
plaintext passwords in executable SQL or production documentation.

## D018 - Replaceable in-memory repositories for Phase 5

Decision: Implement `UserRepository` and `DomainRepository` abstractions with
process-local adapters while Supabase access is prohibited.

Rationale: Controllers, authorization, and business rules can be exercised now,
while PostgreSQL adapters can replace storage without rewriting API contracts.

## D019 - Hosted secret validation boundary

Decision: Require `DATABASE_URL`, JWT secrets, and `ID_ENCRYPTION_KEY` in
staging/production, but generate non-persisted random secrets and permit no
database URL in development/test.

Rationale: Unit tests and local API smoke checks need no committed credentials,
while hosted startup must fail closed when configuration is incomplete.

## D020 - Database health is not connected

Decision: Return `database: "not_connected"` until the PostgreSQL adapter has
performed a real connectivity check.

Rationale: A deployment-safe health response must not claim unverified reachability.

## D021 - Shared HTTP configuration

Decision: Apply the global validation pipe and exception filter through one
`configureApp` function used by both `main.ts` and e2e tests.

Rationale: Production and test requests must exercise identical validation and
error behavior.

## D022 - Granular repository adapter contracts

Decision: Replace the Phase 5 composite domain repository contract with
`AuthRepository`, `UserRepository`, `LocationRepository`, `TripRepository`,
`BookingRepository`, `TicketRepository`, and `TaxiRepository`.

Rationale: Phase 7 PostgreSQL adapters can be introduced by module binding and
tested by responsibility without changing controllers or business services.

## D023 - Business rules use HTTP 422

Decision: Return `422 Unprocessable Entity` for syntactically valid requests
that violate payment, taxi eligibility, or seat-validity rules. Preserve `409`
for a unique seat-lock conflict.

Rationale: Clients can distinguish malformed input, authorization failures,
resource conflicts, and domain-policy failures predictably.

## D024 - In-memory concurrency is simulation only

Decision: Test concurrent Phase 6 seat requests with `Promise.all`, but require
the Phase 7 adapter to use a PostgreSQL transaction and unique constraint.

Rationale: JavaScript's single-process atomic check/set proves service behavior,
not correctness across multiple hosted API workers.

## D025 - Environment-selected PostgreSQL adapters

Decision: Bind PostgreSQL repositories in staging/production and retain the
in-memory implementations in development/test.

Rationale: Hosted execution uses Supabase without changing controllers, while
fast deterministic unit/e2e tests remain independent of external state.

## D026 - Transactional PostgreSQL booking adapter

Decision: Create the booking, booking passenger, and seat lock in one database
transaction and translate unique violations to HTTP 409.

Rationale: The database unique `(trip_instance_id, seat_id)` constraint is the
final concurrency authority across API processes.

## D027 - Stop seeds after migration failure

Decision: Do not execute staging seeds when migrations fail before completion.

Rationale: Seeding an unknown or partial schema would obscure the original
failure and could leave staging in a harder-to-audit state.

## D028 - Supabase Session Pooler for hosted database access

Decision: Use the Session Pooler connection string for migration tooling,
adapter integration tests, and future hosted API configuration.

Rationale: The direct endpoint terminated connections from this network, while
the official session pooler completed migrations, seeds, verification, and tests.

## D029 - Standard libpq semantics for pooler TLS

Decision: When the pooler specifies `sslmode=require`, add
`uselibpqcompat=true` in memory before constructing Node `pg` clients.

Rationale: This preserves encrypted transport with the pooler's certificate
chain and avoids writing a modified credential anywhere.

## D030 - Repository-root Render service

Decision: Build Render from the monorepo root with pnpm workspace filters rather
than setting `services/api` as the Render root directory.

Rationale: The lockfile and workspace manifest live at repository root, so root
builds are deterministic and match local verification.

## D031 - Manual Render deployment gate

Decision: Provide `render.yaml` with `autoDeploy: false` and do not create the
service automatically.

Rationale: Public deployment and hosted secret configuration require explicit
user approval and manual review.

## D032 - Hosted database-aware health

Decision: Ping PostgreSQL only in staging/production health requests and report
`reachable` or `unreachable` without returning connection details.

Rationale: Deployment smoke tests need real database assurance while local tests
must stay fast, deterministic, and credential-free.
