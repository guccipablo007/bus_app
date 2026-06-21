# Build Status

## Current status

Phases 9 and 10 passed. The one Flutter app is integrated with the hosted API,
and a debug staging APK exists at:

```text
apps/mobile_app/build/app/outputs/flutter-apk/app-debug.apk
```

## Latest verification (2026-06-21 — GLM 5.2, session 4 — Phase 12B-A full pass)

```text
Flutter analyze:      no issues found
Flutter test:         5/5 passed (api_client + widget tests)
NestJS build:         passed (nest build)
NestJS typecheck:     passed (tsc --noEmit, 0 errors)
NestJS unit tests:    7 suites, 30 tests, all passed
Staging debug APK:    staging_artifacts/cameroon-bus-staging-debug.apk
SHA-256:              50ADCBD4A52DEAF9F2E10FA45710AD9B67E444D6EC20359A571A1EE38F26627B
```

## Architecture check

- One app only: `apps/mobile_app`.
- Role selection comes from backend login response claims.
- Flutter calls the hosted NestJS API only.
- No local database, Supabase URL, database password, or service key is used by
  the APK.
- APK/build outputs and `staging_artifacts/` remain ignored by Git.

## Phase 12B additions (this session)

- **Session persistence:** Created `SessionStorage` (SharedPreferences-based).
  Login now survives app restarts — tokens and profile are restored on splash.
- **Improved login flow:** Rewrote `LoginScreen` with demo helper buttons, role
  selection for multi-role users, and session storage on successful login.
- **SplashScreen rewrite:** Checks `SessionStorage` for existing session;
  auto-routes to `RoleRouterScreen` or login accordingly.
- **AuthCheck rewrite:** Simplified to use session restoration with loading
  spinner, then navigate to role router.
- **RoleRouterScreen update:** Supports `onLogout` callback that clears session
  and navigates back to login; handles multi-role user selection.
- **PassengerHomeShell update:** Accepts `onLogout` callback and uses it in
  navigation bar sign-out and profile sign-out buttons.

## Remaining validation

Physical-device installation and friend testing are the next step. The
friend-testing package, guide, known-limitations doc, and USB install script
are all ready.

## VS Code workspace readiness

- `.vscode/extensions.json` — created with 13 recommended extensions
- `.vscode/settings.json` — created with safe project-wide settings
- All checks pass
