  # Agent Handoff

  ## Current phase

  **Phase 12B-A (auth/session) — complete** (GLM 5.2, sessions 3–4).

  Session persistence, improved login flow, profile section enhancements, test
  fixes, and verification checks implemented. This is a sub-phase of Phase 12B;
  full onboarding/document/admin work remains pending.

  ## What was completed

  - Created `SessionStorage` service (SharedPreferences-based persistence).
  - Rewrote `LoginScreen` with demo helper buttons, role selection, session save.
  - Rewrote `SplashScreen` — restores session on app start, auto-routes.
  - Rewrote `AuthCheck` — simplified session-based restoration.
  - Updated `RoleRouterScreen` — added `onLogout` callback, multi-role support.
  - Updated `PassengerHomeShell` — added `onLogout` callback, used by both
    sign-out buttons (app bar and profile).
  - Ran `flutter pub get` — resolved dependencies.
  - Ran `flutter analyze` — **No issues found**.
  - Ran `flutter test` — **5/5 passed** (fixed widget test for new login UI).
  - Ran `pnpm --filter api test` — **7 suites, 30 tests, all passed**.
  - Ran `pnpm --filter api build` — passed.
  - Ran `pnpm --filter api typecheck` — passed.
  - Rebuilt debug APK — **√ Built**.
  - Copied APK to `staging_artifacts/cameroon-bus-staging-debug.apk`.
  - SHA-256: `50ADCBD4A52DEAF9F2E10FA45710AD9B67E444D6EC20359A571A1EE38F26627B`
  - Verified `.gitignore` safety (no secrets, no APK files, no staging_artifacts
    staged).
  - Updated all docs: AGENT_HANDOFF, BUILD_STATUS, NEXT_STEPS, COMMAND_LOG.
  - Committed/pushed safe source and docs changes.

  ## Known issue fixed

  - **Auth tokens were held in memory** — sign-in did not survive app restart.
    ✅ Now fixed. `SessionStorage` persists access token, profile, and roles.
    SplashScreen restores session automatically.

  ## Known production concerns (not blockers)

  - `SharedPreferences` is acceptable for **staging** but **must** be replaced
    with `flutter_secure_storage` before any production or release-APK build.
  - Non-passenger dashboards (agency, dispatcher, driver, super-admin) remain
    at placeholder/incomplete level unless explicitly improved.
  - Full company onboarding, identity-document upload, and admin-approval
    workflows are **not yet implemented**.

  ## Files created / changed

  - `apps/mobile_app/lib/services/session_storage.dart` — **created**
  - `apps/mobile_app/lib/auth/login_screen.dart` — **rewritten**
  - `apps/mobile_app/lib/auth/splash_screen.dart` — **rewritten**
  - `apps/mobile_app/lib/auth/auth_check.dart` — **rewritten**
  - `apps/mobile_app/lib/navigation/role_router_screen.dart` — **rewritten**
  - `apps/mobile_app/lib/features/passenger/passenger_home_shell.dart` — **updated**
    (added `onLogout` callback, improved profile sign-out)
  - `apps/mobile_app/test/widget_test.dart` — **fixed** (updated login widget
    expect matches to match new UI text)
  - `docs/BUILD_STATUS.md` — updated
  - `docs/AGENT_HANDOFF.md` — updated
  - `docs/NEXT_STEPS.md` — updated
  - `docs/COMMAND_LOG.md` — updated

  ## Commands run (this session)

  ```powershell
  # Flutter checks
  cd apps\mobile_app && flutter pub get            # Got dependencies
  cd apps\mobile_app && flutter analyze            # No issues found
  cd apps\mobile_app && flutter test               # 5/5 passed

  # Backend checks
  cmd /c pnpm --filter api test                    # 7 suites, 30 tests, all passed
  cmd /c pnpm --filter api build                   # nest build — passed
  cmd /c pnpm --filter api typecheck               # tsc --noEmit — 0 errors

  # Git safety
  git status                                       # Clean — no secrets, APKs, or artifacts

  # Git commit and push
  git add -A                                        # Source + docs only
  git commit -m "Improve auth entry and persistent session"
  git push origin main
  ```

  ## Verification results

  | Check | Result |
  |-------|--------|
  | `flutter pub get` | ✅ resolved |
  | `flutter analyze` | ✅ no issues found |
  | `flutter test` | ✅ 5/5 passed |
  | `pnpm --filter api test` | ✅ 7 suites, 30 tests passed |
  | `pnpm --filter api build` | ✅ nest build passed |
  | `pnpm --filter api typecheck` | ✅ tsc --noEmit, 0 errors |
  | `git status` safety check | ✅ no secrets/APKs staged |
  | APK path | `staging_artifacts/cameroon-bus-staging-debug.apk` |
  | APK SHA-256 | `50ADCBD4A52DEAF9F2E10FA45710AD9B67E444D6EC20359A571A1EE38F26627B` |

  ## Known issues remaining

  - No `test/` directory in `apps/mobile_app` — test folder not yet scaffolded.
  - Non-passenger dashboards are safe placeholders, not operational workflows.
  - Render Free cold starts can delay the first API request (10–30 s).
  - SharedPreferences used for staging; must be replaced with
    `flutter_secure_storage` for production.
  - Full company onboarding, document upload, and admin approval still pending.
  - No identity-document upload or ID verification workflow exists yet.
  - Non-passenger dashboards are placeholder-level only unless improved.

  ## Exact next task

  **BlueStacks / physical-device QA.**
  Install the APK, test all passenger flows (login, trip search, booking, taxi
  eligibility), and report any issues. See `docs/friend_testing_guide.md` for
  instructions.

  The friend-testing package is ready:
  - APK: `staging_artifacts/cameroon-bus-staging-debug.apk`
  - SHA-256: `staging_artifacts/APK_CHECKSUM.txt`

  ## Secrets still needed

  None. The APK connects to the hosted Render API. No Supabase credentials,
  database passwords, or JWT secrets are in the repository or the APK.
