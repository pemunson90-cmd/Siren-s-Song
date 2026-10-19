# Siren's Song — build and runtime environment

## Current toolchain

Godot **4.6.3 stable**, GDScript, Compatibility renderer, official matching Android templates, Java 17 and Android SDK. The checked-in `game/` directory is the Godot project. Use existing configured tools before installing or changing SDK/engine versions. Common existing editor: `/usr/local/bin/godot`; scripts accept environment overrides.

From the repository root:

```sh
scripts/toolchain/headless.sh --editor --import --quit
scripts/toolchain/headless.sh --script res://tests/run_tests.gd
scripts/toolchain/test.sh
scripts/toolchain/build.sh android
scripts/toolchain/build.sh linux
CAPTURE_FRAMES=90 scripts/toolchain/capture.sh
```

`scripts/toolchain/install-godot.sh` verifies the pinned official Godot binary/export templates on a fresh runner. Relevant overrides: `JAVA_HOME`, `ANDROID_HOME` / `ANDROID_SDK_ROOT`, `TOOLCHAIN_CACHE`, `GAME_DIR`, `GODOT_BIN`, `ARTIFACT_DIR`, `CAPTURE_DIR`, `CAPTURE_RESOLUTION`, `CAPTURE_FPS`, `CAPTURE_FRAMES`. The default build output is under `/workspace/.sirens-song-toolchain/artifacts`. Use actual engine frames / full viewport screenshots when assessing visuals; headless checks alone do not certify rendering.

## Persistent development signing

`scripts/toolchain/configure.sh` requires `scripts/toolchain/signing/sirens-song-debug.keystore` and validates its established public certificate. SHA256: `32bcb2287acd01c1f58c26997c7639f3072c74c6b03ab2a24656dc7cd1c7dc3c`. Do not silently generate a different identity if a cache or configuration changes. This is development signing only; `scripts/toolchain/test-configure-signing.py` checks the configuration.

## Android milestone CI

`.github/workflows/android-validation.yml` is triggered by an explicit `gauntlet/production` commit changing `.github/native-milestone.txt`. The sole integrator changes that marker only for a coherent reviewed gameplay batch or actual native-specific problem. Normal feature/docs pushes do not request an APK. Confirm the workflow run's `head_sha`, event, branch, APK digest/certificate and relevant screenshots before identifying what passed.

Hosted emulator acceptance covers native app runtime, layout/input, script errors and bounded save/lifecycle checks. A physical Fold7 remains the separate target for touch comfort, folding, sustained performance and listening. `docs/PLAYTEST_ANDROID.md` describes installing and testing the current accepted build.

## Repository and archive separation

Game, tooling, configuration, tests and compact build instructions remain in active Git. Prior CI dumps, generated screenshots, historical native run writeups and extensive experiment reports are preserved in the archive snapshots: `archive/gauntlet-evidence-2026-10-19` and `archive/gauntlet-evidence-2026-10-19-stage2`. Do not recreate those bulk directories under active `docs/validation/`. Use focused regression fixtures under `scripts/toolchain/fixtures/` when a test needs an archived example. Historical toolchain/run forensic details can be read from those immutable archive refs.
