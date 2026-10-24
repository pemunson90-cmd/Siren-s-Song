# Windows counterpart of headless.sh plus the strict result filter from test.sh.
#
#   headless.ps1 -Action Import                 import the project (editor --import)
#   headless.ps1 -Action Script -Script NAME    run one test script (NAME or res://tests/NAME.gd)
#   headless.ps1 -Action Core                   run res://tests/run_tests.gd
#   headless.ps1 -Action Raw -GodotArgs ...     pass arguments straight to Godot
#
# Exit code is non-zero on FAILURES > 0, script errors, ERROR: lines, 'resources still in
# use', leaks, a missing 'CHECKS N FAILURES M' summary, or a timeout.
[CmdletBinding()]
param(
    [ValidateSet('Import', 'Script', 'Core', 'Raw')]
    [string]$Action = 'Import',
    [string]$Script = '',
    [string]$Prefix = '',
    [string[]]$GodotArgs = @(),
    [switch]$Isolate,
    [string]$UserDataRoot = '',
    [string]$Log = '',
    [int]$TimeoutSec = 480,
    [switch]$ShowAll
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'common.ps1')
Assert-Project
$null = Assert-GodotExe

$requireSummary = $true
switch ($Action) {
    'Import' { $args2 = @('--headless', '--path', $script:GameDir, '--editor', '--import'); $requireSummary = $false; $name = 'import' }
    'Core'   { $args2 = @('--headless', '--path', $script:GameDir, '--script', 'res://tests/run_tests.gd'); $name = 'run_tests'; $Prefix = '' }
    'Script' {
        if (-not $Script) { throw '-Script is required for -Action Script' }
        $res = if ($Script -like 'res://*') { $Script } else { 'res://tests/' + ($Script -replace '\.gd$', '') + '.gd' }
        $name = [System.IO.Path]::GetFileNameWithoutExtension($res)
        $args2 = @('--headless', '--path', $script:GameDir, '--script', $res)
    }
    'Raw'    { $args2 = @('--headless', '--path', $script:GameDir) + $GodotArgs; $requireSummary = $false; $name = 'raw' }
}
if ($Action -ne 'Raw' -and $GodotArgs.Count -gt 0) { $args2 += $GodotArgs }
if (-not $Log) { $Log = Join-Path $script:ArtifactDir "$name.log" }
$iso = ''
if ($Isolate) { $iso = New-IsolatedRoot $UserDataRoot }

$sw = [Diagnostics.Stopwatch]::StartNew()
$code = Invoke-GodotLogged -GodotArgs $args2 -Log $Log -TimeoutSec $TimeoutSec -IsolatedRoot $iso
$sw.Stop()
$res = Test-GodotLog -Log $Log -Prefix $Prefix -RequireSummary $requireSummary

if ($ShowAll) {
    Get-Content -LiteralPath $Log | ForEach-Object { Write-Host $_ }
} else {
    # Filtered view: summary lines, FAIL lines and anything flagged as a problem.
    Get-Content -LiteralPath $Log | Where-Object {
        $_ -match 'CHECKS \d+ FAILURES \d+|FAIL|SCRIPT ERROR|(^|\s)ERROR:|resources still in use|ObjectDB instances leaked'
    } | ForEach-Object { Write-Host $_ }
}

$bad = $false
if ($code -eq -1) { Write-Host "TIMEOUT after $TimeoutSec s"; $bad = $true }
elseif ($code -ne 0) { Write-Host "Godot exit code $code"; $bad = $true }
foreach ($p in $res.Problems) { Write-Host "PROBLEM: $p"; $bad = $true }
$verdict = if ($bad) { 'FAILED' } else { 'OK' }
Write-Host ("headless {0} {1} in {2:N1}s (log: {3})" -f $Action, $verdict, $sw.Elapsed.TotalSeconds, $Log)
if ($bad) { exit 1 }
exit 0
