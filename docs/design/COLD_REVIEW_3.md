# Siren's Song cold review 3 (whole campaign)

Checkout: branch claude/integration at 30f555a, Godot 4.6.3 headless. Reviewer worked cold: source and tests were read only to learn how to inject touch and drive the game. docs/RESUME.md, builder ledgers and COLD_REVIEW_2_FULL.md were read only AFTER the findings below were formed, and only to label them INHERITED or NEW.

Operation numbering: the player sees operations 1 to 30. Source ids are 0 to 29, so "ops 6-29" in the brief means ids, which are player ops 7 to 30. This file uses player numbers (op N = id N-1) and says "id" where it means the source number.

## Limits (read these first)

- Headless, dummy renderer, injected touch only (Canvas touch/mouse pairs through `root.push_input`, plus `NOTIFICATION_WM_GO_BACK_REQUEST` and Escape). No pixels were looked at, no sound was heard, no physical phone, no human enjoyment, no real Android density.
- The notification path used by every test and by me (`propagate_notification`) is NOT the path Android takes. See F1.
- Where I say "played", I mean: the real `main.tscn` was driven by taps (menus, tap craft, tap water, PHOTO button, pause, android back, save and reboot), with the simulation stepped by hand between taps. Whole-operation outcomes for ops 2 to 30 came from scripted routes in the repo journeys or my own small bots. A bot is not a person. My "cautious" bot was not really cautious (it only held position once a lock had started), so its deaths say nothing about a careful human.
- I did not run the full scenario list. Targeted suites run: 33 (29 suites plus 4 journeys), all passed (see "What I ran").
- Nothing tracked was edited, committed, pushed or deleted. Scratch scripts live outside the repo.

## Verdict

The core loop and the opening six operations are in good shape and well covered. The campaign shell around them is the weak part: the long middle and end have no payoff screen, the Operations list is a very long scroll, the briefings for ops 7 to 30 are walls of text, and several player-facing features (settings, challenges, credits) can only be reached at boot. Most importantly, I could not prove the one-line Android Back requirement holds on a device, because the project still has Godot's default "quit on go back" on.

Nothing I tested was a regression from the FIX2, first-Siren cue, early reward, photo rows, route map or ARCH2 changes. Those landed cleanly and their own suites pass. The big gaps are things that were never built or never reviewed (ops 7 to 30 were outside the earlier review).

## What I ran

Real-touch / harness runs (my scratch scripts, building on `tests/fix2_menu_ui_tests.gd` helpers `press`, `tap`, `android_back`, `escape_key`):
- Fresh boot with real title overlay, START GAME, op 1 briefing, manual, enter water, tap Quietus, plot route, PHOTO button, photo captured (frame 59% grade C), save, Android Back in mission, kill and reboot, CONTINUE, RESUME DIVE. Worked.
- Operations list in five save states (fresh, tutorial done, after op 7, through op 29, all 30 recovered), measured scroll length and button positions at 2520x1080 and 2184x1968.
- Briefing screen for all 30 operations (length, screens tall).
- Route map, Fittings, in-game Settings, erase confirm, ending screen, evidence gallery, Android Back from each.
- Synthetic win debriefs for ops 1, 2 (early reward), 6; real scripted win of op 30 (dismantle route) into the real debrief.
- Loss debriefs (beam death on ops 2, 3; oxygen on op 5).
- Mission HUD after tapping Quietus on 23 sampled operations.
- Persona bots on ops 1 to 6 (cautious, aggressive, drone-only) and an idle-craft run on ops 1 to 17.
- Geometry-only travel and photograph of all 14 new photo rows (Sirens removed).
- Scripted challenge runs for `lung_solo` and `stair_no_charges`.
- Repo journeys: opening_depth, glass_reach, iron_choir, expanded_region (all pass).
- Suites passing (0 failures each): route_map, route_map_ui, early_reward, early_reward_ui, first_siren_cue, first_siren_cue_ui, campaign_endings, campaign_main_dispatch, campaign_photo_rows (361 checks), challenges, challenges_ui, challenges_journey, fix2_photo_routing, fix2_feedback_ui, fix2_save_ui, fix2_menu_ui, fix2_frontend_ui, fix2_camera_ui, fix2_study_ui, fix2_state, fix2_save, fix2_optional_recovery, campaign_instruments_ui, archive_recap_ui, lock_warning_ui, siren_warning_pause, photo_audio, audit_photo_ui, module_recovery_runtime_ui.

