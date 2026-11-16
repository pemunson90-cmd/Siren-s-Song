# Issues

Status: LIVE (Pat, 15 Nov 2026: all open problems live here. Root adds an issue when found, with its evidence, and moves it to `.fable/PROGRESS.md` when the fix is merged. The next steps that work on these are in `.fable/HANDOFF.md`.)

## Failing now

- **After WP-145 (merge ae6b224d): one failing check left.** "real touch acknowledges warning without resuming" in `opening_depth_policy_ui_tests` (571 checks, 1 failing, helper run; WP-147 on it). Also `scripts/toolchain/win/test-suite.ps1:19` times this suite out at 480 s (it needs about 650 s). The older notes below are kept until WP-147 reports.
- **Sweep 14 (1be145de) found four failing suites.** WP-144 (merged 8210bdc4) found the main cause: WP-130 gave the wheel nine segments on an eight-segment radius, so every open wheel went into the crowded re-fit (`game/src/presentation/status_text/status_view.gd` `fit`), jumped away from its craft, and a tap landing between two layouts closed it (`playfield_hud_tests` 94/6 → 94/0, helper). Its fix grows the radius for nine segments (`mission_hud.gd`, `layout()`, "# WP-144"). Left, with root's rerun on 8210bdc4 in `.fable/NOW.md`:
  - `fleet_ring_ui_tests` (render): "command ring leaves its own craft visible" and "...when its hull turns vertical" on cover, and "FIT immediately keeps the command ring clear of its craft" (cover and inner): the wheel, now centred on its craft, covers the craft. Read `controls_friction()` at `game/tests/fleet_ring_ui_tests.gd:87`; the player requirement is that the wheel never hides its own craft.
  - "real touch acknowledges warning without resuming" in `depth_policy_ui_tests` and `opening_depth_policy_ui_tests`: not investigated. Helper's guesses (unverified): the Hunt chip no longer re-seats after WP-130 (`hunt_meter.gd` signature) or the wheel covers the hint's dismiss button.
  - WP-141's `panel_open` is not reset on two paths that close the wheel without `dismiss()` (`game/src/main.gd` around lines 300 and 531, `advanced_orders=false`): not shown to cause a failure; check it.

## Interface (root decides)

1. In the zoomed-out overview the staged Quietus can sit under the viewfinder dock: `game/src/presentation/chart_camera.gd:39` gives overview no reserve (found by WP-142).
2. A label fragment ("…M 289°") shows through the chart-stop card: capture `.claude/worktrees/wp-129/_scrap-20261111/wp129-screens/cover100-after-loss.png`; labels avoid `card_rects` (`ocean_view.gd:67`, used at `:1030`) but this card is not in them.
3. "After ▶ RUN: orders run for X" keeps the strip row over the NEXT line while paused with orders: `route_notes.gd:63` `run_line`, `mission_hud.gd` around 834 (WP-128 asked).
4. Route Map at 150% (`game/src/presentation/route_map/route_map_view.gd`); Game Modes page top-heavy at 150% inner (`game/src/presentation/frontend/frontend.gd`) (WP-132).
5. A critic saw the first water tap after DEPLOY do nothing; not reproduced (`order_guard.gd:83` `tap_water`; WP-127 suspects drone overlapping Quietus or the 300 ms tap-after-close window).
6. No debrief line when a decoy breaks a lock: the event exists (`game/src/simulation/orders/weapon_orders.gd:42`, type `lock_broken`) but the result screen does not read it.
7. Large grid suites still run three text sizes; Pat said yes to dropping 130% (`opening_depth_policy_ui_tests`, `stable_board_ui_tests`, `depth_policy_ui_tests`, `menu_reach_ui_tests` in `game/tests/`).
8. Not yet seen by root in a capture: Confluence echo marks (op 11), PHOTO beside LINK (op 02 with a second subject in reach), the intel route label under a lock card, the getting-home NEXT lines beside the ring, every 15 Nov change at 150% on the inner screen.

## Open for Pat (rules, content, spending: do not decide)

- The six trial rules after he has played (rule 3 is off, rule 6 is moot).
- Whether the rock warning should also vibrate; collision speed and film cost.
- Operation 01 solved by one EMP; drones' scouting value.
- After op 01 every fitting needs alloy the player cannot earn yet ("Costs 4 ALLOY" after a win paying "3 scrap, 2 cells"; fun tester B, 15 Nov).
- Op 05 Siren timelines identical between attempts (fun tester A, 15 Nov).
- Drones ramming Quietus cost hull without warning ("Hull strike against DRONE B · 70m/s · hull -26%"; fun tester A).
- The lock card's EMP offer ignores depth transmission (WP-131).
- N-1 to N-7 in `.fable/FINAL_REPORT.md` section 9.
- 120 protected-capability rows now read "no game-play test (retired 15 Nov, Pat's rule)", two of them his rule rows (CAMP-061 arc cards, MENU-010 regional art); any can get a game-play test back (old cells in `_scrap-20261111/_w/ledger_changes.json`).
