# Next Steps

1. Load the ignored Supabase Session Pooler URL into process-only `DATABASE_URL`.
2. Apply only the new migration:
   `powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\push_supabase_schema.ps1 -MigrationPath database/migrations/008_onboarding_applications.sql`.
3. Redeploy the existing Render service from the new commit.
4. Smoke-test all five onboarding/admin endpoints.
5. Install the rebuilt APK in BlueStacks and run the application/review plan.
6. Decide whether status approval should later create agency/driver records and
   roles through a separate audited workflow.
7. Design private Supabase Storage before implementing real document upload.

Do not upload documents, create roles, or treat approval as production onboarding yet.
