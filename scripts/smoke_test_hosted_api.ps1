[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ApiBaseUrl
)

$ErrorActionPreference = 'Stop'
$baseUrl = $ApiBaseUrl.Trim().TrimEnd('/')

try {
    $uri = [Uri]$baseUrl
} catch {
    throw 'ApiBaseUrl must be a valid absolute URL.'
}

$isLocal = $uri.Host -in @('localhost', '127.0.0.1', '::1')
if ($uri.Scheme -ne 'https' -and -not $isLocal) {
    throw 'Hosted API smoke tests require HTTPS.'
}

function Invoke-SmokeGet {
    param([Parameter(Mandatory = $true)][string]$Path)

    Invoke-RestMethod -Method Get -Uri "$baseUrl/$Path" -TimeoutSec 90 -Headers @{ Accept = 'application/json' }
}

Write-Host 'Checking hosted API health (a Render Free cold start may take up to 90 seconds).'
$health = Invoke-SmokeGet -Path 'health'
if ($health.status -ne 'ok' -or $health.database -ne 'reachable') {
    throw "Health check failed: status=$($health.status), database=$($health.database)."
}

$regions = @(Invoke-SmokeGet -Path 'regions')
$cities = @(Invoke-SmokeGet -Path 'cities')
$trips = @(Invoke-SmokeGet -Path 'trips/search?originCity=Buea&destinationCity=Bamenda')

if ($regions.Count -lt 5) { throw 'Region response is incomplete.' }
if ($cities.Count -lt 8) { throw 'City response is incomplete.' }
if ($trips.Count -lt 1) { throw 'Buea to Bamenda trip search returned no trips.' }

[pscustomobject]@{
    status = 'passed'
    service = $health.service
    environment = $health.environment
    database = $health.database
    regions = $regions.Count
    cities = $cities.Count
    bueaToBamendaTrips = $trips.Count
} | ConvertTo-Json -Compress
