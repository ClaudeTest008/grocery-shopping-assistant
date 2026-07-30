<#
.SYNOPSIS
Runs build_runner for Freezed and json_serializable output.

.PARAMETER Watch
Keep running and regenerate on save.

.PARAMETER Clean
Delete generated files and the build_runner cache first. Use this when
you hit duplicate-class errors in *.freezed.dart.

.EXAMPLE
.\scripts\codegen.ps1 -Watch
.EXAMPLE
.\scripts\codegen.ps1 -Clean
#>
[CmdletBinding()]
param(
    [switch]$Watch,
    [switch]$Clean
)

. "$PSScriptRoot\_common.ps1"
Initialize-FlutterEnvironment | Out-Null

if ($Clean) {
    Write-Step 'Removing generated sources'
    Get-ChildItem -Path "$RepoRoot\lib" -Recurse -Include '*.freezed.dart', '*.g.dart' |
        Remove-Item -Force
    Invoke-Checked 'build_runner clean' { & dart run build_runner clean }
}

$mode = if ($Watch) { 'watch' } else { 'build' }
Invoke-Checked "build_runner $mode" {
    & dart run build_runner $mode --delete-conflicting-outputs
}
