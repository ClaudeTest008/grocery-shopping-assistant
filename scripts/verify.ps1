<#
.SYNOPSIS
Runs everything CI checks: formatting, static analysis and tests.

.EXAMPLE
.\scripts\verify.ps1
#>
[CmdletBinding()]
param()

. "$PSScriptRoot\_common.ps1"
$flutter = Initialize-FlutterEnvironment

Invoke-Checked 'dart format (check only)' {
    & dart format --output=none --set-exit-if-changed lib test
}
Invoke-Checked 'flutter analyze' { & $flutter analyze }
Invoke-Checked 'flutter test' { & $flutter test --exclude-tags=golden }

Write-Host ""
Write-Host 'All checks passed.' -ForegroundColor Green
