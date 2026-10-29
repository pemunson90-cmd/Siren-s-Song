# Handoff 115: MAKE THE ONE-BAND THERMAL LAYER MATTER IN REAL OPS

Status: QUEUED (claude-lane)

Precondition: none of the files below claimed by another BOARD row; check `git worktree list`. Root owns 091 (audit) and EXP-PHOTO-INTENT: do not touch either.
Codex may merge: yes, into claude/integration only, after independent Sol6.1-high approval and green required checks on the exact head, merge commit.
Ruling: `docs/codex/PAT_RULINGS_2026-10-29.md` item 7 ("Should the thermal layer cover only one depth band, so picking a depth decides who can hear you? (Protected, your call.)" = "Yes (Recommended)"). Placements and numbers below are AI-DESIGNED.

## Why this exists
105 (PR219, draft, branch `claude/thermal-one-band`, recovery head ab94dd85) implemented the one-band layer correctly but was BLOCKED: only op 3 changed (DEEP win to loss) and no op had a best-depth reversal. The rule is fine; no op is laid out so the layer decides the route. Claude S7, 29 Oct.

## Task
1. Start from the 105 branch work (reviewed source), reconciled onto current claude/integration. Keep its rule, briefing and chart lines.
2. Pick two or three existing ops where the obvious route crosses Siren hearing (op 3 Foundry is one candidate; others from the 093 tables). In each, set the op's layer band and, only if needed, move existing guards or route geometry (copy the 096 method: guards on forced routes, earned discovery) so that:
   - the band holding the layer is the quiet way through, and
   - a plan that ignores the layer (wrong band) is heard and fails or takes clearly worse damage/lock, while the layer-band plan succeeds.
3. The briefing and chart must let a player find the layer band before committing (no hidden-information wins).

## Bar (QUEUE_S6 Siren-behaviour bar)
- At least two full ops, Quietus SILENT throughout, ordinary orders, where the best depth or the outcome differs because of the layer, shown before/after with both depths.
- Fleet table for every touched op plus controls 2, 14, 22, 30: STANDARD bare and equipped, ACCESSIBLE bare. Bare finishable on ACCESSIBLE and STANDARD; no op that met the Sirens in 094 to 097 stops meeting them; equipped clearly better than bare-after (time, or lock/hull with no big time cost).
- Protected rules beyond the layer untouched: sight 180/290 m, 4 s lock warning, beam, collision, damage, hull, V7 sweeper patrol shape, photography, endings.
- If the second attempt still has fewer than two causal ops, mark BLOCKED with numbers.

## Files you may edit
thermal layer code (from 105), op data for the chosen ops (band field, guard placement, route geometry), briefing/chart lines, tests, docs, shared registration lines.

## Files you must not touch
Anything not named above; files of other CLAIMED rows (check 113 and 111); mission_hud.gd photo functions.

## Checks
Import + core, the thermal suite from 105, a permanent suite asserting each chosen op's layer-band plan succeeds and wrong-band plan is heard, and affected suites only.

## Return
Close PR219 as superseded only after this merges (comment, do not delete the branch). New PR into claude/integration with the before/after tables; independent review; merge on green; close the BOARD row and add one LEDGER line.
