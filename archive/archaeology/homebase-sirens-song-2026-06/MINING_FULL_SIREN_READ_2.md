# MINING_FULL_SIREN_READ_2

Scope: three June 2026 HTML backups plus a byte-identity check on a fourth. Folder: `_archive/archaeology-staging/Siren-s-Song/homebase-sirens-song-2026-06/code/`.
Method: every file read line 1 to EOF through `sed -n 'A,Bp'` chunks of 300 to 420 lines (device_bash, Linux VM). No diff-only coverage for any read; a `diff` of pre-step7 against pre-step8 was run only AFTER the full literal read, to check my own chunk notes. Per-chunk notes are in `SCRATCH_NOTES_SIREN_READ_2.md`. Ledger: `READ_LEDGER_SIREN_READ_2.tsv`.
Existing `MINING_FULL_SIREN.md` (289 lines) was read first; items it already holds are not repeated, only cross-referenced by section number. Static reading only; nothing was executed except `sha256sum`, `wc`, `grep`, and a python regex count of TUNING keys.
Line numbers are exact unless prefixed "~" (those come from my chunk notes and were not re-grepped).

## 1. Coverage and identity

| File | Bytes | Lines total | Lines read | Chunks |
|---|---|---|---|---|
| `code/sirens_song.html.bak.pre-step7-20260604` | 110,327 | 2,612 | 2,612 | 7 (1-330, 331-700, 701-1070, 1071-1440, 1441-1800, 1801-2200, 2201-2612) |
| `code/sirens_song.html.bak_pre_step8` | 112,450 | 2,648 | 2,648 | 7 (1-330, 331-700, 701-1070, 1071-1440, 1441-1810, 1811-2230, 2231-2648) |
| `code/sirens_song.html.bak.pre-step9-20260605` | 135,266 | 3,196 | 3,196 | 10 (1-300, 301-640, 641-980, 981-1320, 1321-1660, 1661-2000, 2001-2340, 2341-2680, 2681-3000, 3001-3196) |
| `code/sirens_song.html.bak.pre-step9-refire-20260605` | 135,266 | 3,196 | not read separately | sha256 identity only |

Identity: `sha256sum` of `...pre-step9-20260605` and `...pre-step9-refire-20260605` are both `cc70e9fbb3d88bcff730c6d72c9d6e5f4533a05aec3dffc8fce5bd63af3f16c1`. Byte-identical, so the pre-step9 read covers the refire copy. Prefix hashes of the three read files: f0e3e0b7..., e188e7a7..., cc70e9fb... (full sums in the ledger).
All three files end with LF; `wc -l` equals the line numbers read to EOF.

## 2. Constants and TUNING keys (counted by me)

Method: python regex `^\s*([A-Z][A-Z0-9_]*)\s*:` inside the `const TUNING = {` block up to the first line starting `};`, then `sort | uniq`.

| File | TUNING block | Keys | Unique |
|---|---|---|---|
| pre-step7 (post step 6) | L94-L375 | 90 | 90 |
| pre-step8 (post step 7) | L94-L391 | 90 | 90 |
| pre-step9 (post step 8) | L243-L540 | 90 | 90 |

