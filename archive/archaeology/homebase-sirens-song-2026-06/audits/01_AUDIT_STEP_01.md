# Audit — Step 01 sub_sonar_terrain

**Auditor session:** admiring-laughing-hamilton (Cowork Dispatch child, Claude Opus 4.7-1M)
**Audited step handoff:** `handoffs/01_HANDOFF_FROM_STEP1.md`
**Audited code state:** `code/sirens_song.html` (425 lines, 16,230 bytes — new file at this step)
**Audit performed:** 2026-06-04 ~01:55 UTC

---

## Invariant checks

| Invariant | Status | Evidence |
|---|---|---|
| 1. No enemy HP / no player kill-path | PASS | No Siren / enemy / HP / damage / kill / attack symbols anywhere in code (regex scan clean). No entities exist beyond the sub. No player weapon. Trivially held at substrate stage. |
| 2. Suspicion is the spine | PASS (deferred) | Suspicion system lands in step 2 per spec §11. Code has a single explicit hook at `tryActivePing()` line 169–170 (`// STEP 2 HOOK — suspicion +25 on active ping`). No competing threat models wired. No Math.random in source (no RNG fallback). |
| 3. Perceiving costs | PASS | Two reveal modes exist; both spec-aligned. Passive sonar = free 90px ring (spec §3 row 1, "the only constant"). Active ping = wide ring (360px) with explicit +25 suspicion hook ready for step 2. No third reveal path found. Drone-cam and recon correctly deferred. |
| 4. Tools buy time and cost heat | PASS (deferred) | No tools in step 1 per spec §11. Step 5 scope. Nothing pre-emptively wired. |
| 5. Fairness valve | PASS (n/a + traceability held) | No suspicion ⇒ no instakill mechanism ⇒ valve n/a. The lose conditions that DO exist are §10-traceable: `loseReason="sunk"` from terrain/edge contact, `loseReason="suffocated"` from oxygen drain. Cooldown gate (0.6s) prevents instant 3-hull drain on a single contact event — a step-1 fairness gesture aligned with §10.4. |
| 6. Function before form | PASS | Placeholder geometry only: rectangles for terrain, triangle for sub, monospace text HUD, plain `#000` background. CSS comment at line 7 explicitly disclaims it as placeholder. No `Image()`, no `Audio`, no `@font-face`, no non-monospace font, no sprite loading. |

---

## Step scope check

| Check | Status | Evidence |
|---|---|---|
| Stayed within step 01 scope | PASS | Code symbols for `siren / drone / suspicion / recon` appear ONLY inside hook comments and the closing handoff note in line 20 of the HTML (`active ping (+25 suspicion HOOK; suspicion lands in step 2)`). Zero references to those concepts in executable code paths. Win condition not implemented (correctly — step 3). Tools not implemented (correctly — step 5). |

---

## Code hygiene checks

| Check | Status | Evidence |
|---|---|---|
| Syntax valid | PASS | Extracted `<script>` block (15,157 bytes) passes `node --check`. Headless load via DOM-stub also succeeds; `window.__sim` exposed and operable. |
| Single file | PASS | Only `code/sirens_song.html` exists in `code/`. HTML+JS+Canvas all inline. |
| No fabricated tuning numbers | PASS | 9 tuning constants reviewed: HULL_MAX=3 (spec default), PING_DURATION_SEC=3.0 (spec table), OXYGEN_MAX_SECONDS=240 (within "≈ enough for one unhurried full run" qualitative bound, flagged), SUB_SPEED_PX_PER_SEC=80 (within "slowly", flagged), SUB_TURN_RATE_RAD_PER_SEC=1.8 (flagged, no spec default), PING_RADIUS_PX=360 (within "wide", flagged), PASSIVE_RADIUS_PX=90 (within "rough nearby blips", flagged), HULL_HIT_COOLDOWN_SEC=0.6 (no spec default, flagged, serves §10 fairness), SUB_RADIUS_PX=8 (placeholder geometry). All non-default values flagged for step 7 tuning per agent.md §5.1. |
| No scope creep | PASS | See step scope check above. |
| Invariant comments present where critical | PASS | Header block at lines 26–47 cites INV1–INV6 with status. INV5 traceability comment at line 201. INV6 comment at line 7 (CSS) and line 356 (drawSub). INV3 hook docstring at lines 156–162. |

---

## Handoff completeness checks

| Check | Status | Evidence |
|---|---|---|
| All required fields per agent.md §5.2 | PASS | Handoff contains all 10 required sections: What I built / State of file / Spec sections implemented / Tuning values / Sim tests run / Open potholes / Design improvement notes / Invariant adherence / Receipt. |
| Tuning values documented | PASS | Table at handoff lines 38–49 with all 9 constants, sources, and FLAG markers. |
| Sim tests logged | PASS | Table at handoff lines 56–73 with 16 sim test results, all PASS, methodology described (Node + DOM stub + `__sim` harness). |
| Receipt present | PASS | "Step 01: COMPLETE" + file list + Ready-for line at handoff lines 116–121. |

---

## Sim tests I ran

Methodology: extracted `<script>` block to `/tmp/script_block.js`, stubbed `document`/`window`/`performance`/`requestAnimationFrame`, loaded via `new Function(...)`, drove `window.__sim` API directly.

