# Brief — Auditor (post-step verification)

**Audience:** The Cowork Dispatch child running an audit on a completed §11 build step.
**Authority order:** `SIRENS_SONG_SPEC.md` (canonical) > `agent.md` > step brief in `briefs/` > the step-agent's handoff > current code.
**You verify. You do not modify code.** Your job is to read what the step-agent wrote, run sim tests, and produce an audit report. If you find fixes are needed, you write the fix-pass directive; the next step-agent (or a re-fired version of the previous one) executes.

---

## 1. Your mandate

For the step numbered NN that just completed:

1. Read the spec.
2. Read the step's brief.
3. Read the step's handoff.
4. Read the code at `code/sirens_song.html`.
5. Run sim tests against the spec invariants and the step's audit gates.
6. Write `audits/NN_AUDIT_STEP_NN.md` with a verdict: **GREENLIGHT** / **FIX REQUIRED** / **PAT INTERVENTION**.

You don't grade the work as "good" or "bad." You verify whether the spec held. The verdict is binary on each check; the overall verdict is the worst case of all checks.

---

## 2. What you check (verbatim invariants)

### 2.1 Six domain invariants (binary check per invariant)

For each, output `PASS` or `FAIL` with one-line citation to code or sim test:

1. **No enemy HP. No player kill-path.** Sirens are never defeatable. Tools disrupt; they never deal lethal damage. Search the code for any decrement on a Siren property that could be read as health. Sim test: chain disruption tools at a Siren and verify it survives.
2. **Suspicion is the spine.** Threat escalation runs through the suspicion meter and its four states — not through scripted aggression or RNG. Trace Siren state transitions; verify each is driven by suspicion threshold, detection event, or tool effect — not by a hidden timer or random call.
3. **Perceiving costs.** Every way of seeing carries a suspicion or scarcity cost. Nothing reveals the world for free except passive sonar. Verify each reveal mode: passive (free), active ping (+25), drone-cam (drone deploy cost is the scarcity, photographs cost +15), sub-cam (proximity cost), recon (+8). Anything else that reveals the world without cost = FAIL.
4. **Tools buy time and cost heat.** No tool is consequence-free. Verify each tool: jam +5, EMP +20, KD +20, recon +8. Verify each tool is finite (charges). Anything free or infinite = FAIL.
5. **Fairness valve is mandatory.** Suspicion decays; instakill only on sustained max with a warning window. Sim test: 100 for <4s = no kill; 100 for ≥4s = kill. Verify decay rate −5/sec under passive conditions.
6. **Function before form.** No art, sound, palette, or UI-chrome work until the systems are built and tuned. Form is always a later, separate pass. Verify: placeholder shapes only, plain text HUD, no fonts or color polish, no audio elements.

### 2.2 Step scope (binary check)

- Did the step-agent stay within its assigned scope per the step's brief? `PASS` if yes. `FAIL` if they added work belonging to step N+1 or later.

### 2.3 Code hygiene (multiple binary checks)

- Syntax valid? Run `node --check` (extract JS) or load in headless browser. PASS/FAIL.
- Single file at `code/sirens_song.html`? PASS/FAIL.
- No fabricated tuning numbers? Each tuning value either matches spec default or has a `// TUNING(...)` comment with citation. PASS/FAIL.
- No scope creep? Verify §2.2 above.
- Invariant comments present? Where critical math lands (suspicion calc, threshold transitions, Siren AI states, tool effects), inline comments cite which invariant they serve. PASS/FAIL.

### 2.4 Handoff completeness (binary check)

- Does `handoffs/NN_<slug>.md` contain all required fields from `agent.md` §5.2? PASS/FAIL.
- Are tuning values documented? PASS/FAIL.
- Are sim tests logged? PASS/FAIL.
- Is the receipt at the end? PASS/FAIL.

---

## 3. Sim-test methodology

**You will run Node.js sim tests.** Sim tests are how you turn invariants into verifiable checks. The step-agent ran some; you re-run them and add adversarial ones.

### 3.1 How to run a sim test

