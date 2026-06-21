# Build Status

## Phase 12B-A1

Hosted login connectivity regression fixed and debug staging APK rebuilt.

```text
Hosted health: ok; database reachable
Hosted passenger login: HTTP 200
Flutter analyze: no issues
Flutter tests: 11 passed
API tests: 7 suites, 30 passed
API build/typecheck: passed
APK size: 185,439,241 bytes
APK SHA-256: 481417420244873900F2E5BE25144C1F09744DA1189B9973F9CC5628B503E869
```

Build command:

```powershell
flutter build apk --debug --dart-define=API_BASE_URL=https://cameroon-bus-api-staging.onrender.com/api/v1
```

The app default is also hosted staging, preventing an accidental plain debug
build from silently targeting BlueStacks host loopback. Local API testing must
pass its URL explicitly with `--dart-define`.

One app remains at `apps/mobile_app`. No backend, database schema, deployment,
keystore, or secret changed.
