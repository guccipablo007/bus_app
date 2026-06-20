# Render API Deployment Guide

## Deployment boundary

This guide prepares a Render Free Web Service. Do not deploy until the user
explicitly approves the manual Render action. The service architecture is:

```text
Flutter APK -> Render HTTPS NestJS API -> Supabase Session Pooler
```

Flutter receives only the public HTTPS API base URL, never database credentials.

## Option A - Render Blueprint

1. Push the repository to a private or appropriately controlled Git provider.
2. In Render, select **New > Blueprint**.
3. Connect the repository containing root `render.yaml`.
4. Review service `cameroon-bus-api-staging` and choose the Free plan.
5. Enter `DATABASE_URL` when Render requests the unsynced value. Use the
   Supabase Session Pooler connection string.
6. Confirm the generated JWT/encryption variables exist.
7. Create the service only after explicit deployment approval.

The blueprint disables automatic deploys and contains no secret values.

## Option B - Manual Web Service

Use these settings:

```text
Runtime: Node
Plan: Free
Root Directory: leave blank (repository root)
Build Command: corepack enable && corepack prepare pnpm@11.8.0 --activate && pnpm install --frozen-lockfile && pnpm --filter api build
Start Command: corepack pnpm --filter api start:prod
Health Check Path: /api/v1/health
Auto-Deploy: Off for staging preparation
```

The service code is under `services/api`, but the root must remain the repository
root so Render can use `pnpm-lock.yaml` and `pnpm-workspace.yaml`.

## Environment variables

Set these only in Render:

| Variable | Value guidance |
|---|---|
| `DATABASE_URL` | Supabase Session Pooler connection string |
| `NODE_ENV` | `staging` |
| `JWT_ACCESS_SECRET` | Independent long random value |
| `JWT_REFRESH_SECRET` | Different independent long random value |
| `ID_ENCRYPTION_KEY` | Random value compatible with future identity encryption |
| `CORS_ORIGINS` | `*` for early mobile staging, then explicit dashboard origins |
| `PORT` | Supplied automatically by Render; local fallback is `3000` |
| `SUPABASE_DATABASE_NOTE` | `Use Session Pooler connection string` |

Never paste these values into Flutter, repository files, build arguments, logs,
or Render build commands. The API fails startup in staging/production when a
required secret or `CORS_ORIGINS` is missing.

## Health and smoke verification

After Render reports a successful deploy, open:

```text
https://YOUR-SERVICE.onrender.com/api/v1/health
```

Expected shape:

```json
{
  "status": "ok",
  "service": "cameroon-bus-api",
  "environment": "staging",
  "database": "reachable"
}
```

Then run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\smoke_test_hosted_api.ps1 -ApiBaseUrl "https://YOUR-SERVICE.onrender.com/api/v1"
```

The script checks health, regions, cities, and a Buea-to-Bamenda trip search.
It does not require login or use database credentials.

## Free-tier behavior

Render Free services may spin down while idle. The first request after idle can
take roughly a minute; the smoke script allows 90 seconds. Cold starts are
acceptable for friend testing but must be communicated to testers.

## Mobile API URL handoff

Once the smoke test passes, Phase 9 can integrate the hosted URL. A later staging
APK build will use:

```powershell
flutter build apk --debug --dart-define=API_BASE_URL=https://YOUR-SERVICE.onrender.com/api/v1
```

Do not build the APK during Phase 8.
