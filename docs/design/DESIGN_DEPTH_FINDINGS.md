# Design proposal: Depth-band photos and findings that change the rules

Design only, read from claude/integration (522b665). Numbers come from the current formulas and are not play-tested.

## 1. Feature A: photo depth band choice

**Today.** The camera is refused unless the craft is in MIDDLE and settled (simulation.gd lines 491, 717). Reach is 240 m (360 m with tele), needs a clear line and, for samples, under 12 m/s. Ambient light is 0.16 minus 0.12 x (op depth / 4800): op 0 gives 0.139, op 3 gives 0.101. Haze is exp(-0.0016 x distance). The shutter is a 520 m ring (760 m with flash) in the craft's band. Sirens see only inside a shared band and hear across bands at x0.42 (one apart) or x0.18. A band change takes 4 s (2.5 s with sleeve), is exposed in both bands, and adds 130 m of noise. DEEP drains 0.025 oxygen/s (drone 0.035 battery/s). A sleeve hop costs 0.75 oxygen and a 250 m pulse.

**Proposed rules** (one data table):

| | SHALLOW | MIDDLE | DEEP |
|---|---|---|---|
| Ambient light | x2.2 | x1 | x0.45 |
| Haze | x1.6 | x1 | x0.7 |
| Swell (steadiness) | x0.9 | x1 | x1 |
| Shutter ring | 676 m (flash 988) | 520 (760) | 416 (608) |
| Thermal imager | x0.9 | x1 | x1.1 |
| Tele blur | x1.25 | x1 | x1 |
| Exposure cost | none | none | +0.075 oxygen/s (drone +0.3 battery/s) |
| Distance | sqrt(d squared + 40 squared) | d | same as shallow |

**Buys and costs.** SHALLOW buys light, which only helps dim subjects (glow under about 0.3); a glowing subject already saturates light. It costs haze, swell and a louder shutter. DEEP buys clear water and a quiet shutter: a MIDDLE Siren hears it only inside 416 x 0.42 = 175 m, against 520 m today. It costs darkness (lamp or flash), about 0.6% oxygen per 8 s, and two exposed 4 s shifts. The sleeve cuts the shift to 2.5 s but costs 0.75 per hop. Flash suits DEEP and hurts in SHALLOW; the thermal imager leans the other way.

**Chart and HUD.** The camera panel adds a band line: "DEEP: dark, clear, heard 416 m, costs 0.6% oxygen." The Priced Shots reach rings use the band's ring size. The depth hint changes from "settle in MIDDLE" to a subject-aware hint.

**Seams.** `Photo.frame` (light, haze, steadiness, thermal), `Photo.noise_radius`, `Depth.advance` (oxygen). Depth, pressure and sleeve rules are not redesigned.

**Honest difficulty.** "MIDDLE only" is checked in about six places (simulation.gd 491, 582, 717, 894; `discover` twice). All must call one `can_shoot` function. Sirens stay studiable only from their own band.

**Example 1, Op 0 Shelf Signal.** SCORED PLATING (detail 0.5) at 150 m: MIDDLE sharp is about 0.54, a bare pass. SHALLOW falls to about 0.45 (fails: haze and swell, and the glowing beacon wastes the extra light). DEEP, under the arch, is about 0.53 and the 416 m shutter keeps the patrol away. Verify the lee line is clear in DEEP.

**Example 2, Op 3 Cold Foundry.** The VENT LINING (detail 0.45) is near sentinels at (960,260) and (1320,820), tether 190 m. Furnace glow saturates light, so band only changes haze, noise and cost. MIDDLE at 100 m is heard at 520 m, so a Disrupt is spent. DEEP from a spot over 175 m from both posts is not heard at all, for about 0.6% oxygen and two shifts. The choice is a Disrupt charge versus clock and oxygen.

## 2. Feature B: five bounded rule shifts

All are display or planning aids from the player's findings and last contacts. None touches damage, beam, lock, sight or hearing.

