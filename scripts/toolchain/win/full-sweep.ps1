# Runs every registered suite once, locally. Writes one line per suite to the result file.
# Sharding (Pat, 15 Nov: faster sweeps): -Shard i -Of n runs every n-th suite starting at i, so n copies can run at
# once, each in its own worktree. Shard 0 also runs Core. Each shard writes its logs to its own artifact folder.
# Without -Of the script runs every suite, as before.
param([string]$Repo, [string]$Out, [int]$Shard = 0, [int]$Of = 1)
Set-Location $Repo
$env:ARTIFACT_DIR = Join-Path $env:USERPROFILE ('.cache\sirens-song-toolchain\artifacts\fable-root' + $(if ($Of -gt 1) { "-s$Shard" } else { '' }))
New-Item -ItemType Directory -Force -Path $env:ARTIFACT_DIR | Out-Null
"SWEEP START $(Get-Date -Format s) head $(git rev-parse --short HEAD) shard $Shard of $Of" | Out-File -FilePath $Out -Encoding utf8
& scripts\toolchain\win\headless.ps1 -Action Import -Isolate 2>&1 | Select-Object -Last 1 | Out-File -FilePath $Out -Append -Encoding utf8
# WP-142: suites listed in sweep-skip.txt (name | reason) are reported as SKIPPED with the reason, not run.
$skip = @{}
foreach ($line in Get-Content (Join-Path $PSScriptRoot 'sweep-skip.txt') -ErrorAction SilentlyContinue) {
    if ($line.StartsWith('#') -or -not $line.Trim()) { continue }
    $p = $line.Split('|', 2); if ($p.Count -eq 2) { $skip[$p[0].Trim()] = $p[1].Trim() }
}
# Every registered suite (run_tests is Core and runs on shard 0), then this shard's share of them.
$rows = @(Get-Content game\tests\suites.txt | Where-Object { -not $_.StartsWith('#') -and $_.Trim() } | ForEach-Object { , $_.Split('|') } | Where-Object { $_.Count -ge 4 -and $_[0] -ne 'run_tests' })
$mine = @(for ($i = 0; $i -lt $rows.Count; $i++) { if ($i % $Of -eq $Shard) { , $rows[$i] } })
if ($Shard -eq 0) {
    $r = & scripts\toolchain\win\headless.ps1 -Action Core 2>&1
    "run_tests :: $(($r | Where-Object { $_ -match 'CHECKS \d+ FAILURES \d+' } | Select-Object -Last 1))" | Out-File -FilePath $Out -Append -Encoding utf8
}
foreach ($f in $mine) {
    if ($skip.ContainsKey($f[0])) { "$($f[0]) :: SKIPPED ($($skip[$f[0]]))" | Out-File -FilePath $Out -Append -Encoding utf8; continue }
    $render = ($f.Count -ge 5 -and $f[4] -eq 'render')
    if (-not $render -and $f[3] -ne '-') {
        # A CI-ranked suite: the same runner CI uses.
        $r = & scripts\toolchain\win\test-suite.ps1 -Suite $f[0] -SkipCore -TimeoutSec 900 2>&1
        $line = ($r | Where-Object { $_ -match '^(PASS|FAIL|SKIPPED)\s' } | Select-Object -Last 1)
        "$($f[0]) :: $line" | Out-File -FilePath $Out -Append -Encoding utf8
        continue
    }
    # Render-flagged and unranked suites run one at a time through headless.ps1 (some take about ten minutes).
    # WP-142: a suite that measures real rendering prints only 'Native renderer required' headless, so it runs in a window.
    if ($f[0] -in @('art_render_measurements')) {
        $r = & scripts\toolchain\win\headless.ps1 -Action Script -Script $f[0] -Prefix $f[1] -Windowed -TimeoutSec 1700 2>&1
    } else {
        $r = & scripts\toolchain\win\headless.ps1 -Action Script -Script $f[0] -Prefix $f[1] -TimeoutSec 1700 2>&1
    }
    "$($f[0]) :: $(($r | Where-Object { $_ -match 'CHECKS \d+ FAILURES \d+' } | Select-Object -Last 1))" | Out-File -FilePath $Out -Append -Encoding utf8
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
