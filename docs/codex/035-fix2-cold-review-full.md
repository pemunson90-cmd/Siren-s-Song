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

Checkpoint: PR86 https://github.com/pemunson90-cmd/Siren-s-Song/pull/86; branch claude/fix2-cold-review-full pushed272eea93444e9cf19b2a11a4c19e84617e3e847b, integration basea7204e59d9ef5f9b5cfd5483a9c4bc1e015306ea. All implementation complete; exact-head CI39904552528 pending. NOT DONE until green merge.

Item dispositions:
1. Cause: legitimate incomplete-feature photographic retakes were rejected merely because the site was already captured. Narrow photo exemption preserves target/type/finite/duration/duplicate guards. Mid-retake real save/reload12/0; actual transient/persistent I/O retry4/0. Optional photos also exposed two old all-records assumptions; required-job strictness retained, optional recovery20/0.
2,8. Android Back and Escape route overlay detail to list to title; Settings/list/detail Back at top; confirmed Erase moved into Settings. Real touch bothFold and960x432:63/0.
3. Ops4–6 short GOAL/DANGER; generic repeated orders/rules afterop2 moved behind manual. Later unique operational procedures inspected/retained under conditional scope, no narrative rewrite.
4. Separate Fittings; all named hull/chassis choices; Resume after mission rows. Real touch24/0; old frame selection test updated to explicit choices,73/0.
5. Not reproduced: optional validated hints_seen already persists. Actual fresh-launch regression confirms seen hint remains. No redundant field added.
6. Optional validated observed_stun only on already earned visible optical contacts, immediate post-Disrupt presentation and countdown; no enemy/rule writes. Real touch+hint reload12/0, strict state10/0.
7. Camera font/touch/text scale and reduced motion; sharp/light bars and numbers in separate strip, film counter preserved. Suppress duplicate emulated mouse toggles.150percent text+flash+tight+focus tested by touch,54/0.
9. Existing fleet and menu targets measure56.0dp cover,56.55dp inner at420dpi fixture, so reported undersize did not reproduce there. Camera targets raised above48dp. Desktop window pixels do not establish physical Android dp.
10. Added classic/expedition loss line from own state/last observed range only; no hidden detection calculation. State tests10/0.
11. Same-band Sirens work in every requested op6–10 and22–29 (83/0), cross-band rejected. UI overrides and study-index crashes also repaired; real touch study24/0. Optional photos on ids7/8 now route for020. Ready jobs, exposures and powered plant work retain precedence.

Import clean; core818/0 (one additional target check for reset's Settings location). Existing focused passes: loadout38,briefing50,onboarding30,capture52/UI9,depth49,contact reports36,Shelf journey33,lockUI14,cold review218,challenges86. No tests removed or loosened. Independent read-only reviewer /root/review_fix2 (requested gpt-6.1-sol Medium, fresh context) approves exact272eea9 vsa7204e5: no remaining Critical/Important; two Important camera findings fixed/re-reviewed. Personally ran state10 androuting83; other counts parent-reported. Declined physical Android/render/audio/difficulty/CI judgement. Relayed review belongs in PR86 before merge.

Resume: inspect exact-head guidance/game-smoke, fix any CI failure, merge only if mergeable and fresh integration is an ancestor. Then mark035 DONE and update BOARD in one commit, finish019's four remaining PRs, then020. Source recovery refs are pushed; no APK or physical-device claim.

Pat's merge hold: leave PR86 open even when green. Do not merge into integration until Pat explicitly clears merges;45minutes is only an estimate. Claude is landing77/79/82/84. Fetch resulting integration and reconcile source conflicts/checks within the lane as needed, preserving their changes. Continue024 audio source work meanwhile.

CI39904552528 failed at rank102 campaign_debrief_view_tests: new loss line assumed full Sim, but existing lightweight Outcome has no oxygen/hull/contact observations. Reproduced strict runner failure despite7/0 assertions; fixed missing-data handling without weakening fixture. Targeted debrief7/0 and state10/0 clean, core818 rerun in progress. New source checkpoint/CI must replace prior approval head before ready. GitHub job-log tool transport failed; the run-log ZIP API worked, evidence retained under /workspace/fix2-ci-logs. No merge.
