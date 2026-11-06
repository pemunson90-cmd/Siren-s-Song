# Brief — Step 2: Suspicion Meter + ONE Siren (Patroller) + 4 Thresholds + Warning Valve

**Your step in §11:** *"2. Suspicion meter + ONE Siren (Patroller) + the four threshold states + warning valve."*
**You inherit from step 1.** Read `handoffs/01_sub_sonar_terrain.md` and `audits/01_AUDIT_STEP_01.md` before you start.

---

## What you produce

On top of step 1's substrate, add:

- A suspicion scalar, 0–100. Tracked, decays, sourceable.
- Active ping fires now contribute +25 to suspicion (the hook step 1 wired).
- Suspicion decay −5/sec when passive (no pinging/firing, drifting slow, clear of Sirens, not hugging factory). At step 2 you implement: decay when not pinging. Factory proximity and Siren-near-sub terms come later (factory in step 3 + tuning; Siren-near-sub in step 4).
- The four threshold states: 0–33 Curious / 34–74 Alert / 75–99 Hostile / 100 sustained ≥4s instakill.
- The fairness valve: at 75+, an escalation cue (text "WARNING" in HUD is sufficient at this stage). If suspicion drops below 75 within the ~4s window, instakill does not fire. Only sustained 100 for ≥4s kills.
- ONE Siren of type **Patroller**: fixed looping route, predictable speed, no deviation from route below Alert. At Alert+, may deviate toward last-known contact.
- Patroller-sub contact at Alert+ damages hull (per §6 alert behavior).
- Instakill condition: suspicion = 100 sustained ≥4s → instakill lose state (distinct from "sunk" by hull and "suffocated" by oxygen).

You're not building drones, photo objectives, win condition, or the other two Siren types.

---

## Spec sections to re-read (verbatim before you code)

- §3 Perception system (active ping = +25 confirmed).
- §6 Suspicion system (the full section — gain sources, decay, thresholds, fairness valve).
- §7 Sirens (Patroller paragraph, plus detection inputs that apply to all types).
- §10 Fairness principles (all 5 — especially 4, "mistakes are recoverable via the suspicion-decay + warning valve").
- §11 step 2 line.

---

## Inherited state

- `code/sirens_song.html` has: sub, terrain, hull, oxygen, passive sonar, active ping (with a hook for suspicion cost), HUD, lose conditions for sunk and suffocated, restart.
- Read the handoff to see what tuning numbers step 1 picked. Don't second-guess them — keep them unless they conflict with your step's spec needs (they shouldn't).

---

## Scope boundary (the seam where you stop)

You stop after:

- Suspicion is tracked and displayed in HUD (a number is fine).
- Active ping adds +25 suspicion.
- Suspicion decays −5/sec under the conditions the spec specifies (at step 2 scope: "not pinging").
- Threshold state is computed and displayed (text label: "CURIOUS" / "ALERT" / "HOSTILE" / "WARNING (instakill imminent)").
- The Patroller exists, follows a hand-authored loop, becomes faster + deviates at Alert+, and damages sub on contact at Alert+.
- Instakill fires at 100 sustained ≥4s; if suspicion drops below 100 within the 4s, instakill doesn't fire.
- New lose state: "vaporized" (instakill).

You do NOT build:
- Drones (step 3).
- Photo objectives or win condition (step 3).
- Sub fallback cam (step 3).
- Sentinel or Hunter Siren types (step 4).
- Curiosity / decoy behavior (step 4).
- Jamming, EMP, Knockdown tools (step 5).
- Recon plane (step 6).
- Factory proximity suspicion term (deferred — flag in handoff).
- Siren-near-sub scaling suspicion term (deferred to step 4 when more Sirens exist).

---

## Tuning values for this step

| Value | Default (from spec) | Notes |
|---|---|---|
| Suspicion range | 0–100 | §6 |
| Active ping cost | +25 | §3, §6 |
| Decay rate | −5/sec when passive | §6, §11 |
| Threshold Curious | 0–33 | §6, §11 |
| Threshold Alert | 34–74 | §6, §11 |
| Threshold Hostile | 75–99 | §6, §11 |
| Instakill | 100 sustained ≥4s | §6, §11 |
| Warning window | ~4s | §6 |
| Patroller route | hand-authored loop | §7, §11 |
| Patroller speed | "slow", deviates at Alert+ "faster" | §7 (qualitative). Pick numbers, document in handoff |
| Patroller contact damage at Alert+ | "ram sub (hull damage)" | §6 (alert behavior). Default to 1 hull point per contact event, document in handoff |

---

## Sim tests to consider

- **Decay test:** set suspicion to 50, run 1s of game time with no inputs; assert suspicion ≈ 45. Run 10s; assert suspicion = 0 (clamped).
- **Ping test:** suspicion = 0, fire ping, assert suspicion = 25. Fire 3 pings in quick succession; assert suspicion = 75 (and threshold transitions through Curious → Alert → Hostile).
- **Warning valve test:** force suspicion to 100, hold for 3.9s, drop to 99; assert instakill does NOT fire. Force to 100 and hold for 4.1s; assert instakill fires.
- **Threshold transition test:** drive suspicion from 0 → 100 and assert the displayed state label changes at the right boundaries (33→Alert, 74→Hostile, 100→Warning).
- **Patroller loop test:** sim the Patroller for one full route cycle below Alert; assert it returns to start without deviation. Drive suspicion to Alert; assert next tick it deviates toward last ping position.

Log results in handoff §"Sim tests run."

---

## Audit gates (what the auditor will check)

- **Invariant 1 (no enemy HP, no player kill-path):** Patroller has no HP, no kill-able state. There is no player attack that damages a Siren. Auditor will confirm.
- **Invariant 2 (suspicion is the spine):** Patroller behavior keys off suspicion state, not from a hardcoded aggression timer. Auditor will trace the state machine.
- **Invariant 3 (perceiving costs):** ping +25 wired. Auditor will verify the +25 lands.
- **Invariant 4 (tools buy time, cost heat):** n/a yet — no tools.
- **Invariant 5 (fairness valve):** the warning window is implemented; sustained-100-for-≥4s is the ONLY path to instakill; suspicion decays. Auditor will sim-test the valve.
- **Invariant 6 (function before form):** still placeholder shapes. Patroller is a labeled blob. HUD is plain text.
- **Step scope:** auditor will confirm you didn't build drones, other Siren types, weapons, or the win condition.

---

## Handoff format

End your turn by writing `handoffs/02_suspicion_patroller.md` per §5.2 of `agent.md`. Include in §"Open potholes for the next step":

- The factory proximity suspicion term is deferred — flag where the hook should land (step 3 implements factory and objectives).
- The Siren-near-sub scaling suspicion term is deferred — flag for step 4.
- Tuning numbers you picked for Patroller speed, contact damage, deviation behavior.
- Any spec ambiguity you encountered.

Receipt format at end of handoff: `Step 02: COMPLETE / BLOCKED / PARTIAL`.

---

*AI-DESIGNED. Brief for daisy-chain step 2.*
