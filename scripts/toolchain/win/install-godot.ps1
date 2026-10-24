# Install the pinned official Windows Godot 4.6.3 editor into the user cache.
# Idempotent: downloads only when the zip is missing, always verifies SHA512 of the zip
# against the pinned value (refuses on mismatch), extracts only when the exes are missing.
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'common.ps1')

New-Item -ItemType Directory -Force -Path $script:DownloadsDir, $script:WinBinDir | Out-Null
$zip = Join-Path $script:DownloadsDir $script:WinZipName
$consoleExe = Join-Path $script:WinBinDir $script:WinConsoleExeName
$guiExe = Join-Path $script:WinBinDir ($script:WinConsoleExeName -replace '_console\.exe$', '.exe')

if (-not (Test-Path -LiteralPath $zip) -or (Get-Item -LiteralPath $zip).Length -eq 0) {
    Write-Host "Downloading $script:WinZipUrl"
    $partial = "$zip.partial"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $old = $ProgressPreference; $ProgressPreference = 'SilentlyContinue'
    try { Invoke-WebRequest -Uri $script:WinZipUrl -OutFile $partial -UseBasicParsing }
    finally { $ProgressPreference = $old }
    Move-Item -LiteralPath $partial -Destination $zip -Force
}

$actual = (Get-FileHash -LiteralPath $zip -Algorithm SHA512).Hash.ToLowerInvariant()
if ($actual -ne $script:WinZipSha512) {
    Write-Error "SHA512 mismatch for $zip`n  expected $script:WinZipSha512`n  actual   $actual`nRefusing to extract. The file was left in place for inspection; remove it yourself and rerun."
    exit 1
}
Write-Host "SHA512 verified: $script:WinZipName"

if ((Test-Path -LiteralPath $consoleExe) -and (Test-Path -LiteralPath $guiExe)) {
    Write-Host "Godot $script:GodotVersion already installed at $script:WinBinDir"
} else {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [System.IO.Compression.ZipFile]::OpenRead($zip)
    try {
        foreach ($entry in $archive.Entries) {
            if ($entry.Name -eq '') { continue }
            $dest = Join-Path $script:WinBinDir $entry.Name
            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $dest, $true)
        }
    } finally { $archive.Dispose() }
    Write-Host "Extracted to $script:WinBinDir"
}

if (-not (Test-Path -LiteralPath $consoleExe)) { Write-Error "Console exe missing after extract: $consoleExe"; exit 1 }
Write-Host "Console exe: $consoleExe"
& $consoleExe --version
