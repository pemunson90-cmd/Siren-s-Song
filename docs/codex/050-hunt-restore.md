# Handoff 050: HUNT RESTORE, V7 global Hunt pressure made visible

Status: CLAIMED
Claimed at: 2026-10-26 01:41:36 UTC
Claimed by: codex
Finished at:

Precondition: handoff 023 is DONE or paused by Pat (it holds main.gd and HUD files), and the design PR for docs/design/HUNT_RESTORE.md is merged into claude/integration. If roadmap Phase G (AI state trace) has landed, log hunt stage changes through it; if not, build without it. Source of truth: docs/design/HUNT_RESTORE.md (read it fully; section 8 lists numbers Pat may still adjust, build them from the table so changes are one-line edits). Pat, 24 Oct: "we also need to restore the hunt mechanism from v7 parity". AI-DESIGNED details, Pat to ratify.
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (CHECKS N FAILURES 0), and only the tests for what you touched. No full scenario list locally. Never skip, loosen or delete a test.
Standing rules: PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md on claude/integration. Touch-first (48 dp), self-contained module, one narrow seam, numbers in a data table, optional validated save fields, a revert note in the module header, tests beside it. Push WIP every 30 minutes. No em dashes. Never change the 4 s lock window, beam, collision, damage or hull rules. Do not commit generated .uid files that integration does not track, or .import line-ending churn. Windows: see docs/DESKTOP_HANDOFF.md.

## Task (plain language)
The Hunt meter already exists (game/src/simulation/recon_consequences.gd) but only changes a hidden per-Siren multiplier. Make the global Hunt scale how far Sirens notice a craft, as V7 did, and make it visible and audible.
1. New module game/src/simulation/hunt_pressure/ with hunt_table.gd (all numbers, a static enabled flag, revert note) and hunt_pressure.gd (pure functions). One seam: HuntPressure.observe(sim, dt) called once after Recon.tick in simulation.gd, plus one changed line in Recon.readiness: the larger of the existing local value and the guard's hunt_scale. Stamp hunt_scale only on patroller, sentinel, hunter and sweeper. Use the V7 stage table 1.0, 1.15, 1.3, 1.5, 1.7, capped by the per-op table in the design doc (ops ids 0 to 2: 1.00, 3 to 5: 1.15, 6 to 13: 1.30, 14 to 21: 1.50, 22 to 29: 1.70).
2. Action table per the design doc: decoy and survey change from 4 to 0, add +6 when any Siren starts seeing a craft after none did; everything else unchanged. No graze, no hull damage, no goals or reports given to Sirens.
3. Meter in presentation/hunt_meter.gd: chip "HUNT · STAGE x1.30" with five pips, word plus pips (not color alone), at least 48 dp tall, visible in basic and advanced HUD, clear of the warnings stack, tap to explain in pause. Verify both Fold7 shapes and 960x432.
4. Sound: a stage-up cue (at most one per 3 s) and ambience offset +0, +1.6, +2.9, +4.1, +5.1 dB by stage, capped at +3 dB on ops 0 to 5. Update the soundscape comment that says Hunt is never read.
5. Optional validated save field mission.hunt_pressure {revision, stage, seen}; absent means inactive (old saves and in-progress ops unchanged). Register the validator beside the others in persistence/save_checks.gd. Confirm saved Siren validators accept a hunt_scale key or exclude it from snapshots.
6. Flag off gives exactly today's behavior.
Tests (new suite, append to tests/suites.txt): determinism and save/restore replay; each action adds its table amount; decay, delay and floor; cap per op; excluded roles unscaled; max rule with a local floor; lock/beam/damage identical flag on and off; old save loads unchanged; corrupt field rejected; meter by real touch; ops 1 to 5 journeys still win bare with identical results; photo price tests rebased only above stage 0.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-hunt-restore

## Files you may edit
The new hunt_pressure module and its tests, presentation/hunt_meter.gd, the one readiness line, the one observe call, the soundscape read of the stage, the save-check registration, one HUD anchor call.

## Files you must not touch
Lock, beam, damage, hull, collision rules, sensors outside readiness, patrol goals and routes, contact reports, listening network, story text, opening balance.

## What done looks like
Hunt raises Siren notice radius by the V7 stage factor within caps, shown on the HUD in every mode, audible on stage rise, off-switchable, old saves untouched, tests green, CI green on the exact head.

## Return
PR into claude/integration. Merge per the line above; mark DONE and update the board.

## Completion
(Codex fills this in: what changed, PR link, branch and last pushed SHA, test results, unverified items, files outside ownership needed, recommended next.)

### Pat decision, 25 October 2026 Eastern: sight-only first

Pat accepted the recommendation to test sight-only Hunt first: global Hunt may increase sight notice range, but hearing, movement speed and lock timing must stay unchanged. This supersedes the proposed shared-readiness seam wherever that seam would increase hearing or speed. V7 sight-only behavior is the first implementation target. Keep the existing off switch, operation caps, protected combat rules, save compatibility and verification requirements; prove hearing and movement behavior unchanged with the flag on versus off. Do not treat this as permission to add hearing scaling later.

