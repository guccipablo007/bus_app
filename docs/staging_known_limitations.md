# Staging Known Limitations

This document lists every known limitation of the current staging deployment.
Refer to this before filing bugs or requesting new features.

---

## 1. Hosted API (Render Free Tier)

| Limitation | Detail |
|---|---|
| **Cold starts** | Render spins down after 15 minutes of inactivity. First request after idle takes 10–30 seconds. |
| **No dedicated domain** | Uses `*.onrender.com` — not production-ready. |
| **No HTTPS certificate automation** | Render provides auto-issued certs; they work but are not BYO-cert. |
| **Ephemeral filesystem** | Any file written to disk by the API is lost on restart. |
| **No horizontal scaling** | Free tier runs a single instance with limited CPU/RAM. |

## 2. Staging database (Supabase)

| Limitation | Detail |
|---|---|
| **Shared staging database** | All testers share the same data. Demo bookings, trips, and seats are not isolated per tester. |
| **No real data** | Coordinates are approximate (see `database/seed-data/seed_coordinates_warning.md`). |
| **No backup schedule** | Free-tier Supabase may not have automated backups configured. |
| **Demo credentials only** | Only pre-seeded accounts exist; registration creates users but the data is shared. |

## 3. App features (not yet built)

| Limitation | Detail |
|---|---|
| **Login persistence** | Access tokens are held in memory only. Closing the app requires re-login. |
| **Real payments** | Only "demo payment" is implemented. No MTN Mobile Money, Orange Money, or card processor. |
| **Agency operations** | Agency shell is a placeholder with no real management features (buses, routes, staff, manifests). |
| **Taxi dispatcher flow** | Dispatcher dashboard is a placeholder. No real assignment workflow. |
| **Driver ride tracking** | Driver can see assigned rides but GPS tracking is not implemented. |
| **Super admin functions** | Super admin dashboard is a placeholder. No user management, audit log browsing, or system config. |
| **QR tickets** | Ticket data is displayed as text. QR code generation is not yet implemented. |
| **Push notifications** | No Firebase Cloud Messaging or equivalent. |
| **Offline mode** | The app requires a network connection for all operations. |
| **Multi-language** | English only. French localization is not implemented. |
| **Accessibility** | Basic Material 3 compliance, but no dedicated accessibility audit has been done. |
| **Seat lock expiry** | `trip_seat_locks` are created but no background job releases expired locks. |

## 4. Testing and security (staging only)

| Limitation | Detail |
|---|---|
| **Debug APK (unsigned)** | The APK is debug-signed and cannot be distributed through the Play Store. |
| **No release keystore** | A release/production keystore has not been created. |
| **No rate limiting** | API endpoints do not rate-limit requests. |
| **No audit trail for writes** | `audit_logs` table exists but not every write action is logged. |
| **ID document handling** | Identity document numbers are stored in plain text for staging. Encryption is deferred. |
| **Coordinates are approximate** | Terminal/residential area coordinates are manually set for staging and must be verified before production. |

## 5. Build and development

| Limitation | Detail |
|---|---|
| **APK size** | Debug APK is ~140 MiB. A release APK with ProGuard would be significantly smaller. |
| **No CI/CD** | Builds are manual. No GitHub Actions or similar pipeline is configured. |
| **Windows-only build** | The project was scaffolded and built on Windows 11. macOS/Linux build steps may differ. |
| **JDK path** | `JAVA_HOME` must point to JDK 17+. If the environment variable is missing, specify it via `flutter config --jdk-dir`. |
| **PowerShell execution policy** | Some scripts require `-ExecutionPolicy Bypass` or cmd.exe for pnpm/npm commands. |

## 6. Taxi-specific limitations (staging)

| Limitation | Detail |
|---|---|
| **15 km hard limit** | Distance eligibility is hard-coded in `TaxiFareService`. Configuration may be needed for different cities. |
| **No real-time driver assignment** | Taxi rides are created without an assigned driver. The dispatcher interface is a placeholder. |
| **Fare is approximate** | Fares use distance bands (0–3 km: 1000 XAF, etc.) but are not validated against real fuel/pricing data. |
| **No ride tracking** | Driver cannot update ride status beyond manual "start" and "complete" actions. |

## 7. Data awareness

| Limitation | Detail |
|---|---|
| **Demo trips are weekly** | Seeded trip instances cover a fixed date range. After the seed dates pass, no future trips exist unless reseeded. |
| **Seat inventory** | 150 seats total across 3 buses (30 + 50 + 70). All testers share the same seats. |
| **Residential areas** | 35 areas seeded across 5 cities. Some are intentionally `verified_by_admin = false` to test filtering. |
