# Physical Device Test Plan

Run only after migration `008` and Render redeployment.

## Artifact

```text
APK: staging_artifacts/cameroon-bus-staging-debug.apk
SHA-256: 0B2B6C31E67006ADC9F06ECF305095E4BCED3605C0E1ADCE0E393F9B4FD4694F
Passenger: passenger.demo@cameroonbus.test / Password123!
Super admin: superadmin.demo@cameroonbus.test / Password123!
```

## BlueStacks checks

1. Confirm the previous passenger login/search/booking/payment/ticket/taxi flow.
2. Passenger Profile: verify Apply as bus company, Apply as taxi driver, and My applications.
3. Submit empty agency/driver forms and confirm friendly validation.
4. Submit an agency application with optional document filename metadata.
5. Confirm the pending-admin-review screen and My Applications status.
6. Confirm the UI says metadata/placeholder and never claims file upload.
7. Submit a driver application and confirm it appears separately.
8. Login as super admin and verify pending agency/driver sections.
9. Approve one application; confirm status changes only.
10. Reject one with a reason; confirm the passenger sees that reason.
11. Confirm a passenger cannot call admin review endpoints.
12. Check agency and driver dashboards show status and coming-next placeholders.
