# Security Rules

## Secrets

Never commit:

- Supabase `DATABASE_URL`
- database password
- Supabase service role key
- JWT secrets
- ID encryption key
- Android keystore files
- keystore passwords

## Mobile app

The Flutter app must not contain:

- Supabase database password.
- Supabase service role key.
- hardcoded privileged roles.
- production secrets.

The mobile app calls only:

```text
hosted HTTPS NestJS API
```

## Backend authorization

Every protected endpoint must enforce permissions on the backend.

Frontend role hiding is not security.

Examples:

- Passenger cannot access agency booking manifests.
- Taxi driver cannot access rides not assigned to them.
- Agency staff cannot access another agency's data.
- Taxi dispatcher can assign rides only for authorized agency scope.
- Super admin actions require `super_admin`.

## Hosted API implementation

- Access JWTs contain backend-issued roles and are verified by `JwtAuthGuard`.
- `RolesGuard` checks route metadata; passenger booking/taxi routes require the
  `passenger` role.
- Booking ownership is rechecked in the service for every booking and taxi action.
- `AgencyScopeGuard` and `DriverAssignmentGuard` provide explicit structures
  for later agency and assigned-ride endpoints.
- Passwords are hashed with bcrypt and never returned by the API.
- Development/test secrets are random, process-local values. Staging and
  production fail startup when required secrets or `DATABASE_URL` are absent.
- Validation strips unknown input and rejects non-whitelisted fields.
- API errors use a consistent envelope and omit internal stack traces.
- Business-rule failures use `422`; unique seat conflicts use `409`.
- HTTP tests prove missing JWTs return `401`, wrong roles and ownership return
  `403`, missing resources return `404`, and malformed DTOs return `400`.
- Hosted health reports only `reachable`/`unreachable` and never prints database
  configuration or connection errors.

## Role source of truth

The backend is the role source of truth.

Login response returns:

```json
{
  "user": {
    "roles": ["passenger"]
  }
}
```

The app uses these roles only for navigation. The backend still verifies permissions for every protected request.

## Taxi security

Taxi ride creation must require:

- authenticated passenger.
- passenger-owned booking.
- paid or confirmed booking.
- pickup terminal equal to booking arrival terminal.
- destination area in booking destination city.
- active and verified destination area.
- destination area within 15 km.

## Identity documents

For staging:

- Avoid identity document image upload.
- Do not log document numbers.
- Store document numbers securely if required for MVP.

## Database access and RLS

The migrations are designed for backend-only table access:

- Do not expose `DATABASE_URL` or Supabase service credentials to Flutter.
- Do not use the Supabase Flutter client for direct table access.
- The hosted NestJS API owns authentication, agency scoping, ownership checks,
  and role guards.
- RLS policies can be added later only if direct Supabase Data API exposure is
  deliberately introduced and tested.
- RLS does not replace backend authorization.

Phase 3 migration comments record these assumptions. No credentials, grants,
or permissive RLS policies were added.

Phase 7 used the Supabase Session Pooler from temporary process environments.
Phase 8 keeps the same value exclusively in Render's backend environment.

## PostgreSQL adapter

The PostgreSQL `BookingRepository` performs booking/seat-lock writes in a
database transaction and relies on the unique trip-seat constraint across API
processes. Ticket creation relies on database uniqueness for one ticket per
booking passenger and globally unique QR values.

Supabase credentials belong only in backend environment variables. They must
never appear in Flutter source, Dart defines, logs, committed files, or mobile
network requests. Flutter role routing remains presentation logic, not security.

## Seed security

- Demo users use synthetic `@cameroonbus.test` addresses.
- SQL contains bcrypt hashes, not plaintext demo passwords.
- The staging plaintext appears only in
  `database/seed-data/demo_credentials_warning.md`.
- Identity documents and real passenger ID numbers are not seeded.
- Coordinates and demo credentials are explicitly staging-only.
- `run_sql_files_with_pg.mjs` reads `DATABASE_URL` only from the environment
  and never prints it.
- `run_supabase_seeds.ps1` requires `-ConfirmStaging`.
- Seed execution completed in Phase 7. Do not rerun or reset staging during
  hosted deployment preparation unless explicitly approved.
