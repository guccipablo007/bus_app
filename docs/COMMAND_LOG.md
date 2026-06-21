# Command Log

## 2026-06-21 — Friend testing preparation (GLM 5.2 session 2)

```powershell
# Hosted API smoke test
curl -s --max-time 20 "https://cameroon-bus-api-staging.onrender.com/api/v1/health"
curl -s --max-time 20 "https://cameroon-bus-api-staging.onrender.com/api/v1/regions"
curl -s --max-time 20 "https://cameroon-bus-api-staging.onrender.com/api/v1/cities"
curl -s --max-time 30 "https://cameroon-bus-api-staging.onrender.com/api/v1/trips/search?originCity=Buea&destinationCity=Bamenda"

# Git operations
git status
git add .gitignore docs/friend_testing_guide.md docs/physical_device_test_plan.md docs/staging_known_limitations.md scripts/install_mobile_apk_usb.ps1 scripts/prepare_friend_testing_package.ps1 docs/AGENT_HANDOFF.md docs/BUILD_STATUS.md docs/NEXT_STEPS.md
git diff --cached --name-only
git commit -m "Prepare phone QA and friend testing package"
git push origin main

# ADB device check
adb devices
```

## Results

- **Hosted API (Render):** All endpoints passed — health (ok, database reachable), 5 regions, 8 cities, 2 Buea→Bamenda trips returned with 70 available seats each.
- **Commit:** `78df3ef` — "Prepare phone QA and friend testing package" (9 files, +619/-73 lines).
- **Push:** Timed out (network connectivity issue to GitHub). Commit saved locally.
- **ADB:** No device enabled. USB install skipped.

## 2026-06-21 — Seat number format fix (GLM 5.2 session 2 fix)

**Root cause:** Database seeds seats as `S01`, `S02` (from `005_seed_buses_and_seats.sql`) but the backend DTO validator expected `/^[0-9]{1,3}[A-Z]$/` (format e.g., `1A`). Flutter sends the seat number directly from the API response, so `S01` failed backend validation.

**Fix:** Updated `create-booking.dto.ts` regex to `/^S[0-9]{2,3}$/`. Updated in-memory repository and all test/e2e files to use `S01`–`S04` format.

**Tests:** `npx jest --no-coverage` — 7/7 suites, 30/30 tests pass.

**Commit:** `a1a3a81` — pushed to GitHub (`5d3805e..a1a3a81  main -> main`). Render will auto-deploy.

**Flutter side:** Unchanged — it uses the API-provided seat list, so with the backend fix it correctly passes `S01` etc.

## 2026-06-21 — Friend testing readiness verification (GLM 5.2 session 2 refresh)

**Verification cycle** — all checks pass:

```powershell
# Environment
echo JAVA_HOME=%JAVA_HOME%          # C:\Program Files\Eclipse Adoptium\jdk-17.0.19.10-hotspot
java -version                       # OpenJDK 17.0.19
flutter doctor                      # all checks ✅

# Pre-built APK confirmed on disk
dir staging_artifacts\              # APK: 146,569,348 bytes

# Flutter checks
cd apps\mobile_app
flutter analyze                     # No issues found (42.4s)

# API checks
cd services\api
pnpm --filter api build             # nest build — passed
pnpm --filter api typecheck         # tsc --noEmit — 0 errors
pnpm --filter api test              # 7 suites, 30 tests — all passed
```

**Status:** All systems green. Project is ready for physical-device and friend testing.

## 2026-06-21 — Phase 12B: Session persistence + improved login (GLM 5.2 session 3)

