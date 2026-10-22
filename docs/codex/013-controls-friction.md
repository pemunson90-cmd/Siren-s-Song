# Handoff 013: fix FIT and craft-handle overlap and ring friction

Status: OPEN
Claimed at:
Claimed by:
Finished at:

Precondition: handoff 012 must be DONE or BLOCKED.
Codex may merge: yes, into claude/integration only, after GitHub's guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE.
Testing: import, core tests, and only the tests for what you touched. Do not run the full scenario list locally; GitHub runs it. Fix red CI by pushing again.
Overlap warning: Claude's PHOTO1 builder is rewriting photography (simulation capture code, recon_consequences.gd, camera_feed.gd, evidence_catalog.gd, archive parts of main.gd, campaign/archive_recap.gd, campaign/encounters/work_sites.gd, equipment_catalog.gd, save_store.gd) on claude/photo1-recon and may land first. Do not edit those files except where this handoff says so. Always fetch origin/claude/integration fresh and merge it before you push; on conflict keep both sides.
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
(Codex fills this in: what changed in plain language, PR link, test results, unverified items, anything for Pat.)
