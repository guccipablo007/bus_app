# API Contract

## Base path and errors

All routes use `/api/v1`. Invalid DTOs reject unknown fields and return `400`.
Normal errors use this envelope and never include a stack trace:

```json
{
  "statusCode": 422,
  "error": "Unprocessable Entity",
  "message": "Taxi add-on is only available after the bus booking is paid or confirmed.",
  "path": "/api/v1/bookings/BOOKING_ID/eligible-taxi-areas",
  "timestamp": "2026-06-20T00:00:00.000Z"
}
```

Status meanings:

| Status | Meaning |
|---:|---|
| `400` | DTO or query validation failed |
| `401` | Missing, invalid, or expired access token |
| `403` | Authenticated but wrong role, owner, agency, or assignment |
| `404` | Requested resource does not exist |
| `409` | Unique resource conflict, including an occupied trip seat |
| `422` | Valid request violates a booking, payment, or taxi business rule |

## Endpoint access

| Method | Path | Required access |
|---|---|---|
| `GET` | `/health` | Public |
| `POST` | `/auth/register` | Public |
| `POST` | `/auth/login` | Public |
| `GET` | `/regions` | Public |
| `GET` | `/cities?regionId=...` | Public |
| `GET` | `/trips/search` | Public |
| `POST` | `/bookings` | `passenger` JWT |
| `GET` | `/bookings/:bookingId` | Owning `passenger` JWT |
| `POST` | `/bookings/:bookingId/confirm-demo-payment` | Owning `passenger` JWT |
| `GET` | `/bookings/:bookingId/eligible-taxi-areas` | Owning `passenger` JWT |
| `POST` | `/bookings/:bookingId/taxi-rides` | Owning `passenger` JWT |

## Health

```json
{
  "status": "ok",
  "service": "cameroon-bus-api",
  "environment": "staging",
  "database": "reachable"
}
```

Hosted health performs a safe database ping. It returns `status: "degraded"`
and `database: "unreachable"` on connection failure without exposing host,
username, password, or internal error details. Development/test returns
`database: "not_connected"` and does not open a database connection.

## Register and login

`POST /auth/register`:

```json
{
  "fullName": "Test Passenger",
  "phone": "+237670000001",
  "email": "passenger@example.com",
  "password": "strong-passphrase"
}
```

`POST /auth/login`:

```json
{
  "identifier": "passenger@example.com",
  "password": "strong-passphrase"
}
```

Both authentication responses expose backend-provided roles:

```json
{
  "accessToken": "jwt",
  "refreshToken": "jwt",
  "user": {
    "id": "uuid",
    "fullName": "Test Passenger",
    "phone": "+237670000001",
    "email": "passenger@example.com",
    "roles": ["passenger"]
  }
}
```

## Trip search

```http
GET /api/v1/trips/search?originCity=Buea&destinationCity=Bamenda&travelDate=YYYY-MM-DD
```

`originCity` and `destinationCity` accept current names or IDs. Results include
trip ID, cities and terminals, departure, arrival estimate, agency, bus class,
base price XAF, and available seat count.

## Booking and demo payment

```json
{
  "tripId": "trip-buea-bamenda",
  "seatNumber": "1A"
}
```

Creation returns `201` with `status: "pending_payment"`. Concurrent requests
for the same `(tripId, seatNumber)` produce one `201` and one `409`.

Demo payment requires no body. The first confirmation moves a pending booking
to `paid` and creates one ticket. Repeated confirmation returns the same ticket
ID and QR code. A non-pending booking without a prior ticket returns `422`.

## Taxi eligibility and ride request

Eligibility returns the booking arrival terminal and only same-destination-city
areas that are active, admin-verified, and at most 15,000 meters away:

```json
{
  "bookingId": "uuid",
  "arrivalTerminal": {
    "id": "terminal-bamenda",
    "name": "Bamenda Demo Terminal",
    "city": "Bamenda"
  },
  "distanceLimitMeters": 15000,
  "eligibleAreas": [
    {
      "id": "area-nkwen",
      "name": "Nkwen",
      "distanceMeters": 2400,
      "estimatedFareXaf": 1000
    }
  ]
}
```

Ride request:

```json
{
  "destinationAreaId": "area-nkwen",
  "destinationLandmark": "Near pharmacy, blue gate"
}
```

The client cannot supply pickup terminal, fare, destination city, or status.
Unknown fields return `400`; an ineligible area or unpaid booking returns `422`.

## Staging limitations

- Render Free may cold-start after idle.
- Identity-document image upload remains disabled/not implemented for staging.
- Refresh-token rotation/revocation endpoints remain future work.
- Agency and assigned-driver operational endpoints remain future work.

## Phase 9 mobile client coverage

The Flutter API client uses the hosted `/api/v1` contract for health, regions,
cities, trip search, register/login, booking creation, demo payment, taxi
eligibility, and taxi ride creation. Bearer tokens are added only to protected
requests. Error responses are converted to readable client errors without
logging credentials or tokens.

The staging APK receives its API base URL through `--dart-define=API_BASE_URL`.
The emulator default remains `http://10.0.2.2:3000/api/v1`; the built staging
artifact uses `https://cameroon-bus-api-staging.onrender.com/api/v1`.
