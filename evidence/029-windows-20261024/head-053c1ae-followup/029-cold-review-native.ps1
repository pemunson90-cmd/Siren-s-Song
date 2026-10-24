$ErrorActionPreference='Stop'
$taskRoot=$PSScriptRoot
$godotExe='C:/Users/Archi/.cache/sirens-song-toolchain/win/Godot_v4.6.3-stable_win64_console.exe'
$gamePath=Join-Path $taskRoot 'integration/game'
$rows=@()
foreach ($shape in @('cover','inner')) {
 $casePath=Join-Path $taskRoot ('029-cold-review-native-'+$shape)
 New-Item -ItemType Directory -Force -Path $casePath | Out-Null
 $env:APPDATA=$casePath;$env:LOCALAPPDATA=$casePath;$env:XDG_DATA_HOME=$casePath
 $out=Join-Path $taskRoot ('029-cold-review-native-'+$shape+'.log')
 $err=Join-Path $taskRoot ('029-cold-review-native-'+$shape+'.err.log')
 $child=Start-Process -FilePath $godotExe -ArgumentList @('--headless','--path',$gamePath,'--script','res://tests/cold_review_archive_tests.gd','--',$shape) -WindowStyle Hidden -PassThru -RedirectStandardOutput $out -RedirectStandardError $err
 $child.WaitForExit()
 $joined=[IO.File]::ReadAllText($out)+"`n"+[IO.File]::ReadAllText($err)
 $summary=[regex]::Match($joined,'(?m)^ARCHIVE PROFILE CHECKS ([1-9][0-9]*) FAILURES 0\r?$')
 $errors=[regex]::Matches($joined,'(?im)SCRIPT ERROR:|(^|\s)ERROR:|resources still in use|ObjectDB instances leaked').Count
 $row=[ordered]@{shape=$shape;exit=$child.ExitCode;footer=$summary.Value.Trim();errors=$errors;passed=($child.ExitCode -eq 0 -and $summary.Success -and $errors -eq 0)}
 $rows+=$row
 $row | ConvertTo-Json -Compress
}
$rows | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $taskRoot '029-cold-review-native-results.json') -Encoding utf8
if (@($rows | Where-Object {-not $_.passed}).Count -gt 0) {exit 1}
Write-Output 'WINDOWS COLD REVIEW LAUNCHER CHECKS 2 FAILURES 0'
