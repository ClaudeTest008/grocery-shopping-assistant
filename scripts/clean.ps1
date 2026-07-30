<#
.SYNOPSIS
Cleans build output and restores packages.

.PARAMETER Deep
Also remove generated Dart sources, the build_runner cache and the
Windows CMake cache. Use when a build misbehaves in ways `flutter clean`
alone does not fix.

.EXAMPLE
.\scripts\clean.ps1
.EXAMPLE
.\scripts\clean.ps1 -Deep
#>
[CmdletBinding()]
param(
    [switch]$Deep
)

. "$PSScriptRoot\_common.ps1"
$flutter = Initialize-FlutterEnvironment

Invoke-Checked 'flutter clean' { & $flutter clean }

if ($Deep) {
    Write-Step 'Removing generated sources and caches'
    Get-ChildItem -Path "$RepoRoot\lib" -Recurse -Include '*.freezed.dart', '*.g.dart' -ErrorAction SilentlyContinue |
        Remove-Item -Force
    foreach ($dir in @("$RepoRoot\build", "$RepoRoot\.dart_tool")) {
        if (Test-Path $dir) { Remove-Item -Recurse -Force $dir }
    }
    Write-Ok 'generated sources, build\ and .dart_tool\ removed'
}

Invoke-Checked 'flutter pub get' { & $flutter pub get }

if ($Deep) {
    Invoke-Checked 'build_runner build' {
        & dart run build_runner build --delete-conflicting-outputs
    }
}

Write-Host ""
Write-Host 'Project clean.' -ForegroundColor Green