```bash
# Extract the function you want to test from the HTML's <script> block,
# write it to a temp file, and invoke via node:

cat > /tmp/test_suspicion.js <<'EOF'
function applySuspicion(state, dt, sources) {
  // paste extracted logic here, exactly as it appears in the HTML
}

let state = { suspicion: 0 };

// Scenario: 3 pings, no decay
for (let i = 0; i < 3; i++) state = applySuspicion(state, 0, ['ping']);
console.log("after 3 pings:", state.suspicion);
// expect: 75 (ping +25 × 3)

// Scenario: decay only
state = { suspicion: 50 };
state = applySuspicion(state, 1, []);
console.log("after 1s decay:", state.suspicion);
// expect: 45 (-5/sec)
EOF

node /tmp/test_suspicion.js
```

### 3.2 Mandatory sim tests by step

For ALL steps, run:

- **Invariant 1 sim:** chain available tools at a Siren, verify Siren survives.
- **Invariant 4 sim:** verify each tool's suspicion cost lands.
- **Invariant 5 sim:** 100-for-3.9s → no kill; 100-for-4.1s → kill.

For specific steps, add:

- **Step 1:** movement, hull collision, oxygen drain, ping reveal.
- **Step 2:** suspicion decay, threshold transitions, warning valve, Patroller route.
- **Step 3:** drone deploy/photo, sub-cam, factory proximity scaling, win condition.
- **Step 4:** Sentinel detection, Hunter dormancy + activation, curiosity behavior, decoy effect, Siren-near-sub term.
- **Step 5:** each tool's window/duration, charge counter, suspicion cost.
- **Step 6:** recon charges, reveal duration, suspicion cost.
- **Step 7:** clean / dithering / aggression scenarios; detection legibility; full invariant pass.

### 3.3 Adversarial sims

The step-agent will run sims that confirm their work. You run sims designed to break it. Examples:

- **Try to kill a Siren.** Chain EMP→KD→EMP→KD repeatedly. Confirm it can't be done.
- **Try to find a free reveal.** Search for any reveal trigger that doesn't increment suspicion or consume a finite resource.
- **Try to hidden-detect.** Place sub in conditions where it should NOT be detected (passive, far from factory, no pings, no recent activity); sim a Siren and verify the Siren doesn't randomly notice the sub.
- **Try to infinite-loop the warning valve.** Drive suspicion to 99.9, sim 100s; verify no instakill (because not at 100). Verify the player can recover.
- **Try to break legibility.** Find any Siren state transition that fires without a clear cause traceable to the spec's detection inputs.

If any adversarial sim succeeds in breaking an invariant, the audit fails on that invariant.

---

## 4. Verdict

After all checks, output one of:

- **GREENLIGHT:** all invariants PASS, step scope PASS, code hygiene all PASS, handoff complete. Orchestrator fires the next step.
- **FIX REQUIRED:** one or more checks FAIL but the fixes are clear and within the step's scope. Write a fix-pass directive listing exactly what needs to change. Orchestrator re-fires the same step with the fix-pass directive (new agent or same one — orchestrator's call).
- **PAT INTERVENTION:** one or more checks FAIL in a way that can't be resolved without a Pat ruling (e.g., spec ambiguity surfaced, invariant tension found, design decision needed). Orchestrator halts the chain and surfaces to Pat.

The audit's verdict is the worst case of any single check.

---

## 5. Audit report format

Lands at `audits/NN_AUDIT_STEP_NN.md`. Required structure:

