param(
  [ValidatePattern('^https://')]
  [string]$ApiBaseUrl = 'https://cameroon-bus-api-staging.onrender.com/api/v1'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$app = Join-Path $root 'apps\mobile_app'

Push-Location $app
try {
  flutter clean
  flutter pub get
  flutter analyze
  flutter test
  flutter build apk --debug --dart-define="API_BASE_URL=$ApiBaseUrl"
  Write-Host "APK: $app\build\app\outputs\flutter-apk\app-debug.apk"
} finally {
  Pop-Location
}
