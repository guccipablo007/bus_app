# Next Steps

## ✅ Completed this session (Phase 12B-A — Auth/Session)

- **SessionStorage service** — `apps/mobile_app/lib/services/session_storage.dart`
  SharedPreferences-based persistence for access token, profile, and roles.
- **LoginScreen rewrite** — demo helper buttons, role picker for multi-role
  users, saves session to storage on success.
- **SplashScreen rewrite** — checks SessionStorage for existing session,
  auto-routes to RoleRouterScreen or login.
- **AuthCheck rewrite** — simplified, session-based restoration with loading
  spinner.
- **RoleRouterScreen update** — onLogout callback, multi-role user selection,
  clears session on sign-out.
- **PassengerHomeShell update** — accepts onLogout callback, uses it in both
  the app bar sign-out and profile sign-out buttons.
- **Widget test fixed** — updated expect matches to match new login UI text.
- **Verification checks:**
  - `flutter pub get` — resolved
  - `flutter analyze` — no issues found
  - `flutter test` — 5/5 passed
  - `pnpm --filter api test` — 7 suites, 30 tests, all passed
  - `pnpm --filter api build` — passed
  - `pnpm --filter api typecheck` — passed
- **Git safety** — verified: no secrets, APK files, or staging_artifacts staged
- **Commit:** `Improve auth entry and persistent session` (pushed to origin/main)
- **Phase note:** This is Phase 12B-A only. Full company onboarding, document
  upload, and admin approval are still pending. Non-passenger dashboards remain
  placeholder-level unless explicitly improved.
- **SharedPreferences note:** Acceptable for staging; must be replaced with
  `flutter_secure_storage` before any production/release build.

## Immediate — Physical-device / BlueStacks QA

The APK is ready. The friend-testing package is in `staging_artifacts/`:

1. Install `staging_artifacts/cameroon-bus-staging-debug.apk` on BlueStacks or
   a physical Android device.
2. See `docs/friend_testing_guide.md` for setup instructions.
3. Verify these flows:
   - **Login** — both demo helpers and manual sign-in
   - **Session persistence** — close app, reopen; should still be logged in
   - **Trip search** — search Buea → Bamenda
   - **Booking** (if backend supports it in current staging state)
   - **Taxi eligibility** — check after paid/confirmed booking
   - **Sign out** — confirm session clears and login screen returns
4. Record issues and report back.

## Product follow-up

- Replace `SharedPreferences` with `flutter_secure_storage` for production.
- Implement refresh-token rotation and logout invalidation in the API.
- Build full company onboarding, document upload, and admin approval flow.
- Build real agency, dispatcher, driver, and super-admin operations (currently
  placeholder or incomplete).
- Add identity-document upload and ID verification workflow.
- Add device-level integration tests and accessibility checks.
- Create release signing only after explicit user approval.

Do not commit the APK or add Supabase credentials to Flutter. A release APK and
keystore are intentionally outside the current scope.