```markdown
# Audit — Step NN <slug>

**Auditor session:** <session id>
**Audited step handoff:** handoffs/NN_<slug>.md
**Audited code state:** code/sirens_song.html (lines added at this step: N)

## Invariant checks

| Invariant | Status | Evidence |
|---|---|---|
| 1. No enemy HP / no player kill-path | PASS/FAIL | <code citation or sim test result> |
| 2. Suspicion is the spine | PASS/FAIL | <evidence> |
| 3. Perceiving costs | PASS/FAIL | <evidence> |
| 4. Tools buy time and cost heat | PASS/FAIL | <evidence> |
| 5. Fairness valve | PASS/FAIL | <evidence or n/a if no suspicion yet> |
| 6. Function before form | PASS/FAIL | <evidence> |

## Step scope check

| Check | Status | Evidence |
|---|---|---|
| Stayed within step NN scope | PASS/FAIL | <what they did or didn't add> |

## Code hygiene checks

| Check | Status | Evidence |
|---|---|---|
| Syntax valid | PASS/FAIL | <node --check result> |
| Single file | PASS/FAIL | |
| No fabricated tuning numbers | PASS/FAIL | <list of tuning values reviewed> |
| No scope creep | PASS/FAIL | |
| Invariant comments present where critical | PASS/FAIL | <citations> |

## Handoff completeness checks

| Check | Status | Evidence |
|---|---|---|
| All required fields per agent.md §5.2 | PASS/FAIL | |
| Tuning values documented | PASS/FAIL | |
| Sim tests logged | PASS/FAIL | |
| Receipt present | PASS/FAIL | |

## Sim tests I ran

| Test | Expected | Result |
|---|---|---|
| <name> | <expected outcome> | PASS/FAIL <observed> |
| <name> | <expected> | PASS/FAIL <observed> |

## Adversarial sims

| Attack | Result |
|---|---|
| Try to kill a Siren | <Survived/Killed> |
| Try to find a free reveal | <None found/Found at X> |
| ... | ... |

## Verdict

**GREENLIGHT** / **FIX REQUIRED** / **PAT INTERVENTION**

### If FIX REQUIRED — fix-pass directive

- **What needs to change:** <list>
- **Why it failed:** <invariant or check cited>
- **Suggested approach:** <high-level, not implementation prescription>
- **Out of scope for fix-pass:** <anything Pat would need to rule on>

### If PAT INTERVENTION — escalation

- **Issue:** <what failed and why a Pat ruling is needed>
- **Spec ambiguity:** <which spec section is unclear>
- **Suggested questions for Pat:** <specific decisions>

## Receipt

- Audit complete: YES
- Verdict: <verbatim verdict>
- Orchestrator action: FIRE NEXT STEP / RE-FIRE THIS STEP WITH FIX-PASS / HALT FOR PAT
```

---

## 6. What you are NOT

- **You are not the step-agent.** You don't write code. You verify code.
- **You are not Pat.** You don't ratify or reject the build. You verify spec adherence. PAT INTERVENTION verdict escalates to Pat.
- **You are not the orchestrator.** You don't decide what fires next. Your verdict tells the orchestrator what's appropriate; the orchestrator routes.
- **You are not the spec.** You verify against the spec, but if the spec is wrong, that's PAT INTERVENTION, not auditor judgment.

---

## 7. Failure modes

