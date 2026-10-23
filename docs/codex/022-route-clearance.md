# Handoff 022: NAV1, planned courses stop clipping rock corners

Status: DONE
Claimed at: 2026-10-22 23:08:54 UTC
Claimed by: codex
Finished at: 2026-10-23 00:05:58 UTC

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
DONE. PR75: https://github.com/pemunson90-cmd/Siren-s-Song/pull/75, merged into claude/integration as `07eb8905d2cc70babe92e87a26dbddf3750bb0ab`.
Branch: `claude/lane-nav-clearance`. Last pushed SHA: `ecfd4ef18df1bf1107e9772dfafbdc2d090b7f33`. Both guidance and game-smoke succeeded on that exact head, run39873627262. Fresh integration335f082 ancestry and mergeability verified immediately before the merge commit. DONE and BOARD committed together as bcf88f6.

Reproduced a real unsafe plotted leg at fixed steps: Cold Foundry (index3, displayed operation4), legal start(889.6,800), extraction(1420,880). Minimum terrain clearance was11.803m, inside the12m hull. Dropping the first safe AStar grid point caused the accepted course to cross the corner; the physical failsafe then cancelled it. The original cold-review tap coordinates were not preserved, so these are reconstructed source-known cases.

The player-only path flag retains that grid entry and validates emitted legs with the existing continuous hull guard. Shared non-player path output is pinned unchanged. Focused regression was RED6/2, then GREEN7/0; fixed clearance20m and physical arrival with full hull. Corner-start sweep was607/1, then607/0. Final ordinary endpoint sweep1145/0. Seven isolated motion cases across60/16/4Hz frame updates passed84/0, separating frame cadence from the fixed simulation step. These fixtures isolate navigation from threats and other hulls and do not claim live-mission finishability.

The self-contained presentation/route_clearance/hull_band.gd owns the style table, read-only footprint geometry and revert note. One draw seam each in the chart and planner shows the physical12m-radius hull band. It reads own accepted route nodes and no hidden terrain. Touch UI was RED9/3, then GREEN17/0 on both Fold shapes: actual waypoint touch and zoom, read-only preview, pending-touch cancellation, Android Back. A deferred Main seam closes the route panel on Back, matching Escape and cancelling its pending gesture.

A pre-existing route-program fixture failure also reproduced on the unchanged baseline: it drove Quietus into parked DroneB and treated the collision impulse as acceleration failure. Only the fixture parks the live drones clear; all35 assertions retained. This does not fix the actual opening friendly-collision issue, which belongs to034.

Final local integrated verification: clean import; core817, route35, collision20, turn-safe22, route UI44, planner UI34, challenge UI86, all-stop UI12, photo-rules UI4; focused clearance7, following84, ordinary sweep1145, corner sweep607, touch/Back17, strict bare Well13. All zero failures, no Godot error or leaked-resource lines. Bare Well won with full hull, no tools and standard initial oxygen. No full scenario list run locally; GitHub ran it on the final head.

No collision, damage, hull, Siren or photo rules/numbers changed. No APK, main or production changes. Physical Android hardware and rendered screenshot verification were unavailable; injected touch and Android Back notification propagation are the verified scope. NAV1 tests are now registered by claimed016 on its pushed lane, including the short default probe; 018 was Claude-owned and not modified.
