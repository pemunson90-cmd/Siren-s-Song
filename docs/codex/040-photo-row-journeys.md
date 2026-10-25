# Handoff 040: PHOTO ROW JOURNEYS, play evidence for the 14 campaign photo rows under live Sirens

Status: CLAIMED
Assigned to: codex (Pat split the queue 24 Oct; Codex takes this when Pat says continue)
Claimed at: 2026-10-25 19:51:09 UTC
Claimed by: codex
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

### Implementation plan,25October2026 Eastern

Goal: fourteen small launch-to-photo journeys with authored live Sirens, actual movement/depth/framing/camera commands and usable target-specific film. These are source-known technical routes, not first-exposure preference or full-campaign claims.

- Root owns a new RefCounted journey support file, suites.txt and the single inaccurate comment. Two implementation workers own disjoint sets of seven new per-row SceneTree entry points. The support records real elapsed time, distance, hull/oxygen, Siren count and film; each entry has its own exact summary prefix. No existing journey or patient_play helper is edited.
- Support API: new(op,key), go(point), depth(band), tick(seconds), command(name,args), focus(), target(), record_current() for a real required job, record() for the exact optional row, study(at,then,refuge_band) using patient_play.rehearsal_survives before the actual exposure, and finish(tree,prefix). Patient restore/depth preconditions and target/result identity are asserted separately because the existing helper returns true for some failed preparations.
- Every voyage starts at Sim.start's actual craft positions with original Sirens/terrain, baseline equipment and finite tools. Thirteen rows use endurance; the relay uses the publicly selectable disruption loadout with three EMP charges and100oxygen. No equipment entitlement fixture is used in the final journeys. No direct craft position/angle/band/hull/time/capture/mission-success edits; no removed, moved, frozen or changed Sirens. Real commands may use existing machinery or finite defensive tools, with use recorded. Rehearsal is on a snapshot copy and must not mutate the live state.
- Discover and reacquire the actual objective by optical key. Before camera work assert the selected context targets it; after actual Sim.advance assert captured, usable shot, row feature/intel and valid snapshot. Advance the full authored duration, including28seconds for the relay cycle, and prove live survival/retreat. A record-secured message alone is insufficient.
- Reserve local248..261 and CI268..281 in the same fourteen-row order as campaign_photo_rows_tests.EXPECTED. Check registry before every push. Import/core and only the new row journeys plus directly affected photo tests run locally; full hosted game-smoke remains the exact-head gate. Each row stays bounded by the existing per-suite CI cap.
- Investigate tender/relay separately without production edits. Initial read-only evidence: tender discovery creates a different objective, and the first normal camera command can complete the required rendezvous receiver instead of the optional door; reacquiring the right target then captures it. Relay28seconds is an intentional24second cycle plus dwell; sampled exposed viewpoints fail to threats before completion, which is not proof of an impossible route. Geometry-only staged probes are labeled and never counted as journey proof.
- If a fair route is not found, preserve the closest failed live evidence and report the blocker for Pat. No sensing, lock, beam, collision, damage, hull, camera-rule or story changes. Row-data/flag edits require a demonstrated bug within the handoff's narrow permission. Do not lower assertions, fake a successful capture or silently drop a row.
- After all row results are known, replace the false travel-coverage comment with exact journey references. Publish WIP within30minutes, open a coherent draft PR, merge current integration before final hosted checks, obtain independent exact-head review with actual import/core/named runs, then merge only on both green jobs. Retain every failed probe and limit in Completion and update only owned handoff/BOARD at closeout.

Review focus: real spawn/travel instead of staged viewpoints; target-priority mistakes and stale hidden dictionaries; full observation windows with live world time; helper false-positive preparation and live-copy isolation; actual usable film/survival rather than UI messages. Each is asserted by the new support or a named row journey.


SUITE RANK BLOCK (Claude, 24 Oct): Codex's new suites use local 240.. and CI 260.. so they cannot collide with Claude's blocks (local 228-239, CI 251-259). Validate with scripts/toolchain/check-suites.py before committing.

### Progress checkpoint,25October2026 Eastern

Draft PR144: https://github.com/pemunson90-cmd/Siren-s-Song/pull/144 . Branch claude/lane-photo-row-journeys, latest pushedf96ed4df8d61ae4fdf5efa182ff5de0d03b95a38 at4:18PM Eastern. Thirteen of fourteen live journeys now have passing local evidence; refinements after that push are pending the next WIP. Relay_blink remains red: actual approach/discovery succeeds, but the authored28second exposure and withdrawal have not yet survived. Failed probes retained outside the code tree for the final evidence archive. No production rule or data edits. Import and core836/0 baseline passed; final exact-head review and hosted checks are still pending. Pat reassigned048 to Codex after040 and033;040 stays the only active claim.

Latest recovery update,5:10PM Eastern: pushedb4945e2a, preserving all13 passing routes and the still-red relay route. Existing photo fixture361/0; registry275suites/0errors. PR144 progress comment6403344025 explicitly records the unresolved relay and pending final gates. Root import on this head passed; core rerun underway. Current attempted extension is a read-only feasibility probe of the already-earnable tele lens through public fitting and launch APIs, not a rule change or full-campaign evidence.

Reversible implementation choices, per Pat25October: keep production rules untouched for040; failed baseline relay routes remain evidence. A new optional launch argument defaults to the unchanged empty launch, so the thirteen baseline voyages retain their existing setup. The prospective relay lens fixture must validate reward consistency, fitting legality, physical stock and actual installed equipment; it cannot claim a real campaign reward was earned by this test. All existing journey assertions stay strict. No row is marked passed until the full real exposure, informative film and withdrawal pass.

### Coherent final candidate,5:16PM Eastern

PR144 is ready for review on44a168d610be02dbddcedd7947285a52eeaa6c4c, containing current integration0bf42344. All fourteen initial actual journeys pass:632checks/0failures, all finish at hull100. The relay uses disruption rather than endurance, with EMP at camera+7s,+17.5s,+28.5s, then completes a physical deep withdrawal to900,1700. Its unarmed patient rehearsal is false. A separate exact snapshot rehearsal executes the same finite timed public commands and checks usable specific film, survival, unchanged live snapshot and actual completed retreat before the live cycle. No existing study assertion is removed.

Historical prospective tele-lens plan above was investigated but not selected: staged viability did not survive the actual route and withdrawal with two EMP charges. Its external probe logs are retained, and no equipment/reward fixture or launch-dictionary extension remains in the final code. The helper instead accepts the ordinary launch upgrade, default endurance, with disruption used only by the relay.

Tender mismatch diagnosis: the first ordinary camera command can finish the required rendezvous job instead of the separately discovered optional tender row; a record-secured message and a hidden descriptor are not the optional captured objective. The live drone journey now verifies the exact target and usable film. Relay28seconds is the authored24second cycle plus dwell, unchanged. No proven row-data or flag bug, so no production changes were made.

Final root import/core/fourteen rows/photo fixture and independent nonauthor exact-head review are underway. Hosted run40234636132 is pending on44a168d6. The head must not merge until both hosted jobs and attributable exact-head independent review pass. These are source-known launch-to-photo journeys, not full-operation extraction, campaign/unlock or first-exposure preference evidence.
