# SIREN'S SONG — Functional Spec (v0.3, function before form)

**What this is:** a build input for Cowork. Systems and rules. The form layer (pixel art,
palette, sprite work) is a later pass — but note v0.3 promotes **audio** and **noise** to
core systems, not polish. Numbers are first-pass tuning defaults; they exist so systems are
testable, not because they're balanced.

**One-line pitch:** pilot an experimental US stealth sub into the alien deep-sea factory,
photograph it, and get out — armed only with zero-kill gear, because the things guarding it
(Sirens) instakill anything that reads as a threat.

---

## 1. Core fantasy & the two knots

You cannot win a fight. The Sirens are superior tech; the lore is that they vaporize military
craft on contact. Your zero-kill loadout means they read you as curious intruder, not threat —
push that goodwill and you trigger the lore-accurate instakill.

The game lives in two tensions:

- **Knot A — perceiving is being perceived.** Every way of seeing (active ping, recon, drone
  cam) costs suspicion or a scarce resource.
- **Knot B — moving is being heard.** Throttle is a noise signature. Speed makes you loud;
  loud draws Sirens to investigate. Creeping is silent but slow. (New in v0.3 — see §6.)

---

## 2. Player vessel (the sub)

- Continuous 2D top-down bounded area. Position + heading. **Face-and-thrust handling** —
  turns toward target at a limited rate and drives along its nose, with momentum/drag. It is
  a slow, fragile vessel, not an agile combatant.
- **Hull integrity:** small pool for terrain/contact. Depletion = **sunk** (lose).
- **Sub fallback camera:** grainy long-range cam. Can shoot any objective, but a close shot
  forces the sub into short range = heavy exposure (§6). Drones are the safe alternative (§4).
- **Oxygen:** slow always-on drain bounds run length and punishes camping. Depletion = lose.
- **Throttle = noise (new):** the faster you move, the louder your signature (§6).
- **Silent running (new):** a toggle that cuts engines — noise drops to near-zero and you
  cannot move. The held-breath beat for letting a Siren drift past. Oxygen still ticks.

---

## 3. Perception system (Knot A)

Four ways to see, each with a cost; all gated by line-of-sight (obstacles cast sonar shadows).

| Mode | Reveals | Cost | Notes |
|---|---|---|---|
| Passive sonar | Rough nearby contacts, LOS-gated | 0 | Always on. Safe, near-blind. Lit bubble with visible blind cones. |
| Active ping | Wide reveal, fades in ~3s, LOS-gated | High suspicion + **summons** (§7) | Lit sweep with visible shadow cones behind rock. |
| Recon plane call-in | Large sector reveal | Low, consumable | Precious. |
| Drone cam | Local vision at each drone | Drone exposure | Distributed eyes (§4). |

Reveals are transient — the world fades back to dark. Obstacles block sonar; what's in a
shadow cone is invisible to you (and you to a Siren whose LOS is blocked — cover cuts both ways).

---

## 4. Drones (the identity system — currently unbuilt in prototype)

Torpedo-launched submersibles. The half of the design the prototype stands in for with the
sub cam; this is the priority build-out.

- Limited supply (default 4–5). Point-and-click a destination; the drone travels there.
- **Roles:**
  - *Scout* — provides a drone-cam vision bubble at its location. Push it into the hot zone
    so the fragile sub doesn't have to.
  - *Photograph* — the **primary, low-risk camera**: gets close at low exposure and captures
    full-detail shots (higher photo quality than the sub cam — see §8 scoring).
  - *Decoy* — a parked drone draws curious/investigating Sirens (§7), letting the sub slip.
- **Expendable, finite.** Sirens destroy drones at Alert+. A moving drone near a Siren is a
  small detection/noise source (it can be investigated). Losing all drones does not strand you
  (sub fallback cam), but loses safe scouting.

---

## 5. Disruption tools (window-creators, never kills)

No tool kills a Siren; none has an HP bar. Tools buy time; using them near a Siren spikes
your own suspicion (save-tool-draws-heat).

