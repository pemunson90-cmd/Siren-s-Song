# Issues

Status: LIVE (Pat, 15 Nov 2026: all open problems live here. Root adds an issue when found, with its evidence, and moves it to `.fable/PROGRESS.md` when the fix is merged. The next steps that work on these are in `.fable/HANDOFF.md`.)

## This round's goal (Pat, 16 Nov, verbatim in `docs/USER_DIRECTIVES.md`)

"Finished for this round is an APK where I can play through the entire game." Only blockers to a full playthrough are fixed now; polish, new features, number changes and story items below wait for the next Gauntlet round. Playthrough testers A (campaign from the start, no debug) and B (later operations and endings) running on 0338b98a.

### Playthrough findings (16 Nov)

- Tester B (`critic-kits\pt-b`, 0338b98a): no crash or stuck screen; 42 campaign ids listed (0-41). Every ending needs op 34 "Beneath the Well" completed (root checked `endings.gd:30`). Op 34 lost 3 times (1/4, 2/4, 3/4 records); unproven whether winnable. Near-blockers (unverified): sluice photo costs hull 100 → 71 → 51 in 12 s with no lock (a "factory" strike); a record "seen only from DEEP" gives no band hint in the briefing; Iron Choir ops 22 and 29 start with "RECORDS 0 / 0". A dedicated tester is trying to win op 34.

## Failing now

- **`depth_policy_ui_tests` 160/4 on 504eb7f4** (retest b16): "FAIL real depth input starts deliberate transit", "FAIL physical planner input retains public operator destination" ×2 (`artifacts\fable-root-b16\depth_policy_ui_tests.log:7039`). Likely WP-166's depth-change warning (unverified). WP-169 on it. All other b16 suites green incl. Core 856/0.

