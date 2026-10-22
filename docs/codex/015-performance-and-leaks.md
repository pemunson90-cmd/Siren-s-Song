# Handoff 015: measure performance and fix leaks and slowdowns

Status: CLAIMED
Note: BATCH 2 (released 22 Oct 17:45 UTC). Follow the standing engineering rule in PLAN_SNAPSHOT.md: self-contained module, one narrow seam, numbers in a data table, optional validated save fields, tests beside the feature.
Claimed at: 2026-10-22 22:26:35 UTC
Claimed by: codex
Finished at:

Precondition: handoff 014 must be DONE or BLOCKED.
Codex may merge: yes, into claude/integration only, after GitHub's guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE.
Testing: import, core tests, and only the tests for what you touched. Do not run the full scenario list locally; GitHub runs it. Fix red CI by pushing again.
Overlap warning (22 Oct): PHOTO1 and ONBOARD1 are merged. Claude's PHOTO2 builder (branch claude/photo2-images) owns the camera, viewfinder, archive viewer, photo save paths, recon_consequences.gd, camera_feed.gd and evidence_catalog.gd. Claude's SWEEP1 builder (branch claude/lane-t2-sweeper) owns the sweeper code and its warning text, plus a first-warning tutorial pause in onboarding_hints.gd. Do not edit those files; write what you need in your Completion section instead.
Never change combat, beam, collision, detection, damage or hull rules, story, or photography design (those are Pat's). No em dashes in any text you add. Briefings and story text stay short placeholders.

## Task (plain language)
CONTINUATION notes record density and ObjectDB (leaked-object) risks. Measure first. Using the headless toolchain, step the heaviest operations (for example 19 and 22 to 29, plus a crowded Glass Reach op) for a few simulated minutes and record simulation step cost, and at exit record leaked objects or resources (Godot prints ObjectDB or resources-still-in-use lines; CI fails on any ERROR line). Find the top three costs or leaks and fix those that are safe (freed nodes, repeated allocation in per-frame code, redundant path searches, unneeded redraws) without changing behavior. Report before and after numbers in the Completion section. Android devices cannot be tested here; say so and list any risks you could not resolve. No gameplay changes. If a fix would change behavior, stop and report instead.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-performance-and-leaks

## Files you may edit
Performance-related edits across game/src (smallest possible diffs), new measurement tests under game/tests/.

## Files you must not touch
Gameplay rules, the PHOTO1 files listed above (report issues in them instead).

## What done looks like
Before and after numbers, at least one real fix with identical behavior proven by existing tests, no new leaks, PR merged on green.

## Return
Open a PR into claude/integration, wait for guidance and game-smoke, merge when green, then write the Completion section and push to codex/handoffs.

## Completion
Work in progress, exact-head CI pending. Branch: `claude/lane-performance-and-leaks`. Last pushed SHA: `9899a2c0272d3b2b44bc989df9a19d5c3cec4961`. PR: https://github.com/pemunson90-cmd/Siren-s-Song/pull/73 (ready).

Measured first. Top inclusive costs on a 30-second operation-19 trace: threats 909 ms, observation 789 ms, movement 348 ms. Movement is nested inside threats; these must not be summed. Crowded operation 16 showed the same three costs (1120/770/1100 ms). Terrain-chart work was negligible, so it was left alone. Only observation had a small, clearly behavior-preserving fix: four added lines skip pure visibility queries for already-true known-water cells; false and unknown cells retain ordinary sight checks. No detection, movement, damage, photography or operation rules changed.

Before/after mean microseconds per real fixed simulation step, 180 seconds and 10800 ticks per operation, live idle standard fleets with ordinary outcomes/resources:

| Operation | Before us | After us | Reduction |
| --- | ---: | ---: | ---: |
| 19 | 1163.6 | 819.8 | 29.5% |
| 22 | 1003.6 | 677.1 | 32.5% |
| 23 | 919.9 | 439.9 | 52.2% |
| 24 | 845.9 | 527.2 | 37.7% |
| 25 | 865.5 | 543.3 | 37.2% |
| 26 | 822.1 | 472.5 | 42.5% |
| 27 | 898.4 | 583.4 | 35.1% |
| 28 | 949.4 | 675.7 | 28.8% |
| 29 | 753.8 | 445.3 | 40.9% |
| 16 | 1780.7 | 1196.6 | 32.8% |

All ten complete final-state hashes match baseline exactly. Median mean-step reduction across cases: 36.1%. Operation-19 observation in the instrumented trace fell from 789 to 59 ms. These are single-host headless CPU measurements, not Android frame-rate claims; moving play is covered by existing core tests, not by the idle timing sample.

Regression demonstrated RED 7 checks/1 failure, then GREEN 7/0. Clean import; core 817/0; terrain chart 14/0; opening depth 72/0; full baseline/after measurements 10/0 each; profiles 3/0 each; repeat-retention probe 4/0. Initial +3/+2 retained objects did not repeat on subsequent runs of the same operations (zero steady-state growth). No ObjectDB, leaked-resource or resources-still-in-use lines in these exits, and no Godot error lines in passing checks. No tests loosened.

Unverified/risk: no physical Android device, GPU/dense-rendering profile, or long-session device memory measurement. First fresh-worktree asset import segfaulted once; retry and final import were clean, no cgroup OOM event, cause not established. Threat/movement costs remain; changing their behavior was outside this handoff and was not attempted. No photo-owned files touched.

Register `performance_measurements` (short default) and `known_water_observation_tests` in 016. Full timing probe uses `-- --seconds=180 --operations=19,22,23,24,25,26,27,28,29,16`; optional `--profile` measures inclusive method costs. Next: 016 after 015 merges on green; leave 018 to Claude.
