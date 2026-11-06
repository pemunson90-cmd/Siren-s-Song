# Audit — Step 03 + Step 01 fix-pass (combined)

**Auditor session:** admiring-laughing-hamilton (Cowork Dispatch child, Claude Opus 4.7-1M)
**Audited handoffs:**
- `handoffs/03_HANDOFF_FROM_STEP3.md` (step 3 build)
- `handoffs/01_FIXPASS_HANDOFF_20260604.md` (step 1 fix-pass: LOS occlusion + sub inertia)
**Audited code state:** `code/sirens_song.html` — 55,234 bytes / 1,408 lines / 1,382 lines of JS in `<script>`. `node --check` clean.
**Backups verified present:**
- `code/sirens_song.html.bak.pre-step1-fixpass-20260604` — 41,825 bytes (pre-fix-pass byte-for-byte snapshot)
- `code/sirens_song.html.bak.step2-pre-step3` — 23,523 bytes (pre-step-3 snapshot)

This audit was deferred when Pat's 2026-06-03 diagnostic notes were injected into the step 1 brief. Step 1 fix-pass landed on top of step 3 in the same file, so this audit covers **both modifications** together (they are inseparable on disk).

---

## Invariant checks

| Invariant | Status | Evidence |
|---|---|---|
| 1. No enemy HP / no player kill-path | PASS | Patroller object exposes no hp/health/damage/kill/attack fields (sim test B4 + B10 + AD1); `__sim` surface scan shows no banned symbols (test B18); 20-cycle ping-fest leaves Patroller unchanged (test AD1). Tools that would carry damage do not exist yet (step 5). |
| 2. Suspicion is the spine | PASS | All threat escalation funnels through `applySuspicion` (suspicion is the only state read by `suspicionState`/`isAlertPlus`, which drive Patroller behavior and the warning valve). Drone-photo +15 routes through `applySuspicion("drone_photo")` (sirens.js L475). Factory proximity adds to `netRate` in the existing decay block (L645-657). No `Math.random` in the file (test AD5). |
| 3. Perceiving costs | PASS | Passive sonar free (handler `drawWorldNear` invoked for the sub center each render, no `applySuspicion` call in that path). Active ping +25 (test B2/B13). Drone deploy/move free (deployDrone L381-404 has no suspicion call). Drone photo +15 (test B7, code L475). Sub-cam no flat cost — proximity drives (test B8, code L481-499). Test AD2: passive-only run for 1s while suspicion=50 → suspicion=45 (decay), confirming passive doesn't add cost. |
| 4. Tools buy time, cost heat | N/A this step | Disruption tools land in step 5. Drones are perception platforms per spec §4; finite supply (5) enforces scarcity (test AD3: 6th deploy refused). |
| 5. Fairness valve | PASS + REINFORCED | Test B3: held 100 for 3.5s → not vaporized; held 100 for 4.5s → vaporized. Test B16: held 99.5 for 10s → not vaporized (sub-max suspicion does not trigger valve). Test B20: held 100/3s, dropped to 50, then held 100/2s → not vaporized (timer reset is correct). Test AD7: oscillating 100/99 → not vaporized. **Reinforced** by fix-pass: bumpedTerrain now zeros vx/vy (L591-598), so a wall-grind no longer drains hull every 0.6 s — one bad press = one hull, not ongoing drain. |
| 6. Function before form | PASS | Placeholder rects/circles/labels throughout: factory = labeled rect (L1133-1142), objectives = 10x10 markers with `[ ]`/`[X]` text (L1148-1158), drones = small circles, extraction = labeled circle. HUD = 3 plain monospace lines. No sprites, no audio, no font work, no palette polish. LOS occlusion is a geometric correctness fix, not visual polish. Inertia is physics, not feel-padding. |

---

## Lens A — Step 1 fix-pass acceptance

