# Hosted Staging Plan

## Architecture

```text
apps/mobile_app
  -> Render HTTPS API (/api/v1)
  -> Supabase Session Pooler
  -> Supabase PostgreSQL/PostGIS
```

Supabase migrations, seeds, verification, and PostgreSQL adapter tests passed in
Phase 7. The Render HTTPS deployment and hosted smoke test passed in Phase 8.

Verified API base URL:

```text
https://cameroon-bus-api-staging.onrender.com/api/v1
```

## Deployment sequence

1. Render service created from root `render.yaml`.
2. Backend-only environment variables configured in Render.
3. `/api/v1/health` verified with `database: reachable`.
4. Public location and Buea-to-Bamenda trip endpoints verified.
5. Use the verified base URL for Phase 9 mobile API integration.
6. Build the staging APK only in the later APK phase.

The APK must never require localhost, Docker, the user's PC, a Supabase key, or
a database connection string.
