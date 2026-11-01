# Item 139: Bare Quietus meets the Sirens on ops 2, 16, 17 and 20

Goal (player): Flown by hand, bare, Quietus SILENT, ops 2 (Blackwater custody), 16, 17 and 20 (Glass Reach) put the Quietus in real contact with the Sirens (Hunt 20 or more, or a received lock) instead of a quiet walk; they stay finishable on STANDARD and ACCESSIBLE.
Why now: item 127 R2 table (PR 241): those four ops peak at Hunt 9 to 17 with 0 locks, so only 5 of 9 hand-flown ops meet Pat's 3/4 bar (Pat 28 Oct: fleet must matter; an op that plays like a walking simulator is a defect).
Class: sim
Areas: campaign.ops
Files: game/src/campaign/opening_depth_operations.gd, game/src/campaign/glass_reach_operations.gd, game/tests/bare_contact_tests.gd
Serial zones touched: none
Depends on: 127
Protected rules touched: none (Siren and role senses, beam, lock timing, collision and damage stay as they are; only patrol placement, routes, timing and objective layout in those op definitions change)

## Acceptance test (fails before, passes after)
bare_contact_tests: hand-pilot each of ops 2, 16, 17, 20 bare with Quietus SILENT on STANDARD and ACCESSIBLE; each reaches Hunt 20 or more or receives a lock, and still finishes. Fails today on all four.

## Do not
Change any protected rule or constant (protected_rules_tests must stay green). Make an op unfinishable by hand. Rely on oxygen pressure alone.

## Evidence (class cap, PROCESS.md section 5 on claude/workflow-v2)
R2 table for the four ops before and after (time, Hunt peak, locks, hull, O2, finished), plus one line that the other ops' voyage hashes are unchanged.

## Builder notes
Branch item/139-bare-contact from origin/claude/integration after 127 merges. Preferred provider: claude:opus then codex.
Checks before push: import, core, the affected suites, check-suites, canaries.
