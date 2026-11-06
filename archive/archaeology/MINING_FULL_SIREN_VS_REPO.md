# MINING_FULL_SIREN_VS_REPO

Archive side: `_archive/archaeology-staging/Siren-s-Song/homebase-sirens-song-2026-06` (reports MINING_FULL_SIREN.md, MINING_FULL_SIREN_READ_1.md, MINING_FULL_SIREN_READ_2.md, all read in full).
Repo side: ACTIVE repo `Claude Code Homebase C/siren-s-song` (Windows `C:\Users\Archi\Documents\Claude Code Homebase C\siren-s-song`), HEAD 2888192 (PR #112, 2026-10-23). Repo has no CLAUDE.md; AGENTS.md is its policy file.
Companion ledger: `READ_LEDGER_SIREN_VS_REPO.tsv` (every repo file read, lines read vs total, plus every tracked file not read and why). Working notes: `SCRATCH_NOTES_SIREN_REPO_COMPARE.md` (batches 1-51, READLOG lines).
Citation form: `file:line` is a line in the repo file at HEAD unless it starts with an archive path. "Newer wins" chronology applied: June 2026 chain versus repo decisions of 19-24 Oct 2026.
Status vocabulary: RESOLVED (repo has a working answer, cited), STRUCTURALLY ABSENT (the defect needs a mechanism the repo does not have, cited), SUPERSEDED (the thing audited no longer exists or was replaced by a ruling), DROPPED (never carried, no trace), NEVER ADDRESSED (repo has no counterpart and none is required by its rules), PROPOSED (written in a repo doc, not built), OPEN (no ruling anywhere), N/A-DOC (error inside the archive only), NOT VERIFIED (I did not read the code that would settle it; stated plainly).
No em dashes. Existing files were not modified; this file and the ledger are new.

## 1. Direct answers to the ten items Pat listed

### 1.1 Stationary sub hull-sink at about 8.4 s, suspicion peak about 87.7, versus the repo's 4 s beam lock
Status: SUPERSEDED. The June scenario cannot occur as written; an equivalent concern exists only as PROPOSED, and no test covers it.
- The repo has no player-wide suspicion meter, no 100-for-4-s sustain and no ram-based sink. The only kill route is a per-Siren sight lock: `game/src/simulation/simulation.gd:1142-1149` (lock accrues only while the Siren detects the craft, LOCKING below 4.0 s, then BEAM, then hull set to 0 and outcome lost). Sight radius is a literal in the same block (290, 180 when silent, times readiness; `simulation.gd:1108,1142-1149`).
- A stationary Quietus makes no noise: `game/src/simulation/acoustic_paths.gd:13-16` gives hearing radius 430*(speed/78)^2, so radius 0 at rest, and `acoustic_paths.gd:42` returns no arrivals when radius <= 0. A stationary craft is found only by sight, never by being heard. So the June mechanism (Hunter rams and suspicion climbing while the sub sits) has no analogue.
- Rams in the repo are closing-speed damage, not instant sink: `simulation.gd:237-273` (COLLISION_SAFE_SPEED 12, damage (impact-12)*0.45 capped 35, cooldown 1.0, `simulation.gd:66-77`; Sirens counted as bodies at `:253-273`). Test: `game/tests/collision_boundaries_tests.gd:57` (incoming moving hull damages stationary Quietus).
- Repo equivalent of "sit still and get found": a stationary craft inside patrol sight gets a 4.0 s lock, and the lock is telegraphed from the first observed tick (`game/src/presentation/lock_warning.gd:8-12`; `game/tests/lock_warning_tests.gd:19-20` asserts remaining > 3.9 s at the first frame; dedicated rising voice `:22-25`). The lock is breakable: stun zeroes lock and target (`simulation.gd:1094-1099`), cover breaks the warning (`lock_warning_tests.gd:46`), lock decays 3x without sight (`simulation.gd:1150-1152`). Design text: `docs/architecture/GAUNTLET.md:49` ("breaking detection/stunning provides a genuine recovery window"). Missions start paused (`game/src/presentation/flow/campaign_flow.gd:90`) and the first warning in ops 0-3 auto-pauses once (`game/tests/siren_warning_pause_tests.gd:31-73`).
- Numbers are therefore not comparable. June: about 8.4 s to hull-sink, never reaching the 4 s sustain. Repo: 4.0 s from first sight to instant loss, with warning and pause available.
- Hunter speed offered at 60-65 in audit 07: repo hunter speed is 64 (return 38), alert Siren 48, idle 25 (`simulation.gd:1168-1172`). It was never a ruling; it is just where the repo landed.
- `docs/FUTURE_OPTIONS.md:13` records a repo-side "stationary Quietus 78 hull alone, 100 with a second craft" (audit finding 5, echo resets armed strike). That is about the parked active-sonar sweeper on branch `claude/future-siren-active-sonar-sweeper`, not integration (`docs/SESSION_LEDGER_2026-10-21.md:19`, `docs/REPOSITORY_MAP.md:34`).
- PROPOSED, not built: `docs/design/STEALTH_AI_ROADMAP.md:154` item 4 ("a stationary Quietus with all tools unused can always reach a pause-and-plan state") and `:167` assertion (b) (stationary pauseable window of at least 4 s from first notice to beam). Closest built test: `game/tests/patient_play.gd:21` (rehearsal fails if any Siren reaches LOCKING or BEAM) and `game/tests/opening_depth_scenarios.gd:117` (repeated depth toggling cannot make a stationary craft invulnerable). No registered suite in `game/tests/suites.txt` asserts the stationary-patient case.
- Rule guard: combat, beam, collision, damage, hull and Siren sight/hearing are frozen without Pat (`docs/DESKTOP_HANDOFF.md:89-92`, `docs/RESUME.md:94-95`).

### 1.2 90 versus 93 TUNING keys
Status: SUPERSEDED (June table not carried); counts re-confirmed from the archive reports.
- Archive: 90 keys in the Step 6, 7 and 8 builds, 93 in the final Step 9 build (adds NOISE_GAIN, NOISE_HEAR_MAX, SILENT_BIND_KEY); handoff 07 table has 89 rows; handoff 09 claim of 99-102 is wrong (MINING_FULL_SIREN.md 2.1; READ_2 section 2).
- Repo: `game/src/simulation/tuning.gd` (26 lines, 14 constants as read, `tuning.gd:1-26`; includes EMP_RADIUS 340, EMP_STUN 12.0, WEAPON_NOISE 650, DECOY_NOISE 1100, DECOY_TIME 15.0, RECON_TIME 8.0). The rest of the repo's tuning is spread across module data tables and `simulation.gd:58-98` constants (`all_stop_table.gd:12-15`, `depth_bands.gd:3-4,90-92`, `sweeper_senses.gd` PROFILES, `craft_upgrades.gd:20-29`, `endurance_budgets.gd:4`). The repo's engineering rule is "numbers in data tables" (`docs/SESSION_LEDGER_2026-10-22.md:6`). The June 93-key table is not in the repo, and no June constant name appears (`git grep` of INSTAKILL, kill_hold, hasActiveDetector: 0 hits outside reference/).
- Side-by-side map is in section 4.

### 1.3 Audio starting only on keypress for touch users
Status: STRUCTURALLY ABSENT in code; device confirmation DEFERRED by Pat's rule.
- Godot players are created at node ready and run without a gesture gate: `game/src/audio/soundscape.gd:69-82` (ambience, tension and engine call play() then stream_paused until the dive), Soundscape node added in `game/src/main.gd:148`. Native Godot audio needs no key or gesture unlock; the June defect was a Web Audio `AU.init()` inside a `keydown` handler.
- Suspension and mute are handled: `main.gd:665-682` (APPLICATION_PAUSED/FOCUS_OUT pauses, saves, `sound.suspend()`; RESUMED resumes), `soundscape.gd:116,124-140`, MUTE at `main.gd:645`, settings text `main.gd:639`. Photo audio also suspends (`game/src/audio/photo_audio/photo_audio.gd:85-91`). Test names: `photo_audio_tests`, `received_audio_retry_tests` (`game/tests/suites.txt:126,210`; not read).
- No repo doc or test mentions first-touch audio start or Android audio focus (`git grep` for unlock, first touch, user gesture, audio focus returned nothing audio related). `docs/PLAYTEST_ANDROID.md:24` is a generic audio and dread check. Phone testing is deferred (`AGENTS.md:25`, `docs/DESKTOP_HANDOFF.md:181-183`).

### 1.4 Touch HUD hidden with no canvas replacement
Status: STRUCTURALLY ABSENT, with one nuance worth Pat's eye.
- No `display:none` touch branch exists. The HUD is built unconditionally (`main.gd:107-126`). The always-on status line (`main.gd:314`, DEPTH, O2, HULL, RECORDS, PAUSE) is hidden by the mission HUD (`game/src/presentation/mission_hud.gd:333`), and replaced by on-canvas instruments: per-craft gauge rings (`game/src/presentation/fleet_ring.gd:3-7,47-56`; drawn at `fleet_instruments.gd:232`), text status `HULL %d | O2 %d` for Quietus and `BAT %d%%` for drones (`fleet_instruments.gd:88-93`), a forced text plate whenever any reserve is at or below 25% (`fleet_instruments.gd:188-191`, critical at `fleet_ring.gd:6`), tool counts on the buttons (`main.gd:335-342`), the intent line (`mission_hud.gd:401`), the OP PRESSURE and HEARD WARNING alarm (`mission_hud.gd:537-551`), RECORDS n/m (`mission_hud.gd:408`). Tests read in full: `game/tests/fleet_ring_ui_tests.gd:168-177` asserts that an unselected craft's critical reserve stays numeric, that RUN sheds ordinary selected detail while keeping critical numbers, and that pause restores exact selected reserves; `:40-56` (stock_reference) asserts a 27-oxygen warning stays numeric through a loadout cycle, RESUME and a binary save restore; `game/tests/playfield_hud_tests.gd:52,60` assert the persistent HUD leaves most water unobscured and every chart control is at least 48 dp. All run at 2520x1080 and 2184x1968. `radial_hud_tests` not read.
- Nuance: the always-visible reserve is the gauge arc, not digits. Digits show while the craft is selected and (paused or within 3 s of selection), or when critical (`fleet_instruments.gd:139,189-191`). June asked for hull, oxygen, charges and state to be visible at all times; the repo gives arcs always and numbers on demand. See open item 2.

### 1.5 RESTART appearing only after certain taps
Status: STRUCTURALLY ABSENT.
- The debrief always renders RETRY DIVE and OPERATIONS ARCHIVE for both outcomes (`game/src/presentation/flow/campaign_flow.gd:179-180`), and the loss branch shows SIGNAL LOST, the cause and a loss summary (`campaign_flow.gd:175-178`, `game/src/presentation/loss_summary.gd:7-18`). Debrief is entered from the frame loop whenever `sim.outcome` is set (`main.gd:296-305`), so time-based losses (oxygen, beam) reach it with no tap-owned flag. Defeats keep progress and retry is immediate (`docs/architecture/GAUNTLET.md:45`). Tests: `campaign_debrief_view_tests` was read and covers the expedition debrief (`campaign_debrief_view_tests.gd:38-51`), not the RETRY button itself; `campaign_main_dispatch_tests` not read. So the always-present RETRY DIVE is established from `campaign_flow.gd`, not from a test.

### 1.6 Unscaled mouse coordinates on hybrid devices
Status: STRUCTURALLY ABSENT.
- One input path serves touch and mouse with `event.position` in viewport coordinates after engine stretch scaling (`main.gd:369-425`, shared `map_gesture`; `game/src/input/map_gesture.gd:1-34`), project stretch `canvas_items`, aspect `expand` (`game/project.godot:13-14`), content rect scaling in `game/src/presentation/layout_metrics.gd:3-13`. Emulated mouse events from touch are ignored to prevent double-fire (`main.gd:391`, `mission_hud.gd:204-211,241`, `fleet_instruments.gd:33`). There is no separate unscaled desktop handler. Tests send a real touch plus an emulated mouse event for every tap and assert one action (`game/tests/fleet_instruments_ui_tests.gd:12-15`, `fleet_ring_ui_tests.gd:16-17`), and cover drag, second-finger and mixed gestures that must not become orders (`fleet_instruments_ui_tests.gd:54-65`). No true touch-plus-physical-mouse device test exists and none was run.

### 1.7 Does the repo's stun display leak hidden Siren positions
Answer: no, by construction, with one deliberate bearing disclosure.
- Stun is shown only on contacts: `game/src/presentation/contact_feedback.gd:19-21` and `lock_warning.gd:9` call `observed_stun.remaining(contact, elapsed)`; `game/src/simulation/observed_stun.gd:9-13` records a stun only for a visible, fresh (<0.3 s) contact. Contacts exist only when `contact_visible` is true (`simulation.gd:999-1007,1034-1044`) and expire after 20 s (`:1013`).
- Sirens are drawn only from `contact_entries()` (`game/src/presentation/ocean_view.gd:366-372,604-641`): fresh and stale glyphs differ, stale contacts are dim at the last seen point with LAST SEEN text (`contact_feedback.gd:11`), the pin display is derived from the contact (`ocean_view.gd:604-641`). `git grep` over presentation and main found no read of `sim.sirens` except stdout diagnostics (`main.gd:773-780`, "Hidden AI state never enters the player HUD"). The June leak (stun ring at every stunned Siren's true position, READ_1 defect 18) is therefore absent.
- Deliberate exceptions, both owner-approved or earned: the D1 first-Siren cue shows a bearing only, ops 1-3 only, with a 2.5 s arrow (`game/src/presentation/first_siren_cue/first_siren_cue.gd:42-55`, `cue_table.gd:4-10`, `docs/USER_DIRECTIVES.md:10`), and the HEARD WARNING bearing from a received sound (`mission_hud.gd:544-551`).

### 1.8 itch.io-first distribution advice versus Android-first
Status: SUPERSEDED on platform (newer wins); the monetization and distribution advice itself is NEVER ADDRESSED in the repo and is outside agent scope.
- Zero hits for itch.io, butler or PWYW in the repo (`git grep -i itch` matched only the substring in "switch" and audio attribution text). Export config is Android plus Linux, no Web preset, `permissions/internet=false` (`game/export_presets.cfg:1-48`, L29). Decision record: `docs/decisions/0001-godot-android-production.md:9` rejects the HTML5/Canvas wrapper. Platform contract: `docs/architecture/GAUNTLET.md:11,23` (Android first; no WebView, browser or network dependency). Scope: `docs/CURRENT_GAME_SPEC.md:10` (store submission, monetization, marketing and publisher accounts out of scope unless the user asks) and `AGENTS.md:25,43` (APK builds prohibited, publishing administration outside the grant). Pat's stated end goal is a publishable APK (`docs/directives/2026-10-20-audit-reaffirmation.md:28`).
- The June research (itch.io PWYW, Patreon, Ko-fi, web portals, no native mobile) is not rejected, only out of scope. Keep as a human-owned note.

### 1.9 One-way story frame versus rescue arc
Status: SUPERSEDED. The repo is a rescue and survivor arc; none of the June text survives.
- Repo premise: Quietus is a military photographic recon vessel; Sirens were here first and built the factory; rescued survivors are humans from drilling and military sites struck by threat-reactive Sirens (`docs/STORY_BIBLE_DRAFT.md:3,7,10-13`, `docs/USER_DIRECTIVES.md:45,55`, `docs/SESSION_LEDGER_2026-10-21.md:7`). Pat rejected the Siren-evacuation arc (`docs/PAUSE_CHECKPOINT_2026-10-21.md:12,78`). Playable graph and four endings (Silent Exodus, Beacon Pact, Hidden Harbour, Surface Reckoning): `docs/PASS0_CAMPAIGN_PLAN.md:10-30`; true ending after op 25 (`docs/SESSION_LEDGER_2026-10-22.md:27`). Mission 5 debrief ends with "THE SONG CONTINUES": two bearings, people at both, air running down, Quietus can reach one first (`campaign_flow.gd:170-173`; `simulation.gd:1437`).
- The June frame ("never reconnaissance", "never meant to come back", "hide in the cold") has 0 hits outside `reference/`. The functional spec's "never meant to be a return trip" line is `reference/original-prototype/SIRENS_SONG_functional_spec.md:190-193`. USER_DIRECTIVES (21 Oct) still says do not author new narrative text, so the June lines must not be reused without Pat.

### 1.10 Pre-fix v7 variant
Status: RESOLVED in the repo, verified now by direct diff.
- CR-stripped diff of the Inbox copy (`homebase-sirens-song-2026-06/Inbox_from_Claude.ai/Siren's Song claude web/sirens_song_prototype_v7.html`, 47,365 B) against `reference/original-prototype/sirens_song_prototype_v7.html` (47,972 B raw, CRLF, md5 b6e3a220...): exactly one line differs, line 587 `startGame`. The Inbox copy calls `resize()` before un-hiding HUD and controls (pre-fix); the repo copy moves `resize()` to the end, after un-hide (fixed).
- Repo MANIFEST row `reference/original-prototype/MANIFEST.md:17` says v7 is 47,365 B, md5 e142ae3c..., and "adds ... the resize-ordering fix". The size and md5 describe LF bytes; the fix text is true of the repo file's content but the Inbox file of that size lacks it. The MANIFEST hash row does not match the repo file (CRLF).
- The Inbox copy is superseded by the repo copy; scrap is Pat's call (open item 8).

## 2. The 30 audit rows of MINING_FULL_SIREN.md section 3, one by one

| # | June finding | Repo status | Repo evidence (file:line) |
|---|---|---|---|
| 1 | Stationary sub hull-sinks about 8.4 s, susp about 87.7; Hunter 60-65 offered | SUPERSEDED; equivalent PROPOSED, untested | Section 1.1: `simulation.gd:1142-1149`, `acoustic_paths.gd:13-16,42`, `STEALTH_AI_ROADMAP.md:154,167` |
| 2 | Valve reset below 100 versus below 75 | SUPERSEDED | No global meter. Fairness valve is the telegraphed 4 s lock broken by cover or stun: `simulation.gd:1094-1099,1150-1152`, `lock_warning_tests.gd:46`, `GAUNTLET.md:49` |
| 3 | Objective markers occluded by the factory | SUPERSEDED | Observable sites are masked by the photo rules, not by a factory occluder: `ocean_view.gd:63-64`, `simulation.gd:274-276`. Deeper marker logic not read |
| 4 | Sentinel inside factory LOS-occluded; basic multi-Siren coordination; Hunter wanders at Curious | SUPERSEDED, with a correction | Sentinel, hunter, sweeper and four more roles still exist (`enemy_types.gd:5`); sight needs line and depth transmission (`simulation.gd:1034-1044,1142-1149`). The earlier report said the global Hunt replaces the Hunter: wrong, the hunter role remains and the mission Hunt is separate (`recon_consequences.gd:9-14`) |
| 5 | Stun maps keyed by `siren.type` break with 2+ Patrollers | RESOLVED | Stun lives on each Siren and contact: `acoustic_network.gd:35-36`, `contact_reports.gd:19,25`, per-contact `observed_stun.gd:9-13` |
| 6 | Recon not LOS-gated | NOT VERIFIED | Recon is a 4-pressure action (`simulation.gd:694-697`) with RECON_TIME 8 (`tuning.gd`); I did not read the recon reveal code, so whether it is LOS-gated is undetermined here |
| 7 | Recon radius test hardcodes 400 after Step 7 made it 460 | DROPPED | June harness not in repo (0 hits for smoke_test, jsdom, step6_tests). Repo harness: `game/tests/run_tests.gd:10-41`, `scripts/toolchain/test.sh` |
| 8 | Oxygen 210 is an estimate | SUPERSEDED | Per-level budgets 180 to 840 s: `game/src/campaign/endurance_budgets.gd:4`; drain `operation_endurance.gd:8` |
| 9 | Sub-cam-only path unaddressed | RESOLVED by design, scripted proof only | Quietus photographs itself, per-craft capture (`CURRENT_GAME_SPEC.md:69`, `docs/PHOTO_RECON.md`); scripted Quietus-only runs finish 16 of 16 (`SESSION_LEDGER_2026-10-21.md:20`), "not balance or enjoyment proof" |
| 10 | Mobile potholes: touch listeners unconditional, click double-fire, text-only portrait warning, `?` no-op | SUPERSEDED, double-fire guarded | Emulated mouse ignored: `main.gd:391`, `mission_hud.gd:204-211`, `fleet_instruments.gd:33`. Landscape fixed: `project.godot:15`, `export_presets.cfg:27`. Help is a FIELD MANUAL button: `campaign_flow.gd:73,78` |
| 11 | UI placeholder constants (deadzone 0.22, axis 0.35, 22vmin) | SUPERSEDED | No joystick. Gesture constants `map_gesture.gd` DRAG_THRESHOLD 14; 48 dp minimum `layout_metrics.gd:9-13`, `USER_DIRECTIVES.md:37` |
| 12 | `AU.beat`, `AU.decoy`, `AU.drone`, `AU.stopAmb` unbound | SUPERSEDED | All cues loaded in one list (ping, camera, emp, knock, snare, record, loss, extraction, alert, recon, decoy, creak, beam, heartbeat and more): `soundscape.gd:78`; received cues `received_cues.gd:1-20` |
| 13 | Noise to Siren investigate write-through deferred | RESOLVED in design | Heard path `simulation.gd:1108-1110` (propulsion over 50, 430 times ear times readiness) and water-path arrivals when `acoustic_revision==1` (`:1190`, `acoustic_paths.gd:13-16`); notice signal `:1129` |
| 14 | `AU.init()` only on `keydown` | STRUCTURALLY ABSENT | Section 1.3 |
| 15 | Step 9 RED truncated build, hardened gates | N/A-DOC | Repo analogue of hard gates: summary line and error scan required per suite, `test.sh:84-90`; CI `gauntlet-pr-checks.yml:73-87` |
| 16 | Refire YELLOW misattributes stationary case to oxygen | N/A-DOC | Archive-internal |
| 17 | Handoff 09 TUNING count 99-102 (actual 90-93) | N/A-DOC | Archive-internal |
| 18 | Step 9 patch size and `__sim` counts wrong | N/A-DOC | Archive-internal |
| 19 | Step 9 patch never merged into spec | DROPPED | Repo spec is `CURRENT_GAME_SPEC.md`; 0 hits for hasActiveDetector, active detector, shadowPoly. Repo-native text: `design/SIRENS_SONG_DESIGN_BIBLE_GAUNTLET_V1.md:66`, `GAUNTLET.md:49` |
| 20 | Ratification conflict on the four Step 9 pulls | OPEN | Archive-internal; repo records v7 as ratified reference 2026-10-19 (`SOURCE_AUTHORITY.md:21`), not the Step 9 pulls |
| 21 | Smoke test on wrong build, fails `node --check`, needs jsdom | DROPPED | No June harness in repo; repo has its own suite registry `game/tests/suites.txt` (217 lines, 194 suites), `test.sh:23-49` validates it before any run |
| 22 | Hardcoded Patroller proximity 194 px / rate 1.5 outside TUNING | DROPPED, lesson applies | Not carried, but the repo also has inline literals (sight 290/180, hearing 430 at `simulation.gd:1108-1110,1142-1149`) outside `tuning.gd` |
| 23 | Sirens ignore terrain | SUPERSEDED | Enemy pathing respects terrain: `GAUNTLET.md:49`; nav built in `simulation.gd:431-640` (`_build_navigation`, used by `lock_warning_tests.gd:16`) |
| 24 | Stale titles and comments (Step 4, 1000x640, speed 110) | DROPPED | HTML line not in repo |
| 25 | Inbox analysis wrongly says v7 lacks kill rule, drones, noise | N/A-DOC | Repo treats v7 as the ratified reference: `SOURCE_AUTHORITY.md:21`, `V7_TO_GODOT_PARITY.md:16,26`, bible `:66` |
| 26 | Inbox v7 lacks the `resize()` ordering fix | RESOLVED | Section 1.10, direct diff |
| 27 | MINING_REPORT backup-size map wrong | N/A-DOC | Archive-internal |
| 28 | `claude_index.md` stale | N/A-DOC | Archive-internal |
| 29 | Audit 04 first-pass failures were harness issues | N/A | Resolved inside the June chain |
| 30 | "Section 2.7 thermocline" cited but absent | N/A-DOC | Archive-internal |

Counts (30 rows): RESOLVED 4 (rows 5, 9, 13, 26); STRUCTURALLY ABSENT 1 (14); SUPERSEDED 9 (1, 2, 3, 4, 8, 10, 11, 12, 23); DROPPED 5 (7, 19, 21, 22, 24); OPEN 1 (20); NOT VERIFIED 1 (6); N/A-DOC 8 (15, 16, 17, 18, 25, 27, 28, 30); N/A 1 (29). Total 30.

## 3. READ_1 and READ_2 defects mapped to the repo

### 3.1 MINING_FULL_SIREN_READ_1 (24 new defects, 6 corrections)

| R1 # | June defect | Repo status | Evidence |
|---|---|---|---|
| 1 | EMP with nothing in range raises Hunt by 4 (v7 only) | DIFFERENT, consistent cost | `game/src/simulation/orders/weapon_orders.gd:14` spends the charge unconditionally; disruption adds 4 pressure through `_noise` (`simulation.gd:694-697`). Both cost and pressure always apply; the v7 inconsistency is not carried. Whether spending a charge on an empty radius is intended is open item 9 |
| 2 | No key-repeat guard: held SPACE pins suspicion; held Digit1 burns charges | PARTLY RESOLVED | Ping is refused while its feedback timer runs (`game/src/simulation/orders/sensor_orders.gd:11`) and every pulse spends oxygen or battery (`advanced_sonar.gd:35-37`); recon and weapons spend counted charges. Nothing in the repo converts a held key into suspicion. Primary input is tap buttons, keyboard is fallback (`USER_DIRECTIVES.md:37`, `CONVENTIONS.md:17`); SPACE only pauses (`main.gd:450-462`). Keyboard `echo` handling itself not traced |
| 3 | World edge counts as a hull hit; hull 3 lost in 1.8 s | PARTLY | Damage is speed-scaled with a safe speed of 12 and a 1.0 s cooldown (`simulation.gd:66-77,237-252`), so slow contact is free. World-edge handling not read |
| 4 | Extraction comments say bottom-left, is top-left | DROPPED | June layout |
| 5 | Patrol segment crosses the factory rect | DROPPED | Repo asserts mobile circulation or stationary sweeper per mission: `game/tests/patrol_scenarios.gd:14` |
| 6 | Win and lose in the same tick; overlays both draw | NOT VERIFIED | Single `sim.outcome` string drives one debrief branch (`campaign_flow.gd:150,175`); tie precedence not separately tested |
| 7 | "Coast about 3 s" comment wrong | RESOLVED explicitly | ALL STOP COAST_DECEL 14.0 with a test bound under 42.0: `all_stop/all_stop_table.gd:12-15`, `game/tests/all_stop_tests.gd:29` (as cited by READ_1) |
| 8 | Objective markers gated by a LOS that includes the factory | SUPERSEDED | Audit row 3 |
| 9 | Terrain drawn through reveal discs | PARTLY MET by design | Fog from known/visible (`ocean_view.gd:283-287`), ping rays stop at cover (`:296-302`); precharted rock silhouettes allowed (`GAUNTLET.md:51`) |
| 10 | Sentinel orbit snaps and teleports | DROPPED | Repo sentinels tether (`STEALTH_AI_ROADMAP.md:15`); repo's own gap: sentinels cannot walk authored points (`:75`), proposed Phase C (`:122-123`) |
| 11 | Sentinel pursues without LOS; Hunter omniscient | SUPERSEDED | Acquisition needs sight or heard arrival (`simulation.gd:1034-1044,1108-1110,1142-1149`); fair-information rule `CURRENT_GAME_SPEC.md:71` |
| 12 | Hunter clears the single shared lastPing | NOT CARRIED | Per-Siren heard state; sweepers follow only the last noise they heard (`onboarding_text.gd:41`). No shared global ping variable found |
| 13 | A parked drone pins Curious Sirens forever; no decoy lifetime | RESOLVED for decoys | DECOY_TIME 15.0 (`tuning.gd`), range 160 (`simulation.gd:60-65`), 3 charges (`:97-98`). Drone-as-bait not verified |
| 14 | Proximity terms not LOS or state gated; suspicion rises idle | RESOLVED by design | Sight needs `Depth.sight` and line (`simulation.gd:1142-1149`); a stationary craft makes no sound (`acoustic_paths.gd:13-16,42`) |
| 15 | Stale step comments | DROPPED | |
| 16 | Sentinel in factory untargetable by EMP/KD | SUPERSEDED | Repo targeting needs a fresh optical contact under 0.3 s within 150 (`simulation.gd:557-566`) and refuses with "no torpedo spent" (`main.gd:429-441`) |
| 17 | Dead exports (raycastTerrainHit, jamProxMultiplier) | DROPPED | |
| 18 | Stun overlay leaks true position through the dark | STRUCTURALLY ABSENT | Section 1.7 |
| 19 | Click consumes tool on refused shot; EMP/KD on stunned wastes a charge | RESOLVED for torpedo | `weapon_orders.gd:19-22` (invalid knock spends nothing, stunned target refused), `main.gd:429-441`. EMP unconditional (item 9) |
| 20 | Kill path has no detector condition at Step 5 | RESOLVED | Lock accrues only while detected; stun zeroes it: `simulation.gd:1094-1099,1142-1149` |
| 21 | `countVisibleSirens` duplicates draw-side logic | RESOLVED | Single `contact_visible` feeds contacts and targeting: `simulation.gd:999-1007,557-566,1034-1044` |
| 22 | Sirens ignore terrain; ping hearing ungated; drones die to touch | SUPERSEDED | `GAUNTLET.md:49`; sound does not pass rock (`CURRENT_GAME_SPEC.md:66`); drones die to a beam (`V7_TO_GODOT_PARITY.md:16`) |
| 23 | Factory geometry and ring mismatches; circular rocks vs polygons | DROPPED | Repo polygon bounds suite `polygon_bound_tests` (`suites.txt:27`, not read) |
| 24 | `user-scalable=no`; remote Google Fonts | STRUCTURALLY ABSENT | Text size NORMAL/LARGE/EXTRA LARGE (`main.gd:648`); no internet permission (`export_presets.cfg:29`) |
| C1 | Mining item 26 evidence wrong (byte sizes) | CONFIRMED and now diffed directly | Section 1.10 |
| C2 | Mining item 14 correct only for June build | CONFIRMED | Section 1.3 |
| C3-C6 | Items 25, 24, 3, hunter chase 64 | CONFIRMED | Repo hunter speed 64 (`simulation.gd:1168-1172`) |

### 3.2 MINING_FULL_SIREN_READ_2

| R2 item | Repo status | Evidence |
|---|---|---|
| pre-step7 defects 1-4, 9 (stale comments, orphan blocks, hoisted placeholder) | DROPPED | HTML line not in repo |
| pre-step7 5 and 6 (loseReason overwritten; win and lose same tick) | NOT VERIFIED | See R1 6 |
| pre-step7 7 (photo through rock, range only) | NOT VERIFIED | Photo rules read only at doc level: `docs/PHOTO_RECON.md`; `photo_capture.gd` (443 lines) not read |
| pre-step7 8 (marker LOS includes factory) | SUPERSEDED | Audit row 3 |
| pre-step7 10 (hold thrust into rock, hull drops 1 per 0.6 s) | RESOLVED | Speed-scaled damage, safe speed 12, cooldown 1.0, 25% speed retained: `simulation.gd:66-77,237-252` |
| pre-step7 11 (stun keyed by type) | RESOLVED | Audit row 5 |
| pre-step8 (400 versus 460, area versus radius, stale prose) | N/A-DOC / DROPPED | |
| pre-step9 1 (no readout on touch) | STRUCTURALLY ABSENT | Section 1.4 |
| pre-step9 2 (RESTART visible only after arm taps) | STRUCTURALLY ABSENT | Section 1.5 |
| pre-step9 3 (hybrid mouse unscaled) | STRUCTURALLY ABSENT | Section 1.6 |
| pre-step9 4 (armed strings claim wrong) | N/A-DOC | |
| pre-step9 5-6, 8, 9 (DEPLOY redundant, helpVisible, synthetic keys, digital joystick) | NOT APPLICABLE | No joystick or armed-deploy mode; orders by chart tap and command ring (`mission_hud.gd:16,63-76`) |
| pre-step9 7 (`user-scalable=no`) | STRUCTURALLY ABSENT | R1 24 |
| Section 4 wrong claims 1-9 | N/A-DOC | Archive-internal |
| Section 5 repo-check rows (15) | RE-VERIFIED from code, 2 corrections | Corrections in section 5 below (suspicion decay; hunter) |

## 4. June tuning constants versus the repo (what each became)

June values from MINING_FULL_SIREN.md 2.1 and READ_2 section 2; repo values read at HEAD. "Same number, different meaning" is flagged because it is the easiest place to misread.

| June constant (value) | Repo counterpart | Status |
|---|---|---|
| HULL_MAX 3, any bump is 1 hit, HULL_HIT_COOLDOWN 0.6 | hull 100 continuous; collision damage (impact-12)*0.45, cap 35, safe speed 12, cooldown 1.0, speed retained 0.25 (`simulation.gd:66-77,91,237-252`) | SUPERSEDED |
| INSTAKILL_SUSTAIN_SEC 4.0 (suspicion at 100 for 4 s) | per-Siren sight lock 4.0 s then instant hull 0 (`simulation.gd:1142-1149`) | Same number, different meaning |
| SUSP_MAX 100, THRESH_ALERT 34, THRESH_HOSTILE 75, WARNING_THRESHOLD 75 | No player meter. Per-Siren suspicion 0..1 with floors; mission Hunt stages at 20/45/70/90 (`recon_consequences.gd:9-14,59`); a `pressure.hostile` flag only speeds the heartbeat (`soundscape.gd:137-140`) | SUPERSEDED |
| SUSP_DECAY_PER_SEC 5 | per-Siren suspicion falls 0.015/s toward its floor (`simulation.gd:1150-1152`); mission Hunt falls 1/s after 6 s without action, floored at 8 per secured photo (`recon_consequences.gd:9-14,30`); lock decays 3x without sight (`:1150-1152`) | SUPERSEDED. Corrects the earlier claim that the repo has no decay |
| SUB_SPEED 80, drones 110 | Quietus 78 cruise, 42 silent; drones 96 transit, 42 quiet (`simulation.gd:747`, `route_orders.gd:52`, `Tuning.DRONE_*`) | SUPERSEDED |
| Inertia accel 60 / reverse 0.5 / drag 0.45 / turn 2.6 / 2.0 | Not carried by name. ALL STOP coasts at 14 m/s^2, costs 1.0 oxygen to stop, restart 0.5, 6 s at 20 (`all_stop_table.gd:12-15`) | SUPERSEDED |
| OXYGEN 210 (240 before Step 7) | per-level 180-840 s (`endurance_budgets.gd:4`, `operation_endurance.gd:8`) | SUPERSEDED |
| PING 3.0 s / 360 px, SUSP_PING_COST 25 | pulse low 440 m, cost 0.4; high 720 m, cost 1.2 oxygen; signature 750/1300; 2.5 s noise event; sound speed 300 (`advanced_sonar.gd:7-9,41`) | SUPERSEDED (cost is reserves, not heat) |
| PASSIVE_RADIUS 90 | Quietus passive 240, drones 330, survey 460 (`craft_upgrades.gd:27-29`; PARITY `:23`) | SUPERSEDED |
| NOISE_GAIN 4.5, NOISE_HEAR_MAX 360 | hearing radius 430*(speed/78)^2 (`acoustic_paths.gd:13-16`); silent engines-off gives zero (`all_stop_table.gd` OFF_NOISE 0.0) | SUPERSEDED |
| Patroller 40 x1.6, Hunter 75 (90 before), Sentinel 24/55 | alert 48, idle 25, hunter 64 (return 38) (`simulation.gd:1168-1172`) | SUPERSEDED |
| Patroller proximity 194 px, rate 1.5 (hidden) | Sight 290 m, 180 silent, times readiness 1.0-1.7 (`simulation.gd:1142-1149`, `recon_consequences.gd:23-25`) | SUPERSEDED |
| DRONE_SUPPLY 5, vision 120 | two drones, 3 decoys, 2 torpedoes, 2 recon (`simulation.gd:97-98`, `campaign_flow.gd:35`) | SUPERSEDED |
| JAM 3 charges, +5 susp, 4 s, halves proximity | No player jam. Listed as proposed (`design bible:64`); only an encounter rule named jam (`choir_rules.gd:30`) | DROPPED (proposed only) |
| EMP 3 charges, 5 s targeted, +20 susp | radial EMP_RADIUS 340, EMP_STUN 12.0, 2 charges (`tuning.gd`, `simulation.gd:97-98`, `CURRENT_GAME_SPEC.md:76`) | SUPERSEDED. v7 values match the repo, not June |
| KNOCKDOWN 2 charges, 12 s targeted | physical torpedo, KNOCK_RANGE 150, KNOCK_TIME 8, pin 8 s, speed 180 (`simulation.gd:60-65,1074-1075`) | SUPERSEDED |
| RECON 2 charges, 8 s, radius 460 | RECON_TIME 8.0, 2 charges, local 560 m survey when the mission has a world size (`tuning.gd`, `sensor_orders.gd:24`) | SUPERSEDED |
| Decoy passive 180, active 320, weight 2.0 | DECOY range 160, 3 charges, DECOY_TIME 15.0, DECOY_NOISE 1100 (`simulation.gd:60-65`, `tuning.gd`) | SUPERSEDED |
| FACTORY_PROX tiers 140/260/420 at 3/2/1 per s | No factory proximity gain by name. Mission pressure from actions and readiness; photo grade formula keeps v7's drone .55 / sub .25 plus .45 proximity (`recon_consequences.gd:39`) | SUPERSEDED |
| Thermal band halves detection (v7 x0.5) | foundry front transmission 0.55 per crossing, close range 120 (`thermal_front.gd:5,45-51`) | SUPERSEDED, same idea |
| SENTINEL_DETECT 220, tether | tether 160 to 190 proposed range (`STEALTH_AI_ROADMAP.md:15`) | SUPERSEDED |
| HUNTER roles: dormant, pursue, return | hunter role kept in an eight-role roster (`enemy_types.gd:5`) | CARRIED |

## 5. Corrections to earlier statements (mine and the archive's)

1. Earlier MINING_FULL_SIREN.md section 5 said "no suspicion decay in the repo". Wrong. Per-Siren suspicion decays 0.015/s toward the hidden floor (`simulation.gd:1150-1152`) and the mission Hunt decays 1/s after 6 s (`recon_consequences.gd:9-14`). What the repo dropped is the player-wide meter, the 5/s decay and the 4 s sustain.
2. Earlier row 4 said the global Hunt replaces the Hunter. Wrong. Both exist: `enemy_types.gd:5` keeps `hunter`, and `recon_consequences.gd` carries a separate mission pressure with stages.
3. Doc versus code tension, not mine to resolve: `docs/V7_TO_GODOT_PARITY.md:19` says the global Hunt was replaced by local suspicion plus a campaign-wide action estimate plus guard floors, while `recon_consequences.gd:9-14,59` still implements a per-mission hunt with five named stages that the HUD surfaces as OP PRESSURE (`mission_hud.gd:537-543`). The doc may describe the intended design and the code the landed one.
4. READ_2 section 4 item 8 correction stands: the file is `game/src/simulation/tuning.gd`, not `game/src/tuning.gd`.
5. `docs/FUTURE_OPTIONS.md:13` (stationary Quietus 78 hull alone, 100 with a second craft) belongs to the parked active-sonar sweeper branch, not to integration. The earlier archive report cited it as a stationary-sub hit without that scope.
6. READ_2 section 5 said "no hull cooldown constant found" in the repo. There is one: collision cooldown 1.0 (`simulation.gd:66-77,237-252`).
7. READ_1 stated "Hunt-on-empty-EMP: weapon_orders L8-20 has none". Confirmed, and the repo's EMP spends its charge with no empty-radius check (`weapon_orders.gd:14`); see open item 9.

## 6. Open items for Pat (new, from this comparison; the 12 in MINING_FULL_SIREN.md section 7 and 3 in READ_2 still stand)

1. Stationary-in-sight: the repo kills a stationary craft 4.0 s after first sight, with a warning and pause available. The roadmap proposes a fairness assertion for it (`STEALTH_AI_ROADMAP.md:154,167`) but no suite checks it. Do you want that assertion written as a test only (no rule change), given the frozen combat rules?
2. Touch readout: hull and oxygen are always visible as gauge arcs, but as digits only when the craft is selected and paused or newly selected, or at 25% or less (`fleet_instruments.gd:139,188-191`). Is arcs-plus-on-demand-digits acceptable, or do you want digits always shown (the June ask)?
3. Device checks still deferred by your rule: first-touch audio start, Android Back (`RESUME.md:38-46` flags `quit_on_go_back` risk, handoff 041; `project.godot` has no key and only `main.gd:681` handles GO_BACK), hybrid mouse input. Their code paths are present; nothing here was run on a device.
4. The v7 MANIFEST row (`MANIFEST.md:17`) lists 47,365 B and md5 e142ae3c for a file whose repo copy is 47,972 B CRLF with a different md5. Informational; the MANIFEST ships inside a zip too (`reference/SIRENS_SONG_ORIGINAL_PROTOTYPE_HANDOFF.zip`, not opened).
5. The Inbox v7 copy is the pre-fix variant (one line, `startGame`). Safe to treat as superseded and scrap, your call. Nothing was removed.
6. The June story lines have 0 hits in the repo. Keep them archived only, per `USER_DIRECTIVES.md:55` ("Do not author new narrative text").
7. The doc versus code tension on the global Hunt (correction 3): which one is the intended design?
8. June monetization and distribution stack stays a human-owned note (itch.io, Patreon, Ko-fi, portals); the repo and its grant exclude it (`CURRENT_GAME_SPEC.md:10`, `AGENTS.md:43`).
9. EMP spends a charge and adds disruption pressure even when no Siren is inside the radius (`weapon_orders.gd:14`, `simulation.gd:694-697`). v7 charged nothing and gave Hunt anyway on empty. Intended? Weapon rules are in the frozen set.
10. Inline literals outside `tuning.gd` (sight 290/180, hearing 430 at `simulation.gd:1108-1110,1142-1149`) repeat the June lesson about constants that escape tuning passes. A table move is a no-behavior refactor, but the combat rules are frozen, so it needs your go.

## 7. Coverage and limits (stated plainly)

Repo files read in full, literal numbered chunks, no sampling: 108 files (ledger rows status `full`; per-file line counts in `READ_LEDGER_SIREN_VS_REPO.tsv`). Partial reads: 0. Tracked files at HEAD 2888192: 1015.
Not read, listed one by one in the ledger with a reason:
- 353 Godot `.uid` sidecars, 36 `.import` metadata, 40 binary art/audio/archive files and 2 generated checksum/log files: skipped by category (not logic, not text).
- 476 text files unread (mostly `.gd` game source and tests for individual campaign operations, `docs/superpowers/plans/*`, `docs/repository/BRANCH_LEDGER_20261024.md` and `branches-2026-10-22.tsv`, `references/package/*`, `references/visual/*`, `.github/workflows/android-validation.yml`, `scripts/toolchain/*` other than `test.sh`, `scripts/toolchain/check-gauntlet-guidance.py` which was read, test files other than lock_warning_tests, siren_warning_pause_tests, patient_play, run_tests, combat_rules_tests, collision_boundaries_tests, all_stop_tests, campaign_debrief_view_tests, first_siren_cue_tests, fleet_instruments_ui_tests, fleet_ring_ui_tests and playfield_hud_tests). These are not claimed as read. None was found to bear on a June finding by grep or by the docs that cite them, but grep is not reading.
What was read in full and bears directly on the findings: all of `game/src/simulation/simulation.gd` (1457), the acoustic, sonar, depth, contact, order, persistence and audio sources named in the ledger, `main.gd`, `ocean_view.gd`, `mission_hud.gd`, `fleet_instruments.gd`, `fleet_ring.gd`, `campaign_flow.gd`, the first-siren-cue module, all design/process docs listed in `check-gauntlet-guidance.py`, the whole `reference/original-prototype/` text set (the 47,972 B v7 HTML itself was compared by diff, not read line by line here; it was read in full in READ_1 as the Inbox copy), and the project and export config.
Timeouts: one recursive `find` over Documents timed out (about 111 s) and was retried narrower; several device_bash calls reported "waited behind another command" and were re-run unchanged. No result depends on a timed-out command.
Method limits: static reading only. Nothing was run as a game, no Godot test was executed, no device was used. Citations are lines of the files at HEAD 2888192. Line numbers for `simulation.gd:1108-1110` and `:1142-1149` come from my chunk notes of two adjacent chunks and should be re-grepped before being quoted in code review.

## 8. The June `__sim` test hook (62, 73, then 80 keys) versus the repo

Status: SUPERSEDED by a native seam; the June key list is not carried.
- June exposed a `window.__sim` object (14 keys at Step 2 growing to 73 at Step 8 and 80 at Step 9) for a jsdom smoke harness. `git grep -i __sim` outside `reference/` returns 0 hits.
- Repo seam: `Simulation.command(order,args)` (`game/src/simulation/simulation.gd:493`), `advance(dt)` (`:719`), `snapshot()` (`:1277`), `restore(data)` (`:1284`) with `valid_snapshot` rejecting incompatible or malformed saves (`:1294-1394`), a scenario boot flag `--scenario=` (`game/src/main.gd:152-157`), and a registered headless suite list run by `scripts/toolchain/test.sh` (`game/tests/suites.txt`). Tests drive real input events and compare snapshot hashes (`first_siren_cue_tests.gd:57-64`, `fleet_instruments_ui_tests.gd:54-59`). This is a stricter replacement for the June hook, including the "test the right build" lesson (`test.sh:84-90` requires each suite's own summary line).
- Not carried: the June touch-state keys (getJoystickState, simulateTouchEvent, setTouchModeForTesting) because there is no joystick or touch-mode switch.

## 9. Final verification and coverage (supersedes sections 2, 3 and 7 where they say NOT VERIFIED or unread)

Four open items, verified against local HEAD 2888192 (files staged to the cloud container; the GitHub head f5b66a1 is a different, smaller snapshot of 333 files and does not contain 2888192, so it was not used for cites):
- Held-key echo: RESOLVED. `game/src/main.gd:451` (ESC) and `:456` (key handler) both require `not event.echo`. `sensor_orders.gd:11` also refuses a second ping while `ping_time>0`.
- Win/lose in the same tick: RESOLVED, loss wins. `simulation.gd:805-807` set `outcome="lost"` (oxygen, hull) before the extraction calls at `:808-811`. `_try_extract` (`:328-339`) needs `departure_context()`, which requires `outcome.is_empty()` (`:324`); `:810` is guarded the same way; `advance` stops looping once outcome is set (`:722`). A beam kill also sets `lost` mid-tick (`:1148`). `Departure.emit` (`foundry_departure.gd:18`) only emits noise. The June two-overlay defect cannot occur (one string, `won` cannot overwrite `lost`).
- World-edge hull hit: damage, not instant loss. `blocked()` (`simulation.gd:428`) counts any point within the craft radius of the world border as blocked; `_course_collision`/`_hull_strike` (`:239-252`) apply `collision_damage` (`:237-238`) only above COLLISION_SAFE_SPEED and at most once per COLLISION_COOLDOWN (`:248`). Instant `hull=0` exists only for the 4 s Siren beam (`:1148`).
- Recon LOS (audit row 6): split answer. Siren sight needs line of sight (`Depth.sight`, `simulation.gd:1109,1113`); legacy hearing needs `Depth.clear` (`:1110`). The player SURVEY (`sensor_orders.gd:21-24`, `simulation.gd:207`) is a 560 m disk with no LOS test (`WorldRegion.survey_visible`, `simulation.gd:1035,1046`; `signal_field.gd:15`). The Hunt meter (`recon_consequences.gd:5-14,59`) is global pressure, not a sight reveal. Photos use `photo_capture.gd` optics range 240 m (`:96`) and a terrain-hit view (`:220,240`); the through-rock question (pre-step7 7) is covered by that terrain-hit sampling, not by a separate range-only test.
The NOT VERIFIED rows (audit 6, R1 6, R2 pre-step7 5-7) are therefore closed as above.

Coverage of the 1015 tracked files:
- 108 read in full earlier by numbered literal chunks (model-visible).
- 476 text-path files read in full as literal bytes by script on 2026-11-06 (`LITREAD_SIREN_VS_REPO.tsv`: lines, bytes, encoding, NUL count, em dash count, TODO count per file). Totals: 34,785 lines, 2,635,212 bytes, matching the ledger. 474 decode as UTF-8 text. Two are binary despite being in the text list: `game/tests/fixtures/split_channel_legacy.bin` (4,387 NULs) and `scripts/toolchain/signing/sirens-song-debug.keystore`. Honest limit: for these 476 the full-file read was done by script, and I looked at the content of only the targeted files (the four-item sources plus recon, sensor, sweeper, signal-field and departure code, `campaign_consequences.gd`, and the workflow/gitignore/native-milestone sizes). I did not read every line of the 17,345 test lines or 10,350 src lines as model-visible text. A model-visible read of the rest remains open if Pat requires it.
- 431 skipped by category: 353 `.uid`, 36 `.import`, 24 `.wav`, 12 `.png`, 2 `.archive` (Godot binary variant saves, header `QUIETUS_ARCHIVE_1`), 1 `.zip` (prototype handoff), 1 `.svg` (finale_warning, 2,493 bytes of vector art), 1 `.sha256` (66 bytes, a certificate hash), 1 `.log` (`truncated-native-ui-metrics.log`, 1,097 bytes, a test fixture of UI metrics JSON). Spot checks of the log, checksum, svg and both archives found nothing that matters for the comparison.
- Ledger `READ_LEDGER_SIREN_VS_REPO.tsv` updated: statuses now full 108, full-scripted-read 474, full-scripted-read-binary 2, skipped-by-category 431, with bytes and lines per file.
- Em dashes: the 476 repo files contain 64 em dash characters (repo content, not mine); this report and ledger use none.
