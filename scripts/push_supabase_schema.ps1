[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

if ([string]::IsNullOrWhiteSpace($env:DATABASE_URL)) {
    throw 'DATABASE_URL must be set in the current process environment.'
}

try {
    $databaseUri = [Uri]$env:DATABASE_URL
} catch {
    throw 'DATABASE_URL is not a valid URI.'
}

if ($databaseUri.Scheme -notin @('postgres', 'postgresql')) {
    throw 'DATABASE_URL must use the postgres or postgresql scheme.'
}

if ($databaseUri.Host -notlike '*.supabase.co' -and $databaseUri.Host -notlike '*.pooler.supabase.com') {
    throw 'DATABASE_URL must point to a Supabase database host.'
}

Push-Location $root
try {
    Write-Host 'Applying ordered migrations to Supabase staging.'
    & node '.\scripts\run_sql_files_with_pg.mjs' 'database/migrations'
    if ($LASTEXITCODE -ne 0) {
        throw 'Supabase migration runner failed.'
    }
    Write-Host 'Supabase staging migrations completed.'
} finally {
    Pop-Location
}
