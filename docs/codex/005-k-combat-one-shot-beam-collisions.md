# Handoff 005: one-shot beam and collision damage

Status: BLOCKED
Claimed at: 2026-10-21 22:57:52 UTC
Claimed by: codex
Finished at: 2026-10-22 00:00:22 UTC

Precondition: run `git log -1 --format=%cr origin/claude/lane-k-combat`. If the newest commit is under 90 minutes old, a Claude worker may still be active on this branch: do not claim, skip to the next OPEN handoff, and if none remain tell Pat.
Codex may merge: yes, same rule, after you open the pull request into claude/integration.

## Task (plain language)
Pat decided (Option A plus collisions). (1) When a Siren's beam fires at Quietus it destroys Quietus outright, like V7's vaporize. Keep the existing 4 second lock build (LOCKING then BEAM) as the fair warning, and keep every way to break it (losing line of sight, EMP, knockdown, cover, braking or turning). Replace the beam hull drain (hull=maxf(0,hull-dt*18) near game/src/simulation/simulation.gd line 1160) with an immediate loss when the beam fires on unit 0, outcome text VAPORIZED. Drones still die to a beam at once. (2) Collisions hurt: Quietus takes hull damage when it hits terrain or hulls, scaled by impact speed. Slow bumps cost little, hard fast impacts cost real damage, a single normal-cruise hit never destroys Quietus. Add a short hit cooldown so grinding is not a per-frame drain. Keep V7's slowdown (speed cut to 25 percent). Show collision damage in the existing hull readout. Other damage sources stay (interceptor burst 20, pressure patch 8 per second, sonar sweeper 22). Pat's target: a punishing stealth game that rewards careful planning, route execution and timing of tools and equipment, neither impossibly hard nor painfully easy. Autopilot strength gets tuned later by Pat, so put the numbers in clearly named constants at the top of the file with a comment. A Claude worker started this and a WIP snapshot is on the branch.

Do not change detection or suspicion rules, drone rules or any story text. Update old tests that assumed the slow beam drain or no collision damage, narrowly, and say which and why. Authored bare-Quietus journeys for operations 0 to 29 must still finish; if one does not, report it instead of editing the route. Add a focused new test (beam kills on fire; a broken lock does not; fast collision damages, slow bump barely does; cooldown works) and register it in .github/workflows/gauntlet-pr-checks.yml.

## Added 21 Oct by Claude (Codex audit findings 1 and 5, Pat said continue the loop)
(a) Strike targeting (audit finding 5): DO NOT CHANGE. V7 Sirens have no sonar of their own; they notice by proximity plus line of sight and by hearing throttle noise and Quietus pings. The active-sonar sweeper enemy is a later addition and Pat is deciding whether it stays. Leave sonar_sweeper.gd untouched; only keep the reproduction (stationary Quietus 78 hull alone, 100 with a second craft) in your completion note.
(b) After the combat work lands on your branch, update the pressure probe (docs/codex/run_ci_scenarios.sh lists it; test files from lane X2). All four policies reject their first route in operation 14 at time zero because the controller assumes old map dimensions. Read dimensions from the operation data, rerun ops 14 to 29 for all four policies, and put the resulting difficulty curve table in your completion note. Probe files only; no tuning of game numbers, report them to Pat instead.

## Base and branch
Work on the existing branch `claude/lane-k-combat`. First `git fetch origin` and merge `origin/claude/integration` into it, resolving conflicts and keeping both sides. Do not rewrite history or force push.

## Files you may edit
The beam, lock, hull and collision parts of game/src/simulation/simulation.gd, the hull readout, new tests.

## Files you must not touch
Detection rules, drone rules, story text, campaign tables.

## What done looks like
Beam fires means Quietus is destroyed; collisions hurt as described; bare-Quietus journeys finish; all scenarios ok.

