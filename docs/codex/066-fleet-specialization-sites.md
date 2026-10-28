# Handoff 066: Make hull, chassis and the new tools matter through optional fleet-specialization sites

Status: CLAIMED
Claimed at: 2026-10-28 06:12:07 UTC
Claimed by: codex-root-parallel
Finished at:

Precondition satisfied: 055 DONE, PR150 merged609f29a9. Continue only066 on claude/lane-fleet-sites; root owns current-head hosted CI/merge. Read ORCHESTRATION_2026-10-26.md first.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

Source: Claude gap scout 27 Oct (four scanners, two adversarial verifiers per gap, completeness critic). AI-DESIGNED scope; owner may adjust.

## Task (plain language)
Author four to six optional sites in existing regions that reward a specific fleet choice, using existing primitives only (cargo, machine, listen sites and current or thermal lanes).
- Heavy or Fast: an optional cache of three physical cargo items that standard craft can only carry in two trips.
- Scout: a passive LISTEN account reachable only from outside the Sirens' approach, using the longer passive reach.
- Endurance: a long loiter job that exceeds a standard drone battery.
- Quiet hull: a short approach lane where motion noise decides whether a nearby listener hears the craft.
- Tools: one site where a silt screen breaks a sight line, one where a sonobuoy bearing shows a patrol gap, and one where a relay buoy extends a drone's listening.
Pay off in recovered notes, scrap or alloy through the existing economy table. State in the briefing which fleet choice helps.

Spec basis: CURRENT_GAME_SPEC: "Missions connect approach, sensing, fleet allocation, objective priorities and withdrawal through multiple viable strategies"; "Typed mounts and power/noise/endurance/cargo budgets create actual tradeoffs"; acceptance requires "actual strategic alternatives".
Evidence it is missing: Hulls and chassis act only as global multipliers: speed, noise, endurance, reach, pulse and winch capacity, via craft_upgrades.gd and module_recovery.capacity. A git grep of origin/claude/integration game/src/campaign and game/src/simulation finds hull or chassis ids only in economy prices and glass_research RECIPES (hull:quiet, hull:fast). No operation authors a place where the Low noise hull, Fast transit hull, Scout, Heavy or Long endurance chassis is the better answer. After PR150, nothing in game/src/campaign references sonobuoy, silt_screen, hull_patch or relay_buoy either. The frame and tool tradeoffs exist as numbers but are not tested by any authored decision.

Orchestrator note: If 076 is CLAIMED, do not edit campaign/encounters/calder_layouts.gd; put Calder-region sites in a later handoff.

## Base and branch
Base: origin/claude/integration (fetch fresh). Create branch: claude/lane-fleet-sites

## Files you may edit
game/src/campaign/optional_operations.gd, game/src/campaign/encounters/work_sites.gd, game/src/campaign/encounters/calder_layouts.gd, game/src/campaign/encounters/iron_layouts.gd or glass_reach_operations.gd (optional rows only), a new small table such as game/src/campaign/encounters/fleet_sites.gd

## Files you must not touch
Optional only. Core objectives stay finishable with the bare standard fleet. No photography-design change (no photo-subject rules). No Siren sensing, damage or hull-rule change. Do not rebalance economy numbers that claude/c7-economy-calibration is tuning. Lock, beam, collision, damage, hull rules, Siren senses, photography design. Files owned by any other CLAIMED handoff.

## Checks
One bare-fleet finishability journey per touched operation, where a core operation is edited. One journey per frame-specialization site, showing it is not completable without the matching choice. Never more than ORCHESTRATION section 5 requires. Suite ranks: Codex local 300-349 / CI 400-449 next free.

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
- PARTIAL / CLAIMED codex-root-parallel: head8f58039c on claude/lane-fleet-sites, open [PR169](https://github.com/pemunson90-cmd/Siren-s-Song/pull/169); preserves acce5a2d frame sites and merges055/integration609f29a9 via11219c8d. Root collects current-head CI; no merge claimed.
- Added optional relay account37, silt-covered watch reception38 and sonobuoy patrol account39 through existing finite tools; photography, bare-standard main routes, sensing/combat/hull formulas and legacy cargo are preserved. Recovered notes only; no economy changes.
- Isolated Godot4.6.3: import/core848/0; tool order journeys24/0; bare37 real photo/screw/recovery8/0; existing bare38/39 photo recoveries18/0; legacy cargo checks25/0. No assertions changed, registered suite added, touch/phone/human acceptance claimed. External scripts/logs: C:/Users/Archi/.cache/sirens-song-toolchain/artifacts/066-tools-20261028 (failed probes retained).
- Successful routes: relay standard drone west perch and return11.27s/100% hull; silt sluice/DEEP approach/MIDDLE account/DEEP retreat114.45s/86.44%; sonobuoy eastern-basin bearings/account plus both photos and extraction199.37s/98.85%. Bare37 screw recovery136.40s/86.50%; bare38/39 recoveries200.87s/100% and167.63s/98.85%.
- Heavy/Fast three-piece cache remains undelivered, CLAIMED. Exact wider seam below; no fixture cargo, invented module/resource IDs or unsupported completion. RESUME/MODULES and PR corrected. Preserve072/082/084,076,056 and global-landmark ownership.

## Remaining cache seam (28 October continuation)
The permitted isolated helper plus registration/carriage count alone cannot implement the two-trip comparison safely. Existing W.cargo creates a single five-field artifact; Glass.context/command/tick/transfer/status/valid each address that one artifact and one job. Glass.valid pins its ID through ITEMS, ModuleRecovery.valid accepts only actual launched equipment IDs, and ModuleRecovery.carried counts one Reach artifact. A cache must own three distinct validated physical custody records and include them in capacity, interruption, lost-carrier/wreck and local transfer handling while retaining every legacy single-artifact case.

Glass.complete/can_extract/recover currently require the mission artifact aboard a living carrier and mark it recovered only at full operation victory. A standard two-place carrier cannot unload two pieces, return for the third and keep the photography job running. The missing behavior is a local pre-victory cache-unload action at the recovery mouth, separate from mission extraction, with validated saved per-item delivered state. Existing mission_hud/module_recovery_view/fleet_instruments expose one Reach artifact/transfer; safe support also needs ordinary touch-visible selection/status for multiple pieces and unloading. These custody, pre-victory delivery, validation and presentation changes exceed this lane's authoring/helper/accounting scope. Root must assign that coherent runtime seam before cache authoring; do not repurpose research artifacts or equipment manifests as fake cache cargo.

28Oct06:13UTC ownership: start the explicitly permitted frame-only work now. Root assigns new fleet_sites.gd plus optional_operations.gd only (074 released). Do not edit glass_reach_operations, iron_layouts, calder_layouts or global landmarks while076/077 active. Defer tool-dependent hooks until055 lands. Preserve optionality and bare-fleet campaign completion. Record partial status honestly; do not mark complete until full assigned content is delivered.
