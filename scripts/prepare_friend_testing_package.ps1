# Prepare Friend Testing Package
#
# Copies the debug APK to staging_artifacts/ with a fixed name,
# computes the SHA-256 hash, records file size, and prints a summary.
#
# Usage:
#   .\scripts\prepare_friend_testing_package.ps1
#
# Output:
#   staging_artifacts/cameroon-bus-staging-debug.apk   (copy of the APK)
#   staging_artifacts/APK_CHECKSUM.txt                  (hash and size)
#
# The staging_artifacts/ directory is git-ignored.

param(
    [string]$ApkSource = "",
    [string]$OutputDir = ""
)

$ErrorActionPreference = "Stop"

# Determine paths
$RootDir = Split-Path -Parent $PSScriptRoot

if (-not $ApkSource) {
    $ApkSource = Join-Path $RootDir "apps\mobile_app\build\app\outputs\flutter-apk\app-debug.apk"
}

if (-not $OutputDir) {
    $OutputDir = Join-Path $RootDir "staging_artifacts"
}

# Resolve source
$ApkSource = Resolve-Path $ApkSource -ErrorAction Stop
Write-Host "Source APK: $ApkSource" -ForegroundColor Cyan

# Create output directory
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
    Write-Host "Created: $OutputDir" -ForegroundColor Yellow
}

# Destination path
$DestPath = Join-Path $OutputDir "cameroon-bus-staging-debug.apk"

# Copy
Write-Host "Copying APK..." -ForegroundColor Yellow
Copy-Item -Path $ApkSource -Destination $DestPath -Force
Write-Host "Copied to: $DestPath" -ForegroundColor Green

# Compute SHA-256
Write-Host "Computing SHA-256..." -ForegroundColor Yellow
$hash = Get-FileHash -Path $DestPath -Algorithm SHA256
$sha256 = $hash.Hash

# Get file size
$fileInfo = Get-Item -Path $DestPath
$sizeBytes = $fileInfo.Length
$sizeMiB = [math]::Round($sizeBytes / 1MB, 1)

# Write checksum file
$checksumContent = @"
Friend Testing APK Checksum
===========================
File: cameroon-bus-staging-debug.apk
SHA-256: $sha256
Size: $sizeBytes bytes ($sizeMiB MiB)
API: https://cameroon-bus-api-staging.onrender.com/api/v1
Prepared: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

How to verify:
  Windows:  certutil -hashfile cameroon-bus-staging-debug.apk SHA256
  macOS:    shasum -a 256 cameroon-bus-staging-debug.apk
  Linux:    sha256sum cameroon-bus-staging-debug.apk
"@

$ChecksumPath = Join-Path $OutputDir "APK_CHECKSUM.txt"
$checksumContent | Out-File -FilePath $ChecksumPath -Encoding utf8
Write-Host "Checksum written to: $ChecksumPath" -ForegroundColor Green

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Friend Testing Package Ready" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "APK:    $DestPath" -ForegroundColor White
Write-Host "Size:   $sizeBytes bytes ($sizeMiB MiB)" -ForegroundColor White
Write-Host "SHA-256: $sha256" -ForegroundColor White
Write-Host "API:    https://cameroon-bus-api-staging.onrender.com/api/v1" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Share the APK file with your testers." -ForegroundColor Green
Write-Host "Direct them to docs/friend_testing_guide.md for instructions." -ForegroundColor Green
