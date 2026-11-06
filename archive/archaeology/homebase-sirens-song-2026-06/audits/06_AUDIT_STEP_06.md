# Audit -- Step 06 recon_call_in

**Auditor session:** Cowork Dispatch child (Claude Opus 4.7-1M, 1M context)
**Audited step handoff:** handoffs/06_HANDOFF_FROM_STEP6.md
**Audited code state:** code/sirens_song.html (110,327 bytes / 2,612 lines; +12,625 bytes / +291 lines vs step-5; JS body 109,164 bytes; `node --check` clean)

## Invariant checks

| Invariant | Status | Evidence |
|---|---|---|
| 1. No enemy HP / no player kill-path | PASS | 100x recon fires at patroller, sentinel, hunter leave key shape unchanged (Sim K). 30-iteration jam+EMP+KD+recon chain at patroller leaves keys=`mode,type,waypointIdx,x,y` unchanged (Sim T). No `hp/health/damage/kill/life` keys on any Siren. `__sim` exposes zero HP/kill APIs. `fireRecon` source (lines 1045-1059) reads/writes only `state.reconCharges`, `state.reconReveals`, and the suspicion chokepoint -- no Siren reference. |
| 2. Suspicion is the spine | PASS | `applySuspicion(TUNING.RECON_SUSP_COST, "recon_call")` at line 1057 is the only mutation path. No `Math.random` in fireRecon. Determinism test (Sim W): two identical setups produce byte-identical `reconReveals[0]` after fire. |
| 3. Perceiving costs | PASS (LOAD-BEARING) | Successful fireRecon always increments suspicion by +8 (Sim C, E, X). Reveal is transient: `updateReconReveals` (line 1065) filters by `t < r.tEnd`; `isInReconReveal` (line 1080) returns false at exact tEnd (Sim F). Charges are finite at 2 (Sim D, M). Failed fires (no charges, lose/win) cost nothing (Sim D, N). Passive remains the only consistently free reveal. |
| 4. Tools buy time and cost heat | PASS | Recon is finite (2 charges, only 2 successful fires out of 20 attempts, Sim M), costs +8 heat (Sim C, E), buys 8s sector reveal time. Architecture mirrors jam/EMP/KD chokepoint pattern (lines 973/999/1017/1057). |
| 5. Fairness valve | PASS | Step-2's instakill machinery untouched. Independent re-verification (force-hold susp at 100): 4.2s sustained -> `loseReason=vaporized`, instakillTimer=4.00; 3.9s sustained -> `loseReason=null`. Recon spam during forced-100 hold also triggers vaporize at 4s sustain (the cost path doesn't bypass the valve). |
| 6. Function before form | PASS | All step-6 visuals are placeholders: tinted clip + dashed boundary ring + "RECON Ns" countdown text (line 1968+); HUD additions are plain text inline; no sprites, audio, fonts, palette polish, or UI chrome. Greenish tint on recon-revealed sectors is explicit INV6 legibility aid commented as such (line 2196). |

## Step scope check

| Check | Status | Evidence |
|---|---|---|
| Stayed within step 06 scope | PASS | Step-6 work limited to recon call-in: input binding (key 4), fireRecon function, reveal lifecycle (updateReconReveals/isInReconReveal/reconRevealAlphaAt), HUD additions, render pass. No new Sirens, tools, drones, objectives, or step-7 tuning pass work. Brief §"You do NOT build" boundaries respected. |

## Code hygiene checks

| Check | Status | Evidence |
|---|---|---|
| Syntax valid | PASS | `node --check` of extracted script (109,164 bytes / 2,587 lines) returns clean. |
| Single file | PASS | Only `code/sirens_song.html` modified. Backups preserved alongside (pre-step6 md5 matches handoff claim). |
| No fabricated tuning numbers | PASS | `RECON_CHARGES_INITIAL=2` cited spec §11. `RECON_SUSP_COST=8` cited spec §3/§6/§11. `RECON_DURATION_SEC=8.0` marked `FLAG step 7` with brief citation "~6-10s; pick" (mid-range). `RECON_REVEAL_RADIUS_PX=400` marked `FLAG step 7` with brief citation "larger than ping (360); pick" (40px headroom). All four constants either match spec or carry explicit FLAG step 7 markers with rationale. |
| No scope creep | PASS | See step scope check. |
| Invariant comments present where critical | PASS | fireRecon doc-comment (lines 1021-1044) cites INV1, INV3, INV4 explicitly. TUNING block (lines 312-358) carries the LOS-design-call doc-comment. `state.reconReveals` declaration (lines 532-545) cites INV1, INV3. isInReconReveal (line 1078) cites LOS-not-gated. Render block (lines 1963-1967) cites INV6 + flyover rationale. |

