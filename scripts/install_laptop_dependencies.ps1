param(
  [switch]$Install,
  [switch]$InstallPostgresClient
)

$ErrorActionPreference = "Continue"

function Write-Section {
  param([string]$Title)
  Write-Host ""
  Write-Host "===== $Title =====" -ForegroundColor Cyan
}

function Test-CommandExists {
  param([string]$Name)
  return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Invoke-Logged {
  param(
    [string]$Label,
    [scriptblock]$Command
  )
  Write-Section $Label
  try {
    & $Command
    if ($LASTEXITCODE -ne $null -and $LASTEXITCODE -ne 0) {
      Write-Warning "$Label exited with code $LASTEXITCODE"
    }
  } catch {
    Write-Warning "$Label failed: $($_.Exception.Message)"
  }
  $global:LASTEXITCODE = 0
}

function Add-UserPathEntry {
  param([string]$PathEntry)
  if (-not $PathEntry -or -not (Test-Path -LiteralPath $PathEntry)) {
    return
  }

  $currentUserPath = [Environment]::GetEnvironmentVariable("Path", "User")
  $parts = @()
  if ($currentUserPath) {
    $parts = $currentUserPath -split ";" | Where-Object { $_ }
  }

  if ($parts -notcontains $PathEntry) {
    $newPath = (($parts + $PathEntry) -join ";")
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "Added to user PATH: $PathEntry"
  } else {
    Write-Host "Already in user PATH: $PathEntry"
  }

  $processParts = $env:Path -split ";" | Where-Object { $_ }
  if ($processParts -notcontains $PathEntry) {
    $env:Path = (($processParts + $PathEntry) -join ";")
  }
}

function Set-UserEnvironmentVariable {
  param(
    [string]$Name,
    [string]$Value
  )
  if (-not $Value -or -not (Test-Path -LiteralPath $Value)) {
    return
  }
  [Environment]::SetEnvironmentVariable($Name, $Value, "User")
  Set-Item -Path "Env:$Name" -Value $Value
  Write-Host "Set user environment variable $Name=$Value"
}

function Find-JdkHome {
  $candidates = @(
    "C:\Program Files\Eclipse Adoptium",
    "C:\Program Files\Java"
  )

  foreach ($root in $candidates) {
    if (Test-Path -LiteralPath $root) {
      $match = Get-ChildItem -LiteralPath $root -Directory -ErrorAction SilentlyContinue |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName "bin\java.exe") } |
        Sort-Object Name -Descending |
        Select-Object -First 1
      if ($match) {
        return $match.FullName
      }
    }
  }

  $java = Get-Command java.exe -ErrorAction SilentlyContinue
  if ($java) {
    $javaPath = $java.Source
    return (Resolve-Path (Join-Path (Split-Path (Split-Path $javaPath -Parent) -Parent) ".")).Path
  }

  return $null
}

function Find-AndroidSdk {
  $candidates = @(
    $env:ANDROID_HOME,
    (Join-Path $env:LOCALAPPDATA "Android\Sdk")
  ) | Where-Object { $_ }

  foreach ($candidate in $candidates) {
    if (Test-Path -LiteralPath $candidate) {
      return $candidate
    }
  }

  return $null
}

function Install-WithWinget {
  param(
    [string]$PackageId,
    [string]$DisplayName,
    [int]$TimeoutSeconds = 900
  )

  if (-not (Test-CommandExists winget)) {
    Write-Warning "winget is not available. Install $DisplayName manually."
    return
  }

  Write-Section "Installing $DisplayName with winget"
  $args = @(
    "install",
    "--id", $PackageId,
    "--exact",
    "--source", "winget",
    "--silent",
    "--disable-interactivity",
    "--accept-package-agreements",
    "--accept-source-agreements"
  )
  $process = Start-Process -FilePath "winget" -ArgumentList $args -NoNewWindow -PassThru
  if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
    try {
      Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
    } catch {}
    Write-Warning "$DisplayName winget install timed out after $TimeoutSeconds seconds."
    return
  }
  if ($process.ExitCode -ne 0) {
    Write-Warning "$DisplayName winget install exited with code $($process.ExitCode)."
  }
}

