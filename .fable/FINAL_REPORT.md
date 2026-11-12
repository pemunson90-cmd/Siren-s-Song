# Final report: overhaul run `overhaul-20261111`

Status: FINAL (2026-11-12)

Branch `fable/overhaul-20261111`, final game code at `955ac8a1` (later commits on the branch change only documents). The first closeout was at `247e0582`; Pat then approved repairs (section 12), which are included, base `claude/integration` at `cabd5bd5` (tag `fable/pre-overhaul-20261111`). Pull request: https://github.com/pemunson90-cmd/Siren-s-Song/pull/262 (ready for review, unmerged; Pat merges).

## In plain English (for Pat)

**What you will notice when you play**

- *Drones launch from the submarine.* Every dive starts with both drones aboard Quietus, off the map, where nothing can see or hit them. Open FLEET, choose a drone and tap the water: it launches beside the submarine and swims there. A drone you never launch comes home with you. This restores how the prototype worked; the rebuild had dropped it.
- *Recon is discovery again.* After the first three tutorial operations the map starts almost blank: you see a small patch of water around your launch point and your craft's sensors fill in the rest as you explore. A survey sweep shows water and objectives for 30 seconds; they fade unless one of your craft goes and maps them. Each objective is a search area until a craft senses it or a sonar pulse reaches it.
- *The EMP* (it used to be labelled DISRUPT) no longer wastes a charge when no Siren is in range. It is an area pulse: no target needed.
- *Drones are scouts again.* A Siren that is calm ignores a drone even in plain sight. Once that Siren is alerted (it heard something, it is locking the submarine, or Hunt has reached SEARCHING), drones are targets and die to the beam as before. Drones are also about 40 percent quieter.
- *You can see how far a Siren sees,* as a faint ring, once you have photographed that Siren type's sensor array. Until then, no ring.
- *Sonar is free for the submarine.* A pulse no longer costs oxygen; the risk is being heard. Drones still pay battery.
- *The factory senses you.* In the two operations with a factory (3, Cold Foundry, and 11, Confluence), staying within 340 m of it raises Hunt, and the Hunt meter says why.
- *Getting caught makes sense.* When you line up a photograph, the map draws a ring showing how far the shutter noise carries. When a Siren locks onto a craft, a countdown appears next to that craft. When you lose a drone, the message says what destroyed it and from which direction, or "UNSEEN SIREN" if you never saw it. A new optional setting (off by default) pauses the dive when a craft is lost.
- *Planning while paused works.* Tapping a craft while paused no longer swings the camera away. RESUME always resumes in one press, and the button is large enough that taps are not missed. The "replace this route?" box names its real buttons, shows what the craft is doing now, and the clock stops while it is open.
- *Photographs explain themselves.* There is a SHUTTER button in the camera panel. If you are zoomed wide on something that needs a close-up, you get a warning before film is spent; press again to shoot anyway. After a dive, and in the archive, each photograph shows what it earned.
- *Oxygen is always visible.* While the dive is running the pause button shows oxygen and roughly how long is left, and turns amber at 25 percent. From the second operation on, the briefing says how long the oxygen lasts.
- *Buttons and labels stay put.* Warning labels no longer jump or run off the screen. After a lost dive, RETRY is at the top. The Expedition start screen keeps BEGIN at the bottom of the screen. A greyed-out LOAD button says why. The Operations screen has a TITLE button at the top. Typos such as "by45%" are fixed.

**Not changed:** no number, Siren behavior, story text or price. The one rule change is the drone launch above, on your ruling. The developer travel shortcuts still work in your test build; they are blocked only in a release build, as you ruled on 30 October.

**Behind the scenes:** one rulebook for agents, one status page and one list of your rulings (your words copied exactly). Ten outdated notes moved to a scrap folder; nothing was deleted. Safety tests lock in your protected numbers and the rule that no tool permanently disables a Siren. Adding an operation, region, Siren type or fitting is simpler and has a short how-to. A plan to tidy 326 old branches is written and waits for your yes.

**What I could not check:** nothing was seen on a real phone. Everything was checked by automated tests and by three AI play-testers, who covered the opening and middle of the campaign only. After the drone launch change I ran only the checks that test it directly (your minimum-testing rule): its own suite, the core rules suite, the three rule canaries and the hand-piloted journeys, all passing. Seventy-two other test files that drive the whole game and touch drones were not rerun; some may need their setup updated the next time the full check runs for a release build.

