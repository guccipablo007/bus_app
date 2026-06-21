# APK Build Report

```text
Path: staging_artifacts/cameroon-bus-staging-debug.apk
Size: 185,439,241 bytes (about 176.8 MiB)
SHA-256: 0B2B6C31E67006ADC9F06ECF305095E4BCED3605C0E1ADCE0E393F9B4FD4694F
API: https://cameroon-bus-api-staging.onrender.com/api/v1
```

Built with:

```powershell
flutter build apk --debug --dart-define=API_BASE_URL=https://cameroon-bus-api-staging.onrender.com/api/v1
```

All Flutter/backend checks passed first. The APK is ignored and debug-signed.
Onboarding calls require migration `008` and a Render redeploy before device QA.
