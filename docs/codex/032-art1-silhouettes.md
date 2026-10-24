# Handoff 032: ART1, Siren, Quietus and structure silhouettes (procedural, Pat judges)

Status: CLAIMED
Claimed at: 2026-10-24 18:33:15 UTC
Claimed by: codex
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


Claimed 24 October 2026, 2:33 PM Eastern, before implementation.
031 is verified DONE at actual integration ad841f69394eb4ade818794056e5ccac56f0bc0b
(PR127 merged after both exact ec23 checks and independent approval).
032 precondition017 is DONE. Code branch claude/lane-art1 will start from freshly
fetched actual integration. One implementation worker and independent reviewer.
Preserve existing art direction and all rules; no new story or SIREN TELL.
Provide source-matched old/new native pictures at both Fold7 shapes, real drawing
cost evidence alongside the simulation-only015 probe, and a single old-look switch.
Pat decides the actual artwork after the concrete candidate is ready. Do not merge
new artwork before that judgment. Next assigned task after032 is033 only.
