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

### ANGLE run: precise passing subset and capture stall

Run `39195458084`, job `117877147986`, source `5f471b4414ad8e5f079e5e36ae22e921616b960a`, used `swangle_indirect`. The actual emulator reports ANGLE OpenGL ES3.1 (`ANGLE2.1.17841`, hash `5fa2e61da947`) and booted at03:38:21 UTC. Native touches passed cover mission entry, drone/sub selection, route placement, and pause/unpause, followed by cover background/resume and explicit process death/restart/archive restoration. The same live process resized to2184×1968, and inner mission entry, selections, route and pause taps passed. Inner HOT resume completed at03:40:08.516 UTC. No further output appeared before cancellation at03:51:35.892 UTC; the following code performs the inner-resume screenshot/activity capture, then another background/kill sequence. Thus the stalled region is a capture or subsequent lifecycle adb call; this was not an emulator boot timeout. The exact blocked command was not logged by that revision.

This passing interaction subset is supported by timestamped command/action logs, not a full-run success. Actual rendered pixels remain uninspected: the runtime artifact grew to57,624,492 bytes (`12161752847`), exceeding the executor transfer limit. No network-policy bypass was attempted. Full inner lifecycle completion and shader-error-free rendering remain open. The APK artifact from this run (`12161727935`) predates persistent signing-cache support and is not advertised as a ready hands-on update.

The next diagnostic revision keeps the same GPU backend, bounds each adb call to30 seconds (APK installation120 seconds), reports command/status failures, and timestamps screenshot begin/completion and activity-dump begin/completion. It splits cover/inner screenshots into separate artifacts and omits redundant successful targeting PNGs from uploads, retaining the failed-target screenshot when an interaction fails. Emulator version/GPU help/acceleration probes and a300-second boot/12-minute composite bound distinguish capability, boot, capture and lifecycle failures. None of these changes silently relaxes native rendering or restoration assertions.

Run `39196658594`, job `117880831755`, at `cf07590` stopped in the new version diagnostic before native validation. Bare `emulator -version` chose the windowed `qemu-system-x86_64` executable, which lacked `libpulse.so.0`; prior actual runs used `qemu-system-x86_64-headless`. Diagnostic probes now use the same `-no-window -noaudio` flags, additionally record installed `source.properties` and headless executable dependencies, have30-second command limits, and record exit status without blocking the native smoke. KVM character-device/read-write assertions remain required. No desktop audio package was installed to satisfy an unnecessary GUI probe, and no new Android rendering claim follows from this failed diagnostic attempt.

That run also exposed early-cache save warnings: the cache action rejects paths containing literal `..`, even when they resolve outside the checkout. Both download/key saves failed on that pattern, so no persistent signing identity was established by this attempt. The workflow now canonicalizes the external cache path with `realpath -m` into `GITHUB_ENV` before restore/save actions. Key/path pairs remain exact and outside the repository; cache persistence must be confirmed from the next actual save/restore logs before promising APK update compatibility.

### Inspected Android pixels and first saved development identity

Run `39197089036`, job `117882079212`, source `c96c3bf6674912d658bc2c67a579aa25dc31eed3`, successfully saved the verified-download cache at 03:57:50 UTC and development-key cache at 03:57:54 UTC. These are confirmed saves, **not yet confirmed reuse**. The actual capability artifact (`12161419498`) records emulator 37.2.12/build 16428233, successful headless version/GPU-help probes, and KVM version 12 installed/usable. Its help lists `swangle` as ANGLE with SwiftShader; the running `_indirect` alias had already produced ANGLE GLES 3.1 in the prior native run.

Downloaded and visually inspected actual 2520×1080 Android [operations](android-39197089036/cover-operations.png) and [briefing](android-39197089036/cover-briefing.png) PNGs. The map, terrain, craft, text and controls render. The first-use system overlay is absent. The earlier legacy shader-link error does not occur in the captured log. This establishes native cover rendering for these states; it does not establish every mission/camera state, unfolded rendering, or full lifecycle success.

The native first mission tap succeeded (`SS_MISSION_SELECT 0`) but produced a genuine Godot error: `Condition "!is_inside_tree()" is true. Returning: false`, at `can_process (scene/main/node.cpp:902)`, immediately after menu selection. The production lead received the exact reproduction and [unaltered Godot log excerpt](android-39197089036/godot-logcat-excerpt.txt). Independently, the next read-only `adb logcat -d` returned 255; a subsequent cleanup read succeeded and exposed the UI error. The smoke therefore did not finish. The next log-reader retries only this observed 255 read failure, at most three times with each adb call bounded, retains every partial stdout/stderr attempt, and rejects genuine runtime errors found in any retained log. It does not retry taps or hide the menu error.