function Install-ZipFromUrl {
  param(
    [string]$Url,
    [string]$ZipPath,
    [string]$Destination
  )

  New-Item -ItemType Directory -Force -Path (Split-Path $ZipPath -Parent) | Out-Null
  New-Item -ItemType Directory -Force -Path $Destination | Out-Null
  Invoke-Logged "Downloading $Url" {
    Invoke-WebRequest -Uri $Url -OutFile $ZipPath
  }
  Invoke-Logged "Extracting $ZipPath" {
    Expand-Archive -LiteralPath $ZipPath -DestinationPath $Destination -Force
  }
}

function Install-Pnpm {
  if (Test-CommandExists pnpm) {
    Write-Host "pnpm already exists."
    return
  }

  if (-not $Install) {
    Write-Host "pnpm missing. Re-run with -Install to enable via Corepack."
    return
  }

  Invoke-Logged "Enabling Corepack" { corepack enable }
  Invoke-Logged "Preparing pnpm" { corepack prepare pnpm@latest --activate }
}

function Install-Jdk {
  if (Test-CommandExists java) {
    Write-Host "Java already exists."
  } elseif ($Install) {
    $installRoot = Join-Path $env:LOCALAPPDATA "Programs\EclipseAdoptium"
    $existing = if (Test-Path -LiteralPath $installRoot) {
      Get-ChildItem -LiteralPath $installRoot -Directory -ErrorAction SilentlyContinue |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName "bin\java.exe") } |
        Sort-Object Name -Descending |
        Select-Object -First 1
    }

    if (-not $existing) {
      Invoke-Logged "Resolving latest Eclipse Temurin JDK 17 ZIP" {
        $assets = Invoke-RestMethod -Uri "https://api.adoptium.net/v3/assets/latest/17/hotspot?architecture=x64&image_type=jdk&os=windows&vendor=eclipse"
        $package = $assets[0].binary.package
        $zip = Join-Path $env:TEMP (Split-Path $package.name -Leaf)
        $extract = Join-Path $env:TEMP ("temurin-jdk-" + [guid]::NewGuid().ToString())
        Install-ZipFromUrl -Url $package.link -ZipPath $zip -Destination $extract
        New-Item -ItemType Directory -Force -Path $installRoot | Out-Null
        $jdkDir = Get-ChildItem -LiteralPath $extract -Directory | Where-Object {
          Test-Path -LiteralPath (Join-Path $_.FullName "bin\java.exe")
        } | Select-Object -First 1
        if ($jdkDir) {
          $target = Join-Path $installRoot $jdkDir.Name
          if (Test-Path -LiteralPath $target) {
            Remove-Item -LiteralPath $target -Recurse -Force
          }
          Move-Item -LiteralPath $jdkDir.FullName -Destination $target
          Write-Host "Installed JDK to $target"
        } else {
          Write-Warning "Downloaded JDK ZIP did not contain a recognizable JDK directory."
        }
      }
    }
  } else {
    Write-Host "Java missing. Re-run with -Install to install Eclipse Temurin JDK 17."
  }

  $jdkHome = Find-JdkHome
  if ($jdkHome) {
    Set-UserEnvironmentVariable -Name "JAVA_HOME" -Value $jdkHome
    Add-UserPathEntry -PathEntry (Join-Path $jdkHome "bin")
  } else {
    Write-Warning "Could not find JDK home yet."
  }
}

