# SIREN'S SONG — Pressure & Difficulty Design

**Status: DESIGN PROPOSAL (Keel, designer hat). Not ratified, not built. For Pat's review.**
*This is my call on the root problem and the system to fix it. Nothing touches the prototype until you green-light it.*

---

## 1. Diagnosis (committed — no hedging)

There is exactly one root cause, and all three of your symptoms grow from it:

**Nothing in the run escalates.** The patrols are static, the oxygen drain is flat and linear, the space is uniform, and failure is a single binary instakill. There is no curve.

- **"It feels flat / missing something"** → there's no arc. A dread game builds: safe → tense → climax → desperate escape. Yours is one tension level the whole way.
- **"Too easy"** → the baseline is a calm coast. Nothing mounts against you, so most of the run is a low-stakes walk — and the movement fix (correctly) made that coast even smoother.
- **"Too hard"** → all the difficulty is crammed into one place: the binary instakill in the guarded zones. It's the *only* source of pressure, and it's all-or-nothing.

Flat floor + lethal ceiling, nothing connecting them. Fix the connection — build a rising slope — and all three resolve together.

---

## 2. Design goal

Replace *flat-floor-plus-lethal-ceiling* with a **felt rising slope**: a run that starts dormant and tightens into a desperate climax, where danger you can *see coming* forces you to act. The player should always be able to point at the meter and say "it's getting worse, and it's getting worse because of what I'm doing."

---

## 3. The core system: THE HUNT

A single global pressure meter, 0–100, that represents the base waking up to you. This is the spine the whole game has been missing.

**What raises it**
| Source | Why | First-pass |
|---|---|---|
| Time inside | the base slowly notices an intruder | +0.6 / sec |
| Taking a photo | it feels its systems being documented | +8 each |
| Active ping | loud, broadcasts you | +5 each |
| EMP / knockdown fired | overt aggression | +4 each |
| A Siren acquiring you (detection event) | confirmed contact | +6 each |

**The ratchet (this is the important part).** The Hunt cools slowly between encounters (−1/sec after 6s of no detection and no actions) **but never drops below a floor set by your progress** — floor = `photosTaken × 8`. So you get breathing room after a close call, but the run *trends upward* and can never reset to easy. Progress is one-way pressure.

**Why this fixes "too easy":** the coast is no longer free. Standing still costs time; acting costs more. There's always a low-grade clock, and sloppiness spikes it.

**Why this fixes "missing something":** the meter *is* the arc. The run now has a shape because the Hunt climbs.

---

## 4. The escalation ladder (the slope that replaces the cliff)

The Hunt drives five staged states. This **replaces** the current ad-hoc `baseAlert × 0.04` detection bump with a coherent, readable curve. Each stage visibly and audibly changes the world so the player *feels* it tightening.

| Stage | Hunt | Sirens | Factory / world | Audio |
|---|---|---|---|---|
| **0 Dormant** | 0–20 | lazy patrols, base detection | quiet | calm ambient |
| **1 Stirring** | 20–45 | detection ×1.15, +10% patrol speed | first low pulse | a heartbeat begins |
| **2 Searching** | 45–70 | ×1.3, leave stations to sweep, longer investigates, hunter stirs | factory lights shift | rising bed |
| **3 Hunting** | 70–90 | ×1.5, hunter actively pursues, Sirens drift toward objectives & last-known | **factory powers up (visible)** | tense, driving |
| **4 Lockdown** | 90–100 | ×1.7, everything converges on objectives + extraction; a Siren roams the extraction zone | full alert | alarm |

The point: at Stage 0 you explore freely; by Stage 4 the map you walked in calmly is now hostile and the way out is contested. The danger you face at any moment is a function of how loud your run has been — and you can read it climbing.

---

## 5. Graduated failure (kill the binary)

The instakill stays as the *ultimate* fail (lore-true: they vaporize confirmed threats). But we add a survivable middle so detection isn't pass/die:

