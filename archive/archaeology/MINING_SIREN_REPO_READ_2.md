# Siren's Song repo, literal read, slice 2 of 3

Slice: the 474 UTF-8 text files in LITREAD_SIREN_VS_REPO.tsv read only by script, sorted by path, rows 159 to 316 (second third). Files run from game/tests/audit_photo_integrity_tests.gd to game/tests/opening_depth_scenarios.gd.
Source: the PC repo C:\Users\Archi\Documents\Claude Code Homebase C\siren-s-song, read from the staged copy at /mnt/user-data/uploads/Documents/Claude Code Homebase C/siren-s-song/. Nothing in the repo or on the PC was modified. Checkpoint file: /home/claude/scratch_siren_read_2.md.

## Coverage statement

Files read in full 158 of 158 (this slice). Total 716,699 bytes and 9,701 lines, read as literal text with Read, whole file per call (none exceeded 2000 lines; the largest is game/tests/fixtures/blackwater_first_extract.gd at 711 lines). No sampling, no skipping. Per-file bytes (stat) and lines (newline count) are in the table at the end and in each section. Four checkpoint line counts were off by one at read time and are corrected in the sections (files 2, 27, 91, 153).
Scope note: all 158 files are Godot GDScript test, fixture, probe and capture scripts under game/tests/. None is gameplay source, so every rule below is what the tests assert about src/ code, not the code itself. The Quietus in these tests moves, routes and holds, so no stationary-sub model exists in this slice.

## Cross-cutting findings by theme (entry numbers refer to the per-file sections)

Stationary-sub model: absent. The only "stationary" items are tests that need a craft settled (vel under 2) before work (winch, glass work, hydrophone sampling: 144, 122, 5), a quiet stationary craft granting a buoy no contact (117, L24), and the onboarding manual text "stationary seconds" (154, L50). A stationary craft cannot become invulnerable by depth toggling (158, L117, hull under 70 after three toggles under acquired beam pursuit).

Beam lock: buildup 4.0 s. A lock on Quietus (target 0) shows the lethal warning; mode BEAM stops it (139, 140). Contact rows read "BEAM 2.5s" at lock 1.5 and "BEAM 2.0s" at lock 2.0 (152 L30, 153 L28). Stun, pin or depth cover cancel the lock (133 L35, 4 beam_emission_tests). Visible shared-band target stays vulnerable while the enemy changes depth, so outcome "lost" at hull 0 with lock over 4 (158 L89). Helper plans auto-fire EMP when contact.lock is over 1 and the contact is fresh under 0.3 s (112, 136, 151).

TUNING-style values asserted by tests: EMP stun 12.0 s (133 L104, 138 L52); KNOCK pin 8 s, range 150 m exact, 2 torpedoes, noise "KNOCKDOWN" radius 650, struck-target suspicion at least 0.45 (133); start tools emp 2, decoy 3, recon 2, knock 2 (156 L46, 157 L122); decoy transmission 15 s (152 L34); survey 8 s with RECON UPLINK noise (138 L53); RECOVERY WINCH 4 s, 60 m, noise radius 520 (144 L31); fast hull speed 78 x 1.15, quiet hull motion x0.7, full power bus x1.5 SONAR reserve (137); hull clearance 12 and planner margin 24 (146 to 150); high active ping reserve cost at least 1.19 oxygen (158 L109). No test names a TUNING dictionary key directly.

__sim keys: no "__sim" identifier appears in this slice. The tests drive Sim.new().start(op, loadout, ctx), s.command(name, args), s.advance(dt), Sim.STEP, snapshot, restore and valid_snapshot.

Stun display: knock sets mode "PINNED" with a pin_time clock separate from EMP stun; EMP over a pin does not reset the snare (133 L30-35, L101). Siren stun=100 or 200 is widely used as a test mute (2, 5, 124). The "STUNNED replaces BEAM" label is not asserted by this slice (earlier-slice tests carry it).

Audio and touch handling: the standard tap helper is ScreenTouch plus emulated MouseButton for press and release (120, 125, 131, 143, 145, 149); some older UI tests use mouse only (134, 138, 142, 154). Android Back (NOTIFICATION_WM_GO_BACK_REQUEST) cancels a pending touch and closes the route panel (149). Touch targets keep at least 48 dp including at text scale 1.5 (115, 134, 154). Torpedo cue headroom bound: loudest sample times voice gain at most 0.31 (133 L118). Industrial departure plays one restrained cue only for a selected receiver (113). Settings clamp volumes, snap text scale to 1.15 or 1.5 steps, and fall back to defaults on damaged JSON (115). Fixture shapes: 2520x1080 (inset 136), 2184x1968, 1280x720, dpi 420 and 95.

Recon LOS: line_clear and Depth.clear gate camera preview, torpedo launch, salvage, winch and listening (1, 60, 133 L70, 144 L28-29, 158). Known cells are never re-queried and repeated paused observation preserves state (135). Recon floor rises to 8.0 per secured record (124 L39); the e638 Blackwater extract holds reconnaissance delay 6.0, floor 16.0, hunt 24.4 (110).

Win/lose precedence: survival (hull, oxygen) resolves before extraction in the same tick (file 92 extraction_survival_tests.gd, see its section). Outcomes seen: "won", "lost", "withdrawn" (withdrawn spends no campaign stock, 144 L110). Industrial ops add "lost" when the NPC load is destroyed or a sled jams (126, 127).

Story frame: tutorial ops 0 to 5 (24, 156, 157, 158); op6 Divergence and shelf or deep routes, op11 Confluence, endings 12 concealed and 13 overt (17, 78, 90, 91, 142, 145); onward ops 9 and 10 (155); regions Glass Reach ops 14 to 21 and Iron Choir ops 22 to 29, unlocked by earlier outcomes and paying fittings quietus_prism, quietus_decoder, quietus_pressure_sleeve, drone_traction_yoke (117 to 122, 126 to 132); 12 curated challenges (44). Save envelope version 1 (version 2 with equipment), files quietus.save, .bak, .tmp; incompatible archives rejected (115, 133 L120-122, 137).

Defects and notes: none found that a test fails on; fixtures accepted-blackwater.archive and accepted-finale.archive are deliberately rejected as incompatible (133). Several tests assert on production wording (for example "Torpedo run ended · shot spent", "unsafe terrain"), which makes them brittle to text changes.

## Per-file purpose and findings

### 1. game/tests/audit_photo_integrity_tests.gd
Bytes 4359, lines 65, read in full.

Godot SceneTree test (Sim/Photo/Gear). Flash charge persists through exposure and restore L11-26; route command cancels exposure L27-30; viewfinder blocked by terrain via s.line_clear L31-36 (recon LOS: preview empty through cover); lead stage needs forward camera L37-40; discover() makes sighted L41-44; Needle Strait op15 = 9 sirens L45-51; ops 6-10,22-29 allow Siren study when same-band observed L52-58; optional Siren study cannot displace plant supply L59-63. Flash noise_radius >=760 L24.

### 2. game/tests/audit_photo_ui_tests.gd
Bytes 1887, lines 35, read in full.

Main-scene UI test: caption must not leak SIGNAL SPIRE L18; Siren stun=100 held at (780,560), drone at (900,560) L19-23; camera command, PHOTO button, fleet task L24-27; 9 s exposure yields film shot L28-31. Stun used as photo precondition.

### 3. game/tests/authored_plant_scenarios.gd
Bytes 4655, lines 49, read in full.

RefCounted helper: registers authored plant operation id 50 from op 10 config, world 2400x2400 L15-17; travel() via route command, STEP loop 12000 L6-13; tests restore, chain_power/chain_route/chain_send, bounds rejections incl world_size 2401 / 6040 L47-49, extraction inside shutter reject L45-46. Save dict version 1 L34. No stationary-sub content.

### 4. game/tests/beam_emission_tests.gd
Bytes 2550, lines 41, read in full.

BEAM LOCK: dark-water charging emission visible only when target>=0 and lock>0 L17-18; no target = no emission L21-22; stun>0 = no emission L23-24; structure cover blocks emission L25-26; cruise (non-silent, no darkness) beam visible outside passive reach at 1170 L27-28; alert_floor .24 extends range (1100 yes, 1300 no) L29-32; beam warning does not invent passive receivers L19-20. Full run: Quietus one-shot vaporized, warning-to-damage gap >3.5 s L33-40. Sim.start(2), drone (900,840) siren (1060,840).

### 5. game/tests/blackwater_courier_tests.gd
Bytes 7006, lines 85, read in full.

Godot test of op2 Blackwater optional reply carrier (glider). Isolates by stunning every siren stun=200.0 L13 (stun used as test mute). Launch 2.0 s after request L23; carrier path points L30; settled hydrophones needed (vel 60 blocks) L55-56; cover blocks signal L57-59; dead receiver kills feed L66-67; missed voyage leaves eastern relay fallback L68-72; NaN/future courier_launch invalid L75-78; legacy save gains nothing L83-84; save dict version 1 L43; pause freezes L40-41.

### 6. game/tests/blackwater_delivery_runtime_ui_tests.gd
Bytes 10653, lines 107, read in full.

Real main.tscn UI test with injected touch: tap() pushes InputEventScreenTouch plus emulated mouse press/release L13-17 (touch handling). Two window shapes 2520x1080 (safe area Rect2(136,0,2384,1080)) and 2184x1968 L49-52; capture dir arg L47-48; sirens=[] L54. Checks cargo/handoff/winch, 4 s shared winch L74, DELIVERED 2/2 debrief L65, readout plate rect enclosure L78-80, text fits card width L86-87. Fitted drone_deep_cells.

### 7. game/tests/blackwater_delivery_tests.gd
Bytes 17411, lines 184, read in full.

Op2 physical data-delivery tests via Observed fixture (blackwater_first_extract.gd): recorded flags plus home Quietus cannot auto-win L157-166; handoff needs both settled (vel>=2 blocks) L106-114, structure blocks, range 60 m L113-114; 4 s buffer winch L51; COLLISION_MAX_DAMAGE bounded hull loss during return L88-104; pause freezes L52-53; save version 1, unlocked 2/5 L55,117; fixture sets band=1 and acoustic_tone 180+id*17 L83-84; redundant resample ends on delivery L130-153.

### 8. game/tests/blackwater_delivery_ui_tests.gd
Bytes 12360, lines 121, read in full.

Public-projection UI fixture with DeliverySim subclass (stub delivery status, handoff range 60, winch duration 4, noise_radius 520 L11-18). Touch rules: water tap passes through packet telemetry as route L64-66; drag from craft ring pans camera without route/transfer L68-70; drag through TRANSFER popup sends nothing L76-77; multi-touch cancels whole gesture L79-80; canceled touch never becomes late command L82-85; separate tap sends exactly one handoff L86-88. Two window sizes as file 6 L51-54. Debrief DELIVERED n/2 L99; wreck marker names kits+buffers L102-106.

### 9. game/tests/blackwater_scenarios.gd
Bytes 7478, lines 73, read in full.

Op2 receiver rules. Sirens stun=100 fixture L7. 2.0 s direct relay samples, blackwater_revision 1 L15; Quietus passive reach 156 m (210 m needs ping) L24-26; drone reach 214.5 m (230 needs ping) L29-31; replay sonar cooldown 3.5 s, ACTIVE SONAR noise radius 750 L27; cover blocks reception and replay L37-38; moving craft cannot accumulate L40-41; pause freezes L44; save dict version 1 L52; fixtures/accepted-blackwater.archive rejected with warning L71-73 (old archive incompatible).

### 10. game/tests/blackwater_tests.gd
Bytes 299, lines 9, read in full.

Thin SceneTree wrapper that runs blackwater_scenarios.gd. No rules.

### 11. game/tests/blackwater_ui_scenarios.gd
Bytes 2661, lines 32, read in full.

Main UI scenario: op2 receiver action labelled SAMPLE L4; briefing avoids "Use CAMERA within 240m" L9; optical_feed hydrophone inset L11; 123 frames at 1/60 earns request L16-18; evidence plates res://assets/evidence/blackwater_request.png and blackwater_reply.png L24,30; incompatible accepted-blackwater.archive cannot replace progress L31-32.

### 12. game/tests/blackwater_ui_tests.gd
Bytes 673, lines 14, read in full.

Wrapper: 1280x720 main.tscn capture_scenario blackwater-ui then runs blackwater_ui_scenarios.gd.