function Install-AndroidStudioAndSdk {
  $androidStudioCommand = Get-Command studio64.exe -ErrorAction SilentlyContinue
  $androidStudioDefault = "C:\Program Files\Android\Android Studio\bin\studio64.exe"

  if ($androidStudioCommand -or (Test-Path -LiteralPath $androidStudioDefault)) {
    Write-Host "Android Studio appears to be installed."
  } elseif ($Install) {
    Install-WithWinget -PackageId "Google.AndroidStudio" -DisplayName "Android Studio" -TimeoutSeconds 1200
  } else {
    Write-Host "Android Studio missing. Re-run with -Install to install it with winget."
  }

  $sdk = Find-AndroidSdk
  if (-not $sdk -and $Install) {
    $sdk = Join-Path $env:LOCALAPPDATA "Android\Sdk"
    New-Item -ItemType Directory -Force -Path $sdk | Out-Null
    Set-UserEnvironmentVariable -Name "ANDROID_HOME" -Value $sdk

    $cmdlineLatest = Join-Path $sdk "cmdline-tools\latest"
    $sdkManager = Join-Path $cmdlineLatest "bin\sdkmanager.bat"
    if (-not (Test-Path -LiteralPath $sdkManager)) {
      Invoke-Logged "Resolving Android command-line tools ZIP" {
        $studioPage = Invoke-WebRequest -Uri "https://developer.android.com/studio" -UseBasicParsing
        $match = [regex]::Match($studioPage.Content, "https://dl\.google\.com/android/repository/commandlinetools-win-[0-9]+_latest\.zip")
        if (-not $match.Success) {
          throw "Could not find Android command-line tools ZIP URL on developer.android.com/studio."
        }
        $zip = Join-Path $env:TEMP "android-commandlinetools-win-latest.zip"
        $extract = Join-Path $env:TEMP ("android-cmdline-tools-" + [guid]::NewGuid().ToString())
        Install-ZipFromUrl -Url $match.Value -ZipPath $zip -Destination $extract
        New-Item -ItemType Directory -Force -Path (Split-Path $cmdlineLatest -Parent) | Out-Null
        if (Test-Path -LiteralPath $cmdlineLatest) {
          Remove-Item -LiteralPath $cmdlineLatest -Recurse -Force
        }
        $source = Join-Path $extract "cmdline-tools"
        Move-Item -LiteralPath $source -Destination $cmdlineLatest
      }
    }
  }

  if ($sdk) {
    Set-UserEnvironmentVariable -Name "ANDROID_HOME" -Value $sdk
    Add-UserPathEntry -PathEntry (Join-Path $sdk "platform-tools")
    Add-UserPathEntry -PathEntry (Join-Path $sdk "cmdline-tools\latest\bin")
  } else {
    Write-Warning "Android SDK path not found. Android Studio first-launch setup may be required."
    Write-Host "Manual Android Studio setup:"
    Write-Host "1. Open Android Studio."
    Write-Host "2. Complete Setup Wizard."
    Write-Host "3. Install Android SDK."
    Write-Host "4. Install Android SDK Platform-Tools."
    Write-Host "5. Install Android SDK Command-line Tools."
    Write-Host "6. Install one current Android SDK Platform."
    Write-Host "7. Return to Codex and rerun this script."
    return
  }

  $sdkManager = Join-Path $sdk "cmdline-tools\latest\bin\sdkmanager.bat"
  if ((Test-Path -LiteralPath $sdkManager) -and $Install) {
    Invoke-Logged "Accepting Android SDK licenses" {
      1..30 | ForEach-Object { "y" } | & $sdkManager --licenses
    }
    Invoke-Logged "Installing Android SDK platform-tools" { & $sdkManager "platform-tools" }
    Invoke-Logged "Installing Android SDK command-line tools" { & $sdkManager "cmdline-tools;latest" }
    Invoke-Logged "Installing Android SDK platform" { & $sdkManager "platforms;android-35" }
    Invoke-Logged "Installing Android SDK platform 36" { & $sdkManager "platforms;android-36" }
    Invoke-Logged "Installing Android SDK build tools" { & $sdkManager "build-tools;35.0.0" }
    Invoke-Logged "Installing Android SDK build tools 28.0.3" { & $sdkManager "build-tools;28.0.3" }
    Add-UserPathEntry -PathEntry (Join-Path $sdk "platform-tools")
  } elseif (-not (Test-Path -LiteralPath $sdkManager)) {
    Write-Warning "sdkmanager not found. Complete Android Studio Setup Wizard and install Command-line Tools."
  }
}

function Install-Flutter {
  if (Test-CommandExists flutter) {
    Write-Host "Flutter already exists."
    return
  }

  $flutterHome = Join-Path $env:LOCALAPPDATA "Flutter\flutter"
  $flutterBin = Join-Path $flutterHome "bin"

  if (Test-Path -LiteralPath (Join-Path $flutterBin "flutter.bat")) {
    Add-UserPathEntry -PathEntry $flutterBin
    return
  }

  if (-not $Install) {
    Write-Host "Flutter missing. Re-run with -Install to clone Flutter stable into $flutterHome."
    return
  }

  New-Item -ItemType Directory -Force -Path (Split-Path $flutterHome -Parent) | Out-Null
  Invoke-Logged "Cloning Flutter stable SDK" {
    git clone --branch stable https://github.com/flutter/flutter.git $flutterHome
  }
  Add-UserPathEntry -PathEntry $flutterBin
}

