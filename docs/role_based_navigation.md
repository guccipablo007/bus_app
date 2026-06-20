# Role-Based Navigation

## Login flow

```text
SplashScreen
  -> AuthCheck
  -> LoginScreen / RegisterScreen
  -> RoleRouterScreen
  -> correct role interface
```

The backend login response must provide roles.

The mobile app must not infer roles from hardcoded local data.

## Phase 2 implementation status

Scaffolded in `apps/mobile_app/lib`:

- `SplashScreen`
- `AuthCheck`
- `LoginScreen`
- `RoleRouterScreen`
- `RoleSwitchScreen`
- `PassengerHomeShell`
- `AgencyShell`
- `TaxiDispatcherShell`
- `TaxiDriverShell`
- `SuperAdminShell`

The role router consumes a `UserSession` role list. Authentication is intentionally disabled until the backend auth contract is implemented; the login button is a placeholder and no role is inferred locally.

## Role routing

| Backend role | Shell |
|---|---|
| `passenger` | `PassengerHomeShell` |
| `agency_owner` | `AgencyShell` |
| `agency_admin` | `AgencyShell` |
| `agency_staff` | `AgencyShell` |
| `taxi_dispatcher` | `TaxiDispatcherShell` |
| `taxi_driver` | `TaxiDriverShell` |
| `super_admin` | `SuperAdminShell` |

If a user has multiple roles, route to:

```text
RoleSwitchScreen
```

## Passenger shell

Bottom navigation:

- Home
- Bookings
- Taxi
- Profile

Screens:

- `PassengerHomeScreen`
- `TripSearchScreen`
- `TripResultsScreen`
- `TripDetailScreen`
- `SeatSelectionScreen`
- `PassengerDetailsScreen`
- `PaymentScreen`
- `TicketScreen`
- `MyBookingsScreen`
- `TaxiEligibilityScreen`
- `TaxiRideRequestScreen`
- `TaxiRideStatusScreen`
- `PassengerProfileScreen`

## Agency shell

Navigation:

- Dashboard
- Trips
- Bookings
- Taxi
- Settings

Screens:

- `AgencyDashboardScreen`
- `AgencyTripsScreen`
- `AgencyBookingsScreen`
- `PassengerManifestScreen`
- `TicketValidationScreen`
- `AgencyBusesScreen`
- `AgencyRoutesScreen`
- `AgencyTerminalsScreen`
- `AgencyTaxiZonesScreen`
- `AgencyTaxiFleetScreen`
- `AgencyStaffScreen`

## Taxi dispatcher shell

Screens:

- `DispatcherDashboardScreen`
- `PendingTaxiRequestsScreen`
- `AssignTaxiDriverScreen`
- `ActiveTaxiRidesScreen`
- `DispatcherRideDetailScreen`

## Taxi driver shell

Navigation:

- Assigned
- Active Ride
- History
- Profile

Screens:

- `DriverDashboardScreen`
- `AssignedRidesScreen`
- `RideDetailScreen`
- `StartRideScreen`
- `CompleteRideScreen`
- `ReportIssueScreen`

## Super admin shell

Navigation:

- Dashboard
- Agencies
- Locations
- Audit

Screens:

- `SuperAdminDashboardScreen`
- `AgenciesManagementScreen`
- `RegionsCitiesScreen`
- `SystemAuditLogsScreen`
