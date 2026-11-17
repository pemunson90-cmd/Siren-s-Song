# Siren's Song: development environment

Current execution and Windows transition: [RESUME](RESUME.md) and
[DESKTOP_HANDOFF](DESKTOP_HANDOFF.md). Pat requested a cloud stop after PR96 and
the documentation handover. Setup does not authorize another implementation task.

## Engine and ordinary checks

Godot 4.6.3 stable, GDScript and Compatibility. `game/` is the project root.
For Windows, use WSL2 Ubuntu x86_64 for the existing Bash automation; the pinned
installer downloads a Linux x86_64 binary. It is not a native PowerShell or ARM
installer. Native Windows Godot 4.6.3 can open `game/project.godot` for optional
desktop play without exports. Neither path certifies physical Fold7 behavior.

The current wrappers require Bash/GNU utilities, Python3, curl, unzip and JDK 17.
Rendered suites additionally need Xvfb, xauth and software OpenGL libraries.
Android SDK/emulator setup is unnecessary for ordinary Godot import and tests.
Use existing tools before installing or changing versions.

From the repository root in Linux/WSL Bash:

```sh
export PATH="$HOME/.cache/sirens-song-toolchain/bin:$PATH"
scripts/toolchain/install-godot.sh
scripts/toolchain/headless.sh --editor --import --quit
scripts/toolchain/headless.sh --script res://tests/run_tests.gd
scripts/toolchain/test.sh --profile ci --suite runtime_tests
```

The last command is an example affected suite, not a required default for every
change. Run core plus suites for the changed area. Never run the complete local
scenario list; GitHub game-smoke owns it. Every candidate log must have its
successful summary and no script errors, ObjectDB leaks or resources-in-use line.
See [TESTING](TESTING.md). No APK builds, Android workflow dispatch or exports.
The historical `build.sh linux` command is not a ready desktop setup path: the
installer extracts Android templates, and that wrapper also configures Android.

The installer verifies pinned official downloads but does not export its binary
onto PATH. If TOOLCHAIN_CACHE is customized, prepend its `bin/` directory instead.
Overrides include `JAVA_HOME`, `TOOLCHAIN_CACHE`, `GAME_DIR`, `GODOT_BIN`,
`ARTIFACT_DIR` and the existing capture variables. Default cache is
`/workspace/.sirens-song-toolchain` only if that directory already exists;
otherwise `${XDG_CACHE_HOME:-$HOME/.cache}/sirens-song-toolchain`. Artifacts default
to that cache's `artifacts/`. Cloud `/workspace` and `/tmp` paths do not transfer
to desktop. Give concurrent suites distinct artifact directories.

## Signing and deferred Android machinery

Preserve `scripts/toolchain/signing/sirens-song-debug.keystore`. Its public
certificate SHA256 is
`32bcb2287acd01c1f58c26997c7639f3072c74c6b03ab2a24656dc7cd1c7dc3c`.
Never generate a replacement on a cache miss. No release/store key is required.

The Android workflow and matching templates remain reference machinery. Current
Pat rules prohibit APK builds and defer phone testing until feature complete and
bug free. Do not change `.github/native-milestone.txt`, push production/main or
dispatch Android validation during the desktop transition. Future phone testing
must use an explicitly recorded accepted source/run after Pat changes this rule;
[PLAYTEST_ANDROID](PLAYTEST_ANDROID.md) is deferred reference only.

## Source and evidence recovery

Recreate checkouts from published refs; do not copy tool caches or credentials.
Desktop handover notes identify the preserved source/preparation and the archive
branch containing cloud evidence. Older evidence is retained on the existing
archive refs. Raw reports and generated captures stay outside active source Git;
the historical archive branches are recovery locations, not current instructions.
