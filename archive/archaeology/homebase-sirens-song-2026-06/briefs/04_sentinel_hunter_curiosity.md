# Brief — Step 4: Sentinel + Hunter + Curiosity/Decoy Behavior

**Your step in §11:** *"4. The other two Siren types (Sentinel, Hunter) + curiosity/decoy behavior."*
**You inherit from steps 1–3.** Read `handoffs/03_drones_camera_objectives.md` and `audits/03_AUDIT_STEP_03.md` before you start.

---

## What you produce

On top of steps 1–3, add:

- **Sentinel Siren:** stationary or small orbit guarding a key photo objective (your call — pick the bays or the power core). Large detection radius. Forces tool use to bypass. Active across all suspicion states.
- **Hunter Siren:** dormant below Alert (34+). At Alert+, activates and actively pursues last-known contact. Fast. The threat your own noise summons.
- **Curiosity behavior (cross-cutting on all 3 Siren types in Curious state, 0–33):** any Siren in Curious state will move to investigate a decoy or a recent ping position. Slow, non-lethal approach. This is the "approachable, baitable, photogenic" exploit verb from §7.
- **Decoy drones:** the third drone function (Scout + Photograph from step 3 already exist). Park a drone, mark it as "decoy"; Curious Sirens move to investigate it. Pat ratified 2026-06-03 that **both passive parking and an active decoy mode count** — implement both: a parked drone in vision of a Siren below Alert acts as a draw, AND an explicit "decoy mode" the player can toggle on a parked drone for stronger draw. Document the difference between the two in code comments and handoff.
- **Siren-near-sub scaling suspicion term:** the spec's §6 line *"Siren-near-sub +scaling/sec (closer = faster)"*. Land this now that multiple Sirens exist. Sum the contributions of all Sirens within their per-type proximity range. Pick the scaling curve, document it in the handoff.
- **Sentinel and Hunter detection inputs:** consistent with Patroller — active pings (heard), proximity, nearby drone activity, weapon fire. No new hidden detection rules. §10 fairness principle 1 ("death is always traceable to a player decision") binds.
- Sentinel and Hunter contact damages hull at Alert+ (same as Patroller per §6 alert behavior). At Hostile they may also coordinate (the spec says §6: 75–99 coordinated hunt). Implement the basic version — they all converge on last-known contact; don't over-engineer flocking.

You're not building disruption tools (step 5), recon plane (step 6), or final tuning (step 7).

---

## Spec sections to re-read (verbatim before you code)

- §4 Drones (the Decoy function paragraph — your third drone function).
- §6 Suspicion system (Siren-near-sub scaling/sec term; threshold behavior at Alert and Hostile).
- §7 Sirens (the full section — Sentinel + Hunter paragraphs, detection inputs, curiosity cross-cutting).
- §10 Fairness principles (especially 1 and 5).
- §11 step 4 line.

Pat's 2026-06-03 ruling on decoys: BOTH passive (parked drone as bait) AND active (explicit decoy mode) — don't force a choice. Document both in code.

---

## Inherited state

- `code/sirens_song.html` has: everything from steps 1+2+3.
- Patroller exists. Drones (scout + photograph) exist. Factory and objectives exist. Win condition wired.

---

## Scope boundary (the seam where you stop)

You stop after:

- One Sentinel exists at a hand-authored position, guarding a designated objective (bays or power core).
- Sentinel has a large detection radius and stays put or small-orbits.
- One Hunter exists at a hand-authored dormant position.
- Hunter is dormant below Alert; activates at Alert+ and pursues last-known contact at speed.
- All three Siren types (Patroller, Sentinel, Hunter) implement Curious-state investigation of decoys/pings.
- Drones have a Decoy function: parked drones act as bait passively, AND an explicit decoy-mode toggle makes them a stronger draw (per Pat 2026-06-03).
- Siren-near-sub +scaling/sec contribution lands and is included in the suspicion math.
- HUD shows: number of Sirens visible, threshold state still correct, decoy state of any parked drone (optional but useful for testing).

