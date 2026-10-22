# Handoff 029: ONBOARD2, short briefings for ops 4 to 29 with a field manual page

Status: OPEN
Claimed at:
Claimed by:
Finished at:

Precondition: handoff 017 DONE (it is).
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (must end CHECKS N FAILURES 0), and only the tests for what you touched. No full scenario list locally; GitHub runs it. After any red game-smoke also run the later CI-list tests locally. Never skip, loosen or delete a test.
Standing rules: read docs/codex/PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md on claude/integration (STANDING DELEGATION, STANDING ENGINEERING RULE, INPUT PRIORITY: Android touch-first, 48 dp, Android Back as Escape, keyboard fallback only). Self-contained module, one narrow seam, numbers in a data table, optional validated save fields, a revert note in the module header, tests beside it. Push WIP to your lane branch at least every 30 minutes. No em dashes. Story text stays 1 to 2 line placeholders. Never change combat, beam, collision, damage, hull or Siren sight/hearing rules. Do not commit generated .uid files that integration does not already track.

## Task (plain language)
ONBOARD1 shortened the op 1 briefing to a goal plus one danger line, with the full rules behind an optional FIELD MANUAL button (ops 1 to 3); ops 4 and up still have long briefings. Apply the same pattern to ops 4 to 29 with the existing onboarding machinery: briefing text becomes a goal plus one danger line plus the Priced Shots photo-problems line; long rules move to the field manual page. Keep everything touch-first and readable at large text size on both Fold7 shapes. All text is 1 to 2 line placeholders; do not write new story; keep existing facts accurate (do not drop a rule the player needs, move it to the manual). Add data rows, not new engines.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-onboard2

## Files you must not touch
Operation logic, rules, story text beyond shortening, photo and sweeper modules.

## What done looks like
Every op 4 to 29 briefing fits above the fold at large text on both shapes (screenshot three in Completion); the manual page holds the removed text; tests pass.

## Return
PR into claude/integration; merge per the line above; mark DONE and update the board.

## Completion
(Codex fills this in: what changed, PR link, branch and last pushed SHA, test results, unverified items, files outside ownership needed, recommended next.)
