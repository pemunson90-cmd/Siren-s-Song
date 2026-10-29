# Handoff 100: TOOL LOCKERS (default loadouts carry tools again; extra tools still cost cargo)

Status: DONE (PR208 merged; codex-fresh-100 implementation, root integration)
Claimed at: 28 Oct 2026 17:37 ET (Claude launch, per BOARD)
Claimed by: codex-fresh-100; branch claude/tool-lockers; implementation authorship retained.
Finished at:

Precondition: 098 tool cargo is on integration (PR199 merged 28 Oct). Read HANDOFF.md and ORCHESTRATION_2026-10-26.md first. Current review rule (Pat, 28 Oct): independent Sol6.1-high review of the frozen patch before commit and before merge.
Codex may merge: yes, into claude/integration only, after independent approval and green required checks on the exact head, merge commit.

## Why (Claude S5, 28 Oct; follow-up to Pat's 14:13 ET ruling "Yes" that carrying tools costs cargo)
After Claude's revision request on PR199, templates may never reduce a craft's whole winch places. Tool weights are fractions of a cargo unit and winching counts only whole units. So every template now carries **0 tools** on every frame (PR199 table). Default players would launch bare without knowing it. That contradicts Pat's 28 Oct rule: planning, tools and drones must change the outcome, and the game must not feel like a walking simulator. Claude's rule was too strict; this fixes it.

## Task (plain language)
1. **Locker per craft.** Give each craft a small tool locker that tool charges fill first, before general cargo. Size it so the original free bundle for that craft's role fits (about 0.5 cargo for Quietus, 0.25 per drone, AI-DESIGNED; derive from the old ENDURANCE/DISRUPTION/SURVEY counts and the 098 weights). Scout chassis may get a smaller locker but not zero, unless a reason is stated.
2. **Spill costs cargo.** Charges beyond the locker use general cargo exactly as 098 does now, so a tool-heavy loadout still gives up winch places or modules (Pat's ruling stands).
3. **Templates** fill the lockers with the original free bundles again (ENDURANCE, DISRUPTION, SURVEY) and never spill. So defaults carry tools and keep every pre-098 whole winch place.
4. **Fittings screen** shows locker used/left separately from cargo used/left.
5. **Migration:** profiles saved by 098 with empty template racks get the locker template, unless the player edited racks (keep edited racks).
6. Keep the "Hold full of tools" refusal for spill-caused refusals.

## Files you may edit
equipment/tool_racks.gd, equipment/field_tools.gd (locker sizes), the rack view and fittings surface, migration, tests, MODULES.md row, shared registration lines.

## Files you must not touch
Tool effects, Siren senses, lock, beam, collision, damage, hull rules, mission data. Files owned by any other CLAIMED handoff.

## Checks
Import + core. Extend the racks suite:
- every template on every hull and chassis keeps its pre-098 winch places and carries the original bundle
- spill beyond the locker reduces winch places
- migration of 098 empty-template profiles
- edited racks are kept
- UI at both viewports
Rerun the field tool, economy, fittings, module recovery and save suites.

## Return
PR into claude/integration; independent review, merge on green; close per ORCHESTRATION section 7; one LEDGER line.

## Prepared handoff (historical provenance; now merged)
PR208 head `222b5c6270ed86f148f6648d7748d07a8d904fdb`, exact tree `fe3b7c64ed7a52bf6b595f1abef4b561615eb9ff`; independent nonauthor review reported in PR208 body; root verified head/tree.
Root collected session51452 at18:03 ET after confirming no source changes, under published88e27a81/Claude17:58 agreement; no finished-worker restart.
Root-held separate successor branch `claude/reconcile-lockers-content`, local `39f8170800686d46db541ea69d89a5aa8961c711`, exact tree `a93635123692df22adec4b4e5aad16a149273d40`; integration review47 APPROVE.
PR207 accepted as152111a1. Root published successor bad644d3e24c192e32aaf08450ddc04c2f1eb809 to PR208 (READY), after source review47 and doc-only review49B tree4484cfd36bbfe8eced2fab74db26649271f576b9. Own seven required checks green40785277937; merged `2dcb1bb3`. Worker collected; no restart.

## Completion
PR208 accepted head `bad644d3`; merged `2dcb1bb3` after own seven green40785277937.
Independent reviews47/49B; reviewed tree `4484cfd36bbfe8eced2fab74db26649271f576b9`.
Default role bundles use per-craft lockers; excess tools still cost general cargo; implementation authorship retained.
