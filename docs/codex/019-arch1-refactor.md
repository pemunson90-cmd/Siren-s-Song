# Handoff 019: ARCH1, behavior-preserving cleanup of the shared choke points

Status: CLAIMED
Claimed at: 2026-10-23 03:35:16 UTC
Claimed by: codex
Finished at:

Precondition: handoff 018 must be DONE (so the refactor does not collide with it) and handoff 016 DONE (the test list file exists).
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (must end CHECKS N FAILURES 0), and only the tests for what you touched. Do not run the full scenario list locally; GitHub runs it. After any red game-smoke, also run the later tests in the CI list locally, because CI stops at its first failure. Never skip, loosen or delete a test.
Standing rules: read docs/codex/PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md (STANDING DELEGATION and STANDING ENGINEERING RULE) on claude/integration. Every feature is a self-contained module with one narrow seam, numbers in a data table, optional validated save fields, a revert note in the module header, tests beside it. No em dashes. Story text stays 1 to 2 line placeholders. Never change combat, beam, collision, damage, hull or Siren sight/hearing rules beyond what these handoffs say Pat approved. Do not commit generated .uid files that integration does not already track.

## Task (plain language)
Read docs/design/ARCH_AUDIT_1.md on branch codex/handoffs. Do steps 2, 3 and 4 of its ARCH1 plan, each as its own small pull request, each provably behavior-preserving: (2) one save-check registry (a save_checks list that features register into) plus the enemy-type list moved out of simulation.gd; (3) one shared "cancel_released" helper replacing the five hand-copied versions; (4) extract player orders out of simulation.gd command() into game/src/simulation/orders/ files behind one lookup table, one family per PR: weapons, then sensors, then route and drive, photo last. Prove each step: run the core suite before and after and show identical check counts, run the targeted suites named in the audit for that step, and let GitHub game-smoke run the rest. No renames, no rewrites of physics or sonar math, no changes to mission content rows, no new test layers. Pause new orders while an extraction PR is open (nobody else should be adding orders; if someone is, wait).
Steps 5 and 6 (main.gd extractions, HUD/ocean-view contract) are NOT in this handoff; they wait for a later one.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branches: claude/arch1-save-checks, claude/arch1-cancel-helper, claude/arch1-orders-weapons, and so on.

## Files you must not touch
Game rules and numbers (move them verbatim), mission content, story text.

## What done looks like
Each step merged with identical behavior (same check counts, CI green). Record the conventions note from the audit as docs/CONVENTIONS.md (under 30 lines).

## Return
PRs into claude/integration; merge per the line above; mark DONE and update the board.

## Completion

In progress, not DONE. Step 2 merged in PR81: https://github.com/pemunson90-cmd/Siren-s-Song/pull/81
- claude/arch1-save-checks: c7c5cfd9e97d0ea1e6bb04b924a0e1ac4ae69948; exact-head CI39896278323 guidance/game-smoke green; merged4e89cc37bac9d55fc160c1a4e0e6797bee4f1ff8.
- Step 3 PR83: https://github.com/pemunson90-cmd/Siren-s-Song/pull/83; claude/arch1-cancel-helper pushedfaff74e4189fb095ce2ecf23cd1af4d534c090d7; CI39898572326 green; mergeda7204e59d9ef5f9b5cfd5483a9c4bc1e015306ea.
- Prepared dependent lane claude/arch1-orders-weapons: 5893121.
- Prepared dependent lane claude/arch1-orders-sensors: 3427ef0.
- Prepared dependent lane claude/arch1-orders-route: 1474ba3.
- Prepared dependent lane claude/arch1-orders-photo: f25c5eb.
All lanes pushed. Each dependent step must merge fresh integration and open its own PR only after its parent has merged; exact-head guidance/game-smoke and mergeability remain mandatory. No force pushes, APK, main or production changes.

Godot4.6.3 import clean; core817/0 before and after every prepared step. Save checks: Well9/0, equipment10/0, divergence12/0, sweeper52/0. Cancellation: delivery63/0, witness UI108/0, module55/0 plus UI37/0 and runtime22/0, recipient69/0, Glass42/0+14/0+40/0+9/0+UI28/0, journey70/0; industry47/0, chain49/0, depth112/0. Weapons: combat17/0, knock59/0, decoy14/0, UI30/0. Sensors: depth112/0 and delivery63/0. Route: drone23/0, program35/0, all-stop31/0; real touch/UI route44/0, drone38/0, all-stop12/0, telemetry46/0. Photo: capture52/0, study save45/0, pricing64/0, depth49/0, rules49/0, UI9/0+11/0+4/0, departure45/0. Final injected-touch cold-review218/0 includes Android Back at cover/inner; headless locally, hosted CI owns rendered coverage. No physical-device claim.