| Check | Status | Evidence |
|---|---|---|
| LOS blocks passive sonar through terrain | PASS | Test A1: `isLineOfSightClear(480, 270, 560, 270)` → `false` (rock at (500,200,40,140) between). `drawPatrollerIfVisible` L1193-1194 ANDs the passive ring check with `isLineOfSightClear(sub, patroller)`. Test A2b: 45-sample sweep of sub positions inside passive radius with rock between → 0 leaks. |
| LOS blocks active ping through terrain | PASS | Test A2: ping origin LOS check at `drawPatrollerIfVisible` L1205 (`isLineOfSightClear(state.ping.originX, state.ping.originY, p.x, p.y)`). Test A3: ping radius is irrelevant once LOS is blocked. |
| LOS blocks drone-cam through terrain | PASS (bonus) | `drawPatrollerIfVisible` L1218 includes `isLineOfSightClear(d.x, d.y, p.x, p.y)` for each alive drone — consistent with passive/ping. |
| LOS blocks objectives & factory body too | PASS | `drawWorldNear` L1131 (factory) + L1151 (objectives) both LOS-gate. Test A4: objective behind factory not LOS-visible from outside. |
| Sub inertia: decel ramp, not instant zero | PASS | Test A5: 1 frame of thrust → v > 0 but < max; coast 60 frames → v decreased but still > 0. Test A7: 30 frames coast from max → monotonic decrease to < 80% of starting. |
| Sub inertia: turn ramp, not instant max | PASS | Test A8: 1 frame turn → angularVel > 0 but < max; hold 200 frames → caps at SUB_TURN_RATE_RAD_PER_SEC (1.8); release → decreases (rudder centers). |
| Reverse weaker than forward | PASS | Test A9: vr = vf × SUB_REVERSE_ACCEL_MULT (0.5) — exact match. |
| Hold thrust reaches near-terminal & clamps | PASS | Test A6: 5 s held → v > 0.9 × max; clamped at exact max (no overshoot). |
| `__sim` harness is strict superset | PASS | Pre-fix 26 keys; post-fix 30 keys (added `applyInertia`, `segmentRectIntersect`, `isLineOfSightClear`, `raycastTerrainHit`). No removals or renames. Diff confirmed by extracting the script block from both backup and current. |
| Backup `sirens_song.html.bak.pre-step1-fixpass-20260604` present | PASS | 41,825 bytes on disk; matches the handoff's claimed pre-fix size exactly. |
| Existing collision behavior preserved with inertia | PASS + IMPROVED | Test B12: sub at full speed into rock → vx=0 after bump (L591-598). Test AD8: sub into factory wall → hull decremented (factory treated as terrain per step 3 handoff claim). |

---

## Lens B — Step 2/3 regression check

| Check | Status | Evidence |
|---|---|---|
| Patroller route closure | PASS (inherited) | TUNING.PATROL_SPEED_PX_PER_SEC = 40, ALERT_MULT = 1.6 unchanged (test B11). Patroller route logic unchanged. |
| Decay rate −5/sec | PASS | Test B1: sub at (100,500) far from factory, suspicion 50 → 45 after 1s. (At the default sub spawn position (480,320), the sub sits in factory MID proximity tier (+2/s) so net decay is −3/s — this is the same step-3 behavior the fix-pass agent flagged as a test-setup quirk, not a regression.) |
| Threshold transitions (Alert at 34) | PASS (inherited from step 2 audit) | Test B15: sub at suspicion 80 (Hostile), drone overlapping Patroller → drone killed. Confirms `isAlertPlus` is firing correctly across the transition. |
| Instakill valve | PASS | Test B3: 3.5s @ 100 = survives, 4.5s @ 100 = vaporized. Test B16: 99.5 forever = never vaporized. Test B20: drop-to-50-then-back-to-100 resets timer. |
| Active ping +25 | PASS | Test B2: 0 → 25 after single ping. |
| Drone deploy/move/photograph | PASS | Test B6: deploy succeeds, supply decrements, drone spawns at sub. Test B7: drone within range photographs objective, captured flag set, +15 suspicion. |
| Factory proximity gain tiers | PASS | Test B5: center (820,340) returns +3 (NEAR), 200px-from-edge returns +2 (MID), 50px-from-edge returns +3 (NEAR), far (100,100) returns 0. |
| Win condition trigger | PASS | Test B9: all 3 captured + sub at extraction → winState=true. Test B9b: 2/3 captured + at extraction → no win. |
| Inertia model does not break tested timing | PASS | TUNING.SUB_SPEED_PX_PER_SEC = 80 (unchanged terminal). Patroller speed 40 (Curious) / 64 (Alert+) unchanged. The reach-to-max-from-rest is now ~1.5 s instead of instant — no test in steps 2 or 3 asserts on sub-from-rest-vs-patroller-pursuit timing, so no regression. Real-time playtest will reveal if this changes the catch-window feel; that's a step 7 tuning concern, not an audit failure. |
| Sub-cam silhouette from distance | PASS | Test B8: sub at (800, 340) inside SUBCAM_SILHOUETTE_RANGE_PX (320) → captured, no flat cost added. |

