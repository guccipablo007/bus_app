# Taxi Zone Rules

## Core rule

Agency taxi service is tied to the final bus destination. It is not a general taxi marketplace.

The backend must enforce this rule.

## Eligibility

A passenger can request an agency taxi only when:

- The passenger owns the booking.
- The bus booking is `paid` or `confirmed`.
- The pickup terminal is the booking arrival terminal.
- The destination area belongs to the booking destination city.
- The destination area is active.
- The destination area is verified by an admin.
- The destination area is within 15,000 meters of the arrival terminal.

## Example

For a bus booking:

```text
Buea -> Bamenda
```

Allowed taxi:

```text
Bamenda arrival terminal -> approved Bamenda residential area
```

Not allowed:

- Taxi in Buea.
- Taxi in Douala.
- Taxi in Yaounde.
- Taxi in any unrelated city.
- Taxi to inactive areas.
- Taxi to unverified areas.
- Taxi beyond 15 km from the arrival terminal.

## Fare rules

Backend-calculated MVP fares:

| Distance | Fare |
|---|---:|
| 0-3 km | 1000 XAF |
| 3-7 km | 1500 XAF |
| 7-10 km | 2000 XAF |
| 10-15 km | 3000 XAF |
| Over 15 km | Not eligible |

## Phase 3 schema enforcement

Migration `006_residential_areas_taxi_zones.sql` adds:

- Required `taxi_rides.booking_id` and `passenger_id`.
- Required `pickup_terminal_id` and `destination_area_id`.
- Active and admin-verification flags on areas and terminal-distance rows.
- Unique terminal/area distance rows.
- Nonnegative distance and duration checks.
- Taxi ride status enum.
- Driver and vehicle agency consistency checks.
- A taxi eligibility trigger that rejects unrelated cities, terminals,
  agencies, inactive/unverified areas, unpaid bookings, and distances over
  15,000 meters.

Backend validation remains mandatory. The trigger is defense in depth and is
not a replacement for authenticated ownership and role guards.

## Phase 6 service enforcement

`TaxiService` now enforces the rule before ride creation using the booking's
actual trip destination. It checks passenger ownership, paid/confirmed status,
same destination city, active and verified state, and the 15 km limit. The
pickup terminal is taken from the trip's arrival terminal and cannot be supplied
by the client.

`TaxiFareService` calculates all four fare brackets and rejects distances over
15,000 meters. Tests cover Bamenda-only and Douala-only results, unpaid
bookings, hidden inactive/unverified/out-of-range areas, wrong-city ride
requests, and every fare boundary.

Phase 6 HTTP tests verify that unpaid and unauthenticated access fails, only
Nkwen is returned for a paid Buea-to-Bamenda booking, wrong-city/unknown areas
return `422`, and clients cannot override pickup terminal or fare fields.

The Phase 6 adapter is in-memory. PostGIS remains the source for verified
distances when the PostgreSQL repository is introduced later.

## Phase 4 taxi seed coverage

- Thirty-five required residential areas have staging-only center points.
- Verification flags are intentionally mixed so unverified rows can be hidden.
- A few areas are inactive to test active-area filtering.
- Terminal-area straight-line distance is computed by PostGIS.
- `active` is derived from the area state and `ST_DWithin(..., 15000)`.
- Terminal-area verification follows the residential-area verification flag.
- Driving distance/duration remain null until verified routing data is added.

Approximate coordinates must not be used for production pricing or dispatch.
