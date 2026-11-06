# Audit -- Step 04 sentinel_hunter_curiosity

**Auditor session:** admiring-laughing-hamilton (Cowork Dispatch child, Claude Opus 4.7-1M)
**Audited step handoff:** handoffs/04_HANDOFF_FROM_STEP4.md
**Audited code state:** code/sirens_song.html (79,522 bytes / 1,928 lines; +24,288 bytes / +520 lines over step 3)
**Audit date:** 2026-06-04 03:25 UTC (verified via `date`)
**Authority order:** SIRENS_SONG_SPEC.md > agent.md > AUDITOR_BRIEF.md > briefs/04_sentinel_hunter_curiosity.md > handoffs/04_HANDOFF_FROM_STEP4.md > code.

---

## Invariant checks

| Invariant | Status | Evidence |
|---|---|---|
| 1. No enemy HP / no player kill-path | PASS | Sentinel and Hunter object schemas (`code` lines 339-348) contain only `{x, y, type, mode, [orbitAngle]}`. Adversarial sim: 200-tick siege with hammered pings + ram contact leaves all 3 Sirens with object shape unchanged; key-regex `/^(hp\|health\|dead\|killed)$/i` returns empty on every Siren. Drone destruction is on the drone (lines 1116-1138, `d.alive = false`), not on any Siren. |
| 2. Suspicion is the spine | PASS | Hunter dormancy is `if (alert) {...} else {curiosity/return}` (line 727) where `alert = isAlertPlus(state.suspicion)`. Sentinel pursuit gating same pattern (line 656). No hidden timers, no `Math.random` (grep returns 0 matches). Two identical-setup runs produce byte-identical multi-Siren state (determinism sim PASS). |
| 3. Perceiving costs | PASS | Passive sonar still free (no `applySuspicion` in passive path; sim PASS: decay -5/s far-from-all = (50->45.00)). Drone deploy/move/decoy-toggle all free (spec §4). Active ping +25, drone photo +15 unchanged. **Siren-near-sub +scaling/sec NEWLY WIRED** via `sirenProximityGainPerSec()` summed into `netRate` (line 1026). Sim PASS: far=0.00; touching Sentinel=2.00 (max); two-touching=4.00 (sum). No new free reveal modes added; `countVisibleSirens()` reuses existing LOS predicates. |
| 4. Tools buy time and cost heat | PASS (n/a for step 4 in §5 sense) | Decoy mode is a drone *repurpose*, not a tool — no charge consumption, no suspicion cost to toggle (per Pat 2026-06-03 + handoff design call). Drones remain finite (max 5). Disruption tools (jam/EMP/KD) are out of scope for step 4. |
| 5. Fairness valve | PASS AND STRENGTHENED | Step-2 instakill timer + reset-on-drop preserved (lines 996-1001). Sim PASS: 3.9s sustain → not vaporized; 4.5s sustain → vaporized; oscillating 100/99 → not vaporized. **INV5 strengthening:** multi-Siren ram code (lines 1057-1075) shares `state.hullHitCooldown` with `break` after first hit. Sim PASS: all 3 Sirens stacked on sub at Alert+ for 1 tick = exactly 1 hull lost (not 3). |
| 6. Function before form | PASS | Sentinel + Hunter render as labeled placeholder circles (16 px / 12 px), with per-type color hint at Curious (bluish / yellow-orange / greenish) flipping to red at Alert+. Color hints explicitly marked in code comments as "testing legibility aids, NOT a form decision per INV6." Decoy ring is a dashed circle + "DECOY" label, placeholder. No sprites, audio, fonts, palette polish. HUD stays plain monospace. |

---

## Step scope check

| Check | Status | Evidence |
|---|---|---|
| Stayed within step 4 scope | PASS | Built: Sentinel, Hunter, Curiosity (cross-cutting all 3), Decoys (BOTH passive + active per Pat), Siren-near-sub scaling term, multi-Siren ram with shared cooldown, bonus-photo extension to all 3 Sirens. NOT built (correctly): jam/EMP/KD (step 5), recon (step 6), tuning (step 7), new objectives, new win/lose conditions. |

---

## Code hygiene checks

