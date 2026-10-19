# Existing environment and reproducible builds

The production baseline is **Godot 4.6.3 stable, GDScript, Compatibility renderer**, using the existing editor at `/usr/local/bin/godot` (symlink to `/opt/godot/4.6.3/Godot_v4.6.3-stable_linux.x86_64`). Android exports use official prebuilt native engine templates, not a WebView. This choice fits the game's 2D controls, navigation, shaders, audio, and mobile input while supporting desktop inspection from the same project.

No replacement Codex environment was configured. The current shell has Android variables pointing at an existing shared tool cache. Scripts use those paths and permit environment overrides.

## Commands

From the repository root:

```sh
scripts/toolchain/headless.sh                         # import project
scripts/toolchain/headless.sh --script res://tests/run_tests.gd
scripts/toolchain/test.sh                             # require clean logs and successful CHECKS summary
scripts/toolchain/build.sh android                     # signed debug APK
scripts/toolchain/build.sh linux                       # desktop binary
CAPTURE_FRAMES=90 scripts/toolchain/capture.sh          # rendered PNG sequence
scripts/toolchain/android-smoke.sh                    # connected emulator/device only
```

The test runner command requires that the named runner exists. `headless.sh` forwards arbitrary Godot arguments. `capture.sh` also forwards arguments, including game arguments after `--`. Headless execution uses the dummy renderer and cannot validate visual quality. Native captures use Xorg and Mesa software rendering. They validate appearance and deterministic scenarios; they do not establish mobile GPU performance.

On a fresh Linux runner, `scripts/toolchain/install-godot.sh` downloads the pinned editor and official template archive, verifies embedded official SHA512 values, and installs the editor plus Android debug/release templates under user-writable cache/data directories. Java17 and Android SDK platform/build tools must already be supplied by that runner. The local cache paths above are conveniences, not requirements: scripts honor the runner's `JAVA_HOME`, `ANDROID_HOME`/`ANDROID_SDK_ROOT`, and `TOOLCHAIN_CACHE`.

Outputs default to `/workspace/.sirens-song-toolchain/artifacts`; downloads and logs live alongside that directory. Set `ARTIFACT_DIR`, `GAME_DIR`, `GODOT_BIN`, `TOOLCHAIN_CACHE`, `CAPTURE_DIR`, `CAPTURE_RESOLUTION`, `CAPTURE_FPS`, or `CAPTURE_FRAMES` to override individual choices. The Android output is `sirens-song-debug.apk`. `build.sh` verifies its APK signatures and prints its SHA256. Release signing requires a separately managed production key.

`configure.sh` writes workstation Godot Android editor paths and creates an external debug keystore using Android's standard debug identity. It does not download packages or put keys in the repository. The Android preset exports package `org.sirenssong.game`, landscape, with ARM64 and x86_64 native libraries; Gradle custom builds are disabled.

GitHub Actions caches its development debug keystore separately from official downloads so successive playtest APKs can update the same installation and retain saves. The cache is created after a successful job and is scoped by GitHub's cache rules. `build.sh` prints the APK certificate SHA256 as well as the APK SHA256. A deleted/missing cache produces a new debug signing identity; check the certificate before offering an update to an existing playtest installation. This standard debug key is neither confidential production signing material nor suitable for a store release. Local and hosted keys are separate identities unless deliberately coordinated.

A missing key emits an explicit **Signing identity cache miss** warning. Public certificate/signature evidence is saved as `apk-signature.txt`; the APK's checksum is saved beside it as `sirens-song-debug.apk.sha256`. Both are included in the installable APK artifact. Private key bytes are never uploaded as an artifact or committed. A future durable release/update channel needs controlled signing-key storage; the development cache alone is not a permanent identity guarantee.

## Installed toolchain

| Component | Observed version / path |
| --- | --- |
| Godot editor | `4.6.3.stable.official.7d41c59c4` |
| Official export templates | `~/.local/share/godot/export_templates/4.6.3.stable` |
| Selected templates | Android debug/release/source; Linux x86_64 debug/release |
| Recommended Java | Temurin `17.0.16+8`, `/workspace/.command-library-env/jdk-17.0.16+8` |
| System Java | OpenJDK `21.0.12.1`; scripts select configured JDK17 |
| Android SDK | `/workspace/.command-library-env/android-sdk` |
| Platform tools / adb | `37.0.1` / `1.0.41` |
| Installed SDK platform | `android-37.0` |
| Installed build tools | `36.0.0` |
| SDK command-line tools | `23.0` (`latest`), also `19.0` |
| Cached Gradle | `9.6.0`; not substituted for Godot's wrapper |
| Xorg | `1.21.1.16`, existing dummy-driver configuration |
| Native software graphics | Mesa `25.0.7`, OpenGL `4.5`, llvmpipe LLVM `19.1.7` |
| Capture / encoding | ImageMagick `import`, FFmpeg `7.1.5` |
| Browser fallback | Chromium `154.0.8037.57`, Node `24.19.0` |

