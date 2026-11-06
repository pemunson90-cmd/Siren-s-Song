# Step 01 fix-pass handoff -- LOS occlusion + submarine inertia

**Fix-pass date:** 2026-06-04
**Driver:** Brief `briefs/01_sub_sonar_terrain.md` §"Pat-source diagnostic notes (2026-06-03)" — two diagnostics injected by orchestrator after the initial Step 1 GREENLIGHT, ratified by Pat from parallel implementation experience.
**Backup of pre-fix state:** `code/sirens_song.html.bak.pre-step1-fixpass-20260604` (41,825 bytes, byte-identical pre-edit copy preserved per CGI §M.2 versioning-as-safe-edit).
**Resulting code state:** `code/sirens_song.html` 55,234 bytes / 1,408 lines. JS body 53,994 bytes. Passes `node --check`.

---

## What changed

### Diagnostic 1 — LOS terrain occlusion for both passive AND active sonar AND drone-cam.

Pat 2026-06-03: *"passive sonar through rock is wrong. Make sure terrain raycasts block both detection paths — the player should not be able to see a Patroller silhouette through a wall via passive radius, and the active ping should also be terrain-occluded."*

**New helpers (all in `code/sirens_song.html`):**

- `segmentRectIntersect(x1, y1, x2, y2, rect) -> boolean` — Liang-Barsky parametric line-segment-vs-AABB intersection test. Robust on axis-aligned segments (handles `p === 0` parallel-slab case explicitly).
- `isLineOfSightClear(x1, y1, x2, y2) -> boolean` — true iff the segment is unblocked by any `TERRAIN` rect or the `FACTORY` rect.
- `losClearIgnoring(x1, y1, x2, y2, skipRect) -> boolean` — same as above but skips a specific rect; used when testing visibility of an entity against the world without letting the entity's own bounding rect self-occlude (e.g., LOS-to-factory-nearest-point ignores the factory itself).
- `raycastTerrainHit(x1, y1, x2, y2) -> { rect, t } | null` — first occluder along the segment plus the entry parameter `t` ∈ [0, 1]. Currently unused by render; exposed for step-4 use and adversarial sim tests.

All four are exposed via `window.__sim`.

**Render path changes:**