The [public signing evidence](android-39197089036/apk-signature.txt) reports certificate SHA256 `32bcb2287acd01c1f58c26997c7639f3072c74c6b03ab2a24656dc7cd1c7dc3c`. APK SHA256 is [recorded alongside it](android-39197089036/sirens-song-debug.apk.sha256): `b81013eeaa93660cf1ad80b3309d70ae0c153cac3c0882be50f4e88053991a3b`. The [early hands-on APK artifact](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/39197089036/artifacts/12162671131) is shared with the mission-entry error/incomplete-lifecycle caveat, not as a passed build. Check the same certificate on subsequent updates and separately verify cache reuse. The private key remains outside the repository and artifacts.

### First complete native smoke and inspected unfolded restoration

[Run 39197795717](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/39197795717), job 117884208822, source `539f58b7b3cb37920df8e545f5dc156b63d5665d`, passed 70 core and 173 headless runtime checks, signed APK export, and the full native smoke. The production fix defers menu actions until native button signal dispatch completes. The installed build now passes mission selection/entry without the prior `can_process` error. The strict gate scans all retained intermediate/partial logcat reads for script, parse, engine and fatal errors; it passed.

The [unaltered selected workflow lines](android-39197795717/workflow-evidence-excerpt.txt) retain timestamps for actual cache hits/restoration, test counts, public certificate/hash, native touches, exact viewport assertions and lifecycle stages. Emulator boot completed before the smoke entered at 04:09:11 UTC. The native test finished at 04:12:00 UTC; this run did not encounter the previous unexplained capture stall. Both 2520×1080 cover and 2184×1968 inner profiles passed fresh native touches for mission entry, drone/sub selection, route and pause/unpause, Home/resume, confirmed process death with `am kill`, cold restart and mission archive restoration/entry. The inner profile follows a live resize of the prior mission.

Visually inspected the original [cover gameplay PNG](android-39197795717/cover-gameplay.png) and [inner restored gameplay PNG](android-39197795717/inner-restored-gameplay.png). Map, terrain, craft, status and controls render in both; controls reflow below the map on the inner display, and the restored screen states that the mission is paused for review. No system overlay or obvious bounds clipping is visible in these two inspected states. This is actual Android output, not desktop Movie Maker imagery. It does not validate all camera/mission states or every saved field.

The two caches actually restored from exact keys `godot-4.6.3-official-sha512-v1` and `sirens-song-development-signing-v1`; installer time was four seconds without a fresh 1.17 GiB templates download. Certificate SHA256 remains `32bcb2287acd01c1f58c26997c7639f3072c74c6b03ab2a24656dc7cd1c7dc3c`. The [installable APK artifact](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/39197795717/artifacts/12162622874) has APK SHA256 `513ec0b57b5b09b176fa4ae9a10b05dd407052b349508cc9a54f68383a62e836`. This verifies update-signing continuity with c96c3bf; cache eviction remains a future risk, and the key itself is never uploaded as an artifact.

Repeated successful logcat snapshots inflated the native-evidence artifact to 96,657,757 bytes, beyond the executor's 32 MiB transfer limit. The separately uploaded cover/inner artifacts were 3,064,069 and 4,943,676 bytes and were downloaded/inspected successfully. The next workflow upload retains one final full log, deduplicated raw engine events, failed-read stderr, command/progress/certificate/error evidence and selected screenshots. Every intermediate/partial log still remains on the runner and participates in the same strict error gate; only duplicate upload scope changes. Shell syntax and workflow YAML were checked locally; reduced hosted artifact size requires a subsequent run.

Physical Fold7 hinge/cutout/firmware behavior, device audio/heat/performance, touch ergonomics, complete campaign play and user acceptance remain separate gates. No native performance claim follows from software-emulated rendering. Model requested for this audit/development: explicit `gpt-6.1-sol`; actual backend routing and cost telemetry are unavailable. No nested agents were spawned.

The next bounded native expansion completes Shelf Signal with ordinary input rather than a debug scenario: select Drone A, route to the clear `(1300,510)` camera approach through the actual map, resume until canonical camera readiness, pause/start CAMERA, resume until the objective is recorded and outcome is `won`, then cold restart and require `completed=[0] unlocked=1` archive restoration. New markers only observe real range/line-of-sight/alive/exposure, objective and campaign state. The native fixture bounds its waits and captures camera/exposure, debrief and restored-campaign PNGs. This is implemented but not yet verified by a hosted execution; the preceding successful run covered mission entry/orders/lifecycle, not completion.

