# MINING_FULL_SIREN_READ_1

Scope: six files read completely, line 1 to end, in file order, in numbered chunks. Source notes with per-chunk detail: SCRATCH_NOTES_SIREN_READ_1.md. Ledger: READ_LEDGER_SIREN_READ_1.tsv. Only findings NEW relative to MINING_FULL_SIREN.md and MINING_FULL_SIREN_READ_2.md are recorded. All defects are static (code read, plus small node/grep checks on copies; nothing was run as a game). L = line number in the file named in the heading.

## Coverage (lines read vs total)

| File | Read | Total | Bytes |
|---|---|---|---|
| Inbox_from_Claude.ai/Siren's Song claude web/sirens_song_prototype_v7.html (A) | 1-607 | 607 | 47365 |
| code/sirens_song.html.bak.step2-pre-step3 (B) | 1-633 | 633 | 23523 |
| code/sirens_song.html.bak.pre-step1-fixpass-20260604 (C) | 1-1119 | 1119 | 41825 |
| code/sirens_song.html.bak.pre-step4-20260604 (D) | 1-1408 | 1408 | 55234 |
| code/sirens_song.html.bak.pre-step5-20260604 (E) | 1-1928 | 1928 | 79522 |
| code/sirens_song.html.bak.pre-step6-20260604 (F) | 1-2321 | 2321 | 97702 |

Line and byte counts re-verified with wc at close.

## Build lineage as the code states it

- B = Step 2 build (L5, L27). C = Step 3 build. D = Step 3 plus Step 1 fix-pass. E = Step 4. F = Step 5 code under a title and header that still say "Step 4" (L5, L26-84; first stale at Step 5, not only in the final build).
- TUNING key counts by script: B 23, C 40, D 45, E 73, F 86. __sim key counts: B 14, C 26, D 30, E 43, F 57. Every step is a strict superset of the previous __sim (checked D, E, F).
- Line growth: 633 -> 1119 -> 1408 -> 1928 -> 2321.

## Per-file state and what changed

### A. v7 reference prototype (portrait, pointer-only)
- World 1200x1800, view height 900 (L102). Full CFG list L103-120 (reported in scratch notes). New vs mining: noiseGain 13, thermal band 0.40-0.455 of world height with detection x0.5 (L119, L208-209), investigateT 6.5, pingHear 430, factoryR 340 / factoryGain 8.
- Audio: all 11 AU cues are called (ping L248/L250, emp L254, knock L238/L391, decoy L235/L326, drone L234, cap L263, boom L395, surface L396, beat L385, startAmb/stopAmb L264/L587/L588). AU.init runs on the Start button click (L587), so touch users get sound.
- No keyboard handling anywhere (pointer and buttons only).
- Main loop runs update(dt*0.30) while a tool mode is armed (L584-585): all timers slow to 30 percent.
- Grade: sub photo quality max 0.70, drone photo up to 1.00 (L257-263); A needs mean >= 0.95, B >= 0.7 (L589-590). A sub-only run is practically always C.
- Hunt: floor = photos * 8, clock +0.2/s cannot outrun 1.0/s decay (L344-349).
- Graze period is 1.5 + 3.0 = 4.5 s, 5 hits need >= 19.5 s (L389-392); hull never regenerates.

### B. Step 2
- Fixed 960x640, no inertia, no win condition, no objectives. 11 rect terrain, 10 waypoint patrol loop: 1818.8 px, 45.5 s at 40 px/s, 0 clip points at radius 14 (comments L106, L108 are true, node check).
- Suspicion decay paused 3.0 s after every ping (L321-330). Kill check runs before decay (L301-308).

### C. Step 3
- Adds drones (supply 5), sub-cam photo, three required objectives plus a Siren close-up bonus, factory rect (730,240,180x200) as terrain, factory proximity tiers 140/260/420 for 3/2/1 per s, extraction (70,70) r30 with win overlay, mouse input.
- Unchanged from B: movement (no inertia), ping, Patroller, valve, hull rules.

### D. Step 3 plus fix-pass
- Adds persistent vx/vy/angularVel, applyInertia (accel 60, reverse x0.5, drag 0.45, turn accel 2.6, turn drag 2.0), velocity zeroing on bumps (L583-598), LOS helpers, LOS gating in render.
- Not changed: suspicion, factory proximity, drones, win rule, Patroller AI, ping.

### E. Step 4
- Adds Sentinel, Hunter, curiosity framework, decoy toggle (B), Siren proximity suspicion term, bonus photo vs any Siren, three-Siren ram and drone-kill, drawSirenIfVisible refactor, HUD fields (+28 TUNING keys, listed in scratch notes E chunk 2).