- The key SET is identical across all three (`diff` of the sorted key lists is empty). Step 7 changed values and comments only; Step 8 added zero keys. The 90 therefore predates Step 7, so the report line "Step 7 table of 90" describes a count that was already true at the end of Step 6.
- Handoff 07 table: I extracted the first column of every `| NAME | value | source |` row after line 232 of `handoffs/07_HANDOFF_FROM_STEP7.md`: 89 rows, no duplicates. Set difference against the code: code has `DECOY_TOGGLE_KEY_HINT` (string "B", UI doc only) which the table lacks; the table has nothing the code lacks. So the code has 90, the table has 89, and the report's "90" is right for the code and wrong as a row count. This confirms `MINING_FULL_SIREN.md` section 2.1 independently.
- Step 8 report claim (`ORCHESTRATOR_COMPLETE_STEP8.md` line 32 and `handoffs/08_HANDOFF_FROM_STEP8.md` line 45): "90 constants verbatim / unchanged". TRUE for key set and values (A to C: only the 3 Step 7 values differ from A). 
- NEW wrong claim: `ORCHESTRATOR_COMPLETE_STEP8.md` line 32 lists "all thresholds (33/74/99/100)" as spot-checked constants. No such constants exist. Code constants are `THRESH_ALERT: 34`, `THRESH_HOSTILE: 75`, `WARNING_THRESHOLD: 75`, `SUSP_MAX: 100`, `INSTAKILL_SUSTAIN_SEC: 4.0` (C L300-L303). 33/74/99 are band upper edges, not values. Also `THRESH_HOSTILE` and `WARNING_THRESHOLD` are two keys with the same value 75.
- Hidden constants outside TUNING in step 8 build (UI placeholders): joystick `deadzone: 0.22` (L814), `axisThresh = 0.35` (L845), thumb offset `cap * 30` percent (L882-L886), CSS `22vmin`, min 96 / max 180 px joystick, tray 84 to 160 px. Also still hardcoded from Step 4: Patroller proximity `PATROL_RADIUS_PX + 180` and max rate `1.5` (pre-step7 L761, pre-step8 L797, pre-step9 L1259, line with `+ 180`; max rate 1.5 on the next line). Mining 2.1 already lists these; I confirm line positions only.
- Values (all three files): HULL_MAX 3; SUB_SPEED 80; SUB_TURN_RATE 1.8; PING 3.0 s / 360 px; PASSIVE 90 px; HULL_HIT_COOLDOWN 0.6; inertia 60 / 0.5 / 0.45 / 2.6 / 2.0; SUSP_PING_COST 25; DECAY 5/s; THRESH 34 / 75 / 75; SUSTAIN 4.0 s; Patroller 40 x1.6, reach 60; drones 5 supply, +15 photo, 110 px/s, vision 120, photo range 90, bonus 100; subcam 70 / 320; factory 140/260/420 px at 3/2/1 per s; extraction 30 px; Sentinel orbit (855,410) r40 0.45 rad/s, detect 220, prox 240 max 2.0, curious 24, alert 55; Hunter dormant (200,60), prox 200 max 2.0, curious 22; curiosity 35/360/180/320, Patroller curious 28, decoy weight 2.0; jam 3 charges +5 4.0 s x0.5; EMP 3 charges +20 5.0 s; KD 2 charges +20 12.0 s; pick radius 90; projectile 360 px/s r3; recon 2 charges +8 8.0 s.
- Per-step differing values: pre-step7: OXYGEN 240, HUNTER_PURSUE 90, RECON_R 400. pre-step8 and pre-step9: 210, 75, 460.

## 3. Per-file state

### 3.1 pre-step7 (post Step 6), 2,612 lines

Mechanics (all in one `<script>`, canvas 960x640, `WORLD_W/H` from canvas):
- Sub: inertial drive (`applyInertia` L1775): thrust accelerates along heading (60, reverse x0.5), drag applies ONLY when thrust is 0 (so held thrust has no drag, speed cap 80 only), angular accel 2.6 with drag 2.0 when no turn, turn cap 1.8. Collision zeroes velocity (edge per axis; terrain and factory both axes). Hull cooldown 0.6 s shared by walls and rams. Oxygen drains unconditionally (near L1490).
- Suspicion (L1496-1552): fairness valve at `suspicion >= 100` accrues `instakillTimer`, at 4.0 s sets `loseReason = "vaporized"` (L1500). NO detector gate (that is Step 9). Net rate per tick = -5 (unless ping window active, 3 s) + factory tier + sum of three Siren proximity terms; clamped 0..100.
- Sirens: Patroller (route of 10 waypoints, deviates to `lastPing` at Alert+ at 40x1.6 = 64 px/s), Sentinel (orbit anchor, pursue sub inside 220 or ping inside 220 at 55, curious to decoy/ping at 24), Hunter (dormant (200,60); Alert+ pursues lastPing else sub position directly with no LOS at 90; curious 22; returns to dormant). Rams at Alert+ use one shared cooldown. Sirens ignore terrain (`moveToward`). Drones die on terrain, factory, bounds, or Siren contact at Alert+.
- Tools: jam (no target, clears `lastPing`, halves prox for 4 s), EMP/KD click-targeted with LOS from the sub within 90 px of the click, stun maps keyed by `siren.type` (L923), projectiles visual only, recon plane (disc, no LOS, 400 px at this step, 8 s, up to 2 concurrent).
- LOS: Liang-Barsky (`segmentRectIntersect` L1841); occluders = TERRAIN + FACTORY.
- Win: all 3 required photos and sub within 30 px of (70,70) (L1666).
Audio: none (0 AudioContext/Audio/oscillator hits). RNG: none in code; the one `Math.random` string is a comment at L904.
UI: one plain-text DOM HUD (`updateHud` L2418, 5 lines), canvas WARNING banner at >=75 and "instakill imminent" countdown at 100, lose and win overlays ("press R to restart"). Keyboard + mouse only. State label function returns WARNING at >=75 (L622).
`__sim`: L2532-2606, 62 keys by line-pattern count. Matches the "62" the Step 8 handoff gives for pre-Step-8.