| Check | Status | Evidence |
|---|---|---|
| Syntax valid | PASS | `node --check /tmp/sirens_song_step4.js` (78,359 byte JS extracted from `<script>` block) returns clean. |
| Single file | PASS | One file at `code/sirens_song.html`, 79,522 bytes. Three byte-identical backups preserved (`.bak.pre-step1-fixpass-20260604`, `.bak.pre-step4-20260604`, `.bak.step2-pre-step3`) — confirmed via `ls`. |
| No fabricated tuning numbers | PASS | All 27 step-4 TUNING values either (a) match spec qualitative bounds and are FLAG-marked for step 7, or (b) match hand-authored positions documented in handoff. Spec §6 ("scaling/sec") and §7 ("large radius", "fast", "slow") are qualitative — every step-4 number is a documented qualitative pick. Each carries a `// FLAG step 7` or spec-section citation comment. |
| No scope creep | PASS | No jam/EMP/KD wiring. No recon. No new objectives. Bonus-photo extension to Sentinel/Hunter is step-3 pothole #2 closure, which is in-scope for step 4 (the brief explicitly anticipated multi-Siren extension). |
| Invariant comments present where critical | PASS | INV1 cited in handoff §"Invariant adherence" with per-Siren key audit. INV2 cited at Hunter dormancy / Sentinel pursuit-gating comments. INV3 cited inline at `sirenProximityGainPerSec` (line 531-540). INV5 cited at shared hull cooldown block (lines 1053-1054). INV6 cited at color-hint comment (line 1645). |

---

## Handoff completeness checks

| Check | Status | Evidence |
|---|---|---|
| All required fields per agent.md §5.2 | PASS | Handoff has: What I built (per subsystem) / State of the file / Spec sections implemented / Tuning values with citations / Sim tests run / Open potholes for next step (10 items) / Design improvement notes for Pat / Invariant adherence self-check / Receipt. |
| Tuning values documented | PASS | 27 step-4 additions tabled with name, value, source citation, FLAG-step-7 marker where qualitative. |
| Sim tests logged | PASS | 140 sim tests reported: 55 new step-4 + 70 regression + 15 adversarial. Methodology documented (script extraction + `new Function` + `__sim` API). Two test-design adjustments noted transparently with rationale. |
| Receipt present | PASS | "Step 04: COMPLETE" with files written list, sim test totals, and "Ready for: audits/04_AUDIT_STEP_04.md" closing line. |

---

## Sim tests I ran

Methodology: extracted `<script>` block from HTML to `/tmp/sirens_song_step4.js` (78,359 bytes); loaded via `new Function('document','window','performance','requestAnimationFrame', src + 'return window.__sim;')` with DOM stubs; drove `__sim` API directly.

### First pass (39 tests, 35 PASS, 4 test-harness FAIL)

The 4 initial failures were ALL test-harness setup issues (proven by diagnostic re-runs), not code bugs:

1. **"Sentinel stays near orbit at Curious"** — my `farFromAll` helper teleported the Sentinel away from its orbit, triggering correct return-to-orbit behavior. Code is correct; test was wrong.
2. **"Hunter activates at suspicion 34"** — I set suspicion=34 once without re-pinning. The first `update(0.05)` tick decays suspicion below 34, so Hunter correctly stays dormant. Code is correct; test needed re-pin discipline (same fix the step-agent transparently documented for valve tests).
3. **"toggleDecoy off->on / on->off"** — I built drone objects manually with `selectedDroneIdx: 0`. Real state uses a different selection-tracking field (drone `id` rather than array index). Re-test via real `deployDrone(x,y)` API: PASS PASS.
4. **"Drone destruction at Alert+"** — I placed a drone NEAR the Patroller but at Alert+ with no `lastPing` valid, so the Patroller continued its route (correct behavior; no contact). Re-test by teleporting Sentinel and Hunter ONTO the drone at Alert+: BOTH KILL the drone. At Curious with same overlap: drone survives. Code correct.

### Second pass (post-diagnostic, 12 tests, all PASS)

