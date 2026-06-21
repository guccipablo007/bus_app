# Next Steps

## ✅ Completed this session

- **Docs created:**
  - `docs/physical_device_test_plan.md` — detailed QA checklist
  - `docs/friend_testing_guide.md` — end-user testing guide
  - `docs/staging_known_limitations.md` — exhaustive limitation list
- **Scripts created:**
  - `scripts/install_mobile_apk_usb.ps1` — adb USB install
  - `scripts/prepare_friend_testing_package.ps1` — APK packaging + checksum
- **Updated `.gitignore`** — ignores `staging_artifacts/` and `*.apk`
- **Friend-testing package prepared:**
  - APK → `staging_artifacts/cameroon-bus-staging-debug.apk`
  - SHA-256 → `staging_artifacts/APK_CHECKSUM.txt`
- **Full verification passed:**
  - `flutter doctor`, `flutter analyze`, API `build`, API `typecheck`, API `test` (30/30)
- **Docs updated:** AGENT_HANDOFF, BUILD_STATUS, NEXT_STEPS, COMMAND_LOG

## Immediate — Physical-device QA

The APK is ready. The friend-testing package is in `staging_artifacts/`:

1. Share `staging_artifacts/cameroon-bus-staging-debug.apk` with testers.
2. Direct testers to `docs/friend_testing_guide.md` for instructions.
3. For USB-connected devices, run:
   ```
   .\scripts\install_mobile_apk_usb.ps1
   ```
4. Record:
   - Render cold-start time (first API call)
   - Android version and phone model
   - Any UI/network errors
   - Successful booking and taxi eligibility flows

## VS Code workspace (✅ completed)

- `.vscode/extensions.json` — 13 recommended extensions configured.
- `.vscode/settings.json` — project-wide editor/formatter/lint settings.
- All checks pass.

## Product follow-up

- Persist access/refresh tokens using secure device storage.
- Implement refresh-token rotation and logout invalidation in the API.
- Add persistent booking history and recovery after app restart.
- Build real agency, dispatcher, driver, and super-admin operations.
- Add device-level integration tests and accessibility checks.
- Create release signing only after explicit user approval.

Do not commit the APK or add Supabase credentials to Flutter. A release APK and
keystore are intentionally outside the completed Phase 10 scope.
