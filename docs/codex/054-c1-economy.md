# Handoff 054: C1 ECONOMY (resume Claude lane)

Status: DONE
Claimed at: 2026-10-27 05:20:10 UTC
Claimed by: codex
Finished at: 2026-10-27 06:31:16 UTC

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
Economy completed and merged in https://github.com/pemunson90-cmd/Siren-s-Song/pull/151, preserving presets, resources, repair/manufacture, deliberate research and frame unlocks.
Landed0f2cc962e41e280330e1c56859aa09d349ac7da7; retained lane710f8909a20bc53b5ef5d45fa178e4085517b07f, tree verified; exact-head gates green40455323703.
Import/core846/0, economy57/0, save13/0. Bare downgrades free, retry settlement independent, duplicate loaded debrief unpaid; missing055 fittings retain pending material.
Accepted seams retained: presentation/expedition_operations.gd research hold and persistence/save_store.gd archive validation. All new recipes and prior settings preserved.
Protected mechanics unchanged; phone play deferred. Ownership released; next055.