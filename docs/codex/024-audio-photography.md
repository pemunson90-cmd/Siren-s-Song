# Handoff 024: AUDIO1, sound for the camera and all-stop

Status: CLAIMED
Claimed at: 2026-10-23 05:28 UTC
Claimed by: codex
Finished at:

Precondition: handoff 018 must be DONE.
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (must end CHECKS N FAILURES 0), and only the tests for what you touched. Do not run the full scenario list locally; GitHub runs it. After any red game-smoke, also run the later tests in the CI list locally. Never skip, loosen or delete a test.
Standing rules: read docs/codex/PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md (STANDING DELEGATION and STANDING ENGINEERING RULE) on claude/integration. Self-contained module, one narrow seam, numbers in a data table, optional validated save fields, a revert note in the module header, tests beside it. No em dashes. Story text stays 1 to 2 line placeholders. Never change combat, beam, collision, damage, hull or Siren sight/hearing rules. Do not commit generated .uid files that integration does not already track.

## Task (plain language)
Add sound cues in a self-contained module (game/src/audio/photo_audio/, data table of cue names, gains and curves): shutter, exposure hold tension that builds, plate developing, film low and film empty warnings, all-stop engine spin-down and silence, band-change pressure creak (shallow versus deep). Use the existing soundscape generation tools (procedural); mute and suspension correctness must be preserved. One narrow seam into the existing soundscape. Pat judges subjective quality, so keep every level tunable in the table and keep cues short and unobtrusive. No music changes.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-audio-photo

## Files you must not touch
Siren warning audio (handoff 011 owns it), music, combat.

## What done looks like
Cues play at the right moments in a headless event test; mute works; table documented.

## Return
PR into claude/integration; merge per the line above; mark DONE and update the board.

## Completion
Claimed as the lowest OPEN eligible independent task while035 exact-head CI runs (021 waits020;023 waits019). Keep035 merge priority, then019/020 integration order. Audio work stays in its owning module plus one soundscape seam; no warning/music/combat edits.