Source comparisons preserve original order bodies after resolving receivers/constants and expanding the shared leg-mode helper; all41 keys registered exactly once. Original guard ordering, early returns and cleanup are retained. No game rules, save shapes, inputs, mission rows or test assertions changed. New modules have revert notes; CONVENTIONS is under30 lines. Independent reviewer /root/review_arch1 (fresh context, requested gpt-6.1-sol Medium) approved sourcef25c5eb6a66212d589b94e134087f29b11410aef against7089470: no Critical/Important/Minor findings, declined-to-judge[]. Relayed verdict is recorded in PR81 and PR83; CI gates remain separate. One first import in the separate baseline worktree hit a Godot threaded-import crash; clean reimport and affected baseline tests subsequently passed. No tests were loosened or skipped.

Resume:035 now has priority after merged PR83. Finish035, then merge fresh integration into claude/arch1-orders-weapons, open its own PR and continue through the dependent branches above. This task remains CLAIMED until every required step has merged. Mark DONE and update BOARD in one final commit only then.

During merge hold, prepared weapon lane normally incorporates reviewed03558cdeed and PR77:0c94966e12885e56679bc49d70ea1b087b7b9208 pushed. Conflict preserves successful EMP ObservedStun.record at start of shared finish hook, before unchanged JobRelease/AllStop; rejected orders bypass it. Independent reviewer re-approved exact head against58cdeed with token parity, no findings; parentcore818/0 and weaponcore818/0, combat17/knock59/decoy14/aimUI17/stunfeedback12/state10 pass. Sensors lane62c58e1 propagates same parent normally; core running, depth112/delivery63 pass. No new refactor PR yet;035 still has merge priority and Pat hold prohibits integration merges.

All prepared normal-merge lane heads now re-reviewed against03558cdeed: weapons0c94966, sensors62c58e1, routece4b481, final photo220fa18dfbeee14635fb1f89dc6be4e06978e155. Core818/0 at parent and every step. Sensor depth112/delivery63; route drone23/program35/allstop31 and touch44/38/12; photo capture52/study-save45/pricing64/depth49/rules49/audit45/routing83, touchcapture9/study24 anddeparture45 all pass. Study24 used actual Xvfb Canvas. Independent reviewer confirms all41keys once, exact body parity after receiver/constants/helper expansion, original-versus-selected craft cleanup, departure bypass and preserved PR77 plant/negative-study guards. No findings. Source ready; separate per-family PRs/exact-head hosted CI still follow035 integration, and all merges remain held.

Pat cleared merges and revised order: finish019, then035,036,037. Prior prepared lanes including035 remain published recovery refs; new final lanes branch from integration0df6796 and replay only each original refactor, keeping035 separate. Weapons sourcee60e840 independently approved against0df; final3cbba0a adds RESUME reconciliation. PR88 draftopen, baseline/head core817 parity and exact-head CI running. Do not merge the earlier035-containing preparations as019. Next sensors, route, photo each follow its merged parent.

Pure019 final sequence now prepared without035: weapon3cbba0a (PR88 ready, CI39912374021), sensor30dffdbaa2e1de0c65765fde61b498232b404cb8, routee98534f82fabaae157c4e1d925cf0f12e40c9295, photo53b5b6ed380b4c0076fa53132ca6ec6732712aa2. Freshintegration0df6796 and every family core817/0. Source reviewer confirms all41keys, exact-body/constant/receiver parity, guard ordering, original-craft cleanup andPR77camera guards; soleMinorprepared-handoff wording corrected in53b5b6e. These are the integration candidates; earlier035-containing recovery refs remain preserved. Actual merged-parent reconciliation, per-step RESUME update and exact-head CI remain required for each small PR.

