<#
.SYNOPSIS
Starts the whole local development environment in one command.

.DESCRIPTION
Resolves the Flutter SDK, fetches packages, runs code generation when
generated sources are missing or stale, then launches the app on Windows
desktop and Chrome in separate windows. Both keep hot reload.

.PARAMETER SkipCodegen
Skip the build_runner step even if generated files look stale.

.PARAMETER WindowsOnly
Launch only the Windows desktop target.

.PARAMETER WebOnly
Launch only the Chrome target.

.EXAMPLE
.\scripts\start-dev.ps1
.EXAMPLE
.\scripts\start-dev.ps1 -WindowsOnly
#>
[CmdletBinding()]
param(
    [switch]$SkipCodegen,
    [switch]$WindowsOnly,
    [switch]$WebOnly
)

. "$PSScriptRoot\_common.ps1"
$flutter = Initialize-FlutterEnvironment
Write-Host "Flutter: $flutter" -ForegroundColor DarkGray

Invoke-Checked 'flutter pub get' { & $flutter pub get }

if (-not $SkipCodegen) {
    # Freezed/json_serializable output is committed, so only regenerate
    # when something is actually missing.
    $generated = Get-ChildItem -Path "$RepoRoot\lib" -Recurse -Filter '*.freezed.dart' -ErrorAction SilentlyContinue
    if (-not $generated) {
        Invoke-Checked 'build_runner (generated files missing)' {
            & dart run build_runner build --delete-conflicting-outputs
        }
    }
    else {
        Write-Step 'build_runner'
        Write-Ok "generated sources present ($($generated.Count) files) - skipping"
    }
}

$targets = @()
if (-not $WebOnly) { $targets += @{ Name = 'Windows desktop'; Device = 'windows' } }
if (-not $WindowsOnly) { $targets += @{ Name = 'Chrome'; Device = 'chrome' } }

foreach ($target in $targets) {
    Write-Step "Launching $($target.Name)"
    # Each target gets its own console so both keep interactive hot reload
    # (press r to reload, R to restart, q to quit in that window).
    Start-Process -FilePath 'powershell' -ArgumentList @(
        '-NoExit', '-NoProfile', '-Command',
        "Set-Location '$RepoRoot'; & '$flutter' run -d $($target.Device)"
    ) | Out-Null
    Write-Ok "$($target.Name) starting in its own window"
}

Write-Host ""
Write-Host 'Development environment started.' -ForegroundColor Green
Write-Host '  r = hot reload, R = hot restart, q = quit (in each run window)' -ForegroundColor DarkGray
