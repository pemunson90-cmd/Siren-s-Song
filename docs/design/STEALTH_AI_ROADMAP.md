# Stealth AI roadmap

**AI-DESIGNED (Claude, 23 Oct 2026). Proposal for Pat's ratification. Nothing here changes the game until a phase is approved and built.**
Baseline: `claude/integration` at 1cb093f. Line numbers below are for that commit.

Pat's goal: intelligent, progressively stronger Siren AI across the campaign. Stationary sentries that wake and move, patrol routes, enemy-to-enemy communication, and several ways through each operation, in the spirit of Metal Gear, Splinter Cell and Dishonored, while keeping the core design: unlimited tactical pause, readable chart, sound is the enemy, a 4 s lock warning before the beam kills Quietus, photography about viewpoint and range, V7 Sirens with no sonar, touch-first 48 dp.

## 1. What exists today

### 1.1 Roles (`simulation/enemy_types.gd:5`, eight roles)

| Role | Behavior now | Source |
|---|---|---|
| patroller | Walks authored circuit, stands to lock on sight | `simulation.gd:1156-1170`, `sweeper_senses.gd:19` |
| sentinel | Holds post, investigates a heard spot, searches a ring, returns home (tether 160 to 190) | `_station_intent` `simulation.gd:1213-1235`, `roster.gd:15` |
| hunter | Fast (64), chases by sight (`_visual_pursuit` `:1202`), returns to post | `simulation.gd:1169` |
| sweeper | V7 senses only, ear x1.3, 20 s attention, slow walk 22, fast investigate 34, walks a lane only if authored points exist | `sweeper_senses.gd:17-22, 48` |
| buoy / relay | Passive listeners that forward a stale report (see 1.4) | `acoustic_network.gd` |
| interceptor / warden | Windup then burst or pressure patch, never the beam. Interceptor patrols only a circuit anchored at its post | `industrial_threats.gd:25-60` |

### 1.2 States and escalation
- Modes are strings: PATROL, INVESTIGATE, SEARCH, LOCKING, BEAM, RETURN, DORMANT, DISRUPTED, PINNED (plus LISTENING, BUOY CHARGING, RELAY CHARGING, BURST WINDUP and similar for the network and industrial roles). Written at `simulation.gd:1115-1170`, `:1217-1221`.
- `suspicion` (0 to 1) is a number, not a tier. It rises 0.3 on hearing a craft, 0.45 on a pulse or noise, +0.3/s while locking, and decays 0.015/s toward `alert_floor` (`:1152`). Alert speed is 48 when suspicion > 0.1, else 25 (`:1168`).
- `alert_floor` (`recon_consequences.gd:17-34`) is a persistent per-Siren ratchet raised by seeing a craft or hearing a pulse. `Recon.readiness` (`:23`) turns it into a 1.0 to 1.7 multiplier on sight radius (`simulation.gd:1108`), hearing radius (`:1113`) and +20% speed. **It is not shown on the chart or in any presentation file I found (grep: simulation and recon only). This is a hidden sense multiplier and conflicts with the readability principle below.**
- Lock: `s.lock += dt` only while the Siren sees a craft; at 4.0 the beam fires and Quietus is vaporized or a drone dies (`:1142-1148`). Without sight the lock decays 3x faster (`:1152`). `presentation/lock_warning.gd` shows a receiver-earned countdown from the first observed lock. `first_siren_cue/` (ops 1 to 3, flag `cue_table.gd:3`) adds a bearing cue when a Siren first notices a craft (`siren_notice` signal `:1129`).

### 1.3 Senses
- Sight: 290 m (180 m when the craft is `silent`) x readiness, needs a shared depth band and clear line (`:1108`, `depth_bands.gd:93`).
- Hearing: legacy path uses noise radius x ear x `Depth.transmission` (`:1122-1126`). Acoustic ops (`acoustic_revision == 1`) use `_heard_arrival` (`:1180-1200`), which returns only water-path arrivals and ambiguous branches, so Sirens can search a wrong branch. Throttle noise is `motion_radius` (`:386`); decoys, pings, camera, shutter and tools are `noises`.
- Investigation: heard spot becomes `goal`, `last_known`, `attention_time` (sweeper 20 s, others 12 s default), `search_index` walks eight points at 80 m around the spot (`:1225-1230`). Unreachable spots fall to `_search_approach` (`:1255`). Sweepers also keep a stale `listen` record (`sweeper_senses.gd:42-44`).

