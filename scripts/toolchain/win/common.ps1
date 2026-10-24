# Shared helpers for the Windows toolchain scripts. Dot-source this file; do not run it.
# Mirrors scripts/toolchain/common.sh for native Windows PowerShell 5.1.
Set-StrictMode -Version 2.0

$script:GodotVersion = '4.6.3'
$script:WinZipName = "Godot_v$($script:GodotVersion)-stable_win64.exe.zip"
$script:WinZipSha512 = 'd44ea7ef5bab754cacd49d581b6062836b2eea12a82e1d183aebfad9cd8c7db2bd82513337bd657d6d2d5c04d46239c0570b029faf1343e81e8a2fa7b85dd83b'
$script:WinZipUrl = "https://github.com/godotengine/godot/releases/download/$($script:GodotVersion)-stable/$($script:WinZipName)"
$script:WinConsoleExeName = "Godot_v$($script:GodotVersion)-stable_win64_console.exe"

# Repository root: scripts/toolchain/win -> three levels up.
$script:ToolchainRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..'))
$script:GameDir = if ($env:GAME_DIR) { $env:GAME_DIR } else { Join-Path $script:ToolchainRoot 'game' }
$script:ToolchainCache = if ($env:TOOLCHAIN_CACHE) { $env:TOOLCHAIN_CACHE } else { Join-Path $env:USERPROFILE '.cache\sirens-song-toolchain' }
$script:ArtifactDir = if ($env:ARTIFACT_DIR) { $env:ARTIFACT_DIR } else { Join-Path $script:ToolchainCache 'artifacts' }
$script:WinBinDir = Join-Path $script:ToolchainCache 'win'
$script:DownloadsDir = Join-Path $script:ToolchainCache 'downloads'

function Get-GodotConsoleExe {
    if ($env:GODOT_BIN) { return $env:GODOT_BIN }
    return (Join-Path $script:WinBinDir $script:WinConsoleExeName)
}

function Assert-Project {
    if (-not (Test-Path -LiteralPath (Join-Path $script:GameDir 'project.godot'))) {
        throw "Missing Godot project: $(Join-Path $script:GameDir 'project.godot')"
    }
}

function Assert-GodotExe {
    $exe = Get-GodotConsoleExe
    if (-not (Test-Path -LiteralPath $exe)) {
        throw "Godot console exe not found: $exe. Run scripts\toolchain\win\install-godot.ps1 first."
    }
    return $exe
}

function ConvertTo-ArgString([string[]]$Items) {
    # Windows command-line quoting for Start-Process, which does not quote for us.
    $parts = foreach ($a in $Items) {
        if ($a -eq '') { '""' }
        elseif ($a -match '[\s"]') { '"' + ($a -replace '(\\*)"', '$1$1\"' -replace '(\\+)$', '$1$1') + '"' }
        else { $a }
    }
    return ($parts -join ' ')
}

