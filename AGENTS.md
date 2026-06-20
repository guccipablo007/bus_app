# AGENTS.md — Cameroon Bus Booking App Build Brief

## Active architecture note

The active MVP architecture is the later "Single App, Role-Based Interfaces, Glassmorphism UI" update in this file.

Use one Flutter Android app only:

```text
apps/mobile_app
```

Do not scaffold separate MVP apps at:

```text
apps/passenger_app
apps/taxi_driver_app
apps/agency_admin
```

After login, route users by backend-provided roles:

```text
passenger -> PassengerHomeShell
agency_owner / agency_admin / agency_staff -> AgencyShell
taxi_dispatcher -> TaxiDispatcherShell
taxi_driver -> TaxiDriverShell
super_admin -> SuperAdminShell
```

Use Flutter Material 3 with a simple, modern, stylish, intuitive glassmorphism-inspired UI.

Use Supabase as the hosted staging database. Do not use a local container database for this project. The final APK must connect to a hosted HTTPS API, never localhost or Supabase database credentials directly.

---

## Project root

Use this exact Windows folder as the project root:

```text
C:\Users\Administrator\Documents\my_busapp
```

Do not create a nested `cameroon-bus-app` or `bus_app` folder inside it. Build directly inside `my_busapp`.

---

# 1. Agent workflow: Codex first, Cline fallback

This project will be built first with Codex. If Codex credits run out, Cline will continue from the same folder.

The project must therefore be easy for another coding agent to continue. Maintain these handoff files at all times:

```text
docs/AGENT_HANDOFF.md
docs/BUILD_STATUS.md
docs/NEXT_STEPS.md
docs/COMMAND_LOG.md
docs/DECISIONS.md
```

After every major phase, update `docs/AGENT_HANDOFF.md` with:

```text
Current phase
What was completed
Files changed
Commands run
Tests passed/failed
Known issues
Exact next task
Secrets still needed from the user
```

Do not assume the next agent has memory of previous chat context. Everything important must be written into the project docs.

---

# 2. Product goal

Build an Android-first Cameroon inter-regional bus booking platform.

The main goal is not just local code. The final deliverable is:

```text
A shareable Android APK that can be sent to friends for testing.
```

The APK must connect to a hosted staging backend, not localhost.

Correct testing architecture:

```text
Android APK
  -> hosted HTTPS NestJS API
  -> hosted Supabase PostgreSQL/PostGIS database
```

Local Docker is allowed only as a development mirror, not as the final testing backend.

---

# 3. Main regions and cities

Launch regions:

```text
South West
North West
Littoral
West
Centre
```

Launch cities:

```text
Buea
Limbe
Kumba
Bamenda
Douala
Bafoussam
Dschang
Yaoundé
```

---

# 4. User interfaces

Build three product surfaces:

## 4.1 Passenger Android app

Framework:

```text
Flutter
```

Final APK target:

```text
apps/passenger_app/build/app/outputs/flutter-apk/app-debug.apk
```

Passenger must eventually be able to:

```text
Register/login
Provide phone number
Provide email address
Provide ID type and ID number
Search inter-regional bus trips
Select route/date/bus/seat
Create booking
Pay or use staging/manual payment simulation
Receive ticket/QR code
See eligible taxi add-on only after paid/confirmed booking
Book destination taxi if eligible
```

## 4.2 Bus agency/admin dashboard

Framework:

```text
Next.js
```

Agency/admin must eventually be able to:

```text
Manage agency profile
Manage terminals
Manage buses
Manage seat layouts
Manage routes
Manage trip schedules
View bookings
View passenger manifests
Validate tickets
Manage taxi zones
Manage taxi vehicles/drivers
Assign taxi rides
```

## 4.3 Taxi driver app

Framework:

```text
Flutter
```

Taxi driver must eventually be able to:

```text
Login
View assigned rides
See pickup terminal
See passenger contact
See approved destination area
Start ride
Complete ride
Report issue/no-show
```

---

# 5. Critical business rule: taxi is tied to final bus destination

The taxi service is not a general taxi marketplace.

It is an extra service operated by the bus agency itself.

A passenger can only book an agency taxi if they have a paid or confirmed inter-regional bus booking.

