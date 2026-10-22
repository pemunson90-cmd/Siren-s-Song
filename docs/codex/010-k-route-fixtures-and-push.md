# Handoff 010: land the combat lane (fix the five failing authored-route tests)

Status: DONE
Claimed at: 2026-10-22 01:05:01 UTC
Claimed by: codex
Finished at: 2026-10-21 10:37 PM Eastern (PR 64 merged by Claude)

Precondition: none. Replaces blocked 005. Read the Completion section of 005 first; it is your own evidence.
Codex may merge: yes, after green guidance and game-smoke on the exact head and a mergeable PR.
Note: handoff 004 (F1 front end) is done by Claude as PR 61 and 003/006 are done; do not touch them.

## Pat's ruling (22 Oct)
The one-shot beam and collision damage are authored and stay as implemented. The failing journeys are a test-route problem, not a reason to weaken combat. Claude authorizes the scope below.

## Task
1. Push your local combat work (head 59a75fa, branch claude/lane-k-combat; merge fresh origin/claude/integration first, now including PRs 55 to 62 and likely 61 and 63; no history rewrite). If the push fails because a Claude worker's old WIP is on the branch, push to claude/lane-k-combat2 instead.
2. Fix the five failing authored routes by changing ONLY test route fixtures so bare Quietus (no finite tools, default hull) finishes while the beam is lethal: ops 4 (opening_depth_journeys, opening_depth_policy_ui_tests), 8 (shelf_habitat_journey_tests), 12 (concealed_harbour_journey_tests), 19 campaign-linked bare return (glass_reach_journeys). Fix means: route around enemy sight lines, wait out patrols, use cover, depth bands, terrain, braking or turns to break the lock, whichever the layout physically offers. If an op genuinely has no bare-Quietus route that survives a lethal beam, do NOT edit encounters or numbers: stop on that op and report exactly why, with the geometry, so Pat can decide.
3. Probe, hull values, detection, threat logic, sweeper (still on hold), story and campaign tables: do not touch.
4. Rerun import, core and the scenarios for the five routes you changed plus the combat and collision suites (GitHub runs the full list; see README testing note), then the pressure probe for ops 14 to 29 on the final head, and put the new table in your completion note.
5. Open a PR into claude/integration, wait for guidance and game-smoke, merge if green.

## Return
Completion note: PR link, per-op result for the five routes (fixed, or blocked with geometry), final scenario results, new pressure table, anything for Pat.

## Completion

Implementation and measurements are finished. PR 64 is open and mergeable on the submitted head as last checked. Guidance, import and core checks have passed in GitHub; the full scenario step is still running. Status remains CLAIMED until that gate finishes and the authorized merge can be performed. Claude can review the complete evidence below now.

PR: https://github.com/pemunson90-cmd/Siren-s-Song/pull/64
CI: https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/39708840237
Measured and submitted head: f1ed21ac706d62742d7eae921f19dcfe6dbb3e44.

Published the existing combat work after merging fresh integration. The authored lethal ordinary beam, collision damage and warning remain intact. This handoff adds only five test-route fixture fixes. No production rules, probe, hull values, detection, sweeper, story, campaign tables or assertions were loosened. Sweeper remains on hold.

All five fixtures are fixed with default hull and no finite tools:
- Operation 4 model: western archive vantage, 103.07 seconds, 69.18 hull; opening suite CHECKS 48 FAILURES 0.
- Operation 4 actual touch: same western vantage at both screen shapes, 102.83 seconds, 69.20 hull; opening touch suite CHECKS 404 FAILURES 0.
- Operation 8: deep approach/withdrawal and middle-depth work/recovery, 99.92 seconds, 100 hull. Original faster-than-quiet comparison preserved; shelf suite CHECKS 33 FAILURES 0.
- Operation 12: silent shelf returns below the patrol turn; service 247.58 seconds and baffle 249.72 seconds, both 100 hull. Deep controls also pass; harbour suite CHECKS 43 FAILURES 0.
- Operation 19: shallow return through the western reef mouth. Campaign-linked journey 150.22 seconds, 86.50 hull; default closed-gate diagnostic also finishes at 182.55 seconds, 86.67 hull. Glass suite CHECKS 70 FAILURES 0. The middle reef gate is solid at every depth when closed, so explicitly using the west mouth prevents the scripted route from stalling.

Local import passed. Core CHECKS 794 FAILURES 0. Requested seven suites: 48/0, 404/0, 33/0, 43/0, 70/0, combat 17/0, collision 20/0. These passed on 0ab1f87; the only subsequent change was the Glass fixture's west-mouth waypoints, followed by clean import and the full Glass suite again at 70/0. Production and other suites do not depend on that fixture. The hosted checks validate the exact final head. The obsolete broad local scenario run was stopped when the README changed; it is not claimed as a full local pass.

Final pressure measurements: all 64 operation/policy rows complete and report integrity checks pass. 56 wins, 7 combat losses, one controller_route_rejected (operation 16 drone-heavy). Cautious and Quietus-only each finish 16/16; aggressive 14/16; drone-heavy 10/16 plus five losses and that controller finding. Quietus-only minimum hull is 19.05. Operation 16 is a controller/chart-route finding, separate from a combat loss. No probe changes were made to hide it. Raw outputs remain outside Git at /tmp/k10-pressure-final; earlier measurements remain separate.

