# Database Schema

## Target

The schema targets hosted Supabase PostgreSQL/PostGIS. No database connection
was made in Phase 3 and no local container database is used.

## Migration order

1. `001_extensions_and_enums.sql`
2. `002_users_roles_and_auth.sql`
3. `003_regions_cities_agencies_terminals.sql`
4. `004_buses_routes_trips.sql`
5. `005_bookings_payments_tickets.sql`
6. `006_residential_areas_taxi_zones.sql`
7. `007_audit_indexes_and_security.sql`

## Extensions

```sql
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
```

Supabase commonly stores extensions in an `extensions` schema. The migrations
reuse any existing extension and do not attempt to move it.

## Tables

Identity and roles:

- `users`
- `roles`
- `user_roles`
- `passenger_profiles`
- `identity_documents`

Network and agencies:

- `regions`
- `cities`
- `agencies`
- `agency_staff`
- `terminals`

Trips:

- `buses`
- `bus_seats`
- `routes`
- `trip_instances`

Bookings:

- `bookings`
- `booking_passengers`
- `trip_seat_locks`
- `payments`
- `tickets`

Taxi add-on:

- `residential_areas`
- `terminal_area_distances`
- `taxi_vehicles`
- `taxi_drivers`
- `taxi_rides`

Operations:

- `audit_logs`

## Role model

`roles` and `user_roles` support multiple roles per user:

- `passenger`
- `agency_owner`
- `agency_admin`
- `agency_staff`
- `taxi_dispatcher`
- `taxi_driver`
- `super_admin`

The backend remains the authorization source of truth and later returns role
claims such as `roles: ["passenger"]`.

## Geography

```sql
terminals.location geography(Point, 4326)
residential_areas.center_point geography(Point, 4326)
residential_areas.boundary geography(Polygon, 4326)
```

GiST indexes support terminal and residential-area proximity queries.

## Integrity rules

- UUID primary keys use `gen_random_uuid()`.
- Operational timestamps use `timestamptz`.
- `trip_seat_locks` has `UNIQUE (trip_instance_id, seat_id)`.
- Seat-lock triggers verify that the seat belongs to the trip bus and booking.
- One ticket is allowed per booking passenger.
- Ticket QR values are globally unique.
- Route terminals and trip buses must match agency ownership.
- Taxi rides require booking, passenger, pickup terminal, and destination area.
- Taxi eligibility trigger verifies paid/confirmed booking, arrival terminal,
  destination city, agency ownership, active/verified area, and 15 km limit.

## Identity documents

`identity_documents.encrypted_document_number` is a required `bytea` value.
An optional keyed hash can support duplicate detection. Plain ID numbers must
never be written to logs, documentation, or audit metadata.

## Validation

Run static validation without a database connection:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\validate_migration_files.ps1
```

## Phase 4 seed compatibility

Ordered seeds in `database/seeds` follow migration foreign-key order and use
schema-supported natural keys. They rely on:

- Unique role codes and region codes.
- Unique agency registration number.
- Scoped terminal, bus, route, area, vehicle, and user keys.
- PostGIS `ST_MakePoint`, `ST_Distance`, and `ST_DWithin`.
- `CURRENT_DATE` for near-future trip generation.

The seeds intentionally omit bookings, payments, tickets, taxi rides, and
identity documents; those records belong to later API workflow tests.
