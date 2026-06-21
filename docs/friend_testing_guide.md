# Friend Testing Guide

## What is this?

This is a debug APK of the Cameroon Bus Booking app. It connects to a hosted
staging API — no need to run anything on your computer.

## Quick start

1. **Install the APK** — transfer `cameroon-bus-staging-debug.apk` to your
   Android phone and open the file. You may need to enable "Install from unknown
   apps" for your file manager.

2. **Open the app** — you'll see a splash screen, then a login page.

3. **Use one of these demo accounts:**

   | Role | Email | Password |
   |------|-------|----------|
   | Passenger | `passenger@demo.com` | `Demo@123456` |
   | Agency owner | `agency@demo.com` | `Demo@123456` |
   | Taxi driver | `driver@demo.com` | `Demo@123456` |
   | Super admin | `admin@demo.com` | `Demo@123456` |

4. **Try the passenger flow:**

   - Login as passenger
   - Search: Buea → Bamenda
   - Select a trip, pick a seat
   - Fill passenger details
   - Confirm demo payment (no real money)
   - View your ticket
   - Book a destination taxi in Bamenda

## What works

- Login and role-based navigation
- Trip search (Buea → Bamenda, Buea → Douala, etc.)
- Booking, seat selection, demo payment
- Ticket display
- Taxi eligibility (Bamenda areas only after paid booking)
- Taxi ride request
- Placeholder dashboards for agency, driver, super admin

## What does NOT work yet

- Login is not persisted — close and reopen requires sign-in again
- Real payment (staging uses demo/emulated payment)
- Push notifications
- Full agency operations (manage buses, routes, staff)
- Full taxi dispatcher flow
- Driver ride tracking (GPS)
- Release/signed APK

## Important notes

- **First load is slow.** The staging API runs on Render's free tier and spins
  down after inactivity. The first request may take 10–30 seconds.
- **No real money.** All payments are demo/staging only.
- **Coordinates are approximate.** Terminal and area locations are for testing
  only and will be refined before production.
- **Your data is shared.** This is a single staging database — other testers see
  the same demo trips and bookings.

## APK details

- **File**: `cameroon-bus-staging-debug.apk`
- **SHA-256**: (printed during package preparation)
- **Size**: (printed during package preparation)
- **API**: `https://cameroon-bus-api-staging.onrender.com/api/v1`
- **Build type**: debug (unsigned)

## Troubleshooting

| Problem | Likely fix |
|---------|------------|
| "App not installed" | Enable "Install from unknown apps" for your file manager or use `adb install` |
| White screen on first load | Wait 15–30s for Render cold-start |
| "Cannot connect to server" | Check internet connection; verify API is up at the URL above |
| Booking fails | Another tester may have booked the same seat — try a different one |
| Login fails | Check email/password; accounts are case-sensitive |

## Reporting issues

If something breaks, please record:

- Android version
- Phone model
- What you were doing
- What happened (error message, screenshot if possible)
- Approximate time of day (for Render cold-start tracking)

Send to the project owner. Thank you for testing! 🚌