## Checks
Import, core tests, and `bash docs/codex/run_ci_scenarios.sh` all clean (every line ok). Machine may be slow: if a scenario times out, rerun it alone before concluding.

## Return
Push the branch, then open a pull request into claude/integration. Wait for GitHub's checks.
Pat decides design: do not alter anything beyond what is written here.

## Completion

Final-scope correction after fetching concurrent handoff update `70187b6`: sweeper changes are on hold. Final local head is `59a75fa89a54744064c773717f0b819008fabb64`, after restoring `sonar_sweeper.gd` byte-for-byte to integration, removing the new commitment test and its workflow entry. The recoverable patch `/tmp/k-local-review.patch` was regenerated. Existing reproduction: stationary Quietus takes the 22-point strike alone (78 hull), but remains at 100 hull when another craft's echo replaces and resets the strike. That rule is left unchanged pending Pat. Only beam/collision production changes remain. The current workflow has 70 scenarios, with two new suites, not the prior 71 with the withdrawn sweeper suite.

Final head 59a75fa import is clean, core reports `CHECKS 759 FAILURES 0`, combat reports `COMBAT RULES CHECKS 17 FAILURES 0`, and collision reports `COLLISION BOUNDARIES CHECKS 20 FAILURES 0`. Logs: `/tmp/k-hold-import.log`, `/tmp/k-hold-core.log`, `/tmp/k-hold-combat.log`, `/tmp/k-hold-collision.log`.

The detailed 71-scenario and 64-trial results below are historical evidence from before this hold correction, not verification of final head 59a75fa. No full scenario or pressure rerun on the final restored-sweeper head has been completed. The pressure table must be rerun before being used to assess the current branch. No code push or PR was made. The later handoff 009 was not claimed during this active task.

BLOCKED. Pat's chosen combat rules are implemented locally, but the required authored bare-Quietus returns do not all finish. No routes were changed. README step 4 requires every CI scenario to be ok before pushing code, and this handoff explicitly says to report failed authored routes instead of editing them. Consequently no lane push, pull request, hosted CI run or merge was made. There is no CI run link for this local head.

The pre-hold verification head was `623427ec79f83d644c97da5cb6c23a12768b8eb2` in `/workspace/Sirens-combat`, branch `claude/lane-k-combat`. Integration `d09378c` was merged without rewriting history. A complete net patch against that integration is `/tmp/k-local-review.patch`. At that pre-hold verification head, production and probe source was byte-identical to `75dc0ad6eb863db66cf4cea6e377ca726162aa08`; the two subsequent commits change tests only.

Quietus now loses immediately when the ordinary beam fires after the existing warning. Broken locks and finite defensive tools still work, drones retain instant beam death, and a simultaneous drone loss cannot overwrite VAPORIZED. Quietus terrain and hull impacts have named speed, damage and cooldown constants, retain quarter-speed slowdown, and do not turn chart navigation stops into impacts. Relative hull movement includes incoming craft and respects depth. Existing overlapping craft can separate without permanent exclusion. Current-relative velocity retains the impulse. Other damage amounts and detection rules were not tuned. The existing hull readout already consumes hull changes. Cooldown timestamps are optional on restore; old snapshots remain accepted without migration or a schema version change.

The withdrawn sweeper implementation kept an armed target and countdown through later echoes without changing detection. It is no longer present on the final local head, in accordance with the concurrent hold instruction.

Import was clean. Core: `CHECKS 759 FAILURES 0`. All 71 registered CI scenarios ran once to completion: 64 ok, seven FAIL, zero ERR. Two failures were obsolete collision assumptions, fixed narrowly and rerun: blackwater delivery `CHECKS 63 FAILURES 0` (same route wins at 30.03s with 76.72 hull, all craft alive, original spent EMPs), and loadout frames `CHECKS 69 FAILURES 0` (move a parked drone aside in the isolated speed fixture, preserve the speed requirement and require undamaged hulls). Thus 66 scenarios have passing evidence and five remain failing. The full 71-scenario command was not rerun after those two test-only corrections; each corrected script was run in full. Raw full run: `/tmp/k-final-scenarios.log`; targeted reruns: `/tmp/k-blackwater-delivery-final.log` and `/tmp/k-loadout-final.log`.

