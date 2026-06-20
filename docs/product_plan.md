# Product Plan

## Goal

Build an Android-first Cameroon inter-regional bus booking platform as one shareable Flutter APK.

The APK must let different user types log in and see role-specific interfaces inside the same app.

## Active MVP architecture

```text
apps/mobile_app
  -> hosted HTTPS NestJS API
  -> hosted Supabase PostgreSQL/PostGIS
```

Do not build separate MVP apps for passenger, taxi driver, or agency/admin roles.

## Launch geography

Regions:

- South West
- North West
- Littoral
- West
- Centre

Cities:

- Buea
- Limbe
- Kumba
- Bamenda
- Douala
- Bafoussam
- Dschang
- Yaounde

## Roles

- `passenger`
- `agency_owner`
- `agency_admin`
- `agency_staff`
- `taxi_dispatcher`
- `taxi_driver`
- `super_admin`

## Role shells

- `PassengerHomeShell`
- `AgencyShell`
- `TaxiDispatcherShell`
- `TaxiDriverShell`
- `SuperAdminShell`

## Passenger capabilities

- Register/login.
- Manage profile, phone, email, and identity document details.
- Search inter-regional bus trips.
- Select route, date, bus, and seat.
- Create booking.
- Confirm demo/staging payment.
- Receive ticket/QR code.
- See taxi add-on only after a paid or confirmed bus booking.
- Request agency taxi only for the final bus destination city.

## Agency capabilities

- Manage agency profile.
- Manage terminals, buses, seat layouts, routes, and trips.
- View bookings and passenger manifests.
- Validate tickets.
- Manage taxi zones, taxi fleet, and staff.

## Taxi dispatcher capabilities

- View pending taxi requests.
- Assign taxi drivers.
- Monitor active taxi rides.
- Review ride details.

## Taxi driver capabilities

- View assigned rides.
- See pickup terminal.
- See passenger contact.
- See approved destination area.
- Start and complete rides.
- Report issue or no-show.

## Super admin capabilities

- Manage agencies.
- Manage regions and cities.
- View system audit logs.

## Critical taxi rule

Taxi is not a general marketplace. It is a bus agency add-on tied to the passenger's final bus destination.

Example:

```text
Buea -> Bamenda bus booking
Taxi may only be Bamenda arrival terminal -> approved Bamenda residential area
```

The backend must enforce all taxi eligibility rules.
