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

Pat now holds all integration merges until explicit clearance while Claude lands77/79/82/84. Continue this claimed audio implementation and push WIP every30minutes; leave any green ready PR open and mark that state on BOARD.

Checkpoint: branch claude/lane-audio-photo pushedc45f2985c99d0829d8c9d27a74c1027bfda9935c; draftPR87 https://github.com/pemunson90-cmd/Siren-s-Song/pull/87. Self-contained audio/photo_audio module, quiet procedural WAVs cached once, data table of gains/chirp/envelope/build curves, own-event/craft state only, no new saves. Soundscape sync returns an engine multiplier for spin-down/silence. Existing music and Siren-warning ownership untouched. Current soundscape has imported recordings rather than a retained procedural builder; new cue generation uses the same mono16 WAV format, once per cache, with local deterministic noise (no simulation RNG). Import clean, core817/0, actual-player headless audio46/0, plant13/0, retry8/0. No subjective listening/physicalAndroid claim. Independent source review and final fresh-base CI pending. MERGE HOLD until Pat explicitly clears.

Latest3dd614bcd751e277ee516fa3774929a3ec0929e7 pushed. PR87 ready for review, source-approved by /root/review_audio (freshgpt-6.1-sol Medium), no outstanding findings. Reviewer found direct campaign suspension left nested module voices playing; generic Soundscape.suspend now immediately pauses descendant players. Reproduced47/1 then47/0; reviewer independently verified immediate pause and150ms with no updates/global notifications. Existingplant13/retry8/lock27 pass. Existing workflow manually dispatched on lane, run39908066605. Final core817/0 and import clean; source approved, CI pending, not DONE yet. MERGE HOLD remains.
