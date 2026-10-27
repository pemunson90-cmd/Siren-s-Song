# Handoff 054: C1 ECONOMY (resume Claude lane)

Status: CLAIMED
Claimed at: 2026-10-27 05:20:10 UTC
Claimed by: codex
Finished at:

Precondition: none beyond ORCHESTRATION. Read ORCHESTRATION_2026-10-26.md first. Claude's session hit its usage limit on 26 Oct; this lane transfers to Codex, and while you hold this claim you own the files listed here.
Codex may merge: yes, into claude/integration only, on green guidance + game-smoke for the exact head, merge commit.

## Task (plain language)
Finish Claude's economy lane. Spec: docs/CURRENT_GAME_SPEC.md bullet 'Default economy'. Resume from the existing branch tip and any open PR from it; read its commit messages and diff vs claude/integration to see what is done. Older stale WIP to port from, not merge: origin/claude/lane-p2-economy (economy.gd, economy_panel.gd, glass_research pending/start). Deliver: three resources (scrap, cells, alloy); presets Accessible / Standard (default) / Survival plus a one-way Ironman flag chosen at new campaign; a bare standard launch is always free (never soft-lock); once-only settlement after each dive; manufacturing spares and rebuilding lost modules; research costs alloy and is a player choice; quiet/fast hulls gated by entitlements hull:quiet / hull:fast (granted by research targets from materials deep_keel_plate / trawler_screw, or bought with alloy); non-standard drone chassis purchasable; economy state carried by profiles and SAVE2 states with an optional validator in save_checks.gd; a compact touch-first economy panel. Key prices by item id inside economy.gd.

## Base and branch
Branch: claude/c1-economy (exists). Continue on it after merging fresh origin/claude/integration into it.

## Files you may edit
New campaign/economy.gd, presentation/economy_panel.gd; main.gd hooks (briefing/debrief/archive/load/new campaign); presentation/flow/campaign_flow.gd; presentation/frontend/* (new-campaign preset choice); presentation/ops_home/*; presentation/fittings_menu.gd, equipment_context.gd; campaign/fleet_inventory.gd; functions of campaign/glass_research.gd; unlock flags in equipment/hulls.gd and chassis.gd; persistence/profiles/*, persistence/save_states/*; shared append-only files.

## Files you must not touch
Lock, beam, collision, damage, hull rules, Siren senses, photography design, story beyond 1 to 2 line placeholders. Files owned by any other CLAIMED handoff.

## Checks
Import, core, and only the minimum suites in ORCHESTRATION section 5. Suite ranks: local 350-359, CI 450-459.

## Return
PR into claude/integration; merge on green; close per ORCHESTRATION section 7.

## Completion
(five lines max)

## State at transfer (Claude lane report, 26 Oct ~18:35 ET)
- Built and pushed: PR 151, head 83baf869 on claude/c1-economy. Guidance green; game-smoke was pending. Earlier head 2b500f4e failed ONBOARDING (opening brief over 420 chars), fixed in 02dc16a6; preset picker moved below fittings row (83baf869) for DENSITY SCROLL.
- Done: economy.gd + economy_table.gd (resources, presets, Ironman, settlement, refine, enabled switch), spares/rebuild in fleet_inventory.gd, paid pending research incl. hull:quiet targets in glass_research.gd, hull/chassis unlock field, SUPPLIES panel (Operations + Fittings), preset choice on pristine Operations and erase screen, archive field `economy` with SaveChecks archive phase, MODULES/RESUME lines, economy_tests 41 + economy_save_tests 12 (ranks 350/351, 450/451).
- Remaining for Codex: finish game-smoke on 83baf869 (or newer); if red, gh run view --log-failed, fix the cause, push; merge on green; close out. Lines touched outside the original list (accepted): expedition_operations.gd (pending research), save_store.gd (SaveChecks phase call), ops_home.gd (SUPPLIES shortcut), fixtures in loadout_frames_tests, onboard2_ui_tests, fix2_menu_ui_tests.
- AI-DESIGNED numbers live in economy_table.gd; Pat may tune later.
