# Brief — Step 7: Tuning Pass

**Your step in §11:** *"7. Tuning pass — then stop and hand back for playtest."*
**You inherit from steps 1–6.** Read `handoffs/06_recon_call_in.md` and `audits/06_AUDIT_STEP_06.md` before you start.
**You are the last step. After you, the build hands back to Pat for playtest. STOP at the end.**

---

## What you produce

A tuning pass over the whole build. **You do not add new systems.** You verify and adjust the numbers that prior steps picked, against §11's tunable-defaults paragraph and §10's fairness principles.

Per §11 (verbatim): *"The single most important thing to get right in tuning is **Siren detection legibility** — the player must always be able to reason about why a Siren noticed them. That dial is the game."*

Your work:

1. **Pull every tuning value in the build** into a table (sub speed, oxygen drain, hull, suspicion costs, decay rate, threshold positions, warning duration, Patroller speed/route, Sentinel radius, Hunter speed, decoy effects, drone count, drone vision radius, drone speed, sub-cam range, tool charges, tool windows, recon duration/radius, factory proximity curve, Siren-near-sub curve, etc.).
2. **Run scenario sims** — at least three: a "clean run" (player plays well, finishes with margin); a "dithering run" (player camps, runs out of oxygen); an "aggression run" (player pings too much, suspicion maxes, valves out, finally vaporizes).
3. **Identify mis-tuned values** — anywhere the spec's qualitative bounds aren't met (e.g., clean run dies on oxygen = oxygen too tight; or aggression run survives easily = suspicion math is too generous).
4. **Adjust within the spec.** You may change tuning numbers. You may NOT change invariants or design. If a tuning change would require violating an invariant or adding a new system, that's a Pat ruling — flag it in the handoff.
5. **Re-run sims after each adjustment.** Verify the change moves the scenario toward the spec's intent.
6. **Verify detection legibility:** Sim a scenario where a Siren detects the sub. Trace exactly which detection input (active ping / proximity / drone activity / weapon fire) triggered it. If the trace isn't clean (e.g., suspicion just "ticked up" with no clear cause), surface it as a tuning gap.
7. **Final scenarios pass:** run clean / dithering / aggression once more; verify all three end as the spec intends.

After tuning is complete, **STOP**. Write the handoff. The next event is Pat opening the file and playtesting. The orchestrator does not fire another build step after you.

---

## Spec sections to re-read (verbatim before you start)

- §10 Difficulty & fairness principles (the full numbered list — these are the constraints tuning serves).
- §11 Build leash (the full tunable defaults paragraph plus the legibility line).
- All prior §1–9 — you're now responsible for the whole game, not just one slice.

---

## Inherited state

- `code/sirens_song.html` has: everything. All systems should be present.
- Read every prior handoff in `handoffs/` to see what values each step picked and what they flagged for tuning.
- Read every prior audit in `audits/` — fix-pass directives may carry tuning notes the auditor wrote.

---

## Scope boundary (the seam where you stop)

You stop after:

- Every tuning value is documented in a table at the top of the handoff.
- Clean / dithering / aggression scenarios produce their expected outcomes per spec.
- Siren detection legibility check passes (every detection event has a clearly traceable cause).
- Any adjustments are made within the spec's bounds and documented.

You do NOT:
- Add new systems.
- Change invariants.
- Add art/sound/polish (invariant 6).
- Spawn new build agents (you're the end of the chain).
- Run new playtests outside of sim testing — that's Pat's turn.

---

## Tuning values to review (consolidated from prior steps)

The exact tunable-defaults list per spec §11:

- drones 5
- EMP 3
- knockdown 2
- jam 3
- recon 2
- hull 3
- oxygen ≈ enough for one unhurried full run
- suspicion ping +25 / drone photo +15 / EMP+KD +20 / jam +5 / recon +8 / decay −5•s⁻¹
- thresholds 33/74/99, instakill at 100 sustained 4s
- Sirens 3
- required photos 3 + 1 bonus

Plus the qualitative ones prior steps picked numbers for (sub speed, oxygen drain rate, Patroller/Sentinel/Hunter speeds & radii, drone speed/vision, sub-cam range, tool windows, recon duration/radius, factory proximity curve, Siren-near-sub scaling curve, decoy effect strengths).

**Anything that differs from spec defaults needs a justification in the handoff.**

---

## Sim tests to run (mandatory at this step)

These are not optional. The auditor will re-run them.

- **Clean run sim:** scripted "ideal player" inputs — passive sonar use, one or two pings, drones forward, capture all 3 required, return to extraction. Assert: WIN, with oxygen margin, hull intact or near-intact, suspicion never sustained at 100.
- **Dithering run sim:** scripted "camping" inputs — sub idles, no progress, occasional ping. Assert: oxygen depletes → suffocate lose state.
- **Aggression run sim:** scripted "pings every 5s, fires every tool, no jamming" inputs. Assert: suspicion saturates → instakill lose state. The warning valve fires before the kill (the player would have had a chance).
- **Detection legibility sim:** drive a scripted scenario into a Siren detection event; assert the input log shows ONE clear cause (active ping at t=X, or proximity entry at t=Y).
- **Warning valve sim:** drive suspicion to 100, hold for 3s, drop to 99 via jam; assert no instakill. Then drive to 100, hold for 4.1s; assert instakill.
- **Drone-depletion sim:** lose all 5 drones; verify sub-cam can still capture all 3 required + bonus and reach extraction. Verify run is harder but possible.
- **Factory proximity sim:** sit sub at far / mid / close distance from factory; verify suspicion contribution scales as spec'd.

Document every sim test result in the handoff.

---

## Audit gates (what the auditor will check)

- **All six invariants:** end-to-end. The full build is now reviewed.
- **Spec adherence:** every §11 tunable default present and either at-default or with documented justification.
- **Legibility:** the detection-legibility check passes. The auditor may run their own sims.
- **Scenario outcomes:** clean wins, dithering suffocates, aggression vaporizes. Auditor reproduces.
- **Step scope:** no new systems added, no invariants changed.
- **Build is playable:** auditor opens the HTML and verifies it loads, the main loop runs, the win and lose states render.

---

## Handoff format

End your turn by writing `handoffs/07_tuning_pass.md` per §5.2 of `agent.md`. Include in §"Open potholes for the next step":

- This is the LAST step. There is no next step. Note: "Ready for Pat playtest."
- A complete tuning-values table (every numerical knob and its current value).
- Sim test results for all mandatory scenarios.
- Any place where you found a tension between spec invariants and tuning that you couldn't resolve within scope — flag for Pat.

Receipt format at end of handoff: `Step 07: COMPLETE — READY FOR PAT PLAYTEST. ORCHESTRATOR: HALT.`

---

*AI-DESIGNED. Brief for daisy-chain step 7. Last step. Stop after.*
