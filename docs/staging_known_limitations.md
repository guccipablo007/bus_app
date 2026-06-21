# Staging Known Limitations

- Document handling is metadata-only; no file bytes are uploaded or stored.
- Approval changes status only and grants no role or agency/driver record.
- Smoke tests created four clearly named staging applications.
- Render Free can cold-start after idle.
- Sessions use SharedPreferences for QA rather than production secure storage.
- Operational agency/dispatch/driver functionality remains placeholder-level.
- Demo payment, shared data, approximate coordinates/fares, and debug signing
  remain staging-only.
- Production uploads require private storage, authorization, scanning, limits,
  retention/deletion policy, encryption, and audit logging.
