# Brief — Step 6: Recon Plane Call-In

**Your step in §11:** *"6. Recon call-in."*
**You inherit from steps 1–5.** Read `handoffs/05_disruption_tools.md` and `audits/05_AUDIT_STEP_05.md` before you start.

---

## What you produce

On top of steps 1–5, add the recon plane call-in per §3 of the spec.

- **Recon call-in:** consumable, default 2 charges. Reveals a large sector of the map (terrain + contacts) for a longer duration than active ping. Low suspicion cost (+8). Precious resource.
- Input to call in: key press.
- Targeting: the player designates a sector (click a point on the map; sector is centered there with a defined radius — your call on radius, document; should be visibly larger than active ping's reveal).
- Reveal duration: longer than active ping's ~3s. Pick a value (~6–10s suggested), document.
- Charge tracking: 2 charges, displayed in HUD.
- Suspicion cost: +8 on call-in.
- Reveal renders during duration (passes through into the world rendering layer), fades at expiration like active ping does.

---

## Spec sections to re-read (verbatim before you code)

- §3 Perception system (recon plane call-in row in the table; transient reveals).
- §6 Suspicion system (recon +8 gain source).
- §10 Fairness principles (3 — tools buy time and cost heat; nothing is free except passive).
- §11 step 6 line, tunable defaults (recon 2 charges).

---

## Inherited state

- `code/sirens_song.html` has: everything from steps 1+2+3+4+5. All three Sirens. All three disruption tools. Drones + sub-cam. Win/lose conditions.

---

## Scope boundary (the seam where you stop)

You stop after:

- Recon call-in fires on its bound input.
- Player can designate a sector (click target on map).
- Sector reveals — terrain visible + Sirens/factory features within sector visible for the duration.
- Reveal duration is longer than active ping and visibly distinct (larger sector).
- Reveal fades at expiration.
- Charge decrement on use; 2 charges total; no-op after both used.
- Suspicion +8 lands on call-in.
- HUD shows recon charges remaining.

You do NOT build:
- Tuning pass (step 7).
- Additional reveal types.
- New Sirens, tools, drones, or objectives.

---

## Tuning values for this step

| Value | Default (from spec) | Notes |
|---|---|---|
| Recon charges | 2 | §11 |
| Recon suspicion cost | +8 | §3, §6, §11 |
| Reveal duration | longer than active ping (~3s); pick ~6–10s | §3 qualitative; document |
| Reveal radius | larger than active ping; pick value, document | §3 qualitative |
| Sector targeting | click-to-designate | §3 says "large sector reveal" — implementation is your call |

---

## Sim tests to consider

- **Charge counter test:** fire recon twice; assert 0 charges remaining and 3rd fire is no-op.
- **Suspicion cost test:** suspicion = 0, fire recon; assert suspicion = 8.
- **Reveal duration test:** fire recon at t=0; sim N seconds (your chosen duration); assert reveal state on. Sim past duration; assert reveal off.
- **Reveal radius test:** fire recon; verify Sirens within sector are visible and Sirens outside sector are not.
- **Comparative test (recon vs. ping):** fire active ping at point A; fire recon at point B; verify recon's sector is larger and duration longer.

---

## Audit gates (what the auditor will check)

- **Invariant 1:** unrelated — recon is perception, not combat.
- **Invariant 2:** recon's +8 lands. No scripted aggression added.
- **Invariant 3:** **load-bearing here.** Recon costs +8. Reveal is transient. Passive sonar is still the only consistently free reveal. Auditor verifies the cost and the fade.
- **Invariant 4:** recon is finite (2 charges) and costs heat. Same logic as the disruption tools.
- **Invariant 5:** warning valve still works.
- **Invariant 6:** placeholder reveal rendering (e.g., a shaded circle or rectangle showing the revealed sector). No art polish.

---

## Handoff format

End your turn by writing `handoffs/06_recon_call_in.md` per §5.2 of `agent.md`. Include in §"Open potholes for the next step":

- Tuning numbers for recon duration and radius.
- Confirmation that all §11 systems are now in place except final tuning.
- A list of all qualitative tuning values across the whole build that step 7 should review (this is the handoff to the tuning step).

Receipt format at end of handoff: `Step 06: COMPLETE / BLOCKED / PARTIAL`.

---

*AI-DESIGNED. Brief for daisy-chain step 6.*
