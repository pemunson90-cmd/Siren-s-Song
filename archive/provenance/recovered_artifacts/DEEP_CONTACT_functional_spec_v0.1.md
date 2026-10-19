# DEEP CONTACT — Functional Spec (v0.1, function before form)

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
- Optional slow power/battery drain bounds total run length and discourages infinite
  camping. Off by default; enable if playtests stall. Not a primary threat.

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
  - **Photograph** — drones are the primary camera platform. Objectives require a drone
    positioned in range + line of sight, then trigger the shot.
  - **Decoy** — park a drone to bait a curious Siren (see §6).
- Drones are **expendable but finite**. A destroyed drone is gone. Losing your last drone
  before objectives are complete = stranded (soft loss).

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

**Gain sources:** active ping +25 · taking a photo +15 · EMP/knockdown fire +20 ·
jamming +5 · recon call-in +8 · factory proximity +1 to +3/sec (scales with closeness) ·
Siren-near-sub +scaling/sec (closer = faster).

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
- Each photo = a drone positioned in range + line of sight + trigger; taking it spikes
  suspicion (+15). Objectives are spread across the site so suspicion escalates across a
  **route**, and the return leg is the gauntlet.

**Win:** all required photos captured AND sub reaches extraction.
**Lose:** sub vaporized (suspicion max) · sub sunk (hull depleted) · stranded (last drone
lost pre-objectives) · (optional) power drain hits zero.

---

## 9. Core loop

Drift in on passive sonar → spend a ping or recon to locate factory, Sirens, terrain (you
see; suspicion ticks) → route toward an objective, drones forward as eyes, terrain as cover
→ reach a photo position, eat the suspicion spike, use EMP/knockdown/jam/decoys to open
windows when a Siren closes → repeat per objective as suspicion trends up and resources
deplete → run the gauntlet back to extraction before suspicion maxes or you're sunk.

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
1. Sub movement + passive/active sonar + terrain + collision/hull.
2. Suspicion meter + ONE Siren (Patroller) + the four threshold states + warning valve.
3. Drones (deploy / move / cam / photograph) + photo objectives + win/lose.
4. The other two Siren types (Sentinel, Hunter) + curiosity/decoy behavior.
5. The three disruption tools (jam / EMP / knockdown).
6. Recon call-in.
7. Tuning pass — then stop and hand back for playtest.

**DO NOT (v1):** proc-gen, multiple levels, meta-progression, menus beyond start/restart,
dialogue, narrative cutscenes, OR any art/sound/aesthetic polish. Form is a separate pass.

**Tunable defaults (first pass, expect to change):** drones 5 · EMP 3 · knockdown 2 ·
jam 3 · recon 2 · hull 3 · suspicion ping +25 / photo +15 / EMP+KD +20 / jam +5 /
recon +8 / decay −5•s⁻¹ · thresholds 33/74/99, instakill at 100 sustained 4s · Sirens 3 ·
required photos 3 + 1 bonus.

The single most important thing to get right in tuning is **Siren detection legibility** —
the player must always be able to reason about why a Siren noticed them. That dial is the game.
