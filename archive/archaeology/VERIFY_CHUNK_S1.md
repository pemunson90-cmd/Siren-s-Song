# VERIFY_CHUNK_S1: Siren's Song June build staging, literal read

Date: 2026-11-06 (UTC). Read-only. Pat alone decides promotions. Nothing below promotes anything. No secrets printed.
Line cites are `sirens_song.html` (final) unless prefixed: `S2:` = step2-pre-step3 backup, `D01:` `D02:` `D03:` `D04:` = diff files in /home/claude/diffs_s1/.

## 0. Environment facts that differ from the task description (read first)

1. Only 4 of the 13 html builds are on disk in this sandbox. Staging root is
   `/mnt/user-data/uploads/Documents/_archive/archaeology-staging/Siren-s-Song/homebase-sirens-song-2026-06/code/`.
   `/mnt/user-data/outputs/siren` holds 6 .md files and no html. A whole-filesystem search by name and by SHA-256 of every manifest hash found nothing else.
   - ON DISK: `sirens_song.html` (final, 3462 L, 147438 B), `.bak.pre-step1-fixpass-20260604` (1119 L, 41825 B), `.bak.step2-pre-step3` (633 L, 23523 B), `.bak.pre-step9-20260605` (3196 L, 135266 B).
   - NOT ON DISK (6 of the 9 backups): `.bak.pre-step4-20260604`, `.bak.pre-step5-20260604`, `.bak.pre-step6-20260604`, `.bak.pre-step7-20260604`, `.bak_pre_step8`, `.bak.pre-step9-refire-20260605`. All six are listed in `SHA256SUMS.txt` lines 39-44 and 46; the refire entry has the same hash as pre-step9 (cc70e9fb...), so by the manifest it is byte-identical to the pre-step9 file, but cmp cannot be run on a file that is absent.
   - The backups are named `*.html.bak.*`, not `*.html`, so `find -name '*.html'` does not match them.
   - SHA-256 of the 4 on-disk files all match `SHA256SUMS.txt` (final 6a9973bd..., fixpass 2d6b0f6d..., pre-step9 cc70e9fb..., step2 a332da78...).
2. Because steps 4 to 8 are missing, the neighbour diff chain is step2 -> fixpass -> pre-step9 -> final (3 diffs, not 9). The fixpass-to-pre-step9 diff (D02) aggregates the Step 1 fix-pass, Steps 4, 5, 6, 7 and 8 into one block. Per-step attribution inside D02 is from code comments only.
3. Repo clone `/home/claude/pemunson90-cmd/siren-s-song` is HEAD `f5b66a1` (2026-11-01, one commit, 368 packed objects, 143 .gd files, 142 files in game/tests). It is not 2888192 (`git cat-file -t 2888192` fails). A second, bigger working-tree copy without .git exists at `/mnt/user-data/uploads/Documents/Claude Code Homebase C/siren-s-song` (408 .gd, 270 test files, extra modules such as photo_pricing, recon_consequences, onboarding_hints). I grepped both and label each cite "clone" or "upload copy".
4. The newer-canon documents named in the task, `docs/SESSION_LEDGER_2026-10-21.md` and `docs/USER_DIRECTIVES.md`, do not exist in either repo tree or anywhere on the filesystem. I used `docs/CURRENT_GAME_SPEC.md`, `docs/V7_TO_GODOT_PARITY.md`, `docs/SOURCE_AUTHORITY.md` and `design/SIRENS_SONG_DESIGN_BIBLE_GAUNTLET_V1.md` (all present in the clone) as the newer-canon reference. CONFLICTS verdicts below are therefore against those four, not against the two missing files.

## 1. Build lineage as actually found

