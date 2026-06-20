$ErrorActionPreference = 'Continue'

$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
$machinePath = [Environment]::GetEnvironmentVariable('Path', 'Machine')
$env:Path = "$userPath;$machinePath"
$env:JAVA_HOME = [Environment]::GetEnvironmentVariable('JAVA_HOME', 'User')
$env:ANDROID_HOME = [Environment]::GetEnvironmentVariable('ANDROID_HOME', 'User')

$commands = @(
  'git --version',
  'node -v',
  'cmd /c npm -v',
  'cmd /c pnpm -v',
  'java -version',
  'adb --version',
  'flutter --version',
  'dart --version',
  'supabase --version',
  'psql --version',
  'flutter doctor -v'
)

foreach ($command in $commands) {
  Write-Host "`n===== $command =====" -ForegroundColor Cyan
  Invoke-Expression $command
}

Write-Host "`nANDROID_HOME=$env:ANDROID_HOME"
Write-Host "JAVA_HOME=$env:JAVA_HOME"