Remaining failures, deliberately left intact:

- `opening_depth_journeys`: 48 checks, 2 failures. Operation 4 Well uncertain/depth return loses at 88.92s after obtaining records.
- `opening_depth_policy_ui_tests`: 404 checks, 4 failures. The same operation 4 physical return fails at both tested viewport sizes.
- `shelf_habitat_journey_tests`: 28 checks, 11 failures. Operation 8 common bare-Quietus route loses at 54.62s, with beam firing and downstream progress unavailable. The quiet route passes at 192.10s with 100 hull.
- `concealed_harbour_journey_tests`: 43 checks, 4 failures. Operation 12 shelf/service and shelf/baffle no-tools returns lose at 155.38s and 157.23s. Deep and cast-off alternatives pass.
- `glass_reach_journeys`: 70 checks, 3 failures. The campaign-linked operation 19 bare return is VAPORIZED at 83.95s. The other seven Glass journeys pass. This campaign-linked trial differs from the default-history pressure trial below.

An interim collision implementation also broke operation 5 and waypoint behavior; that implementation was repaired, without changing those assertions. Those are not remaining blockers. Final core and opening journey evidence confirms operation 5 finishes.

New focused CI coverage passes: combat 17 checks, collision boundaries 20 checks, sweeper commitment 33 checks, all zero failures. It covers warning and lock break, finite EMP, beam victim identity, cooldown and restore/pause, terrain versus chart stops, depth, currents, incoming hulls and overlapping waypoint travel. Additional checks pass: industrial ordinary-beam endpoint seam 16/0, beam emission 11/0, T pressure regression 31/0. The known industrial victim/contact endpoint seam did not reappear in that focused test. Final measurement snapshots were valid for all 64 pressure trials.

Existing tests were changed only for deliberately changed assumptions: beam emission, depth sonar and opening depth expect the firing beam to be fatal; wake crossing stops its intended losing control at VAPORIZED rather than issuing commands after death; T pressure separately verifies the unchanged 20-point interceptor burst and the subsequent physical ram; blackwater delivery attributes each new hull loss to a bounded physical collision; loadout frames isolates speed from a parked hull. No winning authored route was edited. The pre-hold workflow registered three new focused suites; the current workflow retains only combat and collision coverage. No test was deleted or skipped.

The pressure probe now reads operation dimensions and replays the current authored Glass courses, including depth, work and exit steps. All 64 operation/policy pairs are present and report integrity passes. Totals: 54 wins, nine losses and one controller finding. Cautious wins 16/16; aggressive 14/16; drone-heavy 9/16 with six losses and one controller rejection; Quietus-only 15/16, losing operation 19. No game numbers were tuned from these results. Quietus-only safety is not uniform: operation 15 finishes with 19.05 hull, operation 19 loses, and several later operations still show no ordinary lock time despite collision or industrial damage. Drone-heavy is substantially less robust under this particular scripted controller.

Operation 16 drone-heavy rejects a Quietus waypoint at 37.95s. A bounded diagnostic confirms selected unit 0, matching deep geometry and chart, physically clear destination (1400,1560), but an uncertified chart cell adjacent to a measured return is conservatively blocked. This is a controller/navigation-knowledge finding, not a combat loss or a selection-band mismatch. No navigation code was changed. Diagnostic: `/tmp/k-op16-diagnose-fixed.log`.

