$ErrorActionPreference='Stop'
$taskRoot=[IO.Path]::GetFullPath($PSScriptRoot)
$gamePath=Join-Path $taskRoot 'integration/game'
$godotExe='C:/Users/Archi/.cache/sirens-song-toolchain/win/Godot_v4.6.3-stable_win64_console.exe'
$logRoot=Join-Path $taskRoot '029-later-ci-logs'
$profileRoot=Join-Path $taskRoot '029-later-ci-profiles'
New-Item -ItemType Directory -Force -Path $logRoot,$profileRoot | Out-Null
$suiteRows=@(Get-Content -LiteralPath (Join-Path $gamePath 'tests/suites.txt') | ForEach-Object {
 if ($_ -and -not $_.StartsWith('#')) {
  $fields=$_.Split('|')
  if ($fields[3] -ne '-' -and [int]$fields[3] -gt 72) {
   if ($fields[0] -notmatch '^[a-z0-9_]+$') {throw 'Unsafe suite name'}
   [pscustomobject]@{name=$fields[0];label=$fields[1];rank=[int]$fields[3];render=($fields.Count -eq 5 -and $fields[4] -eq 'render')}
  }
 }
} | Sort-Object rank)
if ($suiteRows.Count -ne 151) {throw ('Unexpected later-suite count '+$suiteRows.Count)}
$results=[Collections.Generic.List[object]]::new()
$progressPath=Join-Path $taskRoot '029-later-ci-progress.json'
foreach ($suiteRow in $suiteRows) {
 $stem=('{0:d3}-{1}' -f $suiteRow.rank,$suiteRow.name)
 $caseAppdata=Join-Path $profileRoot $stem
 New-Item -ItemType Directory -Force -Path $caseAppdata | Out-Null
 $env:APPDATA=$caseAppdata;$env:LOCALAPPDATA=$caseAppdata
 $outPath=Join-Path $logRoot ($stem+'.stdout.log');$errPath=Join-Path $logRoot ($stem+'.stderr.log')
 $godotArgs=@('--path',$gamePath,'--audio-driver','Dummy','--script',('res://tests/'+$suiteRow.name+'.gd'))
 if ($suiteRow.render) {$godotArgs+=@('--position','-10000,-10000','--rendering-method','gl_compatibility')} else {$godotArgs+=@('--headless')}
 $started=[DateTime]::UtcNow
 $caseProc=Start-Process -FilePath $godotExe -ArgumentList $godotArgs -WindowStyle Hidden -PassThru -RedirectStandardOutput $outPath -RedirectStandardError $errPath
 $timedOut=$false
 while (-not $caseProc.WaitForExit(1000)) {
  if (([DateTime]::UtcNow-$started).TotalSeconds -gt 480) {$timedOut=$true;$caseProc.Kill($true);$caseProc.WaitForExit();break}
 }
 $caseProc.WaitForExit()
 $combined=[IO.File]::ReadAllText($outPath)+"`n"+[IO.File]::ReadAllText($errPath)
 $summaryPrefix=if ($suiteRow.label) {[regex]::Escape($suiteRow.label+' ')} else {''}
 $footer=[regex]::Match($combined,'(?m)^'+$summaryPrefix+'CHECKS ([1-9][0-9]*) FAILURES 0\r?$')
 $errors=[regex]::Matches($combined,'(?im)SCRIPT ERROR:|(^|\s)ERROR:|resources still in use|ObjectDB instances leaked').Count
 $passed=($caseProc.ExitCode -eq 0 -and -not $timedOut -and $footer.Success -and $errors -eq 0)
 $row=[pscustomobject]@{rank=$suiteRow.rank;name=$suiteRow.name;render=$suiteRow.render;exit=$caseProc.ExitCode;timed_out=$timedOut;passed=$passed;errors=$errors;footer=$footer.Value.Trim();seconds=[math]::Round(([DateTime]::UtcNow-$started).TotalSeconds,2)}
 $results.Add($row)
 $progress=[ordered]@{scope='CI ranks73..223 only, after failed rank72';total=$suiteRows.Count;completed=$results.Count;failed=@($results | Where-Object {-not $_.passed}).Count;last=$row;results=$results}
 $json=$progress | ConvertTo-Json -Depth 8
 [IO.File]::WriteAllText($progressPath+'.tmp',$json,[Text.UTF8Encoding]::new($false))
 Move-Item -LiteralPath ($progressPath+'.tmp') -Destination $progressPath -Force
 if (-not $passed) {Write-Output ('FAILED '+$stem+' exit='+$caseProc.ExitCode+' errors='+$errors+' timeout='+$timedOut)}
}
Write-Output ('LATER CI COMPLETED '+$results.Count+' FAILED '+@($results | Where-Object {-not $_.passed}).Count)
if (@($results | Where-Object {-not $_.passed}).Count -gt 0) {exit 1}