| Test | Expected | Result |
|---|---|---|
| TUNING.HULL_MAX === 3 | true | PASS (3) |
| TUNING.PING_DURATION_SEC === 3.0 | true | PASS |
| TUNING.OXYGEN_MAX_SECONDS > 0 | true | PASS (240) |
| TUNING.SUB_SPEED_PX_PER_SEC === 80 | matches handoff | PASS |
| No input, dt=1.0 → sub position unchanged | true | PASS |
| Oxygen drains exactly 1.0s per dt=1.0 | true | PASS (240 → 239) |
| Edge contact at (5,320) → hull 3→2 | true | PASS |
| Edge clamp moves sub to x ≥ SUB_RADIUS | true | PASS (x=8) |
| Cooldown blocks 2nd hit at +1 tick | true | PASS (hull stays at 2) |
| Hull reaches 0 → loseReason="sunk" | true | PASS |
| Update freezes in lose state (oxygen unchanged after 1s) | true | PASS (oxy=239.984 unchanged) |
| Oxygen → 0 → loseReason="suffocated" | true | PASS |
| Oxygen clamps to 0 (no negative) | true | PASS |
| Ping fires → tStart === current timeSec | true | PASS (tStart=0) |
| Ping still active at elapsed=1.5s | true | PASS |
| Ping expired at elapsed=3.5s | true | PASS |
| Ping in lose state is no-op | true | PASS (tStart unchanged) |
| newState() defaults: hull=3, oxy=240, lose=null, tStart=-Infinity, cooldown=0 | true | PASS |
| circleRectOverlap inside detection | true | PASS |
| circleRectOverlap far-case rejection | true | PASS |
| Full oxygen-budget run: 0.1s ticks → suffocate at OXYGEN_MAX | true | PASS (2401 ticks ≈ 240.1s) |

---

## Adversarial sims

| Attack | Result |
|---|---|
| Try to kill a Siren (chain pings/anything) | n/a — no Sirens exist yet (correctly deferred to step 2). 50 sequential pings → sub hull unchanged, no lose state. |
| Try to find a free reveal beyond passive | None found. Only two reveal paths: passive (spec-permitted free) and active ping (step-2 +25 hook present). |
| Try to make Math.random or RNG drive state | No `Math.random` anywhere in the source — verified by grep. All state transitions are dt-driven. |
| Try to infinite-loop hull cooldown bypass | Sustained edge-pressure simulation (sub jammed back to x=3 every tick) drained hull at exactly 0.65s intervals (0.0s, 0.65s, 1.30s) → reached sunk state in 1.30s. Cooldown holds; cannot bypass. |
| Try to ping after lose state | Confirmed inert: tStart remained -Infinity after two `tryActivePing()` calls on `loseReason="sunk"` state. |
| Try to scope-creep via comment-only references | "suspicion / siren / drone / recon" appear in source text but exclusively in comments + the HUD help string (line 20). Grep for non-comment occurrences returned 0. |
| Try to restart out of fresh state | `setState(newState())` returns to hull=3, oxy=240, lose=null. R-key handler at line 148 correctly gated on `state.loseReason` (cannot reset during a live run). |
| Try to make oxygen go negative | Confirmed clamp at line 257 holds: oxygen → 0 exact. |

No adversarial sim broke an invariant.

---

## Notes

- One PARTIAL test in my first pass (`sustained edge contact drains hull stepwise`) initially read as failure but on inspection was a test-design flaw, not a code bug: the headless harness can't simulate held WASD input, so after the first edge clamp the sub sits stationary at x=8 with no further contact. Re-tested with explicit per-tick re-positioning (`s.sub.x = 3`) — passed cleanly with three stepwise hull drains 0.65s apart. The code behavior is correct.
- The handoff's stated sim test count (10 line items, ~15 sub-tests) matches what I re-verified independently. No reconciliation issues between handoff claims and observed code state.
- Open pothole #1 in the handoff (the explicit step-2 suspicion hook at `tryActivePing()`) is verified present in code at lines 169–170, exactly as described. Step 2 has a clean seam to land on.
- Open potholes #2–#5 are all tuning-value flags for step 7 — handoff and code agree, all flagged numbers stay within spec qualitative bounds. No fabrications.
- Open pothole #8 (visibility model: sub itself always drawn, not hidden) is a defensible reading of the spec — spec §3 doesn't require hiding the player ship, and an unviewable player ship would be unplayable. Logged as design note for step 7; not a step-1 failure.
- Design improvement notes (heading-locked thrust vs. strafing; edge-collision = hull loss harshness) are properly flagged as Pat-decision items and were NOT implemented.

---

## Verdict

**GREENLIGHT**

### Rationale

All six domain invariants hold at the substrate stage. All step-01-scope features are present and behave per spec. Code is single-file, syntax-valid, sim-testable via the `window.__sim` harness the step-agent built (which is a genuine quality-of-life add for downstream auditors and step agents — within spirit of agent.md §6, not scope creep). Tuning numbers are either spec defaults or qualitative-bound picks with explicit FLAG markers for step 7. Handoff is complete per agent.md §5.2.

22 sim tests + 8 adversarial sims all pass. The single initial test failure was a harness-design artifact, not a code bug — re-tested with corrected setup, code behaves correctly.

No fix-pass required. No Pat intervention required.

---

## Receipt

- Audit complete: YES
- Verdict: GREENLIGHT
- Orchestrator action: FIRE NEXT STEP

---

*AI-DESIGNED. Auditor: Keel (Cowork Dispatch child, session admiring-laughing-hamilton, Claude Opus 4.7-1M). Authority: SIRENS_SONG_SPEC.md > agent.md > briefs/AUDITOR_BRIEF.md > briefs/01_sub_sonar_terrain.md.*

**GREENLIGHT**
