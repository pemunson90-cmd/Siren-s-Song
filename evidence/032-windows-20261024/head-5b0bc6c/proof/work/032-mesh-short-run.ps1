$ErrorActionPreference='Stop'
$taskRoot=$PSScriptRoot
$lock=[IO.File]::Open((Join-Path $taskRoot '032-godot-active.lock'),[IO.FileMode]::OpenOrCreate,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None)
try {
 $packet=Join-Path $taskRoot '032-native/mesh-short-01'
 if(Test-Path -LiteralPath $packet){throw 'Profile path already exists'}
 $env:APPDATA=Join-Path $packet 'appdata';$env:LOCALAPPDATA=Join-Path $packet 'local';$env:XDG_DATA_HOME=Join-Path $packet 'xdg'
 New-Item -ItemType Directory -Force (Join-Path $env:APPDATA "Godot/app_userdata/Siren's Song"),$env:LOCALAPPDATA,$env:XDG_DATA_HOME|Out-Null
 $exe='C:/Users/Archi/.cache/sirens-song-toolchain/win/Godot_v4.6.3-stable_win64_console.exe'
 $argsList=@('--path',(Join-Path $taskRoot 'landmarks-merge/game'),'--rendering-method','gl_compatibility','--position','-9000,-9000','--audio-driver','Dummy','--script',(Join-Path $taskRoot '032-mesh-short.gd'),'--',('--folder='+$packet),'--frames=300','--blocks=3')
 $out=Join-Path $packet 'profile.out.log';$err=Join-Path $packet 'profile.err.log'
 $p=Start-Process -FilePath $exe -ArgumentList $argsList -WindowStyle Hidden -PassThru -RedirectStandardOutput $out -RedirectStandardError $err
 [ordered]@{pid=$p.Id;args=$argsList;source='7619ff17069bf52534239702c54462bac8793561';started=(Get-Date).ToUniversalTime().ToString('o');appdata=$env:APPDATA;localappdata=$env:LOCALAPPDATA}|ConvertTo-Json -Depth 4|Set-Content (Join-Path $packet 'launch.json')
 if(-not $p.WaitForExit(180000)){$p.Kill();$p.WaitForExit();throw 'Owned art profile timed out'}
 $joined=[IO.File]::ReadAllText($out)+"`n"+[IO.File]::ReadAllText($err)
 $footer=[regex]::Matches($joined,'(?m)^ART RENDER CHECKS [1-9][0-9]* FAILURES 0\r?$')
 $errors=[regex]::Matches($joined,'(?im)\x00|SCRIPT ERROR:|(^|\s)ERROR:|resources still in use|ObjectDB instances leaked|^FAIL ').Count
 $row=[ordered]@{exit=$p.ExitCode;footer=($footer.Value -join ';');errors=$errors;passed=($p.ExitCode -eq 0 -and $footer.Count -gt 0 -and $errors -eq 0)}
 $row|ConvertTo-Json|Set-Content (Join-Path $packet 'result.json');$row|ConvertTo-Json -Compress
 if(-not $row.passed){exit 1}
} finally {$lock.Dispose()}