ARCH2: I compared the pre-move bodies in main.gd (before commit 3afb12f) with `src/presentation/flow/campaign_flow.gd` for show_campaign, briefing, show_ending, confirm/new campaign, launch_context, debrief, choose_equipment, cycle_loadout. After normalising `self` to `host`, the only differences were the renames and one dropped comment. No behaviour change found.

## Findings

Severity words: blocker, required expansion, later polish. Status: implemented, observed, untested, aspirational. Class: INHERITED (already in COLD_REVIEW_2 or its stated limits), REGRESSION, NEW.

### F1. Android Back may quit the app instead of acting as Escape
- Evidence: `game/project.godot` has no `application/config/quit_on_go_back` line. A script run shows the setting reads true and `SceneTree.quit_on_go_back` is true (`QOGB true tree=true`). `main.gd:681` handles `NOTIFICATION_WM_GO_BACK_REQUEST` and calls `_android_back`, but Godot's documented behaviour for the default is to quit when Back is pressed. Every test (and COLD_REVIEW_2) injects the notification by hand, so none of them reaches the engine code that decides to quit.
- Player consequence: on a real phone, one press of Back on Operations, in a briefing, or in a dive could close the app instead of going back. That breaks the "Android Back = Escape" requirement and risks losing the moment (a save is written first, so progress is probably safe).
- Severity: blocker until checked on a device (one-line fix if confirmed).
- Standard: Back navigates one level, never exits except by an explicit gesture on the top screen.
- Remedy: set `application/config/quit_on_go_back=false` in project.godot; on the top Operations screen show a "press Back again to exit" toast; add a test that asserts the setting is false.
- Status: untested on device (setting observed). Class: INHERITED (earlier review used the same notification shortcut, so it could not see this).

### F2. The last operation has no finale; there is no photo wall ending
- Evidence: I played op 30 (Spare Lung, dismantle route, 79 s, hull 100) through the real debrief. The screen is: "EXPEDITION RECOVERED", one line of the brief ("Two sites, one window. Throw the far breaker LOCK C, then RECONNECT ... or DISMANTLE ..."), fleet recovery, dive time, then only RETRY EXPEDITION and OPERATIONS ARCHIVE. `Endings.resolve` fires only when ops 13 or 14 (ids 12, 13) are recovered (`expedition_operations.gd`: `mission.id in [12,13]`), and ignores every Glass Reach and Iron Choir result including the dismantle/reconnect choice. A search of `src` finds no photo wall; the only photo summary at the end is one text line, "INTEL PHOTO GRADE B ..." (`main.gd:511`).
- Player consequence: after about 17 operations past the stated ending, finishing the campaign looks the same as finishing any dive. Nothing says the story is over and nothing shows the photographs the player spent the game taking.
- Severity: blocker for a complete campaign arc (required expansion if the arc is allowed to ship open-ended).
- Standard: the last operation ends in a distinct closing screen that reflects what the player chose and shows their best film.
- Remedy: add an "END OF LINE" screen when op 30 is first recovered: short placeholder text keyed to existing facts (`choir_choice`, `choir_people`, `choir_plant`), then a grid of the best recovered frames (the evidence gallery already holds up to 69 record keys, 33 of them photo keys) with a tap-to-enlarge, then credits and Operations.
- Status: aspirational (absent). Class: NEW.

### F3. The ending screen is stale after later operations and its replay path erases everything
- Evidence: with all 30 operations recovered, VIEW CAMPAIGN ENDING still shows the 3-line "UNHEARD" ending plus buttons CONTINUE / IRON CHOIR and CONTINUE / GLASS REACH (both already recovered), NEW CAMPAIGN / CHOOSE ANOTHER ROUTE, and OPERATIONS ARCHIVE. The other three endings need the shelf thread (ops 9 and 11) or the overt branch (op 14). After the deep thread is complete those operations are not on the list at all (probe: not listed in the "through op 29" state), so another ending means ERASE PROGRESS.
- Player consequence: the "ending" arrives at op 13 or 14 and then 16 more operations follow with stale buttons; seeing the other endings costs a full wipe.
- Severity: required expansion.
- Remedy: hide CONTINUE buttons for recovered branches; label the ending as "first ending"; offer a second save slot or a "replay from the fork" that keeps film and fittings. Pat decision (see list).
- Status: observed. Class: NEW (nobody reviewed past op 6).