Defects (static):
1. Title L5 and header L21-93 say "Step 4 build" though the file holds Steps 5 and 6.
2. Comments say 1000x640 and sub speed ~110 (pre-step7 L322 and L327); code is 960x640 and 80.
3. `jamProxMultiplier` (L937) is defined and exported to `__sim` but `sirenProxTerm` (L772) re-derives the factor inline; helper is dead for gameplay.
4. Orphan doc block "step 4 -- Sentinel update" (L858 onward) with no function under it.
5. Valve writes `loseReason = "vaporized"` unconditionally (L1500), so a same-tick "sunk" or "suffocated" is overwritten.
6. Win check (L1666) has no `loseReason` guard; win and lose can both be set in one tick.
7. `tryDronePhoto` (L1326) and `trySubCamPhoto` (L1361) test range only; no LOS check, so a photo can be taken through rock.
8. `drawWorldNear` gates objective markers with `isLineOfSightClear`, which includes the FACTORY rect; all three objectives sit inside the FACTORY rect, so from outside the factory the ray ends inside it and is blocked. Markers show only through recon. (Already row 3 of mining section 3; confirmed from code.)
9. `EXTRACTION.r` set through hoisted `TUNING_PLACEHOLDER_UNUSED()` (L439-L449), works only by function hoisting.
10. Hold-thrust-into-rock: velocity is zeroed on bump but thrust re-accelerates, so hull drops 1 per 0.6 s; sunk in about 1.8 s of holding.
11. Stun maps keyed by type: a second Patroller would share a stun clock (already in mining section 3 row 5).

### 3.2 pre-step8 (post Step 7), 2,648 lines. Changes from previous step

Full literal read, then a `diff` to verify: exactly four hunks, +36 lines, nothing else.
1. `OXYGEN_MAX_SECONDS` 240 to 210 (L97-L102, comment claims a careful run takes about 90 to 120 s).
2. `HUNTER_PURSUE_SPEED_PX_PER_SEC` 90 to 75 (L234-L242; comment claims at 90 the Hunter closes about 360 px in about 4 s and beats the 4 s sustain).
3. `RECON_REVEAL_RADIUS_PX` 400 to 460 (L385-L390).
4. `suspicionState` (L638-L660): returns HOSTILE at >= `THRESH_HOSTILE` (75), ALERT >= 34, else CURIOUS. WARNING is no longer a state label; the banner is unchanged.
No new TUNING keys (90). `__sim` L2568-2642, still 62 keys. Mechanics, AI, UI identical to 3.1.
New defects and wrong claims in this file:
- Stale text left behind: L332 still says `RECON_REVEAL_RADIUS_PX = 400`, L1064 says "(400 px default)", L335 and L387 say 1000x640, L340 says sub speed ~110, L5 title "Step 4 build". The Step 7 edits updated the value but not these.
- WRONG CLAIM in the new comment L387-L389: "recon disc ~28% larger area than ping disc". 460/360 = 1.278 is the radius ratio; area ratio is 1.633 (63% larger). Same comment says the disc "fits comfortably inside the 1000x640 play area": diameter 920 exceeds the 640 height and is within 40 px of the 960 width, so a click near the middle covers the full height and most of the width.
- HOSTILE is a label only: `isAlertPlus` stays >= 34, no behavior keys on 75 except the banner and the valve cue (pre-existing). The HUD now shows "HOSTILE" while the canvas banner says "WARNING" for the same band; this is by design in the comment L638-L657.
- FLAG step 7 comments remain on every key that Step 7 did not touch (about 30 keys), so grepping "FLAG step 7" no longer identifies open items.

