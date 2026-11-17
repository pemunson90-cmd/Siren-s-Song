# Cold review 6: merged findings of three blind critics

Status: COMPLETE (2026-11-12, Phase 1). Coverage is partial; see "Coverage" before relying on a ranking.

Three fresh critics played the game at base `cabd5bd5` through the critic kit (`scripts/critic/`), by touch, from screenshots only. None had source, documents, a watch list or an earlier audit. Evidence level for everything below: critic play on a desktop GPU window at the phone's pixel sizes. Nothing here is a phone observation, and sound was not captured. Journals, reports and 400 or so screenshots are outside the repository at `%USERPROFILE%\.cache\sirens-song-toolchain\artifacts\critic6-fable-20261111` (`audit/<session>/`, `evidence/<session>/`); screenshot numbers below refer to those folders.

| Critic | View | Assignment | Reached |
| --- | --- | --- | --- |
| A, `critic-a-opening` | cover 2520x1080 | New player, fresh campaign | Front end and dock; operation 1 (Shelf Signal) recovered with Quietus only; operation 2 (Split Channel) twice with drones, not finished. About 89 commands in two sessions. |
| B, `critic-b-modes` | inner 2184x1968 | Side modes on the near-square screen | Title, profiles (export and import), every settings section, credits, mode list; one seeded Expedition dive, lost to life support near extraction. About 87 commands. The session was cut off by the usage limit; its findings come from its journal. |
| C, `critic-c-glass` | cover | Returning player, earned mid-campaign profile | Import, dock, route map, fittings, supplies, dossier, archive; Glass Fence (recovered); Needle Strait with full kit (destroyed); optional Shelf Thread with a bare fleet (record secured, grade A). About 110 commands in two sessions. |

## Coverage

Not reached by any critic: END OF LINE and every ending family, Glass Reach beyond its second operation, Iron Choir, Calder Trench, a full Expedition (more than one dive), Naval Career beyond the mode list, Challenges, Ironman play, the Disrupt, Torpedo and Survey tools in the late game, audio, and anything on a phone. The coverage contract in `docs/state/STATE.md` on `codex/handoffs` (1 Nov) is therefore not met. The earlier Critic 6 attempt on this base (5 to 8 Nov, another agent) also reached only the first two operations in fresh play. Screenshot-driven play costs about one command per meaningful action, so a whole-campaign blind pass needs either many sessions or an earned late-game profile per region. This is carried into the plan as a backlog item, not repeated in this run.

One kit limit matters for the findings: Godot scrolls a list by finger drag only when the platform reports a touchscreen. The kit's desktop window does not, so "dragging the content does not scroll" (seen by all three critics) is expected on the kit and is not evidence about the phone. Dragging the scrollbar worked. The game's own suites (`menu_scroll_keys_tests`, item 137) cover menu scrolling.

## Findings, ranked

Ranked by Pat's priorities (gameplay, graphics, interface, bugs, missing features), then by how many critics saw it and how much it cost them. "Rule" marks findings that touch a protected rule or a Pat ruling, where the remedy is limited to presentation.

### Gameplay