These are single scripted trials using endurance, no fittings and default history, not human play, balance proof or enjoyment evidence. Policies use source-known authored routes and react only to fresh observed contacts. Lock and beam seconds measure ordinary enemy targeting and do not cover every industrial attack or collision. Drone losses include exhaustion; causes are not separately classified. No APK, device play, human play or hosted exact-head checks were verified. Continuous simulation, tactical pause and finite tools were retained. No campaign tables, story, equipment or save schema files were edited.

Pressure artifacts remain outside Git in `/tmp/k-pressure-final/`: `rows.json`, `rows.csv`, `summary.txt`, `difficulty-curve.md`, `source.txt` and `op16-controller-finding.txt`. All rows measure production/probe source 75dc0ad; interrupted operation 17 was replaced with a complete same-source rerun, with no interim-source results mixed in.

Source: `75dc0ad6eb863db66cf4cea6e377ca726162aa08`

Each cell: result/outcome; hull; seconds; drone losses; locked seconds; beam seconds):
operation | cautious | aggressive | drone_heavy | quietus_only
--- | --- | --- | --- | ---
14 | win/won; 100.00; 139.92; 0; 0.00; 0.00 | win/won; 100.00; 93.55; 0; 0.00; 0.00 | win/won; 100.00; 139.92; 2; 0.00; 0.00 | win/won; 100.00; 139.92; 0; 0.00; 0.00
15 | win/won; 6.92; 161.87; 0; 0.00; 0.00 | loss/lost; 0.00; 49.40; 0; 1.45; 0.00 | loss/lost; 0.00; 74.68; 0; 0.00; 0.00 | win/won; 19.05; 161.62; 0; 0.00; 0.00
16 | win/won; 100.00; 151.22; 0; 0.00; 0.00 | win/won; 78.00; 101.87; 0; 1.00; 0.00 | controller finding/controller_route_rejected; 100.00; 37.95; 0; 0.00; 0.00 | win/won; 100.00; 151.22; 0; 0.00; 0.00
17 | win/won; 100.00; 220.78; 0; 0.00; 0.00 | win/won; 100.00; 144.77; 0; 1.00; 0.00 | win/won; 100.00; 220.78; 2; 30.33; 0.00 | win/won; 100.00; 220.78; 0; 0.00; 0.00
18 | win/won; 100.00; 119.07; 0; 0.00; 0.00 | win/won; 100.00; 75.17; 0; 0.00; 0.00 | win/won; 19.89; 120.07; 0; 0.00; 0.00 | win/won; 100.00; 119.07; 0; 0.00; 0.00
19 | win/won; 48.76; 167.85; 0; 1.25; 0.00 | loss/lost; 0.00; 46.37; 0; 2.45; 0.00 | loss/lost; 0.00; 113.65; 2; 7.00; 0.00 | loss/lost; 0.00; 125.50; 0; 4.02; 0.02
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


Needed outside the permitted route-edit scope, and not touched: authored route definitions in `game/tests/opening_depth_journeys.gd`, `game/tests/opening_depth_policy_ui_tests.gd`, `game/tests/shelf_habitat_journey_tests.gd`, `game/tests/concealed_harbour_journey_tests.gd` and `game/tests/glass_reach_journeys.gd`. Narrow historical beam/no-collision test updates, workflow registration and probe repairs above were explicitly authorized by this handoff. The earlier sweeper edit was authorized when started and was fully withdrawn after the concurrent hold was fetched.

Recommended next: Pat decides whether to authorize narrow updates to those failed authored routes and UI counterparts while retaining the chosen combat rules. Then rerun import, core and every scenario, push only the combat lane, open its PR into integration, and require green guidance/game-smoke on the exact head before any permitted merge. Keep this code unmerged while the route checks remain red.

Pat clarified at completion that the beam and collision rules are authored and the test runs are the issue. Those combat rules remain implemented. Only the sweeper targeting change was withdrawn under the concurrent explicit hold. Do not treat failed historical routes as authorization to weaken combat. Further repeated test runs were stopped; next development should address the affected test-route fixtures within an authorized scope.
