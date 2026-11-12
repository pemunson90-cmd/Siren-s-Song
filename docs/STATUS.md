# Status

The one live status file. Keep it short. Update it in the change that alters the base, the active work, the top weaknesses, the blockers or the next action. History is in git and in [CHANGELOG.md](../CHANGELOG.md).

Updated: 2026-11-12

## Current integrated base

- `claude/integration` at `cabd5bd5` (2026-11-01). It holds items 126 to 148 and the stable-board package; a debug package of `6182568d` was built for Pat on 2026-11-01 (workflow run 41379272814).
- `main` at `f5b66a19`. `gauntlet/production` frozen at `26e09906`.

## Active work

- Chartered overhaul run `overhaul-20261111` on branch `fable/overhaul-20261111` (charter `.fable/FABLE_RUN.md`, plan `.fable/OVERHAUL_PLAN.md`, run state `.fable/RUN_STATE.json`). It ends in one pull request into `claude/integration` for Pat to review. No other writer is active.
- Parked: item 134, route flow (superseded by the release controls of item 127; reopen only if a critic finds route stops again).

## Top weaknesses

Ranked in `.fable/SURVEY.md` section 7 and `.fable/COLD_REVIEW_6.md`. In short:

1. Photo payoff: value favors distance and tools over photo quality.
2. Late-operation variety and the branching route graph: forks mostly change approaches inside operations, not which operations the player gets.
3. Touch interface defects on real screens: lists that do not scroll by dragging their content, HUD chips that move or clip, unexplained oxygen limit.
4. Expansion cost: operations, regions, Siren roles and fittings are keyed on literal IDs in many files.
5. Look and sound have never been compared against reference games; audio has never been assessed. Art direction is Pat's call.

## Blockers

- None for engineering work.
- The nightly workflow cannot run until `nightly-integration.yml` is on `main` (next promotion, Pat's call).
- Physical phone acceptance is Pat's: he plays the debug package after a run stops.

## Waiting on Pat

Open decisions of the current run are in `.fable/DECISIONS.md`. Older open questions are in [QUESTIONS_FOR_PAT.md](QUESTIONS_FOR_PAT.md) (items 3 and 8).

## Next action

PAUSED, RESUME REQUIRED (2026-11-12, usage reset). Resume command: `/siren-s-start-fable` in the run clone. The run continues from `.fable/RUN_STATE.json`: finish work package WP-11, run the full CI gate, verify every protected capability, build one debug package, write the final report. Then Pat reviews the pull request and plays the debug package.
