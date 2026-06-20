# APK Build Report

## Phase 10 result

The debug staging APK was built successfully on 2026-06-21.

```text
Path: apps/mobile_app/build/app/outputs/flutter-apk/app-debug.apk
Size: 146,569,348 bytes (about 139.8 MiB)
SHA-256: 617C8B17707363C9CDEB38EF7A9A1D66FCA92525CBD05AA76CB701E8C96357B3
API: https://cameroon-bus-api-staging.onrender.com/api/v1
```

The API URL was supplied at build time through `API_BASE_URL`; no Supabase
credential is present in Flutter.

## Build command

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\build_mobile_staging_apk.ps1 -ApiBaseUrl "https://cameroon-bus-api-staging.onrender.com/api/v1"
```

The script ran `flutter clean`, `flutter pub get`, `flutter analyze`,
`flutter test`, and:

```powershell
flutter build apk --debug --dart-define="API_BASE_URL=https://cameroon-bus-api-staging.onrender.com/api/v1"
```

## Verification

- Flutter analyze: passed with no issues.
- Flutter tests: 5 passed.
- APK existence and SHA-256: verified.
- Hosted API smoke test: passed; database reported reachable.
- Physical Android installation: not yet tested in this workspace.
- APK is a debug build, not a signed release artifact.

## Immediately testable

A tester can install the APK, sign in with a seeded staging account, search real
Buea-to-Bamenda trips, create a booking, confirm demo payment, view eligible
destination taxi areas, and submit a taxi request. Render Free may make the
first request slow after idle.

Agency, dispatcher, driver, and super-admin users route to stable role-specific
placeholder dashboards. Persistent sign-in, refresh-token rotation, complete
booking history, and full non-passenger operations remain future work.