### F. Step 5
- Adds jam (Digit1), EMP (Digit2 arm plus click), knockdown (Digit3), Esc disarm, 90 px LOS-gated targeting, stun maps keyed by siren.type, stun gates on movement, proximity, ram, drone kill, projectile tracers, jam aura, stun rings, HUD line (+13 TUNING keys).

## NEW defects and facts (static)

1. A L253-254: doEmp adds hunt += huntTool and resets huntT before the "no Siren in range" early return. EMP with nothing in range costs no charge and no suspicion but raises Hunt by 4. v7 only: the active repo's weapon_orders.gd L8-20 has no Hunt-on-empty (git grep huntTool: 0 hits).
2. B L193-207 and C L326-335, D, E, F: tryActivePing has no cooldown and no e.repeat guard (grep count 0 in E and F). Held SPACE pins suspicion at 100 in about 4 s. Same missing guard affects Tab, B (E L396), Digit1/2/3 (F L469-490). F fireJam (L870-882) has no active-window check, so held Digit1 burns all 3 charges on OS repeat.
3. B L268-275: world edge contact counts as a hull hit with terrain contact, sharing the 0.6 s cooldown; hull 3 can be lost in 1.8 s against a wall.
4. C L206-213 and later: extraction is (70,70), the top-left, while comments (C L176-177, D L217, F L344) say bottom-left. The extraction circle overlaps terrain rect 0 by 20 px; win still reachable.
5. C: patrol segment (780,240)->(780,510) crosses the factory rect (458 of 4010 route samples within 14 px of it, 296 inside, node check); terrain rect 3 overlaps the factory. Carried to F.
6. C L671-678, D L741, E L1171, F: win is evaluated in the same tick as lose reasons, and the win and lose overlays are independent ifs (C L819/L837), so both can draw. Win text hardcodes "/3 required" (C L846, D L1093, F L1903).
7. D L845-885: velocity independent of heading while coasting; "coast ~3 s" comment (D L100, L105-107, carried to E L122-127) is wrong: from 80 px/s speed is 20.5 at 3 s, <= 8 px/s at 5.1 s, <= 4 at 6.6 s (node). Other inertia comments true (95 percent speed at 1.27 s vs "~1.5 s", turn 0.67 s, half turn rate 0.35 s).
8. D L1151, E L1588, F L1961: objective markers gated by isLineOfSightClear that treats the factory as an occluder while all objectives lie inside it. Node sample of 17,718 origin/objective pairs: 0 clear. Markers can never be drawn although photo capture has no LOS test. Gives code evidence for mining item 3 (which was marked unverified).
9. D: terrain behind terrain is still drawn in reveal discs (only entities, factory, markers are LOS-gated). Ratified rule (Pat 2026-06-03) only partly met; v7 uses shadowPoly wedges (A L212-215, L408-414).
10. E L715-734: Sentinel orbit "on ring" band is 10-70 px from centre (tolerance 30 on radius 40); in-band the position snaps to the stale orbit angle (teleport up to about 80 px). Sentinel centre (855,410) and spawn (895,410) are inside the factory rect and terrain rect 3.
11. E L670-735: Sentinel pursues sub's current position within 220 px with no LOS. E L746-794: Hunter at Alert+ always pursues from anywhere at 90 px/s (sub cap 80), returns at 22 px/s (about 18 s for 400 px).
12. E L767-771: Hunter reaching the ping clears the single shared lastPing, cancelling Patroller deviation and Sentinel pursuit.
13. E L602-634: every live drone, parked or not, is bait for Curious Sirens within 180 px (320 if decoyMode); comment says "parked". No decoy lifetime constant in TUNING (v7 has decoyLife 7.0 s, repo DECOY_TIME 15.0), so a parked drone pins Curious Sirens indefinitely.
14. E L563-584: proximity terms are not LOS or state gated (dormant Hunter contributes). Netrate max positive 8.5 vs 5 decay, so suspicion can rise with no ping or photo near the factory and several Sirens. Origin of hardcoded Patroller 194/1.5 is E L566-568.
15. E L1038-1040 and F L1339-1341: stale "deferred to step 4" comment above the code that implements it. F L1141-1145 stale "pothole" comment although L1165-1173 iterates allSirens().
16. E L1587-1630: Sentinel inside the factory is rarely visible (LOS fails except lower orbit arc) and F L856-867 acquireTargetSiren (LOS from sub, no range cap) means EMP/knockdown cannot normally target it.
17. E: raycastTerrainHit defined, exported, never called (L1334, L1383, L1871, L1906; F L1647/L1696/L2248/L2283). F: jamProxMultiplier defined (L844) and exported (L2306), never called; sirenProxTerm repeats the expression inline (L685).
18. F L1822-1843: stun overlay draws ring and "EMP/KD n.ns" at every stunned Siren's true position with no visibility test, contradicting the comment at L1818-1821. Leaks position through the dark.
19. F L495-516: any click consumes the armed tool even on a refused shot (L504-509). F L889-926: EMP/KD on an already stunned Siren wastes a charge and +20 suspicion.
20. F L1318-1325: kill path (suspicion >= 100 for 4.0 s) has no detector condition at Step 5, so a player at 100 dies "vaporized" while all Sirens are stunned. Consistent with mining that Step 9 added the detector gate.
21. E L1824-1847: countVisibleSirens duplicates draw-side visibility logic (maintenance risk). E L1737-1750: only the active decoy ring (320) is drawn, never passive 180.
22. A: Sirens ignore terrain for movement (L352-381); investigation target random-walks with no world clamp (L366, L371, L376). Ping hearing (L248-249) and recon reveal (L400, L404) are not LOS gated. Drones die to any non-stunned Siren within 16 px when alerted or invT > 0 (L380).
23. A: factory proximity centre y 90, objective y 126, drawn outline y 16-112, gradient centre y 54 (L334-335, L453-455); extraction ring drawn at half the real trigger radius (L517-519, win test L396 uses 78); rocks drawn from random polygon (0.85 to 1.12 r) but collide as circles (L171-179, L472-475).
24. A L5-12: user-scalable=no; L8 remote Google Fonts import in a "single file".

