# Handoff 039: CONSEQUENCE LINES, replace the echoed brief in debriefs for ops 15 to 30

Status: OPEN
Claimed at:
Claimed by:
Finished at:

Precondition: none (presentation work; do not collide with an open claim on the debrief files).
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (CHECKS N FAILURES 0), and only the tests for what you touched. No full scenario list locally; GitHub game-smoke runs it. Never skip, loosen or delete a test.
Standing rules: PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md on claude/integration. Touch-first (48 dp, Android Back = Escape), self-contained module, one narrow seam, numbers in a data table, optional validated save fields, a revert note in the module header, tests beside it. Push WIP every 30 minutes. No em dashes. Story text stays 1 to 2 line placeholders. Never change combat, beam, collision, damage, hull or Siren sight/hearing rules. Do not commit generated .uid files that integration does not already track, and do not commit line-ending churn in .import files. Windows: see docs/DESKTOP_HANDOFF.md for the Windows Godot build.

## Task (plain language)
Source: docs/design/COLD_REVIEW_3.md finding F4. For every operation id 14 to 29 the debrief "record" text is just the briefing text echoed back (16 of 16). Journeys for ops 22 to 29 also all end with the same message ("Archive recovered / CHOIR SOUTH RECOVERY"), and five Glass ops with "SOUTH REACH RECOVERY".
Add one short consequence line per operation, shown above the existing record text, built only from facts the game already records (for example what was recovered, who was landed, a plant or route state the run already knows). If no recorded fact exists, use a fixed one-line placeholder from a data table keyed by operation id. One line each. No new story, characters or ending content; these are placeholder consequence lines, flagged for Pat to rewrite.
Do not change ops 1 to 14 debriefs, ending logic or any rule.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-consequence-lines

## Files you may edit
A new small module (table plus a function returning the line for an operation id and its result), one narrow call from the debrief presentation, and tests.

## Files you must not touch
Simulation, rules, ending logic, save schema, camera.

## What done looks like
Debriefs for ids 14 to 29 show a distinct line (a test asserts no two adjacent operations show the identical line and that the line is not contained in the brief); lines fit by real touch at both Fold7 shapes without clipping; a flag in the table turns the feature off; no em dashes.

## Return
PR into claude/integration. Merge per the line above; mark DONE and update the board.

## Completion
(Codex fills this in.)