- **Jamming:** reduces sub detectability for a window. Cheapest. Break-a-lock tool.
- **EMP (area blast):** stuns *every* Siren in blast radius. The panic-freeze. **See the §6
  kill rule** — a stunned Siren cannot execute the vaporize, so EMP is a real self-defense tool.
- **Knockdown torpedo (single-target, currently unbuilt):** bola-snare + downthrust screws
  drag one Siren to the seafloor, immobilized for a *long* window — longer than EMP's stun.
  The tool for slipping past one specific guard (e.g., the Sentinel on the power core).
- **Decoy:** parked lure; pulls Sirens via the attention system (§7).

---

## 6. Suspicion system (the spine)

A tracked scalar 0–100.

**Gain sources:** active ping · taking a photo · firing EMP/knockdown · jamming · recon ·
factory proximity (scales with closeness, §9) · a Siren detecting you (proximity + LOS) ·
**noise from throttle (new):** a loud sub within a Siren's hearing range raises detection and
flags it to investigate your position, even with no ping. Silent running zeroes this.

**Decay:** bleeds off (default 3/s) only after a short delay (default ~1.8s) since the last
noise/gain. Sticky by design — a managed resource, not a transient.

**Threshold states:** Curious (low) → Alert (mid) → Hostile (high, warning) → instakill at
sustained max.

**KILL RULE (the EMP/cover fix — new in v0.3):** the vaporize at max suspicion only fires
while **at least one un-stunned Siren currently has detection (proximity + line-of-sight) on
the sub.** If every nearby detector is stunned (EMP/knockdown) or LOS-broken (cover), the
execution is **suspended** — suspicion may sit at max, but nothing pulls the trigger until a
Siren can act. This makes EMP and cover genuinely life-saving and fixes "I EMP'd and still
died." (Note: stunned Sirens already stop *adding* detection — this rule fixes the kill timer
itself, which previously ran on the abstract meter regardless of whether anything could see you.)

**Fairness valve (retained):** at Hostile, a warning fires; break contact (jam, flee, EMP,
knockdown, cover, silent-run) and drop below threshold within the window to survive.

---

## 7. Sirens (multiple, distinct, legible)

Not killable. Stun / immobilize / evade / bait only. Consistent, learnable rules so every
death is traceable to a decision.

- **Types:** Patroller (predictable loop, the fair anchor) · Sentinel (guards an objective,
  large detection, tethered) · Hunter (dormant until Alert, then fast pursuit).
- **Distinct silhouettes & behaviors (new):** each type reads instantly on sight, not just by
  label — different shape, motion cadence, and tell.
- **Detection inputs:** active pings (heard), proximity, **throttle noise (new)**, nearby
  drone activity, weapon fire. All LOS-gated. No hidden detection.
- **Attention / decoy:** a Siren routes to the nearest active decoy or recent ping/noise it
  heard.
- **Search memory (new):** after investigating a point and finding nothing, a Siren sweeps the
  local area in a short pattern before returning to station — instead of snapping straight home.
  Reads as smarter, gives you a tense "did it give up?" beat.
- **Curiosity as bait (lean in):** a curious/investigating Siren that approaches is a high-value
  close photo (bonus objective, §8) and an easy knockdown setup. Bait-and-shoot is rewarded.

---

## 8. Objectives, scoring & win/lose

**Mission:** capture required photos (default 4: silhouette · bays · power core · factory),
then return to extraction. Bonus: a close Siren photo.

- Each shot can be taken by a **drone** (clean, low-risk, high quality) or the **sub fallback
  cam** (must close range, high exposure, lower quality).
- **Photo quality scoring (new):** each capture is graded by proximity and clarity — a close
  drone shot scores higher than a distant sub-cam grab. The end screen shows a grade/score.
  Rewards bravery and gives replay incentive. (Decision pending: do low-quality shots still
  "count" toward the win, or is there a minimum threshold? Default: all count, score varies.)

**Win:** all required photos captured AND sub reaches extraction.
**Lose:** vaporized (kill rule, §6) · sunk (hull) · oxygen depleted.

---

## 9. Factory activity (new)

The factory is not a static hazard zone — it's *active*.