| Build | Lines | What it is | Evidence |
|---|---|---|---|
| step2-pre-step3 | 633 | Step 2: suspicion, Patroller, valve. 23 TUNING keys. Direct-velocity WASD. HUD printed heading in degrees and Patroller x,y. | S2 L5, L55-87, L227-230, L587, L594 |
| pre-step1-fixpass-20260604 | 1119 | Actually the STEP 3 build (title "Step 3 build"), saved before the Step 1 fix-pass edits (inertia, LOS). Drones, sub cam, factory, 3 objectives, bonus, extraction, win. The name is misleading. | D01 L8; D01 L117-156 |
| pre-step9-20260605 | 3196 | Steps 1 fix-pass, 4, 5, 6, 7, 8 all applied. No audio, no silent, no detector gate, no shadow wedges. | D02 L8-11, D03 whole |
| sirens_song.html (final) | 3462 | The Step 9 REFIRE build. Adds exactly: SILENT button, NOISE_GAIN, NOISE_HEAR_MAX, SILENT_BIND_KEY, AU audio, silentRunning, hasActiveDetector valve gate, noiseRForSub, toggleSilentRunning, applyInertia freeze, shadowPolyForRect plus wedge render, HUD silent and noiseR, 7 `__sim` entries. | D03 L7-9, L27-29, L41-113, L126, L134-145, L226-265, L275-294, L309-313, L331-386, L396-399, L407-416 |

Discrepancy worth knowing: `ORCHESTRATOR_LOG.md:43` says the first Step 9 build was about 151 KB and 3,659 lines, and `audits/09_AUDIT_STEP_09.md:195` cites `AU` at line 587 and `_au_first_gesture()` at line 989. The on-disk final is 147,438 B and 3,462 lines with AU at L567. So the final is the refire rebuild from pre-step9, and the first Step 9 attempt is not on disk.

cmp results: step2 vs fixpass DIFFER (first byte difference 94, line 5); fixpass vs pre-step9 DIFFER (67, line 5); pre-step9 vs final DIFFER (6195, line 163). No byte-identical neighbour pair exists among the on-disk files. pre-step9 vs pre-step9-refire: identical by manifest hash only, file absent.

## 2. The eight candidate leads

