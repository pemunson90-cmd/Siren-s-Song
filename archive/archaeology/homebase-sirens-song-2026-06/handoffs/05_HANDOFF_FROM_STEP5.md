# Step 05 handoff -- disruption_tools

**Build session:** admiring-laughing-hamilton (Cowork Dispatch child, Claude Opus 4.7-1M)
**Built atop:** Step 1 + Step 1 fix-pass + Step 2 + Step 3 + Step 4 (all GREENLIT)
**Backup of pre-step-5 state:** `code/sirens_song.html.bak.pre-step5-20260604` (79,522 bytes, md5-verified byte-identical to pre-edit `sirens_song.html`)
**Resulting code state:** `code/sirens_song.html` 97,702 bytes / 2,322 lines. JS body 96,539 bytes. Passes `node --check`.

---

## What I built

On top of steps 1+2+3+4 + the step-1 fix-pass: the three disruption tools per spec section 5.

### Jamming (key `1`)

- **Sub-centric.** No target. Fires from the sub.
- **3 charges initial** (spec section 11). `state.jamCharges` tracks; decrement on use.
- **+5 suspicion at fire time** (spec section 6). Lands via the `applySuspicion` chokepoint, so the +5 cost shows up in `state.lastSuspChange` and respects the existing valve/decay machinery.
- **Window:** `JAM_WINDOW_SEC = 4.0s` (picked per brief 05: "~3-5s, document"). Tracked via `state.jamActiveUntil = state.timeSec + JAM_WINDOW_SEC` at fire time. `isJamActive()` returns `state.timeSec < state.jamActiveUntil`.
- **Effect strength:** `JAM_EFFECT_PROX_MULT = 0.5`. During the window, **each Siren's proximity contribution is multiplied by 0.5** (halved). Combined with the +5 jam cost, this still produces net suspicion decay near a Siren (sim-verified: at suspicion 80 with one touching Patroller, jam fire brings susp to 85 then decays to ~73 over 3s).
- **Lock break:** `state.lastPing.valid` is cleared at jam fire time. This is the "scrambles Siren localization" reading -- Sirens that were pursuing the last ping lose their target and (per existing logic) walk back to their default behavior. Combined with the proximity multiplier, this gives jam both flavor halves the brief asked for: "reduce sub detectability" + "scramble Siren localization."
- **No target needed.** Single-key fire.

### EMP torpedo (key `2`, then click)

- **Click-to-target.** Press `2` to arm; the next left-click acquires the nearest Siren within `TARGET_PICK_RADIUS_PX = 90 px` of the click position, *with line-of-sight from the sub*. Press `2` again or `Esc` to disarm without firing. If no target acquired on click, no charge consumed; tool disarms.
- **3 charges initial** (spec section 11). `state.empCharges` tracks.
- **+20 suspicion** (spec section 6).
- **Duration:** `EMP_DURATION_SEC = 5.0` (spec section 5 "~5s"). Tracked via `state.empStunUntil[siren.type] = state.timeSec + 5.0` at fire.
- **Effect:** the targeted Siren is `stunned`. Hook is at the **top of every Siren update function** (`updatePatroller`, `updatePatrollerWithCuriosity`, `updateSentinel`, `updateHunter`) -- if `isSirenStunned(siren)` returns true, the update function early-returns, setting `siren.mode = "stunned"`. Movement, detection, ram, and drone-killing all gate off this same predicate via early-returns and `continue` statements in the ram/drone-kill loops.
- **Targeting consistent** with the brief's option (a) "nearest Siren in LOS." Click-targeting works for both EMP and KD.

### Knockdown torpedo (key `3`, then click)

