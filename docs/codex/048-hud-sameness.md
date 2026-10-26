# Handoff 048: HUD SAMENESS, operation-aware status text and an explained ARRIVALS button

Status: DONE
Assigned to: codex (Pat reassigned 25 October2026 Eastern, after040 and033)
Claimed at: 2026-10-25 23:51:10 UTC
Claimed by: codex
Finished at: 2026-10-26 01:38:35 UTC (25 October 2026, 9:38:35 PM Eastern)

Precondition: none; if handoff 023 or 038 still holds mission_hud.gd or main.gd, wait for it. Source: docs/design/COLD_REVIEW_3.md finding F14 (low confidence, first frame only). Presentation only.
Codex may merge: yes, into claude/integration only, after GitHub guidance and game-smoke are both green on the exact head and the PR is mergeable. Merge with a merge commit, then mark DONE and update docs/codex/BOARD.md.
Testing: import, core tests (CHECKS N FAILURES 0), and only the tests for what you touched. No full scenario list locally. Never skip, loosen or delete a test.
Standing rules: PLAN_SNAPSHOT.md and the top of docs/USER_DIRECTIVES.md on claude/integration. Touch-first (48 dp, Android Back = Escape), self-contained module, one narrow seam, numbers and strings in a data table, revert note in the module header, tests beside it. Push WIP every 30 minutes. No em dashes. Story text stays 1 to 2 line placeholders. Change no combat, beam, collision, damage, hull, oxygen or Siren sight, hearing or lock rule. Do not commit generated .uid files integration does not track, or .import line-ending churn. Windows: see docs/DESKTOP_HANDOFF.md.

## Task (plain language)
After tapping Quietus on 23 sampled operations the reviewer saw 8 late operations open with the identical status line "No exact source located · listen from another position or spend local RECON", including Iron Choir operations whose job is machinery, and a button "ARRIVALS 0" with no explanation. The review's op list (7, 10, 12, 23, 25, 28, 29, 30) is in player numbers (ids 6, 9, 11, 22, 24, 27, 28, 29); confirm by reproducing before editing.

### Verified sources
1. The line is produced in `_camera_context_base()` in game/src/simulation/simulation.gd:611, in the branch `mission.has("expedition_revision") and mission.objectives.all(captured) and not any own_origin`, returning "No exact source located · listen from another position or spend local RECON" when `mission.expedition_facts` is empty and mission.id != 8 (else "Observed %s · choose an available named recovery corridor"). The same sentence is therefore shown regardless of the operation's actual task. It reaches the player as `sim.message`/context text in game/src/presentation/mission_hud.gd (`intent.text` around line 399 and `instrument_info.text` around line 406).
2. The ARRIVALS button: game/src/presentation/mission_hud.gd:74 (entry ["arrivals","ARRIVALS"]), text set at :405 and :533 as "ARRIVALS\n%d" from `Expedition.measurements(sim)` (game/src/presentation/expedition_view.gd:9, :20 builds the "RECEIVED ARRIVALS" list). `Expedition.active(sim)` is `expedition_revision in [1,2]`. It is disabled when the count is 0 and never says what an arrival is.
Do NOT edit simulation.gd's context function (it is simulation text and other tests may assert it). Do the replacement in presentation: a new small module (for example game/src/presentation/status_text/status_text.gd with a table) called from the mission_hud.gd seam that sets the displayed text, which maps (mission id, existing state) to a clearer line and passes everything else through unchanged.

## Required behaviour (from existing state only)
1. Status line: when the sim text is exactly the "No exact source located..." sentence, show an operation-aware line chosen from existing public state: unfinished objectives and their kind (photo site, machinery or work site, recovery corridor), the active phase (`mission.get("phase")`), whether a work site or Iron Choir task is available (use the same accessors the HUD already calls, for example the work-site or choir accessors under game/src/campaign/encounters/work_sites.gd and iron_choir_operations.gd; read, never write). Examples of the intent: "Next: reach the machinery at A and work it" for a work-site op, "Next: photograph the three sites" for a photo op, "Source not located: listen from another position or spend local RECON" only when the task really is finding a source. Strings live in the table; one line each, 1 to 2 line placeholders. No hidden information: the line may only name things the player already knows (the HUD already shows known sites; do not reveal unknown positions or Siren data).
2. ARRIVALS: add a one-line explanation, shown when the button is disabled or first shown, such as "ARRIVALS 0: no signal has reached this craft yet" and "ARRIVALS 2: signals received (tap to read)". Keep the button label compact and the 48 dp target; if the label must stay two lines, put the explanation in the page the button opens and in the disabled state's tooltip/status line.
3. Ops where the sentence is correct (a genuine source search) keep their meaning; only the wording becomes explicit.

