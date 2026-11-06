# SIREN'S SONG — Functional Spec (v0.2, function before form)

**What this is:** a build input for Cowork. Systems and rules only. The form layer
(pixel art, palette, UI chrome, sound design, sprite work) is deliberately **out of
scope for this document** and is a later pass. Numbers below are first-pass tuning
defaults, not final balance — they exist so the system is testable on day one.

**One-line pitch:** pilot an experimental US stealth sub into the alien deep-sea
factory, photograph it, and get out — armed only with zero-kill gear, because the
things guarding it (Sirens) instakill anything that reads as a threat.

---

## 1. Core fantasy & the central knot

You cannot win a fight. The Sirens are superior tech; the conspiracy lore is that they
vaporize military craft on contact. Your in-lore survival hinges on carrying **only
zero-kill equipment** — so the Sirens read you as *curious intruder*, not threat, and
stay in a low-aggression state. Push that goodwill (get loud, get aggressive, get
caught) and you trigger the lore-accurate instakill.

**Central knot — perceiving is being perceived.** Every way of seeing the world costs
you suspicion or a scarce resource. The whole game lives in that tension.

---

## 2. Player vessel (the sub)

- Lives in a continuous 2D top-down bounded play area. Has position + heading.
- Moves **slowly**. It is not an agile combatant; it is the fragile thing that must survive.
- Does not directly engage. It perceives, deploys drones, and fires disruption torpedoes.
- **Hull integrity:** small pool (default 3) for terrain collisions and Siren contact at
  alert level. Hull depletion = **sunk** (lose). Distinct from the instakill (below).
- **Sub fallback camera:** a grainy, long-range cam mounted on the sub. It *can* capture
  any objective, so you are never hard-stalled — but shooting a close/interior objective
  forces the slow, fragile sub into short range, which means heavy hull exposure and fast
  suspicion gain via the proximity terms (§6). Always available, deliberately dangerous.
  Drones are the smart play; the sub cam is the desperate one.
- **Oxygen:** a slow, always-on drain bounds total run length and punishes camping.
  Depletion = **lose** (suffocate/stranded). Slow enough that a clean run finishes
  comfortably; only dithering runs you dry. The bounding clock, not the primary threat.

---

## 3. Perception system (the knot, mechanized)

Four ways to see, each with a cost. This is the most important system in the game.

| Mode | Reveals | Suspicion cost | Notes |
|---|---|---|---|
| Passive sonar | Rough nearby blips, no detail | 0 | Always on. Safe but near-blind. |
| Active ping | Wide terrain + contacts, fades in ~3s | **High (+25)** | The "seeing = being seen" act. |
| Recon plane call-in | Large sector reveal, longer duration | Low (+8) | Consumable (default 2). Precious. |
| Drone cam | Local vision radius around each drone | 0 to deploy/move | Drones are distributed eyes; exposed. |

Reveals are **transient** — the world fades back toward darkness after the reveal window
(Iron Lung "the camera is the only way to see" feel). Passive is the only constant.

---

## 4. Drones (Duskers-lite, torpedo-launched)

- Limited supply (default 5). Launched from a torpedo tube to a clicked destination.
- **Point-and-click control** (CLI deliberately dropped — test-bed decision).
- Functions:
  - **Scout** — provide drone-cam vision at their location.
  - **Photograph** — drones are the **primary, low-risk camera**: they get close at low
    suspicion and capture full-detail shots of any objective, including interior/close ones.
  - **Decoy** — park a drone to bait a curious Siren (see §6).
- Drones are **expendable but finite**. A destroyed drone is gone.
- **Losing all drones no longer strands you** — the sub's fallback cam can still finish the
  mission (§2, §8), but at far higher risk. Drones are the safe path, not the only one.

---

## 5. Disruption tools (window-creators, never kills)

No tool kills a Siren. No Siren has an HP bar. Tools buy **time**, and using them near or
against a Siren **spikes your own suspicion** — the save-tool-draws-heat tension.

- **Jamming** (default 3 charges): reduces sub detectability / scrambles Siren localization
  for a window. Small suspicion cost (+5). Your "lower the heat / break a lock" tool.
- **EMP torpedo** (default 3): stuns/blinds one Siren for ~5s (halts movement + detection).
  Fire cost +20 suspicion.
- **Knockdown torpedo** (default 2): bola-snare + downthrust screws drag a Siren to the
  seafloor, immobilized ~12s. Longer window than EMP, rarer. Fire cost +20 suspicion.

---

## 6. Suspicion system (the spine)

