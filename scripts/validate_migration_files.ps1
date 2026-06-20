$ErrorActionPreference = 'Stop'

$root = Split-Path $PSScriptRoot -Parent
$migrationDirectory = Join-Path $root 'database\migrations'

$requiredFiles = @(
  '001_extensions_and_enums.sql',
  '002_users_roles_and_auth.sql',
  '003_regions_cities_agencies_terminals.sql',
  '004_buses_routes_trips.sql',
  '005_bookings_payments_tickets.sql',
  '006_residential_areas_taxi_zones.sql',
  '007_audit_indexes_and_security.sql',
  'README.md'
)

$requiredTables = @(
  'users',
  'roles',
  'user_roles',
  'passenger_profiles',
  'identity_documents',
  'regions',
  'cities',
  'agencies',
  'agency_staff',
  'terminals',
  'buses',
  'bus_seats',
  'routes',
  'trip_instances',
  'bookings',
  'booking_passengers',
  'trip_seat_locks',
  'payments',
  'tickets',
  'residential_areas',
  'terminal_area_distances',
  'taxi_vehicles',
  'taxi_drivers',
  'taxi_rides',
  'audit_logs'
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

$requiredBookingStatuses = @(
  'pending_payment',
  'paid',
  'confirmed',
  'cancelled',
  'refunded',
  'checked_in',
  'boarded',
  'completed',
  'no_show'
)

$requiredTaxiStatuses = @(
  'requested',
  'pending_payment',
  'scheduled',
  'assigned',
  'driver_on_way',
  'passenger_picked_up',
  'completed',
  'cancelled',
  'no_show'
)

$requiredPaymentStatuses = @(
  'initialized',
  'pending',
  'successful',
  'failed',
  'expired',
  'refunded',
  'manually_confirmed'
)

$errors = [System.Collections.Generic.List[string]]::new()

foreach ($file in $requiredFiles) {
  $path = Join-Path $migrationDirectory $file
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
    $errors.Add("Missing migration file: $file")
  }
}

$sqlFiles = Get-ChildItem -LiteralPath $migrationDirectory -Filter '*.sql' |
  Sort-Object Name
$allSql = ($sqlFiles | ForEach-Object {
  Get-Content -Raw -LiteralPath $_.FullName
}) -join "`n"

foreach ($table in $requiredTables) {
  if ($allSql -notmatch "(?im)CREATE\s+TABLE\s+$table\b") {
    $errors.Add("Missing required table declaration: $table")
  }
}

foreach ($role in $requiredRoles) {
  if ($allSql -notmatch "(?i)'$role'") {
    $errors.Add("Missing required role: $role")
  }
}

foreach ($status in $requiredBookingStatuses) {
  if ($allSql -notmatch "(?i)'$status'") {
    $errors.Add("Missing required booking status: $status")
  }
}

foreach ($status in $requiredTaxiStatuses) {
  if ($allSql -notmatch "(?i)'$status'") {
    $errors.Add("Missing required taxi ride status: $status")
  }
}

foreach ($status in $requiredPaymentStatuses) {
  if ($allSql -notmatch "(?i)'$status'") {
    $errors.Add("Missing required payment status: $status")
  }
}

$requiredPatterns = @{
  'postgis extension guard' = '(?im)CREATE\s+EXTENSION\s+IF\s+NOT\s+EXISTS\s+postgis'
  'pgcrypto extension guard' = '(?im)CREATE\s+EXTENSION\s+IF\s+NOT\s+EXISTS\s+pgcrypto'
  'terminal geography point' = '(?is)CREATE\s+TABLE\s+terminals\b.*?location\s+geography\s*\(\s*Point\s*,\s*4326\s*\)'
  'residential geography point' = '(?is)CREATE\s+TABLE\s+residential_areas\b.*?center_point\s+geography\s*\(\s*Point\s*,\s*4326\s*\)'
  'residential optional polygon' = '(?is)CREATE\s+TABLE\s+residential_areas\b.*?boundary\s+geography\s*\(\s*Polygon\s*,\s*4326\s*\)'
  'trip seat unique constraint' = '(?is)CREATE\s+TABLE\s+trip_seat_locks\b.*?UNIQUE\s*\(\s*trip_instance_id\s*,\s*seat_id\s*\)'
  'ticket QR uniqueness' = '(?is)CREATE\s+TABLE\s+tickets\b.*?qr_value\s+text\s+NOT\s+NULL\s+UNIQUE'
  'taxi booking required' = '(?is)CREATE\s+TABLE\s+taxi_rides\b.*?booking_id\s+uuid\s+NOT\s+NULL'
  'taxi passenger required' = '(?is)CREATE\s+TABLE\s+taxi_rides\b.*?passenger_id\s+uuid\s+NOT\s+NULL'
  'taxi pickup terminal required' = '(?is)CREATE\s+TABLE\s+taxi_rides\b.*?pickup_terminal_id\s+uuid\s+NOT\s+NULL'
  'taxi destination area required' = '(?is)CREATE\s+TABLE\s+taxi_rides\b.*?destination_area_id\s+uuid\s+NOT\s+NULL'
  'taxi distance limit' = '(?i)15000'
  'terminal geography index' = '(?im)USING\s+gist\s*\(\s*location\s*\)'
  'residential geography index' = '(?im)USING\s+gist\s*\(\s*center_point\s*\)'
  'encrypted identity value' = '(?im)encrypted_document_number\s+bytea\s+NOT\s+NULL'
}

foreach ($entry in $requiredPatterns.GetEnumerator()) {
  if ($allSql -notmatch $entry.Value) {
    $errors.Add("Missing required schema pattern: $($entry.Key)")
  }
}

$forbiddenPatterns = @{
  'database URL' = '(?i)postgres(?:ql)?://'
  'DATABASE_URL assignment' = '(?im)DATABASE_URL\s*='
  'Supabase service role key' = '(?i)service[_-]?role'
  'destructive database drop' = '(?im)DROP\s+DATABASE'
  'destructive schema drop' = '(?im)DROP\s+SCHEMA'
  'destructive truncate' = '(?im)\bTRUNCATE\b'
}

foreach ($entry in $forbiddenPatterns.GetEnumerator()) {
  if ($allSql -match $entry.Value) {
    $errors.Add("Forbidden content found in migrations: $($entry.Key)")
  }
}

if ($errors.Count -gt 0) {
  Write-Host 'Migration validation failed:' -ForegroundColor Red
  $errors | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }
  exit 1
}

Write-Host 'Migration validation passed.' -ForegroundColor Green
Write-Host "Files checked: $($sqlFiles.Count) SQL migrations and README.md"
Write-Host "Required tables found: $($requiredTables.Count)"
Write-Host "Required roles found: $($requiredRoles.Count)"
Write-Host 'PostGIS geography, taxi eligibility, seat uniqueness, and secret checks passed.'
