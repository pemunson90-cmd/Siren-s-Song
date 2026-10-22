# Handoff 012: read-only report: what V7 does that the Godot game lost or changed

Status: CLAIMED
Claimed at: 2026-10-22 17:32:32 UTC
Claimed by: codex
Finished at:

Precondition: handoff 011 must be DONE or BLOCKED.
Codex may merge: yes, into claude/integration only, after GitHub's guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE.
Testing: import, core tests, and only the tests for what you touched. Do not run the full scenario list locally; GitHub runs it. Fix red CI by pushing again.
Overlap warning (22 Oct): PHOTO1 and ONBOARD1 are merged. Claude's PHOTO2 builder (branch claude/photo2-images) owns the camera, viewfinder, archive viewer, photo save paths, recon_consequences.gd, camera_feed.gd and evidence_catalog.gd. Claude's SWEEP1 builder (branch claude/lane-t2-sweeper) owns the sweeper code and its warning text, plus a first-warning tutorial pause in onboarding_hints.gd. Do not edit those files; write what you need in your Completion section instead.
Never change combat, beam, collision, detection, damage or hull rules, story, or photography design (those are Pat's). No em dashes in any text you add. Briefings and story text stay short placeholders.

## Task (plain language)
Read-only study; edit no game files. Pat treats the playable V7 prototype (reference/original-prototype/sirens_song_prototype_v7.html and the spec files beside it) as the reference for the original design. Compare it with the current game and report, in plain language Pat can read in five minutes: (1) mechanics V7 had that are missing in the Godot game; (2) mechanics that changed, with whether the change is better or worse for the original feel; (3) things the Godot game added that V7 never had (list them; Pat is deciding which to keep, example: the Siren active-sonar sweeper); (4) the five differences that most change how the game feels to play, ranked. Cover detection (sight, hearing, noise), suspicion and Hunt, tools (ping, recon, EMP, knockdown, decoy, drones), oxygen, extraction, currents, thermal, graze and kill rules. Use file and line anchors for V7 and for the Godot code. Do not propose fixes beyond one line each. Do not edit docs/V7_TO_GODOT_PARITY.md; Claude reconciles it.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-v7-parity-gap-report

## Files you may edit
Only the Completion section of this handoff file (put the whole report there).

## Files you must not touch
Everything in the game repo.

## What done looks like
The report is in the Completion section, readable by a non-developer, with anchors, and clearly separates verified-in-code from inferred. No PR needed; mark DONE.

## Return
Open a PR into claude/integration, wait for guidance and game-smoke, merge when green, then write the Completion section and push to codex/handoffs.

## Completion
(Codex fills this in: what changed in plain language, PR link, test results, unverified items, anything for Pat.)
