# Environment Report

Phase: 0 - Environment audit only

Project root:

```text
C:\Users\Administrator\Documents\my_busapp
```

Audit date: 2026-06-20

## AGENTS.md Verification

`AGENTS.md` was found and read from:

```text
C:\Users\Administrator\Documents\my_busapp\AGENTS.md
```

The instructions are understood:

- Work directly inside `C:\Users\Administrator\Documents\my_busapp`.
- Do not create a nested project folder.
- Phase 0 must create only `docs/environment_report.md`.
- Do not scaffold Flutter apps, NestJS API, Next.js dashboard, database schema, migrations, or seed files during Phase 0.
- Final project target is an Android-first Cameroon bus booking platform with a shareable APK that talks to a hosted HTTPS NestJS API and Supabase PostgreSQL/PostGIS.

## Command Results

| Check | Result | Notes |
|---|---:|---|
| `git --version` | Installed: `git version 2.54.0.windows.1` | Available on PATH. |
| `node -v` | Installed: `v22.22.3` | Available on PATH. |
| `npm -v` | Available via `npm.cmd`: `10.9.8` | Direct PowerShell command failed because `npm.ps1` is blocked by execution policy. |
| `pnpm -v` | Missing | `pnpm` is not recognized on PATH. |
| `flutter --version` | Missing | `flutter` is not recognized on PATH. |
| `dart --version` | Missing | `dart` is not recognized on PATH. Dart normally comes with Flutter, but Flutter is not installed or not on PATH. |
| `java -version` | Missing | `java` is not recognized on PATH. |
| `adb --version` | Missing | `adb` is not recognized on PATH. Android SDK platform-tools are missing or not on PATH. |
| `docker --version` | Missing | `docker` is not recognized on PATH. |
| `docker compose version` | Missing | Docker CLI is missing, so Compose is unavailable. |
| `supabase --version` | Missing | Supabase CLI is not recognized on PATH. |
| `psql --version` | Missing | PostgreSQL client is not recognized on PATH. |
| `echo $env:ANDROID_HOME` | Not set | No value returned. |
| `echo $env:JAVA_HOME` | Not set | No value returned. |
| `flutter doctor -v` | Failed | Flutter is not recognized on PATH, so doctor could not run. |

Additional verification:

- `cmd /c npm -v` returns `10.9.8`.
- `Get-Command npm -All` found:
  - `C:\Users\Administrator\AppData\Local\hermes\node\npm.ps1`
  - `C:\Users\Administrator\AppData\Local\hermes\node\npm.cmd`
  - `C:\Users\Administrator\AppData\Local\hermes\node\npm`
- `Get-Command` found only Git and Node among the checked development tools:
  - `C:\Users\Administrator\AppData\Local\hermes\git\cmd\git.exe`
  - `C:\Users\Administrator\AppData\Local\hermes\node\node.exe`

## Installed Tools

- Git: `2.54.0.windows.1`
- Node.js: `v22.22.3`
- npm: `10.9.8`, available through `npm.cmd`
- winget: `v1.28.240`

## Missing Or Not Available On PATH

Required for Phase 2 scaffolding and later APK work:

- pnpm
- Flutter
- Dart
- Java JDK 17+
- Android SDK platform-tools / adb

Useful for hosted database and local development workflow:

- Supabase CLI
- PostgreSQL client / `psql`, only if direct Supabase SQL migration scripts are used instead of Supabase CLI

Not required under the current single-app staging plan:

- Docker
- Docker Compose

Environment variables missing:

- `ANDROID_HOME`
- `JAVA_HOME`

## Recommended Fixes

Phase 1.5 installer script prepared:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install_laptop_dependencies.ps1 -Install
```

Optional PostgreSQL client install, only if direct `psql` migration scripts are needed:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install_laptop_dependencies.ps1 -Install -InstallPostgresClient
```

1. Fix npm usage in PowerShell.
   - Current issue: PowerShell tries to run `npm.ps1`, but script execution is disabled.
   - Short-term workaround: use `npm.cmd` or run npm commands through `cmd /c`.
   - Long-term fix: adjust PowerShell execution policy for the current user, if acceptable:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

2. Install or enable pnpm.
   - With Node available, pnpm can usually be enabled through Corepack:

```powershell
corepack enable
corepack prepare pnpm@latest --activate
pnpm -v
```

3. Install Flutter SDK and add it to PATH.
   - Flutter is required before creating or building the passenger Android app and taxi driver app.
   - Dart should become available once Flutter is correctly installed.

4. Install Java JDK 17 or newer and set `JAVA_HOME`.
   - Android builds require a compatible JDK.

5. Install Android Studio or Android SDK command-line tools.
   - Install Android SDK platform-tools so `adb` is available.
   - Set `ANDROID_HOME`.
   - After installation, run:

```powershell
flutter doctor -v
```

