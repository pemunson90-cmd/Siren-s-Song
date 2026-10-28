# Handoff 079: IRONMAN SAVE INTEGRITY (NO HARD-SAVE OR FORK UNDO BYPASS)

Status: CLAIMED
Claimed at: 2026-10-28 00:48:49 UTC
Claimed by: codex-root-resume
Finished at:

Precondition: none. Read ORCHESTRATION_2026-10-26.md first.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

Source: Claude gap scout 27 Oct (four scanners, two adversarial verifiers per gap, completeness critic). AI-DESIGNED scope; owner may adjust.

## Task (plain language)
Make Ironman mean a single timeline. For a campaign whose economy has ironman=true, hide or disable manual hard saves and 'restore' from fork states in the SAVE2 UI. Keep the automatic safety checkpoint and crash recovery (.bak) untouched. Use a plain explanation line, for example 'Ironman keeps one timeline.' The Ironman panel text and its one-way confirmation must say this before the player commits. Restoring any previously taken state must never be able to turn ironman off. Existing non-Ironman behavior stays identical. This changes only save UI and archive rules, not simulation.

Spec basis: CURRENT_GAME_SPEC.md 'Default economy': "Survival retains heavy attrition with optional Ironman".
Evidence it is missing: economy.gd gives Ironman only two effects: every fitting is charged on every launch (refit_cost) and the preset is locked (cycle_preset returns false). git grep -i ironman over game/src/persistence returns nothing, so SAVE2 (persistence/save_states/save2_controller.gd and save2_ui.gd: 3 manual saves, 4 fork states, exact restore) is fully available to an Ironman campaign. A player can restore an earlier state, and that state's economy block also carries ironman=false, so the 'one way' flag can be undone. Ironman is currently a pricing flag only.

Orchestrator note: Claude lane C14. Ironman = one save timeline: no hard-save restore or fork replay that undoes an Ironman campaign's outcomes; make the limit visible before Ironman is chosen. Do not add other Ironman penalties (owner question pending).

## Base and branch
Base: origin/claude/integration (fetch fresh). Create branch: claude/c14-ironman

## Files you may edit
persistence/save_states/save2_table.gd, save2_controller.gd, save2_ui.gd; presentation/economy_panel.gd (warning text); campaign/economy.gd (one read helper); tests extending economy_save_tests and the save2 suites. Needs a pinned ironman flag in the save2 record validator.

## Files you must not touch
 Lock, beam, collision, damage, hull rules, Siren senses, photography design. Files owned by any other CLAIMED handoff.

## Checks
Import + core. Never more than ORCHESTRATION section 5 requires. Suite ranks: local 570-579, CI 670-679.

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
(five lines max)

Recovery28Oct04:52UTC: root resumes prior Claude lane with existing uncommitted edits last written27Oct20:51-20:57ET. Preserve and snapshot owned source before updating integration. Bounded worker owns this existing branch; no duplicate lane is active. Current Pat ruling is continuous development within protected design limits.

Progress28Oct05:01UTC [KEEL, verified]: inherited WIP preserved/pushed asd116e409 before integration reconciliation; PR168 head01d60552. Isolated import/core846/0, integrity40/0, profiles68/0, storage194/0; guidance passed; game-smoke40635419209 running. Only079 resumed; root retains queue.