# Runs Godot (console exe) with output captured to $Log. Returns the process exit code,
# or -1 when the timeout killed it. $IsolatedRoot, when set, redirects APPDATA and
# LOCALAPPDATA for the child only, so Godot's user:// data lands under that folder.
function Invoke-GodotLogged {
    param(
        [string[]]$GodotArgs,
        [string]$Log,
        [int]$TimeoutSec = 480,
        [string]$IsolatedRoot = ''
    )
    $exe = Assert-GodotExe
    $logDir = Split-Path -Parent $Log
    if ($logDir -and -not (Test-Path -LiteralPath $logDir)) { New-Item -ItemType Directory -Force -Path $logDir | Out-Null }
    $outFile = "$Log.stdout.tmp"
    $errFile = "$Log.stderr.tmp"
    $saveAppData = $env:APPDATA
    $saveLocal = $env:LOCALAPPDATA
    try {
        if ($IsolatedRoot) {
            $roaming = Join-Path $IsolatedRoot 'Roaming'
            $local = Join-Path $IsolatedRoot 'Local'
            New-Item -ItemType Directory -Force -Path $roaming, $local | Out-Null
            $env:APPDATA = $roaming
            $env:LOCALAPPDATA = $local
        }
        $p = Start-Process -FilePath $exe -ArgumentList (ConvertTo-ArgString $GodotArgs) `
            -NoNewWindow -PassThru -RedirectStandardOutput $outFile -RedirectStandardError $errFile
        $null = $p.Handle
        $exited = $p.WaitForExit($TimeoutSec * 1000)
        if (-not $exited) {
            try { $p.Kill() } catch { }
            $p.WaitForExit()
            $code = -1
        } else {
            $p.WaitForExit()
            $code = $p.ExitCode
        }
    } finally {
        $env:APPDATA = $saveAppData
        $env:LOCALAPPDATA = $saveLocal
    }
    $lines = @()
    if (Test-Path -LiteralPath $outFile) { $lines += @(Get-Content -LiteralPath $outFile) }
    if (Test-Path -LiteralPath $errFile) { $lines += @(Get-Content -LiteralPath $errFile) }
    Set-Content -LiteralPath $Log -Value $lines -Encoding UTF8
    Remove-Item -LiteralPath $outFile, $errFile -Force -ErrorAction SilentlyContinue
    return $code
}

# Same failure patterns as test.sh. Returns @{ Problems; Summary; Checks; Failures }.
function Test-GodotLog {
    param([string]$Log, [string]$Prefix = '', [bool]$RequireSummary = $true)
    if ($Prefix -and -not $Prefix.EndsWith(' ')) { $Prefix += ' ' }  # registry label 'FOO' means lines start 'FOO CHECKS'
    $lines = @(Get-Content -LiteralPath $Log)
    $problems = New-Object System.Collections.Generic.List[string]
    $errRe = 'SCRIPT ERROR:|(^|\s)ERROR:|resources still in use|ObjectDB instances leaked'
    foreach ($l in $lines) {
        if ($l -match $errRe) { $problems.Add($l) }
    }
    $sumRe = '^' + [regex]::Escape($Prefix) + 'CHECKS (\d+) FAILURES (\d+)\s*$'
    $summary = $null; $checks = $null; $failures = $null
    foreach ($l in $lines) {
        $m = [regex]::Match($l, $sumRe)
        if ($m.Success) { $summary = $l.Trim(); $checks = [int]$m.Groups[1].Value; $failures = [int]$m.Groups[2].Value }
    }
    if ($RequireSummary) {
        if ($null -eq $summary) { $problems.Add("Missing '${Prefix}CHECKS N FAILURES M' summary line") }
        elseif ($failures -gt 0) { $problems.Add("Suite reported FAILURES $failures") }
        elseif ($checks -lt 1) { $problems.Add('Suite reported zero checks') }
    }
    return @{ Problems = @($problems); Summary = $summary; Checks = $checks; Failures = $failures }
}

# Parses game/tests/suites.txt. Light validation only; check-suites.py is the full validator.
function Read-SuiteRegistry {
    $path = Join-Path $script:GameDir 'tests\suites.txt'
    if (-not (Test-Path -LiteralPath $path)) { throw "Missing suite registry: $path" }
    $rows = New-Object System.Collections.Generic.List[object]
    $n = 0
    foreach ($line in (Get-Content -LiteralPath $path)) {
        $n++
        if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith('#')) { continue }
        $f = $line.Split('|')
        if ($f.Count -ne 4 -and $f.Count -ne 5) { throw "suites.txt line ${n}: expected 4 or 5 fields: $line" }
        $backend = if ($f.Count -eq 5) { $f[4].Trim() } else { 'headless' }
        if ($backend -ne 'headless' -and $backend -ne 'render') { throw "suites.txt line ${n}: bad backend '$backend'" }
        $rows.Add([pscustomobject]@{
            Name = $f[0].Trim()
            Prefix = $f[1]
            LocalRank = if ($f[2].Trim() -eq '-') { $null } else { [int]$f[2] }
            CiRank = if ($f[3].Trim() -eq '-') { $null } else { [int]$f[3] }
            Backend = $backend
        })
    }
    return $rows
}

function New-IsolatedRoot([string]$Base) {
    if (-not $Base) { $Base = Join-Path $script:ToolchainCache 'isolated-userdata' }
    New-Item -ItemType Directory -Force -Path $Base | Out-Null
    return $Base
}
