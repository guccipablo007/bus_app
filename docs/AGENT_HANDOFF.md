# Agent Handoff

## Current phase

Phase 12B-C complete: onboarding migration and hosted deployment verified.

## Completed

- Applied only `008_onboarding_applications.sql` to Supabase staging.
- Verified `agency_applications`, `driver_applications`, and
  `application_documents` through `information_schema`.
- User manually redeployed existing Render service `cameroon-bus-api-staging`
  on commit `ef035c8`; no new service was created.
- Hosted health reports `ok` and database `reachable`.
- Hosted smoke passed passenger and super-admin login, both application types,
  My Applications, admin listing, approve, and reject.
- Added reusable `scripts/smoke_test_hosted_onboarding.ps1`.

## Hosted smoke result

```text
Passenger login: passed
Agency submission: passed
Driver submission: passed
My Applications: passed (4 smoke records after two runs)
Super-admin login/list/review: passed
Document handling: metadata_only
```

Seeded super admin exists:
`superadmin.demo@cameroonbus.test` with the documented staging password.

## Verification

```text
API tests: 30 passed
API build/typecheck: passed
Flutter analyze: no issues
Flutter tests: 16 passed
```

## APK

Not rebuilt in Phase 12B-C because mobile source did not change. Continue using:

```text
staging_artifacts/cameroon-bus-staging-debug.apk
SHA-256: 0B2B6C31E67006ADC9F06ECF305095E4BCED3605C0E1ADCE0E393F9B4FD4694F
```

## Document handling

Metadata/placeholder only. No file bytes are uploaded. Real upload still needs
private object storage, authorization, validation, retention, and audit design.

## Exact next task

Run the Phase 12B-C BlueStacks checklist in `docs/physical_device_test_plan.md`.

## Secrets needed

None for current staging QA.
