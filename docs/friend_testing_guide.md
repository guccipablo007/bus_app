# Friend Testing Guide

Install `staging_artifacts/cameroon-bus-staging-debug.apk`. It is a debug APK
connected to the hosted staging API; the user's computer is not required.

## Seeded demo accounts

| Role | Identifier | Password |
|---|---|---|
| Passenger | `passenger.demo@cameroonbus.test` | `Password123!` |
| Agency owner | `agency.owner.demo@cameroonbus.test` | `Password123!` |
| Taxi driver | `driver.demo@cameroonbus.test` | `Password123!` |
| Super admin | `superadmin.demo@cameroonbus.test` | `Password123!` |

Render Free may take up to 120 seconds on the first login after idle. Passenger
testing covers Buea-to-Bamenda search, an available `S##` seat, demo payment,
ticket, destination taxi eligibility, and taxi request. No real payment occurs.

Report Android version, device model, exact action, error text, and approximate
time. Do not enter real identity-document information in staging.
