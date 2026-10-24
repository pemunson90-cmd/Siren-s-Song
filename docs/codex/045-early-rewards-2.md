# Handoff 045: EARLY REWARDS 2, two more early fitting grants (three before op 7)

Status: CLAIMED
Claimed at: 2026-10-24 23:34:02 UTC
Claimed by: claude (orchestrator, split with Codex by Pat 24 Oct)
Finished at:

Precondition: none (extends the existing early_reward module from handoff 037). Pat, 24 Oct: no number given; "pick a reasonable number that has mechanical value". AI-DESIGNED choice below, Pat to adjust.
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (CHECKS N FAILURES 0), and only the tests for what you touched. No full scenario list locally. Never skip, loosen or delete a test.
Standing rules: PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md on claude/integration. Touch-first, table-driven, optional validated save fields, revert note in the module header. Push WIP every 30 minutes. No em dashes. Do not rebalance ops 1 to 6, and change no oxygen, hull, combat or detection rule. Do not commit generated .uid files integration does not track, or .import line-ending churn. Windows: see docs/DESKTOP_HANDOFF.md.

## Task (plain language)
Today exactly one grant exists (op 1 gives the Tele lens, game/src/campaign/early_reward/reward_table.gd). Make the table hold three grants before op 7, so the Fittings screen offers a real choice by op 4:
1. Op 1: quietus_tele_lens (unchanged).
2. Op 3: quietus_baffles (Quietus acoustic baffles, PROPULSION mount: reduces propulsion sound by 45% at the same speed). Teaches hiding before the layered ops 4 to 6.
3. Op 5: low_light_back (Low-light film back, OPTICS mount: an 8 second still exposure sharpens dark subjects without a flash). It shares the OPTICS mount with the Tele lens, so the player must choose between reach and darkness. That conflict is intentional and gives the early fittings a real trade-off.
If any of these cannot be granted cleanly (mount, power or an existing op 3 or op 5 rule), pick the nearest existing module that keeps one hiding choice and one photographic choice, and say what you swapped in Completion.
Each grant: announced as NEW FITTING in the debrief, appears in Fittings unequipped with its one-line explanation, optional gating from the Priced Shots design still holds (every operation finishable bare), granted once through the existing optional validated save field extended to a list. Existing saves keep what they already got.
Tests: each grant occurs once and persists through save and reload; both OPTICS items cannot be equipped together; Fittings shows all three by real touch at both Fold7 shapes; the ops 1 to 6 journeys still win bare with the same results; flag off gives today's behavior.

Numbering warning: the table's "operation":1 is an operation id, and cold review 3 observed the Tele lens granted after PLAYER op 2 (player number = id + 1). Check the actual trigger and apply the pattern consistently. The intent is: one grant after the first, third and fifth player operations' debriefs if the first grant is really after op 1, or after player ops 2, 4 and 6 if the existing grant stays where it is. Keep the existing grant where it is and place the new two two operations apart after it, all before player op 7.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-early-rewards-2

## Files you may edit
The early_reward module, its table and tests, the narrow seams it already uses.

## Files you must not touch
Simulation, hardware rules, opening balance, story text.

## What done looks like
Three grants after ops 1, 3 and 5, visible and equippable in Fittings, bare play unchanged, tests green, CI green on the exact head.

## Return
PR into claude/integration. Merge per the line above; mark DONE and update the board.

## Completion
(Codex fills this in.)


SUITE RANK BLOCK (Claude, 24 Oct): this handoff's new suites use local 231.. and CI 255.. (read suites.txt before committing and validate with scripts/toolchain/check-suites.py).