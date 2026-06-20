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
