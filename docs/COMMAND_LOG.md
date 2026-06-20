# Command Log

## 2026-06-20 - Phase 0

Environment audit commands:

```powershell
git --version
node -v
npm -v
pnpm -v
flutter --version
dart --version
java -version
adb --version
docker --version
docker compose version
supabase --version
psql --version
echo $env:ANDROID_HOME
echo $env:JAVA_HOME
flutter doctor -v
cmd /c npm -v
Get-Command npm -All
Get-Command git,node,pnpm,flutter,dart,java,adb,docker,supabase,psql -ErrorAction SilentlyContinue
```

Summary:

- Git and Node are installed.
- npm works through `npm.cmd`.
- pnpm, Flutter, Dart, Java, adb, Docker, Supabase CLI, and psql were not found.

## 2026-06-20 - Phase 1

Documentation commands:

```powershell
Get-Content -Raw -LiteralPath 'C:\Users\Administrator\Documents\my_busapp\AGENTS.md'
Get-ChildItem -Force -LiteralPath 'C:\Users\Administrator\Documents\my_busapp\docs'
Get-ChildItem -Force -LiteralPath 'C:\Users\Administrator\Documents\my_busapp'
Get-Content -LiteralPath 'C:\Users\Administrator\Documents\my_busapp\AGENTS.md' -TotalCount 8
```

Summary:

- Confirmed `AGENTS.md` contains the single-app role-based update.
- Added active architecture note to `AGENTS.md`.
- Created Phase 1 documentation files.

## 2026-06-20 - Phase 1.5 preparation

Commands run:

```powershell
Get-Content -Raw -LiteralPath 'C:\Users\Administrator\Documents\my_busapp\AGENTS.md'
Get-ChildItem -Force -LiteralPath 'C:\Users\Administrator\Documents\my_busapp'
Get-ChildItem -Force -LiteralPath 'C:\Users\Administrator\Documents\my_busapp\docs'
git --version
node -v
npm -v
cmd /c npm -v
pnpm -v
winget --version
java -version
adb --version
flutter --version
dart --version
supabase --version
psql --version
echo $env:ANDROID_HOME
echo $env:JAVA_HOME
flutter doctor -v
winget search --id EclipseAdoptium.Temurin.17.JDK --exact
winget search --id Google.AndroidStudio --exact
winget search --id Google.Flutter --exact
winget search --id Supabase.CLI --exact
winget search Flutter
winget search Supabase
winget search PostgreSQL
powershell -NoProfile -ExecutionPolicy Bypass -File 'C:\Users\Administrator\Documents\my_busapp\scripts\install_laptop_dependencies.ps1'
```

Summary:

- No install commands were run.
- `winget` is available as `v1.28.240`.
- `EclipseAdoptium.Temurin.17.JDK` is available through winget.
- `Google.AndroidStudio` is available through winget.
- Flutter SDK was not available through winget in this environment.
- Supabase CLI was not available through winget in this environment.
- PostgreSQL packages are available through winget, but PostgreSQL client install is deferred unless direct `psql` scripts are needed.
- `scripts/install_laptop_dependencies.ps1` was created and tested in verification-only mode.

Pending user approval command:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install_laptop_dependencies.ps1 -Install
```

## 2026-06-20 - Phase 1.5 installation

Approved command:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install_laptop_dependencies.ps1 -Install -InstallPostgresClient
```

Important commands run after initial timeout recovery:

```powershell
Stop-Process -Id 11064 -Force
Stop-Process -Id 24316 -Force
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install_laptop_dependencies.ps1 -Install -InstallPostgresClient
sdkmanager.bat --licenses
sdkmanager.bat "platform-tools" "platforms;android-35" "build-tools;35.0.0"
sdkmanager.bat "platforms;android-36" "build-tools;28.0.3"
git --version
node -v
cmd /c npm -v
cmd /c pnpm -v
java -version
adb --version
flutter --version
dart --version
supabase --version
psql --version
flutter doctor -v
```

Results:

