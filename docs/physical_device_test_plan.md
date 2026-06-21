# Physical Device Test Plan

## Artifact and accounts

```text
APK: staging_artifacts/cameroon-bus-staging-debug.apk
SHA-256: 0B2B6C31E67006ADC9F06ECF305095E4BCED3605C0E1ADCE0E393F9B4FD4694F
Passenger: passenger.demo@cameroonbus.test / Password123!
Super admin: superadmin.demo@cameroonbus.test / Password123!
```

## BlueStacks checks

1. Clear old app data, install APK, and verify passenger login/session restore.
2. Profile: open Apply as bus company, Apply as taxi driver, My Applications.
3. Confirm empty forms show validation errors.
4. Submit an agency application with a clearly fake document filename.
5. Confirm pending-review screen and My Applications `submitted` status.
6. Submit a driver application and verify it appears separately.
7. Confirm all document wording says metadata/placeholder, never uploaded.
8. Login as super admin; verify agency and driver queues plus metadata.
9. Approve the agency application and reject the driver with a reason.
10. Login as passenger; verify approved/rejected states and rejection reason.
11. Confirm approval did not add agency/driver roles automatically.
12. Repeat trip search, seat booking, demo payment, ticket, and taxi request.
