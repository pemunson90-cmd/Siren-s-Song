param([string]$Suite,[string]$Prefix,[string]$Tag)
$env:ARTIFACT_DIR="$env:USERPROFILE\.cache\sirens-song-toolchain\artifacts\fable-wp-136-$Tag"
New-Item -ItemType Directory -Force $env:ARTIFACT_DIR | Out-Null
& "$PSScriptRoot\..\scripts\toolchain\win\headless.ps1" -Action Script -Script $Suite -Prefix $Prefix -TimeoutSec 1700 | Out-Null
Select-String -Path "$env:ARTIFACT_DIR\$Suite.log" -Pattern "^(PRESS|STATE|FAIL|CHECK)|CHECKS|SCRIPT ERROR|ERROR:" | ForEach-Object { $_.Line.Substring(0,[Math]::Min(700,$_.Line.Length)) }
