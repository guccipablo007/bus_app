# Staging Known Limitations

- Onboarding source exists, but hosted migration/deployment is pending.
- Document handling is metadata-only; no file is uploaded or securely stored.
- Approval changes application status only. It grants no role and creates no
  agency, staff, taxi driver, or vehicle record.
- Render Free can cold-start after idle.
- Sessions use SharedPreferences for QA, not production secure storage.
- Agency, dispatcher, driver, and admin operations beyond review are placeholders.
- Demo payment, approximate coordinates/fares, shared data, and debug APK signing
  remain staging-only.
- Production uploads need private object storage and a security/retention design.