### 13. game/tests/briefing_scroll_fitting_ui_tests.gd
Bytes 7558, lines 101, read in full.

TOUCH: Input.set_emulate_touch_from_mouse(true) L81; mouse events with DEVICE_ID_EMULATION; drag = 24 interpolated motion steps with LEFT mask L19-26; waits for scroll coast <250 ms still L27-33. Two shapes 2520x1080 (safe area 136..2384) and 2184x1968 L82-85. Fitting taps keep scroll offset within ui_touch_height L74; fitting drone_deep_cells reserves single kit across drone_a/b L91-94; ENTER WATER freezes fitting L96; loadout cycling keeps active dive snapshot L60. op6 with expedition version 1 routes deep/shelf L87.

### 14. game/tests/cadence_correlator_tests.gd
Bytes 5741, lines 73, read in full.

Tests src/equipment/cadence_correlator.gd. REFERENCE cadence [0.4,0.8,0.4] L5; 6.0 s dwell needed (300 frames not enough, 361 frames match) L21-24; kit-less craft gets no interpretation L27; speed 12 blocks L28; 9-unit displacement resets L32-34; stale/future/foreign-receiver/NaN samples rejected L35-57; result strips label/source_pos L25; qualification must mention identity and range (no authentication) L26; ambiguous same-cadence arrivals unresolved L42-47; state serializable via var_to_bytes L66.

### 15. game/tests/campaign_capture_progress_tests.gd
Bytes 2471, lines 35, read in full.

camera_feed.acquisition_progress uses public capture clock; fit_caption width 270 font 25 with ellipsis L14-16; op12 sluice: drone sampler duration 8 s vs Quietus 4 s (half progress .48-.52 at 4 s/2 s) L19-27; op2 exchange duration 2 s L28-33. sirens=[] fixtures.

### 16. game/tests/campaign_consequence_tests.gd
Bytes 3832, lines 41, read in full.

Campaign.valid/recover/available: legacy expedition valid L10-11; upgrade does not fabricate entitlements L12-13; recovered op7 earns quietus_correlator + return_cadence [0.8,1.6,0.8] L17-19; op9 opens after Deep, op11 after op9, op12/13 only after Confluence L20-24; replay cannot change selected_thread L26-28; corrupt history mission 99 invalid L38-39. Story frame: deep/shelf branches, concealed/overt exits.

### 17. game/tests/campaign_endings_tests.gd
Bytes 5283, lines 68, read in full.

Main-scene ending test over 4 branches (thread x route): ids 12 concealed / 13 overt; endings silent_exodus, beacon_pact, hidden_harbour, surface_reckoning L45; ending screen, atomic save reload, new campaign clears expedition keeps settings L49-56; op13 steps 6.2 s transmission, 55 s to win L31,42; op12 witness_capsule salvage + witness_land L34,41; tutorial finale unlocks quietus_vector_drive and drone_deep_cells L62. WIN: outcome=="won" at extraction L43. sirens=[] L27.

### 18. game/tests/campaign_equipment_save_tests.gd
Bytes 2710, lines 35, read in full.

Sim.start(7) strips consequence_revision/measured_reference still valid L11-12; duplicated sampler (drone_a and drone_b) invalid L15-16; unearned active hardware rejected by Store.valid L17-19; sampler drone 8 s exposure, 270 frames not enough, restore + 240 frames captures L26-33; sampler camera emits CAMERA noise (audible) L26 and uses `emp` command to keep fixture alive L24 (sirens not removed).

### 19. game/tests/campaign_instruments_tests.gd
Bytes 7815, lines 92, read in full.

Public-view tests: equipment_context.rows (3 slots), BARE shown, receiver_scene.applies(7,rendezvous), received_cues.take(): paused or unselected remote cue suppressed, pan derives from arrival direction (relative.x=-330) not hidden pos, stale/repeat events not replayed L47-60; correlation_detail text M1/M2 bearing 090/000 and age; sample_detail "AUDIBLE 8s" "2.5 / 8s" L77-79; soundscape.samples carrier_received != return_received != alert; headroom peak*db_to_linear(volume_db)<.5 and energy>1 L83-89 (AUDIO).

### 20. game/tests/campaign_instruments_ui_tests.gd
Bytes 8257, lines 97, read in full.

TOUCH: tap() toggles emulate_touch_from_mouse and pushes ScreenTouch + emulated mouse L14-19; sizes 2520x1080 / 2184x1968 with safe area L66-69; fitting rows min height >= g.ui_touch_height L78; fit-row tap sends [quietus,""] once L81; fit rows quietus_baffles/vector_drive/survey_array/deep_cells; Equipment.status text; unfitting next launch cannot relabel active vector drive L47-53; Deep op7 at (540,800) known receiver L87-95.

### 21. game/tests/campaign_main_dispatch_tests.gd
Bytes 3396, lines 44, read in full.

Main-frame dispatch for ops 9 and 10: terminal fixtures (sirens=[] L22), op9 listens 4.5 s, op10 chain_power backup/chain_route service/chain_send; departure_context confirmation_required then depart confirm L35-36; screen=="debrief", tutorial ids preserved, selected_thread/history commit L39-41. WIN: outcome=="won" L37.

### 22. game/tests/campaign_photo_rows_tests.gd
Bytes 8363, lines 115, read in full.

Optional recon photo subjects per op: EXPECTED {7:tender_door,8:relay_blink,11:structure_edge,14:buoy_blind,15:vane_crack,18:keel_mark,19:boat_keel,21:locker_latch,23:shutter_order,24:bus_cable,26:spindle_wear,27:slide_mark,28:bell_name,29:feed_room} L10; RETURNS map L11. RECON LOS: water_view uses Depth.clear along sight line to subject L28-35; photo band must match (can_shoot only in declared band) L66-68; exposure spends exactly 1 film L70-77; unusable film gives no intel L96-99; film adds chart marks without changing rocks/structures/sirens L91-95; tele lens makes vane_crack ready at standoff (bare not) L100-110; plant op10 keeps 3 objectives L112-113.

### 23. game/tests/campaign_scenarios.gd
Bytes 2538, lines 44, read in full.

Drone-loss fallback suite: move() routes with 0.1 s steps up to 2600, auto-fires emp when a contact lock>1.0 and tools.emp>0 L8-9 (BEAM LOCK counterplay: EMP vs lock). ops 0-5 start "disruption" loadout; units 1,2 killed; op id4 listening_well_command_plan, id5 finale_command_plan; Blackwater (id2) visited in reverse order with vantage +140 vs 210 offset L32-36; WIN checked outcome=="won".

### 24. game/tests/campaign_ui_scenarios.gd
Bytes 1987, lines 34, read in full.

UI run of the six tutorial missions: ENTER WATER via pointer click, same movement/camera plan as campaign_scenarios.gd; completion unlocks mini(5,id+1) L30; "Introductory arc complete" label after six recoveries L33-34.

### 25. game/tests/capture_acoustic.gd
Bytes 2917, lines 48, read in full.

Capture driver, not assertion test. Engine GUI input replay (mouse motion+button, NOT touch) at fixed 15 fps, default 300 frames L2,10; args --idle --desktop --clip-frames --safe-inset-x --clip-dir; scripted actions frame 0 pause, 5 silent, 15 route_sub(600,800), 30 more, 45 decoy, 60 droneA, 90 decoy, 105 sub, 120 silent, 135 hold, etc L28; idle mode: decoy then pause L29-30. Logs noises at end L47.

### 26. game/tests/capture_acoustic_context.gd
Bytes 2126, lines 31, read in full.

Screenshot driver for context "camera" (select drone 1) or "threat" (select Quietus, silent, ping every 40 steps until contact lock>0 and fresh <0.3 s) L13-20; route to (1300,510), 0.1 s steps up to 1000 L15-21; then decoy+ping. Uses contact.lock as beam-lock proxy.

### 27. game/tests/capture_audio.gd
Bytes 974, lines 18, read in full.

AUDIO audition: production mixer plays CUES [ping, recon, camera, emp, decoy, alert, beam, record, creak, extraction] every 0.55 s from 0.4 s with pan +-300 L6,15-16; sim routed to (800,800) silent; pauses at 7 s L17. Cue names are the audio event vocabulary.

### 28. game/tests/capture_audio_loops.gd
Bytes 990, lines 19, read in full.

Loop regression: ambience loop is 8 s and engine loop 2 s (per header comment L2); prints wav frames/loop_begin/loop_end and playback positions every 2 s L10-17.

### 29. game/tests/capture_blackwater.gd
Bytes 3208, lines 56, read in full.

Blackwater evidence capture; takes receiving/gallery-request/gallery-reply; profile desktop/cover(safe area 136..2384)/inner L41; ordinary commands; auto-EMP rule: if contact fresh <0.3 s and lock>1 and target==selected and emp>0, fire emp at most once per 1 s L14-17 (BEAM LOCK counterplay). Travel step 0.1 s up to 1500, done when |pos-goal|<25, vel<2 L18-25. Stations: (760,390) request, (1360,290) reply L42,47. Writes capture.json incl _ui_metrics and receiver_font_size L54.

### 30. game/tests/capture_blackwater_motion.gd
Bytes 4347, lines 73, read in full.

240 frames @15 fps motion clips for takes approach/idle/active_reply; same protect() EMP rule lock>1 L12-19; active_reply is solo fixture (drones dead), ping at frame 15 then camera at 16 L61-63; request vantage (760,340), reply (1360,270) L40-43; comment: 4.1 s command hold on accepted/challenger vs 2 s new sample L41; chronology.json report.

### 31. game/tests/capture_campaign.gd
Bytes 1304, lines 23, read in full.

Evidence driver --mission 0..5 --view overview/brief/ending; ending plays mission 5 via campaign_scenarios.move with vantage +210 (or -210 if blocked) L12-21; else issues recon and pauses L23 ("recon" command exists).

### 32. game/tests/capture_density.gd
Bytes 2732, lines 38, read in full.

Density screenshot driver: views primary/secondary/settings/briefing(5)/operations; moves drone to (1300,510) 0.1 s steps<=500; zoom 1.8; fixture_dpi=420 print L33; briefing view fails if begin/back controls not unclipped L35-38. Uses _ui_metrics().

### 33. game/tests/capture_density_interaction.gd
Bytes 2654, lines 36, read in full.

Engine GUI mouse replay 240 frames @15 fps planning clicks (droneA, route_a(600,800), queue, route_b(900,800), more_orders, camera, route_c, home, droneB, pause, zoom_in, fit) L17; comment L2 says not Android OS input. World to screen: world_offset + world*world_scale L25.

### 34. game/tests/capture_feedback_tests.gd
Bytes 1441, lines 23, read in full.

capture_feedback(): inactive duration 0; drone sampler duration 8 with elapsed ~1 after 60 frames L13-17; restore keeps duration L18; legacy op0 photo 4.0 s and op2 exchange 2.0 s unchanged L19-21.

### 35. game/tests/capture_finale.gd
Bytes 1164, lines 17, read in full.

Finale view driver using finale_command_plan.play(true,stage); views crown/wakes/receiver zoom 1.6; ending -> _debrief; archive -> evidence gallery "warning" L10-16. Prints records/drones alive.

### 36. game/tests/capture_foundry.gd
Bytes 1219, lines 16, read in full.

Foundry evidence driver with foundry_command_plan.play(true,stage,true); stages incl response_live (clears events) cradle, complete, archive*, debrief L10-16 (mission 3).

### 37. game/tests/capture_observed_contact_lock.gd
Bytes 1108, lines 16, read in full.

v7-style "sight-over-lure" counterexample: fresh Well dive (mission 4), move to (800,800), decoy at (1100,650), run 4 s at 1/60 watching for contact fresh <0.3 s with lock>0.5, then a second decoy attempt L5-15. Observes BEAM LOCK vs decoy (does second decoy get accepted under existing lock).

### 38. game/tests/capture_photo.gd
Bytes 2303, lines 56, read in full.

Viewfinder/archive capture stages viewfinder/exposure/tight/archive/compare/silt(op17)/siren. Spire at (1300,300) facing 2.74, craft at 120 units; "siren" stage: guard.stun=100.0 at (780,560), drone Quietus (900,560) angle PI, camera 4 s L48-55 (mirrors audit_photo_ui_tests).