Pat authorized Codex to carry this work forward after040,033 and048. No second active claim is opened here;040 remains active. Historical Claude claim above is preserved until formal takeover. This records authorization and intended order, not implementation or passing tests. Automated checks precede merge; phone and human testing remain deferred under Pat's standing feature-complete-and-tuned rule.


### Formal takeover and current scope, 25 October 2026 Eastern

048 is DONE and merged as 0fb3873e. Codex now claims 050 as the sole active handoff. Historical Claude claim: 2026-10-24 23:34:02 UTC; the interruption audit found a merged design proposal but no implementation. The preceding decision note's 040-active and formal-claim-pending statements are historical.

Pat's sight-only approval supersedes the original shared Recon.readiness seam wherever it would alter hearing or movement. Implementation will preserve local readiness for hearing/speed and apply max(local readiness, capped global Hunt) only to the eligible sight calculations and truthful photo-price estimate. Lock timing, beam, collision, damage, hull, routes and contact reports remain protected. The original proposal is retained as evidence and will be labeled/reconciled at the authorized source boundary.

Ordinary numbers, caps, display/audio choices and revert switches remain tunable table defaults under Pat's continuation instruction. No new story, graze damage, hearing scaling, phone testing, APK or promotion is authorized. Focused official documentation and existing project helpers will be checked before implementation. Final exact-head independent review and both hosted gates remain mandatory.


### Implementation plan, 25 October 2026 Eastern

1. Reuse existing Recon pressure, delay, decay and secured-record floor. Add a pure Hunt table/module with an optional validated mission state. Initialize only fresh operations; an absent field keeps old/in-progress saves inactive. Keep validation active even when the feature switch is off.
2. Keep Recon.readiness unchanged for hearing. Derive max(local readiness, capped global Hunt) through a separate pure sight helper at the three existing sight uses and matching photo-price estimate. Avoid duplicated guard hunt_scale save fields. Eligible roles only; no patrol, hearing, movement, lock or combat changes. IDs 30/31 use a conservative table cap of 1.00 until their distinct finale balance is assessed.
3. The existing action path records a public last-cause label in the module-owned state; decoy/survey pressure becomes zero only for opted-in missions. The observe call follows Recon.tick and detects the transition from no visual craft targets to some using completed guard state. It changes no goals, positions, reports or damage. Add optional validated cause/cue-clock bookkeeping so save replay and the three-second cue limit remain deterministic.
4. Reuse existing generated audio and Soundscape event/lifecycle paths for a stage-up cue; apply the table ambience offset through the existing player. Extend the already attached, read-only AI trace to record stage changes; no new runtime trace infrastructure.
5. One new Hunt meter uses the existing Button, help sheet, touch harness and Back behavior. A narrow HUD sync anchor and basic-help return branch support it. Word, five pips and global factor stay visible in basic/advanced views at full touch size. Old pressure text restores when inactive. Reuse 048 viewport fitting and preserve genuine warnings.
6. Add focused pure/integration/native UI tests. Reserve local ranks 264/265/266 and CI ranks 284/285/286. Prove legacy/off behavior, save validation/replay, caps/roles/max rule, action/floor/edge behavior, unchanged hearing/movement/lock calculations and successful unchanged bare opening journeys. Keep original failures; run import/core/affected tests, independent exact-head review and full hosted gates.

Ownership rationale: the original shared-readiness proposal cannot satisfy Pat's approved sight-only boundary. Its replacement necessarily changes the existing sight call sites and price mirror while retaining the shared helper. Public last-cause bookkeeping belongs at existing Recon action/secured paths, not a guessed display label. These are narrow seams in the named systems, not new sensing rules. Root owns these integrations and validators; the implementation worker owns only new meter files/tests. Final review remains independent and nonauthor.

Focused official research: Godot 4.6 Dictionary preserves insertion order and supports explicit deep duplication; AudioStreamPlayer provides existing nonpositional playback, volume_db and stream_paused lifecycle. References: https://docs.godotengine.org/en/4.6/classes/class_dictionary.html and https://docs.godotengine.org/en/4.6/classes/class_audiostreamplayer.html . Existing project Recon, validators, generated audio, AI trace and UI harness are preferred over replacement infrastructure.


### Historical first coherent WIP, 25 October 2026, 10:07 PM Eastern

