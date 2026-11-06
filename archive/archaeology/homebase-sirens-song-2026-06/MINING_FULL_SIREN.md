# MINING_FULL_SIREN

Archive folder: `_archive/archaeology-staging/Siren-s-Song/homebase-sirens-song-2026-06`
Compared against ACTIVE repo: `Claude Code Homebase C/siren-s-song` at HEAD 2888192 (PR #112, 2026-10-23).
Companion file: `READ_LEDGER_SIREN.tsv` (one row per file, method and status).
Convention: file names in backticks are the source of the claim. "Inferred" marks my own reading, not a stated fact.

## 1. Coverage statement with counts

Scope: 68 files in the archive folder, plus `Siren-s-Song/README.md` one level up. Total 69 ledger rows.

| Status | Count | What it means |
|---|---|---|
| full | 59 | Whole file read (large files in line-range or byte chunks, with gaps found and re-read). |
| full-by-diff | 9 | 8 `code/sirens_song.html.bak.*` files read through a consecutive diff chain, plus `sirens_song_prototype_v7.html` read as a full diff against the fully read `sirens_song_prototype.html`. |
| full-byte-identical | 1 | `code/sirens_song.html.bak.pre-step9-refire-20260605` is byte-identical to `...bak.pre-step9-20260605` (cmp). |
| unreadable | 0 | Nothing was unreadable. |

Verification:
- `sha256sum -c SHA256SUMS.txt`: 66 hashed entries all OK. The other 2 files on disk are `MINING_REPORT.md` and `SHA256SUMS.txt` itself.
- Ledger paths match a `find -type f` of the folder exactly (no missing, no extra).
- `code/sirens_song.html` (147,438 B, 3,462 lines, md5 477469ef51d2a0876df13d009e7cd610) was read in line-range chunks. A first pass left gaps at lines 331-585 and 1279-1335; both were re-read.
- Diff-chain method for baks: each consecutive pair's removed lines were dumped. Together with the fully read final file, this covers every line that ever existed in the chain. It is not a literal cat of each bak. The ledger says so per row.
- Existing files were not modified. Both deliverables are new.

Repo side (NOT full read, stated plainly):
- Checked by `git grep` at HEAD 2888192 (1,015 tracked files, 324 branches). Terms searched: itch.io, Cowork, homebase, daisy, hasActiveDetector, hull-sink, shadowPoly, shadow cone, graze, smoke_test, jsdom, INSTAKILL, stationary, monetiz, Deep Contact, kill rule, silent running, ALL-STOP, acoustic shadow, HOSTILE, decay.
- Read directly (whole or the relevant part): the `reference/original-prototype/` set, MANIFEST (gap list), SOURCE_AUTHORITY, repo AGENTS.md, STORY_BIBLE_DRAFT, USER_DIRECTIVES, the parity ledger rows, `game/src/tuning.gd`, `game/src/campaign/endurance_budgets.gd`, `game/src/simulation/observed_stun.gd` (first 8 lines).
- Read only by keyword or line: CURRENT_GAME_SPEC, the design bible (line 66 and neighbors), STEALTH_AI_ROADMAP, other docs. Any "repo resolved it" call below that rests on keyword hits is marked "unverified" in the table.
- The reference copies of the md/spec files match the archive Inbox copies modulo CRLF, and the repo MANIFEST md5s match the Inbox md/spec hashes. `reference/original-prototype/history/sirens_song_prototype.html` is identical to the Inbox v6 modulo CRLF.

How each "not in repo" claim was checked: `git grep -n -i -E '<term>'` over the whole tracked tree at HEAD 2888192. A claim of "zero hits" means that command returned nothing. Zero hits does not prove the idea is absent under a different name; where that matters I say so.

## 2. Unique value to promote

Ordered by how much the repo lacks it. Nothing here is promoted automatically; Pat rules first.

### 2.1 The 90-constant tuning table (June HTML build line)

Source: `handoffs/07_HANDOFF_FROM_STEP7.md` roll-up table plus the TUNING block at `code/sirens_song.html` lines 245-556.

Count facts, because three documents disagree:
- `handoffs/07_HANDOFF_FROM_STEP7.md` labels its roll-up "90" but the table has 89 rows.
- The Step 8 code TUNING (`code/sirens_song.html.bak.pre-step9-20260605`) has exactly 90 keys. The one key missing from the table is `DECOY_TOGGLE_KEY_HINT`, a UI string ("B"). So "90" is accurate for the code.
- The final `code/sirens_song.html` has 93 keys. Step 9 added `NOISE_GAIN`, `NOISE_HEAR_MAX`, `SILENT_BIND_KEY`.
- `handoffs/09_HANDOFF_FROM_STEP9.md` claims 99 to 102. That is wrong by 9 (actual 90 to 93).

Values in the final build (93 keys). Step 7 changed three: OXYGEN 240 to 210, Hunter pursue 90 to 75, recon radius 400 to 460 (`handoffs/07_HANDOFF_FROM_STEP7.md`).

Substrate and sub:
HULL_MAX 3; OXYGEN_MAX_SECONDS 210; SUB_SPEED_PX_PER_SEC 80; SUB_TURN_RATE_RAD_PER_SEC 1.8; PING_DURATION_SEC 3.0; PING_RADIUS_PX 360; PASSIVE_RADIUS_PX 90; HULL_HIT_COOLDOWN_SEC 0.6; SUB_RADIUS_PX 8.

Inertia (fix-pass, `handoffs/01_FIXPASS_HANDOFF_20260604.md`; all flagged for step 7 tuning):
SUB_LINEAR_ACCEL_PX_PER_SEC2 60; SUB_REVERSE_ACCEL_MULT 0.5; SUB_LINEAR_DRAG_PER_SEC 0.45; SUB_TURN_ACCEL_RAD_PER_SEC2 2.6; SUB_TURN_DRAG_PER_SEC 2.0.

Suspicion:
SUSP_MIN 0; SUSP_MAX 100; SUSP_PING_COST 25; SUSP_DECAY_PER_SEC 5; THRESH_ALERT 34; THRESH_HOSTILE 75; WARNING_THRESHOLD 75; INSTAKILL_SUSTAIN_SEC 4.0.

Patroller:
PATROL_SPEED_PX_PER_SEC 40; PATROL_ALERT_SPEED_MULT 1.6; PATROL_WAYPOINT_TOLERANCE_PX 6; PATROL_RADIUS_PX 14; PATROL_RAM_HULL_DMG 1; PATROL_DEVIATION_REACH_PX 60.

Drones and camera:
DRONE_SUPPLY_INITIAL 5; DRONE_PHOTO_COST 15; DRONE_SPEED_PX_PER_SEC 110; DRONE_VISION_RADIUS_PX 120; DRONE_RADIUS_PX 5; DRONE_PHOTO_RANGE_PX 90; DRONE_ARRIVAL_TOLERANCE_PX 4; DRONE_SIREN_BONUS_RANGE_PX 100; SUBCAM_PHOTO_RANGE_PX 70; SUBCAM_SILHOUETTE_RANGE_PX 320.

Factory proximity and extraction:
FACTORY_PROX_NEAR_PX 140; FACTORY_PROX_MID_PX 260; FACTORY_PROX_FAR_PX 420; FACTORY_PROX_NEAR_RATE 3; FACTORY_PROX_MID_RATE 2; FACTORY_PROX_FAR_RATE 1; EXTRACTION_RADIUS_PX 30.

Sentinel:
SENTINEL_ORBIT_CENTER_X 855; SENTINEL_ORBIT_CENTER_Y 410; SENTINEL_ORBIT_RADIUS_PX 40; SENTINEL_ORBIT_SPEED_RAD_PER_SEC 0.45; SENTINEL_DETECT_RADIUS_PX 220; SENTINEL_RADIUS_PX 16; SENTINEL_RAM_HULL_DMG 1; SENTINEL_PROXIMITY_RANGE_PX 240; SENTINEL_PROXIMITY_MAX_RATE 2.0; SENTINEL_CURIOUS_SPEED_PX_PER_SEC 24; SENTINEL_ALERT_SPEED_PX_PER_SEC 55; SENTINEL_RETURN_TOLERANCE_PX 30.

Hunter:
HUNTER_DORMANT_X 200; HUNTER_DORMANT_Y 60; HUNTER_RADIUS_PX 12; HUNTER_PURSUE_SPEED_PX_PER_SEC 75; HUNTER_RAM_HULL_DMG 1; HUNTER_PROXIMITY_RANGE_PX 200; HUNTER_PROXIMITY_MAX_RATE 2.0; HUNTER_CURIOUS_SPEED_PX_PER_SEC 22; HUNTER_RETURN_ACTIVE true.

Curiosity and decoy:
CURIOSITY_REACH_PX 35; CURIOSITY_PING_RANGE_PX 360; CURIOSITY_PASSIVE_DECOY_RANGE_PX 180; CURIOSITY_ACTIVE_DECOY_RANGE_PX 320; CURIOSITY_PATROLLER_SPEED_PX_PER_SEC 28; DECOY_ACTIVE_WEIGHT 2.0; DECOY_TOGGLE_KEY_HINT "B".

Disruption tools and recon:
JAM_CHARGES_INITIAL 3; EMP_CHARGES_INITIAL 3; KNOCKDOWN_CHARGES_INITIAL 2; JAM_SUSP_COST 5; EMP_SUSP_COST 20; KNOCKDOWN_SUSP_COST 20; JAM_WINDOW_SEC 4.0; EMP_DURATION_SEC 5.0; KNOCKDOWN_DURATION_SEC 12.0; JAM_EFFECT_PROX_MULT 0.5; TARGET_PICK_RADIUS_PX 90; PROJECTILE_SPEED_PX_PER_SEC 360; PROJECTILE_RADIUS_PX 3; RECON_CHARGES_INITIAL 2; RECON_SUSP_COST 8; RECON_DURATION_SEC 8.0; RECON_REVEAL_RADIUS_PX 460.

Step 9 additions:
NOISE_GAIN 4.5; NOISE_HEAR_MAX 360; SILENT_BIND_KEY "Digit5".

Hidden constants NOT in TUNING (found by reading the code): Patroller proximity range is `PATROL_RADIUS_PX + 180` (194 px) with a hardcoded max rate 1.5 (`code/sirens_song.html`). Mobile UI placeholders (deadzone 0.22, axis threshold 0.35, sizes 22vmin) live in `handoffs/08_HANDOFF_FROM_STEP8.md`.

Second tuning set, claude.ai track: v6 final values in `SIRENS_SONG_dev_notes.md` (maxSpeed 96, passiveR 130, pingMax 520, EMP area 150 for 3.2 s, decay 3/s with a 1.8 s delay, killHold 3.5 s, about 220 s oxygen), and v7 values in `sirens_song_prototype_v7.html` (huntTime 0.2, stage multipliers 1.0/1.15/1.3/1.5/1.7, arriveR 220, oxygen 300, drone vision 120, graze 20 hull with 1.5 s delay and 3 s cooldown). These are in the repo's `reference/original-prototype/` too, so they are preserved there.

Repo comparison: `game/src/tuning.gd` is 770 B and holds order constants (EMP_RADIUS 340, EMP_STUN 12, DECOY_TIME 15, RECON_TIME 8). It does not contain the June table. `game/src/campaign/endurance_budgets.gd` line 4 holds a per-level OXYGEN_SECONDS array from 180 to 840. The June table is therefore not in the repo as a table. Checked: `git grep -n -E 'SUSP_PING_COST|THRESH_ALERT|INSTAKILL_SUSTAIN'` (no June constant names carried over; repeat this grep before relying on it).

### 2.2 The stationary-sub finding

Sources: `audits/07_AUDIT_STEP_07.md`, `handoffs/07_HANDOFF_FROM_STEP7.md` (pothole 1).
- A literally stationary sub under the brief-07 aggression scenario hull-sinks at about 8.4 s with max suspicion about 87.7. It never reaches 100, so the 4 s sustain kill does not fire; the Hunter's rams kill the hull instead.
- The active-aggression case (player keeps pinging or moving in) vaporizes at about 3.9 to 4.1 s.
- Audit 07 offered lowering Hunter speed to 60-65 and left the call as a Pat ruling. No ruling is recorded anywhere in the archive.
- `audits/09_AUDIT_STEP_09_REFIRE.md` edge case 1 blames oxygen for the stationary case. That is wrong; the 07 audit shows hull-sink at about 8.4 s, long before the oxygen budget matters.
- Step 9 added silent running (`Digit5`) which freezes the sub (`vx`, `vy`, `angularVel` zeroed) in `_step9_refire_patch.py`. This makes "stationary" a deliberate player state, which sharpens the finding.
- Repo: `git grep -n -i stationary` returns only unrelated hits (sweeper, depth-band transitions, and FUTURE_OPTIONS line 13 about a stationary Quietus in the beam-echo model). Lethality in the repo is a 4 s beam lock (`recon_consequences.gd`, `sweeper_senses.gd`), so the June scenario cannot occur as written. Whether the beam-lock model has an equivalent "sit still and get found" case was not tested.

### 2.3 Audit verdicts

| File | Verdict |
|---|---|
| `audits/01_AUDIT_STEP_01.md` to `audits/08_AUDIT_STEP_08.md` | GREENLIGHT (each) |
| `audits/09_AUDIT_STEP_09.md` | RED (truncated build, rolled back) |
| `audits/09_AUDIT_STEP_09_REFIRE.md` | YELLOW (build 147,438 B, md5 477469ef...) |

Verdict vocabulary in `briefs/AUDITOR_BRIEF.md`: GREENLIGHT, FIX REQUIRED, PAT INTERVENTION, RED.

### 2.4 Design rules

From `agent.md`, `SIRENS_SONG_SPEC.md`, `claude_index.md`:
1. No enemy HP and no player kill-path.
2. Suspicion is the spine.
3. Perceiving costs.
4. Tools buy time and cost heat.
5. Fairness valve mandatory.
6. Function before form.

Notes:
- `SIRENS_SONG_functional_spec.md` (v0.3) lists SEVEN invariants (adds the audio/noise core and the kill rule). `research/CLAUDE_AI_INBOX_ANALYSIS_20260605.md` says "the same six". That is wrong.
- Rule 1 as written ("no player kill-path") is in tension with v0.3's kill rule. The June build resolved it as: kill only when suspicion has been at 100 for 4.0 s AND a detector is active (`hasActiveDetector`, Step 9 pull; timer pauses with no detector, it does not reset) per `briefs/09_v03_pullin_patch.md` and `SIRENS_SONG_SPEC_STEP9_PATCH.md`.

Pat's hard rulings that act as design rules:
- Decoys work both passively and active: `briefs/04_sentinel_hunter_curiosity.md`.
- Passive AND active reveal must be terrain-occluded (LOS): Pat diagnostics 2026-06-03 in `briefs/01_sub_sonar_terrain.md`; submarine "feel" diagnostics in the same file.
- Single file, landscape, desktop path byte-equivalent, touch OR keyboard+mouse: `briefs/08_mobile_controls.md`, `ORCHESTRATOR_COMPLETE_STEP8.md`. Byte-equivalence proof: JS md5 d64857726e8bb74b0f3f5c5bd6770621 with Step 8 blocks stripped, `audits/08_AUDIT_STEP_08.md`.
- Recon is not LOS-gated: `audits/06_AUDIT_STEP_06.md`.
- Stun gate placed at the top of every update path; stun maps store deadlines: `audits/05_AUDIT_STEP_05.md`.
- Valve resets at suspicion below 100 (a stricter reading, below 75, is a one-line change logged for step 7): `audits/02_AUDIT_STEP_02.md`.
- Shadow cones cover TERRAIN rects only, not the factory: `_step9_refire_patch.py`.
- Speed-as-noise (NOISE_GAIN 4.5, NOISE_HEAR_MAX 360) plus silent running: `handoffs/09_HANDOFF_FROM_STEP9.md`.

Repo has equivalents: speed-squared hearing (2 files), ALL-STOP module `game/src/simulation/all_stop/`, rendered acoustic shadows (`game/src/**/ocean_view.gd:296`, "Sonar rays stop at actual cover, producing explicit acoustic shadows"). The repo does not carry the six or seven invariants as such (not searched by number; inferred from the authority list in AGENTS.md).

### 2.5 Story rulings

Source: `SIRENS_SONG_functional_spec.md` and `sirens_song_prototype.html` (v6 title), `SIRENS_SONG_dev_notes.md`.
- Briefing frame: USS Quietus.
- Log text 1: "...thermal band at mid-depth blinds their sensors. Hide in the cold if you must."
- Log text 2: "This was never reconnaissance. Command wants confirmation, not a pilot back. Run quiet anyway."
- Win text: "you were never meant to come back".
- Intel grades A/B/C.
- No story ruling by Pat for the June HTML build line itself was found in the briefs or handoffs; the text above is claude.ai-track authored content (provenance: AI-authored in the claude.ai track; Pat's ratification of the exact wording is not recorded in any archive file).

Repo position (read): STORY_BIBLE_DRAFT, provisionally approved 2026-10-21, is a rescue arc with human survivors. USER_DIRECTIVES (21 Oct) says "Do not author new narrative text" and rejects the Siren-evacuation / human-fleet arc as unratified AI fabrication. Repo premise (22 Oct): Quietus is a military photographic recon vessel; rescue added later. See section 6.

### 2.6 Distribution advice

Source: `research/GENRE_AND_MONETIZATION_RESEARCH.md`, `PROJECT_CONTEXT.md`.
- Stack: itch.io pay-what-you-want, Patreon, Ko-fi, Poki/CrazyGames web portals. No Steam in 2026. No native mobile.
- IP cautions: avoid humanoid or female-coded Sirens and Subnautica-like silhouettes; run a USPTO search before Steam.
- Title hedges: Deep Contact, The Quiet Depth, Below Listening, Aphotic.
- That document refers to "Section 2.7 thermocline"; no separate 2.7 exists (thermocline is in 2.6).
- Conflict with repo: section 6.

### 2.7 Other pullable items (each cited)

- Four-pull Step 9 design (hasActiveDetector gate, shadowPolyForRect, procedural Web Audio `AU`, speed-as-noise plus silent running): `briefs/09_v03_pullin_patch.md`, `SIRENS_SONG_SPEC_STEP9_PATCH.md`. Repo already has ALL-STOP, speed-squared hearing, acoustic shadows (checked by `git grep`).
- `__sim` harness idea: 73 keys at Step 8 (62 to 73, `handoffs/08_HANDOFF_FROM_STEP8.md`), 7 added at Step 9 (not 8, see section 5).
- The process pattern (brief, handoff, audit per step; auditor with RED/YELLOW/GREENLIGHT) in `briefs/AUDITOR_BRIEF.md` and `ORCHESTRATOR_LOG.md`.

## 3. Audit finding resolution table

Resolution key: RESOLVED (repo changed and the finding no longer applies in a verified way), SUPERSEDED (the thing audited no longer exists in the repo's design or engine), DROPPED (never carried; no trace in repo), OPEN (no ruling recorded anywhere), N/A-DOC (a documentation error in the archive only). "Unverified" means I relied on keyword hits.

| # | Finding | Source file | Repo status | Basis |
|---|---|---|---|---|
| 1 | Stationary sub hull-sinks at about 8.4 s, max susp about 87.7 (pothole 1); Hunter speed 60-65 offered | `audits/07_AUDIT_STEP_07.md`, `handoffs/07_HANDOFF_FROM_STEP7.md` | SUPERSEDED (lethality is a 4 s beam lock); equivalent scenario untested | `git grep -i stationary` unrelated hits only; `recon_consequences.gd`, `sweeper_senses.gd` |
| 2 | Valve reset at <100 vs stricter <75, deferred to step 7 | `audits/02_AUDIT_STEP_02.md` | SUPERSEDED, unverified. Repo MANIFEST lists "kill vs fairness valve" as a contradiction | MANIFEST gap list; no `git grep` hit for "valve" semantics checked |
| 3 | Objective markers occluded by the factory | `audits/03_AUDIT_STEP_03.md` | SUPERSEDED, unverified (repo uses real-cover acoustic shadows and photo-recon) | `ocean_view.gd:296` |
| 4 | Sentinel inside factory is LOS-occluded; multi-Siren coordination basic; Hunter wanders far at Curious | `audits/04_AUDIT_STEP_04.md` | SUPERSEDED (global Hunt replaces the Hunter, 55 files mention Hunt). Specific wander issue not carried | `git grep -il hunt` |
| 5 | Stun maps keyed by `siren.type` break with 2+ Patrollers | `handoffs/05_HANDOFF_FROM_STEP5.md`, code read | SUPERSEDED, unverified. Repo `observed_stun.gd` loops `sim.contacts[id]`, i.e. per-contact ids | first 8 lines of `observed_stun.gd` only |
| 6 | Recon not LOS-gated | `audits/06_AUDIT_STEP_06.md` | SUPERSEDED (photo-recon pillar with its own rules), unverified | repo AGENTS/spec keyword hits |
| 7 | Recon radius test hardcodes 400 after Step 7 made it 460 | `tmp_audit_step6/step6_tests.js` | DROPPED (stale test; repo does not carry it) | `git grep -i step6_tests` not run separately; `smoke_test` and `jsdom` had zero hits |
| 8 | Oxygen 210 is an estimate (pothole 2) | `handoffs/07_HANDOFF_FROM_STEP7.md` | SUPERSEDED. Repo has per-level OXYGEN_SECONDS 180 to 840 | `game/src/campaign/endurance_budgets.gd:4` |
| 9 | Sub-cam-only path unaddressed (pothole 3) | `handoffs/07_HANDOFF_FROM_STEP7.md` | OPEN, unverified (photo-recon pillar exists but I did not trace this case) | none |
| 10 | Mobile potholes: touch listeners bound unconditionally, click double-fire, text-only portrait warning, `?` no-op | `audits/08_AUDIT_STEP_08.md` | SUPERSEDED (engine replaced by Godot Android-first) | repo AGENTS.md, SOURCE_AUTHORITY |
| 11 | UI placeholder constants (deadzone 0.22, axis threshold 0.35, sizes 22vmin) | `handoffs/08_HANDOFF_FROM_STEP8.md` | SUPERSEDED (native Godot controls) | same |
| 12 | Step 9 Flag A: `AU.beat` unbound (also `AU.decoy`, `AU.drone`, `AU.stopAmb`) | `audits/09_AUDIT_STEP_09_REFIRE.md`, `_step9_refire_patch.py` | SUPERSEDED (repo has `game/src/audio/soundscape.gd`); the unwired cues were not carried | file exists; not read |
| 13 | Step 9 Flag B: noise to Siren investigate write-through deferred | `audits/09_AUDIT_STEP_09_REFIRE.md` | SUPERSEDED (speed-squared hearing exists in 2 repo files), unverified for the specific write-through | `git grep` speed-squared |
| 14 | `AU.init()` called only on `keydown`, so touch-only users get no audio | `code/sirens_song.html` line 825 (found by my read; no audit flagged it) | SUPERSEDED by engine. Android audio start not tested in repo (physical-phone testing deferred per AGENTS.md) | AGENTS.md |
| 15 | Step 9 RED: truncated build, rollback; hardened gates | `audits/09_AUDIT_STEP_09.md`, `handoffs/09_HANDOFF_FROM_STEP9.md` | N/A-DOC (process lesson, section 4) | |
| 16 | Step 9 refire YELLOW edge case 1 misattributes stationary case to oxygen | `audits/09_AUDIT_STEP_09_REFIRE.md` | N/A-DOC (error in audit) | audit 07 contradicts |
| 17 | Handoff 09 TUNING counts 99 to 102 (actual 90 to 93) | `handoffs/09_HANDOFF_FROM_STEP9.md` | N/A-DOC | counted in code |
| 18 | Step 9 spec patch size claim 151 KB / 3,659 lines (actual 147,438 B / 3,462) and "8 new `__sim`" (actual 7) | `SIRENS_SONG_SPEC_STEP9_PATCH.md`, `ORCHESTRATOR_LOG.md` | N/A-DOC | |
| 19 | Patch never merged into `SIRENS_SONG_SPEC.md` | `SIRENS_SONG_SPEC.md` vs patch | DROPPED (repo spec is CURRENT_GAME_SPEC; repo has zero hits for hasActiveDetector, shadowPoly) | `git grep -n -i -E 'hasActiveDetector|active detector|shadowPoly|shadow cone'` zero hits |
| 20 | Ratification conflict: brief 09 says pulls ratified 2026-06-03 in claude.ai space; PROJECT_CONTEXT and SESSION_NOTES say pending | `briefs/09_v03_pullin_patch.md`, `PROJECT_CONTEXT.md`, `SESSION_NOTES_20260605.md` | OPEN | no archive file settles it |
| 21 | Smoke test ran on the Step 8 build (135,266 B), not Step 9; `smoke_test.js` fails `node --check` (stray duplicated catch block after the IIFE at line 488); needs jsdom, package.json lists playwright | `smoke_test_run_20260605.log`, `smoke_test.js`, `package.json` | DROPPED (repo has zero hits for smoke_test, jsdom) | `git grep -n -i -E 'smoke_test|jsdom'` |
| 22 | Hardcoded Patroller proximity (194 px, rate 1.5) outside TUNING | `code/sirens_song.html` | DROPPED | not carried |
| 23 | Sirens ignore terrain | `code/sirens_song.html` | SUPERSEDED, unverified | |
| 24 | Stale title and header comments say "Step 4 build"; comments say 1000x640 and sub speed about 110 (real 960x640, 80) | `code/sirens_song.html` | DROPPED (HTML build line not in repo) | |
| 25 | Inbox analysis wrongly says v7 lacks the kill rule, drones, partial noise, and "same six" invariants | `research/CLAUDE_AI_INBOX_ANALYSIS_20260605.md` vs `sirens_song_prototype_v7.html` | N/A-DOC. The repo uses v7 as the ratified reference | design bible line 66 |
| 26 | Inbox v7 copy lacks the `resize()` ordering fix in `startGame` (inbox 47,365 B vs repo copy 47,972 B) | `Inbox_from_Claude.ai/.../sirens_song_prototype_v7.html` | RESOLVED in the repo copy `reference/original-prototype/sirens_song_prototype_v7.html` | byte sizes compared |
| 27 | `MINING_REPORT.md` backup-size map wrong; admits briefs, audits 01-08, handoffs, smoke, html were not read | `MINING_REPORT.md`, `ORCHESTRATOR_LOG.md` | N/A-DOC (corrected here) | |
| 28 | `claude_index.md` stale sizes and state | `claude_index.md` | N/A-DOC | |
| 29 | Audit 04: 4 first-pass failures were harness issues, not game bugs | `audits/04_AUDIT_STEP_04.md` | N/A (resolved inside the chain) | |
| 30 | "Section 2.7 thermocline" cited but absent | `research/GENRE_AND_MONETIZATION_RESEARCH.md` | N/A-DOC | |

## 4. Learnings and failure modes

All from archive files; the first column names the source.

1. Write/Edit tool truncation corrupts large single files: `handoffs/02_HANDOFF_FROM_STEP2.md`, `handoffs/06_HANDOFF_FROM_STEP6.md`, `handoffs/09_HANDOFF_FROM_STEP9.md` (FUSE Edit truncation), `audits/09_AUDIT_STEP_09.md` (RED: truncated build). Fix used in Step 9: atomic string substitutions via script (`_step9_refire_patch.py`, 21 substitutions) plus hardened gates (five, per `handoffs/09_HANDOFF_FROM_STEP9.md`).
2. Context/token death mid-chain: `ORCHESTRATOR_COMPLETE.md` records a token-death event; `ORCHESTRATOR_LOG.md` is the event log that rebuilt the true state.
3. Self-reported numbers drift: size claims (151 KB vs 147,438 B), `__sim` counts (8 vs 7), TUNING counts (99 to 102 vs 90 to 93), table label "90" with 89 rows. Counting from the file is the only safe check. Sources: `SIRENS_SONG_SPEC_STEP9_PATCH.md`, `handoffs/07_HANDOFF_FROM_STEP7.md`, `handoffs/09_HANDOFF_FROM_STEP9.md`, `ORCHESTRATOR_LOG.md`.
4. A passing test on the wrong build proves nothing: the smoke run ran on the Step 8 build (`smoke_test_run_20260605.log`), and the sub did not move under KeyW in jsdom. The script no longer parses (`smoke_test.js`).
5. First-pass test failures can be harness faults: `audits/04_AUDIT_STEP_04.md` (4 of 4).
6. Stale tests and hardcoded absolute paths: `tmp_audit_step6/harness.js` (`/sessions/...`), `tmp_audit_step6/step6_tests.js` (400 px recon radius after Step 7 changed it).
7. Prior mining that samples gets the map wrong: `MINING_REPORT.md` (admits partial reading; wrong backup size map).
8. Analysis written without reading the code is wrong: `research/CLAUDE_AI_INBOX_ANALYSIS_20260605.md` mis-stated v7 on the kill rule, drones, noise, and the invariant count.
9. Ratification provenance gets lost across tracks: `briefs/09_v03_pullin_patch.md` vs `PROJECT_CONTEXT.md` / `SESSION_NOTES_20260605.md`. Record who ratified what, where, and on which date.
10. Docs must be patched into the canonical spec, not left as sidecars: `SIRENS_SONG_SPEC_STEP9_PATCH.md` was never merged into `SIRENS_SONG_SPEC.md`.
11. Reset all UI-init on the first user gesture of any kind: audio is initialized only in a `keydown` handler (`code/sirens_song.html` line 825), so touch-only users are silent.
12. Keying state by enemy type breaks the moment there are two of a type (stun maps keyed by `siren.type`): `handoffs/05_HANDOFF_FROM_STEP5.md`, `code/sirens_song.html`.
13. Constants outside the tuning object escape tuning passes (Patroller 194 px / 1.5): `code/sirens_song.html`.
14. Stale comments and titles mislead later readers: `code/sirens_song.html`, `claude_index.md`.
15. Tuning flags that say "FLAG step 7" are only closed if step 7 actually changes them; Step 7 changed 3 values and one label (WARNING to HOSTILE): `handoffs/07_HANDOFF_FROM_STEP7.md`.
16. Mandatory aggression scenario sims in a tuning brief are what exposed the stationary-sub problem: `briefs/07_tuning_pass.md`, `audits/07_AUDIT_STEP_07.md`.
17. Session artifacts left in the tree: `code/_test_propagation.txt` ("DELETE ME").
18. Dependency declarations must match what tests import: `package.json` lists playwright while `smoke_test.js` requires jsdom.

## 5. Superseded/stale

Chronology rule applied: newer wins.

Timeline: the June chain ran 2026-06-03 to 2026-06-05 (`SESSION_NOTES_20260605.md`, `ORCHESTRATOR_LOG.md`). The repo later decided Android-first, Godot 4.6.3/GDScript, a gauntlet structure, and a 4 s beam-lock lethality model (repo AGENTS.md, SOURCE_AUTHORITY; HEAD 2026-10-23). Repo SOURCE_AUTHORITY says the 2026-06 specs "constrained development to a single hand-authored level"; current intent is a multi-level Android game.

Superseded by the repo (June item, then newer repo decision):
- Single-file HTML/Canvas build line (`code/sirens_song.html`): replaced by Godot. The playable v7 HTML (`reference/original-prototype/sirens_song_prototype_v7.html`) is the ratified implementation reference, not the June 9-step build.
- Suspicion meter as the lethal spine (thresholds 34/75/100, 4.0 s sustain, `INSTAKILL_SUSTAIN_SEC`): replaced by beam-lock lethality; zero repo hits for INSTAKILL and for HOSTILE in `game/src`. (`git grep -n INSTAKILL` zero; `git grep -n -E 'HOSTILE|Hostile' -- game/src` zero.)
- Suspicion decay 5/s: `git grep -n -i decay -- game/src` returns only a comment in `foundry_departure.gd:20` about event decay. No suspicion decay in the repo.
- Hunter (dormant, pursue 75): replaced by global Hunt.
- Fixed oxygen 210: per-level budgets in `endurance_budgets.gd`.
- Desktop-byte-equivalent mobile layer (Step 8): moot under Godot.
- Web Audio `AU`: moot; repo has `soundscape.gd`.

Stale or wrong inside the archive (not carried):
- `claude_index.md` (stale), `MINING_REPORT.md` (partial reading, wrong size map).
- `SIRENS_SONG_SPEC.md` is v0.2; v0.3 and the Step 9 patch were never merged.
- Step 9 patch numbers (151 KB, 3,659 lines, 8 `__sim`): wrong.
- `handoffs/09_HANDOFF_FROM_STEP9.md` TUNING counts: wrong.
- `smoke_test.js`, `tmp_audit_step6/step6_tests.js`: broken or stale.
- `code/sirens_song.html` header comments (Step 4, 1000x640, speed 110).

True size-to-state map for the baks (from the diff chain; `MINING_REPORT.md` has it wrong):

| File | Bytes | State |
|---|---|---|
| `bak.step2-pre-step3` | 23,523 | post step 2 |
| `bak.pre-step1-fixpass-20260604` | 41,825 | post step 3 |
| `bak.pre-step4-20260604` | 55,234 | post fix-pass |
| `bak.pre-step5-20260604` | 79,522 | post step 4 |
| `bak.pre-step6-20260604` | 97,702 | post step 5 |
| `bak.pre-step7-20260604` | 110,327 | post step 6 |
| `bak_pre_step8` | 112,450 | post step 7 |
| `bak.pre-step9-20260605` (and refire copy) | 135,266 | post step 8 |
| `sirens_song.html` | 147,438 | step 9 refire (YELLOW) |

## 6. Conflicts with the repo with dates

| Topic | June archive (date) | Repo (date) | Newer wins |
|---|---|---|---|
| Platform and distribution | itch.io PWYW + Patreon + Ko-fi + Poki/CrazyGames; no Steam in 2026; no native mobile (`research/GENRE_AND_MONETIZATION_RESEARCH.md`, `PROJECT_CONTEXT.md`, 2026-06-05) | Godot Android-first; Android APK builds prohibited for agents; physical-phone testing deferred; "Publishing administration is outside the game-development grant"; CURRENT_GAME_SPEC line 10 excludes publishing administration (HEAD 2026-10-23). `git grep -i itch.io` zero hits | Repo. The research is not rejected, only out of scope for agents. |
| Web-first vs Android-first | Web single file is the target, mobile layer added at Step 8 (2026-06-04/05) | Android-first Godot | Repo |
| Lethality | Suspicion at 100 for 4.0 s with an active detector (June build) | 4 s beam lock (`recon_consequences.gd`, `sweeper_senses.gd`) | Repo |
| Invariant 1 | "No player kill-path" (v0.2) | Repo design bible line 66 records that the accepted prototype's kill rule required an active, unstunned Siren with LOS | Repo, plus v7 |
| Hunt model | Hunter plus stage-less suspicion (June); HUNT 5 stages proposed (`SIRENS_SONG_pressure_design.md`, unratified) | Hunt appears in 55 repo files; v7 has HUNT stages | Repo |
| Story | Log texts and "never meant to come back" frame a one-way mission (`sirens_song_prototype.html`) | Quietus is a military photo-recon vessel (22 Oct); rescue arc with human survivors (STORY_BIBLE_DRAFT, 21 Oct); "Do not author new narrative text" (USER_DIRECTIVES, 21 Oct) | Repo. The June log text must not be reused as new narrative without Pat's ruling. |
| Process | Cowork daisy-chain with sidecar patches and smoke tests | Repo AGENTS.md policy; Actions minutes guardrails (mecha2026) | Repo |
| Name | Title hedges: Deep Contact, The Quiet Depth, Below Listening, Aphotic | Repo design bible uses "Deep Contact" | Repo |
| Scope | Single hand-authored level (SOURCE_AUTHORITY says the June specs constrained to this) | Multi-level Android game | Repo |
| Authority | PROJECT_CONTEXT 35-item ratification queue | Authority order: current user decisions > CURRENT_GAME_SPEC > design bible > source-verified behavior > history | Repo |

The repo contains none of the June chain by name: `git grep -n -i -E 'Cowork|homebase|daisy|itch\.io|hull-sink|graze'` returned zero hits at HEAD 2888192. (The word "graze" does appear in v7 files under `reference/original-prototype/`; my zero-hit claim covers repo code and docs outside that folder. Re-run the grep with `-- . ':!reference'` to confirm.)

## 7. Open questions for Pat

1. Did you ratify the four Step 9 pulls (kill gate, shadow polygons, procedural audio, speed-as-noise plus silent running), and where? `briefs/09_v03_pullin_patch.md` says yes on 2026-06-03; `PROJECT_CONTEXT.md` and `SESSION_NOTES_20260605.md` say pending.
2. Stationary sub: rule on Hunter speed 60-65 or leave it? (`audits/07_AUDIT_STEP_07.md`). Moot under the repo's beam-lock model, but should the "sit still and hide" case be tested there?
3. Do you want the 90/93-constant June table kept as a reference for tuning the Godot game, or scrapped? Scrapping is the only removal route; nothing was removed.
4. Which story text, if any, from the June HTML (the two logs, the win text) may be reused? USER_DIRECTIVES (21 Oct) forbids new narrative text, and the one-way-mission frame conflicts with the rescue arc.
5. Distribution: keep the itch.io/Patreon/Ko-fi/Poki stack as human-owned notes while the repo stays Android-first, or retire it? The repo's AGENTS.md puts publishing administration outside the agent grant.
6. Title: is "Deep Contact" final? The June research offered four hedges.
7. Should the claude.ai-track invariant count (seven, per `SIRENS_SONG_functional_spec.md`) replace the six in the repo's rules? The inbox analysis claims "same six" and is wrong.
8. The valve reset threshold (<100 or <75) from `audits/02_AUDIT_STEP_02.md` was left open; confirm it is irrelevant under beam-lock.
9. The repo copy of v7 has the `resize()` ordering fix and the Inbox copy does not: confirm the Inbox copy can be treated as superseded and scrapped.
10. Audio on touch-only: the June build never initialized audio without a keypress. Confirm the Godot Android build starts audio on first touch when physical-phone testing resumes.
11. Prior `MINING_REPORT.md`, `claude_index.md` and `code/_test_propagation.txt` are stale or junk. Scrap them, or keep as history?
12. The repo side was read partly by keyword. Do you want a full read of CURRENT_GAME_SPEC, the design bible and STEALTH_AI_ROADMAP to firm up the "unverified" rows in section 3?
