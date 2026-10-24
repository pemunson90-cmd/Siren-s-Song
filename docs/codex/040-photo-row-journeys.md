# Handoff 040: PHOTO ROW JOURNEYS, play evidence for the 14 campaign photo rows under live Sirens

Status: OPEN
Assigned to: codex (Pat split the queue 24 Oct; Codex takes this when Pat says continue)
Claimed at:
Claimed by:
Finished at:

Precondition: none (tests, and small data fixes only if a bug is proven).
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (CHECKS N FAILURES 0), and only the tests for what you touched. No full scenario list locally; GitHub game-smoke runs it. Never skip, loosen or delete a test.
Standing rules: PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md on claude/integration. Touch-first, self-contained, tests beside code. Push WIP every 30 minutes. No em dashes. Never change combat, beam, collision, damage, hull or Siren sight/hearing rules. Do not commit generated .uid files that integration does not already track, and do not commit line-ending churn in .import files. Windows: see docs/DESKTOP_HANDOFF.md for the Windows Godot build.

## Task (plain language)
Source: docs/design/COLD_REVIEW_3.md finding F10. The 14 campaign photo rows (ops 7 to 29) are tested only in campaign_photo_rows_tests.gd (13 of the 14 row keys appear nowhere else; relay_blink also appears as fixture data in route_map_tests.gd, not as a play test). Its fixture stages the craft on clear water and its comment says "Campaign travel remains covered separately". No test backs that comment. The critic's geometry-only probe (Sirens removed) captured 11 of 14. Op 8's tender door gave "Record secured" but its captured flag still read false at 10 s. Op 9's relay lamp needs a 28 s hold (inconclusive at 10 s). Op 12 stalls on a straight route, but a 16-step path on a 100 m grid exists.
1. For each of the 14 rows add one journey using the existing patient_play helper, live Sirens on, that reaches the viewpoint through the real operation and captures the row. Follow the existing journeys' pattern: one test per row, small files.
2. Investigate the op 8 captured-flag mismatch and the op 9 hold time. Fix only if it is a bug in the row data or flag handling; otherwise report.
3. If a row cannot be reached fairly under live Sirens, do not change Siren behavior. Record the row, the blocker and the nearest evidence in Completion for Pat.
4. Replace the "covered separately" comment with a pointer to the new journeys.
Keep each test within the CI time budget and add them to game/tests/suites.txt in the right order.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-photo-row-journeys

## Files you may edit
New journey test files, suites.txt, the one comment, and row data or flag handling only if item 2 proves a bug.

## Files you must not touch
Siren, beam, detection, damage, hull and collision rules; story text.

## What done looks like
14 journeys pass (or are honestly reported unreachable with evidence), suites.txt updated, CI green on the exact head.

## Return
PR into claude/integration. Merge per the line above; mark DONE and update the board.

## Completion
(Codex fills this in.)


SUITE RANK BLOCK (Claude, 24 Oct): Codex's new suites use local 240.. and CI 260.. so they cannot collide with Claude's blocks (local 228-239, CI 251-259). Validate with scripts/toolchain/check-suites.py before committing.
