# Audit -- Step 02 suspicion_patroller

**Auditor session:** admiring-laughing-hamilton (Cowork Dispatch child, Claude Opus 4.7-1M)
**Audited step handoff:** `handoffs/02_HANDOFF_FROM_STEP2.md`
**Audited code state:** `code/sirens_song.html` (633 lines, 23,523 bytes -- ~208 lines added on top of step 1's 425/16,230)
**Audit performed:** 2026-06-04 ~02:23 UTC

---

## Invariant checks

| Invariant | Status | Evidence |
|---|---|---|
| 1. No enemy HP / no player kill-path | PASS | Patroller object fields = `["x","y","waypointIdx","mode"]` only -- zero `hp`/`health`/`damage`/`kill` fields. No `kill()`/`damage()`/`attack()` API anywhere in source (grep + `__sim` surface inspection both clean). The lone `damage` matches are comment text. Adversarial sim: 30 pings chained at the patroller, patroller still walking its route. The word "kill" appears only inside "instakill" (player-death mechanism, INV5) and INV1 comment headers. |
| 2. Suspicion is the spine | PASS | Patroller `mode` (`patrolling` vs `deviating`) derives from `suspicionState(state.suspicion)` at `updatePatroller()` lines 364-373; Patroller speed (`baseSpeed` vs `× alert mult`) derives from `isAlertPlus(state.suspicion)` at lines 387-388. No hardcoded aggression timer. Zero `Math.random` in source. Two identical runs produce bit-identical patroller positions (sim verified). All transitions dt-deterministic. |
| 3. Perceiving costs | PASS | Two reveal modes exist, both spec-aligned. Passive sonar = free 90px ring (spec §3 row 1). Active ping = +25 suspicion now LIVE at `tryActivePing()` line 200 (`applySuspicion(TUNING.SUSP_PING_COST, "active_ping")`). Sim verified: 1 ping = 25, 3 pings stacked = 75. No third reveal path. Drone-cam / sub-cam / recon correctly deferred to later steps. |
| 4. Tools buy time and cost heat | PASS (n/a -- deferred) | No tools in step 2 per spec §11. Step 5 scope. Nothing pre-emptively wired. `applySuspicion()` is the chokepoint future tool sources will land on (good seam). |
| 5. Fairness valve | PASS | Valve implemented at `update()` lines 301-308. `instakillTimer` accumulates dt while `suspicion >= 100`, resets to 0 the instant `suspicion < 100`. Sim verified: 100 sustained 3.9s → not vaporized; 100 sustained 4.1s → vaporized; 99.9 sustained 20s → not vaporized; mid-valve drop from 100→99 resets timer. Decay -5/sec when not in active-ping window. Warning overlay fires at 75+. Patroller ram damage uses the 0.6s hull cooldown so one contact event ≠ hull wipe (INV5 fairness gesture, inherited from step 1). |
| 6. Function before form | PASS | Patroller is a labeled placeholder circle (14px radius) with plain `PATROLLER` text label. HUD remains plain monospace. WARNING text is plain red. Color hint (green Curious / red Alert+) is a testing legibility aid explicitly disclaimed in code comment at line 539 ("NOT a form decision"). No sprites, no fonts, no audio, no palette polish. Defensible per agent.md §7. |

---

## Step scope check

| Check | Status | Evidence |
|---|---|---|
| Stayed within step 02 scope | PASS | Symbols `drone / sentinel / hunter / emp / knockdown / jam / recon / factory / decoy / photo / objective / extraction / win` either absent from executable code or appear only in comments documenting the deferred hooks. Zero `drone` references in executable paths. Patroller is the only Siren type. No win condition. No photo objectives. No tools. No factory-proximity term. Brief's "you do NOT build" list fully respected. |

---

## Code hygiene checks

| Check | Status | Evidence |
|---|---|---|
| Syntax valid | PASS | Extracted `<script>` block (607 lines) passes `node --check`. Headless load via DOM-stub also succeeds; `window.__sim` exposed with strict superset of step 1's surface. |
| Single file | PASS | Only `code/sirens_song.html` in `code/`. HTML+JS+Canvas all inline. |
| No fabricated tuning numbers | PASS | 16 tuning constants reviewed. Step-1 substrate values preserved verbatim (9). Step-2 additions (7): SUSP_MIN/MAX (spec §6), SUSP_PING_COST=25 (spec §3/§6/§11), SUSP_DECAY_PER_SEC=5 (spec §6/§11), THRESH_ALERT=34 / THRESH_HOSTILE=75 / WARNING_THRESHOLD=75 (spec §6/§11 boundary placement), INSTAKILL_SUSTAIN_SEC=4.0 (spec §6/§11), PATROL_SPEED_PX_PER_SEC=40 / PATROL_ALERT_SPEED_MULT=1.6 / PATROL_RADIUS_PX=14 / PATROL_RAM_HULL_DMG=1 / PATROL_DEVIATION_REACH_PX=60 / PATROL_WAYPOINT_TOLERANCE_PX=6 (all FLAGGED for step 7, qualitative-bound picks since spec §7 gives qualitative speed/size only). All non-default values FLAG-marked. |
| No scope creep | PASS | See step scope check above. |
| Invariant comments present where critical | PASS | Header docstring lines 26-45 cites INV1-INV6 with status. INV2/INV3 docstring on `applySuspicion` lines 167-170. INV5 fairness-valve ordering rationale at lines 283-300 (a notably good comment -- explains *why* instakill check runs before decay, which is the non-obvious correctness point). INV1 trivially-held assertion at line 33 + updatePatroller header lines 355-362. INV6 disclaimer at CSS line 7 + Patroller color-hint comment line 539. Spec section citations throughout. |

---

## Handoff completeness checks

| Check | Status | Evidence |
|---|---|---|
| All required fields per agent.md §5.2 | PASS | Handoff contains all 10 required sections: What I built / State of file / Spec sections implemented / Tuning values / Sim tests run / Open potholes / Design improvement notes / Invariant adherence / Receipt. Also includes a "Note for the auditor" block flagging a Write-tool truncation issue resolved via bash heredoc -- transparent. |
| Tuning values documented | PASS | Tuning table at handoff lines 57-72 with all 7 step-2 additions, sources, and FLAG markers for step 7. |
| Sim tests logged | PASS | Sections at handoff lines 76-110 enumerate 35 main-pass tests + 11 adversarial tests + a separate terrain-clearance sim. Methodology described. |
| Receipt present | PASS | "Step 02: COMPLETE" + file list + scrap notes + Ready-for line at handoff lines 141-150. |

---

## Sim tests I ran

Methodology: extracted `<script>` block to `/tmp/sirens_step2.js`, stubbed `document`/`window`/`performance`/`requestAnimationFrame` (no-op rAF so the loop doesn't auto-run), loaded via `new Function(...)`, drove `window.__sim` API directly.

| Test | Expected | Result |
|---|---|---|
| TUNING.SUSP_PING_COST === 25 | true | PASS (25) |
| TUNING.SUSP_DECAY_PER_SEC === 5 | true | PASS (5) |
| TUNING.THRESH_ALERT === 34 | true | PASS (34) |
| TUNING.THRESH_HOSTILE === 75 | true | PASS (75) |
| TUNING.INSTAKILL_SUSTAIN_SEC === 4.0 | true | PASS (4) |
| TUNING.SUSP_MIN === 0, SUSP_MAX === 100 | true | PASS |
| `suspicionState(0..33)` → "CURIOUS" | boundaries at 0 and 33 | PASS both |
| `suspicionState(34..74)` → "ALERT" | boundaries at 34 and 74 | PASS both |
| `suspicionState(75..100)` → "WARNING" | boundaries at 75, 99, 100 | PASS all three |
| 50 → ~45 after 1s decay (no ping) | true | PASS (45) |
| 50 → 0 after 10s decay (clamp at 0) | true | PASS (0) |
| 1 active ping → suspicion = 25 | true | PASS (25) |
| 3 active pings stacked → suspicion = 75 | true | PASS (75) |
| Patroller in Curious + valid lastPing → mode "patrolling" | true | PASS (spec §7 "Deviates ONLY at Alert+") |
| Patroller at Alert+ with valid lastPing → mode "deviating" | true | PASS |
| Patroller-sub overlap at Curious → hull unchanged | true | PASS (hull=3) |
| Patroller-sub overlap at Alert+ → hull -= 1 | true | PASS (hull=2) |
| `__sim` surface has no kill/damage/hp/attack keys | true | PASS ([] empty filter) |
| Patroller object has no hp/health/kill/damage fields | true | PASS (only x/y/waypointIdx/mode) |
| Suspicion clamps at SUSP_MIN on large negative apply | true | PASS (0) |
| Suspicion clamps at SUSP_MAX on large positive apply | true | PASS (100) |
| Ping in lose state is no-op (suspicion stays 0) | true | PASS |
| Update in lose state is no-op (oxygen unchanged) | true | PASS |

---

## Adversarial sims

| Attack | Result |
|---|---|
| Chain 30 pings at the patroller | Patroller still moving, x/y advancing, mode "deviating" -- INV1 held (no destroy/kill API exists to even attempt). |
| Find a free reveal beyond passive | None found. Source grep: only two reveal paths -- passive sonar (spec-permitted) and active ping (+25 wired). Drone/sub-cam/recon correctly deferred. |
| Try to make Math.random / RNG drive state | Zero `Math.random` in source. Two identical-input runs produce bit-identical patroller positions (a=(200.00,200.00) b=(200.00,200.00)). Determinism confirmed. |
| 99.9 sustained 20s → instakill should NOT fire | PASS -- loseReason=null. Only exact 100 accumulates the timer. |
| 100 sustained 3.9s, then drop to 99 → should NOT vaporize | PASS -- loseReason=null. |
| 100 sustained 4.1s → SHOULD vaporize | PASS -- loseReason="vaporized". |
| Mid-valve drop (100→99 at timer=3.0s) → timer resets to 0 | PASS -- timer=0 after one tick at 99. |
| Re-spike to 100 after valve reset → player survives if they break contact again | PASS implicitly (timer reset is the mechanism; sim above shows it works). |

No adversarial sim broke an invariant.

---

## Spec-vs-brief ambiguity (handoff pothole #9) -- AUDITOR RULING

**Issue raised by step-agent:** Spec §6 says "100 sustained >=4s: instakill." Brief §"Scope boundary" says "if suspicion drops below 100 within the 4s, instakill doesn't fire" AND brief §"Sim tests to consider" says "force suspicion to 100, hold for 3.9s, drop to 99; assert instakill does NOT fire." But spec §6 also says "If you... drop below threshold within the ~4s window, you survive" -- and "threshold" is ambiguous (the 75+ threshold? the sustained-max?).

**Step-agent's interpretation (implemented):** spec-literal. Timer resets the instant `suspicion < 100`. Dropping from 100 to 99 is enough to be safe; you do NOT need to drop below 75.

**Auditor ruling: ACCEPTABLE -- no PAT INTERVENTION needed.**

Reasoning:
1. The brief's own sim-test prescription is `100 → 99 → assert no instakill`, which is exactly what the implementation does. The brief's looser narrative wording ("drop below 75 within 4s window" implication) is contradicted by its own concrete test specification. The build agent followed the concrete test spec.
2. The implementation is the **more player-favorable** reading. A stricter "must drop below 75" reset would be a harder, less forgiving valve -- which violates spec §10.4 "mistakes are recoverable via the suspicion-decay + warning valve. One error ≠ instant restart." More-forgiving valve is the conservative reading of the fairness invariant.
3. Spec §6 sentence "Only *sustained* max kills" anchors the language to "max" = 100, not 75. The natural reading is: timer accrues only at max; not-at-max → not accruing.
4. The visual UX matches this -- when suspicion < 100, the yellow "instakill imminent" countdown disappears (line 469), which is the right player signal that they're now safe.

If Pat later wants stricter semantics (drop below 75 to be safe), the code change is one line at line 306 (`< THRESH_HOSTILE` instead of `< SUSP_MAX`) and a sim-test refactor. Logged for step 7 tuning consideration, not blocking step 2.

---

## Other notes

- **Decay paused during active-ping window** (handoff pothole #3): defensible. Spec §6 just says "−5/sec when passive (no pinging/firing...)." The 3.0s ping window is canonically "pinging"; decay pause during that window matches the spec letter. Alternative (decay continues during ping) would also be spec-legal. Step-7 tuning concern at most, not a step-2 failure.
- **Patroller speed numbers (40 base, 1.6× alert)** (handoff pothole #4): qualitative-bound. Spec §7 only says "slow" / "faster." Picks are within "slow" (half sub speed) and "faster" (1.6× is noticeable but not unfair). Properly FLAG-marked for step 7.
- **Patroller doesn't collide with terrain** (handoff pothole #6): defensible. Spec §7 doesn't require Sirens to respect terrain. The handcrafted route was sim-verified to clear terrain (0 clips across 200 samples per segment). Alert+ deviation can cut through rock to reach a lastPing, which the agent transparently flagged. Pat-decision for step 7 (feature or polish item).
- **Warning state collapses Hostile (75-99) and 100-band** (handoff pothole #9 second half): both display as "WARNING" with a numeric countdown distinguishing the truly-imminent case. Spec §6 calls Hostile and the 100-sustained-≥4s "warning state begins at 75+" as one continuous escalation cue. The single label matches spec phrasing.
- **Note for the auditor (Write-tool truncation):** verified -- file is 633 lines / 23,523 bytes complete, ends at `</html>`, JS block passes `node --check`. The bash-heredoc workaround landed the full payload cleanly. (Initial Read tool output showed display artifacts past line 633 but `wc -l` and `tail` confirm the file itself is clean.)
- **`__sim` harness** is a quality-of-life add for auditors (same pattern as step 1, extended). Stays within spirit of agent.md §6.

---

## Verdict

**GREENLIGHT**

### Rationale

All six domain invariants hold. All step-02 scope features implemented per brief; no scope creep into steps 3-7. Code is single-file, syntax-valid, sim-testable. Tuning numbers are either spec defaults or qualitative-bound picks with FLAG markers for step 7. Handoff is complete per agent.md §5.2 with notably good ordering rationale on the fairness-valve check-before-decay (which is the non-obvious correctness point and exactly the kind of thing INV5 depends on).

37 sim tests + adversarial battery (chain pings, RNG check, 99.9-sustained, mid-valve drop, lose-state inertness) all pass. The spec/brief ambiguity flagged at handoff pothole #9 is **acceptable as implemented** -- spec-literal, more player-favorable, matches the brief's concrete sim-test prescription. No Pat intervention required for step 2; the alternative-semantics question can ride into step 7 tuning if Pat wants stricter.

No fix-pass required.

---

## Receipt

- Audit complete: YES
- Verdict: GREENLIGHT
- Orchestrator action: FIRE NEXT STEP

---

*AI-DESIGNED. Auditor: Keel (Cowork Dispatch child, session admiring-laughing-hamilton, Claude Opus 4.7-1M). Authority: SIRENS_SONG_SPEC.md > agent.md > briefs/AUDITOR_BRIEF.md > briefs/02_suspicion_patroller.md.*

**GREENLIGHT**
