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
