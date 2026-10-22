# Design proposal: Priced Shots (trades and fittings)

Nothing here changes damage, hull, collision, lock or beam rules, or Siren sight and hearing. Where a part would, it is marked NEEDS PAT'S DECISION. Mechanics 1 to 4 need no such change.

## 1. Why one solution dominates today

- **Sirens see farther than Quietus senses.** A Siren sees 290 m (180 m if you run silent). Quietus's own sensing is 240 m. Only a drone out-senses a Siren (330 m, 460 m with the survey array). So a drone scout is close to mandatory.
- **Disrupt covers a whole photograph.** It stuns every Siren within 340 m for 12 s. A default exposure lasts 4 s. A stunned Siren cannot hear or see, so its shutter noise is harmless. Disrupt costs one of 2 charges and makes 650 m of noise for 2 s. One charge buys one shot with 8 s to spare. The 3 Decoys (15 s, 1100 m) add a second way out.
- **The shutter is nearly the only noise.** A parked exposure makes almost no motion noise (430 x (v/78)^2, so about 3 m at 7 m/s). The camera is one 520 m ring for 2 s (760 m with flash). Staying slow is free: Ops 0 and 3 have 180 s of oxygen, and a 600 m leg takes 14 s silent versus 8 s cruise.
- **The required feature is easy.** Features such as BEACON LAMP and VENT MOUTH have detail 0.04 and resolve at about 200 m. Only the optional "intel" features need detail 0.38 to 0.5, which means about 100 to 150 m in dim water. Nothing makes the player want that, so the grade is decoration.
- **Fittings are free.** No shot needs one, which is by design (bare completion must stay). The standard hull has only ONE optics mount, so flash, tele, thermal and low-light already compete. Nothing in the briefing tells the player what each op's photo problems are, so the choice is blind.

## 2. Four trade mechanics

**1. Sharp or unseen (distance).**
- Decision: shoot from far (safe, soft, required feature only) or close (sharp, detail features, inside Siren sight).
- Buys and costs: at 100 m a detail 0.45 feature resolves, but you sit inside 180 and 290 m sight. At 200 m only the base shot works. Tele lens reaches 360 m, outside sight but inside the 520 m shutter ring. So the Siren hears you and walks over.
- Chart/HUD: with the camera armed, draw two rings around the target. Green ring: "LINING readable inside 105 m, 170 m with flash." Amber dotted rings: sight radius of known Sirens. Add one line: "If heard, nearest Siren arrives in about 11 s."
- Seams: `photo_capture.frame` already holds the numbers. Call it at trial distances to find each ring (a pure read). Draw beside `acoustic_feedback.gd` and `camera_feed.gd`. Siren speed is read from patrol data.

**2. Light has three prices.**
- Decision when a feature says TOO DARK: flash, lamp range, or wait.
- Flash: a charge (4 on Quietus, 2 on a drone) and a 760 m shutter ring. Lamp: Quietus 0.36 versus drone 0.12, so Quietus must close to about 60 m. Low-light back: costs 8 s of perfect stillness (any drift or turn loses the gain) and no extra noise.
- Chart/HUD: the existing LIGHT bar gets a three-line preview: "FLASH ok, heard 760 m, 3 left / WAIT 8 s ok, heard 520 m / CLOSE to 60 m ok". Drone twist: a drone with a flash can be the loud, expendable photographer while Quietus waits silent.
- Seams: `frame()` with the flash setting toggled, `begin()` and `noise_radius()`.

**3. Two clocks (speed, time, exposure).**
- Decision: a subject shows its feature only in a window (the hatch seam opens 7 s of every 30 s). A patrol also has a gap. The player syncs the two.
- Silent arrives later but unheard. Cruise arrives on time but loud. Waiting in range costs oxygen and exposure time.
- Chart/HUD: once seen, "HATCHES OPEN IN 12 s". Patrol timing uses the existing sweep cues.
- Seams: the `window` field already in features, `_window()` and the shared world clock. This is data authoring plus one countdown readout.

**4. Film and readiness (shot budget).**
- Decision: every secured record raises Hunt by 8 and gives guards who heard it a permanent alert floor of +0.12 (sight and hearing x1.15 at floor 20, x1.3 at 45). Retakes today cost only 3 Hunt and nothing else.
- New: finite FILM (Quietus 8 exposures, drone 4). Unusable or interrupted exposures spend one. The player chooses between one patient great frame and several rushed ones.
- Chart/HUD: "FILM 6/8" beside the flash count.
- Seams: a `film` array in `photo_capture.state()` like `flash`, checked in the camera case of `simulation.gd` (about line 618), plus save validation.

**Disrupt repricing (data only).** Author rewarding shots at about 10 s or more of turn plus dwell. One Disrupt then covers one good shot, not three, so the player must rank shots.

## 3. Fittings plan