A tracked scalar, 0–100. (Form layer decides HUD bar vs. diegetic sound; functionally
it's a number.)

**Gain sources:** active ping +25 · drone photo +15 · EMP/knockdown fire +20 ·
jamming +5 · recon call-in +8 · factory proximity +1 to +3/sec (scales with closeness) ·
Siren-near-sub +scaling/sec (closer = faster).

**Sub-cam shots carry no flat photo cost** — instead the sub's required proximity drives
the proximity terms above. That exposure *is* the cost, which is why the sub cam is the
dangerous option.

**Decay:** −5/sec when passive (no pinging/firing, drifting slow, clear of Sirens and not
hugging the factory).

**Threshold states (drive Siren behavior in §7):**

- **0–33 Curious:** Sirens drift to investigate pings/decoys/drones; slow; non-lethal
  approach. This is the lore grace window your zero-kill loadout earns.
- **34–74 Alert:** Sirens converge on last-known contact; faster; destroy drones; ram sub
  (hull damage).
- **75–99 Hostile:** coordinated hunt. **Warning state begins** (the fairness valve).
- **100 sustained ≥4s:** **instakill** — a Siren vaporizes the sub. Run over.

**Fairness valve:** at 75+, an escalation cue fires. If you break contact (jam, flee,
knockdown the nearest Siren, go passive) and drop below threshold within the ~4s window,
you survive. Only *sustained* max kills. A spike is a crisis you can fight out of — not a
coin flip. This is the line between hard and unfair.

---

## 7. Sirens (multiple, distinct, legible)

Not killable. Stun / immobilize / evade / bait only. Three types for the test bed, each
with **consistent, learnable rules** so every death is traceable to a decision.

- **Patroller** — fixed looping route, predictable. Deviates only at Alert+. The fair anchor.
- **Sentinel** — stationary / small orbit guarding a key photo objective; large detection
  radius. The zone you must time, sneak, or disrupt. Forces tool use.
- **Hunter** — dormant until suspicion hits Alert; then actively pursues last-known contact;
  fast. The threat your own noise summons.

**Detection inputs (consistent across all types):** active pings (heard), proximity, nearby
drone activity, weapon fire. No hidden detection — if a Siren found you, a rule you can name
did it.

**Curiosity (cross-cutting, Curious-state behavior):** any Siren in Curious state will move
to investigate a decoy drone or a recent ping. This makes a Siren **approachable, baitable,
and photogenic** — the exploit verb. Bait one in with a decoy, photograph it or snare it,
slip past. Your survival justification *is* a playable mechanic.

---

## 8. Objectives & win/lose (route, not click)

**Mission:** capture required photos, then return to the extraction point.

- Required photos (default 3): factory silhouette · construction bays · power core.
- Bonus photo (default 1): a Siren at close range.
- **Two ways to take any shot:** a **drone** (clean, low-risk, get it close) or the **sub
  fallback cam** (must close the sub to range — high exposure). The *silhouette* is
  comfortably sub-cammable from distance; the *bays*, *power core*, and *Siren close-up*
  strongly favor a drone, since closing the sub to that range is near-suicidal but possible.
- A drone photo spikes suspicion +15; a sub-cam photo's cost is the proximity it demands (§6).
- Objectives are spread across the site so suspicion escalates across a **route**, and the
  return leg is the gauntlet.

**Win:** all required photos captured AND sub reaches extraction.
**Lose:** sub vaporized (suspicion max) · sub sunk (hull depleted) · oxygen depleted.

---

## 9. Core loop

Drift in on passive sonar → spend a ping or recon to locate factory, Sirens, terrain (you
see; suspicion ticks) → route toward an objective, drones forward as eyes, terrain as cover
→ reach a photo position, take the shot (drone if you can, sub cam if you must), use
EMP/knockdown/jam/decoys to open windows when a Siren closes → repeat per objective as
suspicion trends up, drones and oxygen deplete → run the gauntlet back to extraction before
suspicion maxes, you're sunk, or the air runs out.

---

## 10. Difficulty & fairness principles (codified)

1. Death is always traceable to a player decision. Threats telegraph; information is purchasable.
2. No enemy HP. No player kill-path. Asymmetry is the point.
3. Tools buy time and cost heat. Nothing is free.
4. Mistakes are recoverable via the suspicion-decay + warning valve. One error ≠ instant restart.
5. Sirens obey consistent, learnable rules. Difficulty rises from scarcity + escalating
   suspicion, never from RNG ambush or damage spikes.

---

## 11. Build leash for Cowork (scope — read this)

**Target:** one playable build. 2D top-down. **ONE hand-authored site. No proc-gen.**

**Build order (do not skip ahead):**
1. Sub movement + passive/active sonar + terrain + collision/hull + oxygen drain.
2. Suspicion meter + ONE Siren (Patroller) + the four threshold states + warning valve.
3. Drones (deploy / move / cam / photograph) + sub fallback cam + photo objectives + win/lose.
4. The other two Siren types (Sentinel, Hunter) + curiosity/decoy behavior.
5. The three disruption tools (jam / EMP / knockdown).
6. Recon call-in.
7. Tuning pass — then stop and hand back for playtest.

**DO NOT (v1):** proc-gen, multiple levels, meta-progression, menus beyond start/restart,
dialogue, narrative cutscenes, OR any art/sound/aesthetic polish. Form is a separate pass.

**Tunable defaults (first pass, expect to change):** drones 5 · EMP 3 · knockdown 2 ·
jam 3 · recon 2 · hull 3 · oxygen ≈ enough for one unhurried full run (tune so a clean run
finishes with margin, camping does not) · suspicion ping +25 / drone photo +15 / EMP+KD +20 /
jam +5 / recon +8 / decay −5•s⁻¹ · thresholds 33/74/99, instakill at 100 sustained 4s ·
Sirens 3 · required photos 3 + 1 bonus.

The single most important thing to get right in tuning is **Siren detection legibility** —
the player must always be able to reason about why a Siren noticed them. That dial is the game.

---

# SIREN'S SONG — Cowork Project Instructions (Wrapper)

*Wrapper v0.2 — updated 2026-06-03. Source: this design session only. Prior [VERIFY] flags
resolved; see Decision Log at the foot of this file.*

## Project Identity

A fully standalone game-dev project space for building and iterating **Siren's Song**, a
one-shot, single-site, 2D top-down stealth game built as a **test bed**. The player pilots a
zero-kill experimental stealth sub to photograph an alien deep-sea factory guarded by
unkillable "Sirens." The project is exploratory: the goal is a playable prototype that proves
the loop, not a shipped commercial title.

## Source of Truth & Document Hierarchy

- **This file is the single canonical spec.** It is built up incrementally across sessions —
  **append, don't fork.** New decisions amend the relevant section and log to the Decision
  Log; supersede with a version bump, never spawn parallel docs.
- §1–10 = functional design (what the game is). §11 = build leash (how Cowork builds it).
  This wrapper = project governance (how the space operates).
- Build outputs (code, the playable file) are products *of* this spec. If code and spec
  disagree, **the spec wins** unless Pat amends the spec.

## Domain Invariants (do not drift)

These are the project's canon. Any build, edit, or "improvement" that violates one is wrong
by definition, even if it seems like a better game:

1. **No enemy HP. No player kill-path.** Sirens are never defeatable. Tools disrupt; they
   never deal lethal damage. A build that adds a Siren health bar has failed the brief.
2. **Suspicion is the spine.** Threat escalation runs through the suspicion meter and its
   four states — not through scripted aggression or RNG.
3. **Perceiving costs.** Every way of seeing carries a suspicion or scarcity cost. Nothing
   reveals the world for free except passive sonar.
4. **Tools buy time and cost heat.** No tool is consequence-free.
5. **Fairness valve is mandatory.** Suspicion decays; instakill only on sustained max with a
   warning window. One mistake must never be an un-survivable instant restart.
6. **Function before form.** No art, sound, palette, or UI-chrome work until the systems are
   built and tuned. Form is always a later, separate pass.

## Build Governance (Cowork)

- Follow the §11 build order exactly. **Stop after each numbered step and hand back for
  review** — do not run the whole pipeline unattended.
- Honor the §11 DO-NOT list. No proc-gen, multi-level, meta-progression, or menus beyond
  start/restart in v1.
- All balance numbers are tunable defaults; changing them is expected. Changing the
  invariants above is not.
- **Implementation is Cowork's call.** Pick whatever reaches a playable build fastest under
  the one-shot constraints: runs locally without a heavy toolchain, 2D top-down, fits the
  test-bed scope. The "figure it out on the fly" approach is sanctioned — don't over-engineer
  the stack.

## Boundaries

- This is a **fully standalone project.** It does not connect to, reference, or share
  anything with any other project or IP. Keep it self-contained.
- Lore base is generic military + conspiracy-theory material (UFO USOs, the
  underwater-factory meme): original framing, influences only, not reproduction.

## Quick Reference

- Unkillable enemies, no kill-path — ever.
- Suspicion meter is the entire difficulty engine.
- Seeing = being seen.
- Drones safe + clean; sub cam is the dangerous fallback.
- Function before form; build in §11 order, stop per step.
- This file is the source of truth; append, don't fork.

---

## Decision Log

### v0.2 — 2026-06-03
- Titled **Siren's Song** (was working title "Deep Contact").
- **Camera resolved:** sub carries a grainy long-range **fallback cam** (can shoot any
  objective, but must close range = high exposure); **drones remain the primary, safe, clean
  platform** for detail/close shots. Drone depletion no longer hard-stalls a run.
- **Win confirmed:** capture required photos + **return to extraction**.
- **Oxygen clock ON:** slow always-on drain bounds run length and punishes camping;
  depletion = loss. (Replaces the old "stranded on last drone" loss condition.)
- **Tech stack:** Cowork's choice on the fly, within the one-shot constraints (no longer pinned).
- **Confirmed fully standalone;** all other-IP references removed.

### v0.1 — 2026-06-03
- Initial functional spec (§1–11) + Cowork project-instructions wrapper.
