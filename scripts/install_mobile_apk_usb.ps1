# Install Mobile APK via USB
#
# Installs the debug APK on a connected Android device over USB.
#
# Prerequisites:
#   - Android device with USB Debugging enabled
#   - Device connected via USB and authorized (accept RSA key on phone)
#   - adb installed and in PATH
#
# Usage:
#   .\scripts\install_mobile_apk_usb.ps1
#
# Options:
#   .\scripts\install_mobile_apk_usb.ps1 -ApkPath "custom/path/app.apk"
#   .\scripts\install_mobile_apk_usb.ps1 -UninstallFirst

param(
    [string]$ApkPath = "",
    [switch]$UninstallFirst = $false
)

$ErrorActionPreference = "Stop"

# Determine APK path
if (-not $ApkPath) {
    $RootDir = Split-Path -Parent $PSScriptRoot
    $ApkPath = Join-Path $RootDir "apps\mobile_app\build\app\outputs\flutter-apk\app-debug.apk"
}

# Resolve to absolute path
$ApkPath = Resolve-Path $ApkPath -ErrorAction Stop
Write-Host "APK: $ApkPath" -ForegroundColor Cyan

# Check adb
$adb = Get-Command adb -ErrorAction SilentlyContinue
if (-not $adb) {
    Write-Host "ERROR: adb not found. Install Android SDK platform-tools." -ForegroundColor Red
    exit 1
}

# Check for connected devices
Write-Host "Checking connected devices..." -ForegroundColor Yellow
$devices = & adb devices | Select-String "device$"
if (-not $devices) {
    Write-Host "ERROR: No Android device connected. Connect USB and enable USB debugging." -ForegroundColor Red
    exit 1
}

# Show device list
Write-Host "Connected device(s):" -ForegroundColor Green
& adb devices

# Get first device
$deviceId = (& adb devices | Select-String "device$" | ForEach-Object { $_ -split '\s+' | Select-Object -First 1 } | Select-Object -First 1)
Write-Host "Installing on: $deviceId" -ForegroundColor Cyan

# Uninstall first if requested
if ($UninstallFirst) {
    Write-Host "Uninstalling previous version..." -ForegroundColor Yellow
    & adb -s $deviceId uninstall com.cameroonbus.mobile_app
}

# Install
Write-Host "Installing APK..." -ForegroundColor Yellow
$result = & adb -s $deviceId install -r $ApkPath

if ($LASTEXITCODE -eq 0) {
    Write-Host "Installation successful!" -ForegroundColor Green
    Write-Host "Launch the app from your device's app drawer." -ForegroundColor Green
}
else {
    Write-Host "Installation failed." -ForegroundColor Red
    Write-Host "Check that USB debugging is enabled and the device is authorized." -ForegroundColor Red
    exit 1
}
