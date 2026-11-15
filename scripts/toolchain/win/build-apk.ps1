# Build the debug Android APK on Windows, no GitHub Actions. Mirrors build.sh / configure.sh.
# Idempotent: downloads and extracts only what is missing (zips only, no installers, no PATH or
# system changes), checks every download against its publisher checksum, then exports the
# game in -Repo with the tracked development keystore and verifies the signing certificate.
# Nothing is deleted. Godot's editor settings for this build live in a private APPDATA under
# the cache, so your real Godot settings and templates folder are not touched.
[CmdletBinding()]
param(
    [string]$Repo = '',                 # repository folder (default: the repo this script is in)
    [string]$OutDir = '',               # default: <cache>\apk-local
    [switch]$InstallOnly
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'common.ps1')
if ($Repo) { $script:ToolchainRoot = [System.IO.Path]::GetFullPath($Repo); $script:GameDir = Join-Path $script:ToolchainRoot 'game' }
Assert-Project
Add-Type -AssemblyName System.IO.Compression.FileSystem

# Pins. Godot templates: SHA512 (same value as install-godot.sh). JDK and cmdline-tools: SHA256 as published
# by Adoptium (api.adoptium.net) and Google (developer.android.com/studio), verified 15 Nov 2026.
$TemplatesName = "Godot_v$($script:GodotVersion)-stable_export_templates.tpz"
$TemplatesUrl = "https://github.com/godotengine/godot/releases/download/$($script:GodotVersion)-stable/$TemplatesName"
$TemplatesSha512 = 'da606b61c10157844f8300172df374472665f95015495cb1a7cd132c40ede404faa96cc1016a4b9662db9909ddea69632c4948b2cd11163438dad4808881fb68'
$JdkName = 'OpenJDK17U-jdk_x64_windows_hotspot_17.0.21_9.zip'
$JdkUrl = 'https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.21%2B9/' + $JdkName
$JdkSha256 = '98518ecf554465057ee5509462631deeee374bc368c12a411d225cd29381f84b'
$CmdName = 'commandlinetools-win-15859902_latest.zip'
$CmdUrl = "https://dl.google.com/android/repository/$CmdName"
$CmdSha256 = '90ae805d20434428bffcb699c290860f19bb5f66a67e6b330067e3de801fb04a'
$BuildTools = '36.0.0'                  # same as .github/workflows/android-validation.yml
$Platform = 'android-36'

$cache = $script:ToolchainCache
$dl = $script:DownloadsDir
$root = Join-Path $cache 'android'
$jdkHome = Join-Path $root 'jdk'
$sdk = Join-Path $root 'sdk'
$godotData = Join-Path $root 'godot-appdata'   # private APPDATA for the Godot process
if (-not $OutDir) { $OutDir = Join-Path $cache 'apk-local' }
New-Item -ItemType Directory -Force -Path $dl, $root, $sdk, $OutDir | Out-Null

function Get-Verified([string]$Name, [string]$Url, [string]$Hash, [string]$Algo) {
    $path = Join-Path $dl $Name
    if (-not (Test-Path -LiteralPath $path) -or (Get-Item -LiteralPath $path).Length -eq 0) {
        Write-Host "Downloading $Url"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $old = $ProgressPreference; $ProgressPreference = 'SilentlyContinue'
        try { Invoke-WebRequest -Uri $Url -OutFile "$path.partial" -UseBasicParsing } finally { $ProgressPreference = $old }
        Move-Item -LiteralPath "$path.partial" -Destination $path -Force
    }
    $actual = (Get-FileHash -LiteralPath $path -Algorithm $Algo).Hash.ToLowerInvariant()
    if ($actual -ne $Hash) { throw "$Algo mismatch for $path`n expected $Hash`n actual   $actual`nRefusing to use it." }
    Write-Host "$Algo verified: $Name"
    return $path
}

function Expand-Entries([string]$Zip, [scriptblock]$Map) {
    # $Map gets the entry full name and returns a destination path, or $null to skip.
    $a = [System.IO.Compression.ZipFile]::OpenRead($Zip)
    try {
        foreach ($e in $a.Entries) {
            if ($e.Name -eq '') { continue }
            $dest = & $Map $e.FullName
            if (-not $dest) { continue }
            New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dest) | Out-Null
            [System.IO.Compression.ZipFileExtensions]::ExtractToFile($e, $dest, $true)
        }
    } finally { $a.Dispose() }
}

