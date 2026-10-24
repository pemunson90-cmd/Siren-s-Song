param([string[]]$Suites=@('test'),[switch]$Gpu,[switch]$Import,[string]$RunTag='')
$ErrorActionPreference='Stop'
$taskRoot=$PSScriptRoot
$gamePath=Join-Path $taskRoot 'landmarks-merge/game'
$evidence=Join-Path $taskRoot '031-native'
if($RunTag){$evidence=Join-Path $evidence $RunTag}
New-Item -ItemType Directory -Force $evidence|Out-Null
$exe='C:/Users/Archi/.cache/sirens-song-toolchain/win/Godot_v4.6.3-stable_win64_console.exe'
$rows=@()
foreach($suite in $Suites){
 $case=Join-Path $evidence ('final-'+$suite)
 $env:APPDATA=Join-Path $case 'appdata';$env:LOCALAPPDATA=Join-Path $case 'local';$env:XDG_DATA_HOME=Join-Path $case 'xdg'
 New-Item -ItemType Directory -Force (Join-Path $env:APPDATA "Godot/app_userdata/Siren's Song"),$env:LOCALAPPDATA,$env:XDG_DATA_HOME | Out-Null
 $out=Join-Path $evidence ($suite+'.out.log');$err=Join-Path $evidence ($suite+'.err.log')
 $argsList=@('--path',$gamePath,'--audio-driver','Dummy')
 if($Gpu){$argsList+=@('--rendering-method','gl_compatibility','--position','-9000,-9000')}else{$argsList+=@('--headless')}
 if($Import){$argsList+=@('--editor','--import','--quit')}else{$argsList+=@('--script',('res://tests/'+$suite+'.gd'))}
 if($suite -eq 'a11y_cues_ui_tests'){
  $captures=Join-Path $evidence 'captures';New-Item -ItemType Directory -Force $captures | Out-Null
  $argsList+=@('--',('--capture-dir='+$captures))
 }
 $p=Start-Process -FilePath $exe -ArgumentList $argsList -WindowStyle Hidden -PassThru -RedirectStandardOutput $out -RedirectStandardError $err
 $p.WaitForExit()
 $joined=[IO.File]::ReadAllText($out)+"`n"+[IO.File]::ReadAllText($err)
 $footer=[regex]::Matches($joined,'(?m)^.*CHECKS [1-9][0-9]* FAILURES 0\r?$')
 $errors=[regex]::Matches($joined,'(?im)\x00|SCRIPT ERROR:|(^|\s)ERROR:|resources still in use|ObjectDB instances leaked|^FAIL ').Count
 $row=[ordered]@{suite=$suite;pid=$p.Id;appdata=$env:APPDATA;localappdata=$env:LOCALAPPDATA;gpu=[bool]$Gpu;exit=$p.ExitCode;footer=($footer.Value -join ';');errors=$errors;passed=($p.ExitCode -eq 0 -and ($Import -or $footer.Count -gt 0) -and $errors -eq 0)}
 $rows+=$row;$row|ConvertTo-Json -Compress
}
$rows|ConvertTo-Json -Depth 4|Set-Content (Join-Path $evidence ('results-'+($Suites -join '_')+'.json'))
if(@($rows|Where-Object {-not $_.passed}).Count -gt 0){exit 1}
