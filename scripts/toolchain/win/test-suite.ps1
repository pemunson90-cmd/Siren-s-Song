# Windows counterpart of test.sh --profile/--suite (no Android/Linux-only self tests).
#
#   test-suite.ps1 -List -Profile ci
#   test-suite.ps1 -Suite sweeper_tests,back_exit_tests
#   test-suite.ps1 -All -Profile local            (the whole profile, in rank order)
#
# Suites registered with the 'render' backend need Xvfb and are reported as SKIPPED.
# Tests run with an isolated APPDATA by default so real saves are never touched.
[CmdletBinding()]
param(
    [string[]]$Suite = @(),
    [switch]$All,
    [ValidateSet('local', 'ci')]
    [string]$Profile = 'local',
    [switch]$List,
    [switch]$SkipCore,
    [switch]$NoIsolate,
    [string]$UserDataRoot = '',
    [int]$TimeoutSec = 480
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'common.ps1')
Assert-Project

# powershell -File passes 'a,b' as one string, so split commas ourselves.
$Suite = @($Suite | ForEach-Object { $_ -split ',' } | Where-Object { $_ })
$registry = Read-SuiteRegistry
$rankOf = { param($r) if ($Profile -eq 'local') { $r.LocalRank } else { $r.CiRank } }

if ($Suite.Count -gt 0) {
    $selected = foreach ($s in $Suite) {
        $row = $registry | Where-Object { $_.Name -eq $s }
        if (-not $row) { throw "Unknown suite: $s" }
        $row
    }
} elseif ($All -or $List) {
    $selected = $registry | Where-Object { $null -ne (& $rankOf $_) } | Sort-Object { [int](& $rankOf $_) }
} else {
    throw 'Choose -Suite NAME[,NAME], -All, or -List. Running a whole profile is deliberate: pass -All.'
}
if ($SkipCore) { $selected = @($selected | Where-Object { $_.Name -ne 'run_tests' }) }
$selected = @($selected)

if ($List) { $selected | ForEach-Object { $_.Name }; exit 0 }

$iso = ''
if (-not $NoIsolate) { $iso = New-IsolatedRoot $UserDataRoot }
$results = New-Object System.Collections.Generic.List[object]
foreach ($row in $selected) {
    $status = 'PASS'; $checks = ''; $secs = 0.0
    if ($row.Backend -eq 'render') {
        $status = 'SKIPPED'
    } else {
        $log = Join-Path $script:ArtifactDir ($row.Name + '.log')
        $sw = [Diagnostics.Stopwatch]::StartNew()
        $code = Invoke-GodotLogged -GodotArgs @('--headless', '--path', $script:GameDir, '--script', "res://tests/$($row.Name).gd") `
            -Log $log -TimeoutSec $TimeoutSec -IsolatedRoot $iso
        $sw.Stop(); $secs = $sw.Elapsed.TotalSeconds
        $res = Test-GodotLog -Log $log -Prefix $row.Prefix -RequireSummary $true
        if ($null -ne $res.Checks) { $checks = [string]$res.Checks }
        if ($code -eq -1) { $status = 'FAIL (timeout)' }
        elseif ($code -ne 0 -or $res.Problems.Count -gt 0) {
            $status = 'FAIL'
            foreach ($p in $res.Problems | Select-Object -First 3) { Write-Host "  [$($row.Name)] $p" }
            if ($code -ne 0) { Write-Host "  [$($row.Name)] exit code $code" }
        }
    }
    $rank = & $rankOf $row
    $results.Add([pscustomobject]@{ Rank = $rank; Suite = $row.Name; Status = $status; Checks = $checks; Seconds = [math]::Round($secs, 1) })
    Write-Host ("{0,-8} {1}" -f $status, $row.Name)
}

Write-Host ''
$results | Format-Table Rank, Suite, Status, Checks, Seconds -AutoSize | Out-String -Width 200 | Write-Host
$pass = @($results | Where-Object { $_.Status -eq 'PASS' }).Count
$fail = @($results | Where-Object { $_.Status -like 'FAIL*' }).Count
$skip = @($results | Where-Object { $_.Status -eq 'SKIPPED' }).Count
Write-Host "SUMMARY profile=$Profile pass=$pass fail=$fail skipped=$skip total=$($results.Count)"
if ($fail -gt 0) { exit 1 }
exit 0