1. **LOOP CLOCK.** Unlock: a gait frame at quality 0.45+ (`loop` finding). Player sees "LOOP 38 s" and a ghost tick "TURN ~12 s" on the loop. Fair: dead reckoned at 25 m/s from the last time the player saw that Siren, greyed "STALE" after 25 s unseen or once it investigates the player's own noise; it never reads the live position. Ops 0 to 2 patrollers have no authored `patrol_points`, so some loops must be authored. Seam: pure function over `photo.findings` and `contacts`, drawn after `_draw_findings`.
2. **KNOWN LANE.** Unlock: a `route` finding (op 0 lee channel, op 3 load lane). A 45 m strip counts as charted clear, so planned courses along it are not capped by unknown-terrain speed. Fair: the player photographed that water. Seam: photo_marks and terrain_chart reveal (API to confirm).
3. **POST RETURN CLOCK.** Unlock: a sentinel `post` finding. When the player sees that sentinel outside its tether, its post shows "BACK ~9 s" (distance / 25 or 48 m/s), stale once out of view. Sentinels hold posts and do not patrol, so this is the honest "sentinel gap". Same function as 1.
4. **WINDOW CHECK.** Unlock: a `cycle` finding (hatches, 7 s of 30). Arming shows "OPENS IN 12 s, you arrive in 9 s: WAIT" or "TOO LATE", from the player's own route. Shares the Priced Shots countdown.
5. **SIREN TELL (NEEDS PAT'S DECISION).** A studied sweeper or warden would add "BEAM IN ~4 s" to a heard windup. It touches Siren timing and the sweeper rebuild. Minimal alternative: nothing new, keep today's WINDUP label. Defer.

## 3. Interactions and risks

- **Priced Shots.** Rings and "if heard" ETAs must read `Photo.noise_radius`, not hardcoded 520 or 760, or they will be wrong outside MIDDLE. Both features edit `frame()`, so land PRICED1 first. Its window countdown and shift 4 are one readout.
- **Sleeve loop.** The brake on "hop, shoot, hop" is two exposed shifts plus 1.5 oxygen. Do not discount it.
- **Sweeper rebuild (handoff 009).** Sweepers use proximity, sight, throttle noise and pings, and some sit in band 2. DEEP must never be a safe room. Re-read its band rules after it lands and retest ops with sweepers. The 250 m sleeve pulse and 130 m shift noise are real triggers.
- **Drones.** Lamp 0.12 means DEEP drone shots need flash (2 charges), which is loud. Acceptable.
- **Balance.** SHALLOW needs unlit subjects to matter. Op 1 transponders (glow 0.3) are the first candidate.

## 4. Module layout

- `game/src/photo_depth/`: `band_table.gd` (all numbers), `band_photo.gd` (`mods`, `can_shoot`, `noise_scale`, `deep_cost`), `band_hint.gd`, tests beside. Seams: one call atop `Photo.frame`, one in `noise_radius`, the six checks become `can_shoot`, one line in `Depth.advance`.
- `game/src/photo_rules/`: `rule_table.gd` (25 and 48 m/s, stale 25 s, strip 45 m), `loop_clock.gd`, `post_clock.gd`, `known_lane.gd`, `window_check.gd`, tests beside. Seams: one draw call in `ocean_view.gd`, one line in the camera hint.
- Saves: each shot gains an optional `band` (0 to 2, default 1), added tolerantly to `Photo.valid`. Clocks are computed when drawn, never saved. Removing either folder leaves saves valid. Setting the table to all ones and `can_shoot` to band 1 restores today's game.

## 5. Build order and questions

**One milestone:** (1) PRICED1 merges; (2) `photo_depth` and tests, then play ops 0 and 3 in each band; (3) `photo_rules` shifts 1, 3, 4, 2 with two authored loops; (4) tune the table; (5) one cold playtest.

**Must not be built:** shift 5; any change to Siren sight, hearing, lock or beam; a core photo that requires a non-middle band; changes to depth, pressure or sleeve rules; live tracking; new story text.

**Questions for Pat:**
1. Is the DEEP oxygen charge (0.075/s) right? Recommend yes.
2. NEEDS PAT'S DECISION: our own shutter ring changing by band (x1.3 shallow, x0.8 deep). It is our noise, not Siren hearing, but it touches detection. Recommend yes. Fallback: 520 m in all bands.
3. Study Sirens from another band? Recommend no.
4. Author two patrol loops on ops 1 and 2? Recommend yes.
5. Defer SIREN TELL past the sweeper rebuild? Recommend yes.
