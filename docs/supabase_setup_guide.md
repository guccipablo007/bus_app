# Supabase Setup Guide

## Purpose

Supabase is the hosted staging database. This project has no local container
database, and Flutter must never receive database credentials.

## Approved connection flow

Use the Supabase Session Pooler connection string as `DATABASE_URL` in the
current backend/runner process. Do not use the direct string from networks that
cannot reach it, or the Project URL, publishable key, anon key, or service-role
key for migrations.

Never place the value in source, docs, shell history, `.env.example`, Flutter,
or build-time Dart defines. The local `supabase.txt` file is ignored.

## Ordered staging commands

After setting `DATABASE_URL` process-only:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\push_supabase_schema.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\seed_supabase_staging.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\verify_supabase_staging.ps1
cmd /c pnpm --filter api test:integration
```

Run seeds only after migrations succeed. Both PostGIS and pgcrypto are created
by the first ordered migration and checked by verification.

## Current status

Migrations, seeds, extension checks, expected counts, and PostgreSQL adapter
integration tests all pass through the Session Pooler. Phase 8 can use the same
pooler value as a backend-only hosted environment variable.
