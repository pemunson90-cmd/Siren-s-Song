# VERIFY_SIREN: independent verification of the Siren's Song archaeology audit

Verifier session date: 2026-11-06 (UTC). Read-only on every source. Siren is kept separate from Nova and PNB; nothing from those tracks was used.
Pat decides promotion. Nothing below promotes anything.

## 0. What was tested against what

- Archive (primary): `C:\Users\Archi\Documents\Claude Cowork Homebase C\sirens-song\` (original) and the staged copy `C:\Users\Archi\Documents\_archive\archaeology-staging\Siren-s-Song\homebase-sirens-song-2026-06\`.
  - Staged copy holds 76 files. 66 are the June originals; 10 are report or pointer files (MINING_FULL_SIREN x3, MINING_REPORT, READ_LEDGER_SIREN x3, SCRATCH_NOTES_SIREN_READ x2, SHA256SUMS). Those 10 were used only as pointers and no claim in them is relied on.
  - The original folder has the same 66 files plus `DEPRECATED_ARCHIVE_NOTICE.md` (dated 2026-11-06) plus a `node_modules` tree (out of scope).
  - Verified: all 66 staged files are byte-identical to the originals (cmp, per file). `sha256sum -c SHA256SUMS.txt` reports no failure.
  - The 66 files total 1,874,558 bytes.
- Repo (active): `C:\Users\Archi\Documents\Claude Code Homebase C\siren-s-song`, git HEAD `2888192` (2026-10-23 23:52 -0400, merge of PR 112), 1,015 tracked files, 1,003 commits. Read through `git -c safe.directory=* cat-file` and `git grep HEAD` (plain `git show` fails with a Windows stat permission error). The working tree has modified `.import` files only; HEAD was used for every repo cite.
- Whole-file hash match, archive to repo HEAD: only 4 archive files have a byte-identical blob in the repo, all from the claude.ai inbox, all committed in `8598d5a` (2026-10-19): `SIRENS_SONG_dev_notes.md`, `SIRENS_SONG_functional_spec.md`, `SIRENS_SONG_pressure_design.md`, `history/sirens_song_prototype.html` (v6). They live under `reference/original-prototype/`. The other 62 files have no byte-identical blob in the repo, so presence was tested per candidate by content search.

## 1. Result table

Cite format: archive cites are `file:line` relative to the staged June build root; repo cites are `path:line` at HEAD 2888192. "Newer wins" is applied where documents conflict.

### R1. Stationary-sub hull-sink model

| Field | Finding |
|---|---|
| (1) What it is | Step 7 audit reproduced the "literal" brief-07 aggression run (pings every 5 s, every tool, no jam, sub stationary at default start 480,320). The sub hull-sinks at t about 8.4 s with peak suspicion 87.7 and never reaches SUSP_MAX. Cause stated: Hunter at 75 px/s crosses about 360 px in about 5 s; a +25 ping every 5 s nets zero against the -5/s decay, so suspicion oscillates below 100. Cites: `audits/07_AUDIT_STEP_07.md:81`, `:85`, `:89-95`. Build agent measured a different number: hull-sink at t=6.9 s (`handoffs/07_HANDOFF_FROM_STEP7.md:174`, `:218` says "t~7s" and "50-80"). `PROJECT_CONTEXT.md:201,380` and `ORCHESTRATOR_COMPLETE.md:143` carry 8.4 s and "50-87". The 87.7 figure appears only at audit 07 line 85. Active-player variant vaporizes at 3.9 s (audit 07:69) or 4.1 s (handoff 07:175). |
| (2) Repo presence | No hull-sink or stationary-Hunter model. The repo has no global 0-100 suspicion meter and no 4 s sustained-max vaporize. Each Siren holds its own `suspicion` (0 to 1) and `lock`; beam fires when `s.lock>=4` (`game/src/simulation/simulation.gd:1142-1143`, mode LOCKING below 4, BEAM at 4). Comment at `simulation.gd:60-72`: "A fired Siren beam destroys Quietus outright; the 4s lock build before it is the fair warning". Hunter speed 64 (`simulation.gd:1169`). Hull is 100 with speed-scaled collision damage (`simulation.gd:77`, `COLLISION_SAFE_SPEED 12.0`). Stationary-craft tests exist: `game/tests/opening_depth_scenarios.gd:117`, `collision_boundaries_tests.gd:57`. No grep hit for "hull-sink" or "8.4". |
| (3) Chronology | June 2026-06-04 (audit 07) vs repo decision "Combat is decided (Option A)" in `docs/SESSION_LEDGER_2026-10-21.md:9`, reaffirmed `docs/V7_TO_GODOT_PARITY.md:26` and `docs/design/STEALTH_AI_ROADMAP.md:85`. Repo is newer and wins. Step 9 did not change this: audit 09 REFIRE line 215 says the stationary case is covered by the new detector gate, but that gate only matters at suspicion 100, and the 8.4 s case peaks at 87.7. Line 215 also names oxygen as the cause, which audit 07 does not. It was not re-simulated. So the case was never re-tested after Step 9. |
| (4) Verdict | SUPERSEDED (different combat model). Earlier claims: "about 8.4 s, peak about 87.7" CONFIRMED (auditor figure, audit 07:85; build agent's 6.9 s differs). "Never ruled" CONFIRMED: no file among the 66 records a Pat ruling (searched for ruled, ruling, decided, ratified near stationary, Hunter, 8.4). |
| (5) Usefulness | SUPERSEDED. One-line reason: the numbers belong to a model the repo no longer has. The only portable lesson (test the literal scenario and the active scenario separately) is already echoed by `opening_depth_scenarios.gd:117`. |
| (6) Recommendation | Keep archived. |

### R2. TUNING table: 90 keys, handoff 89 rows, Step 9 additions

| Field | Finding |
|---|---|
| (1) What it is | Node-evaluated `Object.keys(TUNING)` per build: step2 23, fixpass 40, pre-step4 45, pre-step5 73, pre-step6 86, pre-step7 90, pre_step8 90, pre-step9 90, final `code/sirens_song.html` 93 (TUNING block L245-556). Final adds `NOISE_GAIN` (L553), `NOISE_HEAR_MAX` (L554), `SILENT_BIND_KEY` (L555). Handoff 07 roll-up table (`handoffs/07_HANDOFF_FROM_STEP7.md:232-339`): my script extracted 89 unique rows, all present in code. The one key not in the table is `DECOY_TOGGLE_KEY_HINT` (code L418, value "B", a HUD hint string). Handoff and audit say "all 90 numeric constants" (handoff 07:228,232; audit 07:32). |
| (2) Repo presence | Repo has no TUNING table; Godot constants are spread across `game/src/simulation/*.gd`. June values differ by design: oxygen 210 s vs repo oxygen 100 with per-mission `oxygen_seconds` budgets (`game/src/simulation/operation_endurance.gd:6-8`); hull 3 vs 100; knockdown 12 s vs `KNOCK_TIME := 8.0` (`simulation.gd:62`); Hunter 75 vs 64. |
| (3) Chronology | Handoff 09 L96 says TUNING went "99 to 102". Measured values are 90 to 93. Handoff 09 is wrong on the counts. `SIRENS_SONG_SPEC_STEP9_PATCH.md:30` lists `NOISE_INVESTIGATE_WINDOW_SEC = 2.5`; the final html has zero occurrences, so that constant was never built. |
| (4) Verdict | SUPERSEDED. 90 keys CONFIRMED. "Handoff table lists 89, omits DECOY_TOGGLE_KEY_HINT" CONFIRMED (and 89 is "numeric" only loosely; the one omitted key is a string). Handoff 09 "99 to 102" REFUTED. |
| (5) Usefulness | SUPERSEDED for values; NOISE for the 89 vs 90 discrepancy. |
| (6) Recommendation | Keep archived. Ignore. |

### R3. `__sim` surface: 62 to 73 keys

| Field | Finding |
|---|---|
| (1) What it is | Top-level entry count of `window.__sim = {...}` by node depth-aware parse: pre-step4 30, pre-step5 43, pre-step6 57, pre-step7 62, pre_step8 62, pre-step9 73, final 80 (final block L3286-3455). 62 to 73 is Step 8 (+11 touch entries, audit 08:197, handoff 08). 73 to 80 is Step 9. |
| (2) Repo presence | None. Repo tests are GDScript, 516 files under `game/tests`. No JS sim harness. |
| (3) Chronology | `SIRENS_SONG_SPEC_STEP9_PATCH.md:37` says 8 new entries including `setSilentRunning` and `getNoiseR`; both are absent from the final html. Actual new entries: `hasActiveDetector`, `shadowPolyForRect`, `AU`, `noiseRForSub`, `toggleSilentRunning`, `toggleSilent`, `getSilentRunning` (7). `audits/09_AUDIT_STEP_09_REFIRE.md:174-194` and handoff 09 agree on 7. The spec sidecar is stale. Audit 07:24 counted 66 by regex vs 62 callable. |
| (4) Verdict | SUPERSEDED. "62 to 73" CONFIRMED. Spec sidecar "8" REFUTED (7 real, 73+7=80). |
| (5) Usefulness | NOISE. |
| (6) Recommendation | Ignore. |

### R4. `smoke_test.js`

| Field | Finding |
|---|---|
| (1) What it is | jsdom boot and 3 s loop crash check (`smoke_test.js:1-33`), desktop 1280x800 and mobile 375x812. Authoritative statement of scope at L9-10: "NOT logic verification". `node --check smoke_test.js` fails: `SyntaxError: Unexpected token 'catch'` at line 488. Cause: lines 488-492 are a stray duplicate `catch((e)=>{...})` after the IIFE already closed at line 487 (`})().catch(...)`). I confirmed `head -487` parses. `package.json:1-5` and `package-lock.json:8` declare only `playwright ^1.60.0`, but the script requires `jsdom` (L37). `PROJECT_CONTEXT.md:293` ("jsdom only dep") is therefore wrong. The log (`smoke_test_run_20260605.log:3,26`) ran against the 135,266 B Step 8 file with 73 `__sim` keys. It was never run on the 147,438 B Step 9 build. |
| (2) Repo presence | Not present. Repo equivalents are the GDScript suites in `game/tests` and `scripts/toolchain`. The prototype it targets is not in the repo. |
| (3) Chronology | Script and log dated 2026-06-05 14:41 UTC; Step 9 landed 23:22 UTC the same day. The archived script cannot be the one that produced the clean log (that one parsed). It was altered after the run. |
| (4) Verdict | SUPERSEDED. "Fails node --check" CONFIRMED (line 488). Removing the 5-line tail fixes it (verified in /tmp, archive untouched). |
| (5) Usefulness | SUPERSEDED. The idea (headless boot check with a Proxy 2D-context stub, `tmp_audit_step6/harness.js` pattern) is not needed for Godot. |
| (6) Recommendation | Keep archived. Ignore. |

### R5. Touch-mode behavior

| Field | Finding |
|---|---|
| (1) What it is | `IS_TOUCH_DEVICE = ("ontouchstart" in window) || navigator.maxTouchPoints>0` (`code/sirens_song.html:913-914`); `body.touch-mode` set at L1140-1141. In touch-mode CSS hides `#hud` and `#help` (L29), scales the canvas to the viewport at 3:2 (L39-47), hides the desktop crosshair (L44-49). Joystick synthesizes WASD into the same `keys` Set; 13-button tray (brief 08 L32-48, audit 08:129-155); `touchCssToGameCoord` L1047-1053; portrait warning L125-139. Touch listeners are bound regardless of device (audit 08:108-115, flagged inert on desktop). Step 8 proof: MD5 of the pre-Step-8 JS body with Step 8 blocks stripped equals `d64857726e8bb74b0f3f5c5bd6770621` (audit 08:106). Pat constraint quote at `PROJECT_CONTEXT.md:84` and `SESSION_NOTES_20260605.md:78-79`. |
| (2) Repo presence | Touch is native to the Godot build: radial command ring, FLEET station, chart drag, FIT/FOCUS (`docs/V7_TO_GODOT_PARITY.md:8`, `docs/CURRENT_GAME_SPEC.md`), phone acceptance in `docs/PLAYTEST_ANDROID.md:18-25`. No browser touch-detection layer. |
| (3) Chronology | June 2026-06-04; repo Oct 2026 newer. |
| (4) Verdict | SUPERSEDED (platform changed). |
| (5) Usefulness | SUPERSEDED. |
| (6) Recommendation | Keep archived. |

### R6. Audio starts on keypress only

| Field | Finding |
|---|---|
| (1) What it is | `AU.init(); AU.resume(); if(!AU.amb) AU.startAmb();` appear only at the top of the `window` keydown listener (`code/sirens_song.html:823-827`; sole `AU.init` hit at L825). No pointerdown or touchstart audio init (`audits/09_AUDIT_STEP_09_REFIRE.md:152` counts `pointerdown` as 0). A touch-only player never triggers a keydown, so gets no audio. Brief 09 line 54 specified "first user gesture (pointerdown / keydown)"; the build only did keydown (handoff 09:129 states keydown). |
| (2) Repo presence | N/A in Godot (no browser autoplay gate). Repo has sampled audio instead: `game/src/audio/soundscape.gd`, `received_cues.gd`, 53 files in `game/assets/audio` (alert, ambience, beam, camera, creak, decoy, emp, engine, extraction, ...). |
| (3) Chronology | June 2026-06-05; repo newer. |
| (4) Verdict | SUPERSEDED. Claim CONFIRMED against code. |
| (5) Usefulness | NOISE (web-only defect). |
| (6) Recommendation | Ignore. |

### R7. RESTART visibility

| Field | Finding |
|---|---|
| (1) What it is | `#btnRestart` is `display:none` by default (`code/sirens_song.html:122`) and shown only under `.touch-mode.gameover` (L123); the class is toggled at L1111-1116. Desktop R works only when `loseReason || winState` (L829); on-canvas text "press R to restart" (L2789, L2804). So there is no mid-run restart on either input path. This is by design for touch: brief 08 L45 "visible when lose overlay is active". `PROJECT_CONTEXT.md:82` lists RESTART among the 13 tray buttons but does not say it is hidden until game over. Handoff 08 note 5 (design notes) flags placement as a form-pass item. |
| (2) Repo presence | Restart exists and is always reachable through menus: `RETRY DIVE` (`game/src/presentation/flow/campaign_flow.gd:179`), `RETRY EXPEDITION` (`expedition_operations.gd:69`), `RETRY CHALLENGE` (`frontend/challenge_session.gd:94`). |
| (3) Chronology | Repo newer. |
| (4) Verdict | SUPERSEDED. Claim CONFIRMED as stated. |
| (5) Usefulness | SUPERSEDED. |
| (6) Recommendation | Ignore. |

### R8. Unscaled mouse coordinates on hybrid devices

| Field | Finding |
|---|---|
| (1) What it is | Mouse `mousedown` uses `x=e.clientX-rect.left` with no `canvas.width/rect.width` factor (`code/sirens_song.html:860-866`). Touch path scales correctly (`touchCssToGameCoord`, L1047-1053). On a hybrid device (touch screen plus mouse) `IS_TOUCH_DEVICE` is true, so touch-mode CSS stretches the canvas to the viewport (L39-47) and mouse clicks land at the wrong world position. Touch-mode also hides the HUD and help text (L29), so a touch-screen laptop loses them. Audit 08 proved the mousedown body byte-identical to Step 7 (audit 08:84) and reasoned only about touch events firing on desktop (audit 08:113-115); it did not examine mouse use in touch-mode. |
| (2) Repo presence | Not applicable. Godot input is unified. |
| (3) Chronology | June defect, never fixed or ruled in the archive. |
| (4) Verdict | SUPERSEDED. Defect CONFIRMED in code. |
| (5) Usefulness | NOISE. |
| (6) Recommendation | Ignore. |

### R9. Brief 09 vs PROJECT_CONTEXT: ratification of the four Step 9 pulls

| Field | Finding |
|---|---|
| (1) What it is | Brief 09 line 7 and line 5: "Pat ratified four targeted pull-ins from the claude.ai parallel build (v0.3 decision log, 2026-06-03)". `ORCHESTRATOR_LOG.md:42` and `claude_index.md:29` repeat it. `PROJECT_CONTEXT.md:390` says none of the five pull-ins is pulled "until Pat ratifies". `SESSION_NOTES_20260605.md:131` ("Don't pull silently across substrates... let Pat ratify") and `:178` ("when Pat ratifies the v0.3 spec swap"). The analysis doc, written before Step 9, asks "Pat ratify? Yes, before we build" for pull-in 1 (`research/CLAUDE_AI_INBOX_ANALYSIS_20260605.md` line 10 of the §10 block, i.e. file lines about 381-389) and "Pat to ratify the spec swap before we touch the build" for pull-in 3; decisions 1 to 5 are listed as open "Ratify?" items. What the v0.3 decision log actually says (`Inbox.../SIRENS_SONG_functional_spec.md:306-327`, repo `reference/original-prototype/SIRENS_SONG_functional_spec.md`): Pat raised the EMP problem (quote at L309-311) and "directed 'do it all with a spec first,' ratifying the full feature set and spec-first sequencing"; mechanical detail is "[KEEL] design proposal pending playtest". |
| (2) Repo presence | The v0.3 log is in the repo (reference copy). The four mechanics exist in the Godot build in other forms (see R13). No document in the repo records a Pat ratification of the June Step 9 pulls. |
| (3) Chronology | All of these are dated 2026-06-05. By `ORCHESTRATOR_LOG.md` line order, PROJECT_CONTEXT (L39) precedes the Step 9 spawn (L42), so brief 09 is the newer text and "newer wins" favors "ratified". But brief 09 cites no new Pat statement; it cites the 06-03 v0.3 log, which covers the claude.ai-track design. Brief 09 line 118 itself says "Pat ratifies via accept/reject of the deliverables", and `handoffs/09:237` and audit 09 REFIRE (lines 257-286) leave the accept/reject undecided. I found no recorded accept or reject. `claude_index.md` contradicts itself: header line 6 "v0.3 in inbox pending Pat ratification" vs row line 29 "ratified by Pat in claude.ai-space". |
| (4) Verdict | CONTRADICTED within the archive. By newer-wins, brief 09 supersedes PROJECT_CONTEXT line 390 as the build instruction; but the premise "Pat ratified the four pulls into the Cowork chain" is NOT EVIDENCED. Design-level ratification in claude.ai space is real only for the EMP kill rule (Pat quote) and, in general terms, "do it all". |
| (5) Usefulness | NOISE for decisions; USEFUL as provenance (do not cite the pulls as Pat-ratified). |
| (6) Recommendation | Keep archived. If Pat wants, he can rule once that the June Step 9 is historical. |

### R10. itch.io-first distribution advice vs repo Android-first

| Field | Finding |
|---|---|
| (1) What it is | `PROJECT_CONTEXT.md:222`: itch.io PWYW + Patreon + Ko-fi + Poki/CrazyGames, decide Steam after 3 months, mobile (Capacitor) deferred; `:271` item 34 "Distribution stack ... confirm or revise". Source: `research/GENRE_AND_MONETIZATION_RESEARCH.md` §4 (headings at file lines 208-296), recommended stack in §5. |
| (2) Repo presence | The repo says the opposite platform: "Android-first" (`docs/CURRENT_GAME_SPEC.md:10`), Godot 4.6.3 Android decision (`docs/decisions/0001-godot-android-production.md:7`), no APKs until feature complete (`docs/USER_DIRECTIVES.md:14` D5, `AGENTS.md:25`). Repo-wide `git grep` for itch.io, Poki, CrazyGames, Patreon, Ko-fi, USPTO, trademark returns only CC licence text. |
| (3) Chronology | June 2026-06-05 vs repo Oct 2026. Repo wins on platform. |
| (4) Verdict | CONTRADICTED on platform and distribution; the monetization and title-risk analysis itself is MISSING from the repo. Claim "itch-first vs repo Android-first" CONFIRMED. |
| (5) Usefulness | USEFUL LATER (store strategy, title and IP risk) but with web-portal and Steam-Electron parts SUPERSEDED. |
| (6) Recommendation | Keep archived; Pat can promote §3 and §4 selectively when release planning starts. |

### R11. One-way story frame vs repo rescue arc and the ban on new narrative text

| Field | Finding |
|---|---|
| (1) What it is | The June chain wrote no story. The one-way frame comes from the claude.ai track: v0.3 §11 "e.g., this was never meant to be a return trip" (`Inbox.../SIRENS_SONG_functional_spec.md:186-193`), and prototype text "the briefing was right: you were never meant to come back" (`sirens_song_prototype_v7.html:593`), "INTERCEPTED LOG" (L70), "BRIEFING: experimental sub USS Quietus" (L78). June v0.2 spec forbade dialogue and cutscenes (`SIRENS_SONG_SPEC.md:198`). `PROJECT_CONTEXT.md:260` (item 25) says narrative logs need Pat-authored text; never pulled. |
| (2) Repo presence | The prototype text is present as reference: `reference/original-prototype/sirens_song_prototype_v7.html:593` and v0.3 spec lines 190-192 (same files, v6 blob-identical). Canon is different: `docs/USER_DIRECTIVES.md:55` rejects the Siren-evacuation arc as "unratified AI fabrication"; rescue subjects are human survivors from drilling or oil-rig sites and military installations; "Do not author new narrative text"; `docs/DESKTOP_HANDOFF.md:91` "No new narrative"; `docs/PAUSE_CHECKPOINT_2026-10-21.md:78`; `docs/SESSION_LEDGER_2026-10-22.md:27`. |
| (3) Chronology | Repo Oct 2026 newer. |
| (4) Verdict | CONTRADICTED by newer Pat canon. Text itself is PRESENT in the repo only as archived reference. Claim CONFIRMED. |
| (5) Usefulness | CONFLICTS WITH NEWER CANON. |
| (6) Recommendation | Ignore. Do not promote. |

### R12. `pre-step9-refire` vs `pre-step9`

| Field | Finding |
|---|---|
| (1) What it is | `code/sirens_song.html.bak.pre-step9-20260605` and `...pre-step9-refire-20260605`, 135,266 B and 3,196 lines each. `cmp` reports identical; SHA256SUMS agrees. md5 `9e6d673b4bcc3e8a82a100f414ef0557` per audit refire:44. `ORCHESTRATOR_LOG.md:46` says the second copy was made at 23:11 UTC before the re-fire. |
| (2) Repo presence | Neither is in the repo. |
| (3) Chronology | Same day; the second is a redundant checkpoint. |
| (4) Verdict | PRESENT in archive as a duplicate. "Byte-identical" CONFIRMED. |
| (5) Usefulness | NOISE. |
| (6) Recommendation | Keep archived (duplicate). |

### R13. The four Step 9 pulls against the repo

| Pull | June build (final html, 147,438 B, 3,462 lines, md5 `477469ef51d2a0876df13d009e7cd610`) | Repo |
|---|---|---|
| 1 Kill rule (vaporize needs an active, unstunned, LOS detector) | `hasActiveDetector` with per-type radii 194 / 220 / 200; timer pauses (no reset) without a detector (audit refire:56-70). | Present in another form: a Siren only locks while `stun<=0` (`simulation.gd:1041`), knockdown zeroes `lock` (`:1074`), stun forces `lock=0, target=-1` (`:1094-1095`). |
| 2 Shadow cones | `shadowPolyForRect` in `drawWorldNear` (audit refire:76-85). | Present: `game/src/presentation/ocean_view.gd:296` "Sonar rays stop at actual cover, producing explicit acoustic shadows". |
| 3 Procedural audio | `AU` module, 7 of 8 seams; `AU.beat` defined and never called (audit refire:103). | Present, sampled not procedural (R6). Heartbeat and vignette: `docs/V7_TO_GODOT_PARITY.md:24`. |
| 4 Speed-as-noise and silent | `noiseRForSub`, `Digit5`, `#btnSilent`, applyInertia freeze; noise-to-Siren investigate write-through never built (audit refire:128, 238-244; handoff 09:153, 207). | Present and richer: continuous speed-squared hearing (`docs/V7_TO_GODOT_PARITY.md:12`), silent propulsion segments (`docs/CURRENT_GAME_SPEC.md:60`), `game/src/simulation/all_stop`. |

Verdicts: all four PRESENT in the repo as adapted systems. June implementation SUPERSEDED. Brief 09 cites are partly wrong: it places the v7 `AU` at lines 102-119 (actual `const AU` at v7 line 126, as handoff 09:127 says) and `shadowPoly` at 207-220 (actual function starts at v7 line 212). Brief 09 sets `NOISE_GAIN = 4.5` to "match v7 noiseHearMax 360", but v7 itself uses `noiseGain:13` (v7 line 112), so the 4.5 is a June-specific number. Usefulness: SUPERSEDED. Recommendation: keep archived.

### R14. Additional missing: v0.2 spec text (the June canonical spec)

| Field | Finding |
|---|---|
| (1) What it is | `SIRENS_SONG_SPEC.md` v0.2 (297 lines). The repo has the v0.3 spec but not v0.2. Items in v0.2 with no text hit in the repo: "Siren detection legibility ... the player must always be able to reason about why a Siren noticed them. That dial is the game" (L207-208); threshold bands 0-33 Curious, 34-74 Alert, 75-99 Hostile with the behavior of each and the warning state (L106-113); "Sub-cam shots carry no flat photo cost, proximity is the cost" (L99-101); Curiosity framed as a playable exploit "approachable, baitable, photogenic" (L137-140); the v0.2 DO-NOT list naming dialogue and narrative cutscenes (L198). Repo `git grep` hits: "detection legibility" 0, "33/74/99" 0, "Duskers-lite" 0, "unhurried" 0. Partial echoes in repo: v0.3 §14.1 "Death is always traceable to a decision" and §7 "Curiosity as bait", both in `reference/original-prototype/SIRENS_SONG_functional_spec.md`. |
| (2) Repo presence | Partially present through v0.3; the v0.2-only sentences are MISSING. |
| (3) Chronology | v0.2 dated 2026-06-03; v0.3 same day supersedes by version. Repo Oct 2026 supersedes both for design. |
| (4) Verdict | MISSING (literal text); concept partly PRESENT. |
| (5) Usefulness | USEFUL LATER. The detection-legibility principle is a design test the repo's stealth AI roadmap (`docs/design/STEALTH_AI_ROADMAP.md:85`, fairness assertions at L167) approaches without stating it. |
| (6) Recommendation | Promote candidate: the legibility sentence only. Pat decides. |

### R15. Additional missing: the June hand-authored map and level data

| Field | Finding |
|---|---|
| (1) What it is | 960x640 world, 11 terrain rectangles (`code/sirens_song.html:644-656`), 10-waypoint Patroller loop (L659-670), factory rect {730,240,180,200} (L687), objectives silhouette (820,340), bays (800,260), power core (855,410) (L689-699), extraction (70,70) (L704), sub start (480,320) (L722), Hunter dormant (200,60), Sentinel orbit centre (855,410) radius 40. |
| (2) Repo presence | None. `git grep` for the rectangle and waypoint coordinates and `Rect2(730,240,180,200)` returns nothing; repo has 30 operations (`docs/V7_TO_GODOT_PARITY.md:28`) and the v7 world 1200x1800. |
| (3) Chronology | Repo newer. |
| (4) Verdict | MISSING from the repo, SUPERSEDED in role. |
| (5) Usefulness | SUPERSEDED. |
| (6) Recommendation | Keep archived. |

### R16. Additional missing: three Pat verbatim quotes from the Cowork chain

| Field | Finding |
|---|---|
| (1) What it is | (a) 2026-06-03 diagnostic: "passive sonar through rock is wrong ... the active ping should also be terrain-occluded"; (b) same date: "the submarine needs to feel like a submarine. Subs have inertia, slow turn radius ..."; (c) 2026-06-04: "it should be playable with touch or keyboard and mouse because I don't want you undoing all the work that actually works already just to make it mobile playable." Sources: `PROJECT_CONTEXT.md:94-100`, `SESSION_NOTES_20260605.md:74-79`. |
| (2) Repo presence | `git grep` finds none of the three phrases. The v0.3 Pat quotes (EMP, "do it all", "Much better and it looks cool") are in the repo reference copies. Intent of (a) and (b) is realized in the Godot build (acoustic occlusion, speed-and-inertia motion); intent of (c) is the same preservation principle the repo and project CLAUDE.md state. |
| (3) Chronology | June. |
| (4) Verdict | MISSING (wording); intent PRESENT. |
| (5) Usefulness | USEFUL LATER (provenance only). |
| (6) Recommendation | Keep archived; promote only if Pat wants the wording recorded. |


### R17. Genre, IP and title research (CORRECTED from first draft: MISSING became PARTIAL)

| Field | Finding |
|---|---|
| (1) What it is | `research/GENRE_AND_MONETIZATION_RESEARCH.md` (58,896 B, 427 lines, read in full this pass). Positioning: "Mark of the Ninja underwater, with unkillable enemies"; avoid the store tags submarine simulator, horror, roguelike, survival. Post-v1 mission types: sabotage (plant device, +30 suspicion), extraction (tow beacon), witness, escort. Thermocline idea (halves ping range below it). Section 3 title check lists Sker Ritual: Siren's Song (DLC), Voiceless: A Siren's Song, Siren's Song Games, PS2 Siren; run USPTO classes 9 and 41; hedge titles Deep Contact, The Quiet Depth, Silent Witness, Below Listening, Lullaby, Aphotic. Siren design: avoid Borderlands Sirens and Subnautica Leviathan silhouettes; non-humanoid, non-female-coded. Tagline "You cannot kill anything. Nothing can kill you, until you give it a reason." Differentiators: suspicion meter as the dominant HUD element, drone-cam screenshots. Monetization stack: itch PWYW + Patreon + Ko-fi + Poki/CrazyGames, Steam after 3 months, no native mobile until asked. |
| (2) Repo presence | PARTIAL. PRESENT: Iron Lung (`AGENTS.md:1`, design bible L22/L78/L113, `docs/CURRENT_GAME_SPEC.md:81`, `docs/PHOTO_RECON.md:3`), Mark of the Ninja (3 hits), Duskers (8 hits), "Deep Contact" as history (design bible L6, L75, L112), witness pod (`CURRENT_GAME_SPEC.md:53`), tow (`concealed_harbour.gd`), thermal front code (`game/src/simulation/thermal_front.gd`). MISSING as text: sabotage (0 hits), USPTO or trademark check (0), Sker Ritual (0), Borderlands (0), Subnautica (0), Aphotic (0), store tags and tagline (0), monetization (0, see R10), thermocline as a ping-range rule (0; thermal front is a different mechanic). |
| (3) Chronology | June 2026-06-05; repo Oct 2026 newer. Platform parts conflict with Android-first (R10). |
| (4) Verdict | PARTIAL: genre anchors PRESENT, title and IP risk and monetization MISSING. Web checks of the research claims are in section 2b. |
| (5) Usefulness | USEFUL LATER for the title and IP check and the Siren silhouette rule (release planning); mission types USEFUL LATER; monetization SUPERSEDED in platform. |
| (6) Recommendation | Promote candidate: section 3 (title and IP) only, after the web recheck in 2b. Keep the rest archived. Pat decides. |

### R18. Additional finding: archive v7 differs from the repo v7

| Field | Finding |
|---|---|
| (1) What it is | `Inbox.../sirens_song_prototype_v7.html` (47,365 B, md5 `501ef64cd595076b2f73ccd553b6de28`) vs repo `reference/original-prototype/sirens_song_prototype_v7.html` (47,365 B, md5 `e142ae3c5fcc8a6c5758d6b8bae4d614`). One line differs, line 587, `startGame()`: the archive calls `resize()` before `syncBtns()`; the repo calls it last. |
| (2) Repo presence | Repo `MANIFEST.md:17` lists the md5 `e142ae3c...` and says v7 includes "the resize-ordering fix". |
| (3) Chronology | The repo copy is the fixed version; the archive copy is the same size with the earlier ordering. |
| (4) Verdict | PRESENT (repo has the newer variant); archive variant SUPERSEDED. |
| (5) Usefulness | NOISE. |
| (6) Recommendation | Ignore. |

### R19. Handoff "Design improvement notes (NOT implemented, for Pat)" tested one by one

All handoffs 01, 01-FIXPASS, 02, 03, 04, 05, 06, 07, 08 were read in full this pass. Repo evidence below is `git grep -i` at HEAD 2888192 excluding `reference/`, plus the known repo mechanics from other rows. Keyword greps are weak evidence; "keyword 0" means no keyword hit, not proof of absence of the mechanic.

| # | Idea (source) | Repo status | Verdict | Usefulness | Recommendation |
|---|---|---|---|---|---|
| 1 | Sonar-shadow darkening (fixpass) | `ocean_view.gd:296` explicit acoustic shadows | PRESENT | SUPERSEDED | ignore |
| 2 | Audio cue for an LOS-occluded contact, heard but not seen (fixpass) | keyword 0; repo has an acoustic path graph and first-siren cue (`docs/V7_TO_GODOT_PARITY.md:14,19`) which is the nearest analogue | MISSING as stated, nearest analogue present | USEFUL LATER | keep archived |
| 3 | Speed HUD readout (fixpass) | keyword 0 (speed, knots) | MISSING | USEFUL LATER (feel pillar) | keep archived; Pat may promote |
| 4 | Strafe vs heading-locked thrust (fixpass) | "strafe" 0 hits; repo uses speed-and-inertia motion | SUPERSEDED | SUPERSEDED | ignore |
| 5 | Tangential wall slide (fixpass; collision zeroes vx and vy) | 1 test-only hit, unrelated (thermal transmission); repo has speed-scaled collision damage (`simulation.gd:77`) | SUPERSEDED | SUPERSEDED | ignore |
| 6 | Soft occlusion (fixpass) | not separately grepped; shadow cones present (#1) | SUPERSEDED | NOISE | ignore |
| 7 | Edge walls non-damaging (step 1) | not separately grepped; repo collision model is different (speed-scaled damage) | SUPERSEDED | NOISE | ignore |
| 8 | Sub-cam on second canvas (step 1) | repo has FLEET station and drone camera views (`docs/PHOTO_RECON.md`) | SUPERSEDED | SUPERSEDED | ignore |
| 9 | Iron Lung darkness for the sub itself (step 1) | Iron Lung referenced across docs (R17) | PRESENT as a design anchor | SUPERSEDED | ignore |
| 10 | Patrol around the factory (step 2) | not separately grepped; repo has 8 enemy roles and patrol routes | SUPERSEDED | NOISE | ignore |
| 11 | Lost-interest search before giving up (step 2) | `docs/design/STEALTH_AI_ROADMAP.md` search patterns, last-known (22 hits) | PRESENT | SUPERSEDED | ignore |
| 12 | Variable decay by Siren distance (step 2) | keyword 0; repo suspicion is per-Siren so a global decay does not exist | SUPERSEDED (model change) | SUPERSEDED | ignore |
| 13 | Suspicion bar HUD (step 2) | per-Siren lock warning remains (`SESSION_LEDGER_2026-10-21.md:9`) | SUPERSEDED | SUPERSEDED | ignore |
| 14 | Directional hint for an off-screen Patroller (step 2) | keyword 0; first-siren cue is the analogue | MISSING as stated | USEFUL LATER | keep archived |
| 15 | Silhouette range 320 too generous (step 3) | June number only; repo ranges are different | SUPERSEDED | SUPERSEDED | ignore |
| 16 | Photo button on the drone, instant deploy at click, drone recall, misclick cost (step 3) | "recall" in `V7_TO_GODOT_PARITY.md`; misclick 0; photo-recon flow in `docs/PHOTO_RECON.md` | PARTIAL (recall present) | USEFUL LATER (misclick cost only) | keep archived |
| 17 | Sub-cam bonus photo at point blank (step 3) | not separately grepped | UNTESTED beyond doc search | NOISE | keep archived |
| 18 | Sentinel orbit offset, Hunter dormant behind the factory (step 4) | repo has Sentinel and Hunter roles; June coordinates absent (R15) | SUPERSEDED | SUPERSEDED | ignore |
| 19 | Decoy-mode heat cost (step 4) | 1 hit in `tutorial_missions.gd`, unclear relevance | UNTESTED | USEFUL LATER | keep archived |
| 20 | Triangle flocking at Hostile (step 4) | flock only in `gauntlet-boundary.py` toolchain, not gameplay | MISSING | NOISE | ignore |
| 21 | Patroller resumes the same waypoint (step 4) | route-resume not separately grepped | UNTESTED | NOISE | ignore |
| 22 | Jam strength and window, per-Siren stun countdown, whether a drone-cam reveal enables firing (step 5) | per-Siren stun countdown: test hits in `fix2_feedback_ui_tests.gd`; June jam tool is not a repo tool (only `choir_rules.gd` jam) | PARTIAL | SUPERSEDED | ignore |
| 23 | KD drag-to-seafloor visual, targeting reticle (step 5) | reticle 0; physical knockdown torpedo adaptation (`CURRENT_GAME_SPEC.md:76`) | MISSING (visuals) | USEFUL LATER (cosmetic) | keep archived |
| 24 | No-charges feedback (step 5) | `challenge_catalog.gd` has a NO CHARGES challenge | PRESENT (different use) | SUPERSEDED | ignore |
| 25 | Recon as a curious-Siren draw, range limit, single vs concurrent reveals, sector shape (step 6) | recon-draw 0; radial EMP 340 units / 12 s (`CURRENT_GAME_SPEC.md:76`) | MISSING (recon draw) | USEFUL LATER | keep archived |
| 26 | Detection-cause readout "last gain: +25 (ping)" (step 7 L359) | keyword 0; fairness assertions in `STEALTH_AI_ROADMAP.md:167` are the nearest | MISSING as stated | USEFUL NOW for legibility (see R14) | promote candidate (idea only) |
| 27 | Tap-and-hold ping repeat (step 8) | `CURRENT_GAME_SPEC.md` and `attention_scenarios.gd` mention ping repeat | PRESENT (probably; keyword only) | SUPERSEDED | ignore |
| 28 | Aim reticle, centered restart, larger touch targets, button order, tray anchoring (step 8) | 48 dp targets `docs/CONVENTIONS.md:17`; retry exists (R7) | SUPERSEDED | SUPERSEDED | ignore |
| 29 | Rotation icon or lock (step 8) | portrait in `android-smoke.sh` and visual plan docs | SUPERSEDED (native Android) | SUPERSEDED | ignore |
| 30 | Narrative logs (not a handoff idea; Pat-authored text needed per PROJECT_CONTEXT item 25) | retained in `CURRENT_GAME_SPEC.md:91` yet "Do not author new narrative text" (`docs/USER_DIRECTIVES.md:55`) | CONFLICTS WITH NEWER CANON | CONFLICTS | ignore |

Result: already present and obsolete (items 1, 9, 11, 24, 27); most others SUPERSEDED by the Godot model; the genuinely missing and possibly useful ideas are items 2, 3, 14, 23, 25 and 26 (all feel or legibility aids, none are rules). Items 17, 19, 21 were not resolved by keyword and are marked UNTESTED honestly.

### R20. Process artifacts (updated)

| Field | Finding |
|---|---|
| (1) What it is | `_step9_refire_patch.py` (read in full), `code/_test_propagation.txt` ("DELETE ME"), `tmp_audit_step6/*` (all read in full), the 9 html backups (not read as text), handoff 09 section 7 note 3 on the FUSE Edit truncation and the atomic-patch workaround, `briefs/AUDITOR_BRIEF.md`, `agent.md` (both read in full). |
| (2) Repo presence | Repo has its own `AGENTS.md`, `docs/AGENT_BRIEF.md`, `docs/CRITIC_BRIEF.md`; none of the June files. |
| (3) Chronology | Repo newer. |
| (4) Verdict | SUPERSEDED. |
| (5) Usefulness | NOISE. The reusable lesson (atomic whole-file patch after editor truncation) is process knowledge, not game content. |
| (6) Recommendation | Ignore. |

### R21. The six domain invariants (agent.md L22-35)

| Field | Finding |
|---|---|
| (1) What it is | No enemy HP and no player kill-path; suspicion is the spine; perceiving costs; tools buy time and cost heat; fairness valve; function before form (`agent.md:22-35`; echoed in `briefs/AUDITOR_BRIEF.md` as the INV1-INV6 audit gates). Authority order spec > agent.md > brief > handoff > code. |
| (2) Repo presence | Verbatim phrases: 0 hits ("function before form", "no enemy hp", "fairness valve", "suspicion is the spine", "tools buy time"); the word "invariant" 0 hits in design, docs and `AGENTS.md`. Equivalent present: "Perceiving is being perceived" (design bible L33, INV3); fairness via `STEALTH_AI_ROADMAP.md:167`. INV1 "no player kill-path" has no explicit text. |
| (3) Chronology | June; repo newer. INV2 (suspicion as one global spine) conflicts with the repo's per-Siren suspicion; INV6 "no audio elements" was already in tension with Pull 3 inside the archive. |
| (4) Verdict | MISSING as text; INV3 PRESENT; INV2 CONFLICTS WITH NEWER CANON. |
| (5) Usefulness | INV5 and INV6 USEFUL LATER as review checklist items; INV2 CONFLICTS. |
| (6) Recommendation | Keep archived; Pat may promote INV3 and INV5 as audit wording. |

### R22. June numbers by step (agent.md, briefs 01-06, handoffs, audits)

| Field | Finding |
|---|---|
| (1) What it is | Step 1: oxygen 240 s (Step 7 tuned to 210), speed 80, turn 1.8, ping radius 360, passive 90, hull 3, hull i-frame 0.6 s, inertia accel 60 / reverse 0.5 / drag 0.45 / turn accel 2.6. Step 2: Patroller 40 px/s, x1.6 at Alert and above, ram 1 hull per 0.6 s. Step 3: drone speed 110, vision 120, photo range 90, factory proximity +3/+2/+1 at 140/260/420 px. Step 4: Sentinel detect 220, Hunter pursue 90 (tuned to 75), decoys 180 / 320 range. Step 5: jam 4 s, EMP 5 s, knockdown 12 s. Step 6: recon 8 s radius 400 (tuned to 460), not LOS-gated. Suspicion: ping +25, drone photo +15, EMP and knockdown +20, jam +5, recon +8, decay -5/s paused during the 3 s ping window. Kill timer 4 s at 100, resets below 100 (audit 02 ruling; stricter variant at 75 is a one-line change). |
| (2) Repo presence | None of these values or their tuning history; repo constants differ (R2). |
| (3) Chronology | June; repo newer. |
| (4) Verdict | MISSING from the repo; SUPERSEDED in role. |
| (5) Usefulness | SUPERSEDED. The reset-below-100 ruling is NOISE under per-Siren locks. |
| (6) Recommendation | Keep archived. |

### R23. Claude.ai-track numbers, THE HUNT meter and graze (dev_notes, pressure_design, analysis doc)

| Field | Finding |
|---|---|
| (1) What it is | Prototype final CFG (dev_notes): maxSpeed 96, passiveR 130, pingMax 520, pingHear 680, decay 3/s after a 1.8 s delay, alert 34, hostile 75, kill hold 3.5 s, oxygen about 220 s (v7 300 s), 4 Sirens, 9 obstacles. THE HUNT (pressure_design section 3-4, 9): global 0-100 meter, +0.6/s time, photo +8, ping +5, tool +4, detection +6; cool -1/s after 6 s clean; floor = photos x 8; stages 20/45/70/90 with detection multipliers 1.0/1.15/1.3/1.5/1.7. Graze (section 5): at suspicion 75 or more with a detector over 1.5 s, hull -20, Hunt +6, 3 s cooldown. Both documents are labelled "Not ratified, not built" and the analysis doc states Pat ratified nothing in it; four open decisions (climb rate, oxygen as backstop, graze damage, ratchet vs decay) are never ruled in the archive. |
| (2) Repo presence | Files are in the repo as reference (`reference/original-prototype/`, blob-identical). Graze: 0 hits outside reference. Hunt: `docs/CURRENT_GAME_SPEC.md:91` says retain "action/Hunt pressure" in the parity ledger and L78 says evaluate v7 Hunt and suspicion interaction. Decay-delay: 0 hits. Factory escalation: 0 hits. |
| (3) Chronology | Repo `CURRENT_GAME_SPEC.md` (Oct 2026) newer; Option A combat (R1) makes graze moot unless Pat reverses it. |
| (4) Verdict | PRESENT as reference text; Hunt PARTIAL as retained intent; graze CONFLICTS WITH NEWER CANON (Option A: beam destroys outright). |
| (5) Usefulness | Hunt: USEFUL LATER (open parity item). Graze: CONFLICTS. Numbers: SUPERSEDED. |
| (6) Recommendation | Keep archived; the Hunt remains a Pat-ruling item already named in `CURRENT_GAME_SPEC.md:78`. |

### R24. First-fire Step 9 lost features (audits/09_AUDIT_STEP_09.md, RED)

| Field | Finding |
|---|---|
| (1) What it is | The first Step 9 fire was RED (truncated file). Features specified in the sidecar and first build that are absent from the final html (refire): `NOISE_INVESTIGATE_WINDOW_SEC = 2.5`, the noise loop that stamped Siren `invX/invY/invT`, `_au_first_gesture` on the silent button. Counts in the final: `invX` 0, `invT` 0, `NOISE_INVESTIGATE` 0, `_noiseR` 0. Audit refire:128 and 238-244 and handoff 09:153,207 acknowledge the investigate write-through was never built. |
| (2) Repo presence | The behavior (noise draws Sirens to the source) exists in richer form (continuous speed-squared hearing, `V7_TO_GODOT_PARITY.md:12`). |
| (3) Chronology | Refire newer than first fire; repo newer than both. |
| (4) Verdict | MISSING from the final June build; SUPERSEDED by the repo. |
| (5) Usefulness | SUPERSEDED. |
| (6) Recommendation | Keep archived. |

### R25. AUDITOR_BRIEF Step 9 gates and ORCHESTRATOR_COMPLETE_STEP8 claims refuted by code

| Field | Finding |
|---|---|
| (1) What it is | `briefs/AUDITOR_BRIEF.md` Step 9 gates (appended 2026-06-05) claim: 8 new `__sim` entries including `setSilentRunning` and `getNoiseR`; `_au_first_gesture()` called from keydown and mousedown with `_au_gesture_done`; a canvas top-right "SILENT" label; AU module with 13 methods. `ORCHESTRATOR_COMPLETE_STEP8.md` lists `__sim` names `simulateButtonTap`, `getActionButtons`, `getCanvasFrame`, `getOverlayState`, `pressTouchButton`. |
| (2) Repo presence | Not in the repo; code facts from the archive html: `setSilentRunning` 0, `getNoiseR` 0 (73+8 would be 81; actual 80, the refire patch adds exactly 7). `_au_first_gesture` 0, `_au_gesture_done` 0 (audio init is keydown only, L825-827). No canvas SILENT label (HUD text only, L3226). AU defines 15 methods; `AU.decoy` and `AU.drone` are defined but never called, `AU.beat` never called; seams present: ping, emp, knock, cap x2, boom (L2182), surface (L2357), startAmb (L827). All five STEP8 names are absent from the pre-step9 `__sim`; handoff 08 names are the real ones (`getTouchInputState`, `setTouchModeForTesting`, `TOUCH_ACTIONS`, `joystickVectorToKeys`, `getKeysSet`, `simulateTouchEvent`, `setJoystickVector`, `getJoystickState`, `touchCssToGameCoord`, `isTouchOverlayVisible`, `IS_TOUCH_DEVICE`). |
| (3) Chronology | Code of the refire is the last word; both documents are stale relative to it. |
| (4) Verdict | CONTRADICTED by code (documents wrong). Earlier claim "spec sidecar says 8" REFUTED stands. |
| (5) Usefulness | NOISE; useful only as a warning that June orchestrator summaries are not reliable. |
| (6) Recommendation | Ignore. |

### R26. Decay delay, speed readout, heard-but-not-seen cue

| Field | Finding |
|---|---|
| (1) What it is | Playtest-derived: decay 7 to 3/s with a 1.8 s delay "suspicion is now a managed resource" (dev_notes R2); speed HUD readout and an audio cue for an LOS-occluded contact (fixpass notes). |
| (2) Repo presence | Zero hits for decay delay or grace, speed readout or knots, heard-but-not-seen cue. |
| (3) Chronology | June; repo per-Siren model newer. |
| (4) Verdict | MISSING. |
| (5) Usefulness | Decay-delay: SUPERSEDED (per-Siren lock model). Speed readout and the cue: USEFUL LATER. |
| (6) Recommendation | Keep archived; speed readout and cue are promote candidates only if Pat wants feel aids. |

### R27. Inbox analysis doc open decisions and pull-in list

| Field | Finding |
|---|---|
| (1) What it is | `research/CLAUDE_AI_INBOX_ANALYSIS_20260605.md` (508 lines, read in full): says "Pat ratifies nothing in this document; it is read-and-rule input" and that the Cowork chain never received the ratification; lists 12 open Pat decisions never ruled in the archive; hold-outs (HUNT, graze, currents and thermal, portrait plus scroll map, 4 Sirens). |
| (2) Repo presence | Repo retains currents, thermal masking, narrative logs, speed-based hearing, targetable knockdown, photo grade in the parity ledger (`CURRENT_GAME_SPEC.md:91`); thermal code present; marine snow in `photo_scene.gd`. |
| (3) Chronology | Doc dated 2026-06-05, before Step 9; strengthens the R9 verdict (CONTRADICTED: brief 09 claims ratification the analysis doc says never happened). |
| (4) Verdict | Doc content PRESENT or SUPERSEDED via the repo ledger; R9 CONFIRMED stronger. |
| (5) Usefulness | NOISE except as provenance. |
| (6) Recommendation | Keep archived. |

### R28. Orchestration and process facts

| Field | Finding |
|---|---|
| (1) What it is | `ORCHESTRATOR_COMPLETE.md` and `_STEP8.md` (both read in full), `_step9_refire_patch.py` (674 lines, read in full: 21 atomic edits with an md5 guard, defines 7 `__sim` entries), `tmp_audit_step6/step6_tests.js` (403 lines), process notes on the CGI section refs, `_scrap-20260604`, and the Write/Edit truncation workaround. |
| (2) Repo presence | None; repo has its own agent policy files. |
| (3) Chronology | Repo newer. |
| (4) Verdict | SUPERSEDED. |
| (5) Usefulness | NOISE. |
| (6) Recommendation | Ignore. |

## 2. Earlier claims, checked

| Claim | Result |
|---|---|
| Stationary hull-sink about 8.4 s, peak about 87.7 | CONFIRMED in `audits/07_AUDIT_STEP_07.md:81,85`. Build agent measured 6.9 s (`handoffs/07:174`). |
| "Never ruled" | CONFIRMED (no ruling in the 66 files). |
| TUNING has 90 keys; handoff lists 89 and omits DECOY_TOGGLE_KEY_HINT | CONFIRMED. |
| 62 to 73 `__sim` keys | CONFIRMED (62 at Step 7, 73 at Step 8, 80 at Step 9). |
| smoke_test.js fails node --check | CONFIRMED, line 488. |
| pre-step9-refire byte-identical to pre-step9 | CONFIRMED. |
| Handoff 09 says TUNING 99 to 102 | REFUTED (90 to 93). |
| Spec patch says 8 new `__sim` entries | REFUTED (7). |
| PROJECT_CONTEXT says smoke test needs jsdom only | REFUTED (package.json declares playwright only; script needs jsdom). |
| Audit 09 REFIRE verifies the stationary edge case | REFUTED (line 215 misattributes the cause and was not simulated). |
| Brief 09 "Pat ratified the four pulls" | NOT EVIDENCED as a chain-level ratification (R9). |
| R9 correction: "claude_index says ratified" | PARTLY: analysis doc (read in full) says Pat ratified nothing and lists 12 open decisions (R27) |
| Genre research "Iron Lung film $8.9M opening" | REFUTED (section 2b) |
| AUDITOR_BRIEF "8 new `__sim` entries incl. setSilentRunning, getNoiseR" | REFUTED (R25) |
| ORCHESTRATOR_COMPLETE_STEP8 `__sim` names | REFUTED (R25) |
| Genre research is MISSING from the repo (first draft R17) | REFUTED: PARTIAL (R17) |

## 2b. Web-checked claims from the genre and IP research

| Claim (research doc) | Check | Result |
|---|---|---|
| A game titled "Sker Ritual: Siren's Song" exists | Steam app 2323211 plus Epic and Xbox listings | CONFIRMED |
| Iron Lung film opened to $8.9M (Variety) | GamesRadar citing Deadline: $17.8M US opening weekend, $21.7M worldwide (Box Office Mojo), budget under $3M | REFUTED or unsupported (figure is about half the reported one) |
| Tetris v. Xio: game rules are not protected, expression is | Willamette summary: rules public domain, block movements and expression protected, Xio's clone infringed | PARTIAL (directionally right; understates that Xio lost) |
| Iron Lung game gross about $2.18M, Subnautica 5M, UBOAT about 1M, Barotrauma about $39M, Borderlands "six" Sirens | not re-fetched | UNVERIFIED |
| Voiceless: A Siren's Song, Siren's Song Games, PS2 Siren as title collisions | not web-checked in this pass | UNVERIFIED |

Nothing here is legal advice; the USPTO class 9 and 41 search recommended by the doc was not run.

## 3. Files read in full (literal text, bytes and lines)

53 of the 66 archive files, 842,324 bytes, 10,754 lines (44.9 percent of the 1,874,558 bytes; the unread 13 are mostly the 147 KB final html and nine html backups). Bytes and lines are `wc` values; every file below was displayed in full without truncation (earlier truncated views of ORCHESTRATOR_COMPLETE, the analysis doc and the genre research were re-read untruncated).

| File | Bytes read = total | Lines read = total |
|---|---|---|
| briefs/09_v03_pullin_patch.md | 10,576 | 118 |
| SIRENS_SONG_SPEC_STEP9_PATCH.md | 5,061 | 45 |
| PROJECT_CONTEXT.md | 36,897 | 394 |
| Inbox_from_Claude.ai/Siren's Song claude web/SIRENS_SONG_functional_spec.md | 16,947 | 334 |
| SESSION_NOTES_20260605.md | 24,361 | 185 |
| ORCHESTRATOR_LOG.md | 13,209 | 50 |
| handoffs/09_HANDOFF_FROM_STEP9.md | 13,119 | 239 |
| claude_index.md | 11,725 | 144 |
| handoffs/07_HANDOFF_FROM_STEP7.md | 32,798 | 411 |
| audits/07_AUDIT_STEP_07.md | 12,342 | 114 |
| briefs/07_tuning_pass.md | 7,282 | 125 |
| smoke_test.js | 18,739 | 492 |
| smoke_test_run_20260605.log | 3,185 | 49 |
| package.json | 56 | 5 |
| code/_test_propagation.txt | 63 | 0 |
| tmp_audit_step6/harness.js | 1,456 | 45 |
| tmp_audit_step6/inv5_check.js | 743 | 16 |
| tmp_audit_step6/inv5_v2.js | 1,015 | 31 |
| briefs/08_mobile_controls.md | 14,653 | 180 |
| audits/08_AUDIT_STEP_08.md | 21,490 | 267 |
| audits/09_AUDIT_STEP_09_REFIRE.md | 25,321 | 290 |
| SIRENS_SONG_SPEC.md | 15,288 | 297 |
| agent.md | 13,145 | 209 |
| briefs/01_sub_sonar_terrain.md | 8,396 | 143 |
| briefs/02_suspicion_patroller.md | 6,747 | 122 |
| briefs/03_drones_camera_objectives.md | 7,327 | 127 |
| briefs/04_sentinel_hunter_curiosity.md | 7,736 | 115 |
| briefs/05_disruption_tools.md | 6,621 | 118 |
| briefs/06_recon_call_in.md | 4,428 | 102 |
| briefs/AUDITOR_BRIEF.md | 18,967 | 344 |
| audits/01_AUDIT_STEP_01.md | 10,191 | 136 |
| audits/02_AUDIT_STEP_02.md | 14,375 | 156 |
| audits/03_AUDIT_STEP_03.md | 19,211 | 183 |
| audits/04_AUDIT_STEP_04.md | 15,938 | 161 |
| audits/05_AUDIT_STEP_05.md | 10,772 | 111 |
| audits/06_AUDIT_STEP_06.md | 11,106 | 141 |
| audits/09_AUDIT_STEP_09.md (first fire, RED) | 22,582 | 258 |
| handoffs/01_FIXPASS_HANDOFF_20260604.md | 25,381 | 248 |
| handoffs/01_HANDOFF_FROM_STEP1.md | 11,387 | 125 |
| handoffs/02_HANDOFF_FROM_STEP2.md | 18,377 | 158 |
| handoffs/03_HANDOFF_FROM_STEP3.md | 20,326 | 218 |
| handoffs/04_HANDOFF_FROM_STEP4.md | 28,375 | 294 |
| handoffs/05_HANDOFF_FROM_STEP5.md | 28,334 | 304 |
| handoffs/06_HANDOFF_FROM_STEP6.md | 24,045 | 322 |
| handoffs/08_HANDOFF_FROM_STEP8.md | 20,853 | 261 |
| research/CLAUDE_AI_INBOX_ANALYSIS_20260605.md | 46,923 | 508 |
| research/GENRE_AND_MONETIZATION_RESEARCH.md | 58,896 | 427 |
| ORCHESTRATOR_COMPLETE.md | 20,854 | 191 |
| ORCHESTRATOR_COMPLETE_STEP8.md | 10,055 | 122 |
| tmp_audit_step6/step6_tests.js | 17,411 | 403 |
| _step9_refire_patch.py | 30,650 | 674 |
| Inbox/SIRENS_SONG_dev_notes.md | 7,753 | 107 |
| Inbox/SIRENS_SONG_pressure_design.md | 8,836 | 135 |

## 4. Coverage statement (final, exact)

Read in full: 53 of 66 files (list in section 3). NOT read in full: 13 files, listed with reasons:

| File | Read | Total | Reason |
|---|---|---|---|
| `code/sirens_song.html` (final) | about 700 lines in segments (L24-60, 245-420, 644-704, 818-830, 858-900, 1105-1146) plus node parsing and greps | 147,438 B / 3,462 L | Context budget; code verified by targeted extraction (keys, handlers, seams, greps), not by full read |
| 9 html backups `code/sirens_song.html.bak*` | hashes, sizes, line counts, TUNING and `__sim` key counts, one `cmp` of the two pre-step9 copies | not summed | Earlier versions of the same file; judged duplicates; not read as text |
| `Inbox/.../sirens_song_prototype.html` (v6) | none (identity only) | 44,721 B / 580 L | Blob-identical to the repo reference copy; analysis doc and dev_notes describe it |
| `Inbox/.../sirens_song_prototype_v7.html` | diff against the repo copy plus greps (AU, shadowPoly, noiseGain, silent) | 47,365 B / 607 L | One-line difference at L587 from the repo copy; rest not read as text |
| `package-lock.json` | greps for names | not measured | Generated lockfile, no design content |

The 10 report and pointer files in the staging root (MINING_FULL_SIREN x3, MINING_REPORT, READ_LEDGER_SIREN x3, SCRATCH_NOTES_SIREN_READ x2, SHA256SUMS) are outside the 66 originals, were not read, and nothing relies on them.

Not completed: items 17, 19 and 21 of the R19 idea table could not be resolved by keyword and are marked UNTESTED; five claims in the genre research are UNVERIFIED (section 2b); the Hunt, graze and Option A interaction was assessed from docs, not run. No timed-out command was left unresolved. Consequence: design content that exists only inside the unread html bodies (code, not prose) could still differ from what grep showed; all prose documents were read in full.

## 5. Facts for the main session (provenance)

- Repo git access: use `git -c safe.directory=* cat-file -p HEAD:<path>` and `git grep ... HEAD`; `git show HEAD:<path>` fails with a stat permission error on this mount.
- Checkpoint file: `/home/claude/scratch_verify_siren.md` (appended after every file, ends with NEXT marker).
- From the user memory store: Pat's standing preference that "read everything" means every file read in full as literal text, no sampling, and a timed-out command is retried narrower or longer. That shaped the second pass. No other fact came from memory.
- Code-refuted June documents: AUDITOR_BRIEF Step 9 gates and ORCHESTRATOR_COMPLETE_STEP8 (R25); handoff 09 TUNING counts (R2).
