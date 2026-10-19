# Environment audit — 2026-10-19 UTC

Requested delegate model: **gpt-6.1-sol**, explicitly routed with `fork_turns=none`. Actual backend model attestation, token usage, and cost telemetry are unavailable in the exposed spawn/tool results. No nested agents were spawned. This document reports observations, not a verified backend-model identity.

Read `AGENTS.md`, `docs/START_HERE.md`, and `docs/SOURCE_AUTHORITY.md`; read the production worktree's updated model policy. Used the cloud-environment runtime guidance to check the existing environment. Environment status reported running, current observations, enforced restricted package-manager HTTP policy, ready configured Android/JDK runtime variables, no secrets, and no VPN. No replacement environment was created or published.

## Exact command evidence

```sh
godot --version
# 4.6.3.stable.official.7d41c59c4
godot --headless --editor --path /tmp --quit
# Godot initializes successfully with dummy/headless renderer.
"$JAVA_HOME/bin/java" -version
# Temurin 17.0.16+8
"$JAVA_HOME/bin/javac" -version
# javac 17.0.16
/workspace/.command-library-env/android-sdk/platform-tools/adb version
# Android Debug Bridge 1.0.41; Version 37.0.1-15733141
/workspace/.command-library-env/gradle/wrapper/dists/gradle-9.6.0-bin/42k10rwplmzkhuboz9kdazi7s/gradle-9.6.0/bin/gradle --version
# Gradle9.6.0, launcher JVM17.0.16
Xorg :99 -config /etc/X11/xorg.conf -noreset -nolisten tcp -logfile /tmp/sirens-song-xorg-audit.log
DISPLAY=:99 LIBGL_ALWAYS_SOFTWARE=1 godot --editor --path /tmp --rendering-method gl_compatibility --rendering-driver opengl3 --audio-driver Dummy --quit-after 3
# OpenGL4.5; Mesa25.0.7; llvmpipe LLVM19.1.7; Compatibility renderer.
DISPLAY=:99 import -window root /tmp/sirens-song-display-audit.png
# Captured1364x1024 PNG after editor exit (blank display, plumbing evidence only).
```

Read package `source.properties` files rather than assuming installed SDK versions from runtime variables. `command -v adb` initially found nothing because SDK tools were absent from PATH; the SDK tools existed at the configured absolute paths. The toolchain scripts now set PATH explicitly for their own processes.

`ls /dev/kvm /dev/dri /dev/bus/usb` found none. No emulator executable or AVD was found under the configured SDK/user paths. A bounded localhost socket probe to port5037 returned connection refused. No claim of a connected device, emulator boot, APK installation, or runtime Android validation follows from these checks.

Xorg logs show missing system DBus and physical input modules; the dummy display and software OpenGL initialize despite those messages. VSync cannot be changed on the software driver. These limits do not prevent deterministic offscreen-window capture, but software rendering timings do not represent Android performance.

## Download provenance

Official archive:

`https://github.com/godotengine/godot/releases/download/4.6.3-stable/Godot_v4.6.3-stable_export_templates.tpz`

Official checksum manifest:

`https://github.com/godotengine/godot/releases/download/4.6.3-stable/SHA512-SUMS.txt`

The archive contains **1,255,918,323 bytes**. Downloaded with `curl --fail --location --retry 2`; HTTPS proxy and CA trust were preserved. Verified the whole archive against its official SHA512 entry before extracting:

```text
da606b61c10157844f8300172df374472665f95015495cb1a7cd132c40ede404faa96cc1016a4b9662db9909ddea69632c4948b2cd11163438dad4808881fb68
```

Downloaded archive and manifest are retained in `/workspace/.sirens-song-toolchain/downloads`. Extracted only `android_debug.apk` (124,546,428 bytes), `android_release.apk` (102,855,501), `android_source.zip` (210,059,811), `linux_debug.x86_64` (72,189,976), `linux_release.x86_64` (71,075,864), and `version.txt` into `/home/agent/.local/share/godot/export_templates/4.6.3.stable`. Linux templates are executable. No SDK, emulator, NDK, or Gradle package was downloaded during this setup.

Pinned source requirements were read directly from:

- `https://raw.githubusercontent.com/godotengine/godot/4.6.3-stable/platform/android/java/app/config.gradle`
- `https://raw.githubusercontent.com/godotengine/godot/4.6.3-stable/platform/android/java/gradle/wrapper/gradle-wrapper.properties`

These establish the custom-build versions recorded in `docs/CODEX_ENVIRONMENT.md`; cached Gradle9.6 is not evidence that a Godot custom Gradle build will work.

## Verification status

