# Handoff 114: Foundation cleanup from the S7 PR audit (Claude lane)

**Why (Pat, 29 Oct 2026 ~13:00 ET):** "make sure that the code base doesn't become a sprawling mess that we have to untangle later ... before we set up for the next leg of the gauntlet, we should make sure we have a good foundation."

Claude S7 ran four read-only auditors over the ~50 game-code PRs merged into `claude/integration` since 26 Oct (base b522312c). Findings are cited by file:line at that base; re-locate them on the current integration head before editing. Starred items were verified by Claude.

## Bar (behaviour-preserving except item 1)
- Except item 1, play must not change. Before/after full voyages on the 093 harness (ops 2, 14, 22, 30, 41; bare SILENT and equipped; STANDARD) must be identical. Here an identical table IS the pass.
- Report net lines removed, per item.
- Never delete or loosen a test that guards game behaviour. A test that only asserts a dead constant or dead counter (for example TOUCH_DP, refresh_count) goes with the dead code; name each one in the PR.
- Old saves must still load. If an item touches save data, keep or add the migration.
- Protected rules untouched (HANDOFF section 2).
- One PR, or two if large (code health, then switch removal). Independent Sol6.1-high review; merge on green exact-head checks.

## 1. Bug: op 41 has no Hunt cap (*verified)
`simulation/hunt_pressure/hunt_table.gd:9` CAPS has 41 entries (ops 0-40). Op 41 (Sorley) falls back to 1.0 at `hunt_pressure.gd:18`, so Hunt never sharpens Siren sight there. Give op 41 the cap of its region's neighbours (AI-DESIGNED: state the value and why) and make a missing id fail loudly in a test, or key CAPS by op id. Show op 41 bare and equipped before/after.

## 2. Dead code (remove)
- `campaign/economy_table.gd:29` ITEM_PRICE={} and its branch at `economy.gd:66-67` (*verified).
- `economy.gd:242-244` cycle_preset and `economy.gd:34-35` pristine_choice: tests only.
- `field_tools.gd:11` TOUCH_DP (test only); `field_tool_effects.gd:94-98` status() (no callers).
- `tool_racks.gd:20` unused `_fit` parameter (left by 199, superseded by 208) and its call sites.
- `quality_runtime.gd:13,40` refresh_count and `ocean_view.gd:41,243` quality_draw_count: written in production, read only by tests.
- `simulation.gd:176` depth_feedback (no references); check `simulation.gd:175` network_feedback (tests only).
- `campaign/arcs/arc_table.gd:6-11` `core` arrays (never read).
- `runs/run_records.gd:67` best_depth (no reader): remove, keeping old-save loading.
- `fit_surface.gd:111-116` stock_text has no callers while `campaign_flow.gd:48` still hard-codes "FREE TOOLS: 3 DECOYS / 2 TORPEDOES; 2 DRONES". Derive that text from rack data so it cannot drift; delete whichever copy is left over.
- `encounters/optional_layouts.gd:15,25` landmarks for ops 38/39: never rendered (`simulation.gd:354-358` returns landmarks only for op 11).
- Glass fleet records `glass_record_37_*`, `_38_*`, `_39_*` (via Glass.recorded): written, never read. Remove, or report the reader you find.
- `glass_reach_work.gd:117` varne_staff duplicates glass_choice; point its one reader (crew_table) at glass_choice.

## 3. Always-on rollback switches (remove the switch and the never-taken branch)
Git history is the rollback now; Promotion 3 is content complete.
- `settings_depth.gd:8` ENABLED (~15 sites, 30-50 lines).
- `menu_reach_table.gd:3` enabled, plus the legacy `main.gd:699-734` _settings_menu and the matching `_set_accessibility` branches.
- `calder_layouts.gd:11` MODULE_SITES_ENABLED; `glass_reach_work.gd:5` MODULE_WORK_ENABLED; `iron_choir_operations.gd:8` FLEET_PRESSURE; `industrial_jobs.gd:3` BELL_TEAMWORK; ARC6 (`final_marks.gd:4` and `final_survey.gd:4`); `ocean_view.gd:48` contour_cache_enabled; `survivor_ascent.gd:4` ENABLED.
- `enabled=true` flags in ledger_table, voices_table, archive_table, event_cue_table, region_audio_table, fit_surface_table.
- `career_table.gd:4` ENABLED gates only the menu button: remove it and fix the "revert: disable" comments in career_state.gd:3 and career_frontend.gd:3.

## 4. Duplication (merge into one)
- Two quality governors: `ocean_view.gd:38,174` and `quality_runtime.gd:8,39`.
- Hunt COOLING/TIME cause logic at `hunt_pressure.gd:22-24` and `:51`.
- `photo_ops.gd:57-58` _unknown() re-implemented inline at `final_pair_operations.gd:33-35`.
- earned_terrain + launch_seed block at `glass_reach_operations.gd:45-46` and `resolution_missions.gd:37-38`.
- Hand-built Siren dicts in `optional_layouts.gd` (_patrol) and `fleet_sites.gd`: use `roster.gd:4` guard().
- operation_id helper in `arc_card.gd:77` and `ops_home.gd:10`.
- Brannock crew ledger line (`crew.gd` ledger_lines) repeats `ledger_table.gd:17,19`. Keep one.
- Onboarding hint ids listed three times in `onboarding_text.gd`: derive SAVED_HINT_IDS from HINTS.
- ITEMS {32,33,35} at `calder_trench_operations.gd:9` and `glass_reach_work.gd:26`.
- accept_rider state and toggle in `career_session.gd:9,87-90` and `expedition_session.gd:18,86-87`.
- decoy/knock label map in `tool_racks_view.gd:36` and `fit_surface.gd:112-113`.
- No-op stubs in expedition_session.gd:42-43, career_session.gd:43-44, challenge_session.gd:35-37: delete if nothing dispatches to them.

## 5. Small hygiene (if cheap)
- Per-frame allocation: `simulation.gd:1246` calls Sweeper.profile(s), which merges dictionaries every call (`sweeper_senses.gd:25-27`). Cache per role.
- `career_table.gd:12,14,17,21` standing gates of -6 equal MIN_STANDING (*verified), so they never block: drop the field for those rows.
- Per-op id hard-codes that could be data: `industrial_jobs.gd:115` (28), `blackwater_delivery.gd:53-54` (2), `iron_choir_operations.gd:57` (25, literal 320 duplicating OXYGEN[25]), `survivor_ascent.gd:12,14-15,26,33`.
- `mission_hud.gd:570-573` one-line wrapper.

## 6. Investigate and report (change only if dead)
- PR169's body said the Heavy/Fast cache was pending, yet `simulation/optional_cache.gd` (166 lines) plus a view and HUD buttons shipped. Can a player reach it in a real op? If not, remove it; if yes, say where.
- PRs 175, 192, 211 were only partly audited; flag anything dead you meet while editing.

## Out of scope (Pat's call or later)
- Tool-rack cargo cost is charged only in Campaign, not Career or Expedition: question for Pat.
- `credits_text.gd:6` creator placeholder: waits for Pat's name.
- "sorley_boy" key holds both log bits and rescue status: design fix later, with save migration.
