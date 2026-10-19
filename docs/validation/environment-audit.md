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

### First hosted run and SDK setup correction

Run `39193374951`, job `117870779465`, at source `5cdcc6e` failed before build/test/emulator execution: the official Godot editor/template checksum verification and installation succeeded, then the shell returned `sdkmanager: command not found` (exit127). The first workflow incorrectly assumed the hosted Ubuntu image exposed SDK tools on PATH. Added explicit `android-actions/setup-android` setup pinned at `9fc6c4e9069bf8d3d10b2204b1fb8f6ef7065407`, installing platform-tools and build-tools36.0.0; removed the implicit bare `sdkmanager` call. Also moved setup-java from the runner-reported deprecated v4 to SHA-pinned v5 `b6effb05e454b25005698d916606bdc6ffcbf961`. The corrected workflow requires a new hosted run; the failed first run provides no Android runtime evidence.

Run `39193493284`, job `117871136234`, at `f872d69` passed explicit SDK setup, official Godot setup, headless tests, APK build, KVM access, and API36 emulator boot (about52 seconds). The smoke script then stopped at `rg: command not found` before installing the APK. Replaced its nonstandard ripgrep dependency with stock `grep -E`, also updating the test/capture wrappers for portability. APK/build/test logs were uploaded as artifact `12160594353`; no APK installation or gameplay evidence follows from this second failed smoke. The next hosted execution is required to validate the corrected runtime path.

### First installed Android runtime evidence

Run `39194450149`, job `117874057812`, source `acb1b1d1fb182726651b7e7b44f498bea1f7f6de`, passes50 simulation and137 headless UI checks, builds/signs the native APK, boots the API36 x86_64 Google APIs emulator, installs the APK, resolves its exported launcher alias, and starts the actual app. Native logcat records `SS_SCREEN operations window=(2520,1080) viewport=(1680,720)` and visible-target markers. The actual2520×1080 screenshot is preserved at [cover-system-overlay.png](android-39194450149/cover-system-overlay.png); it shows Android's first-use immersive-mode confirmation over a black game surface. The original Godot log lines are preserved without rewriting in [godot-logcat-excerpt.txt](android-39194450149/godot-logcat-excerpt.txt). The full downloaded runtime evidence is retained outside git at `/workspace/.sirens-song-toolchain/artifacts/github-run-39194450149/`.

Two distinct defects were observed. The test issued `am kill` before the asynchronous background/onStop transition completed, so it correctly refused to claim process death. Separately, the emulator's legacy `swiftshader_indirect` GLES3.0 driver reports `Fragment shader active uniforms exceed GL_MAX_FRAGMENT_UNIFORM_VECTORS (261)` in Godot's built-in Canvas and Scene shaders. App launch is verified; successful native rendering is **not**. A2520×1080 PNG and live app process alone do not pass that rendering gate.

The next fixture revision suppresses the standard first-use immersive confirmation with `settings put secure immersive_mode_confirmations confirmed`, polls background-process termination for up to30 seconds, and fails on engine shader errors as well as script errors. It also changes the emulator software backend to `swangle_indirect` (ANGLE over modern SwiftShader). Evidence that this mode is supported for API36 x86_64 comes from Chromium's maintained [pinned emulator configuration](https://github.com/chromium/chromium/blob/b3a354c9112d4a95d6c431b2b2bdb727cd1466aa/tools/android/avd/proto/android_36_google_apis_x64.textpb), which uses it with emulator36.4.9; the observed hosted emulator is37.2.12. This is a compatibility fix to test, not proof that the shader problem is confined to the fixture. No game-rendering settings were changed to hide the failure.

The runtime artifact is now separate from the APK, permitting bounded transfer and inspection. Runtime artifact `12161641389` is4,643,888 bytes; APK artifact `12161800743` is60,555,276 bytes. Both belong to the same source/run. The APK is installable but has the unresolved rendering issue above; it is not a validated hands-on release.

The expanded next smoke maps production `SS_TARGET` logical coordinates to actual screenshot pixels with Python stdlib, rejects targets from a previous screen, and sends native `adb input tap` events for mission entry, drone/sub selection, map orders, pause/resume, and restored-mission entry. It requires increasing action/restore marker counts, rather than matching stale log lines. The mapper's2520×1080 coordinate calculation and stale-target rejection were checked locally. Actual native touch and restored-mission screenshots require the next hosted run with the lead's matching target-emission fixes.

Run `39195232273`, job `117876471563`, at source `4463446` passes tests and APK export but stops at the immediate KVM permission assertion after `udevadm trigger`. No emulator/native test ran in this attempt. The log does not distinguish absent device from asynchronous permission application. The fixture now waits for udev events to settle, prints the device permissions, requires a real character device, explicitly applies the same0666 permissions specified by the existing rule, and then asserts read/write access. This preserves KVM as a required gate and will expose a missing device rather than silently using software CPU emulation.