### F4. For ops 15 to 30 the debrief "record" is the briefing, not an aftermath
- Evidence: for every id 14 to 29, `mission.record` text appears inside `mission.brief` (script `REC ...` printed `record_in_brief=true` for all 16). The final-op debrief in F2 shows it verbatim. Journey runs also end with the same message "Archive recovered / CHOIR SOUTH RECOVERY" for ops 22 to 29 and "SOUTH REACH RECOVERY" for five Glass ops.
- Player consequence: the reward text at the end of a hard dive repeats the instructions the player already read. The player is not told what changed.
- Severity: required expansion (story may stay placeholder, but the placeholder should be a consequence line, not an echo).
- Remedy: one short consequence line per op from existing recovered facts (for example people landed, plant state), shown above the instructions.
- Status: observed. Class: NEW.

### F5. The Operations list is the home screen and it is 3.6 to 7.3 screens long
- Evidence: scroll height divided by page height (2520x1080 shape): 3.6 after the tutorial, 3.7 after op 7, 7.3 with everything recovered. With everything recovered, the next AVAILABLE row is 5.2 screens down, ROUTE MAP 5.4, FITTINGS 5.6, VIEW CAMPAIGN ENDING 5.8, ERASE PROGRESS 6.0 (directly under it), SETTINGS 7.2. In the 2184x1968 shape it is 2.8 to 3.8 screens. Fresh start already shows six rows (five locked) plus a block of tool-count text.
- Player consequence: every return from a dive lands at the top of a long list. The player must scroll to find the next operation, the new route map, or fittings. The route map was added but sits mid-list, so most players will not find it.
- Severity: required expansion.
- Remedy: top of Operations gets one big NEXT OPERATION button (and RESUME if a dive is active), then ROUTE MAP and FITTINGS; collapse recovered rows under a "RECOVERED (N)" fold; move ERASE PROGRESS to Settings only (it is already confirmed, but it neighbours VIEW ENDING).
- Status: observed. Class: NEW in scope; the route-map item continues COLD_REVIEW_2 B5 (implemented, but buried).

### F6. Title, Settings (full), Challenges and Credits are reachable only at boot
- Evidence: `_boot_frontend` is called once, from `_ready` (`main.gd:156`); nothing in `show_campaign` re-opens it (search finds no other caller). The Operations list has "AUDIO / SETTINGS" which is a different, smaller screen: music, effects, mute, text size 100/130/150, tips. The title settings add master volume, high contrast, reduced motion, haptics and text sizes 100/115/130/150.
- Player consequence: after tapping CONTINUE, a player cannot reach high contrast, reduced motion, haptics, Challenges or Credits until the app is closed and reopened. A 115% text size set at the title shows no selected button in the in-game screen.
- Severity: required expansion (accessibility options should not hide).
- Remedy: one shared settings screen reachable from Operations, plus TITLE / CHALLENGES / CREDITS buttons at the bottom of Operations that re-show the overlay.
- Status: observed. Class: NEW.

### F7. Briefings for ops 7 to 30 are walls of text; guidance stops at op 5
- Evidence: measured briefing height: ops 1 to 6 are about 10 screens tall (mostly the fittings block, which is longer after later unlocks), ops 7 to 30 are 12.2 to 15.3 screens tall. Characters: 2,521 to 3,412 per briefing in the late state; the brief paragraph alone is 703 to 1,522 characters (op 13: 1,522). `OnboardingText.GOALS` covers ops 1 to 6 only and `MAX_OPERATION := 4`. Ops 7 and later print the full brief in the same 20-pixel style. Op 13's paragraph names winch, pod, sluice, actuator, float and reserve air in one block.
- Player consequence: the fix applied to ops 1 to 6 (GOAL and DANGER) was never extended. New verbs (rendezvous, tender, packets, thermal, choir work, towing) arrive as prose.
- Severity: required expansion.
- Remedy: GOAL / DANGER / NEW THIS DIVE (one line) for every operation; keep the full text in FIELD MANUAL; fold the Fittings block behind a button (a fold exists but is open by default when anything is earned).
- Status: observed. Class: INHERITED (COLD_REVIEW_2 A3 asked for this for every op; only 1 to 6 were fixed). The ops 7 to 30 part is NEW evidence.

