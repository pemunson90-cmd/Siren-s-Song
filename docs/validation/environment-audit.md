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

Run `39201435045`, job `117895044593`, source `f19bbcd9cc6519e58cdadbacc1991aaaa92f1fdf`, includes the canonical endpoint fix and passes 88 core/176 runtime checks and APK export/install. It stops on the first mission tap because Android's [actual first-use immersive introduction](android-39201435045/system-immersive-intro.png) covers the operations screen. The final log confirms the secure preconfirmation setting was written at 04:53:22.495, but this boot still displays `Viewing full screen / Got it`. There is no native audio-fix verdict: active gameplay was never reached. Public [certificate](android-39201435045/apk-signature.txt) remains unchanged; [APK SHA256](android-39201435045/sirens-song-debug.apk.sha256) is `e1d6e552898df6741cc1a95ea65c75f8320e49f33e8906a27f3214f595af18d4`.

The next fixture inspects Android's UIAutomator hierarchy immediately before the first game tap. It acknowledges only a `Viewing full screen` introduction with one clickable `Got it` node belonging to Android/SystemUI, using its actual accessibility bounds, then requires the introduction to disappear. It does not click unrelated dialogs or retry gameplay taps. Raw before/after XML and window/dump diagnostics are uploaded. Local focused checks accept the known system introduction, reject a game-package lookalike and unrelated dialog, and pass shell/YAML checks. A fresh hosted run must establish this fixture correction and the unchanged corrected game.

### Corrected sustained audio and ordinary native mission completion

[Run 39202066103](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/39202066103), job `117896952083`, exact source `93b86310d91054feaef437ce659135aaab970b88` (audio/game fix `cb8c6f9`, Foundry content `322d23c`), passes 88 core/176 runtime checks and the expanded native smoke with its strict error gate. Downloaded final log independently scans with zero fatal/Godot/script/parse matches. Both viewport/order/lifecycle/archive profiles pass; the landscape lock holds. UIAutomator inspection ran, but this boot had no intro to acknowledge, so conditional dismissal remains locally tested only.

Ordinary native Drone A travel resumes at 05:03:28.521; actual camera readiness is 05:03:58.834, over 30 seconds later without the former PCM boundary crash. Camera capture then secures the record and extraction wins. The archive saves `completed=[0] unlocked=1` and a new process restores it at 05:04:29.894. Original [camera exposure, successful debrief and restored campaign images plus raw event/progress/certificate/hash evidence](android-39202066103/README.md) were downloaded, inspected and retained. All three frames are actual 2184×1968 Android PNGs; the optical feed, successful 100%-hull debrief, and recovered/unlocked archive states are visible without obvious clipping.

Both exact caches restored again. Certificate remains `32bcb2287acd01c1f58c26997c7639f3072c74c6b03ab2a24656dc7cd1c7dc3c`; APK SHA256 is `4be4f056a65def993dca34170c2b02fb8e4342a1adac3baa01abcdecc42dcb4e`. The [current APK artifact](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/39202066103/artifacts/12164418637) replaces the earlier exploratory build. Native evidence is 2,000,857 bytes; inner screenshots 8,767,729 bytes, both within the transfer limit. This is a safe development checkpoint for the next touch/zoom cycle, not a claim about physical Fold7 performance, subjective audio quality, all campaign missions on Android, every saved field or release readiness.

### Prepared native navigation challenger gate

Tooling now exercises ordinary +/−/FIT controls and a real single-pointer OS touchscreen swipe on each cover/inner profile. Numeric `SS_VIEW` parsing verifies 1.4×, overview and 1.96× zoom, a left swipe increasing world center.x at unchanged zoom, and FIT returning to world center `(800,480)`. The swipe starts at the dynamically reported `chart_center`; displacement is 12% of the current PNG's shorter dimension, rather than fixed device pixels. The whole navigation sequence must produce zero `SS_ORDER` and zero `SS_PAUSE` events. Zoomed/panned frames and view-check summaries are uploaded; ordinary world-target completion and lifecycle/audio/fatal gates remain intact after FIT.

Eight focused CLI guards pass. They reject a stale view from a prior screen, incorrect numeric zoom, an unchanged pan center, shifted FIT center and target coordinates reported before the latest view transform, while accepting current zoom/pan/targets. The stale-target guard first reproduced RED (old mapper returned success after `SS_VIEW` without fresh coordinates), then passed after the mapper waited for post-transform targets. Shell syntax, workflow YAML and diff checks pass. No native touch-challenger run has yet occurred; verified baseline remains `93b8631`/run `39202066103`. OS multi-touch pinch remains unverified; synthetic production gesture tests are separate evidence.

