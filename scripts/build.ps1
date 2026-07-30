<#
.SYNOPSIS
Builds a release artifact for one or more targets.

.PARAMETER Target
windows, web, apk, appbundle, or all. Defaults to windows.

.PARAMETER Debug
Build the debug variant instead of release.

.EXAMPLE
.\scripts\build.ps1 -Target windows
.EXAMPLE
.\scripts\build.ps1 -Target all
#>
[CmdletBinding()]
param(
    [ValidateSet('windows', 'web', 'apk', 'appbundle', 'all')]
    [string]$Target = 'windows',

    [switch]$Debug
)

. "$PSScriptRoot\_common.ps1"
$flutter = Initialize-FlutterEnvironment

$mode = if ($Debug) { '--debug' } else { '--release' }
$targets = if ($Target -eq 'all') { @('windows', 'web', 'apk') } else { @($Target) }

# The web demo is deployed to GitHub Pages under a project sub-path.
$extraArgs = @{ web = @('--base-href', '/grocery-shopping-assistant/') }

foreach ($t in $targets) {
    $buildArgs = @('build', $t, $mode)
    if ($extraArgs.ContainsKey($t)) { $buildArgs += $extraArgs[$t] }
    Invoke-Checked "flutter $($buildArgs -join ' ')" { & $flutter @buildArgs }
}

Write-Host ""
Write-Host 'Artifacts:' -ForegroundColor Green
foreach ($t in $targets) {
    switch ($t) {
        'windows' { Write-Host '  build\windows\x64\runner\Release\grocery_shopping_assistant.exe' }
        'web' { Write-Host '  build\web\' }
        'apk' { Write-Host '  build\app\outputs\flutter-apk\app-release.apk' }
        'appbundle' { Write-Host '  build\app\outputs\bundle\release\app-release.aab' }
    }
}
