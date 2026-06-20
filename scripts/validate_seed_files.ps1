$ErrorActionPreference = 'Stop'

$root = Split-Path $PSScriptRoot -Parent
$seedDirectory = Join-Path $root 'database\seeds'
$seedDataDirectory = Join-Path $root 'database\seed-data'

$requiredSeedFiles = @(
  '001_seed_roles.sql',
  '002_seed_regions_cities.sql',
  '003_seed_demo_agency_and_staff.sql',
  '004_seed_terminals.sql',
  '005_seed_buses_and_seats.sql',
  '006_seed_routes_and_trips.sql',
  '007_seed_residential_areas.sql',
  '008_seed_terminal_area_distances.sql',
  '009_seed_demo_users.sql'
)

$requiredWarningFiles = @(
  'seed_coordinates_warning.md',
  'demo_credentials_warning.md'
)

$requiredRoles = @(
  'passenger',
  'agency_owner',
  'agency_admin',
  'agency_staff',
  'taxi_dispatcher',
  'taxi_driver',
  'super_admin'
)

$requiredRegions = @(
  'South West',
  'North West',
  'Littoral',
  'West',
  'Centre'
)

$requiredCities = @(
  'Buea',
  'Limbe',
  'Kumba',
  'Bamenda',
  'Douala',
  'Bafoussam',
  'Dschang',
  'Yaoundé'
)

$requiredRoutes = @(
  'Buea -> Bamenda',
  'Bamenda -> Buea',
  'Buea -> Douala',
  'Douala -> Buea',
  'Bamenda -> Douala',
  'Douala -> Bamenda',
  'Buea -> Yaoundé',
  'Yaoundé -> Buea',
  'Bamenda -> Yaoundé',
  'Yaoundé -> Bamenda',
  'Bafoussam -> Douala',
  'Douala -> Bafoussam',
  'Bafoussam -> Yaoundé',
  'Yaoundé -> Bafoussam'
)

$requiredAreas = @(
  'Nkwen', 'Mile 4', 'Up Station', 'Commercial Avenue', 'Small Mankon',
  'Ntarikon', 'Ntamulung', 'Foncha Street',
  'Molyko', 'Mile 17', 'Great Soppo', 'Bonduma', 'Clerks Quarter',
  'Check Point',
  'Bonaberi', 'Akwa', 'Bonamoussadi', 'Makepe', 'Bepanda', 'Deido',
  'Logbessou', 'Bonapriso',
  'Tamja', 'Djeleng', 'Tamdja', 'Banengo', 'Kamkop',
  'Bastos', 'Mvan', 'Ekounou', 'Essos', 'Melen', 'Biyem-Assi', 'Emana',
  'Nlongkak'
)

$requiredDemoEmails = @(
  'passenger.demo@cameroonbus.test',
  'agency.owner.demo@cameroonbus.test',
  'agency.admin.demo@cameroonbus.test',
  'agency.staff.demo@cameroonbus.test',
  'dispatcher.demo@cameroonbus.test',
  'driver.demo@cameroonbus.test',
  'superadmin.demo@cameroonbus.test'
)

$errors = [System.Collections.Generic.List[string]]::new()

foreach ($fileName in $requiredSeedFiles) {
  $path = Join-Path $seedDirectory $fileName
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
    $errors.Add("Missing seed file: $fileName")
  }
}

foreach ($fileName in $requiredWarningFiles) {
  $path = Join-Path $seedDataDirectory $fileName
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
    $errors.Add("Missing warning file: $fileName")
  }
}

$sqlFiles = Get-ChildItem -LiteralPath $seedDirectory -Filter '*.sql' |
  Sort-Object Name
$allSql = ($sqlFiles | ForEach-Object {
  Get-Content -Raw -LiteralPath $_.FullName
}) -join "`n"

function Test-RequiredValues {
  param(
    [string[]]$Values,
    [string]$Category
  )

  foreach ($value in $Values) {
    if ($allSql -notmatch [regex]::Escape("'$value'")) {
      $errors.Add("Missing required $Category value: $value")
    }
  }
}

Test-RequiredValues -Values $requiredRoles -Category 'role'
Test-RequiredValues -Values $requiredRegions -Category 'region'
Test-RequiredValues -Values $requiredCities -Category 'city'
Test-RequiredValues -Values $requiredRoutes -Category 'route'
Test-RequiredValues -Values $requiredAreas -Category 'residential area'
Test-RequiredValues -Values $requiredDemoEmails -Category 'demo email'