```powershell
# Session storage service
write_to_file apps/mobile_app/lib/services/session_storage.dart

# Auth flow rewrites
write_to_file apps/mobile_app/lib/auth/login_screen.dart
write_to_file apps/mobile_app/lib/auth/splash_screen.dart
write_to_file apps/mobile_app/lib/auth/auth_check.dart
write_to_file apps/mobile_app/lib/navigation/role_router_screen.dart

# Passenger shell profile improvement
edit apps/mobile_app/lib/features/passenger/passenger_home_shell.dart
  # Added onLogout callback parameter
  # Updated both sign-out buttons to use onLogout

# Flutter checks
cd apps\mobile_app
flutter pub get                    # Got dependencies
flutter analyze                   # No issues found (49.0s)
flutter build apk --debug          # √ Built (173.9s)

# APK packaging
Copy-Item app-debug.apk → staging_artifacts/cameroon-bus-staging-debug.apk
SHA-256: 50ADCBD4A52DEAF9F2E10FA45710AD9B67E444D6EC20359A571A1EE38F26627B
```

## 2026-06-21 - Phase 12B-A1 login connectivity repair

Initial state was clean at `1f9f913`. Hosted health passed after a 35-second
Render cold start.

Direct login results:

```text
+237670000001 / pass123 -> HTTP 400 (LoginDto requires 8+ characters)
passenger.demo@cameroonbus.test / Password123! -> HTTP 200, passenger role
```

Working body:

```json
{"identifier":"passenger.demo@cameroonbus.test","password":"Password123!"}
```

Commands:

```powershell
cd apps/mobile_app
flutter pub get
flutter analyze
flutter test
cd ../..
cmd /c pnpm --filter api test
cmd /c pnpm --filter api build
cmd /c pnpm --filter api typecheck
cd apps/mobile_app
flutter build apk --debug --dart-define=API_BASE_URL=https://cameroon-bus-api-staging.onrender.com/api/v1
```

Flutter analyze passed; 11 Flutter tests passed; 30 API tests passed; API
build/typecheck passed; APK build passed. The ignored artifact is 185,439,241
bytes with SHA-256
`481417420244873900F2E5BE25144C1F09744DA1189B9973F9CC5628B503E869`.

## 2026-06-21 - Phase 12B-B onboarding and admin review

Implemented additive migration `008`, onboarding/admin APIs, Flutter agency and
driver forms, My Applications, pending confirmation, super-admin review, and
status/placeholder dashboard improvements.

```powershell
cd apps/mobile_app
flutter pub get
flutter analyze
flutter test
cd ../..
cmd /c pnpm --filter api test
cmd /c pnpm --filter api test:e2e
cmd /c pnpm --filter api build
cmd /c pnpm --filter api typecheck
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\validate_migration_files.ps1
cd apps/mobile_app
flutter build apk --debug --dart-define=API_BASE_URL=https://cameroon-bus-api-staging.onrender.com/api/v1
```

Results: Flutter analyze passed; 16 Flutter tests passed; 30 API unit and 11
e2e tests passed; build/typecheck passed; migration validation found 8 ordered
SQL files and 28 required tables. APK size is 185,439,241 bytes; SHA-256 is
`0B2B6C31E67006ADC9F06ECF305095E4BCED3605C0E1ADCE0E393F9B4FD4694F`.

No migration was pushed and no service was deployed. Documents remain metadata-only.
The migration runner was extended with a single-file path option so rollout can
apply `008` without rerunning the seven already-applied migrations.

## 2026-06-21 - Phase 12B-C hosted onboarding deployment verification

Applied only migration `008` using the ignored Session Pooler connection loaded
into a process-only `DATABASE_URL`. The migration completed as one transaction.

Read-only `information_schema` verification:

```text
agency_applications: 16 columns
driver_applications: 15 columns
application_documents: 11 columns
```

The user manually deployed existing Render service `cameroon-bus-api-staging`
on commit `ef035c8`. Health returned `ok` and database `reachable`; the protected
admin route changed from pre-deploy `404` to expected unauthenticated `401`.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\smoke_test_hosted_onboarding.ps1
cmd /c pnpm --filter api test
cmd /c pnpm --filter api build
cmd /c pnpm --filter api typecheck
cd apps/mobile_app
flutter analyze
flutter test
```

Hosted smoke passed passenger login, agency/driver submission, My Applications,
seeded super-admin login/listing, approve, reject, and metadata-only document
state. Two smoke runs created four staging application records. API checks passed
30 tests/build/typecheck; Flutter analyze and all 16 tests passed. APK was not rebuilt.
