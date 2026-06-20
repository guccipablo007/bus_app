# Hosted Staging Plan

## Architecture

```text
apps/mobile_app
  -> Render HTTPS API (/api/v1)
  -> Supabase Session Pooler
  -> Supabase PostgreSQL/PostGIS
```

Supabase migrations, seeds, verification, and PostgreSQL adapter tests passed in
Phase 7. Phase 8 prepares Render but performs no deployment.

## Deployment sequence

1. Create the Render service manually or import root `render.yaml`.
2. Configure backend-only environment variables in Render.
3. Deploy only after explicit user approval.
4. Verify `/api/v1/health` reports `database: reachable`.
5. Run `scripts/smoke_test_hosted_api.ps1` against the HTTPS base URL.
6. Give the verified base URL to Phase 9 mobile API integration.
7. Build the staging APK only in the later APK phase.

The APK must never require localhost, Docker, the user's PC, a Supabase key, or
a database connection string.