function Install-SupabaseCli {
  if (Test-CommandExists supabase) {
    Write-Host "Supabase CLI already exists."
    return
  }

  $installDir = Join-Path $env:LOCALAPPDATA "Programs\Supabase"
  $exePath = Join-Path $installDir "supabase.exe"

  if (Test-Path -LiteralPath $exePath) {
    Add-UserPathEntry -PathEntry $installDir
    return
  }

  if (-not $Install) {
    Write-Host "Supabase CLI missing. Re-run with -Install to download the latest Windows binary."
    return
  }

  New-Item -ItemType Directory -Force -Path $installDir | Out-Null
  $release = Invoke-RestMethod -Uri "https://api.github.com/repos/supabase/cli/releases/latest"
  $asset = $release.assets | Where-Object {
    $_.name -match "windows" -and $_.name -match "amd64" -and ($_.name -match "\.exe$" -or $_.name -match "\.zip$")
  } | Select-Object -First 1

  if (-not $asset) {
    Write-Warning "Could not find a Supabase CLI Windows amd64 asset. Install Supabase CLI manually."
    return
  }

  $downloadPath = Join-Path $env:TEMP $asset.name
  Invoke-Logged "Downloading Supabase CLI $($release.tag_name)" {
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $downloadPath
  }

  if ($downloadPath -like "*.zip") {
    $extractPath = Join-Path $env:TEMP ("supabase-cli-" + [guid]::NewGuid().ToString())
    Expand-Archive -LiteralPath $downloadPath -DestinationPath $extractPath -Force
    $downloadedExe = Get-ChildItem -LiteralPath $extractPath -Recurse -Filter "supabase.exe" | Select-Object -First 1
    if ($downloadedExe) {
      Copy-Item -LiteralPath $downloadedExe.FullName -Destination $exePath -Force
    }
  } else {
    Copy-Item -LiteralPath $downloadPath -Destination $exePath -Force
  }

  Add-UserPathEntry -PathEntry $installDir
}

function Install-PostgresClient {
  if (Test-CommandExists psql) {
    Write-Host "psql already exists."
    return
  }

  if (-not $InstallPostgresClient) {
    Write-Host "psql missing. Skipping PostgreSQL client because -InstallPostgresClient was not provided."
    return
  }

  if (-not $Install) {
    Write-Host "psql missing. Re-run with -Install -InstallPostgresClient to install PostgreSQL client tooling."
    return
  }

  Write-Warning "A safe client-only psql package was not found through winget. Skipping full PostgreSQL server install to avoid unrelated system service changes."
  Write-Host "Install psql manually later only if direct Supabase SQL scripts are chosen."
}

function Invoke-Verification {
  Write-Section "Verification"
  $checks = @(
    @{Name='git --version'; Cmd={ git --version }},
    @{Name='node -v'; Cmd={ node -v }},
    @{Name='npm -v'; Cmd={ npm -v }},
    @{Name='cmd /c npm -v'; Cmd={ cmd /c npm -v }},
    @{Name='pnpm -v'; Cmd={ pnpm -v }},
    @{Name='java -version'; Cmd={ java -version 2>&1 }},
    @{Name='adb --version'; Cmd={ adb --version }},
    @{Name='flutter --version'; Cmd={ flutter --version }},
    @{Name='dart --version'; Cmd={ dart --version }},
    @{Name='supabase --version'; Cmd={ supabase --version }},
    @{Name='psql --version'; Cmd={ psql --version }},
    @{Name='echo $env:ANDROID_HOME'; Cmd={ Write-Output $env:ANDROID_HOME }},
    @{Name='echo $env:JAVA_HOME'; Cmd={ Write-Output $env:JAVA_HOME }},
    @{Name='flutter doctor -v'; Cmd={ flutter doctor -v }}
  )

  foreach ($check in $checks) {
    Invoke-Logged $check.Name $check.Cmd
  }
}

Write-Section "Phase 1.5 laptop dependency installer"
if (-not $Install) {
  Write-Host "Running in verification/planning mode. No installs will be performed."
  Write-Host "To install missing tools after approval, run:"
  Write-Host ".\scripts\install_laptop_dependencies.ps1 -Install"
}

Install-Pnpm
Install-Jdk
Install-AndroidStudioAndSdk
Install-Flutter
Install-SupabaseCli
Install-PostgresClient

Invoke-Verification

Write-Section "Restart guidance"
Write-Host "If tools were installed or PATH/JAVA_HOME/ANDROID_HOME changed, restart the terminal before Phase 2."
Write-Host "If Android Studio was installed for the first time, open it and complete the Setup Wizard before rerunning verification."