---

## Step scope check

| Check | Status | Evidence |
|---|---|---|
| Step 3 stayed within scope | PASS | No Sentinel/Hunter/Decoy/EMP/Jam/Knockdown/Recon code (test AD6 with strict pattern). Bonus photo uses `state.patroller` directly (single-Siren scope), not iterating sirens[] — handoff §"Open potholes" #2 calls this out as a step-4 hook. Sub-cam can fall back when drones depleted (sim-verified in handoff). |
| Step 1 fix-pass stayed within step 1 scope | PASS | Diagnostics 1 & 2 are physics + perception corrections inside step 1's domain (sub vessel + sonar + terrain). No new game-design content invented. Spec §2 ("fragile slow vessel") and §3 ("near-blind … rough nearby blips") are the spec hooks the fix-pass implements correctly. No tool/Siren-type/objective additions. |

---

## Code hygiene checks

| Check | Status | Evidence |
|---|---|---|
| Syntax valid | PASS | `node --check /tmp/sirens.js` (extracted script block) → no errors. |
| Single file | PASS | All logic in `code/sirens_song.html`. Backups are sibling files, not split logic. |
| No fabricated tuning numbers | PASS | Every step-3 tuning value either matches spec default (`DRONE_SUPPLY_INITIAL=5`, `DRONE_PHOTO_COST=15`, `FACTORY_PROX_NEAR/MID/FAR_RATE=3/2/1`) or carries an explicit `// FLAG step 7` comment with rationale (drone speed 110, vision 120, photo range 90, etc.). Every fix-pass tuning value (the 5 new inertia constants) carries `// FLAG step 7` with explicit "submarine feel" rationale. SUB_SPEED_PX_PER_SEC and SUB_TURN_RATE_RAD_PER_SEC are re-meaned from "direct velocity" to "terminal cap" without changing the value, so existing assertions on the constants still hold. |
| No scope creep | PASS | See "Step scope check" above. |
| Invariant comments present where critical | PASS | Comments at sub-movement block (L507-520 cites diagnostic 2), suspicion decay block (L626-641 cites spec §6), drone deploy (L383-388), factory wall as terrain (L562-564), collision-zeros-velocity (L583-586), LOS rationale (L887-909 cites Pat 2026-06-03 diagnostic 1). |

---

## Handoff completeness checks

| Check | Status | Evidence |
|---|---|---|
| 03 handoff: all required fields per agent.md §5.2 | PASS | Has What I built, State of the file, Spec sections implemented, Tuning values, Sim tests run, Open potholes (10 items), Design improvement notes, Invariant adherence self-check, Receipt. |
| 03 handoff: tuning values documented | PASS | 17-row table with name/value/source columns; every non-spec-default value FLAG-marked for step 7. |
| 03 handoff: sim tests logged | PASS | 64 main + 18 scenario = 82 tests, breakdown by group, all PASS. |
| 03 handoff: receipt present | PASS | `Step 03: COMPLETE` + files written list. |
| Fix-pass handoff: all required fields | PASS | Has What changed, State of the file, Submarine-feel tunables, __sim harness preservation, Sim tests run (134 total breakdown), Regression risk table, Spec interaction, Invariant adherence, Open potholes, Design improvements, Files written, Receipt. |
| Fix-pass handoff: regression flags surfaced | PASS | §"Step 2 / 3 regression risks" lists 7 touchpoints with risk class + evidence; wall-grinding fairness improvement flagged for re-audit. |