The official Godot 4.6.3 Android source pins JDK17, Gradle8.11.1, AGP8.6.1, Kotlin2.1.21, compile/target SDK36, build-tools36.1.0, and NDK29.0.14206865. These extra versions would be needed for the corresponding custom Gradle/native source workflow. The initial APK path uses prebuilt templates and the installed signing tools; it does not compile Godot or invoke Gradle. Install pinned dependencies only when that workflow is needed.

## Desktop rendering and capture

`display.sh` reuses an available display or starts Xorg with the existing `/etc/X11/xorg.conf`, defaulting to `:99`. The installed dummy driver provides a 1364×1024 desktop and additional modes. `capture.sh` selects `LIBGL_ALWAYS_SOFTWARE=1`, `gl_compatibility`, OpenGL3, dummy audio, and Godot Movie Maker PNG output at a fixed frame rate. The script logs Godot output in each capture directory. Xvfb is not installed or required.

Movie Maker can emit an audio WAV beside PNGs. For a playable recording, encode a chosen sequence with FFmpeg after checking Godot's actual generated frame names. Screenshots should come from rendered frames, not an empty display after the process exits.

Godot Movie Maker retains the configured1280×720 output size even when `--resolution` changes the window; this can crop a taller fold layout. `capture.sh` therefore also requests the production game's full-viewport screenshot hook, saved as `full.png` after layout settles. Use **full.png** for viewport/layout review. The script ensures at least6 frames run. For an inner-display approximation on the existing desktop: `CAPTURE_RESOLUTION=1092x984 CAPTURE_FRAMES=6 scripts/toolchain/capture.sh -- --scenario=planning`. A caller can supply an explicit absolute `--capture-path=...` to replace the default screenshot destination. Emulator screenshots use `adb screencap` and are unaffected by Movie Maker cropping.

## Android runtime gate

The environment has no emulator executable, AVD/system image, `/dev/kvm`, physical USB device node, or running adb server when audited. APK creation and signature/manifest inspection are feasible here. APK installation, touchscreen behavior, lifecycle/save-resume, Android audio, GPU performance, and thermal behavior require an accessible device or a separately provisioned emulator. Neither a successful export nor desktop rendering is evidence of an Android runtime test.

With an authorized device attached, use the SDK's `platform-tools/adb` to list devices, install the APK, launch `org.sirenssong.game`, collect logcat, and capture actual device screenshots. No device connection or APK installation was claimed during setup.

## GitHub-hosted Android validation

`.github/workflows/android-validation.yml` runs on pushes to `gauntlet/**` and manual dispatch. It builds the APK on Ubuntu24.04 with Java17 and official SHA512-pinned Godot4.6.3 binaries, then uses the maintained Android emulator runner action with a KVM-accelerated API36 x86_64 emulator. Actions are pinned to commit SHAs. Downloads are cached; generated APKs, import/build/test logs, screenshots, fingerprint, activity dumps, process evidence, and logcat are uploaded for14 days even after a later step fails. No custom workflow secret is required.

The emulator smoke uses physical-size overrides to capture **2520×1080 cover landscape** and **2184×1968 inner landscape**, checks actual PNG dimensions, and resizes the live app between profiles. It checks background/resume and verifies background process death before restart. It fails on missing game processes or Java/native/GDScript errors. This is a viewport and lifecycle smoke test; it does not prove saved mission state is restored correctly. It also does not emulate Samsung firmware, physical folding/hinge behavior, Fold7 GPU performance, or touch ergonomics. Those remain device-validation items.

The current smoke additionally sends actual native taps using the game's post-layout `SS_TARGET` markers scaled to screenshot pixels. It exercises mission entry, selection, a route order, pause/resume and restored-mission entry, requiring new event markers for each operation. Engine shader errors also fail the smoke. The hosted GPU uses `swangle_indirect`; an earlier `swiftshader_indirect` run installed/launched the game but failed built-in Godot shader compilation, as preserved in the audit. Successful rendering on the newer backend must be established by its own run. Android's first-use immersive prompt is preconfirmed in the emulator fixture so screenshots show the game. Runtime logs/images and the installable APK are uploaded as separate artifacts.

GitHub API reads work through the installed GitHub connector's generic `github_fetch` API endpoint support. Local `gh api`/`gh run list` returned Forbidden in the audited network path. For monitoring, fetch `https://api.github.com/repos/pemunson90-cmd/Siren-s-Song/actions/runs?branch=gauntlet%2Fproduction&per_page=5`, then inspect jobs/artifacts by run ID. The connector's specialized commit-workflow helper filters pull-request events and should not be used to conclude that push runs are absent.

## Alternatives considered

Godot is preferred because its editor, native runtime, headless import, CLI exports, 2D scene/UI/audio/navigation systems, and real rendered captures are available together. Native Kotlin is viable with the existing JDK/SDK, but a production game would require assembling game rendering, content tools, simulation/debugging, and audio workflows. LibGDX adds a suitable maintained 2D framework and desktop backend, but neither a project nor its dependencies are installed; the Android device gate remains identical. An HTML5 wrapper could reuse archival browser prototypes and Chromium capture, but adds WebView packaging/runtime variation and does not exercise native Godot rendering or satisfy Android runtime testing on its own.

See [environment-audit.md](validation/environment-audit.md) for provenance and exact probe evidence.