### 3.3 pre-step9 (post Step 8), 3,196 lines. Changes from previous step

Added versus pre-step8: 548 lines. Content, all additive (I read all of it; the pre-step8 text reappears unchanged in the rest of the file):
- HTML/CSS (L4-L170): viewport meta with `user-scalable=no` (L7); `#canvasFrame` wrapper (L145); touch CSS (joystick L62, action tray L89, `.tbtn` L103, portrait overlay L125); 13 buttons L148-L163 (PING, DEPLOY, REDIR, JAM, EMP, KD, RECON, PHOTO-F, PHOTO-G, DECOY-B, CYCLE, ?, RESTART); `#portraitWarning` L170 "Please rotate to landscape.". Title L8 appended "+ Step 7 tuning + Step 8 mobile layer" but still starts "Step 4 build".
- JS Step 8 block L776-L1088: `IS_TOUCH_DEVICE` (L801), `touchInput` (L806), `TOUCH_ACTIONS` map of 13 handlers (L821), `joystickVectorToKeys` (L840, four-direction digital, not analog), `applyJoystickKeys` (L857, writes synthetic KeyW/A/S/D into the shared `keys` Set), `joystickStart/Move/End` (L890/L899/L918), `touchCssToGameCoord` (L933), `canvasTapAt` (L947), `refreshTouchArmedUI` (L973), empty `refreshHelpOverlay` (L999), `wireTouchHandlers` IIFE (L1016).
- `__sim`: L3030-L3190, 73 keys (62 + 11: IS_TOUCH_DEVICE, getTouchInputState, getJoystickState, setJoystickVector, simulateTouchEvent, touchCssToGameCoord, isTouchOverlayVisible, setTouchModeForTesting, TOUCH_ACTIONS, joystickVectorToKeys, getKeysSet). Confirms handoff 08 "62 to 73".
- `armedTool` domain grows from null|emp|knockdown|recon to also "deploy" and "redirect" (touch only).
No audio (0 hits). No RNG. Game logic, AI, tuning: unchanged from 3.2 (checked chunk by chunk; the update/AI/render code is the same text, shifted by 548 lines).
`suspicionState` still HOSTILE at 75. Valve still ungated (L1994-L2002). Win check L2164.