| # | Lead | Verdict | Evidence | Rating | Recommendation |
|---|---|---|---|---|---|
| 1 | heard-but-not-seen cue | REFUTED as a June feature. No such cue exists. | Sirens draw only inside a passive, ping, drone-cam or recon window (drawSirenIfVisible L3009-3091). AU has `decoy()` L619, `drone()` L620 and `beat()` L624 defined but never called; the only call sites are L827 (startAmb), L1279, L1619, L1638, L1977, L1997, L2182, L2357. So no proximity or Siren-presence sound. Opposite finding: the HUD prints all three Siren mode strings every frame whether seen or not (L3216) plus a visible count (L3217), an omniscient debug leak. Repo already has the real thing: bearing-only reception with no through-rock source dot (clone `ocean_view.gd:502`, `foundry_departure.gd:24,38`), "heard Ns ago" bearing text (upload copy `onboarding_hints.gd:41`), SCOUT passive-contact stop (clone `simulation.gd:184`). | SUPERSEDED (cue). CONFLICTS (the HUD mode leak vs CURRENT_GAME_SPEC "chart reveals only earned knowledge"). | Ignore |
| 2 | speed readout | REFUTED as a distinct feature. | Final HUD has no speed number. It prints `noiseR: N` (L3227) which is clamp(speed x 4.5, 0, 360) (L2046-2047). The Step 2 HUD printed heading degrees (S2 L587) and Patroller x,y (S2 L594); both were dropped at Step 3 (D01 L984, L991) and never return. Repo: own-motion footprint contours (clone `ocean_view.gd:213,312`), "MOTION NOISE" text (`acoustic_feedback.gd:19`), parity row "Amber noise/range footprint: Adapted". | SUPERSEDED | Ignore |
| 3 | off-screen Patroller hint | REFUTED. No code. | World is the single 960x640 canvas (L241-242); everything is on screen; extraction beacon always drawn (L2680-2682). Off-screen hints only matter in the scrolling Godot world; repo has clamped lock-warning marker (upload copy `lock_warning_ui_tests.gd:26`) and bearing markers. Nothing in June to promote. | NOISE | Ignore |
| 4 | knockdown visuals | PARTLY CONFIRMED (small legibility aid). | KD and EMP share one stun mechanism (L1538-1547). Orange dashed ring at body radius +6 with a live "KD n.ns" or cyan "EMP n.ns" label under the Siren (L2718-2743); tracer line plus dot (L2745-2758); mode string "immobilized" or "stunned" in the Siren label (L1757, L3088-3089); AU.knock sine 90 to 38 Hz, 0.55 s (L618). Effect lands instantly at fire (L1629). Numbers are inverted against newer canon: June EMP 5 s single target, KD 12 s; repo EMP is radial 340 m for 12 s and KD is 8 s (clone `simulation.gd:16`, `:213`, `:223`; CURRENT_GAME_SPEC "radial EMP 340-unit/12s"). Repo renders physical torpedo, cable wrap, shrinking silhouette (spec). A numeric remaining-seconds label on the affected Siren: no `stun`, `PINNED` or `DISRUPTED` rendering found in either tree's presentation code (grep), so the countdown label is PLAUSIBLY MISSING (not proven; I did not read every presentation file). | USEFUL LATER (countdown label only). Ring and numbers SUPERSEDED. | Promote candidate (label only), Pat decides |
| 5 | recon as a draw | REFUTED, inverted. June recon is silent and attracts nothing. Repo already makes recon a draw. | fireRecon L1666-1680 touches no Siren and emits no noise. findCuriosityTarget L1423-1455 considers only drones and lastPing. Repo recon emits a 1100 m "RECON UPLINK" noise (clone `simulation.gd:208`, labelled at `:390`). Design bible keeps recon ("Pat explicitly rejected removing it"). June recon values: 2 charges, +8 suspicion, 8 s, radius 460 vs ping 360 (L531-541), no LOS gate (L495-501), multiple concurrent reveals (L515). | SUPERSEDED | Ignore |
| 6 | detection-cause readout | PARTLY CONFIRMED. A per-term gain readout exists; a last-cause readout does not. | HUD prints band label CURIOUS/ALERT/HOSTILE (L1240-1244, L3176, L3210), `factory_prox +N/s` (L3190-3191, L3211), `siren_prox +x.xx/s` (L3197-3198, L3212), `instakill in n.nn s` (L3177-3178), plus the WARNING banner and "instakill imminent -- break contact" (L2761-2773). `applySuspicion(amount, sourceTag)` (L1210) accepts a tag and never stores or shows it (grep: only L1210). Repo has no suspicion presentation (grep of presentation: none); it uses per-Siren local suspicion and lock (CURRENT_GAME_SPEC "local suspicion", "no omniscient sensor queries"). A port of the global 0-100 meter would conflict. The principle quoted in the build is kept in repo spirit: L1234-1238 "the player must always be able to reason about why a Siren noticed them", L1418-1421 "no hidden detection: if a Siren found you, a rule you can name did it" (repo reference spec `SIRENS_SONG_functional_spec.md:131` says "No hidden detection"). | USEFUL NOW for the principle as a test for the repo's warning text. CONFLICTS for the mechanism. | Keep archived; Pat may cite the principle |
| 7 | setSilentRunning / getNoiseR absent | CONFIRMED absent in final. | Zero hits in sirens_song.html. Real new `__sim` entries are 7 (L3449-3455): hasActiveDetector, shadowPolyForRect, AU, noiseRForSub, toggleSilentRunning, toggleSilent, getSilentRunning; D03 L407-416 shows nothing else added. Names appear only in docs: `SIRENS_SONG_SPEC_STEP9_PATCH.md:37`, `briefs/AUDITOR_BRIEF.md:313` and `:326`, `ORCHESTRATOR_LOG.md:43`, `audits/09_AUDIT_STEP_09_REFIRE.md:194` (which says getNoiseR was deliberately not exposed). | NOISE | Ignore |
| 8 | _au_first_gesture absent | CONFIRMED absent in final. | Zero hits in sirens_song.html. Referenced at `audits/09_AUDIT_STEP_09.md:195` ("referenced from btnSilent action (line 989)") and `briefs/AUDITOR_BRIEF.md:300` (expected from both keydown and mousedown with a `_au_gesture_done` flag). Final has `AU.init()` only in the keydown listener (L823-827) and `btnSilent` only calls toggleSilentRunning (L947). No pointerdown or touchstart audio init, so a touch-only player gets no audio. It belonged to the lost first Step 9 build. | NOISE (web-only defect) | Ignore |

