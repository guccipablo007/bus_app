# Cameroon Bus Platform

Android-first inter-regional bus booking platform for Cameroon.

## Active architecture

```text
Flutter Android app (apps/mobile_app)
  -> hosted HTTPS NestJS API (services/api)
  -> Supabase PostgreSQL/PostGIS
```

The MVP uses one role-based Flutter app. Do not create separate passenger,
taxi-driver, or agency-admin apps.

## Workspace

```text
apps/mobile_app               Flutter Android app
services/api                  NestJS API
database/migrations           Reserved for Phase 3
database/seeds                Reserved for Phase 4
database/seed-data            Reserved for Phase 4
packages/shared_types         Shared TypeScript contracts
packages/shared_validation    Shared TypeScript validation helpers
```

Flutter is intentionally outside the pnpm workspace. The pnpm workspace covers
`services/*` and `packages/*`.

## Development

PowerShell currently blocks npm/pnpm `.ps1` shims on this laptop. Use the cmd
wrappers:

```powershell
cmd /c pnpm install
cmd /c pnpm dev:api
```

The API listens under `/api/v1`. Its initial health endpoint is:

```text
GET http://localhost:3000/api/v1/health
```

## Mobile API configuration

Local Android emulator default:

```text
http://10.0.2.2:3000/api/v1
```

Hosted staging builds override it with:

```powershell
flutter build apk --debug --dart-define=API_BASE_URL=https://YOUR-HOSTED-API-DOMAIN/api/v1
```

Expected APK path:

```text
apps/mobile_app/build/app/outputs/flutter-apk/app-debug.apk
```