# 0. Godot editor (existing script).
if (-not (Test-Path -LiteralPath (Get-GodotConsoleExe))) { & (Join-Path $PSScriptRoot 'install-godot.ps1') }
$godot = Assert-GodotExe

# 1. JDK 17
$javaExe = Join-Path $jdkHome 'bin\java.exe'
if (-not (Test-Path -LiteralPath $javaExe)) {
    $z = Get-Verified $JdkName $JdkUrl $JdkSha256 'SHA256'
    Expand-Entries $z { param($n) $p = $n.Split('/'); if ($p.Count -lt 2) { $null } else { Join-Path $jdkHome ($p[1..($p.Count - 1)] -join '\') } }
}
$env:JAVA_HOME = $jdkHome

# 2. Android command-line tools, then the three named SDK packages
$sdkmanager = Join-Path $sdk 'cmdline-tools\latest\bin\sdkmanager.bat'
if (-not (Test-Path -LiteralPath $sdkmanager)) {
    $z = Get-Verified $CmdName $CmdUrl $CmdSha256 'SHA256'
    Expand-Entries $z { param($n) $p = $n.Split('/'); if ($p.Count -lt 2) { $null } else { Join-Path $sdk ('cmdline-tools\latest\' + ($p[1..($p.Count - 1)] -join '\')) } }
}
$apksigner = Join-Path $sdk "build-tools\$BuildTools\apksigner.bat"
$platformJar = Join-Path $sdk "platforms\$Platform\android.jar"
$adb = Join-Path $sdk 'platform-tools\adb.exe'
if (-not ((Test-Path -LiteralPath $apksigner) -and (Test-Path -LiteralPath $platformJar) -and (Test-Path -LiteralPath $adb))) {
    # Licences are accepted only for these three packages (piped "y" answers), as Pat approved.
    Write-Host "sdkmanager: platform-tools, build-tools;$BuildTools, platforms;$Platform (accepting their licences)"
    $answers = ('y' * 20).ToCharArray() -join "`n"
    $ErrorActionPreference = 'Continue'
    $answers | & cmd.exe /c "`"$sdkmanager`" --sdk_root=`"$sdk`" platform-tools build-tools;$BuildTools platforms;$Platform" | Out-Null
    $code = $LASTEXITCODE
    $ErrorActionPreference = 'Stop'
    if ($code -ne 0 -or -not (Test-Path -LiteralPath $apksigner)) { throw "sdkmanager failed (exit $code)" }
}
$env:ANDROID_HOME = $sdk
$env:ANDROID_SDK_ROOT = $sdk

# 3. Export templates (only the Android ones, like install-godot.sh), into the private Godot data
$tplDir = Join-Path $godotData "Godot\export_templates\$($script:GodotVersion).stable"
if (-not (Test-Path -LiteralPath (Join-Path $tplDir 'android_debug.apk'))) {
    $z = Get-Verified $TemplatesName $TemplatesUrl $TemplatesSha512 'SHA512'
    Expand-Entries $z { param($n) $leaf = $n.Split('/')[-1]; if ($leaf -in 'android_debug.apk', 'android_release.apk', 'version.txt') { Join-Path $tplDir $leaf } else { $null } }
}
Write-Host 'Toolchain ready.'
if ($InstallOnly) { return }

# 4. Signing identity check (same as configure.sh)
$keystore = Join-Path $script:ToolchainRoot 'scripts\toolchain\signing\sirens-song-debug.keystore'
$pinFile = Join-Path $script:ToolchainRoot 'scripts\toolchain\signing\sirens-song-debug.certificate.sha256'
if (-not ((Test-Path -LiteralPath $keystore) -and (Test-Path -LiteralPath $pinFile))) { throw 'Missing tracked debug keystore or certificate pin; restore them. No key is generated.' }
$pinned = (Get-Content -LiteralPath $pinFile -Raw).Trim().ToLowerInvariant()
$ErrorActionPreference = 'Continue'
$der = Join-Path $OutDir 'debug-certificate.der'
& (Join-Path $jdkHome 'bin\keytool.exe') -exportcert -keystore $keystore -storepass android -alias androiddebugkey -file $der | Out-Null
$ErrorActionPreference = 'Stop'
$certSha = (Get-FileHash -LiteralPath $der -Algorithm SHA256).Hash.ToLowerInvariant()
if ($certSha -ne $pinned) { throw "Keystore certificate mismatch: expected $pinned, got $certSha" }
Write-Host "Keystore certificate matches pin: $certSha"

# 5. Godot editor settings, in the private APPDATA (Godot creates the file on first start)
$saveApp = $env:APPDATA
$env:APPDATA = $godotData
New-Item -ItemType Directory -Force -Path $godotData | Out-Null
try {
    $settings = Join-Path $godotData 'Godot\editor_settings-4.6.tres'
    if (-not (Test-Path -LiteralPath $settings)) {
        $ErrorActionPreference = 'Continue'
        & $godot --headless --editor --path $script:GameDir --quit | Out-Null
        $ErrorActionPreference = 'Stop'
    }
    if (-not (Test-Path -LiteralPath $settings)) { throw "Godot did not create editor settings: $settings" }
    # Edit as UTF-8 without a byte-order mark: Godot cannot parse a BOM in this file.
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    $text = [System.IO.File]::ReadAllText($settings)
    $want = [ordered]@{
        'export/android/java_sdk_path' = $jdkHome
        'export/android/android_sdk_path' = $sdk
        'export/android/debug_keystore' = $keystore
        'export/android/debug_keystore_user' = 'androiddebugkey'
        'export/android/debug_keystore_pass' = 'android'
    }
    foreach ($k in $want.Keys) {
        $line = $k + ' = "' + $want[$k].Replace('\', '/') + '"'
        $re = "(?m)^$([regex]::Escape($k)) = .*$"
        if ($text -match $re) { $text = [regex]::Replace($text, $re, { param($m) $line }) }
        else { $text = $text.TrimEnd() + "`n" + $line + "`n" }
    }
    [System.IO.File]::WriteAllText($settings, $text, $utf8)

    # 6. Import and export
    $apk = Join-Path $OutDir 'sirens-song-debug.apk'
    $log = Join-Path $OutDir 'build-apk.log'
    $ErrorActionPreference = 'Continue'
    $lines = @()
    $lines += & $godot --headless --path $script:GameDir --editor --import 2>&1 | ForEach-Object { "$_" }
    $lines += & $godot --headless --path $script:GameDir --export-debug Android $apk 2>&1 | ForEach-Object { "$_" }
    $ErrorActionPreference = 'Stop'
    Set-Content -LiteralPath $log -Value $lines -Encoding UTF8
    $lines | Select-Object -Last 15 | ForEach-Object { Write-Host $_ }
} finally { $env:APPDATA = $saveApp }
if (-not (Test-Path -LiteralPath $apk) -or (Get-Item -LiteralPath $apk).Length -eq 0) { throw "Export produced no APK; see $log" }

# 7. Verify the APK signing certificate against the pin
$ErrorActionPreference = 'Continue'
$sig = & cmd.exe /c "`"$apksigner`" verify --verbose --print-certs `"$apk`"" 2>&1 | ForEach-Object { "$_" }
$ErrorActionPreference = 'Stop'
Set-Content -LiteralPath (Join-Path $OutDir 'apk-signature.txt') -Value $sig -Encoding UTF8
$sig | ForEach-Object { Write-Host $_ }
$signers = @($sig | Where-Object { $_ -match 'certificate SHA-256 digest:' } | ForEach-Object { ($_ -split '\s+')[-1].ToLowerInvariant() })
if ($signers.Count -eq 0) { throw 'APK signer check failed: no certificate SHA-256 line' }
foreach ($s in $signers) { if ($s -ne $pinned) { throw "APK signer check failed: expected $pinned, got $s" } }
Write-Host "APK signer SHA-256 matches pinned development certificate: $pinned"
$h = (Get-FileHash -LiteralPath $apk -Algorithm SHA256).Hash.ToLowerInvariant()
Set-Content -LiteralPath "$apk.sha256" -Value "$h *sirens-song-debug.apk" -Encoding ASCII
Write-Host "APK: $apk ($((Get-Item -LiteralPath $apk).Length) bytes) sha256 $h"