Run `39204224960` at `92625ac` now establishes actual native +/−/swipe/FIT on both screen profiles, with numerical world-center changes and zero accidental orders/pause changes. Both normal lifecycle/archive profiles and ordinary camera/record/extraction/save pass. Actual cover/unfolded pan, optical exposure and debrief pixels were inspected. The final completed-campaign restart fails when adb closes and Android's window service disappears; fresh Zygote startup follows. The [full limited-scope report and raw evidence](android-39204224960/README.md) distinguish these concrete successes from the unpassed final restoration/error gate. No promotion or initiating app/system/memory/graphics cause is claimed.

The controlled retry adds bounded precritical log/boot/service/memory diagnostics and failure app-exit/system_server crash/watchdog capture. Runtime source and all required native gates remain unchanged. The first failed run's overwritten post-restart log cannot resolve the initiating cause retrospectively. Hosted checks are eight parser guards/88 core/225 runtime; certificate unchanged, APK SHA256 `2b6baf12f29f3e2d062e6da03c2b848c061ec1a521fa3ebc505138c94eae6b88`. Baseline remains `93b8631` pending full validation.

### Bounded desktop audio-exit diagnosis

Godot 4.6.3 with Dummy audio leaks AudioStreamWAV/AudioStreamPlaybackWAV references on rapid exit both with and without Movie Maker. An external temporary SceneTree probe instantiating only the production Soundscape, then freeing it after six frames, reproduces two leaked looping playback/stream pairs. Waiting 0.5 seconds **before** freeing still leaks; waiting 0.5 seconds **after** freeing produces zero ObjectDB/leaked-instance warnings. This supports pending audio-thread cleanup at rapid shutdown, rather than proving a persistent native gameplay leak. Logs and probes are outside git under `/workspace/.sirens-song-toolchain/artifacts/audio-exit-*.log` and `/tmp/sirens-audio-exit-*.gd`. The production lead received the reproduction; no audio behavior was changed by tooling. Normal Android audio and sustained memory behavior remain unmeasured.

### Promoted native touch baseline and controlled retry

[Run 39205478335](android-39205478335/README.md), job 117907255561, source `f1ea536636293ca8b9a2744eea865b6bdfe88e2d`, runtime unchanged from `92625ac`, passes eight parser guards, 88 core/225 runtime checks, both actual native +/−/swipe/FIT profiles and unchanged mission/order/lifecycle/audio/completion/error gates. Pan center.x is 875.1025 cover / 899.4498 inner at 1.96×, y480; FIT returns 1× / (800,480). Zero accidental order/pause events. Shelf Signal wins through ordinary Drone A camera commands; a new process restores `completed=[0] unlocked=1`. Raw events, five inspected Android frames, view checks, public certificate/hash and precritical runtime/memory snapshots are retained in the linked evidence directory.

Boot ID and system_server PID 654 stay unchanged through final restart, with window/activity services available. Guest MemAvailable snapshots are 1,160,512 / 1,010,524 / 973,204 KiB; pre-restart app PSS 167812 KiB. These samples do not establish a leak trend or physical-device performance. The prior interruption did not recur, but its initiating cause remains unknown. The strict final gate and independent downloaded-log scan both pass. Both exact caches restored; certificate remains `32bcb2287acd01c1f58c26997c7639f3072c74c6b03ab2a24656dc7cd1c7dc3c`. APK SHA256 is `e3c8fa1b838a1fb561cb118b5e6470c680d344a75c979b9dc6ed456f62c396d6`; the evidence artifact is 4,896,511 bytes. Physical Fold7, OS pinch, whole-native-campaign and subjective/performance limits remain open. Requested Sol6.1 routing remains explicit; backend usage/cost telemetry is unavailable.

### Native A-role numerical gate; artifact delivery pending

Exact source `638811368f697795b4f92a2f97d0598b29b1a5fa`, [run 39216492480](android-39216492480/README.md), job 117941450308 passes 234 core/230 runtime and the complete native smoke plus one fixture-assisted Well noise/search/physical-return encounter and byte-verified genuine Shelf archive restoration. Exact official-template and development-key cache hits are logged, with unchanged public certificate. Direct APK-byte checksum recomputation and pixel inspection remain pending: the artifact connector supplies only File Service metadata, whose `sdmntpreastus2.oaiusercontent.com` host is absent from the current restricted/enforced allowlist. CONNECT 403 is observed; no bypass/configuration change was attempted. The linked record preserves permanent artifact IDs, API ZIP digests and CI-logged APK hash separately. No native finale/full-campaign, density, Samsung physical or phone-performance acceptance follows.