### F8. First-Siren cue covers ops 2 to 4 only
- Evidence: `cue_table.gd` `OPERATIONS=[1,2,3]` (ids), so player ops 2, 3, 4. Op 1 already has a patroller and a sweeper (survey output) and gets no cue. The cue is a text chip, "NOTICE · FROM Q · 143°", for 2.5 s (`DURATION`), once per Siren id. Later new Siren kinds (hunter on op 5, sentinel, warden, interceptor, buoy, relay) get no introduction. The unit tests pass (37 + 52 checks).
- Player consequence: the first moment a Siren notices you in op 1 is not marked the same way, and later new threats arrive unannounced. A bearing in degrees assumes the player reads a compass.
- Severity: later polish (the existing warning pause and 4 s lock banner still apply).
- Remedy: include op 1; show an arrow on the chart edge as well as the chip; add a one-line "new Siren type" note the first time a type appears.
- Status: implemented (partially). Class: continues COLD_REVIEW_2 B3.

### F9. Death screens say where, still not why
- Evidence: beam deaths on ops 2 and 3 show "VAPORIZED · Siren beam struck Quietus." and "Last observed S1 at 176 m before the beam hit Quietus." Oxygen death on op 5 says "Life support ran out before Quietus reached recovery." No cause such as "heard: engine at speed, open water".
- Severity: later polish.
- Remedy: add the loudest own emission in the last 20 s (the sim already tracks noises).
- Status: implemented (partially). Class: INHERITED (COLD_REVIEW_2 B1).

### F10. Photo rows (14 rows, ops 7 to 29): data is tested, play was not
- Evidence: the 14 row keys appear in exactly one test file, `campaign_photo_rows_tests.gd`. That file's own comment says its fixture stages the craft on clear water and "Campaign travel remains covered separately". No other test mentions any row key, so that claim has no evidence in the repo. My geometry-only probe (Sirens removed, craft routed to the fixture's viewpoint, then camera held 10 s): 11 of 14 rows were captured with grade A or near (ops 15, 16, 19, 20, 22, 24, 25, 27, 28, 29, 30). Op 8's tender door gave "Record secured" but its captured flag still read false at 10 s (unclear, not chased). Op 9's relay lamp needs a 28 s hold and I stopped at 10 s (inconclusive). Op 12's single straight route stalled at (3106,3459), but a 16-step path exists on a 100 m grid, so it is reachable with waypoints. Player op numbers here are id+1; the probe printed ids 7 to 29. With live Sirens I did not test any row. Rows exist for 14 ops; ops 7, 10, 11, 13, 14, 26 have no new row (ids 6, 9, 10, 12, 13, 25), and ops 13 and 14, the ending pair, have none at all.
- Player consequence: optional film may be hard or unfair to reach under patrols, with no evidence either way.
- Severity: later polish for the claim, required expansion for a scripted human-feasible route check per row.
- Remedy: add one journey per row with live Sirens (use `patient_play` like the other journeys) or delete the "covered separately" comment.
- Status: observed (geometry only). Class: NEW.

### F11. Challenges: 12 of 30 operations, one end-to-end completion, one par that only one route can meet
- Evidence: `challenge_catalog.gd` has 12 rows. `challenges_journey_tests.gd` completes exactly one (`shelf_passive`) and says so ("proves one representative completion, not difficulty"). The catalog says pars are "authored targets, not a playtest verdict". I completed `lung_solo` two ways with the repo's scripted paths: dismantle 79 s (par 110 s, passes), reconnect 273 s (par 110 s, cannot pass). `stair_no_charges` 188 s (par 240 s, hull par 90, passes). The other nine rows were not completed by anyone in the repo or by me.
- Player consequence: a challenge could be unsolvable or unrewarding without anyone knowing. Challenges are also reachable only from the title (F6).
- Severity: later polish (comments are honest, so no false claim).
- Remedy: one scripted completion per row; make the par depend on the route for ops with two routes.
- Status: observed. Class: NEW.

### F12. Early reward and route map: implemented, small gaps
- Early reward (op 2 grants the Tele lens): debrief shows "NEW FITTING · Tele lens". There is no button to fit it there and no "optional, choose BARE or fit it" line (the expedition path has that line). The briefing for op 3 does show the fitting panel. Only one module appears before op 7. Later polish. Class: COLD_REVIEW_2 B6, now implemented.
- Route map: 70 UI checks pass at two shapes, targets at least 48, pan, zoom, CURRENT, Back and Escape and Android Back all return to Operations. Only two photo keys reveal nodes (`silt_scour`, `exhaust_stack`). The map is presentation-only and has an off switch. Observation, no defect. Class: COLD_REVIEW_2 B5 implemented (see F5 for placement).

### F13. Back-button consistency
- Evidence: from the Field Manual, Android Back goes to Operations, while the on-screen button says BACK TO BRIEFING. From the evidence gallery and photo detail, Back goes to Operations rather than the previous gallery page. Title overlay screens now return one level (63 checks pass). Erase confirm: Back keeps progress.
- Severity: later polish. Class: NEW (small).

