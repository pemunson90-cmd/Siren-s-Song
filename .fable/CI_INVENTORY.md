# CI inventory

Read on 2026-11-11 from `.github/workflows/` at base `cabd5bd5` and from `gh run list`. Durations are wall-clock times of recent runs on GitHub.

## Workflows

| Workflow | Triggers | Jobs and what they run | Typical duration |
| --- | --- | --- | --- |
| `gauntlet-pr-checks.yml` | `pull_request` into `main`, `gauntlet/production`, `claude/integration` (opened, synchronize, reopened, ready_for_review); `merge_group`; `workflow_dispatch`; `workflow_call` (input `ref`) | `guidance`: `test-check-gauntlet-guidance.py`, then `check-gauntlet-guidance.py --root .`. `game-core` (skipped on draft PRs): change detection over `game`, `scripts/toolchain`, `.github/workflows`; pinned Godot install with cache; import; core suite; `test-ci-shards.py`; `test-select-suites.py`. `game-affected` (ready PRs only): `select-suites.py`, then the selected suites plus the canaries. `game-runtime` (4 shards, `fail-fast: false`): import, then `test.sh --profile ci --skip-core --shard N`; runs on dispatch, merge queue, nightly call, and on PRs when selection falls back to the full matrix. `game-smoke`: aggregates the results into the one required check. | Docs-only PR: about 40 seconds. Full matrix: 49 to 54 minutes (runs 41374409065, 41367614726, 41362889168). |
| `nightly-integration.yml` | `schedule` 07:30 UTC daily; `workflow_dispatch` | Calls `gauntlet-pr-checks.yml` with `ref: claude/integration`, then merges per-shard suite times into a `suite-times` artifact. | Has never run: see gap 1. |
| `android-validation.yml` | `workflow_dispatch` on any ref; `push` to `gauntlet/production` that changes `.github/native-milestone.txt` | Job 1 (dispatch only, any ref): import, build the debug APK signed with the tracked development key, check the signer, upload the APK. Job 2 (`gauntlet/production` only): import and simulation tests, APK, emulator install and lifecycle smoke, screenshots at cover and inner viewports. | Job 1: about 90 seconds (run 41379272814). |

All three pin every action to a commit SHA, set `permissions: contents: read`, and set job timeouts. `gauntlet-pr-checks.yml` and `android-validation.yml` have concurrency groups; the PR workflow cancels superseded runs.

## Suite registry

`game/tests/suites.txt` registers 374 suites: 371 in the CI profile, 340 in the local profile, 57 marked `render` (Xvfb with software GL). `check-suites.py` reports 0 errors and 0 warnings. `game/tests/suite-times.json` holds 350 recorded suites totalling about 123 minutes of suite time, which the four shards split by duration. The slowest suites: `glass_fleet_pairs_tests` 371 s, `menu_reach_ui_tests` 271 s, `ops_home_inner_ui_tests` 270 s, `opening_depth_policy_cover_ui_tests` 266 s, `status_text_cover_ui_tests` 241 s. The canaries (`scripts/toolchain/canaries.txt`) are `protected_rules_tests`, `control_mix_tests` and `crash_possible_tests`.

## Redundancy and gaps

1. **Nightly never runs.** Scheduled workflows run from the default branch, and `nightly-integration.yml` is not on `main` (`main` at f5b66a19 has only the other two workflows). The file starts working at the next promotion to `main`, which is Pat's call. No change is possible from a `fable/` branch.
2. **Affected-suite selection rarely narrows.** Decision D25 on `codex/handoffs` records that `select-suites.py` falls back to the full matrix when a serial zone reaches the changed file, which is true for 331 of 341 source files. A ready PR that touches almost any game source therefore runs the full 50 minute matrix. This is safe and it is the largest CI cost. A narrower, still safe selection is a candidate package.
3. **Toolchain self-tests that CI does not run.** CI runs three of the Python tool tests. It does not run `test-gauntlet-boundary.py`, `test-test-sh-failures.py`, `test-configure-signing.py`, the ten `test-android-*.py` files, `test-decoy-role-contract.sh`, `test-native-role-archive.sh`, or the two `.gd` tool tests. A regression in `test.sh` failure reporting or in signing configuration would not be caught by the PR gate. The Python ones are fast and need no Godot.
4. **Each runtime shard and the affected job repeat the import.** About 20 seconds each, five times per full run. The editor binary is shared by artifact; the import cache is not. Small cost; noted, low priority.
5. **Change detection treats any workflow edit as a game change**, so a comment-only workflow edit costs a full matrix. This is the safe choice for CI edits and should stay.
6. **The production push route of `android-validation.yml` targets a frozen branch.** Pat froze `gauntlet/production` on 2026-10-31 (RULINGS). The marker route and job 2 can only run by manual dispatch on that branch now. It is working machinery, so it stays; whether the emulator smoke should move to `main` or to the integration branch is a question for the plan.
7. **Draft PRs run guidance only**, by design (decision D22). The run's draft PR therefore gets no game check until it is marked ready or the workflow is dispatched by hand on the run branch.
8. **No workflow lints the documentation links.** The charter requires a link check at the Phase 3 exit; a small link checker in `scripts/repo/` that the `guidance` job runs would keep links clean after this run.

## How this run uses CI

- Local, per package: import, core, the affected suites that are not `render`, the three canaries, `check-suites.py`, through `scripts/toolchain/win/`.
- GitHub: `gh workflow run gauntlet-pr-checks.yml --ref fable/overhaul-20261111` at the end of Phases 3, 4 and 5, once per head.
- Package: `gh workflow run android-validation.yml --ref fable/overhaul-20261111` once, at Phase 5.
