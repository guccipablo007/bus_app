# Next Steps

## Manual Render actions

1. Push this repository to a Git provider Render can access; do not change the
   Git remote without explicit approval.
2. In Render, choose **New > Blueprint** and select the repository.
3. Review root `render.yaml` and select the Free plan.
4. Set `DATABASE_URL` to the Supabase Session Pooler value.
5. Confirm generated JWT access, JWT refresh, and ID-encryption values exist.
6. Keep `NODE_ENV=staging`, `CORS_ORIGINS=*`, and auto-deploy off initially.
7. Manually approve/create the Render service.
8. Wait for build/start success and copy the public HTTPS service URL.
9. Run the hosted smoke test from the repository root.

Manual configuration alternative:

```text
Build: npx -y pnpm@11.8.0 install --frozen-lockfile && npx -y pnpm@11.8.0 --filter api build
Start: npx -y pnpm@11.8.0 --filter api start:prod
Health: /api/v1/health
```

These commands avoid the Render Corepack `EROFS` failure caused by attempts to
modify read-only `/usr/bin/pnpm`.

## Phase 9 gate

After the smoke test reports `status: passed`, start Phase 9 and configure
`apps/mobile_app` to consume the hosted `/api/v1` URL. Do not build the APK yet.