| Fitting | Opens | Closes or reprices |
|---|---|---|
| Baffles (propulsion mount) | Cruise-speed repositioning at 236 m noise (versus 430 m); silent is 69 m | Excludes the vector drive, since both use the one propulsion mount |
| Vector drive | Catching a short window; escape from a sweep (887 m noise) | Everything quiet; shutter blur is unchanged |
| Pressure sleeve | Skip a band-guarded stretch, hop back to MIDDLE (photos need MIDDLE) in 2.5 s | Each hop emits a 250 m pump pulse and costs 0.75 reserve |
| Deep cells | Drone stakeout: 28 s of endurance (versus 14) holds a low-light or window exposure unseen while Quietus works elsewhere | Uses the drone hardware mount |
| Flash | Dark detail from 170 m (versus 60 m) | A charge and a 760 m ring |
| Low-light back | Silent dark photos | 8 s still; moving shots get no gain |
| Thermal imager | Heat features from range, in shimmer, no light | Every other feature at 85% resolution |
| Tele lens | 360 m standoff, outside sight | Narrow frame (crops wide subjects), blur above about 8 m/s, and the shutter is still heard at 520 m |

Because there is one optics mount, the whole question is "which problem does this op pose?" That requires the briefing to say so (section 4).

**Example A, Op 3 Cold Foundry.** The FURNACE mouth (glow 0.6) is easy. The VENT LINING (detail 0.45, 40 degree arc, one side) and OPEN FRAMES (detail 0.42) are the intel. Sentinels hold the vent and channel. Bare: park about 100 m off the lining inside sentinel sight, so Disrupt it, and the single charge is gone before the frames. Tele: take the lining from 160 m, out of sight, but the 520 m shutter wakes the sentinel and the cold front weakens that sound, so the player must read the front. Thermal: the frames are warm, so shoot them from 200 m with no light.

**Example B, Op 0 Shelf Signal.** The BEACON LAMP is trivial. SCORED PLATING sits on the lee side (bearing 180 degrees, 1.0 rad arc, detail 0.5), so the player must circle the spire at about 150 m. Silent loop is about 17 s. Baffles allow cruise at 236 m noise for about 9 s, then slow to under 7 m/s to shoot. Without gear, silent loop plus one Disrupt.

## 4. How a new player discovers it

Reuse the one-verb hint system in `onboarding_text.gd` (prompts shown once, never gating pause), raising `MAX_OPERATION` past 2.
- **Op 0, "reach":** arming the camera shows the rings. "Closer is clearer. Sirens see 290 m."
- **Op 1, "light":** the first TOO DARK shows the three-price preview.
- **Op 3, "window":** the first cycle countdown.
- **Op 4, "film":** the counter appears when the second exposure starts.

Also move the fit list to the top of the briefing as "PHOTO PROBLEMS: lining needs 105 m or flash. Your optics: tele." (The cold review found it 2,600 px away.)

## 5. Recommended milestone: PRICED SHOTS (one branch)

**Scope:**
1. Reach rings and "if heard" ETA on the chart (mechanic 1).
2. Three-price light preview (mechanic 2).
3. Window countdown on the HUD (mechanic 3).
4. Film counter (mechanic 4).
5. Photo-problem list at the top of the briefing.
6. Data pass on Ops 0 to 5 (detail values, dwell of about 10 s, windows on Ops 3 and 4).
7. Four hints.

**Files:** `photo_capture.gd`, `simulation.gd` (camera case and save check), `photo_ops.gd`, `onboarding_text.gd`, `camera_feed.gd`, `acoustic_feedback.gd`, `equipment_context.gd`, `mission_hud.gd`.

**Risks:**
- Save format (film array).
- Phone-screen clutter from the rings.
- Retuning Ops 0 to 5 so bare play stays finishable.
- Existing photo tests (794 checks) assume unlimited film.

**Do NOT build:**
- New Siren senses or hearing changes.
- Damage, hull or collision tuning, or new gear types.
- Hard gates that bare Quietus cannot pass on core jobs.
- A photo minigame.
- Score currencies.
- New story text.

## 6. Questions for Pat

1. **Film count.** Is 8 for Quietus and 4 for a drone right? Recommend yes, and make film a visible fitting cost later.
2. **Optional-only gating.** Should sleeve, thermal and tele also gate optional bonus features? Recommend yes, optional only. Core jobs stay finishable bare.
3. **Tele cannot hide the shutter.** The shutter ring stays 520 m. NEEDS PAT'S DECISION if tele should be quieter. Recommend no.
4. **Oxygen.** Tighten Ops 0 and 3 by 15%? Recommend no. Windows and patrol gaps do the work.
5. **Disrupt.** Keep 12 s and 2 charges? Recommend yes. The shot design does the repricing.
6. **Unusable exposures cost film.** Recommend yes, to stop spam retakes.