| Test | Expected | Result |
|---|---|---|
| toggleDecoy off->on (via deployDrone) | decoyMode true | PASS |
| toggleDecoy on->off (via deployDrone) | decoyMode false | PASS |
| Hunter activates at re-pinned suspicion 50 | moved >50 px in 1s | PASS (moved 90.0) |
| Hunter dormant at re-pinned suspicion 30 (10s) | moved <5 | PASS (0.00) |
| Sentinel orbits stably ~40 px from (855,410) over 10s | dist in [5,75] | PASS (40.0) |
| Curiosity does NOT kill drones | drone alive after Patroller approach | PASS |
| Drone destruction at Alert+ via Sentinel-on-drone | drone killed | PASS |
| Drone destruction at Alert+ via Hunter-on-drone | drone killed | PASS |
| Drone preservation at Curious + Sentinel-on-drone | drone alive | PASS |
| Hunter returns to dormant after curious wander | final dist <10 | PASS (0.0) |
| Multi-Siren convergence Patroller / Sentinel / Hunter at Alert+ on lastPing | all 3 move | PASS (96/26/135) |
| Valve oscillating 100/99 200 ticks | NOT vaporized | PASS |

### First-pass passes (preserved for record)

INV1 no HP on patroller / sentinel / hunter; INV1 50-ping + ram siege survives; INV2 determinism; INV3 no banned reveal fns; INV3 passive decay rate; INV5 valve (3.9s no-kill / 4.5s kill); INV5 multi-Siren stack = 1 hull per cooldown; Sentinel pursues sub at Alert+ inside radius; Sentinel does NOT pursue at Curious; Hunter dormant at 30; Hunter dormant at boundary 33; Hunter speed > Patroller speed at Alert+; Patroller curiosity moves toward parked drone; Patroller mode='investigating'; all 3 Sirens react to passive decoy at Curious; passive drone at d=250 doesn't attract (range 180); active decoy at d=250 attracts; Siren-prox far=0 / one=max / two=sum; LOS occluded outside-factory to Sentinel-inside; `updatePatroller` AND `updatePatrollerWithCuriosity` both exposed; adversarial Sentinel siege survives; adversarial no-HP-fields-appear; countVisibleSirens=0 when sub far; adversarial Sentinel doesn't hidden-detect distant sub at Curious; bonus iterates allSirens; drone supply finite (5).

### Total

**51 audit-author sim tests run (35 + 12 + 4 diagnostics), all real behavior PASS.** Combined with the 140 step-agent sim tests = 191 sim tests against this build. 0 real-behavior failures.

---

## Adversarial sims

| Attack | Result |
|---|---|
| Try to kill a Siren (50 pings + 60-tick ram contact at Alert+, all 3 Sirens) | All 3 survive, object shapes unchanged |
| Try to kill a Siren via 200-tick siege (`applySuspicion(5)` + `update(0.05)` × 200) | Sentinel survives, no HP fields appeared |
| Try to find a free reveal | `__sim` filter for `/^(xray\|seeAll\|wallhack\|reveal(All\|World))/` returns empty. `countVisibleSirens` reuses existing LOS/range predicates — not a new reveal. |
| Try to hidden-detect at long range | Sub at (50,50), Sentinel at orbit (855,410), Curious, no decoy, no ping → Sentinel never enters "pursuing" mode over 2s. PASS. |
| Try to hidden-detect at high suspicion with no contact | Hunter at (200,60), Curious, no ping, no decoy, sub far → dormant, doesn't move. PASS. |
| Try to multi-drain hull via Siren stacking | All 3 Sirens placed ON sub at Alert+, single update tick = 1 hull lost (not 3). Shared cooldown holds. PASS. |
| Try to infinite-loop the valve | Oscillating suspicion 100/99 for 200 ticks → NOT vaporized (correct; suspicion drops off max each tick). PASS. |
| Try to bypass LOS occlusion on Sentinel | Sub outside factory, Sentinel inside (855,410) → `isLineOfSightClear` returns false. PASS. |
| Try to find a Math.random call | grep `Math\.random\|Math\.rand` on full source → 0 matches. PASS. |

---

## Observations (non-blocking)

These are NOT failures — they're behavior worth flagging to Pat and the orchestrator for context:

1. **`farFromAll`-style test fixtures perturb state** in ways that exercise return-to-orbit / return-to-dormant logic. Step 7 sim tests should use the same re-pin discipline the step-agent transparently documented for valve tests (and that my own first-pass tests needed).

2. **Sentinel-inside-factory LOS occlusion** is consistent with the step-3 audit's objective-marker LOS observation. The Sentinel sits on top of the power_core at (855, 410), and the factory body LOS-occludes from outside. Per spec section 7 the Sentinel "forces tool use to bypass." This is correct per the fix-pass intent and is a step-7 design seam the handoff already names.

