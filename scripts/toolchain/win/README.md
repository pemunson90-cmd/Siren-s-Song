# Windows toolchain (PowerShell 5.1)

Native Windows counterparts of the Linux Bash scripts in `scripts/toolchain`. They
need no WSL. Run them from any folder; they find the repository from their own
location. Where the examples say `powershell -File`, you can also run the script
directly from a PowerShell prompt.

If PowerShell refuses to run scripts, start them with
`powershell -NoProfile -ExecutionPolicy Bypass -File <script> ...`.

## Where things live

- Cache: `%USERPROFILE%\.cache\sirens-song-toolchain` (override with `TOOLCHAIN_CACHE`)
- Godot editor: `<cache>\win\Godot_v4.6.3-stable_win64_console.exe` (override with `GODOT_BIN`)
- Downloaded zip: `<cache>\downloads`
- Logs: `<cache>\artifacts\<name>.log` (override with `ARTIFACT_DIR`)
- Isolated user data for tests: `<cache>\isolated-userdata`

## 1. install-godot.ps1

```
powershell -File scripts\toolchain\win\install-godot.ps1
```

Downloads the official Godot 4.6.3 Windows zip only if it is not already in the
downloads folder, checks its SHA512 against the pinned value, and refuses (exit 1)
if it does not match. It extracts only when the exes are missing, then prints the
console exe path and `--version`. Running it again is safe and changes nothing.

## 2. headless.ps1

```
headless.ps1 -Action Import -Isolate
headless.ps1 -Action Core -Isolate
headless.ps1 -Action Script -Script sweeper_tests -Prefix SWEEPER -Isolate
headless.ps1 -Action Raw -GodotArgs --version
```

- `Import` imports the project. `Core` runs `res://tests/run_tests.gd`.
  `Script` runs one test (`-Script` takes `NAME`, `NAME.gd` or a `res://` path).
  `Raw` passes your arguments straight to Godot.
- `-Prefix` is the suite's summary prefix from `game/tests/suites.txt` (for example
  `SWEEPER`); leave it empty for the core suite.
- `-Isolate` points `APPDATA` and `LOCALAPPDATA` at a private folder for the Godot
  process only, so tests never touch your real saves in
  `%APPDATA%\Godot\app_userdata`. Use `-UserDataRoot <folder>` to choose the folder.
- Output is filtered to the `CHECKS N FAILURES M` line, FAIL lines and errors;
  add `-ShowAll` for everything. The full output is always in the log file.
- Exit code is non-zero when there are failures, script errors, `ERROR:` lines,
  "resources still in use" or leak lines, no summary line, or a timeout
  (`-TimeoutSec`, default 480).

## 3. test-suite.ps1

```
test-suite.ps1 -List -Profile ci
test-suite.ps1 -Suite sweeper_tests,back_exit_tests
test-suite.ps1 -All -Profile local -SkipCore
```

Reads `game/tests/suites.txt` (`name|label|localRank|ciRank[|render]`). Runs the
suites you name, or with `-All` every suite in the profile (`local` or `ci`) in
rank order. A `-` rank means the suite is not in that profile. Suites marked
`render` need Xvfb on Linux, so they are reported as SKIPPED. A pass requires the
strict summary `<label> CHECKS N FAILURES 0` with N above zero and no error or leak
lines. A table with status, check count and seconds is printed at the end, and the
exit code is non-zero if any suite failed. Tests use an isolated user data folder
unless you pass `-NoIsolate`.

The project guidance says not to run the complete scenario list locally. Run import,
core and the suites affected by your change; GitHub CI is the full gate. `-All`
exists so that choice is explicit.

## 4. check-suites.py (in scripts\toolchain)

```
python -I scripts\toolchain\check-suites.py
```

Read-only check of the registry. It reports errors (exit 1) for malformed rows,
duplicate suite names, duplicate or non-positive local or CI ranks, registered
suites whose file is missing, and any `game/tests/*_tests.gd` or `*_scenarios.gd`
that extends `SceneTree` (directly or through a parent script) yet is neither
registered nor listed in `scripts/toolchain/suites-allowlist.txt`. Files with those
names that only define helpers are counted and ignored. Warnings cover stale
allowlist lines and registered files that are not SceneTree entry points.

Add a deliberately unregistered entry-point to the allowlist as `name | reason`.
