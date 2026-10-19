# Codex environment assessment

**Status: pending.** No environment has been selected or published.

Evaluate existing Codex environments first:

- Java/JDK, Android SDK, platform/build-tools, Gradle and Android Gradle Plugin.
- Node.js and package managers if the chosen engine/toolchain requires them.
- Godot and Android export templates if Godot is selected.
- Headless rendering/browser automation, screenshot capture, and test runners.
- APK build, signing strategy for development builds, emulator/device test path.
- Repository access, dependencies, disk/cache limits, and reproducibility.
- Ability to preserve visual and test artifacts between agent runs.

Select an engine after comparing actual project needs and environment capabilities. Record the decision in an ADR under `docs/decisions/`.

Do not publish a new environment solely because this repository was created.
