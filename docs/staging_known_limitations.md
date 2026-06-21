# Staging Known Limitations

- Render Free can cold-start after idle. Login allows up to 120 seconds.
- All testers share one Supabase staging dataset and seat inventory.
- The debug APK is about 176.8 MiB and is debug-signed, not Play-ready.
- Sessions persist in SharedPreferences for QA; production requires secure storage.
- Tokens are not yet refreshed or revoked through a complete lifecycle.
- Demo payment is not real payment processing.
- Agency, dispatcher, driver, and super-admin operations remain placeholders.
- QR rendering, notifications, offline mode, French localization, and a formal
  accessibility audit remain pending.
- Taxi fares and coordinates are staging approximations.
- No release keystore exists.

The APK calls only the hosted NestJS API. No Supabase credential is in Flutter.