$requiredPatterns = @{
  'Unity Express Demo agency' = "(?i)'Unity Express Demo'"
  'five demo terminals' = '(?is)Buea Demo Terminal.*Bamenda Demo Terminal.*Douala Demo Terminal.*Bafoussam Demo Terminal.*Yaoundé Demo Terminal'
  '30-seat bus' = "(?i)'UNITY-DEMO-30'.*?30"
  '50-seat bus' = "(?i)'UNITY-DEMO-50'.*?50"
  '70-seat bus' = "(?i)'UNITY-DEMO-70'.*?70"
  'generated seats' = '(?i)generate_series\s*\('
  'terminal PostGIS point' = '(?i)ST_SetSRID\s*\(\s*ST_MakePoint'
  'distance calculation' = '(?i)ST_Distance\s*\('
  '15 km eligibility' = '(?i)ST_DWithin\s*\([^;]*15000'
  'rolling future trips' = '(?i)CURRENT_DATE'
  'bcrypt demo hash' = '(?i)\$2[aby]\$\d{2}\$[./A-Za-z0-9]{53}'
  'idempotent conflicts' = '(?i)ON\s+CONFLICT'
}

foreach ($entry in $requiredPatterns.GetEnumerator()) {
  if ($allSql -notmatch $entry.Value) {
    $errors.Add("Missing required seed pattern: $($entry.Key)")
  }
}

foreach ($file in $sqlFiles) {
  $sql = Get-Content -Raw -LiteralPath $file.FullName
  if ($sql -notmatch '(?i)ON\s+CONFLICT|NOT\s+EXISTS') {
    $errors.Add("Seed file lacks an idempotency guard: $($file.Name)")
  }
}

$forbiddenPatterns = @{
  'DATABASE_URL assignment' = '(?im)DATABASE_URL\s*='
  'database connection URL' = '(?i)postgres(?:ql)?://'
  'Supabase service-role material' = '(?i)service[_-]?role'
  'local container configuration' = '(?i)docker(?:-compose)?|postgis/postgis'
  'localhost database configuration' = '(?i)localhost|127\.0\.0\.1|10\.0\.2\.2'
  'destructive database reset' = '(?im)DROP\s+(?:DATABASE|SCHEMA)|\bTRUNCATE\b'
  'plaintext demo password in SQL' = '(?i)Password[0-9]{3}!'
  'identity document seed insert' = '(?i)INSERT\s+INTO\s+identity_documents'
}

foreach ($entry in $forbiddenPatterns.GetEnumerator()) {
  if ($allSql -match $entry.Value) {
    $errors.Add("Forbidden seed content found: $($entry.Key)")
  }
}

$coordinateWarning = Get-Content -Raw -LiteralPath (
  Join-Path $seedDataDirectory 'seed_coordinates_warning.md'
)
$credentialsWarning = Get-Content -Raw -LiteralPath (
  Join-Path $seedDataDirectory 'demo_credentials_warning.md'
)

if ($coordinateWarning -notmatch '(?i)approximate.*development/staging only') {
  $errors.Add('Coordinate warning must state coordinates are approximate and staging-only.')
}
if ($coordinateWarning -notmatch '(?i)verified before production') {
  $errors.Add('Coordinate warning must require production verification.')
}
if ($credentialsWarning -notmatch '(?i)Demo accounts are for staging only') {
  $errors.Add('Credential warning must mark demo accounts as staging-only.')
}
if ($credentialsWarning -notmatch '(?is)Demo passwords must not be used in\s+production') {
  $errors.Add('Credential warning must reject production use of demo passwords.')
}
if ($credentialsWarning -notmatch '(?i)Do not use real.*ID numbers') {
  $errors.Add('Credential warning must reject real passenger ID numbers.')
}

if ($errors.Count -gt 0) {
  Write-Host 'Seed validation failed:' -ForegroundColor Red
  $errors | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }
  exit 1
}

Write-Host 'Seed validation passed.' -ForegroundColor Green
Write-Host "Files checked: $($sqlFiles.Count) ordered SQL seed files"
Write-Host "Roles: $($requiredRoles.Count); regions: $($requiredRegions.Count); cities: $($requiredCities.Count)"
Write-Host "Routes: $($requiredRoutes.Count); residential areas: $($requiredAreas.Count)"
Write-Host 'Warnings, idempotency, PostGIS distance logic, and secret checks passed.'