Run `39199537776`, job `117889450455`, source `322d23c2201300eee80f80ef4d719cb516781c41`, passes 86 core/176 runtime checks, APK export/install and cover mission/order/pause/background/kill/archive restoration. It stops before inner taps or the new completion sequence. The inner screenshot initially asserts 2184×1968, but WindowManager then reports `rotation changed to 0 from 1 ... userRotationMode=1 userRotation=0`; the [failed screenshot](android-39199537776/inner-unexpected-portrait.png) is 1968×2184 and shows the app letterboxed at logical 1280×960. The [original selected log lines](android-39199537776/rotation-logcat-excerpt.txt) preserve this transition. The mapper correctly refuses mismatched screenshot/layout coordinates. The final native log independently scans with zero matches for the strict script/parse/Godot/fatal pattern, but the script never reaches its final gate, so this run is not reported as passing native validation. The unrelated nonfatal export message `No project icon specified` remains a production polish issue.

The corrected landscape fixture uses `wm user-rotation lock 1` for each launch after display overrides, records WindowManager's rotation mode, and reacquires the target screenshot on every readiness attempt. It retains the same exact viewport and aspect assertions. Local shell/Python/YAML checks pass, and the actual failed portrait PNG still rejects with both mismatched dimensions reported. A fresh hosted run must establish the correction. This explicit landscape test does not validate automatic physical fold/rotation adaptation.

The reduced native evidence archive is now 2,747,546 bytes, downloaded and inspected successfully, versus 96,657,757 bytes in the preceding successful run. Both caches again hit. The [public certificate](android-39199537776/apk-signature.txt) remains SHA256 `32bcb2287acd01c1f58c26997c7639f3072c74c6b03ab2a24656dc7cd1c7dc3c`; the APK [SHA256](android-39199537776/sirens-song-debug.apk.sha256) is `e4f38c1ee05f19dbf78bea83c2aa283cd09796528d7d44f0d6716a43cdd08080`. Retain 539f58b as the fully passed native playtest baseline while investigating this newer run.

### Sustained active audio exposes an actual native crash

Run `39200256192`, job `117891560814`, source `3caa274d83d0c0a757965246412c61dedf459deb`, passes 86 core/176 runtime checks and both cover/inner touch/order/pause/lifecycle/archive profiles. WindowManager records `lock 1`, so the prior fixture rotation race is corrected. The ordinary-command completion attempt then crashes in AudioTrack about 7.84 seconds after resume, before camera readiness. This is a genuine SIGSEGV in the matching official Godot native library, not a timeout-only or renderer finding. The [complete relevant crash interval, last valid screenshot, progress, fingerprint, certificate/hash, disassembly and source analysis](android-39200256192/README.md) are retained together.

The fault instruction reads PCM16 at ambience frame 176400, exactly one past its 176400 valid frames. Godot's official mixer uses an inclusive loop endpoint, while the generated WAV specified `loop_end=frame_count`; importer/source evidence and register arithmetic agree. The lead owns the focused regression and `frame_count-1` correction. The native fixture now fails immediately on a fatal log or dead process while waiting for gameplay markers; a focused helper probe rejects both and still accepts a fresh healthy marker. No global mute/backend swap or weakened native gate is introduced.

The runtime evidence archive is 3,802,004 bytes and was downloaded/inspected. Certificate SHA256 is unchanged; APK SHA256 is `8d67bb5d8699a306859e687e40efd7192fe09441dc66fa8fc1eeaf6d23799672`. No objective capture, mission win or completed-campaign restore is claimed for this run. Earlier 539f58b evidence remains valid for its brief tested scope, but the same loop construction existed there: it does **not** establish sustained native gameplay/audio stability. Playtest guidance now states the known crash and pending corrected validation.

### Bounded desktop audio-exit diagnosis

Godot 4.6.3 with Dummy audio leaks AudioStreamWAV/AudioStreamPlaybackWAV references on rapid exit both with and without Movie Maker. An external temporary SceneTree probe instantiating only the production Soundscape, then freeing it after six frames, reproduces two leaked looping playback/stream pairs. Waiting 0.5 seconds **before** freeing still leaks; waiting 0.5 seconds **after** freeing produces zero ObjectDB/leaked-instance warnings. This supports pending audio-thread cleanup at rapid shutdown, rather than proving a persistent native gameplay leak. Logs and probes are outside git under `/workspace/.sirens-song-toolchain/artifacts/audio-exit-*.log` and `/tmp/sirens-audio-exit-*.gd`. The production lead received the reproduction; no audio behavior was changed by tooling. Normal Android audio and sustained memory behavior remain unmeasured.