## 3. Other items found, with status

Status words: PRESENT (in repo), MISSING (from repo), SUPERSEDED, CONFLICTS (with newer canon).

| # | Item | Final lines | Repo status and evidence | Rating | Recommendation |
|---|---|---|---|---|---|
| 9 | Pat ruling 2026-06-03: decoys BOTH passive (any parked drone within 180 px draws Curious Sirens) and active (B toggles; 320 px range, weight 2.0, score = dist/weight). A Curious Siren approaches a drone, does not kill it; Alert+ contact kills it. "Exploit verb: park a drone to bait a Curious Siren and photograph it." | L221-224, L413-418, L1344-1349, L1423-1455, L2311-2334, L3136-3149; constants L406-418 | Repo decoys are deliberate placed emissions, 160 m reach, 3 charges, 15 s (clone `simulation.gd:14,225-227`; parity row "Deliberate decoy placement"). Grep for parked-drone bait or lure in clone and upload copy: no hit. Repo drones die when beamed with no Curious state (parity row "Drone targeting: Research + differentiate"). Passive drone-as-bait: MISSING. | USEFUL LATER | Promote candidate (concept only) |
| 10 | Pat ruling 2026-06-03: passive AND active reveal must be terrain-occluded; "Pat's parallel implementation occludes both and it feels great". | L285-294, L2527-2531, L3013-3016 | PRESENT: sensing occlusion via `visible()` and `line_clear`, "Sonar rays stop at actual cover" (clone `ocean_view.gd:197`, `world_region.gd:35`). | SUPERSEDED | Ignore |
| 11 | Pat diagnostic 2026-06-03: "the submarine needs to feel like a submarine". Inertia constants: accel 60, reverse x0.5, linear drag 0.45/s, turn accel 2.6, turn drag 2.0, terminal 80 px/s, 1.8 rad/s; about 1.5 s to 95% speed, about 3 s coast. Collision zeroes velocity (L2139-2154). | L254-283, L2063-2076, L2461-2507 | Concept PRESENT (CURRENT_GAME_SPEC "Preserve inertia, turning"; clone `simulation.gd:134,523`). Numeric constants not compared; repo uses metres and different scale. | SUPERSEDED (numbers) | Keep archived |
| 12 | Silent running as a full stop: toggle zeroes vx, vy, angularVel; noise 0; oxygen still drains. | L813-817, L2464-2468, L2042-2048 | CONFLICTS: repo silent is LOW/OPEN PROFILE, slower and quieter, with per-waypoint inherit/cruise/silent (clone `main.gd:76,235,399`, `route_program_panel.gd:112`, `soundscape.gd:16-17`; CURRENT_GAME_SPEC per-waypoint propulsion). | CONFLICTS | Ignore |
| 13 | Speed-as-noise is display-only in the June build. NOISE_GAIN (L553) and NOISE_HEAR_MAX (L554) are read only in noiseRForSub (L2046-2047), which is consumed only by the HUD (L3227) and `__sim` (L3452). The header comment (L544-546) says noise "feeds Siren detection"; the code does not do that. | L544-555, L2042-2048 | Repo has real speed-squared hearing (parity row "Speed-based acoustic signature: Adapted"). Provenance flag: do not cite the June build as having noise-driven detection. | SUPERSEDED / NOISE | Ignore |
| 14 | Jam tool: 3 charges, +5 suspicion, 4.0 s window, halves every Siren's proximity gain (x0.5), clears lastPing "lock", sub aura ring plus "JAM n.ns" label. | L435, L439, L443-455, L1581-1594, L2700-2716 | MISSING. Repo has no jam. Design bible calls it "proposed jamming"; functional spec line 83: "Jamming: reduces sub detectability for a window. Cheapest." grep of v7 html: no jam. So the June build gave the only concrete tuning of this proposal. | USEFUL LATER | Promote candidate (design reference only), Pat decides |
| 15 | Fairness valve gate: vaporize timer runs only while an un-stunned Siren is within its per-type radius (Patroller 194, Sentinel 220, Hunter 200) with LOS; otherwise the timer PAUSES (does not reset). | L2004-2033, L2172-2188 | PRESENT in different form: design bible "kill rule required an active, unstunned Siren with line-of-sight"; repo beam lock 4 s that resets on stun (clone `simulation.gd:213`, `:1142-1143` per earlier verifier). Pause-vs-reset is a small design difference. | SUPERSEDED | Keep archived |
| 16 | Hunter speed tuned 90 to 75 px/s so the aggression scenario ends in vaporize rather than hull-sink (INV5 margin); oxygen 240 to 210 s. | L248-253, L385-393 | Different combat model in repo (hull 100, beam). | SUPERSEDED | Ignore |
| 17 | HOSTILE vs WARNING naming split (state band vs valve cue). | L1220-1244 | Global meter does not exist in repo. | SUPERSEDED | Ignore |
| 18 | Shadow-cone render: dark 4-point wedges behind every terrain rect inside each reveal disc, alpha x0.85, extended 3 x radius + 200; render only. | L2809-2846, L2874-2892 | PRESENT by ray method: "Sonar rays stop at actual cover, producing explicit acoustic shadow" (clone `ocean_view.gd:197`). | SUPERSEDED | Ignore |
| 19 | Siren close-up bonus photograph: drone within 100 px of any Siren, +15 suspicion, listed on win overlay. | L700-702, L1963-1974, L2802-2803 | Not found by grep in clone (src, docs). Parity row "Photo grading: Polish candidate". Upload copy has a photo_pricing module I did not read. | USEFUL LATER | Keep archived; Pat decides |
| 20 | Extraction beacon always visible as a "diegetic exception". | L2680-2682, L2993-3007 | PRESENT (clone `ocean_view.gd:204-207`). | NOISE | Ignore |
| 21 | Recon design reasoning (no LOS because plane is above seafloor; "I need to see what's in that rock corridor"; disc shape; fade is render-only). | L474-530 | PRESENT in intent (design bible "preserve recon's strategic value"). | SUPERSEDED | Ignore |
| 22 | Stale or wrong comments in the final: title says "Step 4 build" (L8); recon radius "400 px" in fireRecon doc (L1649) while TUNING is 460 (L541); recon comment "sub speed ~110 px/s" (L491) while sub terminal is 80 and 110 is the drone speed (L318); Patroller proximity 194 px and rate 1.5 hardcoded (L1380-1381, L2019), not in TUNING. | as listed | n/a | NOISE | Ignore |
| 23 | Step 2 long rationale comments were condensed at Step 3: why the instakill check runs BEFORE decay (otherwise the timer could never accumulate) and what decay terms were deferred. Full text exists only in the step2 backup. | S2 L283-300, S2 L310-320; D01 L551-569, L577-602 | The global meter is gone in repo. | NOISE | Keep archived |
| 24 | Touch layer defects: mouse mousedown uses unscaled coordinates (L863-865) while touch scales (L1047-1055), wrong on hybrid devices; `?` button toggles a flag with an empty handler (L945, L1119) and HUD/help are hidden in touch mode (L29), so help is inert; RESTART hidden except at game over (L122-123). | as listed | Godot input is native. | NOISE | Ignore |
| 25 | v7 prototype difference (item 3 of the task). | D04 L1-11 | See section 4. | n/a | n/a |