| Rank | Finding | Seen by (screens) | Consequence | Remedy that stays inside the rules |
| --- | --- | --- | --- | --- |
| G1 | **Being caught is not readable on the chart.** C was destroyed by a Siren (S7) that never appeared on the chart; the only cue for the 8 second exposure was a side-panel line "SHUTTER heard to 520m, nearest Siren ~4s". A lost a drone about 25 s after sending it, with only "Drone lost"; no pause, no cause, no bearing. B lost a drone 2.9 s after a Siren report while the Hunt box said DORMANT. A had a Sweeper appear beside Quietus right after "no known Siren in range". The death screen then explains the cause precisely, which critics praised. | C 171 to 172; A 135, 109, 034; B 071 | Loss reads as unfair; drones feel disposable. Reference: Mark of the Ninja. | Rule: senses, lock and beam are protected. Presentation only: draw the shutter-noise radius on the chart while the camera panel is open, show the lock countdown beside the craft, name cause and bearing when a drone is lost, and offer "pause when a craft is lost" beside the existing pause aids. |
| G2 | **Drone play is mostly waiting, and a new player's drones can do nothing but move and photograph.** A measured about 50 m of drone travel in 30 s against legs of 900 to 1800 m. On a fresh campaign every drone tool is at 0, every mount is empty, and the only purchase (a hull) costs 4 alloy with 0 owned, so scrap and cells earned in operation 1 have no outlet. | A 131, 112, 139, 141 | Three-craft command, the game's premise, is not felt in the opening. Reference: Duskers. | Check the speed observation in code first (the drone may have been in SILENT). A player-controlled time step while no Siren is aware, and an early affordable purchase, are design changes: decision for Pat. |
| G3 | **Photo payoff is not shown.** Critics saw a grade letter and never saw what it paid or unlocked. A's operation 1 photo graded C with no visible consequence; C's bare grade A on an empty optional operation cost nothing. The research list read "NOT RECOVERED" throughout and the archive said "Artifacts recovered: not recorded (of 8)" after a recovery. | A 045, 146; C 147 to 149, 191 | The core pillar has a risk dial (praised) and no visible reward. Matches the 1 Nov plan item "photo payoff". Reference: Iron Lung, Highfleet. | Show on the debrief and in the archive what each photograph paid and what a better grade would have paid. Changing the pay table so quality outweighs distance is a rule-adjacent tuning question: decision for Pat. |
| G4 | **Film and time are spent on frames that cannot succeed.** "UNUSABLE FRAME: use a TIGHT frame" appeared only after a 4 s exposure, and the panel had offered only WIDE for that subject. A was refused at 215 m with "camera reaches 240 m" after the menu said 304 m. | C 159 to 162; A 026 to 027 | Film 8 to 6 with nothing gained; exposure near Sirens for nothing. | Say before the exposure that the frame cannot be used, and why. Make the two range figures agree. |
| G5 | **Difficulty cliff between optional and core operations.** Bare Shelf Thread: no Siren in range, grade A in eight commands, 75 percent watching. Needle Strait with a full kit: three or more listening Sirens at the first photograph. No tool or fitting was decisive in either. | C 155, 191 | Preparation does not feel like it matters. Matches the 28 Oct fleet diagnostic and the 1 Nov plan item "late-operation variety". Reference: FTL. | Encounter content and tuning. Backlog, with a structural proposal for Pat. |
| G6 | **The oxygen limit is never explained and not always on screen.** A saw life support go 120 to 48 before noticing; the briefing does not mention it. B's Expedition was lost when life support ran out about 50 m from extraction. | A 012, 028; B 083 to 087 | A loss the player did not know was coming. Reference: Cold Waters. | Keep the life-support reading on screen during a dive and name the limit in the briefing line (factual, not narrative). |
| G7 | **A leg across charted rock is accepted with a red label, then the craft holds with "Rock ahead blocks this leg".** | A 119, 122, 124; B 056 | Critics read it as broken routing. | Rule: this is Pat's 30 Oct ruling (straight legs, crashing possible, light edge assist). No change to movement. The planner should show the same rock warning the chart shows (B saw none in the planner). |

### Interface

| Rank | Finding | Seen by (screens) | Consequence | Remedy |
| --- | --- | --- | --- | --- |
| I1 | **The camera recentres on the selected craft after a tap or unpause**, so a tap planned on one frame lands on something else on the next. A's tap meant for water selected drone B. | A 121, 125, 127 | Multi-craft routing is unreliable. Reference: Door Kickers. | While paused, selecting a craft does not move the camera; FOCUS stays the explicit way to recentre. The specification already says camera intent is preserved through pause. |
| I2 | **HUD chips move and clip.** The HUNT chip was seen top right, top centre, top left and bottom right; the drone B chip floats; NOTICE and NEW SIREN TYPE chips are cut off at the right edge; the HUNT box overlaps the Expedition banner; the EXTRACTION label is thrown to the top of the chart; radial centre text is clipped ("UNKNOWN SIGNAL SO...", "UNKNOWN SEABED RET"); object-menu text overflows its ring. | A 015, 018, 025, 034 to 038, 102; B 037, 056, 063, 075 to 078 | Misreads at the moment of threat. Reference: Cold Waters. | Fixed anchors per chip, clamp to the safe area, ellipsis or wrap for ring text. |
| I3 | **The dive keeps running while a dialog or ring is open.** A lost 15 s with a ring open; B's second water tap raised a confirm dialog while the clock ran, shortly before life support ran out. | A 021, 133; B 085 | Time and oxygen lost to the interface. Reference: Into the Breach. | Hold the simulation while a confirm dialog is open. |
| I4 | **Order flow says things that are not true.** The status line says "GO replaces orders" and no GO button exists; after UNDO the dialog still says "already has orders (1 stop)"; a first ADD tap did nothing while a tip was up; the REPLACE wedge is a mode toggle that looks like an action; RESUME and DONE taps in the route planner were ignored three times; with a ring open the first RESUME tap only closes the ring. | A 021 to 022, 121, 138, 143; B 046 to 047, 057, 068, 073; C 171 | Accidental real time near Sirens; confusion about what was ordered. | Fix each: name the real control, refresh the dialog state, let RESUME always resume. |
| I5 | **The photograph has no obvious trigger.** A photo starts only through tap craft, ring, PHOTO; tapping the viewfinder does nothing; the camera panel opens by itself without a hint. | C 157, 158, 163 | The core verb is hard to find. Reference: Iron Lung. | A shutter control in the camera panel. |
| I6 | **Important buttons sit below the fold.** On the destroyed screen OPERATIONS ARCHIVE is below the panel edge. The Expedition pre-dive page is about four screens tall with BEGIN at the bottom, and every LOAD button is disabled with no reason. The campaign Operations panel on the inner view has no BACK, and Android back from it offers to exit. | C 173 to 175; B 023 to 024, 033 to 036 | The player may think only Retry exists; a stray second back press quits. | Pin primary buttons; give disabled buttons their reason; add BACK. |
| I7 | **Buying and fitting hide what the player needs.** No stats before buying, no confirmation, the balance is not near the buttons; the Low Noise Hull then refused to fit with baffles for a mount it lacks, which was not disclosed. Fittings is a long text list; bars at 100 percent are drawn at two thirds and one half with no scale. | C 016 to 042 | Wasted scrap; unclear upgrades. Reference: FTL. | Show the stat change and conflicts before purchase, confirm, show the balance. |
| I8 | **Small text defects.** Missing spaces ("by45%", "at112m/s instead of78m/s", "remains42m/s"); a garbled sentence ("Port Ardent watch log the shelf for Brannock."); "RETRY" shown before the first attempt; "Eight minutes of margin left" beside life support at 23 percent; "EMIT 0.4 RESERVE" unexplained; Naval Career has no description; "Course so far: STANDING DOWN (provisional)" unexplained; route-map header clipped to one and a half lines; profile slots show no progress summary; export and import show a raw file path. | A 004, 012, 016, 045; B 022; C 004, 011 to 015, 016 to 036 | Reads as unfinished. | Fix spacing and clipping. Lines that are story text stay for Pat. |
| I9 | **First view of a dive is nearly black with a small lit patch; nothing says pinch works.** The readable full chart appears only after pinch-out. | C 152, 182, 185 | Hard to plan; good art is hidden. | Decision for the plan: an opening fit that shows the route to the first objective, or a one-line hint. |
| I10 | A LOW EFFECTS notice appears mid-dive over the map. | B 062; C 187 | Covers the chart at a bad time. | Move it out of the dive or make it a small non-blocking line. |

