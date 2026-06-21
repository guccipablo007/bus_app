# Staging Known Limitations

- Sign-out is fixed in source/tests; BlueStacks matrix validation is pending.
- Sessions use SharedPreferences for QA, not production secure storage.
- Documents are metadata-only; no file bytes are uploaded.
- Application approval is status-only and grants no role or entity.
- Render Free cold starts, shared data, demo payment, placeholder operations,
  approximate coordinates/fares, and debug signing remain staging-only.
- Production requires secure token lifecycle, private document storage, audited
  provisioning, monitoring, release signing, and privacy/retention controls.