### 1.4 Communication: it already exists, in three narrow forms
1. **Sight report, ops 5 and 9 only** (`contact_reports.gd`, flag `contact_report_revision`, valid ids `[5,9]` at `:52`). A Siren with 2 s of continuous sight emits a charge, then one eligible peer in range 430 m (650 on op 9) over real water paths gets a coarse old position on an 80 m grid, 12 s memory, one recipient, cooldown 12 s. Cover or stun interrupts. Never live tracking. Tests: `tests/contact_reports_tests.gd` (37 checks).
2. **Listening network, ops 14 to 21, 24, 25** (`acoustic_network.gd`, `roster.gd:11` `listening_line`). Buoys hear craft motion and loud tools, charge 2 s, relay hops up to 2 (3 s charge), packet lifetime 12 s, grid 160 m. Each stage makes an audible cue (BUOY REPORT WINDUP 320/380 m, RELAY FORWARD 700 m, `:42, :49, :59`). A non-listener peer in link range switches to INVESTIGATE with up to 8 s attention (`:60-62`). Tests: `tests/glass_network_tests.gd`.
3. **Industrial evidence**: interceptor and warden consume sight, heard arrivals or current attention (`industrial_threats.gd:11-21`), so a relay report can trigger a strike.
No general shared alert, no squad state, no "calls for help" from patrollers or sentinels outside ops 5 and 9.