## Base and branch
Base: origin/claude/integration (fetch fresh). Branch: claude/lane-hud-sameness

## Files you may edit
mission_hud.gd narrow seam, the new status_text module and table, expedition_view.gd label text only, tests.

## Files you must not touch
simulation.gd, detection, hearing, lock, combat, save schema, operation tables.

## What done looks like
- A test table covering all 8 sampled ops plus op 1 and op 8 (the other branch): none of the Iron Choir and work-site ops shows the "No exact source located" sentence unless the task is truly a source search; assert the displayed string per op.
- Simulation text unchanged (sim.message and context byte-equal with the module on and off; module has an off switch).
- By real touch at both Fold7 shapes (2520x1080 and 2184x1968, helpers in tests/fix2_menu_ui_tests.gd): tap Quietus on at least four of the sampled ops, read the status line and the ARRIVALS control, no clipping, 48 dp targets, Android Back unchanged.
- Existing mission_hud, instruments and expedition tests pass unchanged.

## Return
PR into claude/integration. Merge per the line above; mark DONE and update the board.

## Completion
(Codex fills this in.)

### Historical reassignment,25October2026 Eastern

Pat explicitly approved Codex taking over this unfinished HUD task after040 and033. Historical Claude claim:2026-10-24 23:34:02 UTC. The verified interruption audit found read-only preparation and no implementation or PR. Reopened and assigned to Codex, not yet claimed;040 remains the sole active claim. Original presentation-only scope and verification gates remain. Hunt050 detection changes remain held for Pat. No HUD implementation is claimed by this record.


### Historical implementation checkpoint, 25 October 2026, 8:25 PM Eastern

Claim193be78c follows033's verified mergee0ee34d3. Pat approved continuing048, then050 sight-only Hunt; the earlier reassignment paragraph's040-active and Hunt-held statements are historical. PR146 is a draft: https://github.com/pemunson90-cmd/Siren-s-Song/pull/146 . First coherent WIP30bcbbd0 is published, not merged or DONE.

Reproduction confirmed the exact fallback in all eight sampled operations. Correction to the verified-source note: on STATUS the actual displayed fallback comes through Main's detail_label; selecting Quietus sets sim.message to a different selection message. The narrow MissionHUD adapter changes displayed labels only. Simulation context and messages remain byte-equal. Public recovery availability takes priority over machinery wording; no hidden locations or Siren data are exposed.

New status_text module owns pure wording, string table, view adapter and independently reversible layout table. Table.enabled=false restores prior presentation; Layout.enabled=false restores prior geometry. ARRIVALS now counts received signals and displays an explanation even at zero. Actual cover-view baseline showed off-screen controls and Back; the adapter fits the existing full-size radial controls and scrollable sheets to the viewport without changing fonts, command order or simulation. Existing drawing/input helpers remain in use.

Development evidence: import clean; core836/0, status wording74/0, headless interface1208/0, native Windows interface1412/0. Native tests inject actual touch and Android Back on both Fold7 viewport shapes at150percent text. These are development checks, not final exact-head acceptance or physical-phone proof. Original failing geometry/progress probes and baseline images remain in048-evidence. Unchanged affected suites, final exact-head independent review and hosted gates remain pending.

Pat requested focused official web research and reuse of established solutions on25October. Godot4.6 Control and Container documentation confirms viewport/input ownership and container-managed positioning. The implementation retains the project's existing controls, touch harness and radial math; only its viewport fit needs custom geometry because the existing command ring is custom drawn. References: https://docs.godotengine.org/en/4.6/classes/class_control.html and https://docs.godotengine.org/en/4.6/tutorials/ui/gui_containers.html . Reuse these findings rather than repeating retrieval without a new question.


### Historical verification checkpoint, 25 October 2026 evening (superseded by verified completion below)