Each table cell is result/outcome; hull remaining; seconds; drone losses; seconds locked; beam seconds.

operation | cautious | aggressive | drone_heavy | quietus_only
--- | --- | --- | --- | ---
14 | win/won; 100.00; 139.92; 0; 0.00; 0.00 | win/won; 100.00; 93.55; 0; 0.00; 0.00 | win/won; 100.00; 139.92; 2; 0.00; 0.00 | win/won; 100.00; 139.92; 0; 0.00; 0.00
15 | win/won; 6.92; 161.87; 0; 0.00; 0.00 | loss/lost; 0.00; 49.40; 0; 1.45; 0.00 | loss/lost; 0.00; 74.68; 0; 0.00; 0.00 | win/won; 19.05; 161.62; 0; 0.00; 0.00
16 | win/won; 100.00; 151.22; 0; 0.00; 0.00 | win/won; 78.00; 101.87; 0; 1.00; 0.00 | controller finding/controller_route_rejected; 100.00; 37.95; 0; 0.00; 0.00 | win/won; 100.00; 151.22; 0; 0.00; 0.00
17 | win/won; 100.00; 220.78; 0; 0.00; 0.00 | win/won; 100.00; 144.77; 0; 1.00; 0.00 | win/won; 100.00; 220.78; 2; 30.33; 0.00 | win/won; 100.00; 220.78; 0; 0.00; 0.00
18 | win/won; 100.00; 119.07; 0; 0.00; 0.00 | win/won; 100.00; 75.17; 0; 0.00; 0.00 | win/won; 19.89; 120.07; 0; 0.00; 0.00 | win/won; 100.00; 119.07; 0; 0.00; 0.00
19 | win/won; 74.33; 183.92; 0; 0.00; 0.00 | loss/lost; 0.00; 46.37; 0; 2.45; 0.00 | win/won; 12.06; 184.67; 2; 3.37; 0.00 | win/won; 86.67; 183.67; 0; 0.00; 0.00
20 | win/won; 45.00; 85.57; 0; 0.00; 0.00 | win/won; 90.93; 54.90; 0; 0.00; 0.00 | win/won; 53.08; 85.57; 0; 0.00; 0.00 | win/won; 45.00; 85.57; 0; 0.00; 0.00
21 | win/won; 100.00; 170.38; 0; 1.03; 0.00 | win/won; 100.00; 111.28; 0; 2.85; 0.00 | loss/lost; 0.00; 125.57; 1; 5.02; 0.02 | win/won; 100.00; 170.38; 0; 1.03; 0.00
22 | win/won; 81.16; 264.70; 0; 0.00; 0.00 | win/won; 64.97; 215.62; 0; 0.00; 0.00 | win/won; 2.94; 264.97; 0; 0.00; 0.00 | win/won; 94.60; 264.42; 0; 0.00; 0.00
23 | win/won; 45.00; 209.97; 0; 0.00; 0.00 | win/won; 100.00; 134.77; 0; 0.00; 0.00 | win/won; 1.53; 210.72; 0; 0.00; 0.00 | win/won; 45.00; 209.97; 0; 0.00; 0.00
24 | win/won; 100.00; 305.47; 0; 0.00; 0.00 | win/won; 93.87; 252.52; 0; 0.00; 0.00 | loss/lost; 0.00; 99.68; 0; 0.00; 0.00 | win/won; 100.00; 305.47; 0; 0.00; 0.00
25 | win/won; 69.82; 233.17; 0; 0.00; 0.00 | win/won; 45.78; 172.07; 0; 0.00; 0.00 | loss/lost; 0.00; 186.48; 0; 0.00; 0.00 | win/won; 94.60; 232.38; 0; 0.00; 0.00
26 | win/won; 75.14; 168.72; 0; 0.00; 0.00 | win/won; 50.98; 104.43; 0; 0.00; 0.00 | win/won; 58.05; 169.00; 0; 0.00; 0.00 | win/won; 100.00; 168.20; 0; 0.00; 0.00
27 | win/won; 81.85; 153.65; 0; 0.00; 0.00 | win/won; 65.66; 121.70; 0; 0.00; 0.00 | win/won; 36.23; 154.17; 0; 0.00; 0.00 | win/won; 95.24; 153.37; 0; 0.00; 0.00
28 | win/won; 82.51; 135.65; 0; 0.00; 0.00 | win/won; 66.33; 109.27; 0; 0.00; 0.00 | win/won; 38.91; 136.43; 0; 0.00; 0.00 | win/won; 95.93; 135.38; 0; 0.00; 0.00
29 | win/won; 45.00; 246.97; 0; 0.00; 0.00 | win/won; 100.00; 149.27; 0; 0.00; 0.00 | loss/lost; 0.00; 144.40; 0; 0.00; 0.00 | win/won; 45.00; 246.97; 0; 0.00; 0.00

These are single scripted-policy runs using source-known routes, default history, endurance and no fittings. They are not human play, balance proof or enjoyment evidence. Ordinary lock/beam measurements omit industrial attack and collision pressure; drone losses can include battery exhaustion. No APK or device play. No known industrial beam recipient seam regression surfaced in the focused evidence, but these runs cannot prove its absence in every situation.

No file outside this handoff's ownership needed editing. Recommend Claude review the landed combat/route evidence and choose the next handoff; sweeper design remains held pending its separate decision.