You do NOT build:
- Jamming / EMP / Knockdown (step 5).
- Recon plane (step 6).
- Final tuning pass (step 7).
- New objectives or new win/lose conditions.

---

## Tuning values for this step

| Value | Default (from spec) | Notes |
|---|---|---|
| Total Sirens | 3 (1 Patroller from step 2 + 1 Sentinel + 1 Hunter) | §7, §11 |
| Sentinel detection radius | "large" | qualitative; pick a number, document |
| Sentinel orbit/stationary | your call between the two | document |
| Hunter dormant threshold | activates at suspicion ≥34 (Alert+) | §7 |
| Hunter pursuit speed | "fast" | qualitative; should be visibly faster than Patroller |
| Curiosity move speed | "slow, non-lethal approach" | §7; qualitative |
| Decoy effect | "any Siren in Curious state will move to investigate" | §7 |
| Siren-near-sub suspicion | "+scaling/sec (closer = faster)" | §6 qualitative; pick a curve, document |
| Active decoy boost vs. passive | your call; document the multiplier or radius difference | |

---

## Sim tests to consider

- **Sentinel detection test:** sub enters Sentinel detection radius; verify Sentinel registers the contact (suspicion contribution scales; at Alert+ Sentinel moves to ram/contact).
- **Hunter dormant test:** suspicion at 30, sim 10s; verify Hunter does not move.
- **Hunter activation test:** drive suspicion to 35, sim 1s; verify Hunter moves toward last-known sub/ping position at higher speed than Patroller.
- **Curiosity test:** suspicion at 10 (Curious for everyone). Place a decoy drone in the play area within Patroller's sensing range. Sim 5s; verify Patroller deviates from route toward decoy.
- **Active vs. passive decoy test:** verify parked drone draws a Curious Siren; verify active-decoy-mode drone draws from a larger range or more strongly.
- **Siren-near-sub suspicion test:** sub far from all Sirens, suspicion stable. Sub close to one Siren, suspicion gains the scaling/sec term. Sub close to two Sirens, term sums.
- **Multi-Siren convergence at Alert:** drive suspicion to 50, place sub at known position; sim 5s; verify multiple Sirens move toward last-known sub position.

---

## Audit gates (what the auditor will check)

- **Invariant 1:** no HP on Sentinel/Hunter. No player tool damages them.
- **Invariant 2:** Hunter dormancy is suspicion-driven (not scripted timer). Curiosity behavior is state-driven. Auditor will trace state machines.
- **Invariant 3:** drone-cam still free at deploy/move. Decoy is a parking choice + a mode toggle, not a separate cost. Suspicion math now includes Siren-near-sub term.
- **Invariant 4:** decoys aren't tools in the §5 sense — they're a drone repurpose. Still finite supply.
- **Invariant 5:** Sirens follow rules; auditor will run sim tests to verify no hidden detection. Death from Sentinel/Hunter contact must be traceable to a player decision (entered detection radius, summoned Hunter via noise, etc.).
- **Invariant 6:** Sentinel/Hunter are still placeholder shapes, distinguishable by label/color (within "function before form" — different blob colors are fine for testing).

---

## Handoff format

End your turn by writing `handoffs/04_sentinel_hunter_curiosity.md` per §5.2 of `agent.md`. Include in §"Open potholes for the next step":

- Tuning numbers for Sentinel radius, Hunter speed, Siren-near-sub curve, decoy effects.
- Where step 5's jamming/EMP/knockdown hooks should land — the Siren state machine needs an "interrupted" or "stunned" path.
- Any places the multi-Siren coordination feels hand-wavy and step 7 will need to tune.

Receipt format at end of handoff: `Step 04: COMPLETE / BLOCKED / PARTIAL`.

---

*AI-DESIGNED. Brief for daisy-chain step 4.*