New defects (static, not run). None of these appear in `MINING_FULL_SIREN.md` section 3 row 10 (which lists unconditional touch listeners, click double-fire, text-only portrait warning, `?` no-op):
1. No readout on touch. CSS L29 `.touch-mode #hud, .touch-mode #help { display: none; }` hides the only DOM HUD, and `render()` (L2432) draws no hull, oxygen, suspicion, charges or photo counter on the canvas (only the WARNING banner and end overlays). A touch player cannot see hull, oxygen, suspicion state, charge counts or armed tool. I grepped `HUD` in `handoffs/08_HANDOFF_FROM_STEP8.md`, `audits/08_AUDIT_STEP_08.md`, `ORCHESTRATOR_COMPLETE_STEP8.md`, `briefs/08_mobile_controls.md`: the only hit is handoff line 26 about CSS rules being intact, so neither the brief nor the audit addressed it.
2. RESTART button visibility. `#btnRestart` is `display:none` unless `.touch-mode.gameover` (L122-L123). `gameover` is toggled only inside `refreshTouchArmedUI` (L994-L995), called only from DEPLOY, REDIR, EMP, KD, RECON handlers, `btnRestart`, and `canvasTapAt` (which returns early when game over, L948). `frame()` (L3006) never calls it. After a loss by time (suffocation, vaporize) or after tapping PING/JAM/PHOTO/DECOY/CYCLE, the RESTART button stays hidden until the player taps an arming button; the canvas lose overlay still says "press R to restart" (L2595; win overlay L2610). WRONG CLAIM: `handoffs/08_HANDOFF_FROM_STEP8.md` line 23 says visibility is "toggled by `refreshTouchArmedUI()` after each state-affecting tap"; it is not called after PING, JAM, PHOTO-F/G, DECOY, CYCLE or on elapsed-time game over. Audit 08 row 152 tests `buttonTap btnRestart` in lose state (handler only), not visibility.
3. Hybrid-device mouse coords. Desktop `mousedown` (L749-L775) uses `e.clientX - rect.left` with no `c.width / rect.width` scaling (L752). On a touch-capable device with a mouse, `.touch-mode` scales the canvas to `min(100vw, 100vh*3/2)` (L39-L43 region), so mouse clicks land at wrong world coordinates unless the display is exactly 960 px wide. The touch path scales correctly (`touchCssToGameCoord` L933).
4. WRONG CLAIM: `handoffs/08_HANDOFF_FROM_STEP8.md` line 20 says the armed strings are "the same string values the desktop keydown handler uses ("emp","knockdown","recon","deploy","redirect")". The desktop handler never sets "deploy" or "redirect" (L717 onward), only the touch handlers do. A hybrid user who arms DEPLOY by tap and then mouse-clicks leaves `armedTool = "deploy"` set, since the mouse path only clears emp/knockdown/recon.
5. DEPLOY button is redundant: `canvasTapAt` defaults to `deployDrone` (L966), so a plain tap already deploys; arming DEPLOY adds nothing except a highlight.
6. `touchInput.helpVisible` (used at L833) is not declared in the `touchInput` literal (L806); created lazily by `btnHelp`. `refreshHelpOverlay` is empty, so the `?` button changes a variable nobody reads (mining already lists "? no-op").
7. `user-scalable=no` (L7) disables pinch zoom for all users including low-vision users.
8. Synthetic keys share the `keys` Set with the keyboard: a physical `keyup` of W deletes a joystick-held W. Low impact.
9. Joystick is four-way digital (axisThresh 0.35), so thrust is always 0 or +/-1 and turn is 0 or +/-1. There is no analog throttle on touch while the desktop has none either, so parity holds, but diagonal stick means thrust AND turn simultaneously, which is the only way to steer under thrust.

## 4. Claims in reports found wrong (this scope)

| # | Claim | Where | What the file shows |
|---|---|---|---|
| 1 | Roll-up table "all 90 constants" | `handoffs/07_HANDOFF_FROM_STEP7.md` line 232 | 89 rows; code has 90; missing `DECOY_TOGGLE_KEY_HINT`. |
| 2 | "all thresholds (33/74/99/100)" spot-checked | `ORCHESTRATOR_COMPLETE_STEP8.md` line 32 | Constants are 34, 75, 75, 100. |
| 3 | Restart button toggled "after each state-affecting tap" | `handoffs/08_HANDOFF_FROM_STEP8.md` line 23 | Only after arm-tool taps; never from frame loop. |
| 4 | Armed strings "same ... the desktop keydown handler uses" including deploy/redirect | `handoffs/08_HANDOFF_FROM_STEP8.md` line 20 | Desktop never sets deploy/redirect. |
| 5 | "recon disc ~28% larger area" | code comment pre-step8 L387-L389 and later | Area is 63% larger; 28% is the radius ratio. |
| 6 | Recon disc "fits comfortably inside the 1000x640 play area" | same comment | Canvas is 960x640; a 460 radius disc spans 920 px. |
| 7 | "No Math.random in any step-5 code (grep-verified)" | code comment L904 | TRUE (0 code hits in all three files); only the comment itself matches. |
| 8 | `MINING_FULL_SIREN.md` says `game/src/tuning.gd` | mining section 1 and 2.1 | The file is `game/src/simulation/tuning.gd` (`git ls-files | grep tuning.gd`); content matches the 770 B description. |
| 9 | Step 8 report: "Desktop path is byte-equivalent" | code comment L792; `handoffs/08` | Behavior of key/mouse handlers is unchanged, but the DOM differs (new `#canvasFrame` parent, viewport meta) and the hybrid-device mouse path is not equivalent (defect 3.3.3). The audit's JS md5 proof covers JS with Step 8 blocks stripped (already in mining 2.4). |

