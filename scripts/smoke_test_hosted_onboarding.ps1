[CmdletBinding()]
param(
    [ValidatePattern('^https://')]
    [string]$ApiBaseUrl = 'https://cameroon-bus-api-staging.onrender.com/api/v1',
    [string]$PassengerIdentifier = 'passenger.demo@cameroonbus.test',
    [string]$PassengerPassword = 'Password123!',
    [string]$SuperAdminIdentifier = 'superadmin.demo@cameroonbus.test',
    [string]$SuperAdminPassword = 'Password123!',
    [switch]$SkipAdminReview
)

$ErrorActionPreference = 'Stop'
$base = $ApiBaseUrl.TrimEnd('/')
$runId = [DateTimeOffset]::UtcNow.ToString('yyyyMMddHHmmss')

function Invoke-JsonRequest {
    param(
        [Parameter(Mandatory)] [string]$Method,
        [Parameter(Mandatory)] [string]$Path,
        [hashtable]$Body,
        [string]$AccessToken
    )

    $parameters = @{
        Uri = "$base$Path"
        Method = $Method
        TimeoutSec = 120
        Headers = @{ Accept = 'application/json' }
    }
    if ($AccessToken) {
        $parameters.Headers.Authorization = "Bearer $AccessToken"
    }
    if ($null -ne $Body) {
        $parameters.ContentType = 'application/json'
        $parameters.Body = $Body | ConvertTo-Json -Depth 8 -Compress
    }
    Invoke-RestMethod @parameters
}

Write-Host 'Checking hosted health.'
$health = Invoke-JsonRequest -Method Get -Path '/health'
if ($health.status -ne 'ok' -or $health.database -ne 'reachable') {
    throw 'Hosted API health or database connectivity is not ready.'
}

Write-Host 'Logging in as seeded passenger.'
$passengerLogin = Invoke-JsonRequest -Method Post -Path '/auth/login' -Body @{
    identifier = $PassengerIdentifier
    password = $PassengerPassword
}
if (-not $passengerLogin.accessToken -or $passengerLogin.user.roles -notcontains 'passenger') {
    throw 'Passenger login did not return the expected role and access token.'
}

Write-Host 'Submitting agency application.'
$agency = Invoke-JsonRequest -Method Post -Path '/onboarding/agency-applications' `
    -AccessToken $passengerLogin.accessToken -Body @{
        companyName = "Hosted Smoke Agency $runId"
        ownerManagerName = $passengerLogin.user.fullName
        phone = '+237670000001'
        email = $passengerLogin.user.email
        city = 'Buea'
        description = 'Automated hosted staging smoke-test agency application.'
        documents = @(@{
            documentType = 'business_registration'
            originalFilename = "hosted-smoke-registration-$runId.pdf"
        })
    }
if ($agency.status -ne 'submitted' -or $agency.documents[0].status -ne 'metadata_only') {
    throw 'Agency application did not return submitted metadata-only state.'
}

Write-Host 'Submitting driver application.'
$driver = Invoke-JsonRequest -Method Post -Path '/onboarding/driver-applications' `
    -AccessToken $passengerLogin.accessToken -Body @{
        driverName = $passengerLogin.user.fullName
        phone = '+237670000001'
        city = 'Buea'
        vehiclePlate = 'SMOKE-TEST'
        documents = @(@{
            documentType = 'driver_license'
            originalFilename = "hosted-smoke-license-$runId.jpg"
        })
    }
if ($driver.status -ne 'submitted' -or $driver.documents[0].status -ne 'metadata_only') {
    throw 'Driver application did not return submitted metadata-only state.'
}

Write-Host 'Fetching passenger applications.'
$mine = @(Invoke-JsonRequest -Method Get -Path '/onboarding/my-applications' `
    -AccessToken $passengerLogin.accessToken)
$mineIds = @($mine.id)
if ($mineIds -notcontains $agency.id -or $mineIds -notcontains $driver.id) {
    throw 'My applications did not include both newly submitted applications.'
}

$adminResult = 'skipped'
if (-not $SkipAdminReview) {
    Write-Host 'Logging in as seeded super admin.'
    $adminLogin = Invoke-JsonRequest -Method Post -Path '/auth/login' -Body @{
        identifier = $SuperAdminIdentifier
        password = $SuperAdminPassword
    }
    if (-not $adminLogin.accessToken -or $adminLogin.user.roles -notcontains 'super_admin') {
        throw 'Super-admin login did not return the expected role and access token.'
    }

    Write-Host 'Fetching admin application queue.'
    $all = @(Invoke-JsonRequest -Method Get -Path '/admin/applications' `
        -AccessToken $adminLogin.accessToken)
    if ($all.id -notcontains $agency.id -or $all.id -notcontains $driver.id) {
        throw 'Admin applications did not include both smoke-test applications.'
    }

    Write-Host 'Approving agency application and rejecting driver application.'
    $approved = Invoke-JsonRequest -Method Patch -Path "/admin/applications/$($agency.id)/review" `
        -AccessToken $adminLogin.accessToken -Body @{ decision = 'approved' }
    $rejected = Invoke-JsonRequest -Method Patch -Path "/admin/applications/$($driver.id)/review" `
        -AccessToken $adminLogin.accessToken -Body @{
            decision = 'rejected'
            rejectionReason = 'Automated staging smoke-test rejection.'
        }
    if ($approved.status -ne 'approved' -or $rejected.status -ne 'rejected') {
        throw 'Admin review did not return the expected final statuses.'
    }
    $adminResult = 'passed'
}

[pscustomobject]@{
    status = 'passed'
    health = $health.status
    database = $health.database
    passengerLogin = 'passed'
    agencyApplication = $agency.status
    driverApplication = $driver.status
    myApplicationsCount = $mineIds.Count
    superAdminReview = $adminResult
    documentHandling = 'metadata_only'
} | Format-List
