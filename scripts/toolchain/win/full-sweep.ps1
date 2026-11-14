# Runs every registered suite once, locally: the CI profile through test-suite.ps1, then each
# render-flagged suite through headless.ps1. Writes one line per suite to the result file.
param([string]$Repo, [string]$Out)
Set-Location $Repo
$env:ARTIFACT_DIR = Join-Path $env:USERPROFILE '.cache\sirens-song-toolchain\artifacts\fable-root'
"SWEEP START $(Get-Date -Format s) head $(git rev-parse --short HEAD)" | Out-File -FilePath $Out -Encoding utf8
& scripts\toolchain\win\headless.ps1 -Action Import -Isolate 2>&1 | Select-Object -Last 1 | Out-File -FilePath $Out -Append -Encoding utf8
$lines = & scripts\toolchain\win\test-suite.ps1 -All -Profile ci -TimeoutSec 900 2>&1
$lines | Where-Object { $_ -match '^(PASS|FAIL|SKIPPED)\s' -or $_ -match '^SUMMARY' } | Out-File -FilePath $Out -Append -Encoding utf8
"RENDER SUITES" | Out-File -FilePath $Out -Append -Encoding utf8
foreach ($row in Get-Content game\tests\suites.txt) {
    if ($row.StartsWith('#') -or -not $row.Trim()) { continue }
    $f = $row.Split('|')
    if ($f.Count -lt 5 -or $f[4] -ne 'render') { continue }
    # Some render suites run for about eight minutes (ops_home_ui_tests); the runner's default limit is 480 s.
    $r = & scripts\toolchain\win\headless.ps1 -Action Script -Script $f[0] -Prefix $f[1] -TimeoutSec 1700 2>&1
    $sum = ($r | Where-Object { $_ -match 'CHECKS \d+ FAILURES \d+' } | Select-Object -Last 1)
    $ok = ($r | Where-Object { $_ -match 'headless Script (OK|FAILED)' } | Select-Object -Last 1)
    "$($f[0]) :: $sum :: $ok" | Out-File -FilePath $Out -Append -Encoding utf8
}
# A suite in neither the CI profile nor the render list (opening_depth_policy_ui_tests) runs here, so every
# registered suite runs once.
"UNRANKED SUITES" | Out-File -FilePath $Out -Append -Encoding utf8
foreach ($row in Get-Content game\tests\suites.txt) {
    if ($row.StartsWith('#') -or -not $row.Trim()) { continue }
    $f = $row.Split('|')
    if ($f.Count -lt 4 -or $f[3] -ne '-' -or ($f.Count -ge 5 -and $f[4] -eq 'render')) { continue }
    $r = & scripts\toolchain\win\headless.ps1 -Action Script -Script $f[0] -Prefix $f[1] -TimeoutSec 1700 2>&1
    $sum = ($r | Where-Object { $_ -match 'CHECKS \d+ FAILURES \d+' } | Select-Object -Last 1)
    "$($f[0]) :: $sum" | Out-File -FilePath $Out -Append -Encoding utf8
}
"SWEEP END $(Get-Date -Format s)" | Out-File -FilePath $Out -Append -Encoding utf8
# The runner scripts print to the host, so the lines above can come out empty. The per-suite logs are the
# record: list every log written during this sweep whose last summary line reports a failure, or has none.
$start = [datetime]((Get-Content $Out -TotalCount 1) -replace '^.*SWEEP START (\S+).*$', '$1')
"FAILURES FROM LOGS (files newer than the sweep start)" | Out-File -FilePath $Out -Append -Encoding utf8
Get-ChildItem (Join-Path $env:ARTIFACT_DIR '*.log') | Where-Object { $_.LastWriteTime -ge $start -and $_.Name -ne 'import.log' } | ForEach-Object {
    $last = Select-String -Path $_.FullName -Pattern 'CHECKS \d+ FAILURES \d+' | Select-Object -Last 1
    if (-not $last) { "NO SUMMARY  $($_.Name)" | Out-File -FilePath $Out -Append -Encoding utf8 }
    elseif ($last.Line -notmatch 'FAILURES 0\s*$') { "FAIL  $($_.Name) :: $($last.Line.Trim())" | Out-File -FilePath $Out -Append -Encoding utf8 }
}
"LOG SCAN END" | Out-File -FilePath $Out -Append -Encoding utf8
