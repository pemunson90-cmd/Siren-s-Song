# Handoff 035 (PRIORITY): FIX2, concrete problems from the full cold review and the Marlow audit

Status: CLAIMED
Claimed at: 2026-10-23 04:41:53 UTC
Claimed by: codex
Finished at:

Precondition: none. Take this before 019's later steps if Codex is between steps; do not interrupt an in-progress PR (finish 019 step 1 / PR81 first).
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (CHECKS N FAILURES 0), and only the tests for what you touched. No full scenario list locally. Never skip, loosen or delete a test.
Standing rules: PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md on claude/integration. Touch-first (48 dp, Android Back), modular, optional validated save fields. Push WIP every 30 minutes. No em dashes. Do not change combat, beam, collision, damage, hull or Siren sight/hearing rules.

## Task (plain language)
A fresh critic played ops 1 and 2 fully and started ops 4 to 6 with real touch input (software render, no sound). Its report is the file `COLD_REVIEW_2_FULL.md` next to this one in docs/design/ on this branch. Verify each item yourself before fixing; report any that do not reproduce. One PR, small changes in each owning module.
1. SAVE ERROR FIRST. "Save rejected: unsupported or invalid archive." appeared on a clean save in op 1, about 40 s in, right after the second photo exposure. Find the half-written capture state that fails validation (a save while an exposure is in flight). Fix at the cause (defer or complete the state), keep the validation strict, add a regression test that saves mid-exposure and reloads. Show the message only if a retry also fails.
2. Android Back / Escape does nothing on Settings, Challenges list and Challenge detail. Make the title overlay handle Back (Settings and list return to title, detail returns to list). Put BACK where it cannot fall below the fold on a 960x432 window (top or sticky footer).
3. Briefings for ops 4 to 6 are jargon walls. Rewrite as the GOAL and DANGER pair used in ops 1 to 3, two lines each, one new idea per op; drop the repeated ORDERS block after op 2. Placeholder length, plain words. Do the same pass for ops 7 to 29 briefings if short.
4. Fittings screen: a separate Fittings entry from the mission list, all three hulls visible at once (no single button that cycles and relabels itself), and mission rows that do not shift down when a RESUME DIVE row appears (two taps hit the wrong mission).
5. Tutorial hint cards come back every launch (ops 2 and 6 seen). Persist which hints were seen in an optional validated save field.
6. After a Disrupt the lock banner still reads "BEAM 3.8s" while the Siren is stunned. Show a STUNNED countdown (UI only, no rule change).
7. Viewfinder text is about 9 px at 1280x576 and 7 px at 960x432 and truncates ("SHARP 79% LIG..."). Make it readable and untruncated, with sharpness and light as two bars plus numbers. Camera controls must also follow the normal text-size and touch-size settings and the reduced-motion setting (audit item: camera_feed.gd and photo_view.gd use fixed sizes and always animate).
8. Move ERASE PROGRESS off the title screen under CONTINUE into Settings (keep its confirm).
9. Report measured touch-target sizes in dp-equivalent for the unit chips (38x38 window px) and menu buttons (38 px at 1280x576, 34 px at 960x432); raise anything under 48 dp-equivalent at the Fold7 shapes.
10. Debrief death line: after a loss, replace the bare "VAPORIZED · Siren beam struck Quietus" with one added plain line saying what happened (for example "Seen at 140 m while engines were loud" if the existing observation record has it). Read-only from existing state; do not change detection.
11. Verify late-operation Siren photography (Marlow audit item 4): in ops 6 to 10 and 22 to 29, can a legitimate same-band Siren be studied with the camera? PR77 claims later operations offer eligible Siren studies. List any operation where it still fails and fix routing if cheap; otherwise report.
NOT in this handoff (design decisions for Claude and Pat, do not change): a pre-lock cue for the first Siren sight, an early module reward, weak frames still securing records, a route map (that is 021).

## Base and branch
Base: origin/claude/integration (fetch fresh; if PR77 or PR79 have merged, include them). Branch: claude/fix2-cold-review-full

## What done looks like
Each item fixed or reported as not reproducing; real-touch tests at both Fold7 shapes for items 2, 4, 6 to 9; the item 1 regression test; CI green.

## Return
PR into claude/integration; merge per the line above; mark DONE and update the board.

## Completion
Claimed while019 step3 PR83 is in progress. Finish that green PR before later019 order-family PRs;035 now has priority. The existing camera-selector early returns also block020's optional photos on7/8. Item11 owns that routing repair, so020 stays data-only and its earlier ownership question is superseded by this new explicit assignment. Preserve ready mission jobs and active exposures. Save error is investigated first.