- **Graze.** At Hostile suspicion (≥75) with a Siren detecting you for >1.5s, you take a **warning hit** — hull damage (−20), not death — and a Hunt spike (+6), then a short cooldown so it's not a continuous grind. You can survive being seen, but you bleed for it.
- **Death** is still suspicion 100 + active detector sustained for the kill-hold. Now it's the *end* of a slope you've been sliding down (graze → repeated exposure → kill), telegraphed the whole way by the rising Hunt.

This gives the game the "wounded but alive" state it completely lacks today. A mistake costs you; it doesn't always end you.

---

## 6. The run arc (temporal + spatial)

Two reinforcing curves:

- **Temporal (this system):** Dormant → Stirring → Searching → Hunting → Lockdown, driven by the Hunt.
- **Spatial (level-design principle — that's step 3, but the layout must serve this):** arrange objectives **periphery → core.** Easy shots on the calm edge, the **factory shot as the climax** (last, deepest, and by then the Hunt is highest because you've done the most), and the **return to extraction as the desperate escape** back through a now-alerted map.

You go deeper exactly as the base wakes up. The space and the clock climb together.

---

## 7. The new core tension

**You're racing your own footprint.** Every photo, ping, and tool use advances the Hunt — so every action is now a cost/benefit decision, not a free press. "Is this ping worth a notch of Hunt?" is the question the game has been missing. This is the "perceiving = being perceived" knot scaled up from the moment to the whole run.

It also adds depth **without adding a single button** — the Hunt is a passive meter, not a control. (It may even let us simplify: see oxygen below.)

---

## 8. How this fixes all three symptoms

- **Flat → arc.** The Hunt curve gives the run a beginning, middle, and climax.
- **Too easy → rising floor.** The coast now has a clock that climbs from time and actions and ratchets on progress. You can't dawdle into safety.
- **Too hard → telegraphed slope + graduated consequence.** The lethal moment is now the end of a visible ramp, with a survivable graze state before it — earned and readable, not a surprise binary.

---

## 9. First-pass parameters (all tunable)

- Hunt rise: time +0.6/s, photo +8, ping +5, tool +4, detection-event +6.
- Hunt decay: −1/s after 6s clean; hard floor = `photosTaken × 8`.
- Stage thresholds: 20 / 45 / 70 / 90.
- Detection multipliers by stage: 1.0 / 1.15 / 1.3 / 1.5 / 1.7.
- Graze: trigger at suspicion ≥75 + detector >1.5s → −20 hull, +6 Hunt, 3s cooldown.
- Oxygen: stretch to ~300s as a generous hard backstop so the Hunt, not the air, is the star.

**The single most important tuning lever:** the time-based Hunt rise (+0.6/s). Too fast and it kills methodical play (you can't be patient); too slow and the coast stays toothless. This is the dial we'll spend the most playtests on.

---

## 10. What this touches in the build

- `baseAlert` already exists and already nudges detection — **it becomes the Hunt**, formalized into the staged curve. We're not bolting on; we're finishing a system that's half-seeded.
- Factory escalation-on-capture is already in — it folds into the Hunt cleanly.
- The kill rule gets the graze layer added before the vaporize.
- Oxygen retuned to a backstop.
- The HUD needs a Hunt readout (a second meter, or fold the stage name into the existing state line).

---

## 11. Open decisions — where I want you at my side

I'll drive the design; these are the genuine forks where your playtesting instinct beats my model:

1. **Hunt climb rate** — methodical (slow, you can be patient) vs urgent (fast, always pressured). I lean *slightly* methodical-leaning so stealth still breathes, but you'll feel the right number in 10 minutes of play.
2. **Oxygen** — keep it as a quiet backstop, or fold it entirely into the Hunt (one clock instead of two)? I lean keep-as-backstop, but folding is cleaner.
3. **Graze damage** — does the warning-hit / hull-bleed middle state feel right to you, or do you want detection to stay tense-but-clean (no chip damage) and rely only on the Hunt ratchet for graduated cost?
4. **Does the Hunt ever fully cool, or is it pure one-way ratchet?** I built in slow decay with a progress floor; a pure ratchet would be more relentless.

That's the spec. It's one system, it fixes all three symptoms, it builds on what's already half-there, and it adds depth without adding buttons. Say the word on which way you want decisions 1–4 to fall and I'll build it — but not before.
