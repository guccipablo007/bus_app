param(
  [switch]$ConfirmStaging
)

$ErrorActionPreference = 'Stop'

if (-not $ConfirmStaging) {
  throw 'Refusing to run seeds without -ConfirmStaging.'
}

if ([string]::IsNullOrWhiteSpace($env:DATABASE_URL)) {
  throw 'DATABASE_URL must be set in the process environment.'
}

$root = Split-Path $PSScriptRoot -Parent
$runner = Join-Path $PSScriptRoot 'run_sql_files_with_pg.mjs'
$seedDirectory = Join-Path $root 'database\seeds'

Write-Host 'Running ordered seed files against the configured staging database.'
Write-Host 'DATABASE_URL is set but will not be printed.'

Push-Location $root
try {
  node $runner $seedDirectory
  if ($LASTEXITCODE -ne 0) {
    throw "Seed runner failed with exit code $LASTEXITCODE."
  }
} finally {
  Pop-Location
}
