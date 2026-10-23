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

CLAIMED, source complete; PR87 remains open behind the current priority queue. Branch claude/lane-audio-photo, exact head87a5f99bed616fa3fd80c18ebaea167a4a890eaa, base integration0df679650bfdc0de98503f162f181b613dcb7574 including PR77/79. Current exact-head CI39911965967 is running. Pat cleared merges; finish019,035,036,037 first.

Own audio/photo_audio module contains eight quiet cues, cached mono16 WAV synthesis with deterministic local noise, and one tuning table for gains/envelopes/build/pitch/low-film/spin-down curves. One Soundscape.update seam reads own craft/capture/film/band/all-stop state and returns an engine multiplier. No simulation RNG, enemy rules, saves, music or warning-audio changes. The existing soundscape uses imported recordings; new synthesis shares its WAV format and builds only once per cache.

Lifecycle covers mission identity reset, historical-edge suppression, mute/effects0, pause, inactivity and Android notifications. Review caught direct campaign Soundscape.suspend leaving nested voices playing; the generic suspension loop now pauses descendant players immediately, including when updates stop. Existing music/warning ownership stays intact. Regression RED47/1 then GREEN47/0; independent probe confirms immediate and150ms pause without updates/global notification.

Import clean/core817/0. Actual-player headless audio47/0, existing plant13/retry8/lockwarning27 all pass. Normal PR77 merge changes no audio source or tests; registry preserves all4audit rows plus audio. Relayed independent review, not formal GitHub approval: /root/review_audio, fresh-context requestedgpt-6.1-sol Medium, approves exact87a5f99 against0df6796, no Critical/Important/Minor findings, personally reran suspension probe. Pat judges subjective levels; no listening/enjoyment or physical-Android claim.

Keep Pat's019,035,036,037 priority order. When exact CI is green, record ready/pending queue position on BOARD. Reconcile fresh integration before any later merge. No APK/main/production changes.

23 Oct resume checkpoint: Pat's latest order is PR88, PRIORITY035/PR86, this024/PR87, then remaining019,036,037. Last pushed claude/lane-audio-photo head1b26249 normally incorporates prepared035ad9cbb3 plus reviewed PR88/D3. Preparation only: actual PR88 and PR86 integration merges and final exact-head checks/review are still required before merging PR87. Source audio module/Soundscape preserved, registry combines D3/all10FIX2/audio rows with unique ranks. Import/photo audio47/0,received retry8/0,lock warning27/0 pass. Core and independent review running. No APK/main/production changes.

Combined core completed818/0 at1b262495deccdb0269aa9c1d021ed2c4c9db575e. Independent /root/review_integration approved this exact preparation againstad9cbb3, no Critical/Important/Minor: byte-identical audio source/tests to prior87a5f99, lifecycle consistent, prior features preserved. Reviewer source/parity/registry checks only; parent runtime. Actual predecessor integration/final checks still required.