Example:

```text
Passenger books: Buea -> Bamenda
Taxi can only be: Bamenda arrival terminal -> approved Bamenda residential area
```

The passenger must not be allowed to book:

```text
Taxi in Buea
Taxi in Douala
Taxi in Yaoundé
Taxi in any unrelated city
Taxi to inactive residential area
Taxi to unverified residential area
Taxi beyond about 15 km from the arrival terminal
```

This rule must be enforced in the backend. Do not rely on frontend hiding alone.

---

# 6. Hosted staging requirement

The user wants friends to install and test the APK remotely.

Therefore, local URLs are not enough.

Bad final testing config:

```text
http://localhost:3000
http://10.0.2.2:3000
http://192.168.x.x:3000
```

Those are only for local development.

Correct friend-testing config:

```text
https://YOUR-HOSTED-API-DOMAIN/api/v1
```

Use `--dart-define` or equivalent build-time config so the APK can be built for staging:

```powershell
flutter build apk --debug --dart-define=API_BASE_URL=https://YOUR-HOSTED-API-DOMAIN/api/v1
```

The APK must never connect directly to Supabase using database credentials.

Correct flow:

```text
Flutter APK -> hosted NestJS API -> Supabase Postgres/PostGIS
```

Wrong flow:

```text
Flutter APK -> Supabase database directly with secret key
```

---

# 7. Infrastructure choice

## 7.1 Hosted database

Use:

```text
Supabase Free PostgreSQL
PostGIS extension enabled
```

Supabase project already planned/name:

```text
cameroon-bus-staging
```

PostGIS must be enabled before migrations are pushed.

Required extensions:

```sql
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
```

Use Supabase as hosted staging database.

Do not commit Supabase connection strings, database passwords, anon keys, service role keys, or JWT secrets.

Use environment variables only.

## 7.2 Hosted backend

Use one free backend host first:

Preferred:

```text
Render Free Web Service
```

Alternative:

```text
Vercel serverless if the NestJS deployment is adapted correctly
```

Render Free has cold-start/spin-down behavior, so document it clearly. It is acceptable for friend testing but not final production.

## 7.3 Local database

Optional but useful:

```text
Docker PostgreSQL + PostGIS
```

Local Docker should remain a development mirror only.

Do not make the shareable APK depend on Docker, localhost, or the user's PC.

---

# 8. Monorepo structure

Create this structure directly under:

```text
C:\Users\Administrator\Documents\my_busapp
```

Required structure:

```text
apps/
  passenger_app/
  taxi_driver_app/
  agency_admin/

services/
  api/

database/
  migrations/
  seeds/
  seed-data/
  init/

packages/
  shared_types/
  shared_validation/

docs/
  AGENT_HANDOFF.md
  BUILD_STATUS.md
  NEXT_STEPS.md
  COMMAND_LOG.md
  DECISIONS.md
  product_plan.md
  hosted_staging_plan.md
  supabase_setup_guide.md
  render_api_deployment_guide.md
  database_schema.md
  taxi_zone_rules.md
  api_contract.md
  security_rules.md
  apk_build_report.md
  seed_data_plan.md

scripts/
  check_environment.ps1
  check_environment.sh
  build_passenger_debug_apk.ps1
  build_passenger_staging_apk.ps1
  push_supabase_schema.ps1
  seed_supabase_staging.ps1
  db_reset_and_seed.ps1
  db_reset_and_seed.sh
```

Root files:

```text
package.json
pnpm-workspace.yaml
.env.example
.gitignore
docker-compose.yml
README.md
AGENTS.md
```

---

# 9. Environment audit first

Before scaffolding code, inspect the machine and create:

```text
docs/environment_report.md
```

Check:

```powershell
git --version
node -v
npm -v
pnpm -v
flutter --version
dart --version
java -version
adb --version
docker --version
docker compose version
supabase --version
psql --version
echo $env:ANDROID_HOME
echo $env:JAVA_HOME
flutter doctor -v
```

If a command fails, document it clearly.

Do not install random tools without asking. If a required tool is missing, document the missing tool and request permission.

Required tools:

```text
Git
Node.js
pnpm
Flutter
Dart
Java JDK 17+
Android SDK / adb
Docker optional for local mirror
Supabase CLI useful for hosted database workflow
```