- **Escalation on capture:** each photo you take raises global Siren alertness a notch (the
  base notices its systems being documented). The run gets hotter as you progress — the factory
  shot (already the hot-zone climax) becomes the tensest because it's last and the base is most alert.
- **Optional cycle:** a visible build/charge timer on the factory as a soft second clock
  beyond oxygen. Tunable; can ship the escalation-on-capture alone for v1.

---

## 10. Audio (new — core, not polish)

This genre lives on sound (Iron Lung is effectively a sound game). Treat as a build pillar.

- Sonar: outgoing ping tone + return blips for revealed contacts.
- Suspicion: rising heartbeat/alarm bed that intensifies Curious → Alert → Hostile.
- Ambient: deep-sea pressure drone; hull creak near the factory / deep zones.
- Threat: muffled Siren vocalization when one is close — a directional dread cue you hear
  before you see.
- Action: EMP electric discharge, knockdown thrum, camera click on capture, vaporize boom,
  extraction surface tone, silent-running breath-hold bed.
- Implementation: procedural Web Audio for the prototype; real SFX for the build.

---

## 11. Narrative layer (new)

Cheap, high meaning-payoff (Iron Lung's whole gut-punch was one letter).

- One-line mission briefing on dive.
- 2–3 intercepted-comm / log fragments discoverable in the world that recontextualize the
  mission (e.g., this was never meant to be a return trip).
- Ending stingers differ by outcome: extracted / vaporized / suffocated.

---

## 12. Environmental texture (new — mostly form)

- **Currents** that nudge the sub (navigation texture; interacts with momentum).
- **Thermal layers** — bands that mask or distort sonar; a tactical hiding zone.
- Marine snow / particulate (in prototype). Sonar sweep-line on the sub (cosmetic radar).

---

## 13. Core loop

Drift in on passive sonar, throttle low to stay quiet → spend a ping or recon to locate
factory, Sirens, terrain (you see; you make noise; they hear) → push drones forward as eyes
into the hot zones, route the sub through cover → reach a photo position, take the shot (drone
for quality, sub cam if you must) → manage the suspicion spike with EMP/knockdown/jam/decoy/
silent-running/cover, knowing the base gets hotter with every capture → run the gauntlet back
to extraction before suspicion maxes with a detector on you, or you're sunk, or the air runs out.

---

## 14. Difficulty & fairness principles

1. Death is always traceable to a decision. Threats telegraph; info is purchasable.
2. No enemy HP, no player kill-path. Asymmetry is the point.
3. Tools buy time and cost heat. Nothing is free.
4. **You can always survive a max-suspicion moment** by disabling every detector (EMP/knockdown)
   or breaking all line-of-sight (cover/silent-running). The kill needs an active witness (§6).
5. Mistakes are recoverable via decay + the warning valve. One error ≠ instant restart.
6. Sirens obey consistent, learnable rules. Difficulty rises from scarcity, escalation, and
   noise/perception management — never RNG ambush.

---

## 15. Build leash & sequencing (read this)

**Target:** 2D top-down, ONE hand-authored site, no proc-gen. Build order for the v0.3 work,
each step playtested before the next:

1. **EMP/kill-rule fix** (§6) — small, high value. Vaporize requires an active detector.
2. **Speed-as-noise + silent running** (§2, §6) — one variable, deepens stealth most per line of code.
3. **Drones** (§4) — the identity system. Deploy / scout / photo / decoy.
4. **Knockdown torpedo** (§5).
5. **Audio** (§10) — procedural pass; it's a pillar.
6. **Photo scoring + factory escalation** (§8, §9) — pressure and replay.
7. **Siren search memory + distinct silhouettes** (§7).
8. **Narrative fragments** (§11).
9. **Environmental (currents/thermal) + remaining form polish** (§12).

**DO NOT (v1):** proc-gen, multiple levels, meta-progression, menus beyond start/restart.
All balance numbers are tunable defaults; the invariants below are not.

---

# SIREN'S SONG — Cowork Project Instructions (Wrapper)

*Wrapper v0.3 — updated 2026-06-03. Source: design + prototype sessions. Provenance for v0.3
decisions is in the Decision Log.*

## Project Identity

A fully standalone game-dev project space for building and iterating **Siren's Song**, a
one-shot, single-site, 2D top-down stealth game built as a test bed. Pilot a zero-kill stealth
sub to photograph an alien deep-sea factory guarded by unkillable "Sirens." Goal: a playable
prototype that proves the loop, not a shipped commercial title.

## Source of Truth & Document Hierarchy

- **This file is the single canonical spec.** Built up incrementally — append/amend, don't
  fork. New decisions amend the relevant section and log to the Decision Log; version bump on
  supersede.
- §1–14 = design. §15 = build leash. Wrapper = project governance. Companion: SIRENS_SONG_dev_notes.md.
- Build outputs are products *of* this spec. If code and spec disagree, the spec wins unless
  Pat amends the spec.

## Domain Invariants (do not drift)

1. **No enemy HP. No player kill-path.** Sirens are never defeatable; tools only disrupt.
2. **Suspicion is the spine**, with the kill rule: vaporize needs an active, un-stunned,
   line-of-sight detector. Disabling all detectors or breaking LOS suspends the kill.
3. **Perceiving costs, and moving makes noise.** Nothing reveals or moves for free except
   passive sonar / silent running.
4. **Tools buy time and cost heat.** No tool is consequence-free.
5. **Fairness valve mandatory.** Suspicion decays; the kill is survivable. One mistake ≠ instant restart.
6. **Audio and noise are core systems, not polish.**
7. **Function before form.** Build systems before art; but audio ships with the systems.

## Build Governance (Cowork)

- Follow §15 order; stop after each step and hand back for review.
- Honor the §15 DO-NOT list.
- Balance numbers are tunable; invariants are not.
- Implementation is Cowork's call within the one-shot constraints (runs locally, no heavy
  toolchain, 2D top-down). The "figure it out on the fly" approach is sanctioned.

