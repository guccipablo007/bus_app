# APK Build Report

## Current APK target

```text
apps/mobile_app/build/app/outputs/flutter-apk/app-debug.apk
```

## Current status

No APK has been built yet.

Reason:

- Phase 2 explicitly prohibited APK builds.
- Flutter app now exists at `apps/mobile_app`.
- Flutter analyze and tests pass.
- Flutter doctor reports no issues.
- Build scripts are prepared for later APK phases.

## Required local debug build

After `apps/mobile_app` exists:

```powershell
cd apps/mobile_app
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

## Required staging build

```powershell
cd apps/mobile_app
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --debug --dart-define=API_BASE_URL=https://YOUR-HOSTED-API-DOMAIN/api/v1
```

## Definition of done

- APK exists at `apps/mobile_app/build/app/outputs/flutter-apk/app-debug.apk`.
- APK opens on Android.
- APK points to hosted HTTPS API for friend testing.
- APK does not require localhost.
- APK does not require Docker.
- APK does not connect directly to Supabase.
