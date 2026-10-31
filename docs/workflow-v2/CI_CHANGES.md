# CI changes (spec for `.github/workflows/gauntlet-pr-checks.yml` and a new nightly)

Drafted 2026-10-30. Goal: make a CI round rare, short and attributable, without weakening any test. Today every push to any PR runs core plus four runtime shards (about 47 minutes on a green run, 44 of them in the slowest shard) and cancels the run in progress. Of the last 60 runs, 29 were cancelled and 13 were red.

## Measured today

| Job | Green run 41093784501 | Note |
|---|---|---|
| guidance | 6 s | keep |
| game-core | 2 m 45 s | import and core |
| game-runtime 1/4 | 20 m 30 s | shards split by count: `[int(shard)-1::4]` |
| game-runtime 2/4 | 23 m 14 s | |
| game-runtime 3/4 | 37 m 15 s | |
| game-runtime 4/4 | 43 m 40 s | sets the wall clock |
| game-smoke | 4 s | aggregate |

354 registered suites, 480 s per-suite timeout, 90-minute job cap.

## Changes

1. **Draft PRs run no game jobs.** Builders push WIP as drafts. Add to `game-core`, `game-affected` and `game-runtime`:
   `if: github.event_name == 'merge_group' || github.event_name == 'schedule' || github.event.pull_request.draft == false`. This removes the cancelled runs that WIP pushes create. `guidance` still runs on drafts (6 s).

2. **Affected selection on PR pushes.** New job `game-affected` (replaces `game-runtime` for `pull_request` events): runs `scripts/toolchain/select-suites.py --base $BASE_SHA --head HEAD` and executes its list plus the canary set with `test.sh --profile ci --suites <list>`. Budget about 15 minutes. `select-suites.py`:
   - builds the map test file to source files from `preload("res://src/...")`, `load("res://...")` and `extends "res://..."` strings in `game/tests/*.gd` (one pass, cached per commit);
   - selects every suite whose map intersects the changed `game/src` files, plus any changed test file itself, plus every suite whose row in `suites.txt` changed;
   - a change to a serial zone (`main.gd`, `mission_hud.gd`, `ocean_view.gd`, `simulation.gd`) or to `scripts/toolchain`, `suites.txt` or the workflow selects the full matrix instead (the job then runs the four shards as today);
   - if the selection exceeds 60 suites it also falls back to the full matrix;
   - always appends the canary set from `scripts/toolchain/canaries.txt` (the ruling tests in RULING_TESTS.md, core excluded because it already ran).
   The script has its own test (`test-select-suites.py`) with a fixture tree, like `test-ci-shards.py` today.

3. **Full matrix only on the merge candidate and nightly.** Add `merge_group:` to `on:`. `game-runtime` (four shards) runs on `merge_group` and `schedule` only. `game-smoke` requires: on `pull_request`, core and `game-affected`; on `merge_group` and `schedule`, core and all four shards. Enable GitHub merge queue on `claude/integration` with required checks `guidance` and `game-smoke`; until then `runner2.py` phase C triggers `workflow_dispatch` with `full=true` on the merge-candidate head and waits for it.

4. **Duration-balanced shards.** `test.sh --shard N` reads `game/tests/suite-times.json` (suite name to seconds, written by the nightly from the suite logs' wall times) and assigns suites greedily to the shard with the least load, in a stable order. Missing entries default to the median. Expected wall clock about 31 minutes per shard instead of 44. `test-ci-shards.py` keeps proving every suite lands in exactly one shard.

5. **Nightly on integration.** New `nightly-integration.yml` on `schedule` (03:30 UTC) and `workflow_dispatch`: full matrix, then `hand_pilot_journeys.gd` across every core op and one run per side mode writing `metrics.json` (PROCESS.md section 6), a render run under Xvfb with `--print-fps` for the frame-time proxy, and the soundscape event audit. Uploads `metrics.json` and `suite-times.json` as artifacts (7-day retention). A red nightly opens a fix-forward item at the head of the queue (the runner polls the run conclusion). The metrics artifact is copied into the artifact cache under `metrics/<date>/` by the runner for the digest.

6. **No change to tests.** No timeout raised, no assertion weakened, no suite removed. Allowlist and registry checks stay. The `android-validation.yml` marker route stays untouched (no APK).

## Expected effect

| | Today | v2 |
|---|---|---|
| CI minutes per PR push | about 130 runner-minutes, 47 wall | about 20 runner-minutes, 15 wall (draft pushes: 0) |
| Red rounds from another lane's merge | common (118: 9 relaunches) | none: the merge candidate runs everything on the merged head |
| Shard wall clock | 44 min | about 31 min |
| Who repairs red | orchestrator, by hand | runner relaunches A once with the failing lines |

## Evidence to carry in the CI change PR

One green `pull_request` run showing `game-affected` with its selected list in the log; one `merge_group` or dispatched full run; the shard assignment printout from `test-ci-shards.py`; `test-select-suites.py` passing. Nothing else.
