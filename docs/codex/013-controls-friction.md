# Handoff 013: fix FIT and craft-handle overlap and ring friction

Status: DONE
Claimed at: 2026-10-22 17:36:13 UTC
Claimed by: codex
Finished at: 2026-10-22 20:17:41 UTC

Precondition: handoff 012 must be DONE or BLOCKED.
Codex may merge: yes, into claude/integration only, after GitHub's guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE.
Testing: import, core tests, and only the tests for what you touched. Do not run the full scenario list locally; GitHub runs it. Fix red CI by pushing again.
Overlap warning (22 Oct): PHOTO1 and ONBOARD1 are merged. Claude's PHOTO2 builder (branch claude/photo2-images) owns the camera, viewfinder, archive viewer, photo save paths, recon_consequences.gd, camera_feed.gd and evidence_catalog.gd. Claude's SWEEP1 builder (branch claude/lane-t2-sweeper) owns the sweeper code and its warning text, plus a first-warning tutorial pause in onboarding_hints.gd. Do not edit those files; write what you need in your Completion section instead.
Never change combat, beam, collision, detection, damage or hull rules, story, or photography design (those are Pat's). No em dashes in any text you add. Briefings and story text stay short placeholders.

## Task (plain language)
The spec records known control friction: the FIT button and craft handles overlap, and the fleet ring is awkward. Reproduce it with the existing real-touch UI test harness at the Fold7 cover and inner screen sizes (look at the existing *_ui_tests that inject touch, for example fleet_ring_ui_tests and route_telemetry_touch_tests). Fix so that tapping FIT never grabs a craft handle and tapping a handle never triggers FIT, all touch targets are at least 48 dp, the ring does not cover the craft it belongs to or the main view controls, and the layout works on both screen shapes. Prefer small layout and hit-test changes over redesign. Add or extend touch tests that prove each case. Keep main.gd edits minimal and local to input and layout.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-controls-friction

## Files you may edit
game/src/presentation/fleet_ring.gd, fleet_instruments.gd, chart_camera.gd, route and planner presentation, related UI tests, minimal main.gd input and layout edits.

## Files you must not touch
Simulation rules; the PHOTO1 files listed above (including the archive part of main.gd).

## What done looks like
Real-touch tests on both screen shapes show no overlap grabs and all targets large enough; no behavior change to routes or tools.

## Return
Open a PR into claude/integration, wait for guidance and game-smoke, merge when green, then write the Completion section and push to codex/handoffs.

## Completion
Craft command rings now move together with their buttons and tether, stay clear of the selected hull and pause control, and reflow immediately after FIT or zoom. Crowded offscreen handles search the other edges for a clear full-size target; FLEET remains available if every edge is occupied. The main.gd layout change is one local refresh call. Routes, tools and simulation rules are unchanged.

PR [71](https://github.com/pemunson90-cmd/Siren-s-Song/pull/71) merged as `dd9494ba139fdf23b92f5599d1aadcd487e2c637`, after guidance and game-smoke passed on `f71370cab344b1dba21817a0ccd72906133b0fa4`: [CI run](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/39844515618). The refreshed head includes Priced Shots and SWEEP1.

Validation: clean import; core 817, runtime 665, fleet-ring UI 212, fleet-instruments UI 78, route touch 46, onboarding 30, warning pause 15, pricing UI 11 and photo UI 9 checks, all zero failures. Injected touch passes on both logical Fold layouts, including targets of at least 48 dp, FIT/handle ownership, rotated-hull clearance and immediate camera reflow. Local guidance and its eight detector tests pass. Physical Fold7 ergonomics remain unverified.

No game source outside the assigned files was needed. Handoff 017 separately authorizes the one-line CONTINUATION update included during integration. Next: handoff 014.
