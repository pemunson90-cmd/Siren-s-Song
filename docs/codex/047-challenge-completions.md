# Handoff 047: CHALLENGE COMPLETIONS, one scripted completion per challenge row and route-aware pars

Status: DONE
Claimed at: 2026-10-24 23:34:02 UTC
Claimed by: claude (orchestrator, split with Codex by Pat 24 Oct)
Finished at: 2026-10-25 02:10:00 UTC

Precondition: none. Source: docs/design/COLD_REVIEW_3.md finding F11. Tests plus a Pat decision list; par values are NOT changed by this handoff.
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (CHECKS N FAILURES 0), challenges, challenges_ui and the new journeys. No full scenario list locally. Never skip, loosen or delete a test.
Standing rules: PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md on claude/integration. Touch-first (48 dp, Android Back = Escape), table-driven, optional validated save fields, revert note in the module header, tests beside it. Push WIP every 30 minutes. No em dashes. Change no combat, Siren sight, hearing or lock rule, and no operation table. Do not commit generated .uid files integration does not track, or .import line-ending churn. Windows: see docs/DESKTOP_HANDOFF.md.

## Task (plain language)
The challenge catalog has 12 rows (game/src/campaign/challenges/challenge_catalog.gd `ROWS`). Only `shelf_passive` has an end-to-end completion (game/tests/challenges_journey_tests.gd, which says "proves one representative completion, not difficulty"). The reviewer completed `lung_solo` by the dismantle route in 79 s (par time 110 s, passes) and by the reconnect route in 273 s (par 110 s, cannot pass), and `stair_no_charges` in 188 s (par 240 s). Nine rows were never completed by anyone.

### Part 1: one scripted completion per row (11 new)
Add journeys (new file game/tests/challenges_completions_tests.gd or one per group) for the remaining rows: split_solo, foundry_no_charges, well_intact, song_fleet, rendezvous_middle, wake_one_charge, glass_passive, reach_quiet, glass_fast, stair_no_charges, lung_solo. Use `ChallengeRun.setup(id)` (src/campaign/challenges/challenge_run.gd, the same entry shelf_passive uses), the live simulation, ordinary commands, and the patient_play style from game/tests/patient_play.gd (`rehearsal_survives`) before each photograph so the route is honest about live Sirens. Reuse the existing operation journeys as route sources where they exist: tests/opening_depth_journeys.gd, glass_reach_journeys.gd, iron_choir_journeys.gd, expanded_region_journeys.gd, shelf_habitat_journey_tests.gd, wake_crossing_journey_tests.gd, warning_chain_journey_tests.gd, witness_evacuation_journey_tests.gd, and `Travel.move` in tests/campaign_scenarios.gd. For each row assert: outcome is "won", `result().loss` is false, the row's rule was not violated (`rule_failure` empty), and print `CHALLENGE <id> outcome= time= hull= tools=` so the actual numbers can be compared with the par.
A row that cannot be completed by a scripted route within its rule is a finding, not a failure to hide: leave a clearly named test that records the attempt, do not skip or weaken it, and report it.
Challenge ops (catalog `op` is an id; player op = id + 1): 0 shelf_passive, 1 split_solo, 3 foundry_no_charges, 4 well_intact, 5 song_fleet, 7 rendezvous_middle, 9 wake_one_charge, 14 glass_passive, 16 reach_quiet, 19 glass_fast, 23 stair_no_charges, 29 lung_solo.

### Part 2: route-aware pars (propose, do not change)
`challenge_records.gd` `pars(row, result)` scores time against one `row.par.time`. For ops with two routes (lung_solo: dismantle 79 s vs reconnect 273 s) one par is unreachable on one route. Do NOT edit any par number or the scoring. Instead:
1. From your completions, record per row the measured time, hull and tools for every route you can script (both routes for lung_solo; check every other row for a second route).
2. Write docs/design/CHALLENGE_PARS_PROPOSAL.md with a table: row, route, measured time/hull/tools, current par, proposed par (AI-DESIGNED), and one proposed schema sketch for route-aware pars (for example `par` as a list keyed by route id, with the route read from existing mission state such as `choir_choice`, never from player input). Mark each change as a Pat decision.
3. Optional only if small and behind a default-off flag: the scoring accepts either shape. Default must keep today's numbers and behaviour.
Pat decides pars. Report the proposal in Completion and on the board row.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-challenge-completions

## Files you may edit
New tests, tests/ helpers if needed, docs/design/CHALLENGE_PARS_PROPOSAL.md, and (only behind a default-off flag) challenge_records.gd.

## Files you must not touch
challenge_catalog.gd par values, operation tables, simulation rules.

## What done looks like
- 11 new scripted completions (or each blocked row reported with the reason) plus the existing one; CHALLENGES JOURNEY CHECKS N FAILURES 0.
- The pars proposal file exists with measured numbers for both lung_solo routes.
- Challenges UI at both Fold7 shapes (2520x1080 and 2184x1968) by real touch unchanged (challenges_ui_tests pass).
- Zero par numbers changed.

## Return
PR into claude/integration. Merge per the line above; mark DONE and update the board. Post the pars proposal summary in Completion for Pat.

## Completion

DONE by Claude (orchestrator). PR138 via batch PR140 (merge 246eb72). 11 new scripted completions of the challenge rows (opening, reach and iron suites); lung_solo both routes (dismantle 79.3 s, reconnect 273.6 s against a 110 s par). No par, rule or scoring changed. docs/design/CHALLENGE_PARS_PROPOSAL.md proposes route-aware pars for Pat to decide. glass_fast completes but misses its hull par (74.4 vs 85). split_solo uses a SHALLOW then MIDDLE route. Tests: 39 + 53 + 30 checks, 0 failures; core 835/0.


## Pat ruling, 27 October 2026 — approved design; no code changed

Use route-aware par times for `lung_solo`: dismantle **110 s**, reconnect **300 s**, with route inferred from mission outcome (not player-selected). Keep hull 100 and tools 0 for each route. Retain an individual personal best **per legitimate route** plus **overall challenge completion**, so a dismantle best cannot prevent recognition of reconnect completion. The design is approved but remains unimplemented; do not claim the old 047 completion was updated to include new scoring. Development remains paused.