## Anything in the existing reports found wrong or incomplete

- Mining item 26 (Inbox v7 vs repo v7): conclusion right, evidence wrong. Repo reference/original-prototype/sirens_song_prototype_v7.html is 47972 B raw (CRLF); CR-stripped it is 47365 B, identical size to the Inbox copy, differing only at L587 startGame (resize() moved after HUD/controls un-hide). Byte sizes do not show the difference.
- Mining item 14 (touch users get no audio): correct for the June build only. v7 initialises audio on the Start click (A L587). Also the June build lost AU.beat/decoy/drone/stopAmb wiring that v7 has.
- Mining item 25 (Inbox analysis says v7 lacks kill rule, drones, partial noise): confirmed wrong (A L395, L324/L380, L332-339).
- Mining item 24 (stale step labels in the final build): first stale at Step 5 file F, not only final.
- Mining item 3 (objective markers occluded): was "superseded, unverified"; code evidence now in D L1151 / E L1588 / F L1961 with node check.
- Mining June audit proposal Hunter chase 60-65: v7 hunter chase is already 64 (A L194).

## Repo cross-check (ACTIVE repo)

Method: device_bash, Linux VM, working tree at $HOME/mnt/Documents/Claude Code Homebase C/siren-s-song (Windows C:\Users\Archi\Documents\Claude Code Homebase C\siren-s-song), HEAD 2888192 (re-confirmed). Searches: git grep -n -i -E on a term with reference/ excluded for absence claims; CR-stripped diff of the two v7 copies; read docs/V7_TO_GODOT_PARITY.md and weapon_orders.gd L8-20. Keyword greps do not prove absence.
- Tuning file is game/src/simulation/tuning.gd. EMP_RADIUS 340, EMP_STUN 12.0, DECOY_TIME 15.0 (L9) confirmed. weapon_orders.gd L30 uses DECOY_TIME for decoy noise.
- No hits outside reference/ for kill_hold, noise_gain, hull regen, lastPing/last_ping, AU.beat, invest-clamp, graze/hull-graze, time-scale tool slowdown, intel grade/flawless/grainy. Parity doc L24 shows heartbeat/vignette recovered as "rough functional recovery" driven by received lock cues.
- Occlusion: docs/CURRENT_GAME_SPEC.md L66 forbids sound passing through rock, so the v7 ungated ping-hearing (A L248) is intentionally not carried. Design bible L39 treats visible occlusion shadows as essential.
- all_stop_table.gd L20 COAST_DECEL 14.0 (units unverified) with test bound < 42.0 in all_stop_tests.gd L29: the repo handles the long-coast question explicitly.
- STEALTH_AI_ROADMAP.md L15 sentinel tether 160 to 190, close to v7 tether 190 (A L193).
- Parity ledger rows exist for camera, knockdown, decoy, speed-squared hearing, thermal, currents, global Hunt, photo grading, archetypes.
- Not verified: whether the active repo's HUD or stun display leaks hidden position (F finding 18); that needs a read of presentation code and was not done here.
