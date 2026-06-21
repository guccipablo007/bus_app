# Agent Handoff

## Current phase

Phase 12B-B implemented and locally verified. Hosted rollout is pending.

## Completed

- Added migration `008_onboarding_applications.sql` with agency applications,
  driver applications, and application document metadata.
- Added passenger submit/list APIs and super-admin list/review APIs.
- Approval/rejection is status-only; it does not create agencies/drivers or roles.
- Added passenger agency/driver forms, My Applications, and pending-review screen.
- Added live super-admin review queue and clearer agency/driver placeholders.
- Added backend e2e and Flutter widget coverage.
- Built the ignored debug staging APK with the hosted API dart-define.

## Document handling

Metadata only. The app records document type and filename with a staging
placeholder path. It does not upload file bytes. Real uploads require a private
Supabase Storage bucket, server-side credentials, size/type checks, signed URLs,
malware policy, retention rules, and manual environment configuration.

## Verification

```text
Flutter analyze: no issues
Flutter tests: 16 passed
API unit tests: 30 passed
API e2e tests: 11 passed
API build/typecheck: passed
Migration validation: passed, 8 files / 28 tables
```

## APK

```text
staging_artifacts/cameroon-bus-staging-debug.apk
185,439,241 bytes
SHA-256 0B2B6C31E67006ADC9F06ECF305095E4BCED3605C0E1ADCE0E393F9B4FD4694F
```

## Known issue / exact next task

The code is not live on hosted staging yet. Apply only migration `008` using
`push_supabase_schema.ps1 -MigrationPath database/migrations/008_onboarding_applications.sql`
and the existing process-only `DATABASE_URL`, then redeploy the existing Render service.
Do not test hosted submission/review before both steps complete.

## Secrets needed

No new secrets. A real upload phase would require manually configured private
storage credentials; none were guessed or committed.
