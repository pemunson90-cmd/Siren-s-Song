# Status

The one live status file. Keep it short. Update it in the change that alters the base, the active work, the top weaknesses, the blockers or the next action. History is in git and in [CHANGELOG.md](../CHANGELOG.md).

Updated: 2026-11-12

## Current integrated base

- `claude/integration` at `cabd5bd5` (2026-11-01). It holds items 126 to 148 and the stable-board package; a debug package of `6182568d` was built for Pat on 2026-11-01 (workflow run 41379272814).
- `main` at `f5b66a19`. `gauntlet/production` frozen at `26e09906`.

## Active work

- Chartered overhaul run `overhaul-20261111` on branch `fable/overhaul-20261111`: finished, awaiting Pat's review in pull request 262 (report `.fable/FINAL_REPORT.md`). No writer is active.
- Parked: item 134, route flow (superseded by the release controls of item 127; reopen only if a critic finds route stops again).

## Top weaknesses

Ranked in `.fable/SURVEY.md` section 7 and `.fable/COLD_REVIEW_6.md`. In short:

1. Photo payoff: value favors distance and tools over photo quality.
2. Late-operation variety and the branching route graph: forks mostly change approaches inside operations, not which operations the player gets.
3. Touch interface defects on real screens: lists that do not scroll by dragging their content (HUD chips and the oxygen reading were addressed in the overhaul run; unverified on a phone).
4. Expansion cost: operations, regions, Siren roles and fittings are keyed on literal IDs in many files.
5. Look and sound have never been compared against reference games; audio has never been assessed. Art direction is Pat's call.

## Blockers

- None for engineering work.
- The nightly workflow cannot run until `nightly-integration.yml` is on `main` (next promotion, Pat's call).
- Physical phone acceptance is Pat's: he plays the debug package after a run stops.

## Waiting on Pat

The run's decisions D-01 to D-15 are answered. New questions N-1 to N-7 are in `.fable/FINAL_REPORT.md` section 9. Older open questions are in [QUESTIONS_FOR_PAT.md](QUESTIONS_FOR_PAT.md) (items 3 and 8).

## Next action

The overhaul run `overhaul-20261111` is finished (2026-11-12), including the repairs Pat approved the same day. Pull request 262 holds all of it. Next, in this order:

1. Pat plays the debug package (link and install steps in `.fable/FINAL_REPORT.md` section 11) and gives feedback.
2. Pat answers the new yes or no questions N-1 to N-7 (report section 9) and merges pull request 262 into `claude/integration`.
3. The next run builds what Pat approved for after the playtest (photo pay retune, fast-forward and a starter drone tool, late-campaign alternates), then the P2 backlog in `.fable/OVERHAUL_PLAN.md`, reordered by the playtest feedback.

Testing rule (Pat, 2026-11-12): the bare minimum for every change; the full matrix only by manual dispatch before a release or near-release package.
