# Physical Device Test Plan

## Purpose

Verify that the Cameroon Bus Booking APK works correctly when installed on a
real Android device. This plan covers installation, passenger flow, taxi
eligibility, and role-based routing.

## Prerequisites

- Android device with Developer Options and USB Debugging enabled
- USB cable or shared file transfer (if USB not possible)
- The APK at `apps/mobile_app/build/app/outputs/flutter-apk/app-debug.apk`
- Seeded staging credentials (see `docs/friend_testing_guide.md`)

## Test environment

- **APK**: `staging_artifacts/cameroon-bus-staging-debug.apk`
- **API**: `https://cameroon-bus-api-staging.onrender.com/api/v1`
- **Database**: Supabase staging (migrated and seeded)

## Test checklist

### 1. App installation

| Step | Action | Expected | Done |
|------|--------|----------|------|
| 1.1 | Transfer APK to device via USB or cloud | File arrives intact | ☐ |
| 1.2 | Open APK on device and install | No warning about "unsafe app" | ☐ |
| 1.3 | Launch the app from app drawer | Splash screen appears | ☐ |

### 2. Health and connectivity

| Step | Action | Expected | Done |
|------|--------|----------|------|
| 2.1 | Wait for splash to resolve | App shows login screen | ☐ |
| 2.2 | (First load may be slow due to Render cold-start) | Login renders within 15s | ☐ |

### 3. Demo passenger login

| Step | Action | Expected | Done |
|------|--------|----------|------|
| 3.1 | Enter passenger staging credentials | No errors on login button | ☐ |
| 3.2 | Tap "Login" | Navigates to PassengerHomeShell | ☐ |
| 3.3 | Verify bottom nav shows: Home, Bookings, Taxi, Profile | All four visible | ☐ |

### 4. Trip search

| Step | Action | Expected | Done |
|------|--------|----------|------|
| 4.1 | From origin city select **Buea** | Origin dropdown shows Buea | ☐ |
| 4.2 | From destination city select **Bamenda** | Destination shows Bamenda | ☐ |
| 4.3 | Select today's date | Date displayed correctly | ☐ |
| 4.4 | Tap "Search" | Loading indicator then trip results | ☐ |
| 4.5 | Verify at least one trip appears | Trip card with time/price/bus | ☐ |

### 5. Booking flow

| Step | Action | Expected | Done |
|------|--------|----------|------|
| 5.1 | Tap on a trip result | Trip detail screen with seat map | ☐ |
| 5.2 | Select an available seat | Seat highlights, shows as selected | ☐ |
| 5.3 | Tap "Continue" or "Book" | PassengerDetails screen | ☐ |
| 5.4 | Enter passenger full name, phone, email | Fields accept input | ☐ |
| 5.5 | Submit booking details | Navigates to Payment screen | ☐ |

### 6. Demo payment

| Step | Action | Expected | Done |
|------|--------|----------|------|
| 6.1 | Tap "Confirm Demo Payment" | Processing indicator | ☐ |
| 6.2 | Wait for API response | Success message or ticket screen | ☐ |
| 6.3 | Verify booking status shows "paid" or "confirmed" | Status badge updates | ☐ |

### 7. Ticket verification

| Step | Action | Expected | Done |
|------|--------|----------|------|
| 7.1 | Navigate to My Bookings tab | List shows the booked trip | ☐ |
| 7.2 | Tap on the booking | Ticket details or booking detail screen | ☐ |
| 7.3 | Verify ticket displays route, date, seat, passenger info | All fields present | ☐ |

### 8. Taxi eligibility — correct destination only

| Step | Action | Expected | Done |
|------|--------|----------|------|
| 8.1 | From the booking/ticket, tap "Book Taxi" | TaxiEligibility screen | ☐ |
| 8.2 | Confirm only **Bamenda** areas appear | No Buea/Douala/Yaoundé areas | ☐ |
| 8.3 | Verify areas listed are within 15 km of Bamenda terminal | Nkwen, Mile 4, Up Station etc. | ☐ |
| 8.4 | Some unverified areas may be present but disabled | Filtering works correctly | ☐ |

### 9. Taxi request

| Step | Action | Expected | Done |
|------|--------|----------|------|
| 9.1 | Select a residential area from the list | Area highlights | ☐ |
| 9.2 | Enter a landmark (e.g. "Near pharmacy") | Text field accepts input | ☐ |
| 9.3 | Tap "Request Taxi" | Loading indicator | ☐ |
| 9.4 | Success screen shows ride details | Taxi ride created successfully | ☐ |

### 10. Non-passenger role dashboards (if multiple role users exist)

| Step | Action | Expected | Done |
|------|--------|----------|------|
| 10.1 | Log in as agency user | Navigates to AgencyShell | ☐ |
| 10.2 | View agency dashboard (placeholder) | Placeholder screen with menu | ☐ |
| 10.3 | Log in as taxi driver | Navigates to DriverShell | ☐ |
| 10.4 | View driver dashboard (placeholder) | Placeholder screen with menu | ☐ |
| 10.5 | Log in as super admin | Navigates to SuperAdminShell | ☐ |

### 11. App restart behavior

| Step | Action | Expected | Done |
|------|--------|----------|------|
| 11.1 | Force close the app | App exits | ☐ |
| 11.2 | Reopen the app | Splash screen appears | ☐ |
| 11.3 | Verify login screen is shown (no persistence yet) | Login required again | ☐ |

### 12. Edge cases

| Step | Action | Expected | Done |
|------|--------|----------|------|
| 12.1 | Try searching without selecting cities | Validation error shown | ☐ |
| 12.2 | Try booking a trip without selecting a seat | Error/validation prevents booking | ☐ |
| 12.3 | Try taxi eligibility on unpaid booking | Error: "Taxi add-on only after paid booking" | ☐ |
| 12.4 | Airplane mode / no network | Graceful error message, no crash | ☐ |

## Test results template

```text
Device: ________________
Android version: _______
APK size: _____________
APK SHA-256: __________
Cold-start time: ______s
Passed: ___/___ tests
Notes:
```

## Success criteria

- App installs and opens
- Passenger can complete: login → search → book → pay → see ticket → request taxi
- Taxi eligibility shows only destination-city areas
- No crash during any step
- No Supabase credential leak
- API base URL points to Render hosted API