**Not yet seen by anyone:** operations 3 to 41 have never been played or tested end to end on a discovered map. Each was authored with a full chart, so some may now be harder or awkward. That is the first thing your playtest will show.

**Still open from the prototype audit** (your call, nothing changed): what Sirens should notice when the survey plane sweeps (today it is a loud signal they investigate); which other Siren works besides the two factories should sense craft. Items you chose to try as they are: the 4-second lock and beam, terrain damage, moving silent running, the eight Siren types, sonar echoes, drone batteries, tool numbers, sensing ranges, extraction distance and speed.

## 1. Outcome

The repository now has one governing file, one status file, one rulings file, a changelog, a tested harness around Pat's protected rules, and CI that also runs the tool tests nothing ran before. On top of that base the run landed six player-facing packages that answer the blind critics' top findings: readable detection and drone loss, a planning camera that stays put, truthful order dialogs, a clearer photograph flow, always-visible life support and reachable primary buttons. No game rule, number, story text or saved field changed, with one exception listed in section 4 (a drone-loss event carries one extra key that is not saved).

## 2. For the player

- **You can see why you were caught.** While framing a photograph the chart draws how far the shutter is heard. Every craft under a Siren lock shows a countdown beside it. A lost drone says what destroyed it and from which bearing, or "UNSEEN SIREN" when you held no contact. A new setting (off by default) pauses the dive when a craft is lost.
- **Planning while paused works.** Selecting a craft while paused no longer moves the view. RESUME closes an open ring or pending marker and resumes in one press, and its button now fits its label (taps on it were being missed). The route confirm dialog names its real buttons, shows the craft's live orders and holds dive time while open.
- **Photographs explain themselves.** The camera panel has a SHUTTER control. A WIDE frame of a subject that needs fine detail warns before film is spent; a second press within four seconds exposes anyway. The ring shows one reach figure. The debrief and the archive show what each photograph added.
- **Life support is on screen whenever the dive is running** (oxygen and an estimated time left, on the pause control), and from operation 1 on the briefing states the operation's life-support time.
- **Chips and buttons stay where you can use them.** Threat and notice chips stay inside the screen; the Hunt chip stops jumping; loss debriefs put RETRY and OPERATIONS ARCHIVE under the heading; the Expedition pre-dive page pins BEGIN and RETURN; a grey LOAD button says why.
- **Release builds** refuse the developer travel shortcuts on every profile (Pat, 30 October: "they will absolutely have to be stripped for release play"). The debug package Pat tests is unchanged in this respect.

## 3. For the engineering

- **Governance:** `AGENTS.md` is the single governing file (feature-continuity directive carried verbatim); `CLAUDE.md` imports it; `docs/STATUS.md` is the one status file; `docs/WORKFLOW.md` holds the branch model, commit format, review and merge rules and CI gating; `docs/GOVERNANCE_MIGRATION.md` accounts for every rule of the old governing files. Pat's rulings from `codex/handoffs` and from this run are appended verbatim to `docs/USER_DIRECTIVES.md`.
- **Documents:** every documentation file is classified in `.fable/DOC_INVENTORY.md`. Ten pointer and handoff documents moved to `_scrap-20261111/` with a manifest. Stale banners and superseded instructions were corrected in place.
- **Hygiene:** `.gitattributes` (LF text, byte-exact provenance and fixtures), tracked Godot `.uid` files so an import leaves a clean tree, a PR template, `CHANGELOG.md`, a documentation link checker.
- **CI:** the fast `guidance` job also checks documentation links and runs eleven tool self-tests that no workflow ran; `game-core` runs two helper tests that need Godot. The matrix is unchanged and nothing redundant was added.
- **Harness:** the protected-rules golden pins 23 more of Pat's numbers; a new suite states that no player tool permanently disables a Siren, for all eight roles; a release build gate suite; an operation metadata parity suite. Fourteen suites were added in total (ranks 1404 to 1418).
- **Expansion seams:** per-operation metadata lives in one table (`game/src/campaign/operation_meta.gd`) with a parity suite; `docs/guides/` explains how to add an operation, a region, a Siren role and a fitting. Each new player-facing module sits behind one switch and is listed in `docs/MODULES.md`.
- **Tools:** `scripts/critic/` (the blind critic kit, versioned and reviewed) and `scripts/repo/` (branch ledger, archive planner, link check, capabilities ledger check and status, run-state helpers).
- **Critic 6:** three blind critics played the opening campaign, the side modes and the mid campaign; findings are ranked in `.fable/COLD_REVIEW_6.md`. Coverage is partial: no critic reached the endings, Iron Choir, Career, Challenges or Ironman. That is the first item of the P2 backlog.