- `pnpm` installed: `11.8.0`.
- Java installed: Eclipse Temurin OpenJDK `17.0.19+10`.
- Android Studio installed with winget.
- Android SDK installed at `C:\Users\Administrator\AppData\Local\Android\Sdk`.
- `adb` installed: `37.0.0-14910828`.
- Flutter installed: `3.44.2`.
- Dart installed: `3.12.2`.
- Supabase CLI installed: `2.107.0`.
- `ANDROID_HOME` set.
- `JAVA_HOME` set.
- Android licenses accepted.
- `flutter doctor -v` reports `No issues found`.
- `psql` remains missing; skipped because no safe client-only winget package was found and full PostgreSQL server install would add unrelated system services.
- Direct PowerShell `npm` and `pnpm` commands are blocked by execution policy; use `cmd /c npm` and `cmd /c pnpm` or update PowerShell policy later.

## 2026-06-20 - Phase 2 scaffold

Key commands run:

```powershell
flutter create --platforms=android --org com.cameroonbus --project-name mobile_app apps/mobile_app
dart format lib test
flutter --version
flutter doctor -v
flutter pub get
flutter analyze
flutter test
cmd /c pnpm install
cmd /c pnpm --filter api build
cmd /c pnpm --filter api lint
cmd /c pnpm --filter api test
```

Runtime health smoke check:

```text
GET http://127.0.0.1:3101/api/v1/health
```

Response:

```json
{"status":"ok","service":"cameroon-bus-api","environment":"development","database":"not_checked"}
```

Results:

- Flutter doctor: no issues found.
- Flutter analyze: no issues found.
- Flutter tests: 2 passed.
- API build: passed.
- API typecheck: passed.
- API tests: 1 passed.
- pnpm install required explicit `allowBuilds` approval for `unrs-resolver`; configured in `pnpm-workspace.yaml`.
- No APK was built.
- No database migration was created.

## 2026-06-20 - Phase 3 migrations

Commands run:

```powershell
Get-Content -Raw AGENTS.md
Get-Content -Raw docs/database_schema.md
Get-Content -Raw docs/taxi_zone_rules.md
Get-Content -Raw docs/security_rules.md
Get-Content -Raw docs/api_contract.md
Get-ChildItem database/migrations
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/validate_migration_files.ps1
```

Static validation result:

```text
Migration validation passed.
Files checked: 7 SQL migrations and README.md
Required tables found: 25
Required roles found: 7
PostGIS geography, taxi eligibility, seat uniqueness, and secret checks passed.
```

No migration was run. No Supabase connection or secret was requested.

Final static audit:

- Every SQL migration has one `BEGIN` and one `COMMIT`.
- 25 `CREATE TABLE` declarations found.
- 69 explicit indexes found, including partial, composite, and GiST indexes.
- No `DROP DATABASE`, `DROP SCHEMA`, or `TRUNCATE` statements found.
- No database URL, service-role credential, or `DATABASE_URL` assignment found
  in migration SQL.
- Workspace contains only `.env.example`; its connection string is a placeholder.
- No APK or forbidden split-app directory exists.

## 2026-06-20 - Phase 4 seeds

Commands run:

```powershell
Get-Content -Raw AGENTS.md
cmd /c pnpm add -w pg
cmd /c pnpm add -Dw bcryptjs
node scripts/generate_demo_password_hash.mjs
node --check scripts/run_sql_files_with_pg.mjs
node --check scripts/generate_demo_password_hash.mjs
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/validate_seed_files.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/validate_migration_files.ps1
```

Seed validation result:

```text
Seed validation passed.
Files checked: 9 ordered SQL seed files
Roles: 7; regions: 5; cities: 8
Routes: 14; residential areas: 35
Warnings, idempotency, PostGIS distance logic, and secret checks passed.
```

Migration validation rerun: passed.

No seed-runner command was invoked. No database connection or secret was
requested, printed, or stored.

Final Phase 4 audit:

- All nine seed files have balanced `BEGIN`/`COMMIT` transactions.
- Every seed file has at least one idempotency guard.
- The exact demo plaintext password appears only in
  `database/seed-data/demo_credentials_warning.md`.
