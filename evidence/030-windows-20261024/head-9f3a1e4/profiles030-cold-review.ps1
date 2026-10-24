$ErrorActionPreference='Stop'
$godot='C:\Users\Archi\.cache\sirens-song-toolchain\win\Godot_v4.6.3-stable_win64_console.exe'
foreach($shape030 in @('cover','inner')){
 $stamp030=[guid]::NewGuid().ToString('N')
 $env:APPDATA=Join-Path $PSScriptRoot ("profiles030-cold-$shape030-$stamp030-appdata")
 $env:LOCALAPPDATA=Join-Path $PSScriptRoot ("profiles030-cold-$shape030-$stamp030-local")
 $env:XDG_DATA_HOME=Join-Path $PSScriptRoot ("profiles030-cold-$shape030-$stamp030-xdg")
 New-Item -ItemType Directory -Force $env:APPDATA,$env:LOCALAPPDATA,$env:XDG_DATA_HOME | Out-Null
 $out=Join-Path $PSScriptRoot ("profiles030-cold-$shape030.log");$err=Join-Path $PSScriptRoot ("profiles030-cold-$shape030.err.log")
 $args030="--path game --rendering-method gl_compatibility --audio-driver Dummy --script res://tests/cold_review_archive_tests.gd -- $shape030"
 $proc=Start-Process -FilePath $godot -ArgumentList $args030 -WindowStyle Hidden -PassThru -RedirectStandardOutput $out -RedirectStandardError $err
 while(-not $proc.WaitForExit(25000)){Write-Output "RUNNING $shape030 PID $($proc.Id)"}
 Write-Output "$shape030 EXIT $($proc.ExitCode)"
 Get-Content $out | Select-String 'CHECKS|ARCHIVE TOUCH';Get-Content $err
 if($proc.ExitCode -ne 0){exit $proc.ExitCode}
}
