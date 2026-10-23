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

CLAIMED, source complete; PR86 remains open behind019 under Pat's revised order. Branch claude/fix2-cold-review-full, exact head33fbb20d3c7a4ff24c672268b2aa005c0f3bc4c8, base integration0df679650bfdc0de98503f162f181b613dcb7574 including PR77/79. Current exact-head CI39912616182 is running. Pat cleared merges and ordered019,035,036,037.

Item dispositions:
1. Legitimate incomplete-feature photo retakes were rejected because the site was already captured. Narrow photographic exemption preserves target/type/finite/duration/duplicate guards. Actual mid-retake save/reload12/0 and I/O retry4/0. Optional recovery exposed two mandatory-record assumptions; optional-only fixes retain required-job strictness,20/0.
2,8. Android Back/Escape route detail to list to title. Back stays above the fold. Confirmed Erase moved to Settings. Actual Canvas touch at both Fold shapes and960x432:63/0.
3. Ops4–6 use short GOAL/DANGER. Repeated generic orders afterop2 moved behind the manual. Unique later procedures retained under conditional scope; no narrative rewrite.
4. Separate Fittings entry, all named hull/chassis choices, Resume after stable mission rows. Actual Canvas touch24/0; existing explicit frame selection73/0.
5. Not reproduced: optional validated hints_seen already persists. Fresh-launch regression confirms it; no redundant field.
6. Optional validated observed_stun on already earned visible optical contacts; immediate Disrupt feedback/countdown, no enemy or rule writes. Actual Canvas touch12/0; state10/0.
7. Camera font/touch/text scale/reduced motion now follow settings. Separate sharp/light bars and numbers preserve film counter; emulated duplicate mouse toggles suppressed. Actual Canvas150percent-text/flash/tight/focus54/0.
9. Existing fleet/menu targets measure56.0dp-equivalent cover and56.55inner in420dpi fixtures; reported undersize did not reproduce there. Camera controls exceed48dp-equivalent. This does not establish physical-device ergonomics.
10. Classic/expedition loss line reads own state and last observed range only. Lightweight Outcome objects safely omit unavailable values. Existing debrief7/0; state10/0.
11. Eligible same-band Sirens work throughout requested6–10 and22–29, routing83/0 and actual Canvas study touch24/0; cross-band rejected. Study-index/UI crashes fixed. Optional photos on7/8 route for020. Ready jobs, active exposures and powered plants retain precedence.

PR77 normal-merge reconciliation preserves its command guards, stable study identities, flash/provenance/cargo fixes. Fleet object helper is equivalent;035 modular routing is the superset. Registry retains4audit rows, then10FIX2 rows176–185 /197–206. Import clean/core818/0; one extra Settings target check explains the prior817 count. Focused audit45/5/10/25, loadout38,briefing50,onboarding30,capture52/UI9,depth49,contacts36,Shelf33,lockUI14,cold-review218,challenges86 all pass. No tests removed, skipped or loosened.

Relayed independent review, not formal GitHub approval: /root/review_fix2, fresh-context requestedgpt-6.1-sol Medium, approves exact33fbb20 against0df6796, no remaining Critical/Important findings. Personally integrity45/routing83/state10/debrief7 clean. Two earlier camera findings and a CI-only partial-Outcome error were fixed/re-reviewed. Parent supplied the other counts, including the later actual Canvas verification. Physical Android, subjective audio/enjoyment and hosted CI remain separate evidence.

Resume: finish019 first, then reconcile newly landed integration within this lane, re-review/recheck exact head and verify ancestry/mergeability before merging035, then mark DONE and update BOARD in one commit. Then036 and037, followed by the eligible queue. Source recovery refs pushed; no APK/main/production changes.

Latest CI repair: ordinary tutorial PHOTO was disabled after operation-context switches. Preserve tap-for-readiness feedback by restoring its existing enabled state, without bypassing simulation guards. Existing resolution-controls test RED32/2 then GREEN32/0 unchanged; renderedstudy24/routing83 pass, core818/0. Reviewer independently re-approved33fbb20 and personally resolution32/routing83/state10 clean.

23 Oct resume checkpoint: Pat's latest order is PR88, this PR86 (PRIORITY), PR87, remaining019,036,037. Last pushed branch claude/fix2-cold-review-full headad9cbb3 normally incorporates reviewed PR88 head9c9eef0 and current integration2ca9585/D3 as preparation. PR88 has NOT yet merged; before PR86 merges, merge its new integration merge commit and get final exact-head review/checks. Conflict resolution preserves successful-EMP ObservedStun.record at start of _finish_command before JobRelease/AllStop; rejected orders bypass it. Registry retains D3 plus all10FIX2 suites. Import,save12/0,IO4/0,optional20/0,routing83/0,state10/0 pass. Core,Canvas touch tests and independent review running. No APK/frozen-branch change.

Combined core818/0 atad9cbb381f63a0ae7ae0becfbf4c95f23ad6c991. Actual Canvas frontend63,fittings24,camera54,stun12,study24 all0failures; debrief7,resolution32,D3grade6,combat17 pass. Independent /root/review_integration approved exactad9cbb3 against9c9eef0/prior33fbb20 for preparation with no findings, source/conflict/registry checks only. CI39984851838 running; actual PR88 integration reconciliation/final checks remain required.

Final PR86 reconciliation after merged PR88: branch claude/fix2-cold-review-full last pushedfd2224affdaad25d16b2cfc74b049ca032c379c6 contains actual integration009f2b8600f4b22b24a5a5eba919ecf577d4a9f5 through a normal merge. Entire game tree byte-identical to approved/runtime-testedad9cbb3 (core818/0 and all focused/Canvas counts above); only RESUME changes after that preparation, so no redundant runtime rerun. Independent /root/review_integration approves exactfd2224a against009f2b8, no Critical/Important/Minor; personally ancestry/game-tree parity/docs/diff checks, no runtime rerun. Final exact-head CI pending; fresh integration/mergeability still required before merge.035 remains CLAIMED until merged.