- **None.** Sweep 17 on 0d908df0 (04:30, 16 Nov): 140 suites, no failing log. APK of ab8d71f1 (same game as 0d908df0) built, sha256 bef1bf7e...5a11, signer matches the pin. Fixed since: sweep 16 (WP-164, WP-165).
- Was: **Sweep 16 on 1a38472a (02:03): 2 of 140 suites failing, both cover screen.** `stable_board_ui_tests` 466/2 "FAIL Hunt clears threat/lock stack (2520, 1080)" ×2 (`artifacts\fable-root-s1\stable_board_ui_tests.log:24`); `dive_time_honesty_ui_tests` 196/2 "FAIL the tip card shows 2520x1080 100%" and "150%" (`artifacts\fable-root-s2\...:3884`). Suspect WP-158 header changes. WP-164 on it. No phone build until fixed.
- Older: **None.** Sweep 15 on fb924c09 (23:11 to 23:45): 140 suite logs, all "FAILURES 0" (`%USERPROFILE%\.cache\sirens-song-toolchain\artifacts\fable-root-s0..s2\`). APK of ed020e90 (same game as fb924c09) built, sha256 09da2ec6...9da4, signer matches the pin. Old note, fixed by WP-144, WP-145 and WP-147: sweep 14 (1be145de) found four failing suites. WP-144 (merged 8210bdc4) found the main cause: WP-130 gave the wheel nine segments on an eight-segment radius, so every open wheel went into the crowded re-fit (`game/src/presentation/status_text/status_view.gd` `fit`), jumped away from its craft, and a tap landing between two layouts closed it (`playfield_hud_tests` 94/6 → 94/0, helper). Its fix grows the radius for nine segments (`mission_hud.gd`, `layout()`, "# WP-144"). Left, with root's rerun on 8210bdc4 in `.fable/NOW.md`:
  - `fleet_ring_ui_tests` (render): "command ring leaves its own craft visible" and "...when its hull turns vertical" on cover, and "FIT immediately keeps the command ring clear of its craft" (cover and inner): the wheel, now centred on its craft, covers the craft. Read `controls_friction()` at `game/tests/fleet_ring_ui_tests.gd:87`; the player requirement is that the wheel never hides its own craft.
  - "real touch acknowledges warning without resuming" in `depth_policy_ui_tests` and `opening_depth_policy_ui_tests`: not investigated. Helper's guesses (unverified): the Hunt chip no longer re-seats after WP-130 (`hunt_meter.gd` signature) or the wheel covers the hint's dismiss button.
  - WP-141's `panel_open` is not reset on two paths that close the wheel without `dismiss()` (`game/src/main.gd` around lines 300 and 531, `advanced_orders=false`): not shown to cause a failure; check it.

## Round 11 ranking (16 Nov, head 2f11e0a8; reports: `_fable\kit\r11-a\audit\r11-a\report.md`, `_fable\critic-kits\r11-b` (reply only), `_fable\critic-kits\r11-c\audit\r11-c\report.md`)

1. FIXED WP-148 (5c8b595c), root saw marker and drop on inner 150% (`critic-kits\wp148-look\evidence\inner\14-after-decoy-button.png`, `15-after-marker-tap.png`). Left: after the drop the strip's second line still reads "PAUSED: a Siren is locking on" (15), and while aiming the strip keeps "DECOY · TAP CLEAR WATER ≤160m · TAP CANCEL" (14, `mission_hud.gd` about line 772). Was: **Lock card DECOY does not get a decoy off in time** (A and B independently). The card offers DECOY only when `sim.decoy_lock_point` finds a working drop (`threat_read.gd:147`) but the button only arms aiming (`main.gd:353-357`); the player must guess a point that is clear, path-clear and heard by the Siren within 3.9 s. B: "Decoy needs clear water within 160m and a clear path · no charge spent" after pressing it. A: a failed arm answers with stale strip text "AUTO PAUSE: LOCK WARNING" (`play_api.gd:484-485`), lock card stayed open after "S1 LOCK BROKEN", extra decoys spent. Root checked the code lines; the tester sequences are unverified. WP-148.
2. FIXED WP-149 (4617b804): **Air is a hidden clock** (C, `critic-kits\r11-c\evidence\r11-c\011.png` "O2 100% ~3:36"; dive ended "Life support exhausted"); B ended op 2 with "Life support 6% ~0:10". WP-149.
3. FIXED WP-149: **Rock bar makes SEND ANYWAY the bright default, CANCEL dim** (C, `016.png`, root saw it). WP-149.
4. FIXED WP-150 (1caed8c6): **Photo grades disagree** (A and B): objectives `photo_grade A`, `photo_percent 100` vs message and result "photo B (78%)". Unverified. WP-150.
5. FIXED WP-150: **Expedition briefing contradicts its own kit line**: "Scarce: no EMP ... no Hull patch" above "Carrying: ... EMP 2, hull patch" (B). Unverified.
6. RESOLVED WP-154 (166d1b25, play API only; fun-tester briefs must say `operate` for DECODE/SAMPLE/LINK): **Camera DECODE near a Siren photographs the Siren** (A op 03: "QUIETUS · S1 SENTINEL 0.0 / 8s", "Siren study filed"). Unverified.
7. Partly FIXED (Route Map WP-151; chooser heading and "240 m" WP-153; PLAN ROUTE vs ROUTE, GO LOUD line, header labels, BACK button WP-156). PAUSE tip and MENU fixed WP-158 (731511bc). Left: wheel side sheet covers ~40% of the chart (inner dock; root judges it acceptable for now: the dock is the inner screen's order panel and the chart stays tappable beside it). Interface (C): wheel side sheet covers ~40% of chart, PLAN ROUTE vs ROUTE, "GO LOUD / silent is on" (`012.png`, `015.png`); "DRONE A / CHOOSE · WHICH CRAFT?" heading when a drone sits on Quietus (`014.png`, root saw it); PAUSE tip far from its control (`020.png`); no pause menu, exit only via FLEET > MENU (`022.png`, `024.png`); Route Map DIVERGENCE panel cut at the right edge at 150% (`025.png`); "240 m" wraps leaving "m" (`019.png`). Root has not opened these except 014.
8. FIXED WP-152: Alloy: refining exists ("REFINE SCRAP TO ALLOY · 6 SCRAP", B) but Fleet/Fittings never mentions it.
9. For Pat (game design, do not decide): career contracts are walkovers with a free full loadout (B: 79 s and 49 s, no lock, "Next launch costs: free"); Expedition op 3 is a cliff after a boon pick that cannot know the next danger (B); rock differs per depth band and the chart does not show it (A and B: "rock blocks this leg at this depth · SHALLOW is open", hull 100 to 86); locks with no prior contact (A).

11. Partly FIXED WP-155 (7c535e46): contact line fixed and seen; the notice seating is code only, the banner-plus-chooser case was not reproduced. Also at inner 150% without the dock, AIR chip sits hard against "1x · SIREN CONTACT" (`critic-kits\wp155b\evidence\i150\06.png`, helper, unverified). **Notice banner covers QUIETUS · ORDERS in the chooser** (root saw `critic-kits\wp153\evidence\inner\13-chooser.png`: "SIREN TO THE NORTH NOTICED Q · 347°" on the button; red contact line over the speed plate). WP-155.
10. FIXED WP-157 (9c2266d5, cards only). Game Modes cards (after WP-151, `critic-kits\wp151-c\evidence\after\inner-150-modes.png`): each card has an empty band above its title button and the lower third of the page is still empty; title-on-top layout would read better. Route Map still opens on many "?" boxes (start of campaign, by design of the data).

## Round 11-d (Campaign 04 to 06, report `_fable\critic-kits\r11-d\audit\d1\report.md`, head fd061d63)

1. FIXED WP-161 (da41f672): **Extraction silently refused when Quietus is not in MIDDLE** while the game says "Fleet recovery ready" (root confirmed `simulation.gd:377`). WP-161.
2. RESOLVED WP-162 (play API only; planner has DONE · STAY PAUSED): **Blank "program" screen after a chart-stop card with a photo pending, dive unrecoverable** (tester, unverified). WP-162.
3. FIXED WP-162 (f2bd5174): Second drone "No drone is aboard to deploy" while DRONE B read ABOARD (tester, unverified). WP-162.
4. For Pat (rules/content): op 06 two Sirens lock Quietus at once at 26.4 s with Hunt DORMANT; op 05 drone A lost to a lock with no answer ("No answer in reach"); Siren rams cost 10 to 21% hull ("Hull strike against another hull · 58m/s · hull -21%"); rock not on the chart, so routes are found by single-point refusals.
5. A depth order given while a lock card pauses the dive is dropped silently (tester, unverified).
6. Photo grades mostly 38 to 53% C; "better: go round the subject" does not tell how (tester).

7. Note (root, 16 Nov, after Pat asked): sonar DOES chart rock. A pulse queues a terrain return (`advanced_sonar.gd:55-59`, low 440 m / high 720 m) that is merged after the round trip if the craft stayed within 160 m (`:68-75`). The testers' empty chart is consistent with not pinging before routing (unverified per run). Future fun-tester briefs should say: ping, wait for the echo, then route. Possible hint: the uncharted-water bar could say SONAR charts it.
7a. **Pat ruled 16 Nov ("Yes to all for now", `docs/USER_DIRECTIVES.md` last section): rock the player was told about stays charted; the chart names its depth; a route into an unscanned depth is warned first.** Built WP-166 (3a963ac9), (a)-(c) done in WP-167 (504eb7f4). New: at inner 150% the MENU plate partly covers the GOAL chip at top centre (root saw `critic-kits\wp167\evidence\s2\001.png`: only "7" of the GOAL chip shows under AIR and MENU; WP-168). Was: (a) at DEEP almost every tap may warn, since its chart starts nearly empty: risk of the bookkeeping Pat ruled out; consider warning once per depth per dive after SEND ANYWAY; (b) "CHART: DEEP" chip covers part of the "OWN SHUTTER" label on cover (`critic-kits\wp166\evidence\t3\012.png`); (c) told rock not yet seen being drawn on screen; 150% not captured. His test for all changes: no bookkeeping, but "the game can't play itself".

## Interface (root decides)

1. In the zoomed-out overview the staged Quietus can sit under the viewfinder dock: `game/src/presentation/chart_camera.gd:39` gives overview no reserve (found by WP-142). WP-157 tried the follow reserve for overview and it shrank the whole chart to ~60% of the inner screen with no viewfinder showing (`critic-kits\wp157\evidence\a150\007-pinch.png`), not merged; a fix should reserve only while the viewfinder is visible, and the overlap itself was never reproduced.
2. Fix merged unverified WP-159 (05920494; the card was already in `card_rects`, likely a stale rect; needs a look at a chart stop). A label fragment ("…M 289°") shows through the chart-stop card: capture `.claude/worktrees/wp-129/_scrap-20261111/wp129-screens/cover100-after-loss.png`; labels avoid `card_rects` (`ocean_view.gd:67`, used at `:1030`) but this card is not in them.
3. "After ▶ RUN: orders run for X" keeps the strip row over the NEXT line while paused with orders: `route_notes.gd:63` `run_line`, `mission_hud.gd` around 834 (WP-128 asked).
4. FIXED WP-151, WP-157. Route Map at 150% (`game/src/presentation/route_map/route_map_view.gd`); Game Modes page top-heavy at 150% inner (`game/src/presentation/frontend/frontend.gd`) (WP-132).
5. Not reproduced again by WP-159 (two cover runs, taps 1 s and 0.1 s after DEPLOY both added a point); closed unless seen again. A critic saw the first water tap after DEPLOY do nothing; not reproduced (`order_guard.gd:83` `tap_water`; WP-127 suspects drone overlapping Quietus or the 300 ms tap-after-close window).
6. FIXED WP-152 (62cca928): No debrief line when a decoy breaks a lock: the event exists (`game/src/simulation/orders/weapon_orders.gd:42`, type `lock_broken`) but the result screen does not read it.
7. CLOSED (stale, 16 Nov): already done; `menu_reach_ui_tests.gd:295` and `:332` loop `[1.0,1.5]`, `stable_board_ui_support.gd:15` sets only 1.5, the depth suites have no text-size loop (root checked). Was: Large grid suites still run three text sizes; Pat said yes to dropping 130% (`opening_depth_policy_ui_tests`, `stable_board_ui_tests`, `depth_policy_ui_tests`, `menu_reach_ui_tests` in `game/tests/`).
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