- No identity-document insert, database URL, local database configuration, or
  destructive reset SQL exists in seed files.
- No APK exists and `DATABASE_URL` was not set in the process.

## 2026-06-20 - Phase 5 backend API

Commands run:

```powershell
cmd /c pnpm --filter api add @nestjs/jwt class-validator class-transformer bcryptjs
cmd /c pnpm --filter api test
cmd /c pnpm --filter api build
cmd /c pnpm --filter api typecheck
```

Final verification:

```text
Jest: 7 suites passed, 26 tests passed
Nest build: passed
TypeScript typecheck: passed
HTTP smoke on port 3105: passed
```

The smoke check exercised `/health`, `/regions`, `/auth/register`, `/bookings`,
demo payment, and eligible taxi areas. The temporary process was stopped.

No Supabase request was made. No migration, seed, APK build, deployment, local
container configuration, credential request, or secret write occurred.

## 2026-06-20 - Phase 6 backend hardening

Commands run:

```powershell
cmd /c pnpm --filter api add -D supertest @types/supertest
cmd /c pnpm --filter api typecheck
cmd /c pnpm --filter api test
cmd /c pnpm --filter api test:e2e
cmd /c pnpm --filter api build
```

An initial e2e run failed before sending requests because the Supertest CommonJS
module was imported as a default export. The import was corrected to TypeScript
`require` syntax and the complete suite passed.

Final verification:

```text
Unit: 7 suites, 28 tests passed
E2E: 1 suite, 10 tests passed
Nest build: passed
TypeScript typecheck: passed
```

No Supabase endpoint was contacted. No database URL or other secret was
requested, read, printed, or stored. No migration, seed, APK build, deployment,
or local container configuration command ran.

## 2026-06-20 - Phase 7 Supabase and PostgreSQL adapters

Prepared and attempted:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\push_supabase_schema.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\verify_supabase_staging.ps1
cmd /c pnpm --filter api build
cmd /c pnpm --filter api typecheck
cmd /c pnpm --filter api test
cmd /c pnpm --filter api test:e2e
cmd /c pnpm --filter api test:integration
```

Migration attempts reached the direct Supabase host but the connection was
terminated before authentication and before the first SQL filename was logged.
TCP transport was reachable. Strict TLS and a diagnostic no-verify connection
both ended the same way. Seeds were intentionally not run.

Results:

```text
Migrations: failed before SQL execution
Seeds: not run
Verification counts: unavailable
Build/typecheck: passed
Unit: 28 passed
E2E: 10 passed
Integration: 2 failed at database connection
```

The direct connection value was loaded only from ignored `supabase.txt` into
temporary process environments. It was not printed or written to project files.

## 2026-06-21 - Phase 7 resumed with Session Pooler

Used only the `session_pooler_connection_string` field as process-only
`DATABASE_URL`.

Results:

```text
Migrations: 7 of 7 completed
Seeds: 9 of 9 completed
Extensions: pgcrypto, postgis
Counts: roles 7; regions 5; cities 8; agencies 1; terminals 5;
        buses 3; seats 150; routes 14; residential areas 35; users 7
Build/typecheck: passed
Unit: 28 passed
E2E: 10 passed
PostgreSQL integration: 2 passed
```

The first pooler attempt exposed a certificate-chain mismatch. Node `pg` was
updated to use standard libpq semantics for `sslmode=require`; all subsequent
database operations passed. No credential value was printed or persisted.

## 2026-06-21 - Phase 8 hosted API preparation

Commands run:

```powershell
cmd /c pnpm --filter api build
cmd /c pnpm --filter api typecheck
cmd /c pnpm --filter api test
cmd /c pnpm --filter api test:e2e
cmd /c pnpm --filter api test:integration
```

Results:

```text
Build/typecheck: passed
Unit: 30 passed
E2E: 10 passed
PostgreSQL integration: 2 passed
Hosted smoke script syntax: passed
```

Created deployment configuration and documentation only. No Render service was
created, no public deployment occurred, no APK was built, and no secret value
was written or printed.
