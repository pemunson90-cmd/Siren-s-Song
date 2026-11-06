# Brief — Step 1: Sub Movement + Sonar + Terrain + Hull + Oxygen

**Your step in §11:** *"1. Sub movement + passive/active sonar + terrain + collision/hull + oxygen drain."*
**You are the first step in the daisy-chain.** No previous handoff exists. The spec is your only inherited state.

---

## What you produce

A `code/sirens_song.html` that, opened in any modern browser, gives you:

- A bounded 2D top-down play area with hand-authored terrain (rocks, walls, the seafloor edges — one hand-authored level, per §11).
- The player sub: position + heading, moves slowly, responds to input.
- Passive sonar: always on, low-detail blips of "nearby" features (rough, near-blind).
- Active ping: triggered, wide reveal of terrain + contacts, fades over ~3s.
- Terrain collision: sub bumps terrain = takes a hull point.
- Hull integrity counter (default 3); depletion = lose state ("sunk").
- Oxygen drain: slow, always-on, depletion = lose state ("suffocate/stranded").
- A minimal text HUD: position, hull, oxygen %. No graphics polish.

You're not building suspicion, drones, Sirens, weapons, or objectives yet. You're building the **substrate** the next 6 steps will add to.

---

## Spec sections to re-read (verbatim before you code)

- §1 Core fantasy & central knot (so you know why the sub is fragile).
- §2 Player vessel (the source of truth for sub behavior, hull = 3, oxygen mechanics).
- §3 Perception system (the table — Passive and Active rows; you implement those two; the others are later steps).
- §8 Win/lose (you implement only the lose conditions that apply at step 1: sunk by hull, suffocated by oxygen).
- §10 Fairness principles (1, 2, 5 are relevant — death traceable, no enemy HP, no instant restarts).
- §11 build leash (step 1 line, plus tunable defaults: hull 3, oxygen ≈ enough for one unhurried full run).

---

## Inherited state

- Nothing. This is step 1.
- The spec is canon. Read it before coding.

---

## Scope boundary (the seam where you stop)

You stop after:

- The browser opens the HTML, shows a play area with terrain.
- The sub can be moved by input (WASD or arrows — your call).
- Passive sonar is visible (some kind of low-detail rendering of nearby contacts/terrain).
- Active ping fires on a key press and reveals terrain for ~3s before fading.
- Sub colliding with terrain decrements hull; hull 0 triggers lose state.
- Oxygen drains over time; oxygen 0 triggers lose state.
- HUD shows position, hull, oxygen.
- A "you lost (sunk)" / "you lost (suffocated)" message renders on lose condition.
- A "restart" key resets state.

You do NOT build:
- Suspicion meter (step 2).
- Sirens (step 2 introduces Patroller; later steps add Sentinel and Hunter).
- Drones (step 3).
- Photo objectives or win condition (step 3).
- Disruption tools (step 5).
- Recon plane (step 6).
- Tuning pass (step 7).

If you find yourself adding any of those — stop.

---

## Tuning values for this step

| Value | Default (from spec §11) | Notes |
|---|---|---|
| Hull | 3 | §2 + §11 |
| Oxygen | ≈ enough for one unhurried full run, drains continuously | §2 + §11. Tune so a clean run finishes with margin, camping does not. Pick a number that gives ~3–5 min of unhurried play; flag in handoff so step 7 can tune. |
| Active ping reveal duration | ~3s | §3 table |
| Sub speed | "slowly" | §2. Pick a per-frame velocity that feels deliberate; flag in handoff for tuning. |

You're allowed to pick numbers within the spec's qualitative bounds when no exact default exists. **Document every number in the handoff.**

---

## Sim tests to consider

These are suggestions; the auditor may run others.

- **Movement test:** instantiate the sub at (100, 100), apply input "forward" for 60 frames at 60fps; assert position changed in the heading direction by sub_speed × 60 / 60 units.
- **Hull test:** drive the sub into a terrain block; assert hull decremented by 1 and the sub bounced/stopped (your call which, document it).
- **Oxygen test:** simulate T seconds of game time; assert oxygen depleted by T × drain_rate. Verify at chosen oxygen value, T_total seconds of unhurried play is possible.
- **Ping test:** trigger active ping; assert reveal state is "on" at t=0, fades over 3s, at t=3.1s reveal is off.
- **Lose test:** force hull to 0 → assert sunk lose state fires. Force oxygen to 0 → assert suffocated lose state fires. Restart input → assert state resets.

