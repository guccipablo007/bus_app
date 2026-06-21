# Agent Handoff

## Current phase

Phase 12B-A1 complete: hosted login connectivity regression repaired.

## What was completed

- Confirmed the initial worktree was clean with no partial agent edits.
- Verified hosted health and database reachability.
- Verified the backend login body is exactly `identifier` plus `password`.
- Proved the seeded hosted passenger login returns HTTP 200.
- Corrected demo helpers to use accounts actually seeded in Supabase.
- Made hosted Render the safe API default and rebuilt with an explicit dart-define.
- Added status-specific errors and debug-only transport diagnostics.
- Added config, payload, error, demo-fill, and session-save regression tests.

## Root cause

Commit `1f9f913` rebuilt with plain `flutter build apk --debug`, omitting the
staging dart-define. `ApiConfig` therefore selected `10.0.2.2` in BlueStacks.
The rewrite also introduced `+237670000001 / pass123`; `pass123` violates the
backend eight-character minimum and that phone is not assigned to the seeded user.

## Working hosted login

```json
{
  "identifier": "passenger.demo@cameroonbus.test",
  "password": "Password123!"
}
```

The hosted endpoint returned HTTP 200, passenger role, and both tokens. Token
values were not logged.

## Files changed

- Flutter API config, API client, auth service, login helper, and auth tests
- Phase status, build, limitation, friend-testing, and device-test docs

## Verification

```text
Flutter analyze: no issues
Flutter tests: 11 passed
NestJS tests: 7 suites, 30 passed
NestJS build/typecheck: passed
APK build with hosted dart-define: passed
```

## APK

```text
Path: staging_artifacts/cameroon-bus-staging-debug.apk
Size: 185,439,241 bytes
SHA-256: 481417420244873900F2E5BE25144C1F09744DA1189B9973F9CC5628B503E869
```

The APK and `staging_artifacts/` remain ignored.

## Known issues

- Render Free cold starts can delay login; client timeout is 120 seconds.
- SharedPreferences is staging-only token storage; production needs secure storage.
- Non-passenger dashboards remain placeholders.

## Exact next task

Replace the BlueStacks APK, clear old app data, and repeat the login/session and
passenger regression checklist in `docs/physical_device_test_plan.md`.

## Secrets still needed

None.
