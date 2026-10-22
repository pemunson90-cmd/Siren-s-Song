# Handoff 022: NAV1, planned courses stop clipping rock corners

Status: CLAIMED
Claimed at: 2026-10-22 23:08:54 UTC
Claimed by: codex
Finished at:

Precondition: handoff 017 must be DONE.
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (must end CHECKS N FAILURES 0), and only the tests for what you touched. Do not run the full scenario list locally; GitHub runs it. After any red game-smoke, also run the later tests in the CI list locally. Never skip, loosen or delete a test.
Standing rules: read docs/codex/PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md (STANDING DELEGATION and STANDING ENGINEERING RULE) on claude/integration. Self-contained module, one narrow seam, numbers in a data table, optional validated save fields, a revert note in the module header, tests beside it. No em dashes. Story text stays 1 to 2 line placeholders. Never change combat, beam, collision, damage, hull or Siren sight/hearing rules. Do not commit generated .uid files that integration does not already track.

## Task (plain language)
The first cold review saw plotted routes pass through rock corners, causing hull strikes of 3% to 13% in ops 1, 4 and 5 (software render ran about 16 fps so coarse steps may have contributed; verify with the headless sim first at fixed steps). Reproduce with a headless scenario at fixed time steps: plan the same routes and measure the minimum distance between the path and terrain versus the hull radius. If the planner really allows paths that clip, fix it by planning with hull-size clearance and show the clearance margin on the route preview (a faint band or warning colour). Do NOT change the collision damage rule or numbers. If the clipping is only low frame rate, report that and add a regression test pinning the clearance, no gameplay change.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-nav-clearance

## Files you must not touch
Collision damage numbers and hull rules, Siren rules, story text.

## What done looks like
Either a proven planner clearance fix with a preview indicator, or a report plus pinned test showing none was needed; bare-Quietus fixtures and route tests still pass.

## Return
PR into claude/integration; merge per the line above; mark DONE and update the board.

## Completion
Work in progress. Branch: `claude/lane-nav-clearance`. Last pushed SHA: `ecfd4ef18df1bf1107e9772dfafbdc2d090b7f33`. Draft PR: https://github.com/pemunson90-cmd/Siren-s-Song/pull/75.

Reproduced a real unsafe plotted leg at fixed steps. Cold Foundry (index 3, display operation 4), start (889.6,800), destination extraction (1420,880): geometric minimum 11.803 m, inside the 12 m hull. The first safe AStar grid point was discarded, then the physical failsafe cancelled the accepted course. Exact original cold-review tap coordinates were not preserved; these are source-known reconstructed cases, not that original input trace.

Player-only flag retains the safe grid entry and validates emitted legs with the existing continuous hull guard. Original common non-player path is explicitly pinned unchanged. Regression first RED 6/2, now GREEN 7/0, minimum 20 m and arrival with full hull. Corner-start sweep first 607/1, then 607/0. Normal endpoint sweep 1145/0 before fix; final rerun pending. Initial isolated motion matrix 18/0 at 60/16/4 frame updates per second; expanded matrix pending. These remove threats/other hulls to isolate navigation, not prove live mission finishability.

Self-contained `presentation/route_clearance/hull_band.gd` holds the footprint style table, read-only geometry and revert note. One draw call each in the main chart and route-program preview shows the physical 12 m radius band. Touch UI first RED 9/3, now GREEN 17/0 on cover/inner: actual waypoint tap, touch zoom, no simulation mutation, and Android Back cancellation. Back originally left the route panel open over the campaign menu; a deferred route-panel close now matches Escape and cancels pending touch. No keyboard-only path added.

No collision, damage, hull or Siren rules/numbers changed. No photo-owned logic changed. Before DEPTH1 refresh: import clean, core 817/0, turn 22/0, route 35/0, collision 20/0, route UI 44/0, planner UI 34/0, challenge UI 86/0, NAV1 UI 17/0, expanded motion 84/0, final normal sweep 1145/0, strict bare Well 13/0 (full hull/no tools). One pre-existing route-program failure was reproduced on the unchanged baseline: it drove Quietus into parked Drone B and misclassified the collision impulse as an acceleration failure. Only the fixture was moved clear; all 35 assertions retained. Passing logs have no errors or leaked-resource lines.

PR74 landed during verification. Merged current integration `7a95070` into this lane without conflicts and pushed as 1638715. Re-running affected checks on that integrated head before exact-head CI; no changes to Claude-owned feature logic. Physical Android hardware and rendered screenshot verification unavailable in this workspace so far. Preview reads only own accepted nodes, never hidden terrain. New test registration is deferred to 016 to avoid its shared-runner overlap with PR74. 016 stays blocked until Pat releases it; 018 stays Claude-owned.

Latest checkpoint: current integration guidance through 335f082 merged; latest pushed head ecfd4ef18df1bf1107e9772dfafbdc2d090b7f33. Local integrated verification passed: core 817, route 35, collision 20, turn 22, route UI44, planner UI34, challenge UI86, all-stop UI12, photo-rules UI4; NAV7, follow84, normal sweep1145, corners607, touch/back17, strict bare Well13. All zero failures. PR75 ready for review, exact-head guidance green, game-smoke pending.