Log results in handoff §"Sim tests run."

---

## Audit gates (what the auditor will check)

- **Invariant 1 (no enemy HP, no player kill-path):** trivially true at step 1 — no enemies, no player kill action. Auditor will confirm absence.
- **Invariant 2 (suspicion is the spine):** n/a yet — flag in handoff.
- **Invariant 3 (perceiving costs):** passive sonar is free per spec (the only free reveal); active ping has a suspicion cost in spec (+25) but suspicion doesn't exist yet — confirm the active ping is wired with a hook/comment for the suspicion cost to land in step 2.
- **Invariant 4 (tools buy time, cost heat):** n/a yet — no tools.
- **Invariant 5 (fairness valve):** n/a yet — no suspicion. But the lose conditions you DO implement must follow §10 (traceable to a decision — running into terrain, running out of oxygen).
- **Invariant 6 (function before form):** auditor will confirm no art/sound/palette/UI-chrome work was attempted. Placeholder shapes only.
- **Step scope:** auditor will confirm you didn't implement anything from steps 2–7.
- **Spec adherence:** auditor will read the spec sections (§1–3, §8 lose conditions, §10, §11 step 1) and check the code matches.
- **Code hygiene:** single file at `code/sirens_song.html`; HTML+JS+Canvas; syntax-valid; no fabricated tuning numbers; commented invariants.

---

## Handoff format

End your turn by writing `handoffs/01_sub_sonar_terrain.md` per §5.2 of `agent.md`. Include in §"Open potholes for the next step":

- The active-ping-suspicion-cost hook you wired (so step 2 knows where to land +25).
- Any tuning value you picked that needs validation in step 7.
- Any spec ambiguity you encountered and how you ruled.

Receipt format at end of handoff: `Step 01: COMPLETE / BLOCKED / PARTIAL`.

---

*AI-DESIGNED. Brief for daisy-chain step 1.*

---

### Pat-source diagnostic notes (2026-06-03)

*Injected 2026-06-04 02:31 UTC by orchestrator. These arrived AFTER the initial Step 1 build + audit had already closed GREENLIGHT. They are Pat-source diagnostic ratifications from his parallel claude.ai implementation — not implementation contamination, just "this design choice felt right" / "this needs weight" signals. A Step 1 fix-pass has been authorized to address these before the chain continues past Step 3.*

**Diagnostic 1 — LOS-blocking terrain for BOTH passive AND active sonar.**
Pat's parallel implementation occludes both sonar modes against terrain and it "feels great." Passive sonar through rock is wrong. Make sure terrain raycasts block both detection paths — the player should not be able to see a Patroller silhouette through a wall via passive radius, and the active ping should also be terrain-occluded (not magic-flood through walls).

**Diagnostic 2 — The submarine needs to feel like a submarine.**
Movement feel matters. Subs have inertia, slow turn radius, depth-change momentum, no snappy arcade controls. Build player vessel handling with weight. If it feels like 2D top-down ship arcade, it's wrong. Spec doesn't fully prescribe handling values — use submarine-feel as the tuning north star and surface defaults in the handoff so Step 7 tuning can refine.

**Constraints on the fix-pass:**
- Surface defaults in the handoff under a "submarine-feel tunables" block so Step 7 can refine.
- Do NOT break the `__sim` harness exposed surface; downstream steps depend on it. Add new entries; don't remove or rename existing ones.
- Re-run the full Step 1 sim-test battery PLUS new tests for: passive-sonar-through-terrain (must NOT reveal), active-ping-through-terrain (must NOT reveal), sub-stop-from-full-speed (must show deceleration ramp, not instant zero), sub-turn-from-rest (must show angular acceleration ramp, not instant turn rate).
- If new submarine-feel values shift any tested timing (Patroller catch windows, etc.), flag for Step 2/3 regression audit.

*AI-DESIGNED. Diagnostic-note injection per Pat 2026-06-03.*