---

# 10. Backend API

Framework:

```text
NestJS
```

Path:

```text
services/api
```

API base path:

```text
/api/v1
```

Required modules:

```text
AuthModule
UsersModule
RegionsModule
CitiesModule
AgenciesModule
TerminalsModule
BusesModule
RoutesModule
TripsModule
BookingsModule
PaymentsModule
TicketsModule
ResidentialAreasModule
TaxiZonesModule
TaxiRidesModule
TaxiDriversModule
AuditLogsModule
```

Required initial endpoints:

```http
GET /api/v1/health
POST /api/v1/auth/register
POST /api/v1/auth/login
GET /api/v1/regions
GET /api/v1/cities
GET /api/v1/trips/search
POST /api/v1/bookings
POST /api/v1/bookings/:bookingId/confirm-demo-payment
GET /api/v1/bookings/:bookingId/eligible-taxi-areas
POST /api/v1/bookings/:bookingId/taxi-rides
```

The health endpoint must return useful deployment information without leaking secrets:

```json
{
  "status": "ok",
  "service": "cameroon-bus-api",
  "environment": "staging",
  "database": "reachable"
}
```

---

# 11. Database schema

Use PostgreSQL migrations.

Do not manually create tables through Supabase UI.

Required tables:

```text
regions
cities
users
passenger_profiles
identity_documents
agencies
agency_staff
terminals
buses
bus_seats
routes
trip_instances
bookings
booking_passengers
trip_seat_locks
payments
tickets
residential_areas
terminal_area_distances
taxi_vehicles
taxi_drivers
taxi_rides
audit_logs
```

Use PostGIS geography columns for terminals and residential areas:

```sql
location GEOGRAPHY(Point, 4326)
center_point GEOGRAPHY(Point, 4326)
```

Use `trip_seat_locks` to prevent double booking:

```text
One seat cannot be booked twice on the same trip.
```

Use encryption or secure handling for identity document numbers. For MVP/staging, avoid storing ID document images unless absolutely necessary.

---

# 12. Taxi eligibility logic

Required endpoint:

```http
GET /api/v1/bookings/:bookingId/eligible-taxi-areas
```

Backend behavior:

```text
Authenticate passenger.
Load booking.
Confirm booking belongs to current passenger.
Confirm booking status is paid or confirmed.
Load trip instance.
Load route.
Get destination terminal.
Get destination city.
Find active residential areas in destination city.
Filter areas using terminal_area_distances or PostGIS ST_DWithin.
Only return areas:
  active = true
  verified_by_admin = true
  distance <= 15000 meters
```

Expected successful response:

```json
{
  "bookingId": "uuid",
  "arrivalTerminal": {
    "id": "uuid",
    "name": "Bamenda Demo Terminal",
    "city": "Bamenda"
  },
  "distanceLimitMeters": 15000,
  "eligibleAreas": [
    {
      "id": "uuid",
      "name": "Nkwen",
      "distanceMeters": 2400,
      "estimatedFareXaf": 1000
    }
  ]
}
```

If booking is unpaid:

```json
{
  "error": "Taxi add-on is only available after the bus booking is paid or confirmed."
}
```

---

# 13. Taxi ride creation logic

Required endpoint:

```http
POST /api/v1/bookings/:bookingId/taxi-rides
```

Request:

```json
{
  "destinationAreaId": "uuid",
  "destinationLandmark": "Near pharmacy, blue gate"
}
```

Backend must validate:

```text
booking belongs to current passenger
booking is paid or confirmed
pickup terminal is booking arrival terminal
destination area belongs to booking destination city
destination area is active
destination area is verified_by_admin
destination area is within 15000 meters of arrival terminal
```

Taxi ride creation must fail if any rule is broken.

---

# 14. Taxi fare logic

Create backend service:

```text
TaxiFareService
```

MVP fare rules:

```text
0–3 km: 1000 XAF
3–7 km: 1500 XAF
7–10 km: 2000 XAF
10–15 km: 3000 XAF
Over 15 km: not eligible
```

Fare must be calculated by backend, not only Flutter.

---

# 15. Seed data

Create reusable seed scripts.

