# Early Module Reward Implementation Plan

> Execute inline with superpowers:executing-plans; one final independent review.

**Goal:** Grant one existing Tele lens after operation1's successful recovery, ready to equip, with NEW FITTING in the debrief.
**Architecture:** A small early_reward module owns the grant table, optional validated archive state, entitlement projection and explanatory text. Existing equipment selection, physical inventory and launch validation remain authoritative. The reward never auto-equips or touches Simulation.
**Tech Stack:** Godot4.6.3/GDScript, Compatibility renderer.
**Spec:** Approved D2, handoff037 on codex/handoffs and USER_DIRECTIVES.

## Constraints and review focus
- Operations0..5, bare hull/oxygen/combat/detection and all module rules stay unchanged.
- Table: enabled flag, operation1, existing quietus_tele_lens. Its existing range/framing trade teaches photography in ops2/3, at zero cargo and one power on the standard hull.
- Grant once, only on success. Old saves default to no grant; flag off stops new grants and preserves owned equipment.
- Save/load validation, active-versus-next-launch fitting, retry/replay/new-campaign reset, and optional-only progression are review priorities.
- Touch targets remain48dp and Back remains unchanged. No story, APKs, em dashes or promotions.
- Merge92 then93 first; reconcile their actual integration before final037 review/CI.

## Task 1: Grant and presentation
Create game/src/campaign/early_reward/{reward_table,early_reward}.gd and functional/UI tests. Narrow calls in main's completion/entitlement/archive/reset paths, SaveStore's existing entitlement validation, and Fittings' introductory text. Append unique test registry rows after reconciliation.

- [x] Write/run failing functional checks: op/outcome filter, once-only, off switch, retained entitlement, malformed optional field, old archive and legal standard-hull fitting.
- [x] Implement pure grant/state/entitlement helpers and narrow integration.
- [x] Write/run failing actual-game touch checks: successful debrief line, failed/repeated reward, saved/reloaded ownership, ready fitting, explanation, equip/unequip, new campaign reset, both Fold7 shapes.
- [x] Implement presentation and persistence; pass actual Canvas checks.
- [x] Preparation import, core818/0 and affected fitting/save suites; compare all six core campaign wins/hull/time to baseline /tmp/ss-route-core.log. No full scenario list locally.
- [ ] Push WIP, record SHA in037 Completion; independent review, actual-parent reconciliation and exact-head CI before merge; DONE plus BOARD in one commit.

Builder choice: Tele lens changes an already implemented photographic choice without a combat rule or opening balance change. It is owned but initially unequipped; the player can retain BARE. Revert by table.enabled=false, retaining state/entitlement loading for saves.

Execution ledger: missing-module RED then functional36/0; missing actual-campaign property RED then actual Canvas/injected-touch40/0 at both Fold7 shapes. Existing earned equipment12/0, equipment-save10/0, photo pricing64/0, FIX2 menu24/0. Import/exits clean; core running. Simulation tree equals integration70b1f18. Reward is optional and never auto-equips. Published recovery lives in037 Completion; one final designated reviewer checks the whole feature.

Composition checkpoint: actual019 photo integrationdb6b162 and approved proposed036 head57806a3 are included by normal merge while PR93 checks run. Kept both archive writers/validators and cue188/189 plus reward190/191 test rows. Reward module/Fittings/tests equal approvedcc808d3; cue module/tests and complete Simulation equal approved57806a3. Clean actual Canvas40/0 and50/0 with explicit dummy audio driver; first invocation passed assertions but workspace ALSA startup failed, so rerun clean. Core/save checks running. Still reconcile actual036 merge and obtain final review/exact CI before037 merge.

Actual-parent checkpoint: normal merge contains actual036 integrationea78d3d after PR93 passed exacta0f5cba guidance/game-smoke40023109430.019/036 DONE;037 current, existing020 next. Entire game tree equals preparation29a97f3, including reviewed deterministic cue fixture; previous core818/0, reward36/0, cue37/0, Canvas40/0 and corrected52/0, save/equipment checks and six campaign-result parity remain applicable. Only RESUME/this ledger change; no redundant runtime rerun on identical game files. Obtain final exact-parent review and own exact-head CI before merge.
