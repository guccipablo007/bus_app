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

## Phase 9 implementation status

Implemented in `apps/mobile_app/lib`:

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

Registration and login call the hosted API. `UserSession` is created from the
backend response, and `RoleRouterScreen` routes only from that response's role
claims. Users with more than one role see `RoleSwitchScreen`.

The passenger shell now has a real hosted-data flow for trip search, booking,
demo payment/ticket, taxi eligibility, and taxi request. Agency, dispatcher,
driver, and super-admin shells are intentionally stable placeholders. Tokens
are currently memory-only and are cleared when the app process exits.

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