Native editor startup, headless startup, software renderer initialization, display screenshot plumbing, archive checksum, and shell syntax were checked. Production APK export, desktop binary export, game frame capture, and gameplay checks are recorded below as they become available; an environment capability alone is not a gameplay result.

### Independent temporary toolchain probe

Created a minimal Godot project outside the repository at `/tmp/sirens-song-toolchain-probe` to verify packaging and native capture before production files existed. Using the repository's export preset and scripts:

```sh
GAME_DIR=/tmp/sirens-song-toolchain-probe ARTIFACT_DIR=/workspace/.sirens-song-toolchain/artifacts/toolchain-probe scripts/toolchain/build.sh android
GAME_DIR=/tmp/sirens-song-toolchain-probe ARTIFACT_DIR=/workspace/.sirens-song-toolchain/artifacts/toolchain-probe scripts/toolchain/build.sh linux
GAME_DIR=/tmp/sirens-song-toolchain-probe CAPTURE_DIR=/workspace/.sirens-song-toolchain/artifacts/toolchain-probe/capture CAPTURE_FRAMES=3 scripts/toolchain/capture.sh
```

All three commands succeeded. APK signature schemes v2 and v3 verify; manifest inspection shows `org.sirenssong.game`, minSDK24, targetSDK36, native `arm64-v8a` and `x86_64` libraries. APK SHA256: `638a4240e01088f8ea30d5b36667f6d149d2a3940bbf9992d4bc35f3117e3386`. Linux binary SHA256: `b7982421b419479fa26f15ea7285035e601262145b143470fa0305301639c14c`. Movie Maker produced three1280×720 rendered PNGs including the probe label. These are toolchain probes, not production game screenshots or device runtime results.

The first APK probe exposed Godot's silent configuration rejection when `rendering/textures/vram_compression/import_etc2_astc` is false. Official `has_valid_project_configuration()` source confirms the check. Enabling that project setting resolved it; production project ownership was notified. Installed build-tools36.0.0 are sufficient for this prebuilt-template export, despite custom-source build-tools pin36.1.0. No new SDK/NDK/Gradle dependency was needed.

### GitHub validation preparation

Prepared a portable hosted-runner workflow and connected-device smoke script. API36 x86_64 emulator tests and Fold7-sized landscape viewport checks have not yet run at this checkpoint. Local KVM absence does not prevent GitHub-hosted KVM. Generic GitHub connector fetch of `/repos/pemunson90-cmd/Siren-s-Song/actions/runs?per_page=3` succeeded with `total_count:0` before the workflow push; local `gh` requests returned Forbidden. No API-token or credential value was inspected or printed.

Pinned action revisions were resolved with `git ls-remote https://github.com/OWNER/REPO.git refs/tags/v4` (or v2 for emulator runner): checkout `11d5960a326750d5838078e36cf38b85af677262`, setup-java `cf277c60eb25467037889841efdb72551f06f6c3`, cache `0057852bfaa89a56745cba8c7296529d2fc39830`, upload-artifact `ea165f8d65b6e75b540449e92b4886f43607fa02`, emulator runner `4c44018e59b437e86cdfc41da381398f93ed8808`. Workflow YAML parses and all shell scripts pass `bash -n`; emulator behavior requires the first hosted execution.

### Production shell verification

At source commit `5cdcc6e732c01597a296ff8596eb30f48eb7f488`, executed:

```sh
scripts/toolchain/build.sh android
CAPTURE_FRAMES=3 CAPTURE_DIR=/workspace/.sirens-song-toolchain/artifacts/production-planning scripts/toolchain/capture.sh -- --scenario=planning
```

The production APK exported successfully to `/workspace/.sirens-song-toolchain/artifacts/sirens-song-debug.apk` (approximately54MiB). SHA256: `70bca991f4c753c5e1bcaf1c57e565a85976930916bf8f81786203c64868a69f`. `apksigner verify --verbose` confirms v2 and v3 signatures; `aapt2 dump badging` confirms package `org.sirenssong.game`, minSDK24, targetSDK36, and both `arm64-v8a` and `x86_64` native libraries. The metadata reader emits a themed-icon resource warning from the official template; APK signatures pass. An Android runtime check is still required to determine whether any resource issue affects installation or launch.

Movie Maker produced three1280×720 PNG frames without GDScript/runtime errors. Inspected `production-planning/frame00000002.png`: the production tactical map, queued routes, drone/Quietus indicators, status header, and command controls are visible. This is actual production game rendering, separate from the earlier temporary probe. It does not establish Android performance, touch behavior, or physical fold handling. No local APK installation was attempted because no Android runtime is available.
