[CmdletBinding()]
param(
    [string]$MigrationPath = 'database/migrations'
)

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
    $resolvedMigrationPath = [IO.Path]::GetFullPath((Join-Path $root $MigrationPath))
    $migrationRoot = [IO.Path]::GetFullPath((Join-Path $root 'database\migrations'))
    if (-not $resolvedMigrationPath.StartsWith($migrationRoot, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'MigrationPath must stay inside database/migrations.'
    }
    if (-not (Test-Path -LiteralPath $resolvedMigrationPath)) {
        throw "MigrationPath does not exist: $MigrationPath"
    }
    Write-Host "Applying Supabase staging migration path: $MigrationPath"
    & node '.\scripts\run_sql_files_with_pg.mjs' $MigrationPath
    if ($LASTEXITCODE -ne 0) {
        throw 'Supabase migration runner failed.'
    }
    Write-Host 'Supabase staging migrations completed.'
} finally {
    Pop-Location
}