Resume checkpoint 23 Oct 2026: Pat's latest explicit order is PR88, PRIORITY035/PR86,024/PR87, then remaining019 sensors/route/photo,036,037 and eligible numeric queue. Earlier conflicting order notes above are superseded. PR88 branch claude/arch1-weapons-final last pushed9c9eef070ba48439fc43d810e138a38aaf6c4153 contains current integration2ca9585 and corrects RESUME for merged D3/current queue. Independent reviewer /root/review_integration (fresh context, requested gpt-6.1-sol Medium) approved exact9c9eef0 against2ca9585: no outstanding Critical/Important/Minor findings; expanded weapon bodies equivalent, D3 preserved. Source/diff checks only by reviewer; parent combat17/0,knock59/0,decoy14/0,injected aim17/0. Core/baseline and exact-head hosted CI pending.019 remains CLAIMED until all steps land. No APK/main/production change.

23 Oct combined preparation checkpoint (not merged, no new step PRs yet):
- Sensors claude/arch1-sensors-final last pushedfc02923283af5a003e8e9d97b123525717491757 on audio1b26249; import/core818/0,depth112/0,delivery63/0.
- Route claude/arch1-route-final last pushedc8da548e0cef2ad489eb492259385f2ec14bc1f4 on sensorsfc02923; import/core818/0,drive23/0,program35/0,allstop31/0,touch44/38/12 all0failures.
- Photo claude/arch1-photo-final last pushed1b7e233be6c63fd5bac24c7486d69d2e2f130020 on routec8da548; import/core and focused suites ongoing. Capture52,study-save45,pricing64,depth49,rules49,audit45,routing83,captureUI9 all0failures so far.
All normally merge prepared reviewed035ad9cbb3 and0241b26249, not just older035 preparations. Independent /root/review_integration (fresh context, requested gpt-6.1-sol Medium) approved exact sensorsfc02923 against1b26249,routec8da548 againstfc02923,photo1b7e233 againstc8da548 for preparation with no Critical/Important/Minor findings. Reviewer independently expanded bodies/constants/receivers/leg-mode, all41keys once; shared guards, direct departure bypass, original-craft cleanup, PR77 photo safety,FIX2 observed-stun/routing,D3/audio intact. Reviewer source-only, parent runtime counts. No final-head CI or merge readiness implied: PR88 then035/86 then024/87 land first, then each019 step reconciles actual parent/current integration, opens its own PR, gets exact-head review/guidance/game-smoke, and merges in order.019 stays CLAIMED. No APK/main/production changes.

Final photo preparation1b7e233 completed core818/0. Remaining targeted tests studyUI24/0,Foundry departure25/0,navigation departure45/0 pass. All three prepared019families now import/core818/0 plus their affected checks, independent source review without findings. Earlier audit acoustic_scenarios/waypoint_scenarios are embedded in run_tests.gd, not standalone registry rows; their checks were included in each core run. All final per-PR hosted gates remain mandatory after actual parent merges.

PR88 weapons merged23Oct at009f2b8600f4b22b24a5a5eba919ecf577d4a9f5. Exact9c9eef070ba48439fc43d810e138a38aaf6c4153 passed guidance/game-smoke39984364375; source review /root/review_integration approved that exact head, fresh merge-boundary integration2ca9585 ancestor and mergeability verified. Post-merge fetch confirms9c9eef0 landed.019 remains CLAIMED for remaining sensors/route/photo. Next PRIORITY035/PR86,024/PR87, then019 remaining.

PR87/024 mergeda63aeeb after exact9b2f665 bothgreen39993951569;035/024 are DONE. Sensor step now PR90 https://github.com/pemunson90-cmd/Siren-s-Song/pull/90, branch claude/arch1-sensors-final last pushedc2d2876f4566782f4b3ea1d3b277c8ee66150bf7 normally contains actual integrationa63aeeb55f6fb5a4f46e769afc1e117cbe84335e. Whole game tree equals tested/reviewedfc02923; baseline whole game equals tested1b26249, so core before/after818/0,depth112/0,delivery63/0 unchanged and no runtime rerun for ancestry/docs-only merge. Final independent /root/review_integration approves exactc2d2876 againsta63aeeb, no Critical/Important/Minor; ancestry/source/doc checks only, no repeated runtime tests. Fresh own exact-head CI runs; merge only bothgreen/currentbase/mergeable. Next actual sensor merge, then route/drive own PR then photo own PR.019 remains CLAIMED. No new orders from other active PRs (only85data draft open when90 began).