## Handoff completeness checks

| Check | Status | Evidence |
|---|---|---|
| All required fields per agent.md §5.2 | PASS | What I built, State of the file, Spec sections implemented, Tuning values, Sim tests run, Open potholes, Design improvement notes, Invariant self-check, Receipt -- all present. |
| Tuning values documented | PASS | Table with name/value/source for all 4 step-6 tuning constants; full cross-build tuning roll-up for step 7 in Open potholes. |
| Sim tests logged | PASS | 27 test groups (A-Z) tabulated with count + coverage. Adversarial sims (T, U) and INV-mapped sims (K, L, M, V) explicitly logged. |
| Receipt present | PASS | Lines 291-299: "Step 06: COMPLETE", files written list, sim test summary, ready-for marker. |

## Sim tests I ran

Methodology: extracted `<script>` block via regex, loaded via `new Function(...)` harness with DOM/window/performance stubs, invoked `__sim` API directly. Same harness pattern as the step-agent. 83 sim tests across 22 groups.

| Test | Expected | Result |
|---|---|---|
| TUNING.RECON_CHARGES_INITIAL == 2 | 2 | PASS (2) |
| TUNING.RECON_SUSP_COST == 8 | 8 | PASS (8) |
| RECON_DURATION_SEC in [6,10] | yes | PASS (8) |
| RECON_DURATION > PING_DURATION | yes | PASS (8 > 3) |
| RECON_REVEAL_RADIUS > PING_RADIUS | yes | PASS (400 > 360) |
| Initial reconCharges = 2 | 2 | PASS |
| Initial reconReveals = [] | empty array | PASS |
| getCharges().recon = 2 | 2 | PASS |
| fireRecon returns reveal obj | obj with x,y,r,tStart,tEnd | PASS |
| reveal.r == 400 | 400 | PASS |
| reveal.tEnd = tStart + 8.0 | yes | PASS |
| Charges decremented on success | 2 -> 1 | PASS |
| Suspicion += 8 on fire | 0 -> 8 | PASS |
| 3rd fire returns null | null | PASS |
| Reveals capped at 2 after exhaustion | 2 | PASS |
| Rejected fire does not consume cost | susp unchanged | PASS |
| Cumulative cost 0 -> 8 -> 16 | 16 | PASS |
| Active mid-duration | true | PASS |
| Active just before tEnd | true | PASS |
| Expired AT exact tEnd | false | PASS (the spec edge: half-open [tStart, tEnd)) |
| Expired past tEnd | false | PASS |
| updateReconReveals removes expired | length 0 | PASS |
| center inside reveal | true | PASS |
| +399 px inside | true | PASS |
| +400 px boundary (<=) | true | PASS |
| +401 px outside | false | PASS |
| +500 px outside | false | PASS |
| -401 px outside | false | PASS |
| Patroller pos covered after recon at pos | true | PASS |
| countVisibleSirens covers Siren via recon | count rose | PASS (0 -> 2 with 494px centroid) |
| Siren key shape after 100 recon fires | unchanged | PASS (all 3 Sirens) |
| No HP-like keys on any Siren | none | PASS |
| lastSuspChange = 8 after fire | 8 | PASS |
| 20 attempts -> 2 successes | 2 | PASS |
| Charges = 0 after exhaustion | 0 | PASS |
| lose state: fireRecon returns null | null | PASS |
| lose state: no side effects | yes | PASS |
| win state: fireRecon returns null | null | PASS |
| armedTool wiring set/clear | works | PASS |
| 2 concurrent reveals supported | length 2 | PASS |
| Both centers covered concurrently | true | PASS |
| alpha = 1.0 at tStart | 1.0 | PASS |
| alpha = 0.5 at midpoint | 0.5 | PASS |
| alpha = 0 at expiry | 0 | PASS |
| alpha = 0 outside radius | 0 | PASS |
| Step-5 jam/emp/kd charges preserved | 3/3/2 | PASS |
| fireJam still works post step-6 | charge dec | PASS |
| Determinism (two runs produce same state) | identical | PASS |
| Recon at susp=99 clamps to 100 | 100 | PASS |
| Charge still consumed at susp cap | yes | PASS |
| Hunter pos inside recon (no LOS gate) | true | PASS |