PR [146](https://github.com/pemunson90-cmd/Siren-s-Song/pull/146) is ready for review, not merged. Final proposed head: e1dbc026b851d13bf50d6d01abe2d4e60395d379. It contains current integration e0ee34d356d61c42e9809305647415c103e3cf84. Earlier draft and pending-review statements above are historical.

Independent nonauthor reviewer /root/save043_architect returned PASS with no actionable P1/P2 findings. Root verified the actual logs and capture hashes/dimensions. Requested checks passed: core 836, wording 74, headless UI 1,208, native UI 1,412, and unchanged affected suites 343, totaling 3,873 assertions with zero failures. An external refresh/resize/inverse-hit/off-switch probe passed 764 checks. Final-head import, registry validation of 277 suites, guidance and its 10 regressions passed. Initial import/core provenance across the three-line documentation-only final update is explicit in the assessment; game/scripts were byte-identical.

The original external probe's 8 exact-floating-equality failures and one incorrect-path diagnostic remain preserved. Measured rounding was 0.00006103515625 pixels. The corrected external diagnostic uses a justified subpixel threshold; no shipped assertion was changed. The registered geometry, overlap, 48 dp, touch and state-purity tests remain strict.

[Independent review comment](https://github.com/pemunson90-cmd/Siren-s-Song/pull/146#issuecomment-6405622605). [Evidence archive](https://github.com/pemunson90-cmd/Siren-s-Song/tree/2cc0ac23/evidence/048-windows-20261025): baseline/development ZIP has 145 members; independent ZIP has 63. Root reopened both committed ZIP blobs and verified every member. Raw failed evidence is retained alongside passing results; isolated userdata/caches remain locally preserved and excluded from publication.

Hosted run 40249328277 has passed guidance; game-smoke is still running. No DONE claim until final exact-head gates pass and the merge is verified. These are desktop technical checks, not full-campaign, blind-player or physical-phone acceptance. After verified completion, 050 remains the next authorized sight-only task.


### Verified completion, 25 October 2026, 9:38:35 PM Eastern

[PR 146](https://github.com/pemunson90-cmd/Siren-s-Song/pull/146) merged with a merge commit as 0fb3873e4c0650560d57d19c89b106ae3803747c. Root fetched the remote and verified GitHub merged=true, parents e0ee34d356d61c42e9809305647415c103e3cf84 and e1dbc026b851d13bf50d6d01abe2d4e60395d379, and landed tree 6e95c61778004e83f1853c74d1991ef2d2782dc9 equal to the tested tree. Source branch retained. No promotion.

Eight sampled operations now receive public-state-aware STATUS wording. Public recovery readiness takes priority over machinery guidance. ARRIVALS explains the received-signal count, including zero. Actual touch reproduction uncovered existing cover-screen clipping; the presentation adapter fits existing full-size radial controls, scrollable sheets and Back to both required shapes. No simulation context, save, operation-table, sensing or combat rules changed. Table.enabled=false restores prior presentation; Layout.enabled=false restores prior geometry, including its historical clipping.

Independent nonauthor PASS [6405622605](https://github.com/pemunson90-cmd/Siren-s-Song/pull/146#issuecomment-6405622605) covered all changed files and actual import/core/named tests: 3,873 requested checks, zero failures. An external refresh/resize/hit/off-switch probe passed 764 checks. Original precision and path failures remain in the record; no shipped assertion was loosened. Final-head import, registry validation of 277 suites, guidance and 10 regressions passed. All 28 independent native capture dimensions/hashes were verified by root.

Hosted run [40249328277](https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/40249328277) passed guidance and game-smoke on the exact head: 280 summaries, 19,091 checks, zero failures or actual script/runtime/leak errors. Root verified the complete 14-member hosted ZIP. Cached partial log URLs were refreshed before final acceptance; all earlier partial snapshots are exact prefixes of the final log and remain archived. Superseded WIP cancellations are not acceptance.

[Final evidence archive](https://github.com/pemunson90-cmd/Siren-s-Song/tree/492f484b78c6cc6f3cc7659969d3d1e6119fd72d/evidence/048-windows-20261025) contains baseline/development (145 members), independent review (63 members), full hosted logs, original failures and merge verification. Root reopened all committed ZIP blobs and verified every member. Native screenshots and source-known fixtures establish technical desktop behavior, not whole-campaign, blind-player, phone or human acceptance. No APK was built.

Documentation reconciled: new module/tests/reverts in MODULES, capability wording in CURRENT_GAME_SPEC, the source/next-task boundary in RESUME, and Pat's research/reuse instruction in USER_DIRECTIVES. Historical reassignment, draft and pending-review statements were labeled in place; failed evidence was preserved. This handoff and its board row close together. Next authorized task: claim 050 for sight-only Hunt; hearing, movement speed and lock timing remain unchanged.
