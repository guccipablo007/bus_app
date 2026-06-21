# Agent Handoff

## Current phase

Phase 12B-D1 complete: app-wide sign-out regression fixed.

## Root cause

`AuthCheck` created a correct clear-and-navigate callback, but
`RoleRouterScreen.shellFor` did not pass it into any role shell. Passenger
buttons also returned a callback from `onPressed` instead of invoking it.
Fallback dashboard logout only navigated and did not clear persisted session,
and super admin had no sign-out action.

## Completed

- Added shared `AppLogout.perform` coordinator.
- Logout clears stored session and selected role before navigation.
- Root navigator is replaced with login; Android Back cannot reopen a dashboard.
- Routed the same callback through passenger, agency, dispatcher, driver,
  super-admin, and multi-role selection paths.
- Fixed both passenger sign-out buttons and added super-admin sign out.
- Fixed clean-start Splash login to retain the created SessionStorage instance.
- Added logout persistence/navigation/restart tests across role shells.

## Verification

```text
Flutter analyze: no issues
Flutter tests: 22 passed
API tests: 30 passed
API build/typecheck: passed
APK build: passed with hosted API dart-define
```

## APK

```text
Path: staging_artifacts/cameroon-bus-staging-debug.apk
Size: 185,439,241 bytes
SHA-256: FB3B158A216F1ABB2D0738FD68DA2FC4801BE9F46275EB34935DB02C21EB658F
```

## Exact next task

Replace the BlueStacks APK, clear old app data, and run the sign-out matrix in
`docs/physical_device_test_plan.md` before any new feature work.

## Secrets needed

None.
