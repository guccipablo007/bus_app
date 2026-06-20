# Build Status

## Current status

Phases 9 and 10 passed. The one Flutter app is integrated with the hosted API,
and a debug staging APK exists at:

```text
apps/mobile_app/build/app/outputs/flutter-apk/app-debug.apk
```

## Verification

```text
Hosted smoke: passed; database reachable; 5 regions; 8 cities; 2 trips
Flutter analyze: passed with no issues
Flutter tests: 5 passed
NestJS build: passed
NestJS typecheck: passed
NestJS unit/e2e suite: 7 suites, 30 tests passed
Staging debug APK: built, 146,569,348 bytes
```

The APK was built with:

```text
https://cameroon-bus-api-staging.onrender.com/api/v1
```

## Architecture check

- One app only: `apps/mobile_app`.
- Role selection comes from backend login response claims.
- Flutter calls the hosted NestJS API only.
- No local database, Supabase URL, database password, or service key is used by
  the APK.
- APK/build outputs remain ignored by Git.

## Remaining validation

Physical-device installation and friend testing are still required. Auth
persistence and full non-passenger workflows are not part of this APK milestone.
