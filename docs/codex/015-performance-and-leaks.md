# Handoff 015: measure performance and fix leaks and slowdowns

Status: HOLD
Note: parked for BATCH 2. Claude changes Status to OPEN when batch 1 is reported finished. Until then, ignore this file.
Claimed at:
Claimed by:
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
(Codex fills this in: what changed in plain language, PR link, test results, unverified items, anything for Pat.)
