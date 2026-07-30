# Shared helpers for the developer scripts.
# Dot-source this from every script: . "$PSScriptRoot\_common.ps1"

$ErrorActionPreference = 'Stop'

# Repository root is the parent of scripts/.
$script:RepoRoot = Split-Path -Parent $PSScriptRoot

<#
.SYNOPSIS
Locates the Flutter SDK even when it is not on PATH.
#>
function Get-FlutterCommand {
    $onPath = Get-Command flutter -ErrorAction SilentlyContinue
    if ($onPath) { return $onPath.Source }

    $candidates = @(
        "$env:USERPROFILE\flutter\bin\flutter.bat",
        "$env:LOCALAPPDATA\flutter\bin\flutter.bat",
        'C:\flutter\bin\flutter.bat',
        'C:\src\flutter\bin\flutter.bat'
    )
    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) { return $candidate }
    }

    throw "Flutter SDK not found. Install it, or add its bin\ directory to PATH."
}

function Initialize-FlutterEnvironment {
    $flutter = Get-FlutterCommand
    $binDir = Split-Path -Parent $flutter
    if ($env:PATH -notlike "*$binDir*") { $env:PATH = "$binDir;$env:PATH" }
    Set-Location $script:RepoRoot
    return $flutter
}

function Write-Step([string]$Message) {
    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Write-Ok([string]$Message) {
    Write-Host "  OK  $Message" -ForegroundColor Green
}

function Write-Fail([string]$Message) {
    Write-Host "  FAIL  $Message" -ForegroundColor Red
}

<#
.SYNOPSIS
Runs a command and throws with a readable message when it fails.
#>
function Invoke-Checked([string]$Label, [scriptblock]$Action) {
    Write-Step $Label
    & $Action
    if ($LASTEXITCODE -ne 0) {
        Write-Fail "$Label (exit $LASTEXITCODE)"
        exit $LASTEXITCODE
    }
    Write-Ok $Label
}