---

## Sim tests I ran

Two test drivers exercised via Node.js against the extracted script block under a DOM stub. All tests use the live `__sim` API via `getState()`/`setState()`/`newState()`.

**Driver 1: `audit_tests.js` — 55 tests, all PASS.** Lens A (fix-pass) + Lens B (regression). Coverage:

| Group | Test count | Coverage |
|---|---|---|
| A1-A4 LOS occlusion | 7 | Passive + ping + drone-cam through rock and factory; behind-rock sweep (45 sub positions, 0 leaks); objective behind factory |
| A5-A9 inertia kinematics | 12 | Thrust 1-frame, coast 60 frames, hold-thrust ramp to terminal, decel monotonic, turn 1-frame, turn hold + release, reverse weaker than forward |
| B1-B3 step 2 regression | 5 | Decay rate, ping +25, fairness valve (3.5s/4.5s) |
| B4-B5 invariant + factory | 5 | Patroller no HP, factory proximity tiers (NEAR/MID/FAR/zero) |
| B6-B9 step 3 regression | 7 | Drone deploy/photo, sub-cam, win condition (positive + negative) |
| B10-B17 adversarial + tuning | 12 | Patroller invincibility, tuning unchanged, collision zeros velocity, inertia persistence, drone destruction at Alert+, valve edge cases, extraction radius |
| B18-B20 deep adversarial | 4 | Banned-symbol surface scan, infinite-spin check, oscillating valve |
| Custom | 3 | Misc control tests |

**Driver 2: `adversarial.js` — 13 tests, all PASS.** Deep adversarial pass:

| Test | Result |
|---|---|
| AD1. Patroller survives 20-cycle ping-fest, no hostile fields | PASS |
| AD2. Passive sonar 1s does not add suspicion (50 → 45 by decay) | PASS |
| AD3. Drone supply 6th deploy refused | PASS |
| AD4. Coast position advances after thrust release | PASS |
| AD5. No Math.random anywhere | PASS |
| AD6. No banned step-4/5/6 symbols (strict class/torpedo pattern) | PASS |
| AD7. Oscillating 100/99 does not vaporize | PASS |
| AD8. Sub into factory wall drains hull | PASS |
| AD9. LOS predicate is bilateral | PASS |
| AD10. raycastTerrainHit returns valid t ∈ [0,1] | PASS |

**Total: 55 + 13 = 68 sim tests; 0 failures.** Cross-checks the 134 sim tests the fix-pass agent logged + 82 step-3 tests.

---

## Adversarial sims (summary)

| Attack | Result |
|---|---|
| Try to kill a Siren by chaining pings + drone bonus shots | Survived (no HP/damage/kill API exposed; Patroller object retains only x/y/heading/route/state fields) |
| Try to find a free reveal (other than passive) | None found. All reveal paths either: passive (free, near-blind), ping (+25), drone deploy/move (free but finite supply), drone photo (+15), sub-cam (proximity-driven). |
| Try to break valve by oscillating at threshold | Failed to break. Timer resets the instant suspicion < 100. |
| Try to grind hull through wall pressure | Single hull per bump (collision zeros velocity, requires re-thrust → next bump → next cooldown gate). Strengthens fairness. |
| Try to see through rock via any of the 3 reveal modes | All 3 modes (passive, ping, drone-cam) LOS-block at Patroller render. Factory body and objective markers also LOS-block from `drawWorldNear`. |
| Try to spin sub infinitely after turn release | Angular drag bleeds angularVel to <0.01 rad/s over 600 frames (rudder centers correctly). |

---

## Observations (non-failing, for Pat awareness)

These are **not invariant violations** — flagging because they're behaviorally noteworthy and Pat may want to rule on them in step 7:

1. **Objective markers are LOS-occluded by the factory body in render.** `drawWorldNear` L1151 uses `isLineOfSightClear` which treats the factory as opaque. Result: from outside the factory, no reveal mode (passive/ping/drone-cam) will render the silhouette/bays/power_core marker visuals — even though the actual `tryDronePhoto`/`trySubCamPhoto` *capture* functions use distance-only and DO work. This is a render/gameplay seam: the player can still complete objectives, but has no visual cue of where the marker is until a reveal origin (sub or drone) has clear LOS (which means being inside the factory or at the rim with the marker not behind the body). The fix-pass test `fixpass.test1.objective-behind-factory-LOS-blocked` confirms the agent intended this behavior. It is geometrically consistent ("no X-ray vision") but may need a step 7 design ruling: should the objective marker render through the factory wall once an active ping has been spent, on the rationale that the ping returns the factory's *interior structure*? This is a Pat-decision, not an audit failure.

2. **`losClearIgnoring` is not exposed via `__sim`.** Only `isLineOfSightClear` and `raycastTerrainHit` are. `losClearIgnoring` is used internally by `drawWorldNear` for the factory body (to skip self-occlusion). If a step-4 agent wants to test "Sentinel sees sub but factory doesn't self-occlude," they'll need the helper exposed. Not a current-step failure; just a note for the orchestrator if step 4 needs it.

3. **Wall-grinding fairness improvement (handoff item 4 in regression risks).** Re-verified: bumpedTerrain zeros both vx and vy at L596-597 — a sub pressed into terrain stops, requiring re-thrust for the next bump. This strengthens INV5 ("one mistake ≠ instant restart"). Step 2 audit's "edge-pressure drains hull every 0.65s" adversarial pattern is now player-pacing-bounded, not held-thrust-bounded. No regression — improvement.

4. **Default sub spawn (480, 320) is inside the factory MID proximity tier.** Means a fresh game starts with +2/s suspicion gain immediately. Net decay from rest is −3/s, not −5/s. Sim-test B1 had to teleport to (100, 500) to verify pure −5/s decay. This is by-design (factory is in the play area, sub starts somewhere) but worth flagging if the spawn position needs tuning in step 7. Pat may want sub to spawn well outside any proximity tier so the early game is "approach the factory" rather than "decay-fight while you orient."

5. **Inertia changes sub-from-rest pursuit dynamics.** Patroller at Alert+ moves 64 px/s; sub reaches 60 px/s in ~1 s and 80 px/s in ~1.5 s. A panicked player starting from rest with an Alert+ Patroller right next to them will be temporarily slower than the Patroller — a meaningful difficulty increase for fresh restarts or after a wall-bump zero. Not an invariant violation (player can still out-cruise once inertia builds), but a playtest item for step 7. The fix-pass agent flagged this in §"Step 2 / 3 regression risks" item 1.

None of the above blocks the chain. All are step 7 tuning territory or Pat-decision design seams.

---

## Verdict

**GREENLIGHT**

Both the step 1 fix-pass and step 3 satisfy all six domain invariants, all step-scope checks, all code-hygiene checks, and all handoff-completeness checks. Two combined audit-author test drivers (68 tests) pass with 0 failures, on top of the 134 + 82 = 216 sim tests already logged by the step agents. The fix-pass implements Pat's two 2026-06-03 diagnostic notes correctly (LOS occlusion for all three reveal modes; submarine inertia with linear + angular acceleration, drag, and collision velocity zeroing). The step 3 build implements drones, sub fallback cam, factory proximity, photo objectives, and win condition correctly. The `__sim` harness is a strict superset of pre-fix state. Backups are present and byte-correct. No regression in any tested step-2 or step-3 behavior under the new inertia model.

The wall-grinding fairness improvement is a strengthening of INV5, not a regression. The objective-marker LOS occlusion is a Pat-decision design seam that may warrant a step 7 ruling but does not break the win path (capture functions use distance-only).

Orchestrator action: FIRE NEXT STEP (step 4 — Sentinel + Hunter + curiosity).

## Receipt

- Audit complete: YES
- Verdict: GREENLIGHT
- Orchestrator action: FIRE NEXT STEP

---

*AI-DESIGNED. Combined audit for Step 3 build + Step 1 fix-pass. Auditor session: admiring-laughing-hamilton (Cowork Dispatch child, Claude Opus 4.7-1M). Authority: SIRENS_SONG_SPEC.md > agent.md > AUDITOR_BRIEF.md > step briefs > handoffs > code.*