The seed scripts must work against:

```text
local Docker database
hosted Supabase staging database
```

Use `DATABASE_URL` from environment.

Seed data must include:

## 15.1 Regions

```text
South West
North West
Littoral
West
Centre
```

## 15.2 Cities

```text
Buea
Limbe
Kumba
Bamenda
Douala
Bafoussam
Dschang
Yaoundé
```

## 15.3 Demo agency

```text
Unity Express Demo
```

## 15.4 Demo terminals

```text
Buea Demo Terminal
Bamenda Demo Terminal
Douala Demo Terminal
Bafoussam Demo Terminal
Yaoundé Demo Terminal
```

Coordinates may be approximate for staging only. Create warning file:

```text
database/seed-data/seed_coordinates_warning.md
```

The warning must say:

```text
These coordinates are for development/staging only and must be verified before production.
```

## 15.5 Demo buses

```text
30-seat bus
50-seat bus
70-seat bus
```

Generate seats automatically.

## 15.6 Demo routes

```text
Buea -> Bamenda
Bamenda -> Buea
Buea -> Douala
Douala -> Buea
Bamenda -> Douala
Douala -> Bamenda
Buea -> Yaoundé
Yaoundé -> Buea
Bamenda -> Yaoundé
Yaoundé -> Bamenda
Bafoussam -> Douala
Douala -> Bafoussam
Bafoussam -> Yaoundé
Yaoundé -> Bafoussam
```

## 15.7 Demo residential areas

Bamenda:

```text
Nkwen
Mile 4
Up Station
Commercial Avenue
Small Mankon
Ntarikon
Ntamulung
Foncha Street
```

Buea:

```text
Molyko
Mile 17
Great Soppo
Bonduma
Clerks Quarter
Check Point
```

Douala:

```text
Bonaberi
Akwa
Bonamoussadi
Makepe
Bepanda
Deido
Logbessou
Bonapriso
```

Bafoussam:

```text
Tamja
Djeleng
Tamdja
Banengo
Kamkop
```

Yaoundé:

```text
Bastos
Mvan
Ekounou
Essos
Melen
Biyem-Assi
Emana
Nlongkak
```

Some areas should be set `verified_by_admin = true` for staging tests. Others can remain false to prove filtering works.

---

# 16. Passenger Flutter app

Path:

```text
apps/passenger_app
```

The passenger app must support API configuration with `--dart-define`.

Required config behavior:

```dart
const String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000/api/v1',
);
```

Build for local emulator:

```powershell
flutter build apk --debug
```

Build for hosted staging/friend testing:

```powershell
flutter build apk --debug --dart-define=API_BASE_URL=https://YOUR-HOSTED-API-DOMAIN/api/v1
```

Required initial screens:

```text
SplashScreen
LoginScreen
RegisterScreen
HomeSearchScreen
TripResultsScreen
TripDetailScreen
SeatSelectionScreen
PassengerDetailsScreen
PaymentScreen
TicketScreen
MyBookingsScreen
TaxiEligibilityScreen
TaxiRideRequestScreen
TaxiRideStatusScreen
ProfileScreen
```

First APK milestone can have partial UI, but it must:

```text
Open without crashing
Use a configurable API base URL
Show Cameroon route search UI
Call at least one live API endpoint
Document what is real and what is placeholder
```

---

# 17. APK build requirements

Create:

```text
scripts/build_passenger_debug_apk.ps1
scripts/build_passenger_staging_apk.ps1
docs/apk_build_report.md
```

Debug build script:

```powershell
cd apps/passenger_app
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

Staging build script:

```powershell
param(
  [Parameter(Mandatory=$true)]
  [string]$ApiBaseUrl
)

