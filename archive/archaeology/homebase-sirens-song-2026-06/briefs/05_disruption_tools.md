# Brief — Step 5: Disruption Tools (Jamming + EMP + Knockdown)

**Your step in §11:** *"5. The three disruption tools (jam / EMP / knockdown)."*
**You inherit from steps 1–4.** Read `handoffs/04_sentinel_hunter_curiosity.md` and `audits/04_AUDIT_STEP_04.md` before you start.

---

## What you produce

On top of steps 1–4, add the three disruption tools per §5 of the spec. **No tool kills a Siren. No Siren has an HP bar. Tools buy time, and using them spikes the player's own suspicion** — this is the save-tool-draws-heat tension that §10 codifies.

- **Jamming:** default 3 charges. Reduces sub detectability / scrambles Siren localization for a window. Small suspicion cost (+5). The "lower the heat / break a lock" tool. Tune the window — pick a duration that creates a meaningful window without trivializing detection (suggest ~3–5s; document).
- **EMP torpedo:** default 3 charges. Stuns/blinds one Siren for ~5s (halts movement + detection). Fire cost +20 suspicion.
- **Knockdown torpedo:** default 2 charges. Bola-snare + downthrust screws drag a Siren to the seafloor, immobilized ~12s. Longer window than EMP, rarer. Fire cost +20 suspicion.

Each tool needs:

- An input (key press) to fire/activate.
- Aim/target acquisition (your call — click-to-target for EMP/KD; jamming is sub-centric, no target).
- Charge tracking, decremented on use.
- Visible HUD readout (charges remaining for each).
- Effect on Siren state for EMP/KD: hook into the "interrupted/stunned" state Step 4 should have left a seam for.
- Effect for jamming: a sub-detectability multiplier or "Sirens momentarily lose lock" flag, applied for the window duration.
- Suspicion cost lands at fire time.

---

## Spec sections to re-read (verbatim before you code)

- §5 Disruption tools (the full section — three tools, charges, durations, costs).
- §6 Suspicion system (gain sources for tool fires).
- §7 Sirens (detection inputs — weapon fire is one of them; EMP/KD firing draws detection attention even when the target is mid-stun).
- §10 Fairness principles (3 — tools buy time and cost heat; nothing is free).
- §11 step 5 line, tunable defaults (jam 3 / EMP 3 / KD 2; jam +5 / EMP+KD +20).

---

## Inherited state

- `code/sirens_song.html` has: everything from steps 1+2+3+4. Three Sirens (Patroller, Sentinel, Hunter). Curiosity. Decoys. Drone photo and sub-cam. Win condition. Multi-Siren suspicion math.
- The Siren state machines should have left a hook/seam for "stunned" / "interrupted" — that's where EMP and Knockdown land. If they didn't, you'll need to add the stunned state to the Siren state machine (note in handoff).

---

## Scope boundary (the seam where you stop)

You stop after:

- All three tools fire on their bound inputs.
- Charge counters work and decrement correctly.
- Jamming sub-detectability window functions; Sirens momentarily lose lock or have reduced detection of the sub within the window.
- EMP halts movement + detection on a targeted Siren for ~5s.
- Knockdown immobilizes a targeted Siren for ~12s.
- All three suspicion costs land per spec (+5 / +20 / +20).
- Targeting works (click-to-target for EMP/KD; jamming is sub-centric).
- HUD shows charges for each tool.

You do NOT build:
- Recon plane (step 6).
- Final tuning pass (step 7).
- New Siren types or new tool types.
- Sirens that can be killed by repeated EMP/KD — they re-activate after the window. **Reinforce this in code comments.**

---

## Tuning values for this step

| Value | Default (from spec) | Notes |
|---|---|---|
| Jam charges | 3 | §11 |
| EMP charges | 3 | §11 |
| Knockdown charges | 2 | §11 |
| Jam cost | +5 suspicion | §5, §6, §11 |
| EMP cost | +20 suspicion | §5, §6, §11 |
| Knockdown cost | +20 suspicion | §5, §6, §11 |
| EMP duration | ~5s | §5 |
| Knockdown duration | ~12s | §5 |
| Jam window | not specified; pick ~3–5s, document | §5 says "for a window" |
| Jam effect strength | "reduces sub detectability / scrambles localization" — pick a numeric expression (e.g., halve Siren detection range, or 50% reduced suspicion contribution from Siren proximity during window) | §5 qualitative; document |

---

## Sim tests to consider

- **Charge counter test:** fire EMP 3 times; assert 0 charges remaining and 4th fire is no-op.
- **EMP duration test:** fire EMP at Siren; sim 4.9s; assert Siren stunned. Sim 0.2s more; assert Siren un-stunned and resumes prior state.
- **Knockdown duration test:** fire KD at Siren; sim 11.9s; assert immobilized. Sim 0.2s more; assert mobile again.
- **Jam window test:** activate jam; sim within window; verify a Siren that would otherwise detect the sub does not. Sim past window; verify detection resumes.
- **Suspicion cost test:** suspicion = 0, fire EMP; assert suspicion = 20. Fire jam; assert 25. Fire KD; assert 45.
- **No-HP test:** fire EMP at same Siren 10 times across multiple windows; verify Siren still exists, still functions, never dies, never has HP decrement. (Each fire still costs suspicion.)
- **Stack-friendly test:** EMP a Siren, then KD a different Siren; verify both stuns/immobilizations run independently on their own timers.

---

## Audit gates (what the auditor will check)

- **Invariant 1:** **load-bearing here.** No tool deals damage. Sirens cannot be killed by repeated tool fire. No HP bar. Auditor sim-tests this with extreme prejudice.
- **Invariant 2:** suspicion costs land correctly. State transitions still suspicion-driven.
- **Invariant 3:** n/a directly (tools aren't perception).
- **Invariant 4:** **load-bearing here.** Each tool costs heat, each is finite, each buys time. Auditor verifies the cost-of-use is real (sim test: chain all tools, observe suspicion spike past Alert).
- **Invariant 5:** the warning valve still works — sim test: drive suspicion to 75, use jam to drop the contributing terms, assert suspicion drops below threshold and warning clears.
- **Invariant 6:** placeholder UI for tool charges (plain text counters). No tool art.

---

## Handoff format

End your turn by writing `handoffs/05_disruption_tools.md` per §5.2 of `agent.md`. Include in §"Open potholes for the next step":

- Tuning values picked for jam window, jam effect strength.
- Any place the Siren state machine needed extension to host "stunned"/"immobilized" and how it interacts with the existing Curious/Alert/Hostile state from suspicion.
- Confirmation that no Siren can be killed (this is invariant 1 and the auditor will sim-test it).

Receipt format at end of handoff: `Step 05: COMPLETE / BLOCKED / PARTIAL`.

---

*AI-DESIGNED. Brief for daisy-chain step 5.*