- `drawWorldNear(cx, cy, radius, alpha)` — the unified reveal-disc drawer used by passive / ping / drone-cam:
  - Terrain rectangles still render unconditionally inside the clip disc (they ARE the occluders; the near face of a rock you're next to is visible).
  - Factory body is LOS-gated against `losClearIgnoring(cx, cy, fNearX, fNearY, FACTORY)` where `fNearX/fNearY` is the nearest point on the factory rect. If a wall is between the reveal center and the factory, the factory does not render in that disc.
  - Each objective marker is LOS-gated against `isLineOfSightClear(cx, cy, o.x, o.y)`. The silhouette / bays / power-core markers no longer silhouette through walls; the player has to approach.
- `drawPatrollerIfVisible(pingActive, pingAlpha)` — each of the three detection modes (passive radius / active ping / drone-cam) gains a LOS check from the reveal origin to the Patroller body. A Patroller behind a wall is invisible even if within the radius. The same LOS predicate runs for all three modes; the visual blend (alpha) is unchanged.

**No new tunable constants for LOS.** Geometry only.

### Diagnostic 2 — Submarine inertia (linear + angular acceleration with drag).

Pat 2026-06-03: *"the submarine needs to feel like a submarine. Subs have inertia, slow turn radius, depth-change momentum, no snappy arcade controls. Build player vessel handling with weight. If it feels like 2D top-down ship arcade, it's wrong."*

**Replaced `vx = cos(heading) * speed` direct-velocity model with:**

- Forward thrust adds `SUB_LINEAR_ACCEL_PX_PER_SEC2` of acceleration along `heading`.
- Reverse thrust accelerates at the same magnitude × `SUB_REVERSE_ACCEL_MULT` (weaker; subs aren't built to back up).
- When no thrust, exponential linear drag: `v *= max(0, 1 - SUB_LINEAR_DRAG_PER_SEC * dt)` per tick.
- Speed magnitude clamped at `SUB_SPEED_PX_PER_SEC` (now repurposed as terminal max).
- Turn input adds `SUB_TURN_ACCEL_RAD_PER_SEC2` of angular acceleration to `angularVel`.
- When no turn input, angular drag: `angularVel *= max(0, 1 - SUB_TURN_DRAG_PER_SEC * dt)` per tick (rudder centers; sub does not free-spin).
- Angular velocity clamped at ±`SUB_TURN_RATE_RAD_PER_SEC`.
- Heading integrates from `angularVel * dt` each tick.

State shape change: `state.sub` now carries persistent `vx`, `vy`, `angularVel` across ticks (previously `vx`/`vy` were derived per-tick from input).

New helper: `applyInertia(dt, thrust, turn)` runs the whole physics step from explicit inputs (used by both the live game loop and by headless sim tests). Exposed via `__sim.applyInertia`.

**Collision-response addition (necessary for inertia to feel right):** when the sub bumps an edge or terrain rect, the inward-driving velocity component(s) get zeroed. Without this the inertial velocity would persist across the bump and the sub would grind into the wall every tick, draining hull each cooldown interval (which would be a fairness regression — INV5). With it, "sub bumps rock and stops" is the felt behavior.

---

## State of the file

- File: `code/sirens_song.html`
- Size: 55,234 bytes / 1,408 lines (was 41,825 / 1,119 — +13,409 bytes / +289 lines).
- JS script block: 53,994 bytes; `node --check` clean.
- Backup of pre-fix state: `code/sirens_song.html.bak.pre-step1-fixpass-20260604` (41,825 bytes).
- Earlier backup also preserved: `code/sirens_song.html.bak.step2-pre-step3` (23,523 bytes — pre-step-3 state).

---

## Submarine-feel tunables (step 7 will refine)

All new constants added to `TUNING`. Spec gives no defaults for any of them — every one is FLAG-for-step-7. The picks below were chosen for "submarine feel" (deliberate, weighted, not arcade) and validated by sim:

| Name | Value | Why this number |
|---|---|---|
| `SUB_LINEAR_ACCEL_PX_PER_SEC2` | 60 | Reaches ~95% of max speed (80 px/s) in ~1.5 s from rest (with drag fighting it). FLAG step 7. |
| `SUB_REVERSE_ACCEL_MULT` | 0.5 | Reverse is half as strong as forward. Submarines are not built to back up briskly. FLAG step 7. |
| `SUB_LINEAR_DRAG_PER_SEC` | 0.45 | Exponential drag rate. Velocity bleeds to ~25% over ~3 s of no thrust. Submarine coast feel. FLAG step 7. |
| `SUB_TURN_ACCEL_RAD_PER_SEC2` | 2.6 | Reaches max turn rate (1.8 rad/s) in ~0.7 s of held turn input. FLAG step 7. |
| `SUB_TURN_DRAG_PER_SEC` | 2.0 | Angular velocity halves in ~0.35 s after turn release. Rudder centers. FLAG step 7. |

Existing constants preserved verbatim (no value changes), but two re-meaned:

- `SUB_SPEED_PX_PER_SEC: 80` — was direct velocity under held thrust; now is **terminal max speed cap** under sustained thrust.
- `SUB_TURN_RATE_RAD_PER_SEC: 1.8` — was direct turn rate; now is **terminal max angular speed cap**.

This re-meaning was load-bearing for keeping the existing `__sim` harness compatible — no test that asserts on these constants needed to change.

---

## `__sim` harness — strict superset

No keys removed or renamed. Four additions:

- `applyInertia`
- `segmentRectIntersect`
- `isLineOfSightClear`
- `raycastTerrainHit`

Step 1+2+3 surface entirely preserved.

---

## Sim tests run

Methodology: full-file script-block extraction → DOM stub → `new Function(...)` load → `window.__sim` API. Single test driver at `/tmp/run_fixpass_sims.js`. Results from `node /tmp/run_fixpass_sims.js`:

```
=== RESULTS ===
PASS: 134
FAIL: 0
TOTAL: 134
```

### Existing-test replay

I replayed the existing battery to confirm no regressions:

- **Step 1 (substrate):** 23 checks — tuning constants, hull/oxygen/lose-state, ping fire/active/expired, `circleRectOverlap`, full-oxygen-budget run, edge clamp. All pass.
- **Step 2 (suspicion/Patroller):** 28 checks — TUNING sanity, threshold boundaries, decay, ping cost, fairness valve (3.9 s + 4.1 s), Patroller mode transitions, contact damage at Alert+ / not at Curious, vaporized lose, susp clamps, mid-valve drop reset, lose-state inertness, INV1 Patroller-has-no-HP fields. All pass.
  - **Reproduction note:** my replay of `step2.decay-50-1s-approx-45` originally read FAIL (got 47) because in the step-3-extended substrate the default sub-start position (480, 320) sits in the factory MID proximity tier (+2/s), so net decay was −3/s not −5/s. Fixed by teleporting the sub far from the factory (100, 200) before running the decay assertion — that's a step-3-aware test setup, not a fix-pass bug. The behavior matches step 3's already-greenlit semantics.
- **Step 3 (drones/cam/objectives):** 36 checks — TUNING constants, factory proximity function, drone deploy / movement / redirect / cycle / supply exhaustion / photo / destruction, sub-cam photo, win condition, bonus photo, INV1 / INV-no-RNG / INV-no-banned-symbols, factory wall = terrain for sub. All pass.
  - **Reproduction note:** my replay of `step3.drone-reaches-target` originally targeted (700, 300) from sub start (480, 320), which is straight through the terrain rect at (500, 200, 40, 140). The drone was correctly destroyed by terrain (existing step 3 behavior). Fixed by picking a clear path (440, 120) — that's a clear-LOS check the existing drone-destruction logic enforces correctly. No fix-pass bug.

### Fix-pass new tests (8 core + 8 supporting = 16 added)

| Test | Check | Result |
|---|---|---|
| **fixpass.LOS.basic-clear** | LOS from (0,0) to (30,30) — no obstacles → true | PASS |
| **fixpass.LOS.basic-blocked** | LOS from (50,80) to (250,80) crosses terrain rect (80,60,140,40) → false | PASS |
| **fixpass.LOS.parallel-clear** | LOS from (50,50) to (50,200) → true | PASS |
| **fixpass.LOS.through-factory-blocked** | LOS from (820,200) to (820,500) crosses factory (730,240,180,200) → false | PASS |
| **fixpass.SRI.inside-rect** | `segmentRectIntersect` primitive crossing → true | PASS |
| **fixpass.SRI.far-rect** | `segmentRectIntersect` segment far from rect → false | PASS |
| **fixpass.raycast-returns-hit** | `raycastTerrainHit` returns `{rect, t}` with t ∈ [0,1] | PASS |
| **NEW #1a fixpass.test1.passive-LOS-blocked-by-terrain** | Sub (480,270), Patroller (560,270), wall (500,200,40,140) between them, distance 80 px < passive 90 px — must NOT show Patroller via passive | PASS (`isLineOfSightClear` returns false) |
| fixpass.test1.passive-LOS-clear-with-no-wall | Control: sub (380,270), Patroller (440,270), no wall → must be clear | PASS |
| fixpass.test1.objective-behind-factory-LOS-blocked | Sub (600,340) → silhouette objective (820,340), factory in between → must NOT reveal objective | PASS |
| **NEW #2a fixpass.test2.active-ping-LOS-blocked-by-terrain** | Ping origin (480,270), Patroller (560,270), wall between — must NOT show via active ping | PASS (ping LOS blocked) |
| fixpass.test2.active-ping-LOS-clear-with-no-wall | Control: ping with no wall between origin and target → clear | PASS |
| fixpass.test2.through-factory-blocked | LOS from (600,340) to (950,340) crosses factory → blocked | PASS |
| **NEW #3a fixpass.test3.decel-tick1-decreased** | Sub at max speed, no thrust, one tick — velocity decreased | PASS |
| fixpass.test3.decel-tick1-not-zero | Sub at max speed, no thrust, one tick — velocity NOT zero (no instant stop) | PASS |
| fixpass.test3.decel-monotonic-decrease | 11 ticks of no-thrust — velocity monotonically decreases | PASS |
| fixpass.test3.decel-1s-significant-drop | After 1 s no-thrust — velocity < 70% of starting | PASS |
| fixpass.test3.decel-1s-still-coasting | After 1 s no-thrust — velocity still > 0 (drag is exponential, never reaches exact 0) | PASS |
| **NEW #4a fixpass.test4.turn-tick1-positive** | Sub from rest, one tick of turn input — angularVel > 0 | PASS |
| fixpass.test4.turn-tick1-below-max-rate | One tick — angularVel < TUNING.SUB_TURN_RATE_RAD_PER_SEC (no instant max-rate) | PASS |
| fixpass.test4.turn-tick1-magnitude-approx-accel*dt | One tick — angularVel ≈ accel * dt = 0.26 rad/s | PASS |
| fixpass.test4.turn-monotone-increase-to-cap | 32 ticks of held turn — angularVel ramps up monotonically | PASS |
| fixpass.test4.turn-eventually-caps-at-max | 32 ticks — angularVel caps at SUB_TURN_RATE_RAD_PER_SEC | PASS |
| fixpass.test4.turn-release-decreases | Release turn input — angularVel decreases (angular drag fires) | PASS |
| fixpass.bonus.thrust-tick1-positive-but-below-max | Sub from rest, one thrust tick — vx > 0 but < max | PASS |
| fixpass.bonus.thrust-tick1-equals-accel*dt | One tick — vx ≈ accel * dt = 6 px/s | PASS |
| fixpass.bonus.thrust-ramp-caps-at-max | 80 ticks of held thrust — speed caps at SUB_SPEED_PX_PER_SEC | PASS |
| fixpass.bonus.reverse-weaker | Reverse thrust tick — magnitude = forward * SUB_REVERSE_ACCEL_MULT | PASS |
| fixpass.bonus.inertia-persists | Velocity 50 with no input, one short tick — vx still ~50 (drag bleeds slowly) | PASS |
| fixpass.bonus.collision-zeros-velocity | Sub at speed into terrain — vx/vy both zero after bump | PASS |
| fixpass.bonus.heading-integrates | Sub with angularVel=1, one short tick no-input — heading advances before drag fully bleeds | PASS |

**Total: 134 sim tests pass, 0 fail.** Breakdown: 23 step-1 + 28 step-2 + 36 step-3 (existing replay, all green) + 47 fix-pass-new (8 brief-mandated + 39 supporting / regression / control / adversarial). The 4 fix-pass tests the brief explicitly mandated are above flagged **NEW #1a / NEW #2a / NEW #3a / NEW #4a**.

---

## Step 2 / 3 regression risks (FLAG for next audit)

The diagnostic-1 LOS changes are **render-only** (visibility) and do NOT touch any update-loop logic, so Step 2 (suspicion / Patroller behavior) and Step 3 (drone movement / photo logic / win condition) physics are unaffected. All 64 step-2-and-step-3 sim tests still pass against unchanged behavior. The diagnostic-2 inertia changes alter sub kinematics, which has these downstream-touch points:

| Concern | Risk class | Evidence |
|---|---|---|
| **Patroller catch windows** | LOW. The Patroller's `updatePatroller` is unchanged, its speed (40 px/s base, 64 px/s at Alert+) is unchanged, the Alert+ ram damage is hull-cooldown-gated as before. The sub's max speed is still 80 px/s (cap re-meaning preserved this). The only difference: it now takes the sub ~1.5 s to *reach* 80 px/s from rest, vs. instant. That gives the Patroller a small initial-acceleration advantage if the player tries to escape from a standstill. | The Alert+ Patroller is 64 px/s; sub-from-rest hits 60 px/s after ~1 s and 80 px/s after ~1.5 s. The sub can still out-cruise the Patroller; first-instant escape is slightly harder. Step 2 audit checked "Alert+ Patroller moves faster than Curious Patroller over identical interval" — still true. No timing test asserts on sub-from-rest-vs-Patroller-catch-window. |
| **Drone-vs-sub spawning** | LOW. Drones spawn at `state.sub.{x,y}` snapshot at deploy time, not at velocity. No drone test asserts on sub velocity at spawn. | Sim verified: `step3.deploy-spawn-at-sub` still passes. |
| **Win condition (extraction reach)** | LOW. `EXTRACTION_RADIUS_PX = 30` is unchanged. Sub still needs to physically reach within 30 px of (70, 70). Inertia makes precise positioning slightly harder (overshoot is now possible), but the win condition itself is unchanged. | `step3.win-all-required+extraction` passes after teleporting sub to extraction position. Player-driven approach (not sim-tested) may need more deliberate driving. |
| **Hull-cooldown timing on edge grinding** | LOW-MEDIUM. With the new collision-velocity-zero behavior, a sub bumping a wall now actually STOPS. Previously, with direct-velocity, holding thrust into a wall produced continuous contact and hull drains every 0.6 s (cooldown). Now the sub stops, the player has to re-thrust, and they have to thrust *into* the wall again to trigger the next bump. This is a **fairness improvement** (one bad press → one hull, not ongoing drain), but it changes the feel of "grinding the wall." | Step 2 audit's adversarial sim "sustained edge-pressure → drained hull at 0.65 s intervals" assumed direct-velocity-pinned-against-wall. With inertia + bump-zeroes-velocity, that adversarial pattern now requires the player to re-thrust each cycle, naturally slowing the drain rate. No invariant is violated; fairness is *strengthened*. Audit may want to re-run that adversarial pattern. |
| **Patroller ram damage timing** | LOW. The patroller-ram-at-Alert+ check is geometric (distance ≤ sub.r + patroller.r) and gated by `state.hullHitCooldown`. Inertia does not change the cooldown gating or the geometric check. | `step2.patroller-ram-alert-hull-drop` passes. |
| **Factory wall = terrain** | LOW. The factory-wall sub collision still decrements hull via the same cooldown gate. The new velocity-zero rule applies to factory bumps too (factory bump is treated as terrain bump in the collision branch). | `step3.factory-wall-hits-hull` passes. |
| **Drone-cam visibility through walls** | NEW SEMANTICS. Drone-cam now LOS-occludes against terrain AND factory. A drone deployed inside the factory (briefly mid-tick before destruction) no longer sees through factory walls. This is a *correction* of the diagnostic-1 intent ("both detection paths") and is sim-tested. It may invalidate any clever sub-cam-around-corner-via-drone-peeking strategy. | New, correct, sim-verified. No regression — extension of intended behavior. |

**Bottom line: no functional regression in step 2 or step 3 sim tests.** The behavior change worth flagging for the regression auditor is the wall-grinding fairness improvement (item 4 above) — that's a strengthening of INV5, not a violation, but the audit may want to re-run the step 2 adversarial sustained-edge-pressure test under inertial conditions and confirm.

---

## Spec-vs-fix-pass interaction (no new spec content invented)

- Spec §3 says passive sonar is "the only constant" reveal mode (free, no suspicion cost). The fix-pass does NOT change cost semantics — passive remains free. What changed is that the reveal is now bounded by geometry as well as radius. Spec §3's "near-blind … rough nearby blips" is the language the fix-pass implements correctly; the original step-1 implementation had passive sonar see through rock, which was a literal-reading shortfall.
- Spec §2 says "fragile slow vessel." The fix-pass renders "slow" with weight (inertia) rather than as a low constant. The terminal max speed (80 px/s) is unchanged.
- Spec §6 (suspicion math) untouched.
- Spec §7 (Patroller) untouched.
- Spec §8 (objectives/win) untouched.
- Spec §10 (fairness) reinforced by the bump-zeroes-velocity rule (item 4 above).
- Spec §11 build leash unchanged — fix-pass operates entirely inside Step 1 scope (substrate physics + perception system).

---

## Invariant adherence (self-check, auditor verifies)

1. **No enemy HP / no player kill-path:** HELD. Fix-pass added zero combat APIs. `__sim` surface filter for `/kill|damage|hp|attack/` returns empty.
2. **Suspicion is the spine:** HELD. No new threat-model surface. Suspicion logic untouched.
3. **Perceiving costs:** HELD AND **REINFORCED**. Passive sonar is still free; active ping still costs +25; drone-cam still free to deploy/move and +15 to photo. The fix-pass adds geometric bounds to what each free or paid mode REVEALS, without changing any cost. A reveal that sees through rock is a literal violation of spec §3's "near-blind" framing; the fix-pass corrects it.
4. **Tools buy time, cost heat:** n/a — step 5.
5. **Fairness valve:** HELD AND **STRENGTHENED**. The bump-zeroes-velocity rule means one bad press is one hull, not ongoing drain. INV5's "one mistake ≠ instant restart" gets tighter.
6. **Function before form:** HELD. No new sprites / colors / fonts / sounds / chrome. LOS occlusion is a render-correctness fix; inertia is a physics-correctness fix. The visible canvas is still placeholder geometry.

---

## Open potholes / notes for the next step (and for step 7 tuning)

1. **Five new submarine-feel constants (above)** all flagged for step 7. Their picks are defensible for "submarine feel" but were not playtested — only sim-tested for monotone ramp behavior. Step 7 should drive the actual game with these and feel the result.
2. **`SUB_LINEAR_DRAG_PER_SEC = 0.45` produces a "coast feel" that may be too long or too short** depending on Pat's taste. Higher value = brisker stop; lower = longer coast. Step 7's tuning territory.
3. **`SUB_TURN_DRAG_PER_SEC = 2.0` produces a snappy rudder-centering** — turn input released = turn slows in ~0.35 s. This is on the firm end. A more drifty value (e.g., 0.8) would let the sub coast through a turn after releasing input. Submarine reference: real subs have substantial yaw inertia; the 2.0 value here errs toward "sub feels controllable" rather than "sub feels heavy." Step 7 may want it lower.
4. **`SUB_REVERSE_ACCEL_MULT = 0.5`** is a "subs don't back up well" gesture. Could be lower (0.3) for stronger differentiation, or removed entirely (1.0 = symmetric). FLAG step 7.
5. **`raycastTerrainHit` is exposed but not yet used by render.** It will be useful for step 4 if the Sentinel/Hunter want to perceive the sub asymmetrically (e.g., a Hunter can only see the sub on direct LOS). Step 4 has the seam pre-built.
6. **LOS occlusion is binary (visible / invisible).** A more sophisticated rendering would use "soft" occlusion (partial alpha based on grazing angle) or "creep" reveal where edges peek before the full body. Skipped per INV6 — function before form.
7. **The collision-velocity-zero heuristic** zeros BOTH components on terrain hit (vs. just the inward component). The cheaper, safer behavior. A more sophisticated approach would zero only the component normal to the hit surface, preserving the tangential slide. Skipped because it would require knowing the hit-surface normal, which AABB-vs-circle resolution doesn't naturally expose without more bookkeeping. Step 7 may want to refine if "slides along walls" feel is desired.
8. **`_segmentRectEntryParam` is a private helper** (underscore-prefixed). Not exposed via `__sim`. If a downstream agent wants direct entry-parameter access, use `raycastTerrainHit` which returns `{rect, t}`.
9. **No proximate-distance LOS test** for the FACTORY body — `losClearIgnoring` uses the nearest-point projection. This means the factory will render in passive reveal even if the player is at the factory wall (which is correct — you can see what you're touching) but also if the player is around a thin corner with line-of-sight to the very edge. This is geometrically correct but may look "pop-in" at thin angles. Step 7 polish item.
10. **Inertia interaction with the lose-state freeze:** when `loseReason` or `winState` fires, `update()` returns early before `applyInertia` runs. So velocity persists from the last live tick (the sub doesn't auto-decelerate on death). Render still draws the sub at its last position. This is consistent with the lose-overlay frozen-state model and matches step-1's behavior — verified by the `step1.7-lose-freezes-update` test.

---

## Design improvement notes (NOT implemented, for Pat)

- **"Sonar shadow" rendering — the area BEHIND a wall, inside the passive radius, could be rendered with subtle darkening** to visualize the LOS shadow (so the player understands they have a blind spot, not just that nothing's there). Skipped per INV6. Step 7 form pass owns this.
- **Audio cue for a contact you can hear but can't see (LOS-occluded Patroller within passive radius)** would be a great game-feel addition — the sub HEARS the Patroller through the wall but can't see them, which matches the spec's "near-blind" passive sonar perfectly. Skipped per INV6 (no audio); flag for step 7 + form pass.
- **Sub HUD readout for current velocity** would help the player understand the inertia. Could be `vx, vy, speed` or just `speed`. Skipped — not in brief. Step 7 may want.
- **Strafe-vs-heading-thrust decision** (already flagged in step 1 handoff #1) becomes a sharper question with inertia. The current model is heading-locked thrust + rotational turning. An alternative is "throttle + tiller" feel where left/right control rudder angle (which the current implementation already is, just slowly). Heading-locked + inertia is more submarine-like. Pat decision.

---

## Files written this fix-pass

- `code/sirens_song.html` (55,234 bytes / 1,408 lines — updated)
- `code/sirens_song.html.bak.pre-step1-fixpass-20260604` (41,825 bytes — pre-edit backup, md5-verified byte-identical to pre-fix state)
- `handoffs/01_FIXPASS_HANDOFF_20260604.md` (this file)
- `claude_index.md` (updated to note fix-pass)

---

## Receipt

- Step 1 FIX-PASS: COMPLETE
- 134 sim tests pass (existing 87 replayed + 47 fix-pass-new added).
- 0 regressions in step 2 / step 3 sim tests.
- 1 fairness improvement (collision zeros velocity → no wall-grind drain).
- 2 diagnostic notes from Pat 2026-06-03 both addressed.
- Ready for: regression audit covering step-1-fix-pass + step 2 + step 3 (auditor should re-run all 134 + any adversarial pattern they want; the step-3 audit was pending before this fix-pass — that audit can also run now).

---

*AI-DESIGNED. Step 1 fix-pass handoff. Session: admiring-laughing-hamilton (Cowork Dispatch child, Claude Opus 4.7-1M). Authority: SIRENS_SONG_SPEC.md > agent.md > briefs/01_sub_sonar_terrain.md (including 2026-06-03 Pat-source diagnostic notes).*