## 4. Behavior changes

Complete table, built from `git diff fable/pre-overhaul-20261111..fable/overhaul-20261111` file by file and checked against the work-package reports. "Switch" names the constant that restores the old behavior where one exists.

| # | Change | Where | Package | Switch |
| --- | --- | --- | --- | --- |
| 1 | Release builds refuse the six developer-only travel shortcuts on every profile, including an imported developer-marked profile. Debug builds unchanged. | `presentation/release_controls.gd` | WP-06 | none (ruling of 30 October) |
| 2 | Exported packages no longer contain test scripts. | `game/export_presets.cfg` | WP-06 | the `exclude_filter` line |
| 3 | The `SS_` diagnostic lines and the Android UI metric records print only in debug builds. | `main.gd`, `flow/campaign_flow.gd`, `flow/ui_metrics.gd` | WP-06 | see D-13 |
| 4 | Drone beam-loss event carries an extra key `siren` (the Siren's index). Not saved, not read by the simulation. | `simulation/simulation.gd` | WP-08 | none |
| 5 | While a photograph is framed the chart draws a ring "SHUTTER HEARD <n>m" using the camera panel's own figure; fresh contacts inside it are marked "IN SHUTTER REACH". The existing OWN SHUTTER ring is still drawn at the same radius. | `presentation/threat_read/` | WP-08 | `threat_read_table.gd: enabled` |
| 6 | Every craft under a Siren lock shows a chip "S<n> LOCK · <t>s" beside it. | same | WP-08 | same |
| 7 | A lost drone leaves a wreck mark and bearing ray for 10 seconds, and the loss message begins with cause and bearing ("DRONE A LOST · SIREN BEAM FROM 090° · S1 GUARD", "· UNSEEN SIREN", "· BATTERY EXHAUSTED"). A Siren the player never detected in this dive is not named. | same | WP-08 | same |
| 8 | New setting "TACTICAL AID: PAUSE ON CRAFT LOSS" (`auto_pause_loss`), off by default, saved with the other settings. | `persistence/settings_store.gd`, `frontend/frontend.gd`, `accessibility/tactical_aids.gd` | WP-08 | same |
| 9 | Selecting a craft while paused does not move the view; on resume the view follows the selected craft again unless the player panned, zoomed or used FIT. Selecting while running is unchanged. | `main.gd` | WP-09 | none |
| 10 | RESUME (button or SPACE) closes an open command ring or cancels a pending route marker and resumes in one press. | `main.gd` | WP-09 | none |
| 11 | The pause control grows to fit its wrapped label. | `presentation/mission_hud.gd` | WP-09 | none |
| 12 | Route confirm dialog: text built from the craft's live orders and its real button names; dive time is held while it is open; ADD TO ROUTE is hidden (was shown disabled) when the craft has no route; the UNDO chip says what it restores. | `presentation/order_guard.gd`, `main.gd` | WP-09 | none |
| 13 | The route wedge reads "TAPS: QUEUE" or "TAPS: REPLACE"; the field manual and briefing text name it the same way (instruction text, not story). | `main.gd`, `campaign/onboarding_text.gd`, `flow/campaign_flow.gd` | WP-09 | none |
| 14 | SHUTTER control in the camera panel header (same action as the ring's PHOTO). | `presentation/photo_shutter/`, `camera_feed.gd` | WP-10 | `shutter_table.gd: enabled` |
| 15 | A WIDE frame of a still subject that needs fine detail gives a warning before any film is spent, on both SHUTTER and ring PHOTO; pressing again within four seconds exposes anyway (the old WIDE-then-TIGHT path still works). | same | WP-10 | same |
| 16 | The ring caption shows one camera reach figure ("READY · 60m · REACH 240m") and no distance to an unresolved lead's hidden position ("SEARCH AREA"). | `photo_shutter/range_caption.gd`, `mission_hud.gd` | WP-10 | same |
| 17 | Debriefs show a PHOTO PAY block and the archive a "PAID ·" line per photograph (stored intel, camera research, later chart marks). No pay rule or number changed. | `presentation/photo_pay/`, `flow/campaign_flow.gd`, `expedition_operations.gd`, `archive/archive_view.gd` | WP-10 | `pay_table.gd: enabled` |
| 18 | While a dive runs, the pause control reads "Ⅱ PAUSE" over "O₂ 87% ~3:10" (was "Ⅱ" over "PAUSE"), amber at 25 percent or below; the time is oxygen divided by the base drain rate. The control keeps its size. On a narrow control the line shortens to the time or the percentage. The paused control is unchanged. | `presentation/life_support_chip.gd`, `mission_hud.gd` | WP-11 | `life_support_chip.gd: ENABLED` |
| 19 | From operation 1 on (operation 0 keeps its short opening briefing), the briefing stock line gains "LIFE SUPPORT m:ss at the base rate". | `presentation/truthful_commands.gd` | WP-11 | none |
| 20 | The Hunt chip keeps its seat while the layout is unchanged; once moved aside by a lock card or notice it stays there until the layout changes. | `presentation/hunt_meter.gd` | WP-11 | `meter_table.gd: STICKY` |
| 21 | NOTICE and NEW SIREN TYPE chips grow to their text, wrap, stay inside the content edge and move below a lock card; the Expedition banner sits under the header. | `first_siren_cue/first_siren_cue.gd`, `runs/expedition_session.gd` | WP-11 | none |
| 22 | The ring's centre title wraps to two lines, then ends with an ellipsis. | `radial_layout/center_layout.gd` | WP-11 | `center_layout.gd: FIT_TEXT` |
| 23 | Loss and withdrawal debriefs show REVIEW FIELD RECORDS, RETRY and OPERATIONS ARCHIVE under the heading, ahead of the cause and damage lines. | `presentation/debrief_actions.gd` | WP-11 | `debrief_actions.gd: ENABLED` |
| 24 | Expedition pre-dive page: BEGIN OPERATION and RETURN TO MODES are pinned at the bottom of the screen; a refused BEGIN states its reason at the top of the page. | `runs/expedition_session.gd` | WP-11 | none |
| 25 | A grey LOAD button names its reason ("/ NONE ASHORE", "/ CARGO FULL", "/ RACK FULL", "/ SAVE PENDING"), on the Expedition and campaign rack pages. | `presentation/tool_racks_view.gd` | WP-11 | none |
| 26 | Thirteen fitting descriptions gained missing spaces ("by45%" to "by 45%"); one gained a word ("capped22m/s" to "capped at 22m/s"). No number changed. | `equipment/equipment_catalog.gd` | WP-11 | none |
| 27 | Region, route-map position, endurance and opening-arc gating are read from one table. No operation behaves differently (parity suite against values recorded from the base). | `campaign/operation_meta.gd` and five readers | WP-07 | none |
| 28 | Every player dive starts with both drones aboard Quietus (not in the water, carried with it, battery not draining). The first `route` order to a drone launches it beside Quietus in Quietus's depth band; other orders are refused with "DRONE A is aboard Quietus · tap water to launch it"; no launch while Quietus changes depth. A drone never launched is recovered with Quietus and never counted lost. Fleet buttons read ABOARD; the recovery manifest reads "IN · ABOARD". Dives saved earlier keep their drones in the water. | `simulation/drone_bay/drone_bay.gd` and the seams listed in `docs/MODULES.md` | WP-13 | `drone_bay.gd: ENABLED` |
| 29 | The opening message of a dive adds "Drones are aboard: select one and tap water to launch it."; the field manual's ORDERS paragraph gains one sentence saying the same (instruction text). | `simulation/simulation.gd`, `campaign/onboarding_text.gd` | WP-13 | same |
| 30 | A TITLE control is the first row of the Operations panel (same action as the bottom-row TITLE, which stays). | `presentation/ops_home/` | WP-14 | `ops_home_table.gd: TOP_TITLE` |
| 31 | On a player dive after operations 0 to 2 the chart starts as a 480 m window around the launch point and is earned by the craft's sensors (the earned-chart system that five operations already used, now on all of them). Routes are planned on known water only, as on those five. | `simulation/parity_rules/parity_rules.gd`, `simulation/simulation.gd` | WP-16 | `parity_rules.gd: RULES.discovered_charts` |
| 32 | A survey sweep's chart cells and faces lapse 30 s after the sweep last touched them unless a craft's own sensors map them; a saved chart leaves them out. Applies to the five earlier earned-chart operations too. | `simulation/terrain_chart.gd` | WP-16 | same |
| 33 | On a player dive after operations 0 to 2 each plain objective is drawn as a search area (220 m radius, off centre) until a craft's passive sensing with a clear path, or a sonar pulse in its sector, finds it; a survey shows it for 30 s. The camera context says "search the marked area" until then. Developer console command `known` shows charts and objectives from the start. | `simulation/parity_rules/site_search.gd`, `simulation/photo_capture.gd`, `debug/debug_console.gd` | WP-16 | `RULES.site_search` |
| 34 | On a player dive Disrupt is refused with "No Siren within Disrupt range · charge kept" when no Siren is inside its radius. The check uses true Siren positions, as the prototype did, so the refusal also tells the player nothing is that close. | `simulation/orders/weapon_orders.gd` | WP-16 | `RULES.disrupt_needs_target` |
| 35 | In operations 3 and 11 a craft in the water within 340 m of the factory raises Hunt by up to 8 per second (the prototype's suspicion numbers applied to Hunt); the Hunt meter cause reads "factory sensors" and one message announces it. | `simulation/parity_rules/factory_sensors.gd`, `campaign/tutorial_missions.gd`, `campaign/confluence_region.gd`, `simulation/hunt_pressure/hunt_table.gd` | WP-16 | `RULES.factory_sensors` |
| 36 | On a player dive Quietus's sonar pulse costs no life support (was 0.4 or 1.2 oxygen); the EMIT control reads NO COST. A drone's pulse still costs battery. | `simulation/advanced_sonar.gd`, `presentation/mission_hud.gd` | WP-16 | `RULES.free_quietus_sonar` |
| 37 | The tool labelled DISRUPT is labelled EMP in buttons, messages, help, briefings, the field manual, the dossier, the Hunt cause and the challenge rules (28 strings). Internal identifiers are unchanged. The loadout is still named `disruption`. | 20 files under `game/src/` | WP-16 | none |
| 38 | On a player dive a calm Siren (mode not INVESTIGATE, SEARCH or LOCKING, no lock, no target, Hunt stage below SEARCHING) does not acquire a drone by sight. An alerted Siren does, with the usual 4 s lock and beam. Quietus is acquired as before. | `simulation/parity_rules/drone_stealth.gd`, `simulation/simulation.gd` | WP-16 | `RULES.calm_sirens_ignore_drones` |
| 39 | On a player dive a drone's movement noise reaches 0.6 times as far (both acoustic models); its noise footprint on the chart shrinks to match. | same | WP-16 | `RULES.quiet_drones` |
| 40 | The chart draws a ring "S<n> SIGHT ~<m>m" at the last known position of an identified contact whose Siren type has been photographed (campaign photo intel `siren_<type>`, or a usable Siren photograph this dive). Radius: 180 m when the selected craft is silent, 290 m otherwise, times the Hunt stage scale. An estimate; it reads no hidden Siren state. | `simulation/parity_rules/sight_range.gd`, `presentation/threat_read/threat_read.gd` | WP-16 | `RULES.sight_range` |
| 41 | The field manual's ORDERS paragraph gains one sentence on calm and alerted Sirens and drones (instruction text). | `campaign/onboarding_text.gd` | WP-16 | none |
| 42 | The loadout named DISRUPTION is shown as EMP in eight places (loadout cycle button, supply comparison rows, tool racks FILL button, next-dive line, Challenges, Expedition menu, seed entry, run records). The loadout id `disruption` is unchanged in code and saves. | `equipment/field_tools.gd` (`loadout_label`), `campaign/runs/run_records.gd`, `presentation/flow/campaign_flow.gd`, `presentation/frontend/challenges_frontend.gd`, `presentation/runs/expedition_session.gd`, `presentation/runs/seed_entry.gd`, `presentation/tool_racks_view.gd`, `presentation/truthful_commands.gd` | WP-17 (Pat, 2026-11-12) | `LOADOUT_LABELS` in `field_tools.gd` (empty table shows DISRUPTION again) |
| 43 | No change in results; speed only. In operations without depth charts (0, 2, 3, 4, 5) the sensor pulse tests only map cells inside a live craft's reach square (all cells during a legacy survey). The same cells become known in the same order. | `simulation/simulation.gd` (`_observe`), `simulation/world_region.gd` (`reach_squares`, `in_reach`) | WP-19 (audit fix A4) | none |
| 44 | Chart terrain (cell fills, rock faces) is drawn from geometry cached per view and rebuilt when the chart content, style or contrast setting changes. Possible visual differences, unverified without a screen: all rock bodies are drawn before all edge lines (was body then edge per face), batched line calls replace single ones, fill colours pass through 8-bit vertex colour, and in operation 11 fills are drawn for all charted cells, not only those in view. | `presentation/chart_cache/chart_geometry_cache.gd`, `presentation/art/region_renderer.gd`, `presentation/earned_chart_view.gd`, `presentation/confluence_world.gd` | WP-20 (audit fix A3) | `ENABLED` in `chart_geometry_cache.gd` (false draws the old way) |
| 45 | No change in results; speed only. The Siren hearing loop uses each craft's index, fetches the Choir body once, and the Hunt sight floor is computed directly. Save hashes identical on all 42 operations. | `simulation/simulation.gd` (`_heard_arrival`), `simulation/hunt_pressure/hunt_pressure.gd` (`scale`) | WP-19 (audit fix A4) | none |
| 46 | No change in results; speed only. Dive screen functions fetch the objective list, contact list, camera read-out and arrivals once per function instead of several times (each fetch was a full copy). `contact_readout_entries` and `contact_readout_rects` accept an optional list. | `presentation/ocean_view.gd`, `presentation/mission_hud.gd`, `presentation/expedition_view.gd`, `main.gd` (`_refresh`), `audio/soundscape.gd` | WP-21 (audit fix A2, part 1) | none |

Not behavior changes, listed for completeness: 441 `.gd.uid` files and line-ending normalization (whitespace only, `git diff -w` is empty for those files); the AI trace and sweeper patrol files changed in line endings only.

## 5. Protected capabilities

390 rows in `.fable/PROTECTED_CAPABILITIES.md`: 388 PASS, 2 CHANGED, 0 PAT (DEV-009 was answered by D-13 A). 361 rows pass through suites named on the row, all green in full-matrix run 43242777379; the others name their method in the last column.

CHANGED rows:

- **DEV-005** (developer travel shortcuts): kept in debug builds; release builds now refuse them on every profile. Ruling: Pat, 2026-10-30, "they will absolutely have to be stripped for release play" (`docs/USER_DIRECTIVES.md`).

- **MOVE-027** (craft launch with clear starting offsets): on a player dive the drones now start aboard Quietus and launch from it; the offsets remain for a dive started without the launch flag. Ruling: Pat, 2026-11-12, "drones are torpedo launched from the quietus ... they do not start on the map."

Answered: **DEV-009** (UI metric records silent in release builds): Pat, D-13 A, 2026-11-12.

The suite results behind the PASS rows are from run 43242777379, before the drone launch and TITLE changes. Those two changes were checked by their own suites, core and the canaries only.

Rows resolved without a CI suite name the method in the ledger's last column (a CI job, a tool run in this session, direct use during the run, or "unchanged since the base and never automated").

## 6. Evidence

Evidence levels: *implementation* (code read), *scripted verification* (a test suite or tool ran), *automated play* (blind critics driving the real game through the kit), *device observation* (none in this run).

| Gate | Result | Level |
| --- | --- | --- |
| Phase 0 baseline, local | Import OK, core `CHECKS 850 FAILURES 0` on the base | scripted |
| Phase 3 full matrix | Run 43188734403 on `075f627e`: guidance, core, four runtime shards, smoke all green | scripted |
| Phase 4 full matrix | Run 43229665195 on `95cbc1cb`: guidance and core green; seven suites red, all caused by WP-11 (the first life support display took layout space; a briefing line was too long; one typed variable). Fixed in commit `b6a32a16` "fix(hud): show life support on the pause control" | scripted |
| Full matrix on the final code | Run 43242777379 on `247e0582`: guidance, core, four runtime shards and smoke all green | scripted |
| Per package, local | Import, core, the package suites and the three canaries after every merge (figures in `.fable/RUN_LOG.md`) | scripted |
| Reviews | One independent reviewer per package, two for WP-09 (input routing); every finding applied or recorded | implementation |
| Critic 6 | Three blind critics, partial coverage (`.fable/COLD_REVIEW_6.md`) | automated play |
| Debug package (current: every repair and parity restore) | Workflow run 43265277067 on `955ac8a1`: `sirens-song-debug.apk`, 76,864,361 bytes, SHA-256 `ba20421a658225f07ff99dbb1882c17477450647cdd625e2e54f1edfbfd5286f`, versionCode 1, same development key, signature scheme v2 verified by the workflow; built and signed, not launched | scripted (build and signature only); no emulator or phone observation |
| Earlier packages of 2026-11-12 (superseded) | Runs 43257538007 (`615e66b5`, drone launch) and 43263531875 (`8386988a`, parity restores without drone stealth and sight range); run 43262228119 was cancelled | scripted (build only) |
| Debug package (first closeout, superseded) | Workflow run 43251208547 on `247e0582`: `sirens-song-debug.apk`, 76,842,695 bytes, SHA-256 `78a8fa947ccee90714174001cb71ed8972fe6316ba8bc312807fb119eb93bdd3`, versionCode 1, signed with the tracked development key (signer certificate SHA-256 `32bcb228...c7dc3c`, signature schemes v2 and v3 verified by the workflow). The emulator smoke job does not run on a manual dispatch, so the package was built and its signature checked, not launched | scripted (build and signature only); no emulator or phone observation |

Not verified by anyone in this run: how the changes look and feel on Pat's phone, audio, performance on Android hardware, and enjoyment.

## 7. Documentation retired

Ten documents moved to `_scrap-20261111/`; each has a row in [`_scrap-20261111/SCRAP_MANIFEST.md`](../_scrap-20261111/SCRAP_MANIFEST.md). Nothing was deleted. Four documents of uncertain staleness stay in place (D-02).

## 8. Branches

Ledger (`.fable/BRANCH_LEDGER.md`): 374 remote branches on 2026-11-11: 5 SHARED, 19 ACTIVE, 24 UNMERGED-UNIQUE, 61 UNMERGED-STALE, 265 MERGED. The archive plan (`.fable/BRANCH_ARCHIVE_PLAN.md`) covers 326 branches: 265 already merged and 61 old unmerged ones. No ref was removed. Commands awaiting Pat's approval (D-14):

```
git fetch --all
gh pr list --state all --limit 1000 --json number,state,headRefName,baseRefName > prs.json
python scripts/repo/branch_ledger.py --prs prs.json > .fable/BRANCH_LEDGER.md
python scripts/repo/archive_branches.py --execute --approved-by-pat
python scripts/repo/archive_branches.py --remove-branches --approved-by-pat
```

The first three lines refresh the ledger (branches change class as they age), the fourth only adds tags `archive/branch/<name>`, the fifth removes a branch only where its tag already exists at the same commit.

## 9. Decisions for Pat

All fifteen decisions (D-01 to D-15) were answered on 2026-11-12 and are recorded, with the 23-item list Pat answered, in `docs/USER_DIRECTIVES.md` and `.fable/DECISIONS.md`. Applied in this branch: D-02 to D-07, D-11 (drone launch), D-12, D-13, D-14 (tags only) and D-15. Approved for after the playtest and not built: D-08 (photo pay retune, numbers shown first), D-09 (fast-forward and a starter drone tool), D-10 (late-campaign alternates; a Siren on every optional approach; fleet side objectives).

Open questions, each answerable in a word (recommendation in bold):

| # | Question | Recommendation |
| --- | --- | --- |
| N-1 | Spare drones, as in the prototype (it carried four and launched a replacement when one was lost)? | **Decide after the playtest** |
| N-2 | The survey is a recon plane. When it sweeps, should Sirens notice: nothing (as the prototype), a small Hunt rise, or a loud signal they investigate (as now)? Pat, 2026-11-12: "Not sure." | **A small Hunt rise** |
| N-5 | Besides the factories in operations 3 and 11, which Siren works should sense nearby craft: every Siren industrial structure, or only named factories? | **Every Siren industrial structure, after you have played 3 and 11** |
| N-6 | Disrupt's refusal tells you no Siren is within range. Keep that (as the prototype), or fire anyway when you hold no contact? | **Keep** |
| N-7 | Remove the names of the 341 archived branches now that their tags exist? | **Yes, when you want the branch list short** |

## 10. Deferred and backlog

No P0 or P1 package was deferred: WP-00 to WP-12 all merged. Two critic findings inside WP-11 (launch strike, OUTSIDE RECOVERY) proved to be rules working as built and became D-11 instead of code changes; the Operations panel BACK became D-12.

The P2 backlog is in `.fable/OVERHAUL_PLAN.md` ("P2: backlog"). Its first items: whole-campaign blind critic coverage, the route graph and late variety (after D-10), the photo pay table (after D-08), drone pace (after D-09), buying and fitting screens, and decomposing `main.gd` and `simulation.gd`.

## 12. Repairs after the first closeout (2026-11-12)

Pat reviewed the first closeout the same day and approved a list of repairs. Done on this branch:

- **Testing cut to the bare minimum** (Pat: "the literal absolute minimum amount of testing ever"). The audit: the full matrix took 46 minutes and about 150 runner-minutes; 41 of 387 suites took 61 percent of it. Pull requests now run core, at most twelve directly affected suites and the canaries. The full matrix is a manual dispatch for a release or near-release package.
- **Drone launch restored** (WP-13), **TITLE control** (WP-14), **prototype parity audit** (WP-15, eleven unrecorded differences in `docs/V7_TO_GODOT_PARITY.md`).
- **Parity restores Pat ruled on after reading the audit** (WP-16): discovered charts on every operation after the first three, survey sweeps temporary, objectives as search areas, Disrupt keeps its charge with nothing in range, factory sensors in operations 3 and 11.
- **Housekeeping from the answered decisions:** two documents to scrap, correction notes in the story draft, `codex/handoffs` frozen, the specification's movement clause, and archive tags for 341 old branches as `fable/archive/branch/<name>` (the run's guard allows pushes only under `fable/`; no branch was removed).
- **Phase 8 (after the pause):** the DISRUPTION loadout is shown as EMP (WP-17; LOADOUT 40/0, TRUTHFUL COMMANDS 114/0, PLAYER NAMES 2834/0, RUN RECORDS 125/0, MODE RESUME 201/0, ECONOMY 59/0, FIELD TOOLS 95/0, canaries pass; the four render suites the selector named were not run locally). The code base audit Pat asked for is `.fable/CODE_AUDIT.md` (WP-18): no code changed; twelve fixes listed A1 to A12 for his yes or no.

Evidence for the repairs: DRONE BAY 74/0, core `CHECKS 850 FAILURES 0`, PROTECTED RULES 87/0, CONTROL MIX 41/0, CRASH 39/0, HANDPILOT 96/0, ONBOARDING 55/0, OPS TITLE CONTROL 60/0, PARITY RULES 60/0, V7 TERRAIN CHART 14/0, EARNED COURSE CONTINUITY 24/0, PHOTO DISCOVERY 25/0, core and the canaries again after WP-16, the selector and guidance self-tests, all local scripted verification. Unverified: operations 3 to 41 played or journeyed on a discovered chart. No full matrix ran after them, by Pat's rule. The render-only Operations suites were not run with the TITLE control in place.

## 11. Testing on the phone, and rolling back

- **Test:** open https://github.com/pemunson90-cmd/Siren-s-Song/actions/runs/43265277067 on the phone (signed in to GitHub), scroll to Artifacts, download `sirens-song-debug-apk`, unzip it and install `sirens-song-debug.apk`. It is signed with the same development key as the 1 November package, so it installs over that one. Saves from an older build may be rejected (your ruling of 2026-11-11 makes that acceptable); start a new campaign if so.
- **Things worth trying first:** open FLEET, choose a drone (it reads ABOARD) and tap water to launch it; frame a photograph near a Siren and watch the shutter ring; lose a drone and read the message; pause, select each craft and plan; open the camera on a subject that needs TIGHT while in WIDE; let oxygen run under 25 percent; lose a dive and look at the debrief; open an Expedition pre-dive page.
- **Roll back:** nothing outside `fable/` was touched, so not merging PR 262 is a full rollback. The base is tagged `fable/pre-overhaul-20261111`. Backups made before the run: `repos/_backups/Siren-s-Song-pre-overhaul-20261111.git` (mirror) and the `.bundle` beside it.
