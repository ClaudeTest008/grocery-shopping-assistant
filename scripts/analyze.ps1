<#
.SYNOPSIS
Static analysis. Must stay at zero issues (CI enforces this).
#>
[CmdletBinding()]
param()

. "$PSScriptRoot\_common.ps1"
$flutter = Initialize-FlutterEnvironment
Invoke-Checked 'flutter analyze' { & $flutter analyze }