### F14. Late-operation HUD sameness
- Evidence: after tapping Quietus on 23 sampled operations, 8 late operations (7, 10, 12, 23, 25, 28, 29, 30) open with the same status line "No exact source located · listen from another position or spend local RECON". That includes Iron Choir ops whose main task is machinery, and a button labelled "ARRIVALS 0" with no explanation. Craft clusters at the start open the FLEET chooser first (a design choice).
- Severity: later polish. Status: observed, low confidence (first frame only). Class: NEW.

### F15. Difficulty floor (observation, not a recommendation to change combat)
- A straight-line bot dies in 20 to 50 s on ops 2 to 6 (4 s lock window, same as the rules). Drone-only runs run out of oxygen on ops 2 to 6 but win op 1 in 18 s. Idle on op 8 is fatal at 83 to 93 s (a patrol crosses the start). Iron Choir is solvable by bare Quietus with both drones dead (repo journeys). Glass op 16 was won in a journey with 19% hull. These say "a person must learn each map", not "too hard". Journeys use `patient_play` rehearsal on a copied simulation and exact coordinates, so they prove solvable by a perfect player only. Flagged as Pat decisions: Siren sight, hearing, lock timing (not recommended to change).

### F16. First-run screen
- START GAME lands on Operations with five locked rows, a loadout comparison block ("COMPARE: O₂ / DISRUPT / SURVEY", "DISRUPT: 12s · SURVEY: 8s, audible") and a briefing line "3 DECOYS · 2 DRONES · 2 TORPEDOES" for tools not yet taught. Later polish; fold under Fittings until op 2. Class: NEW.

### F17. Save and resume
- Verified: save mid-dive, Back in mission (pauses and goes to Operations with RESUME DIVE row), kill and reboot, CONTINUE shows title with CONTINUE, RESUME DIVE restores elapsed time and paused state. FIX2 save suites pass. Status: implemented. No finding.

## Challenge to completeness claims in comments

- `campaign_photo_rows_tests.gd`: "Campaign travel remains covered separately." No other test touches a row (F10).
- `route_map_ui_tests.gd` labels "all thirty nodes": true, but it checks 48 dp targets and pan, not that a real finger can reach a node in a long list (F5).
- `challenge_catalog.gd` / `challenges_journey_tests.gd`: honest. They say pars are untested and only one completion is proved.
- `patient_play.gd`: honest about rehearsing on a copy; the journeys therefore do not show human feasibility.
- `iron_choir_journeys.gd`: the journey kills both drones ("Explicit source-known staged access") so "bare Quietus can complete" is proved only for that staging.

## Items that need Pat's decision

1. Does the campaign end at op 13 or 14 (current ending) or at op 30? What should the closing screen contain (F2, F3)?
2. Should alternate endings need a full erase, or a second slot / fork replay (F3)?
3. Should title, challenges and credits be reachable from Operations (F6)?
4. Siren sight, hearing and the 4 s lock window: reviewed only as a floor, no change recommended (F15).
5. Is `quit_on_go_back=false` plus a "press again to exit" acceptable (F1)?
6. How many early module rewards before op 7 (F12)?

## Ranked top 10 fixes

1. F1: set `quit_on_go_back=false`, add exit-confirm, verify Back on a phone.
2. F2: build the closing screen with the best-film grid and short placeholder text.
3. F5: NEXT OPERATION / RESUME / ROUTE MAP at the top of Operations; fold recovered rows.
4. F7: GOAL / DANGER / NEW THIS DIVE for ops 7 to 30; collapse fittings by default.
5. F6: reachable settings, challenges, credits from Operations.
6. F3: remove stale CONTINUE buttons; decide the replay and second-ending path.
7. F4: consequence line instead of echoed brief for ops 15 to 30.
8. F10: one live-Siren journey per photo row, or retire the "covered separately" comment.
9. F8: first-Siren cue on op 1 and a "new Siren type" note.
10. F11: one scripted completion per challenge row; route-aware pars.

Everything else (F9, F12 fit button, F13, F14, F16) is later polish.

## Verified working (protect)

Unlimited pause, tap-to-plot route with confirm and UNDO, PHOTO with frame grade, 48 dp targets in every measured control, route map at two shapes with Back/Escape/Android Back, early reward grant and persistence, first-Siren cue unit and UI suites, challenge isolation from the campaign save, save and resume across a reboot, ARCH2 move behaviour-equivalent.
