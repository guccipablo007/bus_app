# Product Completeness Audit

## Working

- Hosted passenger auth, session restore, trip search, booking, demo payment,
  ticket, taxi eligibility, and taxi request.
- Local onboarding API/UI: agency and driver submission, own list, admin list,
  approve/reject, rejection reason, and metadata documents.
- Backend authorization for passenger submission and super-admin review.

## Pending hosted rollout

- Apply migration `008_onboarding_applications.sql` to Supabase.
- Redeploy the existing Render API and smoke-test all onboarding endpoints.
- Repeat BlueStacks onboarding/admin review QA.

## Placeholder only

- Document files are not uploaded. Only type/filename metadata is stored.
- Approval does not provision agencies, staff roles, taxi drivers, or vehicles.
- Agency operations, dispatch, live ride tracking, and broad admin tools.

## Before production

- Private object storage, signed upload/download, authorization, scanning, file
  limits, retention/deletion, encryption, and audit logging.
- Secure token storage and refresh/revocation lifecycle.
- Audited provisioning from approved applications.
- Real payments, notifications, localization, accessibility/device matrix,
  monitoring, backups, release signing, privacy policy, and operational support.