Draft [PR 147](https://github.com/pemunson90-cmd/Siren-s-Song/pull/147), branch claude/lane-hunt-restore, head c34e7ba6ce7f144890e90584909f3ed0f0ff942d, base 0fb3873e4c0650560d57d19c89b106ae3803747c. Published within 30 minutes of the claim. Not merged or DONE.

Actual development checks: baseline/import clean; core 836/0; pure Hunt 88/0; first integration 13/0; first coherent meter headless 127/0 and native GPU 138/0 with 11 captures. Registry validation covers 280 suites with zero errors/warnings. Reuse of existing pressure, strict save codec, standard controls/help/Back, generated audio and AI trace is implemented. Shared Recon.readiness remains unchanged; only the separate sight helper and matching price ring use global pressure.

The first integration runner used nonexistent disk-save method names and was terminated after its script error; its helper printed a nominal timeout despite roughly 62 seconds elapsed. The failed log remains. The corrected RED run reported 13 checks/8 failures, including an invalid late-campaign save-envelope fixture; the final test reuses the existing valid opening save envelope and passed 13/0 after integration. These original probe/runner failures are not acceptance.

The existing 960x432 HUD at 420 dpi/150 percent text has clipped controls and an extremely short help sheet. The new chip fits, but its own help readability is a current blocker: the worker is adding a module-owned compact sheet/Back layout with strict readable-row and touch-scroll assertions. Broader legacy/replay/action/audio/trace tests, unchanged opening journeys, source-document reconciliation, independent exact-head review and hosted gates remain pending. No existing assertion is being loosened or removed.


### Current corrected-head verification checkpoint, 25 October 2026 late evening Eastern

[PR 147](https://github.com/pemunson90-cmd/Siren-s-Song/pull/147) remains unmerged. Proposed head 39d855151534dc81a277e34367341c8711e320cf contains current integration 0fb3873e4c0650560d57d19c89b106ae3803747c; tree 59584924554d285b33337ee8f38b7b88bd8002da. The single observer now commits at the end of the completed step; the earlier plan's before-threat/photo placement is historical. Actual sight/photo ordering regressions failed 66/2, then passed 66/0 after the scoped fix.

The earlier head b7addca4 is BLOCK/HOLD, not acceptance. Hosted run 40261655770 passed guidance/import/core but failed unchanged route_telemetry_touch_tests 46/1. The new card overlapped the full projected craft touch handle by three pixels, even while missing its center. Fleet consequently marked the craft offscreen and changed manual camera from free to follow. Its full failed run and original tests are preserved.

The corrected new meter reserves public live own-craft touch/pick footprints using the existing Ocean projection and performs one deferred HUD refresh after moving off a craft. Compact text reflows without reducing font or target size. The existing route test is unchanged and now passes 46/0; the focused new regression passes 226/0 headless and 247/0 native with 21 captures, including before/after actual craft touch. Stage4 pulse, lock-warning clearance and compact help/scroll remain verified. New final independent review and hosted run 40264491315 are running; no DONE claim until exact-head gates and verified merge.

Independent nonauthor b7 local results were 2,451/0 across 29 processes, but the reviewer explicitly held acceptance for the hosted failure. [Relayed HOLD](https://github.com/pemunson90-cmd/Siren-s-Song/pull/147#issuecomment-6407448853). Root verified every raw result and all 17 capture hashes/dimensions. [Evidence archive](https://github.com/pemunson90-cmd/Siren-s-Song/tree/44ec318bb4f15126e8c18fc998479bbe69f2ec65/evidence/050-windows-20261025) preserves 194 original development paths as 150 unique ZIP members, 67 independent HOLD members and the complete 20-member failed hosted run. Exact byte duplicates are mapped, not deleted. Root verified all committed ZIP blobs and every member.

Fourteen unchanged photography journeys pass 632/0 with Hunt enabled. All five unchanged opening journeys pass 49/0 each with Hunt ON/OFF and identical reported outcomes/time/hull/oxygen/survivors/tools. These are technical fixtures, not whole-campaign or phone acceptance. Earlier unrelated 960 basic/radial clipping remains documented; new Hunt help itself is readable, touch-scrollable and preserves full Back.

Conservative scope is explicit in the source design and PR: the +6 edge reads ordinary craft lock/beam states. Separate interceptor/warden visual windups and listening buoy/relay systems retain their previous behavior; all-eight-role acquisition edges are not claimed. Global sight scaling remains limited to the four eligible ordinary roles. Hearing/movement/lock/combat rules remain unchanged, with the single reversible flag and explicit operation caps.


### Hosted density HOLD, 26 October 2026 just after midnight Eastern

Final local independent review of39d855 completed 37 requested processes with2,895/0 plus152/0 external refresh checks. Relayed verdict6407906269 is PASS only for that local scope. Hosted40264491315 subsequently passed guidance/import/core but failed unchanged density_scenarios1,084 checks/21 failures, all Hunt card text below the existing14 fixture dp minimum. Head39d855 is HOLD and remains unmerged. The UI worker is reproducing only that affected suite before a scoped fix; no full local matrix or repeated unrelated suites are being run. The previous checkpoint's pending-review wording is historical.

Archive887a41e9 preserves full failed hosted logs plus the craft-tap correction's original RED/GREEN logs and screenshots. Root verified49 unique delta members,205 exact baseline references and all20 failed-hosted ZIP members. No original failure, assertion or evidence was removed. Further source changes require a fresh exact-head independent verdict and green hosted gates before DONE.
