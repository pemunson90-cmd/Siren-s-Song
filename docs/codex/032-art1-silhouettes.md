# Handoff 032: ART1, Siren, Quietus and structure silhouettes (procedural, Pat judges)

Status: OPEN
Claimed at:
Claimed by:
Finished at:

Precondition: handoff 017 DONE.
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (must end CHECKS N FAILURES 0), and only the tests for what you touched. No full scenario list locally; GitHub runs it. After any red game-smoke also run the later CI-list tests locally. Never skip, loosen or delete a test.
Standing rules: read docs/codex/PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md on claude/integration (STANDING DELEGATION, STANDING ENGINEERING RULE, INPUT PRIORITY: Android touch-first, 48 dp, Android Back as Escape, keyboard fallback only). Self-contained module, one narrow seam, numbers in a data table, optional validated save fields, a revert note in the module header, tests beside it. Push WIP to your lane branch at least every 30 minutes. No em dashes. Story text stays 1 to 2 line placeholders. Never change combat, beam, collision, damage, hull or Siren sight/hearing rules. Do not commit generated .uid files that integration does not already track.

## Task (plain language)
The spec art direction is layered abyssal basalt, cyan/amber industrial structures, charcoal Quietus, angular ray/serpentine red-lit Sirens, legible sensor and evidence distinction. Improve the in-game drawing of Quietus, the two drones, the Siren roles (patroller, sentinel, hunter, sweeper), and the factory structures using procedural drawing in one self-contained module (game/src/presentation/art/ with a data table of shapes, palettes and glow). Priorities: instantly readable silhouettes at small size on a phone, role distinguishable by shape not just color (accessibility), red-lit angular Sirens that feel dangerous, a clear lamp cone for the camera. Keep draw cost low (no per-frame allocations); check with the performance test from handoff 015. Provide before/after screenshots at the two Fold7 shapes in Completion for Pat to judge; he decides. Keep the old drawing reachable behind a table switch so it can be reverted.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-art1

## Files you must not touch
Gameplay rules, hit shapes and collision geometry (draw only), story.

## What done looks like
Before/after screenshots, no performance regression, old look restorable by one switch.

## Return
PR into claude/integration; merge per the line above; mark DONE and update the board.

## Completion
(Codex fills this in: what changed, PR link, branch and last pushed SHA, test results, unverified items, files outside ownership needed, recommended next.)