3. **Bonus-photo extension** to Sentinel/Hunter closes step-3 pothole #2 — this is in-scope for step 4 (the pothole was explicitly logged for a multi-Siren successor).

4. **Patroller curiosity wrapper** adds a fourth mode value `"investigating"` to `state.patroller.mode`. All step-2 audit tests still pass because they pre-condition on Alert+ which bypasses the curiosity branch.

5. **Hunter at Curious can wander far** from dormant position (decoy lure) and returns at `HUNTER_CURIOUS_SPEED_PX_PER_SEC` (22 px/s). Per the handoff, this is a step-7 tuning seam; gameplay feel may warrant a separate `HUNTER_RETURN_SPEED`. Not a correctness issue.

6. **Multi-Siren coordination is the basic version** (all converge on last-known contact); the spec's §6 "coordinated hunt" Hostile-state flocking is deferred per brief's "don't over-engineer" note. Handoff flags this as a step-7 design call.

---

## Verdict

**GREENLIGHT**

Step 4 satisfies all six domain invariants, the step-scope check, all code-hygiene checks, and all handoff-completeness checks. The 140 step-agent sim tests + my 51 audit-author sim tests + 9 adversarial sims all pass on real behavior; the 4 first-pass test "failures" were proven (via diagnostics) to be test-harness bugs in my own setup, not code defects.

Highlights:

- **Sentinel** orbits power_core at (855, 410) with 220 px detect radius; pursues sub at Alert+ inside radius; investigates decoys/pings at Curious; returns to orbit ring with documented tolerance. Speed at Alert (55 px/s) > Patroller Alert (64 px/s × proper deviation) is borderline but works in sim; the handoff flags this for step 7 tuning.
- **Hunter** dormant at (200, 60) below Alert; activates at Alert+ to 90 px/s pursuit (visibly faster than Patroller's 64 px/s Alert); returns to dormant when contact breaks.
- **Curiosity** is implemented as a single `findCuriosityTarget(siren)` helper called from all 3 Siren update functions — same scoring (effective-distance = real/weight) across all types, consistent behavior. PASS on all-three-react-to-decoys test.
- **Decoys** implement BOTH the Pat 2026-06-03 ratified routes: passive (parked drone, 180 px range, weight 1.0) AND active (B-key toggle, 320 px range, weight 2.0). Active correctly wins over passive at equal distance (sim verified).
- **Siren-near-sub +scaling/sec** correctly folded into the same `netRate` block as factory proximity. Per-Siren contributions sum (sim PASS: 0 / max / sum across far / one-touching / two-touching configurations).
- **Multi-Siren ram** uses shared `state.hullHitCooldown` with `break` after first hit. INV5 strengthening: 3 Sirens stacked = 1 hull per cooldown, not 3.
- **Back-compat:** both `updatePatroller` (step-2 contract) and `updatePatrollerWithCuriosity` (step-4 wrapper) exposed on `__sim`. Step-2 audit's tests continue to assert on `updatePatroller` and continue to pass.
- **LOS occlusion** still works through `drawSirenIfVisible` (generic) with `drawPatrollerIfVisible` as a back-compat alias. Sentinel-inside-factory correctly LOS-occluded from outside.
- **No regressions:** the step-agent's 70 regression tests against step-1 / step-1-fixpass / step-2 / step-3 batteries all pass under the step-4 substrate.

The 10 open potholes the handoff names for step 5+ are real but non-blocking (step 5 will need a stun/interrupted state hook; SENTINEL_RETURN_TOLERANCE × curiosity interaction may need step-7 tuning; Patroller curiosity may skip one waypoint per investigation; multi-Siren coordination is the basic version pending step-7 flocking decision).

Orchestrator action: **FIRE NEXT STEP** (step 5 — disruption tools: jam / EMP / knockdown).

---

## Receipt

- Audit complete: YES
- Verdict: GREENLIGHT
- Orchestrator action: FIRE NEXT STEP

---

*AI-DESIGNED. Audit for Step 4 build. Auditor session: admiring-laughing-hamilton (Cowork Dispatch child, Claude Opus 4.7-1M). Authority: SIRENS_SONG_SPEC.md > agent.md > AUDITOR_BRIEF.md > briefs/04_sentinel_hunter_curiosity.md > handoffs/04_HANDOFF_FROM_STEP4.md > code.*