cd apps/passenger_app
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --debug --dart-define=API_BASE_URL=$ApiBaseUrl
Write-Host "APK: apps/passenger_app/build/app/outputs/flutter-apk/app-debug.apk"
```

Definition of done for APK milestone:

```text
APK exists at apps/passenger_app/build/app/outputs/flutter-apk/app-debug.apk
APK opens on Android
APK points to hosted API for friend testing
APK does not require the user's PC to be running
APK does not require Docker
APK does not connect directly to Supabase
```

---

# 18. Hosted staging deployment

## 18.1 Supabase staging database

Create:

```text
docs/supabase_setup_guide.md
scripts/push_supabase_schema.ps1
scripts/seed_supabase_staging.ps1
```

The scripts must accept `DATABASE_URL` from environment.

Do not hardcode secrets.

Example user workflow:

```powershell
$env:DATABASE_URL="postgresql://..."
.\scripts\push_supabase_schema.ps1
.\scripts\seed_supabase_staging.ps1
```

If Supabase CLI is used, document:

```text
supabase login
supabase link
supabase db push
```

But direct SQL migration scripts are also acceptable.

## 18.2 Hosted NestJS API

Create:

```text
docs/render_api_deployment_guide.md
```

The hosted API must use environment variables:

```text
DATABASE_URL
NODE_ENV=staging
JWT_ACCESS_SECRET
JWT_REFRESH_SECRET
ID_ENCRYPTION_KEY
CORS_ORIGINS
PORT
```

The backend must support Render/Vercel-style `PORT`:

```text
process.env.PORT || 3000
```

Add CORS support.

The API must be deployable from `services/api`.

Document build/start commands.

Example:

```text
Build command: pnpm install --frozen-lockfile && pnpm --filter api build
Start command: pnpm --filter api start:prod
```

Adjust commands to match the actual package structure.

---

# 19. Testing requirements

Create tests for:

```text
Passenger cannot book taxi without paid/confirmed bus booking
Passenger going Buea -> Bamenda only sees Bamenda taxi areas
Passenger going Buea -> Douala does not see Bamenda taxi areas
Residential area beyond 15 km is hidden
Unverified residential area is hidden
Inactive residential area is hidden
Taxi ride cannot be created without booking_id
Taxi pickup terminal must equal booking arrival terminal
Taxi destination city must equal booking destination city
Same seat cannot be booked twice for same trip
Agency A cannot see Agency B bookings
Taxi driver cannot see rides not assigned to him
Payment confirmation creates ticket only once
```

Run tests before every handoff.

---

# 20. Security requirements

Never commit:

```text
Supabase DATABASE_URL
Database password
Supabase service role key
JWT secrets
ID encryption key
Keystore files
Keystore passwords
```

`.env.example` may contain placeholders only.

Flutter app must contain no database password and no Supabase service role key.

ID document numbers must not be printed to logs.

Hosted staging is still not production. Document that ID upload/images are disabled or limited for staging.

---

# 21. Codex execution phases

Work in these phases.

## Phase 0 — Environment audit

Create:

```text
docs/environment_report.md
```

Do not scaffold before audit.

## Phase 1 — Project docs and handoff files

Create all docs listed above.

## Phase 2 — Monorepo scaffold

Create Flutter apps, NestJS API, Next.js dashboard, root workspace files.

## Phase 3 — Database schema and migrations

Create Postgres/PostGIS migrations.

## Phase 4 — Seed scripts

Create reusable seed scripts for local and Supabase.

## Phase 5 — Backend API

Create auth, trips, bookings, taxi eligibility, taxi rides, health endpoint.

## Phase 6 — Backend tests

Create and run taxi/business-rule tests.

## Phase 7 — Supabase staging preparation

Prepare migration/seed push scripts and docs.

Stop and ask user for Supabase `DATABASE_URL`.

## Phase 8 — Hosted API preparation

Prepare Render/Vercel deployment config and docs.

Stop if user needs to create Render/Vercel account or set secrets.

## Phase 9 — Passenger app integration

Create API client, screens, API config, and staging URL support.

## Phase 10 — APK build

Build debug APK.

## Phase 11 — Staging APK build

Build APK with hosted API URL.

## Phase 12 — Cline handoff readiness

Update:

```text
docs/AGENT_HANDOFF.md
docs/BUILD_STATUS.md
docs/NEXT_STEPS.md
```

Cline should be able to continue without reading any chat history.

---

# 22. Codex stop rules

Stop and ask the user before:

```text
Creating paid resources
Deleting existing project folders
Deleting Supabase project
Running destructive database reset against Supabase
Committing secrets
Changing Git remote
Deploying to public hosting with user secrets
Creating release keystore
```

Safe to proceed with approval:

```text
Creating files
Installing npm/pnpm packages
Running tests
Running Flutter analyze/test/build
Creating local Docker database
Running migrations against local database
Preparing Supabase scripts
```

For Supabase staging migrations, ask the user to provide `DATABASE_URL` only when needed. Do not store it in committed files.

---

# 23. First Codex task

When starting Codex, use this prompt:

```text
Read AGENTS.md first.

