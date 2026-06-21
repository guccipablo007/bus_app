# APK Build Report

## Phase 12B-A1 rebuild

```text
Source: apps/mobile_app/build/app/outputs/flutter-apk/app-debug.apk
Testing copy: staging_artifacts/cameroon-bus-staging-debug.apk
Size: 185,439,241 bytes (about 176.8 MiB)
SHA-256: 481417420244873900F2E5BE25144C1F09744DA1189B9973F9CC5628B503E869
API: https://cameroon-bus-api-staging.onrender.com/api/v1
```

```powershell
flutter build apk --debug --dart-define=API_BASE_URL=https://cameroon-bus-api-staging.onrender.com/api/v1
```

The source and copied artifact match by size and hash. Both are ignored by Git.
This is a debug APK and no release keystore was created.

Before build: hosted health/login, Flutter analyze, 11 Flutter tests, 30 API
tests, API build, and API typecheck all passed. BlueStacks retesting remains.
