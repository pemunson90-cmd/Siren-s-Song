# Handoff 055: C2 EQUIPMENT AND FIELD TOOLS (resume Claude lane)

Status: OPEN
Claimed at:
Claimed by:
Finished at:

Precondition: 054 is DONE (avoids fittings/catalog overlap). Read ORCHESTRATION_2026-10-26.md first. Claude's session hit its usage limit on 26 Oct; this lane transfers to Codex, and while you hold this claim you own the files listed here.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

## Task (plain language)
Finish Claude's equipment lane. Resume from the existing branch tip and any open PR. Deliver: 8 new conventional modules across mount types and craft classes with real budget tradeoffs via equipment/craft_upgrades.gd; 2 alien modules with exact ids quietus_wellhead_seal (HARDWARE) and drone_choir_tuner (SENSOR), research-gated like existing alien items; one field-tool catalog (new equipment/field_tools.gd) of 8 finite tools: existing emp, decoy, recon, knock (behavior unchanged) plus AI-DESIGNED sonobuoy (passive listener, player bearings only), silt_screen (short local cloud blocking optical line of sight via existing cover/LOS; never permanently disables a Siren), hull_patch (one-time partial collision repair), relay_buoy (local drone command range). Counts in a table, enabled switch, touch-first orders through simulation/orders. Tools choosable where finite tools are chosen today.

## Base and branch
Branch: claude/c2-equipment (exists). Continue on it after merging fresh origin/claude/integration into it.

## Files you may edit
equipment/* (except hull/chassis unlock flags), equipment/craft_upgrades.gd, new equipment/field_tools.gd, simulation/orders/* and new tool modules, campaign/challenges/challenge_rules.gd FINITE_TOOLS, presentation/fittings_menu.gd tool chooser, new tool views registered in presentation/feature_views.gd; shared append-only files.

## Files you must not touch
Lock, beam, collision, damage, hull rules, Siren senses, photography design, story beyond 1 to 2 line placeholders. Files owned by any other CLAIMED handoff.

## Checks
Import, core, and only the minimum suites in ORCHESTRATION section 5. Suite ranks: local 360-369, CI 460-469.

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
(five lines max)
