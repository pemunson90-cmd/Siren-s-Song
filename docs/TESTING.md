# Tests

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
and runs them with `test.sh --profile ci --suites a,b,c`. Shared code, test
infrastructure or more than 60 suites fall back to the four runtime shards.
The merge queue, nightly and `full=true` dispatches always run all four shards.
`test.sh --shard N` balances shards by `game/tests/suite-times.json`
(suite to seconds; the nightly uploads a fresh one as an artifact).

The core suite must end `CHECKS N FAILURES 0` with a positive check count.
Every other suite must emit its registered prefix and the same strict ending.
A Godot resources-still-in-use line fails CI, as do script errors and leaks.
Each suite has a 480-second timeout. Touch and Android back are primary;
keyboard checks cover fallback behavior only.

## Local limit and Windows setup

Run import, core and only the affected suites locally. Never run the full scenario
list locally; GitHub game-smoke is the complete gate on the exact proposed head.
The default runner behavior above describes implementation, not permission to
run its complete list. No APK or Android export is part of this workflow.

On Windows use WSL2 Ubuntu for the current Linux x86_64 scripts. See
[CODEX_ENVIRONMENT](CODEX_ENVIRONMENT.md) and [DESKTOP_HANDOFF](DESKTOP_HANDOFF.md).
Rendered suites run via Xvfb with software GL and Dummy audio; install `xvfb`,
`xauth` and the distribution's Mesa/software-GL libraries. Keep separate artifact
directories for concurrent checks. A clean exit alone is insufficient: inspect
the strict summary and Godot errors/leaks. No physical-device performance or
headphone evidence follows from these checks.
