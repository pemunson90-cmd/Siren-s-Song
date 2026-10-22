# Handoff 011: make the lethal beam warning unmistakable

Status: OPEN
Claimed at:
Claimed by:
Finished at:

Precondition: none. This is the first handoff of BATCH 1 (011, 012, 013). Handoff 009 is claimed by Claude and does not block you.
Codex may merge: yes, into claude/integration only, after GitHub's guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE.
Testing: import, core tests, and only the tests for what you touched. Do not run the full scenario list locally; GitHub runs it. Fix red CI by pushing again.
Overlap warning (22 Oct): PHOTO1 and ONBOARD1 are merged. Claude's PHOTO2 builder (branch claude/photo2-images) owns the camera, viewfinder, archive viewer, photo save paths, recon_consequences.gd, camera_feed.gd and evidence_catalog.gd. Claude's SWEEP1 builder (branch claude/lane-t2-sweeper) owns the sweeper code and its warning text, plus a first-warning tutorial pause in onboarding_hints.gd. Do not edit those files; write what you need in your Completion section instead.
Never change combat, beam, collision, detection, damage or hull rules, story, or photography design (those are Pat's). No em dashes in any text you add. Briefings and story text stay short placeholders.

## Task (plain language)
Pat made the Siren beam lethal (PR 64) and kept the 4 second lock build as the fair warning. The warning now carries the whole game's fairness, so a player must always notice it in time and know what breaks it. Audit how the lock build (states LOCKING then BEAM) is shown today in simulation output, HUD, world rendering and audio (grep lock, LOCKING, BEAM, warning in game/src/presentation, game/src/audio, game/src/simulation). Then make it readable on a phone in a dark scene, on both the cover and inner views: a distinct escalating audio cue (rising tone or pulse that speeds up, different from the heartbeat and from sonar), a clear world marker on the locking Siren and a line or arc to Quietus, a countdown the eye catches without reading text, and a short on-screen hint of what can break it (cover, braking, depth change, line of sight, EMP, knockdown) shown the first few times only. Presentation and audio only. Do not change the 4 second duration, who locks, what breaks a lock, or any damage. Add tests that the cues start when the lock starts, escalate, and stop when the lock breaks or fires, and that they do not play for drones or non-hostile contacts.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-lock-warning-readability

## Files you may edit
game/src/audio/*, game/src/presentation/acoustic_feedback.gd, contact_feedback.gd, threat-related presentation files, new files under game/src/presentation/ and game/tests/ for this feature, a minimal hook in main.gd.

## Files you must not touch
Beam, lock, hull, collision, detection logic in simulation; the PHOTO1 files listed above.

## What done looks like
A player can tell within a second that a lock has started, how long is left, and which Siren it is; the cue ends cleanly; tests pass; all rules unchanged.

## Return
Open a PR into claude/integration, wait for guidance and game-smoke, merge when green, then write the Completion section and push to codex/handoffs.

## Completion
(Codex fills this in: what changed in plain language, PR link, test results, unverified items, anything for Pat.)
