# Handoff 010: land the combat lane (fix the five failing authored-route tests)

Status: OPEN
Claimed at:
Claimed by:
Finished at:

Precondition: none. Replaces blocked 005. Read the Completion section of 005 first; it is your own evidence.
Codex may merge: yes, after green guidance and game-smoke on the exact head and a mergeable PR.
Note: handoff 004 (F1 front end) is done by Claude as PR 61 and 003/006 are done; do not touch them.

## Pat's ruling (22 Oct)
The one-shot beam and collision damage are authored and stay as implemented. The failing journeys are a test-route problem, not a reason to weaken combat. Claude authorizes the scope below.

## Task
1. Push your local combat work (head 59a75fa, branch claude/lane-k-combat; merge fresh origin/claude/integration first, now including PRs 55 to 62 and likely 61 and 63; no history rewrite). If the push fails because a Claude worker's old WIP is on the branch, push to claude/lane-k-combat2 instead.
2. Fix the five failing authored routes by changing ONLY test route fixtures so bare Quietus (no finite tools, default hull) finishes while the beam is lethal: ops 4 (opening_depth_journeys, opening_depth_policy_ui_tests), 8 (shelf_habitat_journey_tests), 12 (concealed_harbour_journey_tests), 19 campaign-linked bare return (glass_reach_journeys). Fix means: route around enemy sight lines, wait out patrols, use cover, depth bands, terrain, braking or turns to break the lock, whichever the layout physically offers. If an op genuinely has no bare-Quietus route that survives a lethal beam, do NOT edit encounters or numbers: stop on that op and report exactly why, with the geometry, so Pat can decide.
3. Probe, hull values, detection, threat logic, sweeper (still on hold), story and campaign tables: do not touch.
4. Rerun import, core, and every CI scenario on the final head (rerun timeouts alone), then the pressure probe for ops 14 to 29 on the final head, and put the new table in your completion note.
5. Open a PR into claude/integration, wait for guidance and game-smoke, merge if green.

## Return
Completion note: PR link, per-op result for the five routes (fixed, or blocked with geometry), final scenario results, new pressure table, anything for Pat.

## Completion
(Codex fills this in.)
