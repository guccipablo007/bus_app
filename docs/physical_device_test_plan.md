# Physical Device Test Plan

## Artifact

```text
APK: staging_artifacts/cameroon-bus-staging-debug.apk
SHA-256: FB3B158A216F1ABB2D0738FD68DA2FC4801BE9F46275EB34935DB02C21EB658F
```

## Blocking sign-out matrix

For each role below, login, tap Sign out, confirm login appears, press Android
Back, and restart the app. The protected dashboard must never return.

1. Passenger: test the app-bar icon and Profile `Sign out` button separately.
2. Agency owner: test the app-bar sign-out icon.
3. Taxi driver: test the app-bar sign-out icon.
4. Super admin: test the app-bar sign-out icon beside Refresh.

Also verify passenger session restore still works before signing out, and that
signing in again after logout works normally. Then rerun booking/payment/ticket,
taxi request, onboarding submission, My Applications, and admin review smoke QA.