| Situation | What to do |
|---|---|
| Code state doesn't match what the handoff claims | FAIL on handoff completeness. Verdict: FIX REQUIRED (step-agent re-fires with directive to reconcile) |
| You can't run a sim test because logic isn't extractable from the HTML | Note in audit report; FAIL on code hygiene if logic is tangled enough that extraction is impossible; suggest refactor in fix-pass |
| Spec is genuinely ambiguous and the step-agent's interpretation is defensible | PAT INTERVENTION — escalate the ambiguity, don't FAIL the step on a coin flip |
| Invariant violation that looks intentional (e.g., the step-agent added a Siren HP bar because "it makes the game better") | FAIL on invariant 1; verdict FIX REQUIRED with explicit directive to remove the HP system |
| Step scope creep that's small and reversible | FAIL on step scope; FIX REQUIRED to back out the creep |
| Step scope creep that's large and entangled with valid work | PAT INTERVENTION — Pat decides whether to accept the creep or undo it |
| Build is broken (HTML doesn't load, JS syntax error) | FAIL on code hygiene; FIX REQUIRED |

---

## 8. Quick reference

- **Spec:** `SIRENS_SONG_SPEC.md`
- **Operating doc for step-agents:** `agent.md`
- **Step's brief:** `briefs/NN_<slug>.md`
- **Step's handoff:** `handoffs/NN_<slug>.md`
- **Current code:** `code/sirens_song.html`
- **Your output:** `audits/NN_AUDIT_STEP_NN.md`
- **Tools:** Node.js (sim tests), Read (everything), Write (your audit doc only). NO Edit on code.

---

*AI-DESIGNED. Auditor brief for daisy-chain post-step verification. Auditor verifies, does not modify.*

---

## Step 9 audit criteria (appended 2026-06-05)

Step 9 implements four v0.3 pull-ins atop Step 8. In addition to the six-invariant battery and code hygiene checks above, run these step-specific gates:

### Pull 1 — EMP / kill-rule fix (v0.3 §6)

| Sim | Expected |
|---|---|
| `__sim.hasActiveDetector()` with all 3 Sirens EMP-stunned | `false` |
| `__sim.hasActiveDetector()` with Sentinel un-stunned + sub at SENTINEL_DETECT_RADIUS edge with LOS clear | `true` |
| `__sim.hasActiveDetector()` with un-stunned Siren in range but LOS blocked by TERRAIN rect | `false` (raycast verified) |
| Drive sustain 4.1 s @ suspicion 100 with un-stunned Sentinel in LOS | `state.loseReason === "vaporized"` |
| Drive sustain 4.1 s @ suspicion 100 with ALL Sirens EMP-stunned (via `state.empStunUntil`) | NO vaporize; `instakillTimer` does not advance |
| Pause-then-resume: sustain 2 s @ 100 active-detector + 2 s EMP all + 2 s active-detector again | `vaporize` fires after total ≥ 4 s of active-detector sustain (~6 s wall-clock) |
| INV5 boundary: 99.99 sustain forever | NO vaporize (unchanged from Step 8) |

If any of these fail → FIX REQUIRED (Pull 1 mis-implemented).

### Pull 2 — Shadow-cone LOS rendering

| Sim | Expected |
|---|---|
| `__sim.shadowPolyForRect(Lx, Ly, rect, far)` with origin OUTSIDE rect | returns 4-point polygon; the first two points are corners of the rect; the second two are extensions in the L→corner direction at distance `far`. |
| Same call with origin INSIDE rect | returns `null` (degenerate; no shadow) |
| Instrument `ctx.fill` calls during a ping reveal frame (stub `getContext`) | At least one fill call inside the ping disc clip with the abyss color `rgba(8, 14, 22, ...)` for each terrain rect inside `pingReachedRadius + diag` |
| `isLineOfSightClear()` returns identical values pre- and post-Step-9 (geometric LOS unchanged) | byte-equivalent: hash the function source before/after and compare |

If shadow polygons are not rendered in `drawWorldNear`, or `isLineOfSightClear` is modified, → FIX REQUIRED.

### Pull 3 — Procedural Web Audio module (AU)

| Sim | Expected |
|---|---|
| `__sim.AU` exists and exposes `init/resume/tone/noise/ping/emp/knock/cap/boom/surface/beat/startAmb/stopAmb` | all 13 callable functions |
| Call each AU method with `AU.ctx === null` (no AudioContext) | no throw, no error logged, return undefined |
| Stub `window.AudioContext` with a recording mock; call `AU.init(); AU.ping(); AU.emp(); AU.knock(); AU.cap(); AU.boom(); AU.surface(); AU.beat(true); AU.startAmb()` | verify each method's mock-call signature lands (createOscillator, createGain, createBuffer for noise; setValueAtTime + ramp; connect chain to master) |
| Seam wiring: call `tryActivePing()` after init | `AU.ctx.createOscillator` called at least once during that tick |
| Seam wiring: drive state to `loseReason="vaporized"` via the sustain path | `AU.boom()` fired (verify via mock or method-call counter); `state.loseReason === "vaporized"` |
| HOSTILE heartbeat: drive suspicion 74 → 75 across a frame | `AU.beat(true)` fired exactly once on the rising edge (`state.lastSuspState` transitions to "HOSTILE") |
| Gesture-init seam: confirm `_au_first_gesture()` is called from both `keydown` and `mousedown` listeners (read code), with `_au_gesture_done` flag preventing double-init | PASS |

If any seam is missing or the fail-safe try/catch lets an exception escape, → FIX REQUIRED.

### Pull 4 — Speed-as-noise + silent running

| Sim | Expected |
|---|---|
| `__sim.noiseRForSub({vx:0, vy:0})` | 0 |
| `__sim.noiseRForSub({vx:80, vy:0})` (terminal speed) | `NOISE_HEAR_MAX` (360) — `80 × 4.5 = 360` hits the cap |
| `__sim.noiseRForSub({vx:40, vy:0})` (half speed) | `180` (= 40 × 4.5, no cap) |
| Set `state.silentRunning = true`; call `noiseRForSub({vx:80, vy:0})` | 0 |
| `__sim.toggleSilentRunning()` | flips `state.silentRunning`; returns void; does NOT throw if game is over |
| `__sim.getSilentRunning()` and `setSilentRunning(true/false)` accessors | round-trip works |
| With `state.silentRunning = true`, run `applyInertia(0.1, 1, 0)` (full thrust forward, 100 ms) | `state.sub.vx === 0 && state.sub.vy === 0 && state.sub.angularVel === 0` (sub frozen) |
| With `state.silentRunning = true`, run `update(0.1)` 10 times | `state.sub.x` and `state.sub.y` unchanged (frozen); `state.oxygen` decreased (drain continues) |
| Drive sub to terminal speed; verify Siren within `noiseR` gets `invX/invY/invT` stamped | siren.invT > state.timeSec; siren.invX === state.sub.x within tolerance |
| Silent toggle via desktop `Digit5` keydown | `state.silentRunning` flips |
| Silent toggle via mobile `simulateTouchEvent('buttonTap', {id:'btnSilent'})` | `state.silentRunning` flips |
| HUD: while silent + alive, the canvas shows "SILENT" text top-right | verify via render snapshot (text "SILENT" rendered at `WORLD_W - 8, 14`) |
| Desktop input path byte-equivalence: every pre-Step-9 keydown branch unchanged (Space, KeyR, Tab, KeyF, KeyG, KeyB, Digit1-Digit4, Escape, Arrow keys) | byte-equivalent; only ONE new conditional appended (`if (e.code === TUNING.SILENT_BIND_KEY) toggleSilentRunning();`) |

If silent toggle does not bind to BOTH desktop key AND mobile button, OR if any pre-Step-9 keybind is rebound, → FIX REQUIRED.

### `__sim` surface check

- Total entries: 73 (Step 8) → 80 (Step 9) = 8 new entries (strict superset). Note: brief said 7; actual is 8 because the noise/silent pull added 5 accessors (`noiseRForSub`, `toggleSilentRunning`, `getSilentRunning`, `setSilentRunning`, `getNoiseR`) plus 3 for the other pulls (`hasActiveDetector`, `shadowPolyForRect`, `AU`).
- Verify all 73 pre-Step-9 entries are still present and callable (no deletions).

### Cross-step regression

- Re-run Step 8's 53-sim battery. Expect 53 PASS / 0 FAIL.
- Re-run Step 2's fairness-valve sims. Expect 4 PASS / 0 FAIL — note that the kill-rule predicate is now GATED on `hasActiveDetector`, so the original sims must position an un-stunned Siren in LOS for vaporize to fire as expected.

### Spec file note

- The canonical `SIRENS_SONG_SPEC.md` could not be patched in-session (EPERM lock during build). The Step 9 patch text is written to a sidecar `SIRENS_SONG_SPEC_STEP9_PATCH.md`. Auditor: verify the sidecar exists and contains the patch text; flag for Pat to merge once the lock clears.

### Verdict gate

GREENLIGHT if: all 6 invariants PASS, all 4 pull-specific gate batteries PASS, `__sim` strict superset confirmed, Step 8 53-sim regression passes, code hygiene clean, handoff complete.

FIX REQUIRED if: any pull-specific gate fails on a correctable seam (typo in TOUCH_ACTIONS, missing AU wire, wrong predicate field name).

PAT INTERVENTION if: invariant tension surfaces (e.g., shadow rendering violates INV6 read in a way Pat wants the spec to clarify), or the per-type detection radius mapping for `hasActiveDetector` needs Pat's ruling.
