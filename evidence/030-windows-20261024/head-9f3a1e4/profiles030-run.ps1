param([string]$Suite='save_profiles_ui_tests',[switch]$Headless)
$ErrorActionPreference='Stop'
$env:APPDATA=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot ("profiles030-"+$Suite+"-appdata")))
$env:LOCALAPPDATA=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot ("profiles030-"+$Suite+"-local")))
New-Item -ItemType Directory -Force $env:APPDATA,$env:LOCALAPPDATA | Out-Null
$godot='C:\Users\Archi\.cache\sirens-song-toolchain\win\Godot_v4.6.3-stable_win64_console.exe'
$out=Join-Path $PSScriptRoot ($Suite+'.log');$err=Join-Path $PSScriptRoot ($Suite+'.err.log')
$args030="--path game --rendering-method gl_compatibility --audio-driver Dummy --script res://tests/$Suite.gd"
if($Headless){$args030='--headless '+$args030}
$proc=Start-Process -FilePath $godot -ArgumentList $args030 -WindowStyle Hidden -PassThru -RedirectStandardOutput $out -RedirectStandardError $err
while(-not $proc.WaitForExit(25000)){Write-Output "RUNNING PID $($proc.Id)"}
Write-Output "EXIT $($proc.ExitCode)"
Get-Content $out | Select-String 'EMPTY STATE|CHECKS|FAIL'
Get-Content $err
exit $proc.ExitCode