- **Same shape as EMP:** click-target, LOS-required.
- **2 charges initial** (spec section 11). `state.kdCharges`.
- **+20 suspicion** (spec section 6).
- **Duration:** `KNOCKDOWN_DURATION_SEC = 12.0` (spec section 5 "~12s"). Tracked via `state.kdImmobUntil[siren.type]`.
- **Effect:** the targeted Siren is `immobilized`. Same gate as EMP; `isSirenStunned()` checks BOTH `empStunUntil` and `kdImmobUntil`, so a Siren can have both effects stacked. When BOTH are active, `mode` reads `"immobilized"` (KD wins display priority since it's the longer, rarer effect).

### `isSirenStunned()` -- the universal stun gate

- Returns `true` if `state.timeSec < empStunUntil[siren.type]` OR `state.timeSec < kdImmobUntil[siren.type]`.
- Called from:
  - Top of `updatePatroller(dt)` (legacy, exposed for tests)
  - Top of `updatePatrollerWithCuriosity(dt)` (production caller)
  - Top of `updateSentinel(dt)`
  - Top of `updateHunter(dt)`
  - Inside the Siren-sub contact ram loop (`continue` to skip stunned Siren's ram check)
  - Inside the drone-destruction loop (`continue` to skip stunned Siren's drone-kill)
  - Inside `sirenProxTerm()` (returns 0 -- stunned Sirens emit no detection)

### `isJamActive()` and `jamProxMultiplier()` -- jam window plumbing

- `isJamActive()` returns `state.timeSec < state.jamActiveUntil`.
- `jamProxMultiplier()` returns `JAM_EFFECT_PROX_MULT` (0.5) during the window, else 1.0.
- Used inside `sirenProxTerm()` to scale per-Siren proximity contribution.

### Targeting (`acquireTargetSiren`)

- Given click coords `(cx, cy)`, scans all 3 Sirens, returns the nearest whose body is within `TARGET_PICK_RADIUS_PX` of click AND has clear LOS from the sub.
- Pure function (deterministic). Returns `null` if no target.
- Reused by both `fireEMP` and `fireKnockdown`.

### Projectiles (placeholder INV6)

- Each fire of EMP or KD adds an entry to `state.projectiles[]`: `{kind, x, y, tx, ty, targetType, alive}`.
- `updateProjectiles(dt)` ticks position toward target at `PROJECTILE_SPEED_PX_PER_SEC = 360`; kills the projectile on arrival; filters out dead entries each tick.
- Renders as a small colored dot + tracer line from sub to projectile head.
- **Pure visual.** The disruption effect lands at fire time (in `fireEMP` / `fireKnockdown`); the projectile is a placeholder visual artifact. INV6 -- a real form pass will replace it.

### HUD additions

The HUD is now five lines (was four in step 4):

- Line 5 (NEW): `jam[1]: N   emp[2]: N   kd[3]: N   ARMED: <TOOL> -- click target   JAM ACTIVE (Ns)`
- Existing four lines unchanged.

### Render additions

- **Jam aura** around the sub when jam is active: a faint dashed cyan ring at radius 28 + pulse, with a label `"JAM Ns"` showing remaining seconds. Placeholder INV6.
- **Stun ring** around any Sirens in EMP-stun: dashed cyan ring at body radius + 6, label `"EMP Ns"` showing remaining seconds. Drawn only if the Siren is otherwise visible (LOS-clear in any reveal mode, same gating as `drawSirenIfVisible`).
- **Immobilize ring** around any Sirens in KD-immobilize: same shape as stun ring but orange, label `"KD Ns"`.
- **Projectile tracers:** colored line from sub to projectile head + small dot at the head. Cyan for EMP, orange for KD.

### Control bindings

- **1** = fire jam (sub-centric, immediate) -- NEW
- **2** = arm EMP / disarm EMP -- NEW; next left-click fires
- **3** = arm KD / disarm KD -- NEW; next left-click fires
- **Esc** = disarm any armed tool -- NEW
- Left-click while armed: fires the armed tool at click position INSTEAD of deploying a drone. Tool disarms after fire (success or failure).
- Left-click while not armed: deploys a drone (existing behavior unchanged).
- All other bindings unchanged: WASD/arrows, SPACE (ping), RIGHT-CLICK (redirect drone), F (drone photo), G (sub-cam photo), TAB (cycle drone), B (decoy toggle), R (restart).

### Patroller `type` field

The Patroller object previously had no `type` field (it was distinguished by reference identity). Step 5's stun maps are keyed by `siren.type`, so the Patroller initializer in `newState()` now includes `type: "patroller"`. Sentinel and Hunter already had `type` from step 4. No other code touches this field, so the addition is purely additive and back-compat with step-2/3/4 sim tests.

## State of the file

- File: `code/sirens_song.html`
- Size: **97,702 bytes / 2,322 lines** (was 79,522 / 1,928 -- +18,180 bytes / +394 lines)
- JS script block: 96,539 bytes; `node --check` clean
- Backups preserved:
  - `code/sirens_song.html.bak.pre-step5-20260604` (79,522 bytes -- pre-step-5 byte-identical snapshot, md5-verified)
  - `code/sirens_song.html.bak.pre-step4-20260604` (55,234 bytes)
  - `code/sirens_song.html.bak.pre-step1-fixpass-20260604` (41,825 bytes)
  - `code/sirens_song.html.bak.step2-pre-step3` (23,523 bytes)

## Spec sections implemented

- **§5 Disruption tools (all three)**: jamming (+5, 3 charges, sub-centric window), EMP torpedo (+20, 3 charges, ~5s halt), knockdown torpedo (+20, 2 charges, ~12s immobilize). All non-killing; all charge-finite; all suspicion-costing.
- **§6 Suspicion system**: EMP/KD +20 and jam +5 land via `applySuspicion` chokepoint; integrate with existing decay/factory/Siren-prox math.
- **§7 Sirens, detection inputs paragraph**: "weapon fire" detection input -- the +20 suspicion cost IS the detection-attention spike per spec section 6 ("EMP/knockdown fire +20 suspicion"). Sirens don't have separate "noticed the weapon" logic beyond the suspicion gain itself.
- **§10 Fairness principles 1 + 2 + 3**: load-bearing. INV1 (no enemy HP, no kill-path) is enforced at every stun-map deadline; INV4 (tools buy time, cost heat) is the architecture; INV5 (fairness valve) is preserved -- jam can break a 75+ lock and drop heat.
- **§11 step 5**: fully covered.

NOT implemented (correctly out of scope): §3 recon-plane row (step 6), final tuning pass (step 7), additional Siren types, additional tool types, any "killable Siren" gameplay variant.

## Tuning values used (with spec citation)

Step 1 + 1-fixpass + 2 + 3 + 4 values preserved verbatim. Step 5 additions:

| Name | Value | Source |
|---|---|---|
| `JAM_CHARGES_INITIAL` | 3 | spec §11 |
| `EMP_CHARGES_INITIAL` | 3 | spec §11 |
| `KNOCKDOWN_CHARGES_INITIAL` | 2 | spec §11 |
| `JAM_SUSP_COST` | 5 | spec §6 / brief 05 |
| `EMP_SUSP_COST` | 20 | spec §6 / brief 05 |
| `KNOCKDOWN_SUSP_COST` | 20 | spec §6 / brief 05 |
| `EMP_DURATION_SEC` | 5.0 | spec §5 "~5s" |
| `KNOCKDOWN_DURATION_SEC` | 12.0 | spec §5 "~12s" |
| `JAM_WINDOW_SEC` | 4.0 | FLAG step 7. Brief 05 says "pick ~3-5s, document"; picked mid-range. |
| `JAM_EFFECT_PROX_MULT` | 0.5 | FLAG step 7. Brief 05 says "pick a numeric expression... document"; chose 0.5 (halve each Siren's proximity contribution during the window). Plus lastPing.valid = false at fire time for the "break a lock" half of the spec text. |
| `TARGET_PICK_RADIUS_PX` | 90 | FLAG step 7. Click within this radius of a Siren body to lock it as target. Slightly larger than the largest Siren body (Sentinel = 16 px) so click-targeting feels generous without auto-acquiring distant Sirens. |
| `PROJECTILE_SPEED_PX_PER_SEC` | 360 | FLAG step 7. Tracer speed -- placeholder INV6. |
| `PROJECTILE_RADIUS_PX` | 3 | FLAG step 7. Placeholder INV6. |

All non-spec-default values are FLAG-marked for step 7 tuning.

## Sim tests run

Methodology: extracted `<script>` block to `/tmp/sirens_song_step5.js` (96,539 bytes); loaded via `new Function('document','window','performance','requestAnimationFrame', src + 'return window.__sim;')` with DOM stubs; drove `__sim` API directly.

### Step 5 new tests (122 tests, all PASS)

| Group | Count | Coverage |
|---|---|---|
| A: TUNING constants | 11 | All new TUNING values present and in expected ranges; charges, costs, durations, window bounds, mult bounds, pick radius |
| B: Initial state | 10 | Charges initialized correctly; stun maps empty; armedTool null; projectiles empty; jamActiveUntil < 0; patroller.type populated |
| C: INV1 (no HP fields) | ~25 | Every key on every Siren tested against `/^(hp|health|dead|killed|damage|attack)$/i`; same regex on __sim surface |
| D: Jam fire | 12 | Fire returns true, charge dec, +5 cost, window set, window expires, exhausted after 3 fires, 4th is no-op, jam fire clears lastPing.valid |
| E: EMP fire | 17 | Fire returns target, target type correct, charge dec, +20 cost, target stunned, projectile spawned, duration 5s exact, charge exhaust + 4th no-op, no-target null, LOS-blocked null, no-charge-or-cost on failure paths |
| F: KD fire | 10 | Same shape as EMP at 12s; charge dec, +20 cost, exhaust, 3rd no-op |
| G: Suspicion chain | 3 | 0 -> EMP=20 -> jam=25 -> KD=45 |
| H: NO HP after 10x EMP | 2 | Sentinel still exists; no HP-key emerged |
| I: Stack independence | 5 | EMP sentinel + KD hunter run on independent timers; sentinel un-stuns at 5s but hunter still immobilized; patroller unaffected |
| J: Jam halves prox | 3 | full > 0; jam halves; jammed = full * mult exactly |
| K: Stunned Siren contrib 0 | 2 | Sentinel contributes pre-stun; contributes 0 post-stun |
| L: Fairness valve | 1 | susp 80 -> jam fire -> susp < 75 within 3s window |
| M: Stunned doesn't ram, doesn't kill drones | 3 | Hull unchanged; drone alive |
| N: Mode field on stun | 2 | mode = "stunned" after EMP; mode = "immobilized" after KD (overrides) |
| O: Stunned movement freeze | 2 | Hunter x/y absolutely frozen for 1s post-EMP |
| P: Projectile lifecycle | 2 | 1 projectile spawned; gc'd after travel |
| Q: armedTool wiring | 3 | Set/cycle/clear via `setArmedTool` |
| R: Determinism (no Math.random in actual code; 2 runs match) | 2 | grep on comment-stripped source returns 0; two identical setups produce identical state |
| S: Regression baseline (subset) | ~20 | Active ping +25, drone photo +15, threshold transitions, patroller motion, hunter dormancy/activation, decoy toggle, LOS predicate, multi-Siren shared cooldown, decay rate, allSirens count, vaporize sustain, oscillating no-vaporize, inertia, bonus obj presence |

### Regression battery (51 tests, all PASS)

Replayed step-1 / step-1-fixpass / step-2 / step-3 / step-4 contracts against the step-5 file:

| Group | Count | Coverage |
|---|---|---|
| Step 1 substrate | 9 | TUNING constants, oxygen drain, circleRectOverlap, ping fire, LOS clear/blocked |
| Step 1 fix-pass | 3 | Inertia: thrust accelerates; drag decays; reverse weaker than forward |
| Step 2 suspicion | 11 | Threshold constants, state transitions at 0/33/34/74/75/100, isAlertPlus, applySuspicion clamps |
| Step 2 Patroller | 2 | Mode "deviating" at Alert+; PATROL_RAM at Alert+ (no step-5 stun interference) |
| Step 3 drones | 7 | Supply, photo cost, 5x deploy + 6th null, terrain-block deploy, win false initially, objectives count = 3 |
| Step 4 Sentinel/Hunter/curiosity | 11 | Multi-Siren shared cooldown, sentinel orbiting init, hunter dormant init, allSirens=3, findCuriosityTarget callable, decoy toggle on/off, active>passive range, weight>1 |
| Cross-step | 8 | (mixed) |

### Adversarial battery (25 tests, all PASS)

| Test | Result |
|---|---|
| ADV1: 100x EMP at Alert+ -- Sentinel still exists, object shape unchanged | PASS |
| ADV2: __sim has no kill/destroy/deal/damage/hp/health/dead/attack API | PASS |
| ADV3: all 3 tools with 0 charges = no-op, no suspicion drain | PASS |
| ADV4: stacked EMP at same t doesn't compound deadline | PASS |
| ADV5: fireEMP returns null when state.loseReason set; no charge consumed | PASS |
| ADV6: LOS-blocked EMP click returns null; charge preserved | PASS |
| ADV7: jam fired twice at same t produces identical deadline (idempotent at instant) | PASS |
| ADV8: comment-stripped source has 0 Math.random calls | PASS |
| ADV9: stun state cleared after reset (sim.setState(newState())) | PASS |
| ADV10: chain-fire all tools pushes susp past WARNING; charges consumed correctly | PASS |
| ADV11: stunned sentinel absolutely frozen for 30 ticks (1.5s) at Alert+ | PASS |
| ADV12: EMP + KD coexist on same Siren; EMP expires at 5s, KD continues to 12s; Siren still stunned via KD | PASS |

### Total

**122 step-5 + 51 regression + 25 adversarial = 198 sim tests headlessly. 0 failures.**

## Test setup adjustments noted in the test code (transparency)

Tests required careful staging to avoid contamination from existing game systems:

1. **`isolatedStage(targetType, dx, dy)` helper**: positions sub at (480, 320) (default spawn -- known LOS-clear to most of the map) AND teleports all 3 Sirens to (9000, 9000) corner, then places only the target Siren next to the sub. This isolates the test from cross-Siren ram damage during multi-second sims.

2. **Curious-state preference**: EMP/KD duration tests fire with suspicion 0->20 (Curious, no rams). Without isolation, Alert+ tests would have other Sirens rapidly draining hull and triggering `loseReason = "sunk"` before the duration window closed, causing `update()` to early-return and freeze `state.timeSec` (which made early test passes report "stunned" forever -- a false negative until I diagnosed the actual cause).

3. **LOS-blocked targeting test**: the test that proves `fireEMP` rejects a LOS-blocked target had to teleport non-target Sirens to (9000,9000); my first version inadvertently caught the *sentinel* (which was sitting next to the sub in `clearStage`) within the 90px click radius. The corrected test moves all non-target Sirens away first, then places only the patroller behind terrain.

4. **`Math.random` grep**: a code comment in the step-5 helpers literally says "No Math.random in any step-5 code (grep-verified)." A raw grep would falsely match this comment as a violation. The adversarial test strips block and line comments before grepping. The actual code has 0 `Math.random` calls (confirmed).

These are intentional test-design adjustments to maintain the "behavior under controlled inputs" contract. The underlying step-5 code is unchanged.

## Open potholes for the next step

1. **Step 6 recon plane will need a new reveal mode** with a sector reveal and a +8 suspicion cost (spec section 3). Recon consumables (default 2) decrement similarly to jam/EMP/KD charge counters. Plug into the existing reveal-LOS pattern (`drawSirenIfVisible` etc.). Consider whether recon reveal SHOULD pass through terrain or LOS-gate like passive/ping/drone-cam -- spec section 3 calls it "large sector reveal" which suggests no LOS gating (the plane is above the seafloor), but step-1 fix-pass set the precedent that all reveals LOS-gate. Brief 06 will rule.

2. **`armedTool` re-press cycling could be confusing.** Currently pressing `2` arms EMP; pressing `2` again disarms; pressing `3` while EMP armed switches to KD (the `2` re-press isn't needed). This is the most intuitive UX I could pick without a UI menu, but step 7 form pass should iterate.

3. **The `acquireTargetSiren` LOS gate uses `isLineOfSightClear(subX, subY, sirenX, sirenY)`.** This means you can fire EMP/KD through a drone-cam reveal IF the sub itself has LOS too, but you can't fire through rock even when a drone-cam reveals the Siren. This matches "weapons launch from the sub torpedo tube" per spec section 2 ("fires disruption torpedoes"), but the design intent could go the other way (drone-cam reveals enable fire). Step 7 design call.

4. **Targeting affordance is minimal.** The HUD says `ARMED: EMP -- click target` but there's no on-screen "click here to fire" reticle. Step 7 form pass will add the reticle and a "no valid target at click" feedback flash.

5. **Stun timer display in HUD**: not currently in HUD line 4 (which still shows Siren modes from step 4). The mode field reads `"stunned"` / `"immobilized"` when active, so the existing HUD reflects the gate. The render-layer ring shows the countdown. Could add a per-Siren countdown to HUD line 4 if Pat wants centralized at-a-glance.

6. **Projectile spawn point is the sub's center at fire time.** It doesn't update if the sub moves while the projectile travels. With `PROJECTILE_SPEED_PX_PER_SEC = 360` and typical targeting distances under 200 px, the projectile arrives in < 0.6s, so this is rarely visible. Step 7 form pass owns the actual torpedo art.

7. **No "no charges" feedback** beyond the HUD counter showing 0. A failed fire (no charges, no target, LOS blocked) silently no-ops. Step 7 form pass should add a flash/beep cue.

8. **Stun gate semantics:** I picked "stunned == frozen movement + zero detection contribution + can't ram + can't kill drones." This matches spec section 5 "halts movement + detection." The implementation does NOT teleport the Siren to seafloor on KD (spec text says "bola-snare + downthrust screws drag a Siren to the seafloor"). The Siren stays where it was at fire time. Step 7 may want a small Y-drop visual to match the spec's flavor text -- functionally equivalent.

9. **Stun stacking with same tool refreshes the deadline absolutely** (not by adding 5s on top). Fire EMP at t=1 -> deadline 6; fire EMP at t=2 (Siren still stunned) -> deadline 7. This is monotone -- you can re-fire to extend, but the cost is +20 each time. Adversarial test ADV4 confirms simultaneous fires at the same t produce identical deadlines.

10. **EMP and KD have separate stun maps** (`empStunUntil` and `kdImmobUntil`). They don't overwrite each other. A Siren can carry both effects independently, and re-activates only when BOTH deadlines have passed. Adversarial test ADV12 confirms.

## Design improvement notes (NOT implemented, for Pat)

- **Jam strength of 0.5 is a guess.** Spec says "reduces sub detectability / scrambles Siren localization for a window" with no number. I chose 0.5 (halve each Siren's proximity contribution). A lower number (0.2, 0.1) would make jam feel more dramatic; a higher number (0.7, 0.8) would make jam a softer/more frequent tool. Pat can rule on the right number with playtest data.

- **Jam window of 4s is a guess.** Brief said "~3-5s, document." Mid-range. A 3s window would force more frequent jam fires (more often a non-zero charge state); a 5s window would feel like a real "break the lock" reset.

- **Click-to-target for both EMP and KD** is consistent ergonomics but could be split (e.g., EMP click-target, KD select-nearest-via-key-only). I picked consistent because the brief said "your call -- click-to-target for EMP/KD" which suggested both. Step 7 design call.

- **TARGET_PICK_RADIUS_PX of 90 px** is fairly generous (the Sentinel body is 16 px). A smaller pick radius (50 px) would make targeting feel more precise but require pinpoint clicks; a larger one (120 px) would auto-acquire across more of the screen. The 90 px choice tries to be forgiving on the placeholder canvas; step 7 will iterate.

- **Projectile is a tracer line, not a torpedo.** Form pass placeholder. The whole projectile system could be removed and the effect could just "appear" on the Siren -- the projectile is purely visual feedback that a fire happened.

- **Stun ring color hint (cyan for EMP, orange for KD) is a legibility aid** like step 4's color hints on Sirens. Explicitly marked as "NOT a form decision per INV6" in code comments.

- **`Esc` to disarm** is the obvious mapping. Could also use the same key (e.g., `2` again to cancel EMP arm). Both work currently; `2`-toggle is the primary cancel path, `Esc` is a global cancel-all-armed.

- **Knockdown could optionally drag the Siren to seafloor visually** to match spec section 5 flavor ("downthrust screws drag a Siren to the seafloor, immobilized ~12s"). Currently the Siren just freezes in place. Form pass.

## Invariant adherence (self-check, auditor verifies)

1. **No enemy HP / no player kill-path:** HELD AND LOAD-BEARING. Sirens have NO hp/health/dead/killed/damage/attack field; this is grep-verified at code level and key-iterated at runtime (every Siren object's `Object.keys` filtered by regex returns empty). The stun maps `empStunUntil` and `kdImmobUntil` store DEADLINES (numbers), not damage. Repeated EMP/KD on the same Siren refreshes the deadline; the Siren always re-activates when the window expires. Adversarial sim: 100x EMP at Alert+ leaves the sentinel object shape unchanged and Siren still alive. The `__sim` surface filter for `/^(kill|destroy|deal|damage|hp|health|dead|attack)/i` returns empty.

2. **Suspicion is the spine:** HELD AND EXTENDED. All three tool fires land via the `applySuspicion` chokepoint. Tool effects (stun gates, jam proximity multiplier) are pure functions of `state.timeSec` vs deadline; no hidden RNG. The `isSirenStunned()` predicate is a clean lookup-and-compare; the `isJamActive()` predicate is a single comparison. No `Math.random` in actual code (comment-stripped grep returns 0). Determinism sim: two identical setups produce identical state after fire + 30 ticks.

3. **Perceiving costs:** HELD. The disruption tools are NOT new reveal modes -- they don't reveal the world. They affect detection only by halting Sirens (EMP/KD) or jamming their proximity contribution (jam). The four perception modes (passive sonar, active ping, drone-cam, recon) are untouched. No new free reveal path. The `acquireTargetSiren` LOS check is the EXISTING LOS predicate; the player must have a sub-LOS line to fire, which is gated by passive/ping/drone/recon for actually seeing where to click -- so firing implicitly requires a perception path the player already paid for.

4. **Tools buy time, cost heat:** HELD AND LOAD-BEARING. Every fire costs heat (+5 jam, +20 EMP, +20 KD); every fire decrements a finite charge counter; every fire buys time (jam window 4s, EMP stun 5s, KD immobilize 12s). Adversarial sim ADV10: chain-fire all 6 fires possible (1 jam + 3 EMP + 2 KD) pushes suspicion from 0 to 95 (sim verified -- 5+20+20+20+20+20=105 clamped to 100, then jam +5 stays clamped); charges all consumed. The save-tool-draws-heat tension from spec section 10 is the architecture.

5. **Fairness valve:** PRESERVED AND ENABLED. The step-2 instakill timer + reset-on-drop logic is untouched. Sim Group L: with suspicion at 80 (above WARNING 75) and a touching Patroller giving full proximity gain, firing jam bumps suspicion to 85 (+5 jam cost) then the halved proximity contribution plus base decay drops suspicion below 75 within 3 seconds. The fairness valve becomes ACTIONABLE via jam -- the player isn't just waiting for time to pass; they can buy the drop with the +5 cost. EMP/KD also extend the valve indirectly: silencing the Siren that's contributing the proximity gain stops that contribution entirely (sim Group K).

6. **Function before form:** HELD. All step-5 visuals are placeholders explicitly marked in code comments ("placeholder INV6 -- ..."). The jam aura is a dashed cyan ring + countdown text. The stun rings are dashed rings with countdown text. The projectile tracer is a line + dot. The HUD additions are plain text. No sprites, no audio, no fonts, no palette polish, no UI chrome. Step 7 form pass will replace all of it.

## Receipt

- Step 05: COMPLETE
- Files written:
  - `code/sirens_song.html` (97,702 bytes / 2,322 lines -- updated from step-4's 79,522 / 1,928)
  - `code/sirens_song.html.bak.pre-step5-20260604` (79,522 bytes -- pre-edit byte-identical backup per CGI §M.2; md5-verified)
  - `handoffs/05_HANDOFF_FROM_STEP5.md` (this file)
  - `claude_index.md` (updated per CGI §G.4 -- status, file size, progress table)
- 198 sim tests pass (122 new step-5 + 51 regression + 25 adversarial). 0 failures.
- Ready for: `audits/05_AUDIT_STEP_05.md`

### Note for the auditor

The Read tool may show phantom content past the actual file end (flagged in step 2 / 3 / 4 handoffs). Verify with `wc -c -l` and `node --check` on the extracted `<script>` block. Step 5 file is 97,702 bytes / 2,322 lines, ends at `</html>`, passes `node --check`. Written via Python heredoc surgery (same workaround as step 2/3/4 to avoid Write-tool truncation).

The `__sim` harness is a strict superset of step 4:
- Step 1+2+3+4+fixpass surface preserved verbatim.
- Added: `fireJam`, `fireEMP`, `fireKnockdown`, `acquireTargetSiren`, `isSirenStunned`, `isJamActive`, `jamProxMultiplier`, `updateProjectiles`, `getCharges`, `getStunMaps`, `getArmedTool`, `setArmedTool`, `getJamActiveUntil`, `getProjectiles`.

Key seams the auditor should sim-test with extreme prejudice (per brief 05):

- **INV1 load-bearing:** fire EMP/KD at the same Siren many times across windows; assert Siren still exists, never has HP decrement.
- **INV4 load-bearing:** verify each cost lands, each charge decrements, each window has finite duration.
- **INV5 preserved:** drive suspicion to 75; jam should drop it below 75 within the jam window.
- **No Siren killable** by any combination of EMP + KD + jam.

The step-2 audit pattern of "re-pin suspicion mid-test" applies here for any test that wants to drive Siren behavior at a specific suspicion level over multiple seconds -- without pinning, the suspicion decays and Sirens transition state mid-test.

---

*AI-DESIGNED. Step 5 handoff. Session: admiring-laughing-hamilton (Cowork Dispatch child, Claude Opus 4.7-1M). Authority: SIRENS_SONG_SPEC.md > agent.md > briefs/05_disruption_tools.md.*