### 39. game/tests/capture_return.gd
Bytes 699, lines 11, read in full.

Replays split_channel_command_plan.play() (file not in this slice; note: references res://tests/split_channel_command_plan.gd) and presents paused snapshot (mission_index 1). Logs hull, records, decoys.

### 40. game/tests/capture_siren_roles.gd
Bytes 1417, lines 22, read in full.

Passive player-view role clips: idle_patrol (mission 0, move to (800,510), 16 s wait), sentinel_return (mission 3), idle_hunter/hunter_response/hunter_return (mission 4; move to (600,600); decoy at (800,850); hunter_return waits 26 s) L10-20. Siren role keys printed: type (default "patroller"), mode, pos L22. So siren has types patroller/sentinel/hunter and mode state.

### 41. game/tests/capture_touch.gd
Bytes 924, lines 16, read in full.

Touch evidence: Foundry cradle stage, zoom 2.2 at (1240,760), pan (-35,-45), advanced toggle; prints chart_camera.zoom/center.

### 42. game/tests/capture_touch_movie.gd
Bytes 1817, lines 31, read in full.

Synthetic Godot events (header L2 says not OS touch): mouse clicks on zoom_buttons[1], [2], advanced_button; ScreenTouch + ScreenDrag finger pan of (-260,-190) over 0.9 s L22-27; timed phases 0.5..5.8 s.

### 43. game/tests/challenges_journey_tests.gd
Bytes 1680, lines 28, read in full.

Shelf passive challenge replay: ChallengeRun.setup("shelf_passive"); ping/recon blocked L14; move to objective +210; camera work (dur+0.5)*10 steps of .1; outcome=="won" and not result().loss; tools.recon==2 unspent L25.

### 44. game/tests/challenges_tests.gd
Bytes 7048, lines 112, read in full.

12 curated challenges (Catalog.all) L60; rules: no_sonar, quietus_only, no_tools, hull_intact (hull=99 -> lost), no_losses, middle_only (band 2 forbidden), one_tool, quiet_propulsion (loud_time budget 20, motion_radius>430 at vel 120), time_limit (elapsed 360) L20-57; loadout stock table endurance [120 O2,2 emp,2 recon], disruption [100,3,2], survey [100,2,3], decoy 3, knock 2 for all L71-72 (TUNING-like start supplies). LOSE: outcome "lost" with rule_failure. Fixed basic fitting = Gear.default_loadout. Save profile version 2 with optional challenges field L89-95; challenge archive file .challenges separate; ops 0..29 span L87.

### 45. game/tests/challenges_ui_tests.gd
Bytes 9686, lines 139, read in full.

Real title/mode-menu TOUCH: ScreenTouch + emulated mouse L13-17; escape key and Node.NOTIFICATION_WM_GO_BACK_REQUEST as Android Back L18-24; sizes 2520x1080 (safe area 136) and 2184x1968; 12 challenge rows, only recovered op unlocked L77-78; session separate node ChallengeSession, campaign frozen L85-86; campaign files byte-identical across challenge play/suspend L92,96; Android Back opens attempt menu, abandon records loss L125-133; NOTIFICATION_APPLICATION_PAUSED L91.

### 46. game/tests/cold_review_archive_tests.gd
Bytes 5848, lines 83, read in full.

Cold-launch runner: spawns headless Godot with XDG_DATA_HOME fresh dir per profile cover/inner L29-38; native ScreenTouch + Android-style mouse emulation drag 16 steps with ScreenDrag L13-26 (scroll not assigned); no pre-existing quietus.save / .bak L43; fixture: drone at spire+2.74 rad*110, 300 frames camera, evidence gallery with Intel button reachable by drag L53-74; recovered-backup notice text "Primary archive was unreadable. Recovered previous backup." L81. Save filename quietus.save.

### 47. game/tests/cold_review_ui_tests.gd
Bytes 10588, lines 122, read in full.

Profiles 2520x1080 dpi420 inset136, 2184x1968 dpi420, 1280x576 dpi95 L48. LOCK WARNING: own-drone lock fixture (siren at (720,500), drone (600,500), stun 0.0, contact target==1, lock>0 after .5 s) auto-pauses with hint card; GOT IT dismisses, warning not repeated L29-46; heard sweep hint (sonar.history bearing, WARNING class) pauses independently L56-61; goal marker offscreen in FOLLOW view L63-69; second water touch opens replacement confirm guard (go/add/points/cancel) L72-77; pause button text says RESUME not RUN L78; tool help via touch hold 0.65 s with 2 px jitter shows order_help sheet and spends nothing; keys emp, recon, sonar_emit, sonar_sector, sonar_power, sonar_history L96-108; Android Back returns to wheel L93-94,103; ALL STOP primary Quietus choice with "O2" cost text L110-113; loss + briefing clear viewfinder and lock_warning L119-120 (STUN display not covered).

### 48. game/tests/concealed_fixture.gd
Bytes 1104, lines 15, read in full.

Test-only solve(sim) for op12 concealed_harbour: preserves unit/selection/pause, tow attach at (1940,1040) shelf or (1840,1010), moves to (1920,990)/(1840,850), 132 frames, service/release L5-15. Fixture, never journey evidence.

### 49. game/tests/concealed_harbour_journey_tests.gd
Bytes 6418, lines 96, read in full.

Op12 concealed harbour journey probes (deep cast-off north/south, shelf service/baffle). Bare Quietus, silent mode toggled via `silent` command, tools all 0 L44; STEP loop; detects BUNKER WATCH REPLY / TOW DRAG noises being heard by guards (guard.mode=="INVESTIGATE", acoustic_paths.arrivals, _heard_arrival) L16-30; shelf service reply is heard by watch, baffle not L77-78; tow never clips terrain L66; WIN outcome=="won" + valid snapshot L87; witness_land required L85.

### 50. game/tests/concealed_harbour_tests.gd
Bytes 15144, lines 170, read in full.

Op12 local rules: heard_departures, tow attach/release, craft speed <=40 when towing (_craft_speed(unit,78)<=40 L60), pause freeze L59, binary save with expedition progress L52-58, concealed_consequence deep_trace_severed / shelf_service / shelf_baffle L72,96, distinct endings L97, replay cannot rewrite L98-99, shelf baffle weakens acoustic path (shelves[1]<shelves[0]) L100; old finale snapshot without concealed_harbour invalid L103-104. baffle_pod_recovery fixture: relocated sentinel guard (sirens[1]) beam kills occupied drone, event type "beam", witness pod state "salvage" L141-143; EMP used to protect recovery L160; pod inside Rect2(2040,940,200,60) L145.

### 51. game/tests/concealed_harbour_ui_tests.gd
Bytes 10313, lines 137, read in full.

UI fixtures: BERTH (1840,760), HOME (2260,2700) L4-5; TOUCH rejection kinds short drag (20 px), cancel (canceled=true), two fingers all issue nothing L60-69; targets must be >=125.99 physical px (48 dp) in safe area L70-72; ScreenTouch + emulated mouse tap L19-25; account panel text begins "KESTREL'S SONAR OPERATOR:" close button "LOCAL ORDERS" L93; tow attach, release, seat baffle ("longer lower" cost text L121); two shapes x deep/shelf.

### 52. game/tests/confluence_command_plan.gd
Bytes 5820, lines 95, read in full.

Helper: tick(s,0.1 steps) auto-defends: for contact fresh <.3 s with lock>=1.2 on a living target unit, select it, fire emp if tools.emp>0 else decoy 100 units north of unit L5-15 (BEAM LOCK counterplay threshold 1.2). travel(): 1800 steps, STUCK diagnostic, chart_stop re-route L25-26. play(thread,route,service,stage) op11 with fixed waypoint circuits L43-66; play_parallel(): op11 "disruption" w/ drone_sampler, 6000 ticks L67-95. Not an assertion test.

### 53. game/tests/confluence_completion_tests.gd
Bytes 663, lines 10, read in full.

Runs Plan.play for four scenarios [shelf,concealed,false],[deep,overt,true],[deep,concealed,false],[shelf,overt,false]; fails unless outcome=="won" and chosen_route==scenario route L5-9. Prints CONFLUENCE_TECHNICAL outcome/oxygen/hull/tools.

### 54. game/tests/confluence_operation_tests.gd
Bytes 5921, lines 71, read in full.

Op11 Confluence: polygon rocks (PackedVector2Array) L15; world height >4000 L16; roster has hunter, sentinel, patroller types L17; central basalt breaks s.line_clear(1000,2200 -> 2700,2200) L18 (LOS); corridors y>4000 not available L19; one physical gate (sluice), confluence_context hides unseen landmarks L22-24; endurance oxygen_seconds>=720 L25; closed door blocks sight and direct acoustic path L33-34; opening the gate: path shorter by 900 / 700, noise radius>=1100 at actuator L56-58; invalid polygon NaN rejected L63-64; optional service never replaces live packet requirement L65-69.

### 55. game/tests/confluence_parallel_tests.gd
Bytes 848, lines 13, read in full.

Plan.play_parallel must win with gate opened, packet captured, unit 0 far (>2000) from (1080,1840) while unit1 within 240, drone battery <95 and alive L6-10. Prints CONFLUENCE_PARALLEL_TECHNICAL.

### 56. game/tests/confluence_presentation_tests.gd
Bytes 4514, lines 53, read in full.

Mock Canvas records draws; confluence_world.draw_terrain: ambiguous return cells never draw solid rock L26-27; relief limited to measured patch endpoints L28-30; no landmark drawn without earned DTO or surface segments L32-38; confluence_resolution.recovery(): incomplete/route-only gives {} L42-43, concealed vs overt title/drones/service text L44-50. RECON: terrain shown only where observed.

### 57. game/tests/confluence_resolution_ui_tests.gd
Bytes 3976, lines 51, read in full.

Resolution scene ConfluenceResolution after op11 win: sizes 2520x1080 / 2184x1968 (concealed vs overt); four actions next_expedition, evidence, retry, back unclipped L34; art_rect height >45% of viewport L36; Continue touch -> briefing L37-40; opposite-exit replay text mentions replay and committed title "The Concealed Record" / "Open Warning" L43-49. WIN: outcome="won" forced then _debrief L29.

### 58. game/tests/contact_reports_tests.gd
Bytes 8007, lines 93, read in full.

Finale (op5) local contact reports (contact_report_revision 1; earlier ops 0-4 unchanged L22-26). Sentinel sirens: report charge >0.9 after 1.0 s sight, completes ~2.1 s total, quantizes location within 57 units L28,38-39; attention_time >9 s; expires after 620 frames L45-46; interrupt rules: stun (mode "DISRUPTED") L47-49, lost sight L50-51, stunned sender L52-53, pin_time L54-55; acoustic reach bounded L56-57; wall blocks L58-59; thermal front transmission 0.55 weakens L60-61; one strongest peer L62-64; fresh hearing/sight/beam authoritative L65-70 (beam lock precedence); EMP interrupts L73-75; hull==100 unchanged L78; legacy snapshot exact L84-88; NaN charge/target 9 rejected L89-92. Siren fields: stun, lock, target, suspicion, report, report_interest, type, mode.

### 59. game/tests/contact_reports_ui_tests.gd
Bytes 2593, lines 39, read in full.

UI of report warning on op1: contact dict has mode LOCKING, lock 1.0, report_remaining 1.0, type sentinel L24; contact_entries rows contain "REPORT"; text fits row width (font+16), rows inside chart, avoid zoom buttons, rows disjoint L26-34 (lock/beam warning row display; no stun row).

### 60. game/tests/core_scenarios.gd
Bytes 3763, lines 44, read in full.

CORE rules on op0: paused ping and clocks frozen L5-6; queue/emergency order rules L7-12; bedrock blocks line_clear both directions L13-14 (recon/LOS); assisted path avoids rocks with clearance 18 L15-17; sonar does not reveal through cover, hidden Siren cannot lock through cover L18-23; direct sound gives coarse 80 m-bin goal inference (distance<=40.01 from ping origin, not exact) L24-27; legacy (no acoustic_revision) keeps exact origin L28-31; EMP stuns: no hull damage and lock 0 for 120 frames L32-34; fixed-step determinism 1/60 vs 1/30 L35-39; restore always pauses and rejects malformed L40-44. Stationary-sub model not present (Quietus moves, routes).

### 61. game/tests/craft_upgrade_sim_tests.gd
Bytes 3381, lines 41, read in full.

TUNING-like values: Quietus silent cruise 42 m/s (vel<43 after braking) L25; vector_drive raises peak speed >+20 L23; loud motion at vel 78 heard by siren; quietus_baffles shrinks public motion radius to .55x L28-29; drone_survey_array: passive_range(1)==460 after restore L40; deep_cells halves fitted drone battery depletion, other drone unchanged L36; launch equipment frozen across save L37-40. Sim.STEP used.

### 62. game/tests/craft_upgrades_tests.gd
Bytes 2580, lines 31, read in full.

src/equipment/craft_upgrades.gd: tutorial (ops 0-5) grants quietus_vector_drive + drone_deep_cells L13-14; both branches add baffles, survey array, sampler => 5 items L16-18; motion_radius(fit,unit,speed): speed 42 residual >0, 0 speed=0 L23; baseline passive_range Quietus 240, drone 330 (index 2) L27; baffles affect only unit0 L22; catalog public list 5 L30.

### 63. game/tests/current_chart_seam_tests.gd
Bytes 2668, lines 35, read in full.

Unknown-geometry route: tentative intent kept, craft advances only inside certified launch prefix, terrain_chart.is_clear L11-14; currents carry no craft beyond confirmed water, no chart_stop latch L19-22; propulsion_speed >5 under counterthrust; ample observed water keeps axial current assist (positions[1]>positions[0]+50) L24-33; _move(unit,dt,42,false,true,true).

### 64. game/tests/current_motion_tests.gd
Bytes 5113, lines 63, read in full.

current_field.gd: radial fade (center full flow Vector2(34,-10), half at half radius, zero at edge) L19-22; flow +-24 gains/loses >50 ground in 480 frames L27; assist does not exceed engine speed (<=42.01 propulsion, ground vel >42) L28; vector HOLD within 20 units excursion, regains station L33-34; STOP holds station in flow; lateral flow compensated (|y-800|<20) L40; swept collision vs 20-wide wall L41-43; pause freezes L44-45; current_feedback publishes flow+effort w/o center/radius/fields L48-50; receiver camera allowed with ground-stationary counterthrust L56-58 (op11 settled 300 frames).

### 65. game/tests/current_propulsion_tests.gd
Bytes 947, lines 18, read in full.

propulsion_speed(): ordinary vel (3,4)=5; assisted ground 50 with water 20 -> 20; ground-still counterthrust vs water -24 -> 24 L12-14 (noise comes from engine thrust, not ground speed).

### 66. game/tests/decoy_aim_ui_tests.gd
Bytes 4310, lines 52, read in full.

Decoy aiming UI at 1280x720: g.decoy_armed state; arming spends nothing; copy has CANCEL and "160m" L27; rock tap refuses, water tap deploys once, tools.decoy 3->2, noise at point L28-33; cancel via decoy/select/program/menu/knock after press cannot deploy L35-40; torpedo(knock)/decoy mutually cancel L41-42; ScreenDrag keeps pan while armed L43-45; lost-drone auto-selection clears aim L48-49; outcome won clears cue L50. TOUCH: ScreenTouch (index 0) and separate mouse button click L10-16.

### 67. game/tests/decoy_deployment_tests.gd
Bytes 2354, lines 28, read in full.

Decoy rules (op0): tools.decoy starts 3; default landing 160 east of craft invalid in basalt, rejected with no spend L10; invalid targets (rock 560,500, below, negative, NaN, string) no mutate L11-13; valid deployment: noise at point, radius 1100, time 15 (s) L16; water behind basalt not teleport L17-18; default API places at (300,800) for op0 L21-22; legacy noise restore preserved L23-25; selected drone can place decoy L26-27.

### 68. game/tests/density_main.gd
Bytes 1066, lines 22, read in full.

Test subclass of res://src/main.gd: ui_density_dpi()=420, source "test_android_density_fixture", fixture_safe_area override from "recorded physical inset from native run39222413584" L5, _apply_safe_area via layout_metrics.content_rect; _ui_metrics adds safe_rect and "recorded_android_39222413584_fixture".

### 69. game/tests/density_menu_scenarios.gd
Bytes 3797, lines 57, read in full.

Settings/operations stable logical action IDs (settings, loadout, volume_music, volume_effects, mute, back) independent of label; wheel scroll reaches below-fold; BACK in menu_footer fully visible; briefing(5) footer has begin+back L35-55. Mouse (not touch) input.

### 70. game/tests/density_scenarios.gd
Bytes 6699, lines 79, read in full.

48dp target rule: dp=size*scale/(420/160), >=47.99; font >=13.99 dp L49-52; pages water/craft/tools/route/guard/fleet/inspect; opening pages does not mutate paused sim L53; chart area >=50% of viewport L63-64; hit rects not clipped and not overlapping L57-62; queued intent text "DRONE A - MIDDLE - QUEUE" L21; recorded inset 136 profile; briefing(5) ENTER WATER exposed L66-76. Note "MIDDLE" depth band label.

### 71. game/tests/density_scroll_scenarios.gd
Bytes 7064, lines 102, read in full.

TOUCH SCROLL: Input.set_emulate_touch_from_mouse(true) L58; drag with DEVICE_ID_EMULATION 30 motion steps L14-22; waits for coasting to rest and scroll_report_timer debounce L23-32; drag from disabled/enabled rows scrolls, no activation, no mission select L67-80; ordinary tap opens briefing L81-82; settings volume sliders and mute not toggled by drag L84-98 (AUDIO settings keys volume_music, volume_effects, mute).

### 72. game/tests/depth_policy_journeys.gd
Bytes 4145, lines 58, read in full.

Op0 baseline policy: quiet (dive to band 2) vs active (scout drone + emp + high-power sonar) both finish; matched staged control at (850,500): sweeper (sirens[1]) gets lock>1.0 on MIDDLE (band 1) Quietus, lock==0 and hull 100 on DEEP (band 2) L51-56 (BEAM LOCK depth cover). Modes LOCKING/BEAM L56. Quiet policy keeps more emp than active L57. Depth transitions take 4.1 s ticks. Sirens carry type "sweeper" with listen.pos L45.

### 73. game/tests/depth_policy_ui_tests.gd
Bytes 6630, lines 108, read in full.

Extends depth_sonar_ui_tests; real viewport input for the same two policy journeys at 2520x1080 / 2184x1968; first-warning/sweep hints pause for any craft, GOT IT does not resume, pause button resumes L12-18; planner preview taps via ScreenTouch+mouse; ScreenDrag pan fallback L49-51; crafted sonar_power/sonar_emit/sonar_history clicks; depth shift 4.1 s.

### 74. game/tests/depth_repair_scenarios.gd
Bytes 7760, lines 103, read in full.

Knockdown (torpedo `knock`) targeting rules on op4: preview independent of hidden roster/stun/transition L26-31; band-local terrain blocks L32-33; cross-band allied observation not usable L34-36; rejections spend no ammo (tools.knock stays 2) L44-51; stale contact (time -1), range +500, stun 3 reject; triangulated unresolved-depth contact cannot be targeted L52-53. Blackwater buffer winch 4.2 s on DEEP; interrupts: route, loss, depth change, transition, terrain, custody L61-70; moving vel 3 resets winch L58-60. Local work ignores peer selection geometry L71-103.

### 75. game/tests/depth_sonar_scenarios.gd
Bytes 11552, lines 122, read in full.

Depth bands 0 SHALLOW? 1 MIDDLE 2 DEEP (band names MIDDLE/DEEP in labels; band 3 invalid L118-119). Sonar: passive machinery gives bearing history (classification "MACHINERY", confidence<.5, band -1) L21-24; own motion 96 masks passive L25-26; two-drone triangulation labelled source "triangulation" L27-29; ping spends oxygen, echo delayed (2.4 s for ~850 range) and keeps emission-time pos/time, source "active" L34-39; default low power cannot resolve 600 m reflector, high power can L42-45; opaque full-height geometry blocks echo L46-47; lock: different-band guard cannot beam through thermal separation L55-56; guard follows acquired depth, shared band: lock then 3.2 s later outcome=="lost" hull==0 L57-61 (BEAM LOCK -> LOSE); known_band only from visible transition L48-54; Depth.clear(s,pos,pos,band,radius) tests; 4.1 s depth transition; deep wreck band retained, middle craft cannot winch deep cargo L75-86; extraction needs band 1 at recovery mouth L107-111; sweep_received audio cue only to receiver L112-114; EMP noise carries emitter band L115-116; diffracted echo bearing records corner arrival L97-100; ambiguous motor tones no false triangulation L101-104. All registered ops roundtrip L18-20.

### 76. game/tests/depth_sonar_tests.gd
Bytes 300, lines 9, read in full.

Wrapper running depth_sonar_scenarios.gd.

### 77. game/tests/depth_sonar_ui_tests.gd
Bytes 4799, lines 67, read in full.

Touch UI for depth/sonar: cancel/drag(24 px)/pinch rejections preserve state for depth_down, sonar_sector, sonar_power, sonar_emit L34-44; depth_down starts one transition to band 2, planning keeps pause L45-47; 250 frames -> band 2, "DEEP" text L49-51; sonar_sector forward + power high L52-53; pulse spends oxygen, pending echo; 156 frames reflection; history opens waterfall with BEARING text L57-65. Sizes 2520x1080 / 2184x1968.

### 78. game/tests/divergence_save_tests.gd
Bytes 2780, lines 33, read in full.

Op6 Divergence saves: legacy tutorial completion opens [6]; deterministic signal clocks L15-16; evidence "divergence_deep" note; nonfinite bearings, recovered flag without evidence, unsupported route facts rejected L22-27; premature continuation (op7) archive rejected L28-29.

### 79. game/tests/divergence_tests.gd
Bytes 3098, lines 36, read in full.

Op6: observable_sites empty at start; signal_readings no pos/source/points, fields origin,direction,time,uncertainty,receiver,label L18-19; deep source observed at +180 distance (passive) in 0.1 s; shelf by drone at +150 after 0.9 s; exit corridor wins ("won", chosen_route "shelf") L24-26; unarmed basin cannot win; withdrawal armed -> outcome "withdrawn" grants nothing L33-34 (third outcome string).

### 80. game/tests/drone_drive_tests.gd
Bytes 5379, lines 58, read in full.

Drone drive modes: quiet = 42 m/s (vel 40..42.01 after 180 frames), transit = 96 m/s, accelerates not jump L18,26; invalid mode "warp" rejected atomically L24; `silent` profile independent of drive L19-21; legacy untouched drone keeps >42.01 thrust L30-31; route_edit index/mode/stop; undo preserves intentions L36-40; near-wall quiet turn keeps clearance L50-57.

### 81. game/tests/drone_drive_ui_tests.gd
Bytes 5920, lines 76, read in full.

Touch UI: ScreenTouch tap, optionally plus emulated mouse for buttons L11-17; route planner propulsion button cycles INHERIT -> TRANSIT96 -> QUIET42 L43-47; LOW PROFILE unchanged L47,63; ship-local instrument shows QUIET42 L61; control >=125.99 px tall L72; planning collects no time L48-49.

### 82. game/tests/drone_operations_tests.gd
Bytes 7352, lines 82, read in full.

Scout condition: contact_hold -> hold "SCOUT", on own passive observation -> "SCOUT_STOP" with route kept; fleet CONTACT legacy hold; seen_by observer ids (range 0..2, no duplicates) L36-39; survey/sonar-only contacts do not trip scout L42-43,54-58; thermal front weakens L46-50; both drone profiles keep fixed-thrust >80 speed L62-64; scout brakes real momentum (vel >90 first frame, <.1 after 2.5 s) L65-67; visual acquisition distinction 180 (LOW) / 290 (OPEN): target -1 vs 1 at (420,130) L68-71; drone loss preserves SCOUT_STOP + observer attribution through restore L72-81.

### 83. game/tests/drone_operations_ui_tests.gd
Bytes 3486, lines 36, read in full.

Mouse-click UI: drone profile button text "LOW\nPROFILE" -> "OPEN\nPROFILE" and spends no stock L19-21; scout arms SCOUT; latched stop shows "SCOUT STOP . BRAKING", ALERT, RESUME, "route kept" "own contact" L24-27; legacy hold text "FLEET\nGUARD"; Quietus keeps "IF\nCONTACT" and "SILENT ✓" L33; control height >=126 px.

### 84. game/tests/early_reward_tests.gd
Bytes 2625, lines 41, read in full.

Early reward after op1 win grants quietus_tele_lens once (Table.GRANT.operation==1) L15-23; lost/other ops grant nothing L16-19; free lens fits standard hull, Catalog.budget power 1 endurance 1. L26; Table.enabled off switch L27-30; optional early_reward field validity L31-35. Story/progression not LOS.

### 85. game/tests/early_reward_ui_tests.gd
Bytes 4121, lines 49, read in full.

Extends fix2_menu_ui_tests; op1 win debrief shows "NEW FITTING . Tele lens" once; reward never auto-equips active dive; Fittings screen explanation; touch target >= ui_touch_height; Android Back leaves Fittings; save/reload preserves; new campaign resets L44. Two shapes 2520x1080 / 2184x1968.

### 86. game/tests/earned_course_continuity_tests.gd
Bytes 9911, lines 99, read in full.

Route intent vs terrain chart: measured safe prefix travel, chart_stop "New terrain" when measured obstacle, "Physical clearance stop" requires explicit new order L94-95; speeds 42 (silent), 78, 96; autonomous detour uses only certified corridors, A* known_path cached L63-72; SCOUT_STOP drone holds, released drone repairs its own course w/o changing selection L81-85; crossflow composes L86-93; observed_save(args[0]) restores a preserved player profile read-only L28-38.

### 87. game/tests/earned_equipment_tests.gd
Bytes 2444, lines 29, read in full.

Equipment_catalog: choose() returns copy; correlator Quietus-only, sampler drone-only, one sampler not clonable across drones L20-22; unknown slot/item invalid; public_catalog cards have name, compatible_slots, benefit, cost.

### 88. game/tests/expanded_region_journeys.gd
Bytes 1648, lines 28, read in full.

Op1 Split Channel: split_channel_command_plan.play() (coordinated drones+Quietus uplink) must win with all_records and tools.recon==2 (note: references res://tests/split_channel_command_plan.gd, absent from this slice) L8-11; solo Quietus path auto-EMPs when contact lock>1.0 and emp>0 L21-22; coordinated faster than solo by >30 s L25.

### 89. game/tests/expanded_region_tests.gd
Bytes 3201, lines 41, read in full.

World sizes: op0 Vector2(1600,960) L12; op1 Split Channel Vector2(2000,2400), navigation region 50x60 cells (40 px cells) L15-17; physical edge blocks (2010,2000); basin overhang occludes passive returns, `recon` reveals nearby cover but not whole world, tools.recon stock 2 -> 1 and recon_time==8.0 s L26-29 (RECON LOS: local survey sees behind cover, 8 s duration); malformed world_size INF / 20000x24000 / fog cell (50,60) invalid L34-39.

### 90. game/tests/expedition_instruments_ui_tests.gd
Bytes 10401, lines 120, read in full.

Expedition view: only selected receiver's historical public arrival arcs drawn L43-46; no hit region; directionless reception draws nothing "unresolved" L47-48; op6 home button text "WITHDRAW" (tutorial "EXTRACT") L57,118; badge >=126 px; detail text has "ARRIVAL", "may bend", "source fix" L74; sheet < min(50% height, touch_height*3.2); touch scroll via ScreenTouch/Drag + emulated mouse with Input.set_emulate_touch_from_mouse(true) L100-110; corridor tap opens context, "PLOT" route_here, no camera L114-116.

### 91. game/tests/expedition_menu_tests.gd
Bytes 3021, lines 40, read in full.

Main with 1280x720: completed tutorial offers action expedition6 in Operations; start op6 via _enter_water; unlocated sources; success preserves tutorial completed [0..5], unlocked 5; route "shelf" -> expedition8 button only, expedition7 hidden L36-37; text gallery for acoustic notes L34.

### 92. game/tests/extraction_survival_tests.gd
Bytes 4225, lines 52, read in full.

WIN/LOSE PRECEDENCE: with all records captured, siren charged beam lock 4.0 at 220,800 (hull 0.15) or oxygen = STEP/36.0: causes hull, oxygen, both resolve to "lost" and surviving to "won" in the same tick (survival resolved BEFORE extraction) L26-29; message prefixes "Archive recovered", "Life support exhausted.", Simulation.VAPORIZED_TEXT L30; extraction event only for survivor L32; winning tick still consumes oxygen and keeps hull L33; batched advance 0.1/0.25 equals STEP L34-36; pause defers both L37; terminal state frozen, restored terminal cannot resume L38,45; debrief credit completed [0]/unlocked 1 only on win L39-40.

### 93. game/tests/field_sampler_tests.gd
Bytes 1730, lines 22, read in full.

field_sampler.capture_spec(unit,fitted,task): drone with sampler -> {duration 8.0, noise_radius 520.0}; Quietus/unfitted/other drones/incompatible tasks empty L14-20 (matches 520 noise radius used elsewhere).

### 94. game/tests/finale_command_plan.gd
Bytes 2654, lines 53, read in full.

Helper play(coordinated,stage,protect,abandon,existing): op5 "disruption"; auto EMP when contact target!=abandon with lock>1 and fresh <0.3 s and emp>0 L9-10 (BEAM LOCK defence); sequence: crown (1010,240) camera 2+3.5 s, wakes (1190,780), receiver (690,780) 3+3.5 s, warning stage, return stage emergency to extraction; non-coordinated uses decoy L35.

### 95. game/tests/finale_scenarios.gd
Bytes 3874, lines 42, read in full.

Op5 finale rules: receiver objective kind "receiver" required_unit 0 duration 6.0 requires [0,1] L7-8; transmitter/departure/warning optical keys L9; sirens stun=30.0 isolate L12; drone cannot replace shipborne hydrophones L19-20; passive decode emits no CAMERA noise L24; pause freezes acquisition L25; half-heard restore (30+35 frames of 0.1) L26-31; resolved warning still needs Quietus returned L31; accepted-finale.archive incompatible rejected with warning L40-42.

### 96. game/tests/finale_ui_scenarios.gd
Bytes 1386, lines 20, read in full.

Finale UI: incompatible save rejected L3-6; LEE RECEIVER / LISTEN control text L10; evidence gallery warning plate res://src/presentation/evidence_catalog.gd IMAGES.warning L19.

### 97. game/tests/first_siren_cue_ui_tests.gd
Bytes 5902, lines 75, read in full.

Extends fix2_menu_ui_tests. FirstSirenCue node under hud: siren at +120 units, s._threats(.1), `siren_notice` signal; cue.voice plays warning, stream_paused on NOTIFICATION_APPLICATION_PAUSED and on pause button, game.sound.suspend()/resume(); mute silences L50-51; cue is MOUSE_FILTER_IGNORE (never steals touch) L22; font>=18, marker height >=0.8*ui_touch_height L24; label contains "FROM Q" if craft switched L26; cue.Table.AUDIO.id/.pitch, Table.DURATION; once-only per Siren id archived as "first_siren_seen" (list of unique non-negative ids) L56,66-69; later operations (op4) never show cue L70-71. AUDIO + LOCK WARNING cue.

### 98. game/tests/fit_label_main.gd
Bytes 315, lines 6, read in full.

Test subclass of density_main.gd: fixture_dpi default 95.0, ui_density_dpi() returns it, source string "fit_label_desktop_or_recorded_android_fixture"; _report_targets() silenced.

### 99. game/tests/fit_label_scenarios.gd
Bytes 4029, lines 50, read in full.

Zoom buttons (zoom_buttons) fit on one line, height == ui_touch_height, font>=13.99 dp, touch min 48 dp (at dpi420 scale 420/160), inside safe area and chart, non-overlapping; FIT click returns chart zoom to 1.0 and changes no sim state L46-48. Profiles desktop 1280x720 dpi95, cover 2520x1080 dpi420 inset136, inner 2184x1968.

### 100. game/tests/fix2_camera_ui_tests.gd
Bytes 3763, lines 60, read in full.

Extends challenges_ui_tests. Viewfinder: opens when subject near (o+facing*100); control rect >=48 dp (dp = scale*160/420) L19-20; fleet/pause controls >=48dp; tap on camera control changes framing mode without plotting route (route unchanged) L27-30; Settings.current.text_scale 1.25/1.5 scales font, reduced_motion freezes feed time L32-37; fitted photo_flash + tight shows 3 controls inside feed L38-45; focus control responds L46-49.

### 101. game/tests/fix2_feedback_ui_tests.gd
Bytes 2122, lines 27, read in full.

STUN DISPLAY: siren at +60 with lock .2, target 0, mode LOCKING; after real EMP touch, contact_entries text contains "STUNNED" and NOT "BEAM" L10-14; lock_warning.visible false for a stunned contact L15; read-only refresh L16-17; hints_seen persisted incl "priced_film" in optional archive field "hints_seen" L18-22.

### 102. game/tests/fix2_frontend_ui_tests.gd
Bytes 2434, lines 39, read in full.

Extends challenges_ui_tests. Title overlay: erase-progress absent from title (frontend_new_campaign), present in settings L11,16; Android Back (NOTIFICATION_WM_GO_BACK_REQUEST) and Escape return settings->title, detail->list->title; Back above fold; shapes 2520x1080, 2184x1968, 960x432.

### 103. game/tests/fix2_menu_ui_tests.gd
Bytes 1986, lines 32, read in full.

Base helper class for several UI tests (button lookup by ui_action/action meta). Operations: resume row never shifts mission rows L10-14; separate Fittings entry; Quietus hull frames Catalog.frames(0), frame_quietus_quiet sets fitted_equipment.hull=="quiet" L17-21; briefings of ops 3,4,5 show "GOAL:" and "DANGER:" without "ORDERS\n" L24-28.

### 104. game/tests/fix2_optional_recovery_tests.gd
Bytes 1510, lines 16, read in full.

Extends res://tests/shelf_habitat_journey_tests.gd (NOT in this slice; referenced file). Optional photo objective (kind "", optional true) doesn't block recovery nor erase sampler/next op L9-10; incomplete mandatory record grants neither progression nor reward L11-14.

### 105. game/tests/fix2_photo_routing_tests.gd
Bytes 2262, lines 40, read in full.

Siren study routing: ops [5,6,7,8,9,21..28]: fresh() places sirens[0] 60 units away in clear same-band water (Depth.clear), photo candidate>=0, camera_context ready with target -2 (Siren study); target index >=Photo.STUDY; cross-band (band 2) rejects; ops 7,8 optional frame target; powered plant (op10 warning_chain.power=umbilical) keeps its existing work context L38-39. Recon LOS via Depth.clear.

### 106. game/tests/fix2_save_tests.gd
Bytes 2728, lines 43, read in full.

Op1 photo retake: first housing exposure 5 s completes; retake for "clock" feature allowed; partial retake at 0.25 s validates, saves (version 1 envelope) and restores L22-34; elapsed INF/100/ missing subject invalid L35-40.

### 107. game/tests/fix2_save_ui_tests.gd
Bytes 1882, lines 32, read in full.

Save-failure UX: first write failure silent, retry deferred write works; a repeated failure shows archive_status + save_retry_button, g.save_error set L19-27. Orders message preserved.

### 108. game/tests/fix2_state_tests.gd
Bytes 2107, lines 35, read in full.

STUN DISPLAY clock: Context.resolve; observed_stun optional contact field: Stun.remaining(c,6.) with c.time=4, observed_stun=12 -> 10.0 (observed_stun - (now - time)) L17-18; INF or negative invalid L19-22; loss_summary.Summary.line(s): beam loss line contains "140 m" and "last" (last observed range) L27-31; no contact -> no invented range L32; empty oxygen -> "Life support" L33-34; message constants VAPORIZED_TEXT, "Quietus lost.".

### 109. game/tests/fix2_study_ui_tests.gd
Bytes 1679, lines 24, read in full.

Ops 7,27: real PHOTO touch starts the late Siren study (captures[0].target >= Photo.STUDY); unit button and fleet.task(0) show "PHOTO"; optical_feed.subject_view().index >= STUDY; mid-exposure snapshot valid.

### 110. game/tests/fixtures/blackwater_first_extract.gd
Bytes 18264, lines 711, read in full.

Data fixture derived from genuine e638 Blackwater 15.6333 s first extraction; STATE const (L5-680) + OBJECTIVES (L681-699) + RECON (L700-705) + COURIER_LAUNCH 14.6333 (L706) + make() L707-711. Keys/values: elapsed 15.6333, hull 100, oxygen 111.3148, tools {decoy 3, emp 0, knock 2, recon 2} L641-646, ping_time 0, recon_time 0, selected 2. Sirens (2 patrollers) fields: alert_floor 0.12, angle, attention_time 12.0, goal, home, last_known, lock 0.0, mode "DISRUPTED", path_time, patrol, patrol_index, patrol_points (4 points), pos, route, search_index, stun 9.9999999999999, suspicion, target -1, type "patroller", vel L598-640. EMP evidence: noises label "DISRUPTION" radius 650.0 (time 2.1e-15, i.e. just emitted) L582-592; stun ~10 s at 0.083 s after emission => EMP stun duration 10 s. Contacts: mode DISRUPTED, lock 0.0, seen_by [1]/[2], target -1, type patroller L7-28. Units: Quietus (140,800) silent true; drones battery 93.5 / 92.3; drones have &"route_plan" StringName key L665,676. Known fog cells Vector2i grid 40 px cells (known dict ~540 cells). Objectives: exchange kind, duration 2.0, evidence text L684,693 ("SAMPLE 2s within passive reach", "SONAR under 240m ... 3s reply"), REQUEST pos (760,200), REPLY (1360,480), replay_until 0.0. RECON: delay 6.0, floor 16.0, hunt 24.4, secured [0,1] L700-705 (mission.reconnaissance: hunt response after both records secured).

### 111. game/tests/fixtures/split_channel_legacy.gd
Bytes 561, lines 11, read in full.

Loads split_channel_legacy.bin (production snapshot e877e79) via get_var and restore; upgrade "disruption" adds +1 emp (L8), "endurance" sets oxygen 120.0 (L9). Legacy-save fixture, no profile data.

### 112. game/tests/foundry_command_plan.gd
Bytes 2710, lines 47, read in full.

Scripted op3 Foundry play helper: advance() auto-EMPs when contact.lock>1 and contact fresh <0.3 s and emp>0 (L8-9; lock threshold 1.0 scale, beam lock cover); travel() routes, stops on outcome/death/arrival <20 px and vel<2 (L10-19); play() stages initial/approach/furnace/cradle/response/complete, coordinated uses Quietus (740,800), drone A, queued withdrawal, decoy (L20-47). Outcome "won" check L16.

### 113. game/tests/foundry_departure_tests.gd
Bytes 5117, lines 56, read in full.

SceneTree test for op3 departure_revision==1 (L13), legacy archives get no departure state (L16-19), "DEEP MOTOR" noise label (L19,40), pause freezes events (L20), departure_feedback gives bearing only unless inside own range+clear sight (L24-28), hull footprint clear along course (L30-33), remote receivers not globally revealed (L34-35), restore preserves timing (L37-39), one finite departure (L40), unknown revision/chapter/NaN clock reject in valid_snapshot (L41-43), industrial audio cue only for selected receiver, one cue, no spam (L45-49), motor cannot override optical lock: sirens[1].target==0 and lock>0 (L51-53), other chapters 0,1,2,4,5 unaffected (L54-55).

### 114. game/tests/foundry_scenarios.gd
Bytes 2665, lines 29, read in full.

Cold Foundry scenario: structures present, extraction >900 px from Quietus, objectives FURNACE VENT and LAUNCH CRADLE (L5-7), blocked/line_clear agree with structures (L9-11), sirens stunned 30 to isolate semantics (L12), camera needs furnace first (L15), factory response phase "response" + noise label "FACTORY RESPONSE" (L23), restore preserves mission and paused (L24-25), coordinated queued play ends "won" with both drones alive (L27-28).

### 115. game/tests/frontend_scenarios.gd
Bytes 6196, lines 79, read in full.

Settings and frontend: SettingsStore defaults/sanitize (master clamp, effects fallback 0.8, text_scale snaps 1.15/1.5, L13-21), damaged file falls back with warning (L22-24), FrontendSettings.apply: master bus db, music/effects volumes to soundscape, theme font 17*1.3, high contrast font color ffffff, reduced_motion, haptics blocks vibrate (L26-36); profile inspect NONE/OK/UNREADABLE, message contains "untouched", preserve_unreadable copies aside (".incompatible-42") (L38-48); title offers continue/settings/credits, reset lives in Settings (L54), ProfileNotice disables continue (L55), CC-BY credits Michael Brigida (L60), 48 px touch height on settings controls (L63-64). Save envelope version 1 L42. Touch/audio handling.

### 116. game/tests/frontend_stub_host.gd
Bytes 813, lines 19, read in full.

Minimal main.gd stand-in: SaveStore, Soundscape, settings {music .5, effects .8, mute false}, ui_touch_height 48.0, theme font 17, _confirm_new_campaign flag.

### 117. game/tests/glass_network_tests.gd
Bytes 3481, lines 48, read in full.

Op14 buoy/relay network_feedback: stationary quiet craft gives no contact (L24), received ACTIVE SONAR noise latches uncertain grid point (L25-27), delayed relay forward, not instant (L28-33), relay recruits armed investigator last_known and known_band 1 (L35), expiry no loops (L37-38), band 2 defeats buoy hearing (L39-40), EMP interrupts charge (L41-42), terrain blocks (L43-44), feedback reads contacts not hidden roster (L45-46), pause freezes (L31). Stationary-craft note: a quiet stationary craft is not heard (L24).

### 118. game/tests/glass_reach_journeys.gd
Bytes 7454, lines 87, read in full.

Ops 14-21 bare-Quietus authored courses (COURSES L28-38), depth bands via dive (L23-25), actions go/depth/work/camera/recover/exit; progress() builds v2 campaign progress with completed [6,7,9,11,12/13], confluence_route concealed/overt, resolution concealed_recovery/overt_warning (L55); expects outcome "won", tools unchanged, launch_equipment empty (L62); save envelope version 1 unlocked 5, completed [0..5] checksummed roundtrip (L75-77); research entitlements quietus_prism and quietus_decoder (L79); decoder opens gate within 120 m in 2.1 s (L81-84); glass_choice service vs sever alters structures and sirens (L85-86).

### 119. game/tests/glass_reach_tests.gd
Bytes 1441, lines 23, read in full.

Ops 14-21 each authored, world_size.x>=2000, valid snapshot and restore, sirens in open water (Depth.clear 16), eight distinct rock topologies (L21), prerequisites_met(14,[12]) or [13] true, [11] false (L22).

### 120. game/tests/glass_reach_ui_tests.gd
Bytes 6206, lines 70, read in full.

UI test at 2520x1080 and 2184x1968 with density_main.gd; actual touch via ScreenTouch plus emulated mouse tap_at (L13-17); ending offers continue_glass (L28-31); glass_work/glass_service/touch height >= ui_touch_height (L32-40); salvage marker tap -> salvage page (L46-58); SONAR emit gives "BUOY CHARGING" row (L60-64); prism fitting shows "0.8 RESERVE" cost text (L67-68); capture PNGs only when not headless.

### 121. game/tests/glass_research_tests.gd
Bytes 2925, lines 33, read in full.

glass_research ledger: discovery grants nothing, recovered prism_core pays quietus_prism, replay cannot farm, keeper_wafer buys quietus_decoder, entitlement without spent material rejects (L14-28); prism fitting earns 600 m directional echo return (L30), prism costs double reserve oxygen ((120-ox) x2) and larger noise radius (L31); sonar_mode sector forward power low.

### 122. game/tests/glass_work_tests.gd
Bytes 6583, lines 86, read in full.

Local glass_action: recover winch, transfer, partial restore, pause freeze (L21-29), interrupts by route/loss/band/blocked (L30-39), carrier loss leaves "wreck" in occupied band (L40-41), service opens gate (L42-45); decoder locality: bare range 60 m, 8 s, noise REACH MACHINERY radius 520; fitted Quietus 120 m, 2 s, silent (L53-86). Mission.glass_reach.job persists across peer selection and restore.

### 123. game/tests/grade_on_secure_tests.gd
Bytes 1346, lines 27, read in full.

photo_grade/grade_on_secure.gd: letter A>=.9?, B .7, C .3 (L10), note " · frame 62% grade B" (L12), _record_secured message "Record secured ... frame 33% grade C" (L17), no grade text without frame (L21), Grade.enabled=false restores old message exactly (L22-25). Feature switch.

### 124. game/tests/independent_capture_tests.gd
Bytes 4281, lines 69, read in full.

Op1/2 camera rules: parallel captures by two drones, noise label CAMERA per craft (L26), exposure ~4 s (tick 4.1), first craft owns record, second rejected without emission (L34-37), single record raises recon floor to 8.0 with secured==[0] (L39), photo_craft "DRONE A" (L40), interruptions death/move/cover (L41-48), pause freezes (L49-51), duplicate capture target rejects in valid_snapshot (L52-53), save v1 roundtrip (L55-61), Quietus camera fallback after drone loss (L63-67). Recon: reconnaissance.floor 8.0 per secured record.

### 125. game/tests/independent_capture_ui_tests.gd
Bytes 2895, lines 48, read in full.

UI touch (ScreenTouch + emulated mouse L11-18) at 2520x1080 and 2184x1968; both cameras work independently, fleet status contains "PHOTO", optical_feed visible only for drones (id>0), capture_time 1.0 after 60 ticks, switching stations preserves exposures.

### 126. game/tests/industrial_jobs_tests.gd
Bytes 9713, lines 117, read in full.

Ops 22-29 choir_action jobs: equalizer lock_a 7.2 s + 8.2 s, pause freeze, attach/tow, free on carrier loss (L25-32), hidden vessel no live tracker, observation freezes position with age (L33-39), artifact wreck band 2 (L40-43), save validity rejects missing iron_choir/sites/trail/transit (L44-51), worker can't salvage another module (L52-55); rules: 22 sled jams at shut gate and mission "lost" after 150 s (L60-63), opened gate arrives with hull>=100 (L64-66); 23 lock sequence reasons "Finish LOCK_A first"; 25 sled advances only with craft near; 26 hammer seals west mouth after ~101 s, Rect2(1100,350,150,150), cooling release 8.2 s; 27 counterweight slides back unless chocked; 28 bell; 29 breaker drops after 151 s window, stamp -1.

### 127. game/tests/industrial_threats_tests.gd
Bytes 5893, lines 71, read in full.

Industrial enemies interceptor and warden (op22/23): BURST WINDUP seen from sound gives sonar.history row without contact (L20-21), windup commits stale aim (L24-25), physical burst misses relocated craft (L28), warden patches finite expire (L29-32), knock pin_time>7 then EMP stun longer than pin (L37-41, EMP stun > pin), NPC load can be destroyed -> outcome "lost" (L42-43), occupied band acquisition via Depth.sight and shared bands (L46-70), sleeve fitted variants, terrain blocks acquisition (L68-70). Win/lose: "lost" when NPC load destroyed.

### 128. game/tests/interface_scenarios.gd
Bytes 991, lines 11, read in full.

Mission start: camera button hidden until craft tapped, pause_button visible (L4), craft projection reveals camera without mutating paused state (L5-7), route submenu exposes waypoint_mode and home (L8-9), STOP/PASS selection returns to water with sim.pass_through false (L11). Touch UI.

### 129. game/tests/iron_choir_journeys.gd
Bytes 12738, lines 147, read in full.

Bare-Quietus staged journeys through ops 22-29 with course/work/escort helpers, progress() completed [6,7,9,11,12,14..19]; each must end outcome "won", hull>0, tools unchanged, launch_equipment empty (L102); variants dismantle for 29, opposite replay cannot rewrite choir_choice (L122-128), entitlements quietus_pressure_sleeve and drone_traction_yoke (L116), sleeve transition.remaining==2.5 (L132), checksummed save v1 roundtrip (L144-146). Op25 outcome depends on sites[1].done service (L119).

### 130. game/tests/iron_choir_tests.gd
Bytes 1670, lines 26, read in full.

Ops 22-29 catalog: each has iron_choir, objectives empty, sites non-empty, valid snapshot, Depth.clear 12 for enemies (L14-19), eight distinct site structures, stamp==-1 and sealed false (L23), prerequisites_met(22,[19]), 26/27/28/29 unlock after 22/23/24 (L24-25).

### 131. game/tests/iron_choir_ui_tests.gd
Bytes 5770, lines 57, read in full.

UI at 2520x1080 and 2184x1968 with touch tap (ScreenTouch + emulated mouse L11-14); expedition23 button, craft choir_work, size.y>=ui_touch_height, interceptor contact mode "BURST WINDUP" visible (L49), warden patches visible (L54), ballast pick_context subkind "choir". Capture PNG skip on headless.

### 132. game/tests/iron_research_tests.gd
Bytes 3439, lines 39, read in full.

Pressure sleeve and traction yoke fittings: recovered materials fund entitlements, replay cannot farm (L16-22); sleeve shortens depth transition, costs oxygen and PRESSURE SLEEVE noise (L26), drone transition stays 4.0 (L29); yoke speed 22 and propulsion noise (L38), Depth.clear 16 vs 32 (L36).

### 133. game/tests/knockdown_scenarios.gd
Bytes 11637, lines 128, read in full.

KNOCK torpedo (op4): tools.knock==2 (L18); launch range 150 m exact (L53-56); physical projectile, pause freezes; impact pins 8 s (stun>7.7, mode "PINNED", pin_time) (L30-35); pin interrupts beam: lock==0, target==-1, vel zero (L35); noise label "KNOCKDOWN" radius 650.0, suspicion>=0.45 (L36); EMP stun 12.0 (L104) and EMP over pin: stun>10.9 not resetting snare (L101); cover blocks launch (L70); only Quietus can launch (L72); invalid targets rejected with no spend; legacy stock absent (L105-106); torpedo audio cue bounded gain <=0.31 (L115-118); old archives accepted-blackwater.archive and accepted-finale.archive rejected incompatible (L120-122). Stun display: mode "PINNED". Audio headroom bound 0.31.

### 134. game/tests/knockdown_ui_scenarios.gd
Bytes 5400, lines 61, read in full.

UI profiles desktop 1280x720 dpi95, cover 2520x1080 dpi420 inset136, inner 2184x1968 dpi420 (L25); fit_label_main.gd fixture; knock button >=48 dp (L36); armed text must include QUIETUS, 150m, "impact pins 8s", "noisy flight", CANCEL (L38); invalid tap spends nothing and plots no route (L43); stale target rejection (L46); unit switch clears knock_armed (L49); mouse click only (no ScreenTouch) here.

### 135. game/tests/known_water_observation_tests.gd
Bytes 1469, lines 30, read in full.

Probe subclass counts visible() calls; certified known cells (TILE grid) never re-queried (L19-21), repeated paused _observe preserves snapshot (L17), recon tool path finite (L26-28). Recon LOS: visible(point,band) per-cell sight.

### 136. game/tests/listening_well_command_plan.gd
Bytes 1624, lines 34, read in full.

Op4 play helper: travel with EMP when contact.lock>1 and fresh (L13-14), decoy deployed at clear-water 160 m (L25-26), silent cruise variant (L27-29), camera on 3 objectives (waypoints (800,390),(1150,450),(780,850)) with 80 ticks (L24-32), then extraction. Quietus-only; drones disabled L22.

### 137. game/tests/loadout_frames_tests.gd
Bytes 13952, lines 160, read in full.

Hull/chassis/mount/budget model: 3 hulls, 4 chassis (L28); standard frame baseline noise/endurance/pulse 1.0 cargo 2 (L33); quiet hull motion radius x0.7 (L63); fast hull speed 78*1.15 (L69); full power bus makes SONAR pulse cost 1.5x reserve (L79); quiet hull one winch place (L91); save version 2 with equipment, v1 single-slot archives still valid (L98-106); wrong-mount/over-budget/unearned rejected (L107-112); briefing frame buttons, launch freezes hull (L153-155). Mouse-only taps (L125-127).

### 138. game/tests/loadout_ui_tests.gd
Bytes 5720, lines 75, read in full.

Next-dive upgrade cycle endurance/disruption/survey: stock string "O2 %d%% DISRUPT %d SURVEY %d" (L28), advertised EMP duration 12s equals s.sirens[0].stun==12 (L52), survey 8s with RECON UPLINK noise and recon_time==8 (L53), resume preserves active dive snapshot (L47,54), new dive retains Quietus + two drones (L60), density 2520x1080 inset 136, 2184x1968. TUNING: EMP stun 12 s, recon 8 s.

### 139. game/tests/lock_warning_scenarios.gd
Bytes 1199, lines 23, read in full.

Lock warning (presentation/lock_warning.gd): countdown starts from first observed lock, remaining>3.9 when lock .01 (L10) i.e. beam fires at lock 4.0; lock 3.9 gives remaining<.11 (L12); only target==0 (Quietus) counts (L13-14); mode BEAM stops countdown (L15-16); stale observation (time 9 vs 10) none (L17-18); lock 0 none; hidden outside dive. Beam lock constant 4.0 s buildup; BEAM display replaces warning.

### 140. game/tests/lock_warning_ui_tests.gd
Bytes 2164, lines 33, read in full.

UI warning at 2520x1080 and 2184x1968: visible, locks.size()==1, show_hint (L22), banner within safe content (L23), no overlap with pause button (L24), mouse_filter IGNORE (L25), offscreen markers clamp (L26), refresh does not mutate sim (L27), lock 4.0 with mode BEAM hides panel (L30-31).

### 141. game/tests/metrics_transport_tests.gd
Bytes 4286, lines 58, read in full.

diagnostics/metrics_transport: SS_UI_METRICS_PART records with id/part/parts/bytes/sha256, <800 byte records vs 1023 logger limit, raw chunk <=450 bytes (L28-30), reassembly equals canonical JSON, water controls exactly pause, more_orders, fleet_q, fleet_a, fleet_b (L44), VIEW menu actions pause, radial_back, focus, fit, zoom_in, zoom_out (L50). Instrumentation, not gameplay.

### 142. game/tests/module_inventory_main_tests.gd
Bytes 5619, lines 56, read in full.

Main fleet ledger: op6 first launch freezes fleet_commit (L17), real shelf source sensing (L20-22), depart confirm with source "shelf" corridor (L24-26), debrief commits lost drone_deep_cells (L28), historical entitlement stays while stock lost (L29), archive includes "fleet" (L31), reload restores (L34-35), repeat debrief cannot respend (L41-42), completed replay noncommitting (L44), failed first attempt no spend (L46-47), new campaign clears (L48), bare-drone success acknowledges losses (L49-50). Story: op6 Divergence shelf route.

### 143. game/tests/module_recovery_runtime_ui_tests.gd
Bytes 5548, lines 67, read in full.

Physical module recovery UI via ScreenTouch + emulated mouse (L13-17) at 2520x1080 (inset 136) and 2184x1968: salvage_markers, "RECOVERY WINCH" noise, 4 s job (2 s then 2.1 s advance), cargo inert not installed on Quietus, "INACTIVE CARGO", KIT cue, status plate layout, snapshot unchanged by presentation.

### 144. game/tests/module_recovery_tests.gd
Bytes 15567, lines 132, read in full.

Salvage model: battery 0 drops module once at own position; winch needs settled craft (vel 0), LOS, 60 m, 4 s; noise RECOVERY WINCH radius 520 (L31); holds route (HOLD); audible winch makes unseen Siren INVESTIGATE with approximate origin, target -1 (L41-43); departure_context decision: confirm true/false, deferral survives RUN and restore (L60-74), unrecovered equipped drones need explicit decision (L64), bare drones expendable (L78-79), stale corridor confirm rejected (L83-85), ops 8 and 11 extraction waits for hardware decision, op8 shelf_warn galleries deliver, shelf receipts==2 (L86-104), Fleet inventory recover/available/launch semantics (L106-114), forged loss ignored, validation rejects malformed (L116-129), replacement drones always fresh battery 100 (L130-131). Win precedence: outcome "won" at extraction only after confirm; "withdrawn" yields no campaign spend (L110).

### 145. game/tests/module_recovery_ui_tests.gd
Bytes 10584, lines 119, read in full.

RecoverySim subclass with stub salvage/depart API; task text "RECOVER ... 25% FIELD SAMPLER", "CARGO ... INACTIVE" (L49-52); salvage marker tap opens context, "4s" label, one command (L63-70); departure screen pauses sim (L78), keep_recovering vs abandon_modules (L81-100), two-mouth op11 overt corridor (L102-114), holder return preserves silent and drone_drive "quiet" (L115), completed replay text "COMPLETED REPLAY ... stock unchanged" (L117). Op11 Confluence overt exit.

### 146. game/tests/nav_clearance_measure.gd
Bytes 1196, lines 22, read in full.

Independent geometry measurement for NAV1: leg_clearance against Depth.shapes band 1 polygons and world margin; route_clearance min over legs. Hull radius 12 used by tests.

### 147. game/tests/nav_clearance_probe.gd
Bytes 2034, lines 41, read in full.

Diagnostic: ops [0,1,3,4,5], player_path vs measured clearance; fails below 12, reports tight below 24 (planner margin); --sweep and --corners.

### 148. game/tests/nav_clearance_tests.gd
Bytes 1937, lines 30, read in full.

Cold Foundry (op3) corner regression: origin (889.6,800), shared s.path returns [(940,820),target] exactly as pre-NAV1 (L14); player_path clearance >=12 (L18); bare Quietus reaches target with hull 100 (L28-29).

### 149. game/tests/nav_clearance_ui_tests.gd
Bytes 3378, lines 51, read in full.

Route panel hull-band preview: hull_band.gd segments radius==12 (L38), touch edits destination (L31-32), zoom via navigation_buttons[1], Android Back via NOTIFICATION_WM_GO_BACK_REQUEST while touch held cancels pending tap and closes route_editor into paused play, no late waypoint (L44-49). Touch/Back handling.

### 150. game/tests/nav_following_probe.gd
Bytes 2056, lines 32, read in full.

Route following at dt 1/60, 1/16, 0.25 for 7 cases (ops 0,1,3,4,5), hull must stay 100 and settle within 20 px, vel<2; 240 s cap.

### 151. game/tests/navigation_departure_tests.gd
Bytes 6540, lines 83, read in full.

Op2 forward-order solo records with EMP when lock>1.0 (L26), return home "won" (L33); near-wall turn braking, turn-rate limit 1.8 rad/s (1.8/60 per tick, L42), hull never inside wall (L45), unavoidable inertial collision message "unsafe terrain" with unit name and safety stop (L66), pause preserves inertia (L68), restore identical future (L71), emergency replacement overrides turn (L73-74), queued pass/stop retained (L75-77), OPEN_WATER_TRACE_SHA256 and ENEMY_TRACE_SHA256 baseline comparison prints (L62,81). Speed 78 top (fresh_wall velocity 78.0 L64).

### 152. game/tests/observed_contact_scenarios.gd
Bytes 3425, lines 37, read in full.

contact_feedback entries: "S2 HUNTER · INVESTIGATE", stale "S2 HUNTER · LAST SEEN 3s" (L11-13), hidden state cannot alter readout (L17-18), pause freeze, expiry by 34 s (obs time 13, expired at 34, i.e. memory <21 s, L23), locking row "S3 GUARD → QUIETUS · BEAM 2.5s" for lock 1.5 (L30; countdown = 4.0 - lock), stale contacts cannot keep BEAM claims (L31-32), decoy message "Decoy launched · 15s transmission" persists after expiry (L34-37). TUNING: decoy transmission 15 s; beam buildup 4.0 s.

### 153. game/tests/observed_contact_ui_scenarios.gd
Bytes 3149, lines 36, read in full.

Chart consumes contact_entries and contact_readout_rects; LAST SEEN 3s row; covered locking contact not urgent when line_clear false (L13-15); 2520x1080, 2184x1968, 1280x720: urgent beam first with "BEAM 2.0s" (L28), 3 rows inside chart, above optical_feed, avoid zoom buttons, no overlap. Recon/LOS: cover guard.

### 154. game/tests/onboarding_tests.gd
Bytes 8393, lines 123, read in full.

First-run hints_seen flags valid ["move","sweep","pause"] etc., unknown rejected in store.valid (L31-38); opening briefing under 420 chars with GOAL and DANGER, rules behind manual button, "stationary seconds" in FIELD MANUAL (L44-50, stationary-sub rule text); no erase wording on fresh campaign (L56); undo chip, pending marker, REPLACE/ADD/undo (L61-87); hints show once, never pause play except first (L89-100); camera_caption "NO SITE"/"NOT READY"/"READY" (L102-108); text scale 1.5 keeps touch >= ui_touch_height and 1.55x width (L112-114); status text wraps (L117-121). Click uses mouse events only.

### 155. game/tests/onward_mission_tests.gd
Bytes 1382, lines 25, read in full.

Ops 9 and 10 distinct, valid snapshot, not all_records at start, path launch to extraction, restore; op9 signal_readings label "UNRESOLVED CARRIER" without id or pos, optional repeater cannot complete packet. Story frame: op9/op10 onward chapters.

### 156. game/tests/opening_depth_journeys.gd
Bytes 9897, lines 128, read in full.

Baseline-fleet scripted solves of ops 1-5: split (depth 2 underpass, (660,2100), (900,1730), captures by drones, shallow_at_link), blackwater (blackwater_handoff carrier 1, drone_drive quiet/transit, REPLY at (1360,340)), foundry, well (shallow west, hunter, well_reference/well_observation empty when quiet), finale (Song, 6 s listen); each needs outcome "won", tools emp 2 decoy 3 recon 2 knock 2 (L46,75) and valid snapshot. Start tools constants emp 2, decoy 3, recon 2, knock 2.

### 157. game/tests/opening_depth_policy_ui_tests.gd
Bytes 8339, lines 126, read in full.

Subclass of depth_policy_ui_tests.gd; same ops 1-5 via actual touch (viewport touch plus emulated release), planner mode button cycle (silent/cruise), band shifts via depth_down/up, ends outcome "won", tools unchanged (L122), valid snapshot; acknowledge_warning helper; arcs per op.

### 158. game/tests/opening_depth_scenarios.gd
Bytes 10691, lines 134, read in full.

Depth geometry per opening (Split underpass/saddle/sill, Blackwater middle relay handshake replay_until, deep sweeper, Foundry DEEP MOTOR band 2 and thermal_revision 1 transmission .55, Well well_reference earned only in middle cruise, finale reports carry known_band via legit observation, visible shared-band target stays vulnerable: outcome "lost" hull 0 lock>4 L89, matched active ping high power gives known_band and costs >=1.19 oxygen (L108-109), depth-toggle exploit leaves hull<70 (L117), private listening window 4.8+ s belongs to emitter L133). Win/lose: "lost" when hull 0 by lock >4 in one tick window.

## Per-file table (bytes, lines)

number	path	bytes	lines
1	game/tests/audit_photo_integrity_tests.gd	4359	65
2	game/tests/audit_photo_ui_tests.gd	1887	35
3	game/tests/authored_plant_scenarios.gd	4655	49
4	game/tests/beam_emission_tests.gd	2550	41
5	game/tests/blackwater_courier_tests.gd	7006	85
6	game/tests/blackwater_delivery_runtime_ui_tests.gd	10653	107
7	game/tests/blackwater_delivery_tests.gd	17411	184
8	game/tests/blackwater_delivery_ui_tests.gd	12360	121
9	game/tests/blackwater_scenarios.gd	7478	73
10	game/tests/blackwater_tests.gd	299	9
11	game/tests/blackwater_ui_scenarios.gd	2661	32
12	game/tests/blackwater_ui_tests.gd	673	14
13	game/tests/briefing_scroll_fitting_ui_tests.gd	7558	101
14	game/tests/cadence_correlator_tests.gd	5741	73
15	game/tests/campaign_capture_progress_tests.gd	2471	35
16	game/tests/campaign_consequence_tests.gd	3832	41
17	game/tests/campaign_endings_tests.gd	5283	68
18	game/tests/campaign_equipment_save_tests.gd	2710	35
19	game/tests/campaign_instruments_tests.gd	7815	92
20	game/tests/campaign_instruments_ui_tests.gd	8257	97
21	game/tests/campaign_main_dispatch_tests.gd	3396	44
22	game/tests/campaign_photo_rows_tests.gd	8363	115
23	game/tests/campaign_scenarios.gd	2538	44
24	game/tests/campaign_ui_scenarios.gd	1987	34
25	game/tests/capture_acoustic.gd	2917	48
26	game/tests/capture_acoustic_context.gd	2126	31
27	game/tests/capture_audio.gd	974	18
28	game/tests/capture_audio_loops.gd	990	19
29	game/tests/capture_blackwater.gd	3208	56
30	game/tests/capture_blackwater_motion.gd	4347	73
31	game/tests/capture_campaign.gd	1304	23
32	game/tests/capture_density.gd	2732	38
33	game/tests/capture_density_interaction.gd	2654	36
34	game/tests/capture_feedback_tests.gd	1441	23
35	game/tests/capture_finale.gd	1164	17
36	game/tests/capture_foundry.gd	1219	16
37	game/tests/capture_observed_contact_lock.gd	1108	16
38	game/tests/capture_photo.gd	2303	56
39	game/tests/capture_return.gd	699	11
40	game/tests/capture_siren_roles.gd	1417	22
41	game/tests/capture_touch.gd	924	16
42	game/tests/capture_touch_movie.gd	1817	31
43	game/tests/challenges_journey_tests.gd	1680	28
44	game/tests/challenges_tests.gd	7048	112
45	game/tests/challenges_ui_tests.gd	9686	139
46	game/tests/cold_review_archive_tests.gd	5848	83
47	game/tests/cold_review_ui_tests.gd	10588	122
48	game/tests/concealed_fixture.gd	1104	15
49	game/tests/concealed_harbour_journey_tests.gd	6418	96
50	game/tests/concealed_harbour_tests.gd	15144	170
51	game/tests/concealed_harbour_ui_tests.gd	10313	137
52	game/tests/confluence_command_plan.gd	5820	95
53	game/tests/confluence_completion_tests.gd	663	10
54	game/tests/confluence_operation_tests.gd	5921	71
55	game/tests/confluence_parallel_tests.gd	848	13
56	game/tests/confluence_presentation_tests.gd	4514	53
57	game/tests/confluence_resolution_ui_tests.gd	3976	51
58	game/tests/contact_reports_tests.gd	8007	93
59	game/tests/contact_reports_ui_tests.gd	2593	39
60	game/tests/core_scenarios.gd	3763	44
61	game/tests/craft_upgrade_sim_tests.gd	3381	41
62	game/tests/craft_upgrades_tests.gd	2580	31
63	game/tests/current_chart_seam_tests.gd	2668	35
64	game/tests/current_motion_tests.gd	5113	63
65	game/tests/current_propulsion_tests.gd	947	18
66	game/tests/decoy_aim_ui_tests.gd	4310	52
67	game/tests/decoy_deployment_tests.gd	2354	28
68	game/tests/density_main.gd	1066	22
69	game/tests/density_menu_scenarios.gd	3797	57
70	game/tests/density_scenarios.gd	6699	79
71	game/tests/density_scroll_scenarios.gd	7064	102
72	game/tests/depth_policy_journeys.gd	4145	58
73	game/tests/depth_policy_ui_tests.gd	6630	108
74	game/tests/depth_repair_scenarios.gd	7760	103
75	game/tests/depth_sonar_scenarios.gd	11552	122
76	game/tests/depth_sonar_tests.gd	300	9
77	game/tests/depth_sonar_ui_tests.gd	4799	67
78	game/tests/divergence_save_tests.gd	2780	33
79	game/tests/divergence_tests.gd	3098	36
80	game/tests/drone_drive_tests.gd	5379	58
81	game/tests/drone_drive_ui_tests.gd	5920	76
82	game/tests/drone_operations_tests.gd	7352	82
83	game/tests/drone_operations_ui_tests.gd	3486	36
84	game/tests/early_reward_tests.gd	2625	41
85	game/tests/early_reward_ui_tests.gd	4121	49
86	game/tests/earned_course_continuity_tests.gd	9911	99
87	game/tests/earned_equipment_tests.gd	2444	29
88	game/tests/expanded_region_journeys.gd	1648	28
89	game/tests/expanded_region_tests.gd	3201	41
90	game/tests/expedition_instruments_ui_tests.gd	10401	120
91	game/tests/expedition_menu_tests.gd	3021	40
92	game/tests/extraction_survival_tests.gd	4225	52
93	game/tests/field_sampler_tests.gd	1730	22
94	game/tests/finale_command_plan.gd	2654	53
95	game/tests/finale_scenarios.gd	3874	42
96	game/tests/finale_ui_scenarios.gd	1386	20
97	game/tests/first_siren_cue_ui_tests.gd	5902	75
98	game/tests/fit_label_main.gd	315	6
99	game/tests/fit_label_scenarios.gd	4029	50
100	game/tests/fix2_camera_ui_tests.gd	3763	60
101	game/tests/fix2_feedback_ui_tests.gd	2122	27
102	game/tests/fix2_frontend_ui_tests.gd	2434	39
103	game/tests/fix2_menu_ui_tests.gd	1986	32
104	game/tests/fix2_optional_recovery_tests.gd	1510	16
105	game/tests/fix2_photo_routing_tests.gd	2262	40
106	game/tests/fix2_save_tests.gd	2728	43
107	game/tests/fix2_save_ui_tests.gd	1882	32
108	game/tests/fix2_state_tests.gd	2107	35
109	game/tests/fix2_study_ui_tests.gd	1679	24
110	game/tests/fixtures/blackwater_first_extract.gd	18264	711
111	game/tests/fixtures/split_channel_legacy.gd	561	11
112	game/tests/foundry_command_plan.gd	2710	47
113	game/tests/foundry_departure_tests.gd	5117	56
114	game/tests/foundry_scenarios.gd	2665	29
115	game/tests/frontend_scenarios.gd	6196	79
116	game/tests/frontend_stub_host.gd	813	19
117	game/tests/glass_network_tests.gd	3481	48
118	game/tests/glass_reach_journeys.gd	7454	87
119	game/tests/glass_reach_tests.gd	1441	23
120	game/tests/glass_reach_ui_tests.gd	6206	70
121	game/tests/glass_research_tests.gd	2925	33
122	game/tests/glass_work_tests.gd	6583	86
123	game/tests/grade_on_secure_tests.gd	1346	27
124	game/tests/independent_capture_tests.gd	4281	69
125	game/tests/independent_capture_ui_tests.gd	2895	48
126	game/tests/industrial_jobs_tests.gd	9713	117
127	game/tests/industrial_threats_tests.gd	5893	71
128	game/tests/interface_scenarios.gd	991	11
129	game/tests/iron_choir_journeys.gd	12738	147
130	game/tests/iron_choir_tests.gd	1670	26
131	game/tests/iron_choir_ui_tests.gd	5770	57
132	game/tests/iron_research_tests.gd	3439	39
133	game/tests/knockdown_scenarios.gd	11637	128
134	game/tests/knockdown_ui_scenarios.gd	5400	61
135	game/tests/known_water_observation_tests.gd	1469	30
136	game/tests/listening_well_command_plan.gd	1624	34
137	game/tests/loadout_frames_tests.gd	13952	160
138	game/tests/loadout_ui_tests.gd	5720	75
139	game/tests/lock_warning_scenarios.gd	1199	23
140	game/tests/lock_warning_ui_tests.gd	2164	33
141	game/tests/metrics_transport_tests.gd	4286	58
142	game/tests/module_inventory_main_tests.gd	5619	56
143	game/tests/module_recovery_runtime_ui_tests.gd	5548	67
144	game/tests/module_recovery_tests.gd	15567	132
145	game/tests/module_recovery_ui_tests.gd	10584	119
146	game/tests/nav_clearance_measure.gd	1196	22
147	game/tests/nav_clearance_probe.gd	2034	41
148	game/tests/nav_clearance_tests.gd	1937	30
149	game/tests/nav_clearance_ui_tests.gd	3378	51
150	game/tests/nav_following_probe.gd	2056	32
151	game/tests/navigation_departure_tests.gd	6540	83
152	game/tests/observed_contact_scenarios.gd	3425	37
153	game/tests/observed_contact_ui_scenarios.gd	3149	36
154	game/tests/onboarding_tests.gd	8393	123
155	game/tests/onward_mission_tests.gd	1382	25
156	game/tests/opening_depth_journeys.gd	9897	128
157	game/tests/opening_depth_policy_ui_tests.gd	8339	126
158	game/tests/opening_depth_scenarios.gd	10691	134