## 4. v7 prototype comparison

Staging `Inbox_from_Claude.ai/Siren's Song claude web/sirens_song_prototype_v7.html` vs repo `reference/original-prototype/sirens_song_prototype_v7.html` (47365 B each): exactly one changed line (`startGame`), confirmed in D04 L3-8. Staging: `...startAmb();init();resize();syncBtns();screen='playing';...`. Repo: `resize()` removed from before `syncBtns()` and appended as the last statement, after the overlay is hidden and the log modal is hidden. No other difference. The v6 prototype (`sirens_song_prototype.html`, 44721 B) is byte-identical to repo `reference/original-prototype/history/sirens_song_prototype.html` (cmp).

## 5. Pat rulings and spec quotes recorded in the final's comments (provenance list)

- L221-224, L413-416, L1344-1349: "Pat 2026-06-03 ruling" decoys passive and active (item 9).
- L285-288, L2527-2531, L3013-3016: "Pat 2026-06-03 ratified" both passive and active reveal terrain-occluded; "diagnostic 1" (item 10).
- L2063-2065: "Diagnostic 2 from Pat 2026-06-03: the submarine needs to feel like a submarine" (item 11).
- L1234-1238: spec section 11 quote on Siren detection legibility (lead 6).
- L1418-1421: spec section 7 "no hidden detection" paraphrase (lead 6).
The earlier archive verifier found that the "Pat ratified the four Step 9 pulls" claim is not evidenced; I did not re-test that (docs were only grepped here).

