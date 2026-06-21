# Build Status

## Current status

Phases 9 and 10 passed. The one Flutter app is integrated with the hosted API,
and a debug staging APK exists at:

```text
apps/mobile_app/build/app/outputs/flutter-apk/app-debug.apk
```

## Latest verification (2026-06-21 — GLM 5.2, session 2 — full pass)

```text
Flutter doctor:    no issues (all checks ✅)
Flutter analyze:   no issues found
Flutter test:      (no test/ directory — expected at this stage)
NestJS build:      passed (nest build)
NestJS typecheck:  passed (tsc --noEmit, 0 errors)
NestJS unit tests: 7 suites, 30 tests, all passed
Staging debug APK: 146,569,348 bytes (139.8 MiB)
Friend pkg ready:  staging_artifacts/cameroon-bus-staging-debug.apk
SHA-256:           617C8B17707363C9CDEB38EF7A9A1D66FCA92525CBD05AA76CB701E8C96357B3
```

## Architecture check

- One app only: `apps/mobile_app`.
- Role selection comes from backend login response claims.
- Flutter calls the hosted NestJS API only.
- No local database, Supabase URL, database password, or service key is used by
  the APK.
- APK/build outputs and `staging_artifacts/` remain ignored by Git.

## Remaining validation

Physical-device installation and friend testing are the next step. The
friend-testing package, guide, known-limitations doc, and USB install script
are all ready.

## VS Code workspace readiness

- `.vscode/extensions.json` — created with 13 recommended extensions
- `.vscode/settings.json` — created with safe project-wide settings
- All checks pass
