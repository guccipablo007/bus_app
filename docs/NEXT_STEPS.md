# Next Steps

## Immediate device test

1. Transfer the ignored debug APK from
   `apps/mobile_app/build/app/outputs/flutter-apk/app-debug.apk`.
2. Install it on an Android device after permitting installation from the file
   source when Android requests it.
3. Confirm the splash and login screens open without a crash.
4. Use the seeded passenger staging login.
5. Search Buea to Bamenda and confirm live trip results appear.
6. Create a booking, confirm demo payment, and verify ticket details.
7. Load eligible Bamenda taxi areas and submit a destination request.
8. Record Render cold-start time, Android version, and any UI/network errors.

## Product follow-up

- Persist access/refresh tokens using secure device storage.
- Implement refresh-token rotation and logout invalidation in the API.
- Add persistent booking history and recovery after app restart.
- Build real agency, dispatcher, driver, and super-admin operations.
- Add device-level integration tests and accessibility checks.
- Create release signing only after explicit user approval.

Do not commit the APK or add Supabase credentials to Flutter. A release APK and
keystore are intentionally outside the completed Phase 10 scope.