## Boundaries

- Fully standalone. Does not connect to, reference, or share anything with any other project or IP.
- Lore base is generic military + conspiracy-theory material: original framing, influences only.

## Quick Reference

- Unkillable enemies, no kill-path — ever.
- Suspicion is the engine; the kill needs an active witness (EMP/cover saves you).
- Seeing = being seen; moving = being heard.
- Drones safe + clean; sub cam is the dangerous fallback.
- Audio is core. Function before form; build in §15 order, stop per step.
- This file is the source of truth; append, don't fork.

---

## Decision Log

### v0.3 — 2026-06-03
**Provenance:** [PAT] raised the EMP problem — "Emp'd enemies shouldn't continue to increase
your detection... it's not a good self-defense tool if you can still die from it." [PAT] then
directed "do it all with a spec first," ratifying the full feature set and spec-first
sequencing. The mechanical detail of each feature below is [KEEL] design proposal pending
playtest — confirmed in scope, not yet in balance.

- **EMP/kill rule:** vaporize now requires an active un-stunned LOS detector; disabling all
  detectors or breaking LOS suspends the kill. ([KEEL] correction: stunned Sirens already
  stop adding detection — the real bug was the kill timer running on the abstract meter.)
- **Noise as a second axis:** throttle generates a noise signature (§2, §6); silent-running
  toggle zeroes it and freezes movement.
- **Drones fleshed out** (§4) as the priority unbuilt system: scout / photo / decoy, expendable.
- **Knockdown torpedo** (§5) specced as the single-target long-disable, distinct from EMP.
- **Audio** (§10) promoted to a core build pillar.
- **Photo quality scoring** (§8); **factory escalation-on-capture** (§9).
- **Siren search memory + distinct silhouettes** (§7).
- **Narrative fragments + briefing + ending stingers** (§11).
- **Environmental texture** (§12): currents, thermal layers.
- Spec reorganized to 15 sections to hold the new systems.

### v0.2 — 2026-06-03
- Titled Siren's Song. Camera: sub fallback + drones for detail. Win: return to extraction.
  Oxygen clock on. Tech: Cowork's choice. Confirmed standalone.

### v0.1 — 2026-06-03
- Initial functional spec + Cowork project-instructions wrapper.
