# Database Migrations

These ordered SQL migrations target Supabase PostgreSQL/PostGIS.

## Extension assumption

PostGIS should be enabled in Supabase before schema deployment. Migration
`001_extensions_and_enums.sql` still uses safe guards:

```sql
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
```

Supabase commonly keeps extensions in an `extensions` schema. The guards are
unqualified so an existing extension is reused without attempting to move it.
The Supabase database search path must make extension functions and types
available, which is the standard Supabase configuration. Do not relocate an
existing extension during application migrations.

`008_onboarding_applications.sql` adds agency/driver applications and staging
document metadata. It is additive and does not create agencies, drivers, or
roles when an application is approved.

## Order

Run files in numeric filename order:

1. `001_extensions_and_enums.sql`
2. `002_users_roles_and_auth.sql`
3. `003_regions_cities_agencies_terminals.sql`
4. `004_buses_routes_trips.sql`
5. `005_bookings_payments_tickets.sql`
6. `006_residential_areas_taxi_zones.sql`
7. `007_audit_indexes_and_security.sql`

## Deployment safety

- Do not run these migrations until the user provides `DATABASE_URL` in the
  staging deployment phase.
- Keep `DATABASE_URL` in the process environment only.
- Never commit database passwords, Supabase service keys, JWT secrets, or ID
  encryption keys.
- Never run a destructive Supabase reset without explicit user approval.
- The Flutter app must call the hosted NestJS API and must not access Supabase
  tables directly.

## Phase 3 validation

Phase 3 performs static file validation only:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\validate_migration_files.ps1
```

No database connection or migration execution occurs in that script.
