# Tests

> **In force since 2026-11-12 (Pat):** GitHub Actions are not used: the monthly allowance is spent, and no run is started unless Pat asks for it. Every push carries `[skip ci]`. Testing is local. The registry holds 238 suites: the local profile is the everyday set (39 suites, `scripts\toolchain\win\test-suite.ps1 -All -Profile local`, about 20 minutes), run before a merge of size; the others are guards, run when the file they cover changes (`python scripts/toolchain/select-suites.py --minimum --changed <paths>`). 152 suites were retired to `_scrap-20261111/tests-retired/` (list and reasons in `.fable/TEST_TRIM.md`). Where the text below describes GitHub jobs as the gate, it describes how the workflows behave when they are run, not what is run today.

`game/tests/suites.txt` is the single suite registry. Each row is
`suite|summary prefix|local order|CI order`; the core prefix is empty.
Ranks preserve the historical local and CI orders; `-` excludes a profile.
Append a new standalone harness in one row with the next rank in both profiles.
Helpers and capture utilities are not standalone suites.
An optional fifth field `render` selects Compatibility software GL via Xvfb;
install Xvfb and xauth to run those tests. CI already provides both.

Use `scripts/toolchain/test.sh --list --profile ci` to inspect the order.
Use `scripts/toolchain/test.sh --profile ci --suite NAME` for a targeted check.
The default command retains local toolchain and density checks.
CI runs import, core, then the CI profile excluding core.

CI by event: draft pull requests run guidance only. Ready pull requests run core
and `game-affected`: `scripts/toolchain/select-suites.py` picks the suites whose
res:// references reach the changed files, plus `scripts/toolchain/canaries.txt`,
and runs them with `test.sh --profile ci --suites a,b,c`. Files a serial zone
reaches, files no suite reaches, test infrastructure or more than 60 suites
fall back to the four runtime shards.
The merge queue, nightly and manual dispatches always run all four shards.
`test.sh --shard N` balances shards by `game/tests/suite-times.json`
(suite to seconds; the nightly uploads a fresh one as an artifact).

The core suite must end `CHECKS N FAILURES 0` with a positive check count.
Every other suite must emit its registered prefix and the same strict ending.
A Godot resources-still-in-use line fails CI, as do script errors and leaks.
`test.sh` runs every selected suite even after a failure, then prints `FAILED SUITES: a, b` and exits non-zero.
Each suite has a 480-second timeout. Touch and Android back are primary;
keyboard checks cover fallback behavior only.

## Local limit and Windows setup

Run import, core and only the affected suites locally. Never run the full scenario
list locally; GitHub game-smoke is the complete gate on the exact proposed head.
The default runner behavior above describes implementation, not permission to
run its complete list. An Android package is not part of the test workflow; a
debug package is built on request through `android-validation.yml` (see
[WORKFLOW](WORKFLOW.md) and [PLAYTEST_ANDROID](PLAYTEST_ANDROID.md)).

On Windows use the native PowerShell scripts in `scripts/toolchain/win/`
(see [their README](../scripts/toolchain/win/README.md)); they need no WSL.
They run import, core and every suite that is not marked `render`. Rendered
suites need Linux: they run via Xvfb with software GL and Dummy audio (install
`xvfb`, `xauth` and the distribution's Mesa/software-GL libraries) and
otherwise run on GitHub. Keep separate artifact directories for concurrent
checks. A clean exit alone is insufficient: inspect the strict summary and
Godot errors/leaks. No physical-device performance or headphone evidence
follows from these checks.

## Environment

[Carried on 2026-11-12 from the retired CODEX_ENVIRONMENT and DESKTOP_HANDOFF
documents, now under `_scrap-20261111/docs/`.]

Godot 4.6.3 stable, GDScript, Compatibility renderer. `game/` is the project
root. The Linux wrappers need Bash and GNU utilities, Python 3, curl, unzip and
JDK 17. The Android SDK and emulator are not needed for import and tests. Use
existing tools before installing or changing versions.

Linux, from the repository root:

```sh
export PATH="$HOME/.cache/sirens-song-toolchain/bin:$PATH"
scripts/toolchain/install-godot.sh
scripts/toolchain/headless.sh --editor --import --quit
scripts/toolchain/headless.sh --script res://tests/run_tests.gd
scripts/toolchain/test.sh --profile ci --suite runtime_tests
```

The last command is an example of one affected suite. The installer verifies
pinned official downloads and does not put its binary on PATH. Overrides:
`JAVA_HOME`, `TOOLCHAIN_CACHE`, `GAME_DIR`, `GODOT_BIN`, `ARTIFACT_DIR` and the
capture variables. The default cache is `/workspace/.sirens-song-toolchain`
only if that directory already exists, otherwise
`${XDG_CACHE_HOME:-$HOME/.cache}/sirens-song-toolchain`; artifacts default to
its `artifacts/` folder. Give concurrent suites distinct artifact directories.

Godot user data (saves, profiles, settings) is normally
`%APPDATA%/Godot/app_userdata/Siren's Song` on Windows and
`~/.local/share/godot/app_userdata/Siren's Song` on Linux; respect any explicit
XDG or Godot user-data override, and back up existing data before replacing
it. Do not overwrite desktop or phone progress with test fixtures.

Signing: the development keystore is tracked at
`scripts/toolchain/signing/sirens-song-debug.keystore`; its public certificate
SHA256 is `32bcb2287acd01c1f58c26997c7639f3072c74c6b03ab2a24656dc7cd1c7dc3c`.
Never generate a replacement on a cache miss. No release or store key is in
the repository.

Evidence from the cloud period (route-map screenshots, test logs, parity
scripts) is preserved on the branch `archive/cloud-desktop-20261023`. Raw
reports and captures stay outside the active tree.