### 1.5 Patrol routes
- Authored circuits live on every tutorial op: `tutorial_missions.gd:104-111` (`circuits` table, ops 0 to 5, 1 to 3 Sirens each), Divergence/Onward/Resolution ops 6 to 13 use `Divergence._patrol` helpers. Test `tests/patrol_scenarios.gd` asserts each Siren has 3+ reachable points or is a stationary sweeper.
- `_patrol_route` (`simulation.gd:1236-1254`) round-robins `patrol_points`, skips points within 35 m, validates with `path()`, and falls back to procedural rings around home for legacy saves. Dwell time is zero; it re-plans every 2 s.
- Sweepers in `opening_depth_operations.gd:62-66` and `shelf_signal_operation.gd:13` have `patrol_points=[]`, so they stand still. Lane-walking for sweepers exists in code (`walks_lane`, `sweeper_senses.gd:35-38`) and is waiting on authored points (Directive: "sweeper lane-walking deferred"; Pat's request: Phase A in flight).
- Sentinel `roster.post()` writes three patrol points but `walks_lane` ignores them for sentinels, so they are inert data.

### 1.6 Difficulty by operation
There is no difficulty table. Strength comes only from authored rosters (op ids are 0 to 29, 30 operations):

| Ops | Roster (from source) |
|---|---|
| 0 to 3 | 1 to 2 patrollers, op 3 two sentinels, op 0 plus 1 stationary deep sweeper, ops 1 to 2 patrollers split across bands (`opening_depth_operations.gd` PROFILES) |
| 4, 5 | 3 Sirens: patroller, hunter (op 4), 3 patrollers (op 5, with sight reports) plus a deep sweeper each |
| 6 to 13 | 2 to 3 Sirens: patroller plus sentinel or hunter |
| 14 to 21 | Glass Reach: sentinel post, buoy/relay listening line, hunter or sweeper, warden from 17, interceptor on 19 and 20 (`glass_reach_operations.gd:63-201`) |
| 22 to 29 | Iron Choir: 2 to 3 interceptors, a warden, relay on 24 and 25 (`iron_layouts.gd:53-63`) |
Roster helpers are only 16 lines (`encounters/roster.gd`). Pressure also comes from `Recon` hunt value and `alert_floor` (hidden).

### 1.7 Route variety for the player
- Three depth bands (`depth_bands.gd:3-5`, 4 s transition occupying both bands), per-band authored rock overrides (`opening_depth_operations.gd` `bands`). Sirens live in one band and cannot see across bands.
- Quiet play: `silent` craft sight 180 vs 290; `AllStop` coast (`all_stop/`); drone quiet speed 42 (`tuning.gd:15`); unlimited pause and queued routes (`route_program.gd`).
- Tools (`simulation.gd:98`, `tuning.gd`): decoy x3 (1100 m, 15 s, placed within 160 m), EMP x2 (radius 340, stun 12 s), knockdown torpedo x2 (8 s pin), RECON x2, relay playback (240 m).
- Terrain: currents (`current_field.gd`), thermal fronts on ops 3, 8, 16, 25 (`thermal_front.gd`), gates and sluices that open noisily (`warning_recipient.gd` `_open`), named recovery corridors, cover rocks.

### 1.8 Debug and telemetry for AI
- Deterministic, headless: `Simulation.snapshot()/restore()` plus `advance(dt)` loops (`tests/patient_play.gd` rehearses a manoeuvre on a copy and fails if a Siren would reach LOCKING or BEAM).
- Scenario suites: `sweeper_scenarios.gd` (34 checks), `patrol_scenarios.gd`, `siren_role_scenarios.gd`, `attention_scenarios.gd`, `lock_warning_tests.gd`, `siren_warning_pause_tests.gd`, `industrial_threats_tests.gd`, `contact_reports_tests.gd`, per-region `*_journeys.gd`. Registered in `tests/suites.txt`.
- Observers: `siren_notice` signal, `NoticeTracker` (read-only), `capture_siren_roles.gd` screenshots, `metrics_transport.gd` (UI metrics over logcat).
- Missing: no AI event log (state transitions with time), no time-to-detection metric, no "why did this Siren move" trace, no in-game debug overlay of Siren state.

### 1.9 Docs checked
`docs/FUTURE_OPTIONS.md` (only the preserved active-sonar sweeper, a hard mod, explicitly not current spec). `CURRENT_GAME_SPEC.md` lines 19, 71 to 78 (fair perception, stale information, no omniscient queries, "enemy intelligence" as a benchmark axis). `USER_DIRECTIVES.md` lines 9 to 16 and 33 to 41 (D1 first-Siren cue, "SIREN TELL waits until after the sweeper rebuild", "Sirens may NOT be studied from a band other than their own", standing delegation and engineering rule). `PHOTO_RECON.md` (patrol loops feed photo timing windows). No SIREN TELL design exists in the repository beyond those mentions; it is undefined. No `docs/design/*` existed before this file.

## 2. Pat's wish list against reality

| Wish | Today | Gap |
|---|---|---|
| Stationary sentries that wake and move | Sentinel investigates, searches, returns (DORMANT). Hunter chases. Sweeper (standing) investigates | No visible "waking" step; stationary sweepers never patrol; sentinels cannot walk their authored points |
| Patrol routes | Authored circuits on most patrollers, round-robin | No dwell, no look-around, no timed or branching routes, no route variety per difficulty |
| Alert tiers with search | One float plus mode strings plus hidden `alert_floor` | Tiers are implicit and partly invisible; search is a fixed 8-point ring |
| Communication | Sight report (ops 5, 9), buoy/relay network (14 to 25) | Not available to patrollers and sentinels elsewhere; no visible link; limited counterplay beyond stun and cover |
| Route opportunities | Bands, tools, currents, fronts, gates | No per-op design rule; no timed windows tied to patrols; no cost-bearing shortcuts as a pattern |
| Progressive strength | Authored rosters | No curve table, no stated intro order for behaviors |
| AI testing | Strong scenario tests | No telemetry on detection time or fairness |

## 3. Design principles (these protect the core)
1. **Readable first.** Every AI state change must have a chart mark or a sound the player can receive through the existing physics (bearing cue, mode label on a contact, windup noise). If a Siren could behave differently and the player cannot tell, do not ship it. The hidden `alert_floor` multiplier must become visible before any tier work builds on it.
2. **Fair via the 4 s lock.** New behaviors may change how a Siren gets to sight, never the lock rule. No instant detection, no beam shortcut, no new damage. Any new approach must leave a player at least one pause window with the warning visible before a lock can start.
3. **No hidden senses.** Sirens use sight and hearing exactly as today (V7: no sonar, no omniscient queries). Reports carry coarse, stale points, never live targets (as `contact_reports.gd:1-4` already states).
4. **Everything off-switchable.** One flag per module in a data table, a revert note in the file header, behavior identical to today when off.
5. **Deterministic.** No random calls in AI choices; use patrol index, elapsed time and the existing `Acoustics.choose(..., patrol)` pattern so scripted tests and save/restore replay exactly.
6. **Early ops stay gentle.** Ops 0 to 5 get only readable, forgiving behavior; new tiers of mind arrive one at a time.
7. **Standing engineering rule** (USER_DIRECTIVES): one module, one narrow seam, tables not conditionals, optional validated save fields, tests beside the feature.
8. **Touch-first.** Any new indicator or control is at least 48 dp and has no hover or keyboard-only path; pause explains it.

## 4. Phased roadmap
Each phase is a new small module (folder under `simulation/` or `presentation/`) with one seam, a data table, optional validated save fields, a flag, tests, and a revert note. Order is by dependency. Owner is a suggestion; the engine seams in `simulation.gd` threat loop are shared, so only one phase edits them at a time.

| Phase | Module | Size | Owner | Needs Pat |
|---|---|---|---|---|
| A | Patrol circuits for sweepers and sentinels | S | Claude (in flight) | No |
| B | Alert tiers with indicators | M | Claude (design), Codex (tests) | Yes, readiness visibility |
| C | Stationary sentries that investigate and return | M | Codex | No (inside B's tiers) |
| D | Alert sharing with delay, range and a visible signal | L | Claude | Yes |
| E | Difficulty curve for ops 0 to 29 | M | Claude | Yes (numbers by feel) |
| F | Route opportunity design per op | L, content | Claude then Codex content | Partly |
| G | Telemetry and debug overlay | S to M | Codex, can start now | No |

Recommended build order: G first (measuring tools), then A, B, C, D, E, F. G is independent and makes every later phase testable.

### Phase A: patrol circuits for existing sweepers (already in flight)
- Author `patrol_points` for the sweepers in `opening_depth_operations.gd` PROFILES and `shelf_signal_operation.gd`. Code path already exists (`walks_lane`). Keep speed 22.
- Data: points per op in the profile tables; extend `patrol_scenarios.gd` (which already allows "3+ points or stationary sweeper") to assert reachability, band and clearance for sweepers.
- Add optional dwell: `{pos, wait_s}` points in a table; default wait 0 so behavior is unchanged. Sentinel `post()` points either get used (walks_lane for tethered sentinel, short loop inside tether) or removed from the data; decide with C.
- Risk: patrol paths feed `photo_rules/loop_clock.gd` timing windows; re-run photo window tests.

### Phase B: alert tiers with visible indicators
- A pure function `tier(siren)` in `simulation/alert_tiers/` that maps existing state to five names: UNAWARE (PATROL/DORMANT, no suspicion), SUSPICIOUS (suspicion > 0.1 or INVESTIGATE start), SEARCHING (attention window running after reaching the spot), ALERTED (LOCKING or BEAM, or last seen under sight), RETURNING (RETURN). No change in simulation behavior: the first version only labels.
- Presentation: tier shown on contacts the player has earned (same rule as existing contact modes, `contact_feedback.gd`): a small glyph plus word, never colour alone, plus the existing lock countdown. Hearing a Siren's call or a muted cue per tier up (bearing only, like D1).
- Make `alert_floor`/`readiness` visible: show a "wary" mark on a Siren whose floor has risen, so the player can see why a Siren notices farther.
- Data table: thresholds and glyphs. Save: derive from existing fields; no new save field in v1.
- Tests: scripted transitions (hear, search, lose, return) assert the tier sequence and that no tier skip happens within one tick.
- Needs Pat: whether `readiness` stays (the player can see it, but it is a sense change that is currently invisible).

### Phase C: stationary sentries that investigate and walk back
- New behavior state "WAKE" for sentinel, sweeper (stationary) and warden-adjacent posts: on first heard craft, the Siren turns toward the bearing for a visible beat (1.5 s, pausable) before moving; moves along `path()` to the spot; searches; returns to `home`.
- Reuse `_station_intent` pieces: 8-point ring, `attention_time`, tether. Replace the fixed ring with a table of search patterns by role (ring, sweep arc, corridor sweep). All deterministic by `search_index`.
- Leash: the tether stays conditional (as now), and a "give up" rule returns the Siren after a table-defined time so a post never abandons its job permanently.
- Optional save field: `wake` {phase, t}, validated like `sweeper_senses.valid`. Absent means idle.
- Tests: scripted decoy at several ranges yields wake, move, search, return; the Siren never leaves tether when nothing is heard; a stun mid-wake resets cleanly.

### Phase D: alert sharing between Sirens
- Generalize the existing sight-report (ops 5 and 9) and the buoy/relay packet into one module `simulation/alert_share/` driven by a table: sender roles, range, charge time, delay, hop limit, memory, content (coarse stale point only), cooldown.
- Always visible: a charge mark on the sender (aligned with the 2 s charge already in `contact_reports.gd`), an audible "call" cue with bearing for the player if the physics lets the sound reach them, and a line on the chart for a delivered report that fades. No hidden recipients.
- Counterplay with existing tools: break line of sight inside the charge; EMP, knockdown or stun the sender (clears the charge, as `contact_reports.gd:25-26` does); break the water path with rock, depth band or a thermal front (`band_acoustics.arrivals` and `Depth.transmission` already gate delivery); decoy to spoof a point (a report built from a heard decoy carries the decoy's grid cell, so the player can pull search away); cut the relay (stun).
- Rules: one recipient per report, no chaining beyond the hop limit, no recipient already in `fresh` sensing, order independent (resolve after all turns, like `contact_reports.gd:33-35`).
- Save: `report` and `report_interest` already validated; extend with a per-mission `alert_share_revision` flag. Old saves have none.
- Needs Pat: yes, this is a Siren awareness rule that is not already approved (standing delegation lists Siren sight/hearing changes as Pat's).

### Phase E: progressive difficulty curve, ops 0 to 29
Add `campaign/difficulty_curve.gd`: one table from op id to enabled behaviors, so authors tune strength in one place instead of per-op code. Proposed introduction order (all numbers are placeholders for Pat):
| Ops | Adds |
|---|---|
| 0 to 3 | Phase A circuits, tier labels (B), D1 cue; sentinels wake slowly (C, long wake beat); no sharing |
| 4 to 5 | hunter, sight report on op 5 as today, first short-range call cue (D, 1 hop) |
| 6 to 9 | sentinel search patterns, patroller dwell and look-around, op 9 sharing as today |
| 10 to 13 | sharing between patrol and sentinel pairs, shorter wake beat, readiness visible |
| 14 to 21 | buoy/relay networks keep their forms; patrol pairs share; sweeper lanes; searches branch |
| 22 to 29 | industrial roles; shared alerts across stations with visible relays; fastest but never faster than the 4 s lock window |
Hard limits for the table: the beam rule never changes; sight and hearing radii stay at today's values (`readiness` visible); the earliest a new behavior can appear is stated, never silently added to an op that already shipped.

### Phase F: route opportunity design per op
Per-op authored checklist, then content passes in groups of four ops:
- **Lanes**: vent/current lanes (use `current_field`), thermal-front lanes (existing fronts on 3, 8, 16, 25; add a few), depth-band lanes (per-band rock overrides), cover rocks and gates. Each op documents three route families: quiet-slow, band-shift, and tool-assisted.
- **Timed windows**: patrol dwell from Phase A and circuit period give a published gap; decoy windows from the 15 s decoy; EMP windows from the 12 s stun.
- **Shortcuts that cost**: noisy sluice or gate (`_open` pattern: 650 m noise, 6 s), oxygen cost for deep, film cost for tele range, battery for drones.
- **Design checklist** (genre practice): (1) at least two viable solutions that differ in risk, time or resource, (2) every patrol is observable from safe water before committing (on chart or by sound), (3) risk and reward scale together, (4) no unavoidable detection: a stationary Quietus with all tools unused can always reach a pause-and-plan state, (5) failure states teach (the lock warning, tier labels and debrief cause line say why), (6) each tool has a role on that op but none is required, (7) a quiet no-tools route exists for core objectives (spec: baseline-fleet completion), (8) optional objectives can demand mastery, core cannot.
- Tests: for each op a scripted "quiet route" and "band route" journey with `patient_play` asserting completion without a lock.
- Needs Pat: new layouts that alter story spaces or recovery corridors; terrain changes inside ops with story beats.

### Phase G: telemetry and debug (start now)
- `diagnostics/ai_trace.gd` (read-only observer, mirrors `NoticeTracker`): ring buffer of per-Siren state changes `{t, id, role, from, to, cause}` where cause is sight, sound label, report, decoy, stun, timer.
- Derived metrics: time from first notice to LOCKING, time from lock start to beam, number of Sirens woken per op, unmet-warning count (a lock that began without a prior cue). Export through the existing logcat path in `metrics_transport.gd`.
- Debug overlay behind a flag, off in release: Siren tier, goal, `attention_time`, route, `alert_floor`. The same data later powers Phase B's player-facing marks.
- Tests: trace never writes simulation state; identical run twice yields identical trace.

## 5. Test strategy
- **Scripted scenarios** for each behavior (hear, wake, search, return, report, stun interrupt), asserting the exact tier sequence and timestamps with `advance(1/60)` loops and fixed seeds (no randomness).
- **Journeys with `patient_play`**: per-op quiet route and band route complete with no BEAM; rehearsal gates every surfacing.
- **Fairness assertions** (new, shared helper): (a) lock never starts without the lock-warning frame being available the same tick (`lock_warning.frames`); (b) from first notice to beam, a stationary pauseable window is at least 4 s; (c) a report never carries a live target (`contact_reports_tests` already checks); (d) a Siren seeing no craft never reaches LOCKING.
- **Telemetry thresholds**: per-op median and p95 time-to-detection on the scripted routes, recorded in a table; a change that moves them beyond a tolerance fails CI and needs a note.
- **Save**: old-save restore test per new optional field (absent field equals today's behavior), plus corruption cases like `ContactReports.valid`.
- **Performance**: a stress scene with 12 Sirens and all modules on, 60 s simulated, asserting per-tick cost under a budget; run on the phone-class profile when Pat enables device tests.
- Add each suite to `tests/suites.txt` (append, keep ranks).

## 6. Decisions
**Pat decides (not covered by standing delegation):**
- Anything touching Siren sight or hearing radii, the `readiness` multiplier (Phase B), or new sharing between Sirens (Phase D).
- Lock timing, beam, damage, hull or collision rules (this plan changes none; any request to would stop and ask).
- SIREN TELL: undefined in the repo; it waits (directive 22 Oct). Phase B indicators and Phase D calls are the closest overlap, so Pat should say whether SIREN TELL is one of them or separate.
- Story, characters, endings, and any layout that moves a story recovery space.
- The numbers in Phase E (difficulty by feel), because he plays the result.
- Whether Sirens may ever get active sonar (stays in `FUTURE_OPTIONS.md`, hard-mod option).

**Proceeds under standing delegation (ordinary implementation, behavior-preserving or additive):** Phase G entirely, Phase A, Phase B labelling without a rules change, Phase C inside the existing tether and investigation rules, tests, data tables, flags, save validators, docs, content authoring that keeps core objectives finishable bare.

## 7. Risks
- **Balance drift**: stacked behaviors multiply difficulty. Mitigation: one flag per module, curve table, telemetry thresholds, ship one behavior per op group.
- **Readability**: more states can become noise. Mitigation: principle 1, one glyph set, pause explains states, never colour alone, tested at 48 dp.
- **Hidden `alert_floor` multiplier** already breaks readability; fix first (Phase B).
- **Phone performance**: path() calls every 2 s per Siren and the acoustic arrivals are the hot spots. Mitigation: reuse `path_time` throttles, cache per-tick arrivals, stress test, no per-frame allocations in new modules.
- **Save compatibility**: new fields optional and validated, absent equals old behavior, no renumbering of `Sirens` array indexes (reports use sender indexes).
- **Photo coupling**: patrol dwell and route changes move photo windows (`photo_rules/loop_clock.gd`); re-run photo and PHOTO_RECON tests with every circuit edit.
- **Array-order effects**: sharing must resolve after all Sirens sense (pattern in `contact_reports.gd:33`).
- **Scope**: Metal Gear and Dishonored breadth can sprawl. Keep to "Output over infrastructure": each phase ships a playable difference on a named op.