Work inside:
C:\Users\Administrator\Documents\my_busapp

Start Phase 0 only.

Create docs/environment_report.md by inspecting the machine and checking all required tools.

Do not scaffold the project yet.

After the audit, stop and report:
1. installed tools
2. missing tools
3. recommended fixes
4. whether Android APK build is possible
5. whether Supabase CLI is available
6. whether Docker is available for optional local mirror
```

---

# 24. Final acceptance criteria

The project is not done until all are true:

```text
Supabase hosted database exists
PostGIS enabled in Supabase
Migrations pushed to Supabase
Seed data loaded to Supabase
Hosted API is live over HTTPS
Hosted API can reach Supabase database
Passenger APK is built with hosted API URL
APK can be installed by a friend
Friend can open APK without your PC running
App can call hosted API
Taxi eligibility rule works against hosted database
All critical tests pass
docs/AGENT_HANDOFF.md is current
```
# AGENTS.md UPDATE — Single App, Role-Based Interfaces, Glassmorphism UI

Apply this update to the active project:

```text
C:\Users\Administrator\Documents\my_busapp
```

This update overrides any older instruction that described three separate apps.

---

# 1. Major product correction

The MVP must be built as **one Android app**, not three separate apps.

Correct MVP:

```text
One Flutter Android app
  -> role-based login
  -> interface changes based on authenticated user's role/credentials
  -> hosted NestJS API
  -> Supabase PostgreSQL/PostGIS database
```

Do not create separate Flutter apps for passenger and taxi driver.

Do not create a separate agency/admin app for the MVP.

A web dashboard can be considered later, but the current APK goal is one role-based mobile app.

---

# 2. Main app path

Use this app path:

```text
apps/mobile_app
```

Do not use these as separate MVP apps:

```text
apps/passenger_app
apps/taxi_driver_app
apps/agency_admin
```

If those paths were already created, stop and ask before deleting or restructuring.

---

# 3. Role-based interfaces

After login, the backend must return the user's role.

The Flutter app must use a role router to decide which interface to show.

Required roles:

```text
passenger
agency_owner
agency_admin
agency_staff
taxi_dispatcher
taxi_driver
super_admin
```

Login flow:

```text
SplashScreen
  -> AuthCheck
  -> LoginScreen / RegisterScreen
  -> RoleRouterScreen
  -> correct role interface
