# Tests

`game/tests/suites.txt` is the single suite registry. Each row is
`suite|summary prefix|local order|CI order`; the core prefix is empty.
Ranks preserve the historical local and CI orders; `-` excludes a profile.
Append a new standalone harness in one row with the next rank in both profiles.
Helpers and renderer capture utilities are not standalone headless suites.

Use `scripts/toolchain/test.sh --list --profile ci` to inspect the order.
Use `scripts/toolchain/test.sh --suite NAME` for a targeted check.
The default command retains local toolchain and density checks.
CI runs import, core, then the CI profile excluding core.

The core suite must end `CHECKS N FAILURES 0` with a positive check count.
Every other suite must emit its registered prefix and the same strict ending.
A Godot resources-still-in-use line fails CI, as do script errors and leaks.
Each suite has a 480-second timeout. Touch and Android back are primary;
keyboard checks cover fallback behavior only.