### Bugs

| Rank | Finding | Seen by (screens) |
| --- | --- | --- |
| B1 | Hull 60 to 47 at 00:02 of Needle Strait: "COLLISION against DRONE A at 42m/s". A drone launches overlapping Quietus (seen with the Low Noise Hull fitted). | C 156, 172 |
| B2 | Operation 1 result lists both drones "OUTSIDE RECOVERY" although they never left the start. | A 045 |
| B3 | The bearing readout (338, 335, 325, 300, 293) did not match the chart direction to the target, which lay north-east. | A 016 to 020 |
| B4 | Route map: node 13 box has an offset fill; "-" does nothing at minimum zoom; optional nodes 40 and 41 are off screen below. | C 011 to 015 |
| B5 | Selecting a deep Quietus hides middle-layer rock, the drone and the Siren. | B 079 |
| B6 | The archive shows "Sorley's boy was not brought home" on a brand-new campaign, before the player can know who that is. | A 008 |

B5 and B6 may be intended (depth-band display; the hidden rescue). They are listed because a blind player read them as defects.

### What critics praised

The photo viewfinder and its risk dial (sharpness, light, exposure time against shutter noise); DISRUPT (instant, clear, 12 s); the SILENT against cruise trade with the visible noise ring; the LOCK card with auto-pause and usable advice; the death screen's cause line ("drawn by the CAMERA shutter 5 s before the lock"); the Siren dossier (role, tell, counterplay); mission restore ("paused for review"); the abandon-dive dialog; the honest decoy refusal with no charge spent; profile export and import with a 30 s undo; the briefing's GOAL and DANGER lines.

## Decided versus watched

| Operation | Critic | Deciding | Watching |
| --- | --- | --- | --- |
| Shelf Signal, Quietus only | A | 45% | 55% |
| Split Channel, drones | A | 50% (much of it fighting controls) | drone legs about 80% watching |
| Needle Strait, full kit | C | 70% (reacting to danger it could not read) | 30% |
| Shelf Thread, bare | C | 25% | 75% |

## The five changes the critics ranked highest, merged

1. Make detection and loss readable on the chart: shutter-noise radius, lock countdown by the craft, cause and bearing on a lost drone (G1).
2. A stable planning camera and an honest order flow (I1, I3, I4).
3. Make preparation and photographs pay visibly: show what a photo paid, show stats before a purchase, give drones something to do early (G2, G3, I7).
4. A shutter control, and no film spent on a frame that cannot succeed (G4, I5).
5. Stable HUD chips, no clipped text, primary buttons never below the fold (I2, I6, I8).

## Compared with the 1 November plan

The plan recorded on `codex/handoffs` expected, after Critic 6: photo payoff, late-operation variety and the branching route graph, fitting allocation, a look-and-sound comparison. This review confirms photo payoff (G3) and the variety problem (G5), adds readable detection (G1) and the planning camera (I1) above them for a new player, and says nothing about the route graph, endings, look or sound because no critic got there.