## 5. Active repo check (ACTIVE Siren repo)

How: `cd "$HOME/mnt/Documents/Claude Code Homebase C/siren-s-song"` (the VM mount of `C:\Users\Archi\Documents\Claude Code Homebase C\siren-s-song`). `git log -1` = `2888192 2026-10-23 Merge pull request #112 ... stealth-ai-roadmap`, same HEAD as `MINING_FULL_SIREN.md`. `git status` shows only modified `.wav.import` files. Searches: `timeout 100 git grep -n -i -E '<term>' -- <paths>` over the tracked tree (game, docs, design; also whole tree excluding `reference/` for HOSTILE, joystick/touch, restart/retry, hull cooldown, LOS terms). No command timed out; none needed a retry. Output was cut with `head`, so counts below are "at least" where stated. `git ls-files` used to locate `tuning.gd`, `enemy_types.gd`, `observed_stun.gd`.

| Item from my files | Repo finding | Basis |
|---|---|---|
| HOSTILE state label | No state label in `game/src`; only `pressure.hostile` flag in `game/src/audio/soundscape.gd:140` (heartbeat tempo) and the docs word "hostile". | `git grep -i 'HOSTILE|hostile'` |
| Joystick 0.22 deadzone, 4-way digital stick | Zero hits for joystick, deadzone, virtual stick. Repo is touch-first with chart drag/pinch/tap-to-plot, route programming, 48 dp targets. | `git grep -i 'joystick|deadzone|virtual.?stick|touch'`; `docs/CONVENTIONS.md:17`; `docs/PLAYTEST_ANDROID.md:20` |
| RESTART button hidden unless gameover class (defect 3.3.2) | Not carried. Repo uses RETRY SAVE (`game/src/main.gd:138`) and mission retry flows; no equivalent hidden-restart pattern found in the hits I viewed (8 shown). | `git grep -i 'restart|retry'` |
| No HUD on touch (defect 3.3.1) | Repo builds a full-rect Control HUD (`game/src/main.gd:107`) and a `mission_hud` (L38). Not the same defect. | `git grep -i 'hud|readout' -- game/src` (first 4 lines) |
| Stun keyed by siren.type (defect 3.1.11) | Absent. Stun lives on each Siren dict (`e.stun`, `s.stun`) in `game/src/simulation/acoustic_network.gd:35-36` and `contact_reports.gd:19,25`; roster entries carry `"stun":0.0` (`game/src/campaign/encounters/roster.gd:5`). Also the stun clock is displayed per contact via `observed_stun.gd`. | `git grep -E '\.stun\b|"stun"'` |
| Suspicion global 0..100 | NOT how the repo works: `suspicion` is a per-Siren float (`roster.gd:5` "suspicion":0.0; `simulation.gd:1075` `struck.suspicion=maxf(...,0.45)`; `:1111` `s.suspicion=maxf(s.suspicion,0.3)`; `:1120`; `recon_consequences.gd:34`), raised to INVESTIGATE thresholds, with no player-wide meter. This sharpens `MINING_FULL_SIREN.md` section 5 ("replaced by beam-lock lethality"): the repo kept a suspicion variable, moved it onto each Siren, and dropped the player-side meter, decay and sustain. | `git grep -i suspicion -- game/src/simulation` |
| Valve and 4 s sustain (valve ungated in these three files) | Not carried: lethal path is a beam strike (`simulation.gd:1148`, `VAPORIZED_TEXT` L71). Design bible line 66: the accepted prototype's kill rule needed an active, unstunned Siren with LOS. The June Step 9 `hasActiveDetector` gate (not in my files) is the same idea. | `git grep -i 'sustain|instakill|vapor'`; `design/SIRENS_SONG_DESIGN_BIBLE_GAUNTLET_V1.md:66` |
| Hull cooldown 0.6 s, 3 hull | Hull is a continuous number (tests use `hull<70`, `game/tests/opening_depth_scenarios.gd:117`); no hull cooldown constant found. | `git grep -i 'hull.{0,12}cooldown|invuln|i-frame|iframe'` (2 test hits only) |
| Jam (no target, halves prox, clears lastPing) | Design bible line 64 lists jamming as "proposed"; the only `jam(` is `game/src/campaign/encounters/choir_rules.gd:30` (an encounter rule, unrelated). Not implemented as a player tool. | `git grep -i '\bjam'` |
| EMP 5 s targeted / KD 12 s targeted | Repo EMP is radial: `EMP_RADIUS 340`, `EMP_STUN 12.0` (`game/src/simulation/tuning.gd`); KD is a physical torpedo with snare (`docs/CURRENT_GAME_SPEC.md:76`, 2 charges, 8 s). Differs from June EMP 5 s / KD 12 s; v7 values match repo, not June. | `cat game/src/simulation/tuning.gd`; spec line 76 |
| Recon: 8 s, no LOS, disc | `RECON_TIME = 8.0` (tuning.gd). Spec and design bible keep recon as strategic reveal; photo-recon module in `docs/PHOTO_RECON.md`. June radius 400/460 not carried. | tuning.gd; bible line 64 |
| Decoy | `DECOY_TIME 15.0`, `DECOY_NOISE 1100` (tuning.gd). June passive and active decoy ranges (180/320) and weight 2.0 not carried by name. | tuning.gd; `git grep -i decoy -- game/src` |
| Sub inertia 60/0.5/0.45/2.6/2.0 | Not carried as constants; bible line 37 and spec lines 59-60 require inertia, acceleration and turn limits. The June values remain the only documented numeric inertia set I found; not searched in `reference/`. | `git grep -i 'accel|drag|inertia|coast'` (first 8) |
| Liang-Barsky LOS | Not found by name. Repo uses terrain-cover LOS and acoustic shadows (bible line 39, 66; `docs/FUTURE_OPTIONS.md:14`). | `git grep -i 'liang|segment.?rect|line.of.sight|raycast|los_'` |
| Patroller / Sentinel / Hunter roles | Carried: `game/src/simulation/enemy_types.gd:5` `ALL = ["patroller","sentinel","hunter",SWEEPER,"buoy","relay","interceptor","warden"]`. | `grep` on `enemy_types.gd` |
| Per-level oxygen | `game/src/campaign/endurance_budgets.gd:4` `OXYGEN_SECONDS=[180,300,180,180,240,300,300,300,300,300,300,840,420,360]`; June 210 is a fixed value. | file read via grep |

