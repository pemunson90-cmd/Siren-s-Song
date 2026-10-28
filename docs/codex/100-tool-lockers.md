# Handoff 100: TOOL LOCKERS (default loadouts carry tools again; extra tools still cost cargo)

Status: OPEN
Claimed at:
Claimed by:
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

## Completion
(five lines max: locker sizes and the template table)
