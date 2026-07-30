<#
.SYNOPSIS
Runs the test suite.

.PARAMETER Coverage
Also write coverage/lcov.info.

.PARAMETER UpdateGoldens
Regenerate golden files instead of comparing against them.

.PARAMETER Path
Limit the run to one file or directory.

.EXAMPLE
.\scripts\test.ps1 -Coverage
.EXAMPLE
.\scripts\test.ps1 -Path test/features/shopping_lists
#>
[CmdletBinding()]
param(
    [switch]$Coverage,
    [switch]$UpdateGoldens,
    [string]$Path
)

. "$PSScriptRoot\_common.ps1"
$flutter = Initialize-FlutterEnvironment

$flutterArgs = @('test')
if ($Coverage) { $flutterArgs += '--coverage' }
if ($UpdateGoldens) { $flutterArgs += '--update-goldens' }
else { $flutterArgs += '--exclude-tags=golden' }
if ($Path) { $flutterArgs += $Path }

Invoke-Checked "flutter $($flutterArgs -join ' ')" { & $flutter @flutterArgs }

if ($Coverage) {
    Write-Host "Coverage written to coverage\lcov.info" -ForegroundColor DarkGray
}