Limits: I did not read `CURRENT_GAME_SPEC.md`, the design bible, or `reference/` in full; rows citing them rest on the single lines shown. `head` truncated several grep outputs at 5 to 10 lines, so "not found" means not in the lines returned for the specific term, not an exhaustive zero, except where I say "zero hits" (joystick/deadzone/virtual stick, which returned only touch-test CI and docs lines and no code identifier).

## 6. Learnings (new, this scope only)

1. A count that a report calls out (90) can be right for the code and wrong for the table beside it; the code count was already 90 two steps earlier, so "Step 7 table of 90" says nothing about what Step 7 changed. Counting by regex from the file, not from the handoff, settles it.
2. Value edits that update a constant but not the paragraphs beside it leave contradicting prose (400 vs 460, 1000x640 vs 960x640, area vs radius). Step 7 did this three times in one edit.
3. A UI layer that hides the only readout (`display:none` on `#hud`) needs a replacement readout in the same step; neither the brief nor the audit checked for it.
4. State flags that gate a control (gameover class) need a single owner in the frame loop; here the class is owned by five tap handlers, so a state change that arrives by time has no owner.
5. "Additive, desktop byte-equivalent" claims need a hybrid-device case (touch plus mouse); the unscaled mouse handler is the counterexample.

## 7. Open items for Pat (new only; the 12 in `MINING_FULL_SIREN.md` section 7 still stand)

1. Do you want the touch HUD and RESTART defects recorded as a closed history (the HTML line is superseded by Godot), or turned into acceptance checks for the Godot Android HUD (hull, oxygen, state, charges visible at all times; restart always reachable)?
2. Scrap candidates for the stale June prose that contradicts its own values? Nothing was changed or removed.
3. Should `MINING_FULL_SIREN.md` get the one-line path correction (`game/src/simulation/tuning.gd`)? I did not edit it (new files only).