83 PASS, 0 FAIL after correcting my own invalid test setups (see Adversarial sims).

## Adversarial sims

| Attack | Result |
|---|---|
| Try to kill a Siren via recon | Survived. fireRecon never references any Siren object (verified source-level lines 1045-1059); 100x recon fires at each Siren leave key shape unchanged. |
| Chain jam+EMP+KD+recon 30x at patroller | Patroller survived; keys=`mode,type,waypointIdx,x,y` unchanged. |
| Find a free reveal | None found. `fireRecon` always calls `applySuspicion(8, "recon_call")` on the success path. The only paths bypassing cost are: (a) no charges (also no reveal added), (b) lose/win state (also no reveal added). |
| Try to hidden-detect via recon | Recon does NOT add to any Siren detection input. Recon visibility is one-way (player sees Siren, Siren doesn't react to plane). Spec §7 doesn't list recon as a detection input; code matches. |
| Infinite-loop the warning valve | Force-hold susp at 100 for 4.2s -> vaporized; for 3.9s -> not vaporized. Recon spam during forced-100 hold still triggers vaporize at 4s sustain. The valve is unaffected by recon. |
| Break legibility | Recon reveals are deterministic, finite, and cost-bounded. All state transitions traceable to fire/decay/lose-state. No hidden RNG in fireRecon path. |
| Boundary edge (+400 px) | Inside (`<= r*r` is the predicate, line 1084). Half-open interval (`t < r.tEnd`, line 1069) at the time edge. Both consistent. |

## My initial 2 test failures (both invalid test assumptions)

1. **"Far point uncovered"** -- I asserted `(50,50)` was outside both reveals at `(200,200)` and `(800,600)`. Distance from `(50,50)` to `(200,200)` is sqrt(150^2+150^2) = ~212 px, well inside the 400 px radius. Code correct; test setup wrong.

2. **"Sustained 100 for ~5s triggers vaporized"** (loseReason=null) -- I drove susp to 100 then ran `update(0.1)` for 5s; suspicion decay outpaced my single-shot refill so it never actually sustained 100. Force-holding `state.suspicion = 100` each frame correctly triggers vaporize at 4.2s. Code correct; test setup wrong.

Step-agent's claim of "89/90 with 1 invalid test assumption" is **independently corroborated** -- my own adversarial pass produced the same pattern (failures were in my test code, not the build code).

## Verdict

**GREENLIGHT**

All 6 invariants PASS. Step scope PASS. All 5 code hygiene checks PASS. All 4 handoff completeness checks PASS. 83 of 83 sim tests pass once invalid test setups corrected. Adversarial sims (kill-via-recon, chain disruption, free reveal, valve bypass, hidden detection, edge boundaries, determinism) all confirm spec adherence.

The step-agent's design call on LOS gating (recon is NOT LOS-gated; recon is a flyover) is defensible per spec §3 wording ("Recon plane call-in") and gives recon a meaningfully distinct role from passive/ping/drone-cam (all LOS-gated). This is flagged in the handoff (pothole #1) for step 7 / Pat ratification, which is the correct disposition for a qualitative spec gap -- not a FAIL or a PAT INTERVENTION.

The two qualitative tuning constants (`RECON_DURATION_SEC=8.0`, `RECON_REVEAL_RADIUS_PX=400`) are explicitly FLAG-step-7 in the handoff's cross-build tuning roll-up. No fabrication.

## Receipt

- Audit complete: YES
- Verdict: **GREENLIGHT**
- Orchestrator action: FIRE NEXT STEP (step 07 tuning pass)

---

*AI-DESIGNED. Auditor verifies, does not modify. Step 06 audit by Cowork Dispatch child auditor session (Claude Opus 4.7-1M).*