6. Install Supabase CLI before hosted staging database work.
   - Supabase CLI is not strictly required if direct SQL scripts are used, but it is useful for `supabase login`, `supabase link`, and `supabase db push`.

7. Install PostgreSQL client tools.
   - `psql` is useful for applying migrations and checking Supabase/local database connectivity.

8. Do not install Docker for this project unless a later explicit requirement changes the architecture.
   - The current project direction uses Supabase as the staging database.
   - No local container database is planned.
   - The shareable APK must not depend on Docker or this local machine.

## Android APK Build Readiness

Android APK build is not possible yet on this machine.

Blocking issues:

- Flutter is unavailable.
- Dart is unavailable.
- Java is unavailable.
- Android SDK / `adb` is unavailable.
- `ANDROID_HOME` is not set.
- `JAVA_HOME` is not set.
- `flutter doctor -v` cannot run.

## Supabase CLI Availability

Supabase CLI is not available.

Hosted Supabase staging work can still be planned later, but actual CLI-based workflows such as `supabase login`, `supabase link`, and `supabase db push` cannot run until Supabase CLI is installed or an alternate `psql`-based workflow is prepared.

## Docker Availability

Docker is not available.

Docker Compose is also unavailable because Docker CLI is missing. Under the current single-app staging plan, this is not a blocker because no local container database is planned.

## Can The Project Proceed To Phase 1?

Yes, the project can proceed to Phase 1.

Reason:

- Phase 1 is documentation and handoff file creation, which does not require Flutter, Android SDK, Java, Docker, Supabase CLI, or `psql`.

Important caveat:

- Phase 2 and later setup can begin for Node-based project files after pnpm is installed or enabled.
- Flutter/Android phases and APK build phases must wait until Flutter, Java JDK, Android SDK, and `adb` are available.
- Supabase staging phases will need Supabase CLI and/or `psql`. Docker is not required under the current no-local-container-database plan.

## Phase 1.5 Update

`scripts/install_laptop_dependencies.ps1` was created in verification-first mode.

The script:

- Checks existing tools.
- Installs only missing tools when run with `-Install`.
- Uses Corepack for pnpm.
- Uses winget for Eclipse Temurin JDK 17 and Android Studio.
- Uses a Git clone of Flutter stable into the user's local app data folder.
- Downloads Supabase CLI from the latest GitHub release.
- Sets user-level `JAVA_HOME` and `ANDROID_HOME` when paths are found.
- Updates user PATH safely.
- Skips PostgreSQL client by default unless `-InstallPostgresClient` is provided.

No installation commands have been run yet because user approval is required first.

## Phase 1.5 Final Verification

User-approved install command:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install_laptop_dependencies.ps1 -Install -InstallPostgresClient
```

Installed or enabled:

| Tool | Status |
|---|---|
| Git | Installed: `git version 2.54.0.windows.1` |
| Node.js | Installed: `v22.22.3` |
| npm | Available through `cmd /c npm -v`: `10.9.8` |
| pnpm | Installed: `11.8.0`, use `cmd /c pnpm -v` or fix PowerShell policy |
| Java JDK | Installed: Eclipse Temurin OpenJDK `17.0.19+10` |
| Android Studio | Installed with winget: `Google.AndroidStudio` |
| Android SDK | Installed at `C:\Users\Administrator\AppData\Local\Android\Sdk` |
| Android platform-tools / adb | Installed: `37.0.0-14910828` |
| Flutter | Installed: `3.44.2` stable |
| Dart | Installed through Flutter: `3.12.2` |
| Supabase CLI | Installed: `2.107.0` |
| `ANDROID_HOME` | Set to `C:\Users\Administrator\AppData\Local\Android\Sdk` |
| `JAVA_HOME` | Set to `C:\Program Files\Eclipse Adoptium\jdk-17.0.19.10-hotspot` |

Android SDK packages installed:

- Android SDK Command-line Tools.
- Android SDK Platform-Tools.
- Android SDK Platform `android-35`.
- Android SDK Platform `android-36`.
- Android SDK Build-Tools `35.0.0`.
- Android SDK Build-Tools `28.0.3`.

Android licenses:

- Accepted.

`flutter doctor -v` result:

```text
No issues found.
```

Remaining gap:

- `psql` is not installed.
- A safe client-only `psql` winget package was not found. Full PostgreSQL server installation was skipped to avoid unrelated system service changes.
- This does not block Phase 2. Use Supabase CLI first; install `psql` later only if direct SQL migration scripts are chosen.

PowerShell note:

- Direct `npm -v` and `pnpm -v` still hit PowerShell execution policy because the `.ps1` shims are blocked.
- Workaround works:

```powershell
cmd /c npm -v
cmd /c pnpm -v
```

Phase 2 readiness:

- Phase 2 can start.
- Android APK toolchain is clean enough for Flutter Android builds.
