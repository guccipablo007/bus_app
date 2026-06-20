# Seed Data Plan

## Status

Phase 4 seed preparation is complete. Seeds have not been run and no database
connection was made.

## Ordered seed files

1. `001_seed_roles.sql`
2. `002_seed_regions_cities.sql`
3. `003_seed_demo_agency_and_staff.sql`
4. `004_seed_terminals.sql`
5. `005_seed_buses_and_seats.sql`
6. `006_seed_routes_and_trips.sql`
7. `007_seed_residential_areas.sql`
8. `008_seed_terminal_area_distances.sql`
9. `009_seed_demo_users.sql`

## Included data

- Seven application roles.
- Five launch regions and eight launch cities.
- Unity Express Demo agency.
- Five demo terminals with approximate PostGIS points.
- 30-seat, 50-seat, and 70-seat buses.
- 150 seats generated with `generate_series`.
- Fourteen required routes.
- Two rolling near-future trips per route using `CURRENT_DATE`.
- Thirty-five residential areas with approximate PostGIS center points.
- Mixed active/inactive and verified/unverified taxi areas.
- Terminal-area distances calculated with `ST_Distance`.
- Taxi-zone activity calculated with `ST_DWithin(..., 15000)`.
- Seven synthetic role-test users.
- Demo agency memberships, one demo taxi vehicle, and one demo taxi driver.
- No identity document rows or real personal data.

## Idempotency

- Stable region codes, agency registration number, auth subjects, vehicle
  registrations, and scoped names are used as natural keys.
- `ON CONFLICT` updates or preserves existing seed records.
- Trip instances use `WHERE NOT EXISTS` for route/departure uniqueness.
- Rolling trip dates may add a new future window when rerun on a later day;
  reruns on the same day do not duplicate the same departures.

## Warnings

- `database/seed-data/seed_coordinates_warning.md`
- `database/seed-data/demo_credentials_warning.md`

Coordinates and accounts are staging-only. Demo password hashes may need
regeneration if backend authentication adopts a different hash mechanism.

## Static validation

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\validate_seed_files.ps1
```

## Future execution

Do not execute until the staging phase and explicit user approval.

The prepared command is:

```powershell
$env:DATABASE_URL="postgresql://..."
cmd /c pnpm db:seed:staging
```

The runner requires `-ConfirmStaging`, stops on the first SQL error, prints
only seed filenames, and never prints the connection string.