```

Role routing:

```text
passenger -> PassengerHomeShell
agency_owner / agency_admin / agency_staff -> AgencyShell
taxi_dispatcher -> TaxiDispatcherShell
taxi_driver -> TaxiDriverShell
super_admin -> SuperAdminShell
```

If one user has multiple roles, use a RoleSwitchScreen after login.

---

# 4. Interface groups inside the one app

## Passenger interface

Screens:

```text
PassengerHomeScreen
TripSearchScreen
TripResultsScreen
TripDetailScreen
SeatSelectionScreen
PassengerDetailsScreen
PaymentScreen
TicketScreen
MyBookingsScreen
TaxiEligibilityScreen
TaxiRideRequestScreen
TaxiRideStatusScreen
PassengerProfileScreen
```

## Agency interface

Screens:

```text
AgencyDashboardScreen
AgencyTripsScreen
AgencyBookingsScreen
PassengerManifestScreen
TicketValidationScreen
AgencyBusesScreen
AgencyRoutesScreen
AgencyTerminalsScreen
AgencyTaxiZonesScreen
AgencyTaxiFleetScreen
AgencyStaffScreen
```

## Taxi dispatcher interface

Screens:

```text
DispatcherDashboardScreen
PendingTaxiRequestsScreen
AssignTaxiDriverScreen
ActiveTaxiRidesScreen
DispatcherRideDetailScreen
```

## Taxi driver interface

Screens:

```text
DriverDashboardScreen
AssignedRidesScreen
RideDetailScreen
StartRideScreen
CompleteRideScreen
ReportIssueScreen
```

## Super admin interface

Screens:

```text
SuperAdminDashboardScreen
AgenciesManagementScreen
RegionsCitiesScreen
SystemAuditLogsScreen
```

---

# 5. UI design direction

The app must have a simple, modern, stylish, intuitive glassmorphism-inspired interface.

Do not make it visually noisy.

Design keywords:

```text
clean
modern
simple
stylish
glassmorphism
soft blur
rounded cards
subtle gradients
large readable text
clear action buttons
low clutter
intuitive role-based navigation
```

Use Flutter Material 3 as the base design system.

Use glassmorphism carefully:

```text
soft gradient backgrounds
translucent cards
rounded corners
subtle shadows
blurred panels where appropriate
good contrast for readability
```

Avoid:

```text
overly transparent text areas
tiny text
too many colors
heavy animations
dark text on dark blur
low contrast
cluttered dashboards
```

---

# 6. Navigation style

Use a role-specific shell after login.

Passenger role:

```text
Bottom navigation with:
Home
Bookings
Taxi
Profile
```

Agency role:

```text
Dashboard
Trips
Bookings
Taxi
Settings
```

Taxi driver role:

```text
Assigned
Active Ride
History
Profile
```

Super admin role:

```text
Dashboard
Agencies
Locations
Audit
```

Use adaptive layout later if web/tablet support is added.

---

# 7. Backend authentication requirement

Backend login response must include:

```json
{
  "accessToken": "jwt",
  "refreshToken": "jwt",
  "user": {
    "id": "uuid",
    "fullName": "string",
    "phone": "string",
    "email": "string",
    "roles": ["passenger"]
  }
}
```

The mobile app must never decide a user's role from local hardcoded data.

The mobile app must use backend-provided roles/claims.

---

# 8. Security rule

Every protected API endpoint must enforce role permissions on the backend.

Frontend role hiding is not security.

Examples:

```text
Passenger cannot access agency booking manifests.
Taxi driver cannot access rides not assigned to them.
Agency staff cannot access another agency's data.
Taxi ride creation must still require paid/confirmed bus booking.
```

---

# 9. Updated monorepo structure

Use:

```text
apps/
  mobile_app/

services/
  api/

database/
  migrations/
  seeds/
  seed-data/

packages/
  shared_types/
  shared_validation/

docs/
  AGENT_HANDOFF.md
  BUILD_STATUS.md
  NEXT_STEPS.md
  COMMAND_LOG.md
  DECISIONS.md
  environment_report.md
  product_plan.md
  hosted_staging_plan.md
  supabase_setup_guide.md
  render_api_deployment_guide.md
  database_schema.md
  taxi_zone_rules.md
  api_contract.md
  security_rules.md
  apk_build_report.md
  seed_data_plan.md
  ui_design_system.md
  role_based_navigation.md

scripts/
  check_environment.ps1
  install_laptop_dependencies.ps1
  build_mobile_debug_apk.ps1
  build_mobile_staging_apk.ps1
  push_supabase_schema.ps1
  seed_supabase_staging.ps1
```

Root files:

```text
package.json
pnpm-workspace.yaml
.env.example
.gitignore
README.md
AGENTS.md
```

---

# 10. APK target update

The APK target is now:

```text
apps/mobile_app/build/app/outputs/flutter-apk/app-debug.apk
```

The staging APK build command must support:

```powershell
flutter build apk --debug --dart-define=API_BASE_URL=https://YOUR-HOSTED-API-DOMAIN/api/v1
```

---

# 11. Documentation update required

Update these docs to reflect one app with role-based interfaces:

```text
AGENTS.md
docs/product_plan.md
docs/BUILD_STATUS.md
docs/NEXT_STEPS.md
docs/AGENT_HANDOFF.md
docs/api_contract.md
docs/security_rules.md
docs/apk_build_report.md
```

Also create:

```text
docs/ui_design_system.md
docs/role_based_navigation.md
```

---

# 12. Stop rule

Do not scaffold separate apps for passenger, taxi driver, and agency dashboard.

If older instructions conflict with this update, this update wins.
