# Handoff 116: MAKE SIREN RADIO REPORTS MATTER IN REAL OPS

Status: QUEUED (claude-lane)

Precondition: none of the files below claimed by another BOARD row; check `git worktree list`. Root owns 091 (audit) and EXP-PHOTO-INTENT: do not touch either. Runs after 115 (both touch Siren sensing).
Codex may merge: yes, into claude/integration only, after independent Sol6.1-high approval and green required checks on the exact head, merge commit.
Ruling: `docs/codex/PAT_RULINGS_2026-10-29.md` item 6 ("On ops with 2+ patrolling Sirens, should they radio each other with a visible charge-up you can interrupt? (Protected, your call.)" = "Yes, 2+ patrollers (Recommended)"). Placements and numbers below are AI-DESIGNED.

## Why this exists
104 (PR220, draft, branch `claude/siren-reports`) implemented the interruptible report correctly but was BLOCKED: across 64 paired runs no number changed, because on current layouts the second Siren is never placed where a report about Quietus changes anything. Claude S7, 29 Oct.

## Task
1. Start from the 104 branch work (reviewed source, 3 s / 430 m candidate), reconciled onto current claude/integration (and 115 if merged).
2. Pick two or three existing ops with two or more patrollers. Only if needed, move existing guards or route geometry (copy the 096 method) so a completed report sends a second Siren to cover the player's exit or objective, while the charge-up stays visible and interruptible (break contact, Disrupt, Decoy).
3. Result wanted: a plan that lets the report complete fails or is clearly worse (lock, hull, time), and a plan that interrupts it (quiet break, drone Disrupt, decoy) succeeds. Interrupting must be possible bare (break contact) and easier equipped.

## Bar (QUEUE_S6 Siren-behaviour bar)
- At least two full ops, Quietus SILENT throughout, ordinary orders, where letting the report complete versus interrupting it changes the outcome, shown before/after.
- Fleet table for every touched op plus controls 2, 14, 22, 30: STANDARD bare and equipped, ACCESSIBLE bare. Bare finishable on ACCESSIBLE and STANDARD; no op that met the Sirens in 094 to 097 stops meeting them; equipped clearly better than bare-after.
- Protected rules beyond the report untouched (sight 180/290 m, 4 s lock warning, beam, collision, damage, hull, V7 sweeper patrol shape, photography, endings).
- If the second attempt still has fewer than two causal ops, mark BLOCKED with numbers.

## Files you may edit
Siren report code (from 104), op data for the chosen ops (guard placement, route geometry), chart cue drawing (not mission_hud.gd photo functions), event cue sound line, tests, docs, shared registration lines.

## Files you must not touch
Anything not named above; files of other CLAIMED rows (check 113 and 111); mission_hud.gd photo functions.

## Checks
Import + core, the radio suite from 104, a permanent suite asserting each chosen op's interrupt plan succeeds and let-it-complete plan is clearly worse, and affected suites only.

## Return
Close PR220 as superseded only after this merges (comment, do not delete the branch). New PR into claude/integration with the before/after tables; independent review; merge on green; close the BOARD row and add one LEDGER line.
