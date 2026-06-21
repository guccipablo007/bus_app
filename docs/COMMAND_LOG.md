# Command Log

## 2026-06-21 — Friend testing preparation (GLM 5.2 session 2)

```powershell
# Hosted API smoke test
curl -s --max-time 20 "https://cameroon-bus-api-staging.onrender.com/api/v1/health"
curl -s --max-time 20 "https://cameroon-bus-api-staging.onrender.com/api/v1/regions"
curl -s --max-time 20 "https://cameroon-bus-api-staging.onrender.com/api/v1/cities"
curl -s --max-time 30 "https://cameroon-bus-api-staging.onrender.com/api/v1/trips/search?originCity=Buea&destinationCity=Bamenda"

# Git operations
git status
git add .gitignore docs/friend_testing_guide.md docs/physical_device_test_plan.md docs/staging_known_limitations.md scripts/install_mobile_apk_usb.ps1 scripts/prepare_friend_testing_package.ps1 docs/AGENT_HANDOFF.md docs/BUILD_STATUS.md docs/NEXT_STEPS.md
git diff --cached --name-only
git commit -m "Prepare phone QA and friend testing package"
git push origin main

# ADB device check
adb devices
```

## Results

- **Hosted API (Render):** All endpoints passed — health (ok, database reachable), 5 regions, 8 cities, 2 Buea→Bamenda trips returned with 70 available seats each.
- **Commit:** `78df3ef` — "Prepare phone QA and friend testing package" (9 files, +619/-73 lines).
- **Push:** Timed out (network connectivity issue to GitHub). Commit saved locally.
- **ADB:** No device connected. USB install skipped.
