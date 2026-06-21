# Physical Device Test Plan

## Test artifact

```text
APK: staging_artifacts/cameroon-bus-staging-debug.apk
Size: 185,439,241 bytes
SHA-256: 481417420244873900F2E5BE25144C1F09744DA1189B9973F9CC5628B503E869
API: https://cameroon-bus-api-staging.onrender.com/api/v1
Passenger: passenger.demo@cameroonbus.test / Password123!
```

## BlueStacks regression checklist

1. Uninstall the old APK or clear app storage, then install the new artifact.
2. Launch and confirm splash resolves to login.
3. Tap Passenger; confirm the seeded email/password fill exactly.
4. Tap Sign in. Allow up to 120 seconds after Render has been idle.
5. Confirm PassengerHomeShell and Home, Bookings, Taxi, Profile navigation.
6. Force-close and reopen; confirm the session restores.
7. Sign out, reopen, and confirm login remains cleared.
8. Enter a wrong password; expect `Invalid phone/email or password.`
9. Disable network and retry; expect the connection message, not credential error.
10. Search Buea to Bamenda and confirm live trips.
11. Select a returned `S##` seat and create a booking.
12. Confirm demo payment and verify ticket details.
13. Confirm only eligible Bamenda taxi areas appear.
14. Submit a taxi request with an area and landmark.

## Report template

```text
Device/emulator:
Android version:
APK SHA-256 verified: yes/no
Cold-start login time:
Login: pass/fail
Session restore/logout: pass/fail
Search/booking/payment/ticket/taxi: pass/fail
Observed error text:
Notes/screenshots:
```