## 6. What I could not verify

- Steps 4 to 8 individually (6 backups absent). Attribution of D02 hunks to steps 4, 5, 6, 7, 8 relies on code comments.
- Pre-step9 vs refire byte identity (absent file; manifest says identical).
- The two newer-canon files named in the task (absent everywhere).
- Whether the repo draws a stun countdown on affected Sirens (grep only; presentation files were not read in full).
- Repo inertia constants (not compared).
- The upload copy's photo_pricing and onboarding modules beyond the grep lines cited.

## 7. Coverage statement

Files read in full as literal text with the Read tool, every line:

| File | Lines read / total | Bytes read / total | Calls |
|---|---|---|---|
| code/sirens_song.html (final) | 3462 / 3462 | 147438 / 147438 | 9 (1-400, 401-800, 801-1200, 1201-1600, 1601-2000, 2001-2400, 2401-2800, 2801-3200, 3201-3462) |
| code/sirens_song.html.bak.step2-pre-step3 (no earlier neighbour) | 633 / 633 | 23523 / 23523 | 2 (1-340, 341-633) |
| diffs_s1/01_step2_to_fixpass.diff | 1044 / 1044 | 44231 / 44231 | 3 |
| diffs_s1/02_fixpass_to_prestep9.diff | 2593 / 2593 | 115890 / 115890 | 7 (1-400, 401-800, 801-1200, 1201-1600, 1601-2000, 2001-2593) |
| diffs_s1/03_prestep9_to_final.diff | 419 / 419 | 18086 / 18086 | 1 |
| diffs_s1/04_v7_staging_vs_repo.diff | 11 / 11 | 1830 / 1830 | 1 |

Files covered through diff hunks, not as standalone reads:
- `.bak.pre-step1-fixpass-20260604` (1119 L, 41825 B): every changed hunk vs step2 read in D01 and every changed hunk vs pre-step9 read in D02. Unchanged regions between hunks were not displayed by the diff, but diff guarantees they equal the step2 text (read in full) on one side and the pre-step9 text on the other.
- `.bak.pre-step9-20260605` (3196 L, 135266 B): changed hunks vs fixpass in D02 and vs final in D03 read in full; unchanged regions equal the final text (read in full) by diff construction.

Gaps and reasons:
- Six backups (pre-step4, pre-step5, pre-step6, pre-step7, pre_step8, pre-step9-refire): 0 of their lines and bytes read, because the files are not present in this sandbox (section 0).
- Repo, staging .md specs, audits, briefs and handoffs were searched with grep only, not read in full. Cited doc lines came from grep output. The only repo documents read in full were `docs/CURRENT_GAME_SPEC.md` and `docs/V7_TO_GODOT_PARITY.md`; `docs/SOURCE_AUTHORITY.md` was read except for a truncated tail.
- No timeouts occurred; no command was left unresolved.

Checkpoint file: /home/claude/scratch_chunk_S1.md. Diff files: /home/claude/diffs_s1/01 to 04.
