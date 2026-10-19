# v7 → Godot mechanics reconciliation ledger · 2026-10-19
Status: actionable inventory grounded in playable `reference/original-prototype/sirens_song_prototype_v7.html`, historical `archive/prototypes/` and current Godot code. Historical `docs/reviews/2026-10-19-original-prototype-mechanics-audit.md` is useful but source-revision-specific, not current status authority. Details and future disposition governed by `docs/CURRENT_GAME_SPEC.md`.

| Feature | v7 evidence | Current Godot interpretation | Disposition |
| --- | --- | --- | --- |
| Knockdown torpedo | Functional instant target pin/selection, two charges, ~150 original-scale range, 8s stun, suspicion/Hunt costs, visual/audio effect | Absent; EMP radial 340 world units/12s is different | **Restore/adapt under newer explicit user direction:** physical Quietus-launched, audible steering projectile; LOS launch, travel/terrain misses, impact cable snare with2D sink/fade/recovery; preserve flight saves and translate balance by play |
| Speed-based acoustic signature | Continuous speed-squared hearing/footprint; silent behavior distinct | Mostly velocity threshold at 50 and 430 hearing; silent/cruise visual radii 180/290 | **Adapt** continuous acoustic field and truthful feedback |
| Amber noise/range footprint | Live radius and planning guides | Own noise events/indicators, missing proportional propulsion ring | **Restore/adapt** |
| Acoustic around terrain | Earlier action sound cover attenuation; current Godot 0.36 blanket obstruction factor, direct velocity hearing | Geometric multi-path around cover not present | **New approved direction:** seeded ambiguity tied to acoustic paths |
| Drone targeting | v7 alert-sensitive close-range destruction distinctions | Common 4s beam lock detects drones and sub; drones die immediately when beamed | **Research + differentiate** without arbitrary drone nerf |
| Thermal cover | Cold band reduces detection | Absent | **Adapt** as spatial stealth affordance |
| Currents | Implemented current drift/forces | Absent | **Adapt**, preserving Godot route/collision honesty |
| Global Hunt and action pressure | Discovery-dependent pressure floor, action spikes, decay, sound modulation | Local suspicion and authored events instead | **Evaluate for integrative pressure**, decide through play |
| Photo grading | Proximity and drone versus sub quality grades, final A/B/C | Exposure/retained illustrated evidence without grade | **Polish candidate** after core gains |
| Photo imagery | Live prototype graphical feedback | Godot live optical panel and authored evidence illustrations | **Accept placeholder**; real captured viewpoint later |
| Logs/story discoveries | Triggered environmental narrative interactions | Campaign records and gallery, not same exploratory cadence | **Compare and enrich** story discovery later |
| Enemy archetypes | Patroller, sentinel tether, hunter | Current Godot now has patroller/sentinel/hunter roles | **Retained/adapted** |
| Combat | Beam plus targetable knockdown counterplay | Beam and EMP/decoy only | **Restore knockdown**, defer broader enemy arsenal |
| Navigation/waypoints | Basic autopilot and planning cues | Advanced Godot pathing with REPLACE/QUEUE and PASS/STOP, but no per-segment speed/edit/undo | **Add** per-segment programming; preserve Godot improvements |
| Campaign/progression | One playable prototype scenario | Six playable authored chapters with evidence, archival save, drones, advanced control | **Expand quality and variety**, not historical scope cap |
| Save management | Prototype state | Single user://quietus.save + recovery backup | **Keep for now**, profile/export milestone later |

All unimplemented rows remain visible until one of: verified integrated, explicitly superseded with gameplay-based rationale, or prioritized for later. Source parity is a means to preserve the intended game, not a mandate to clone historical UI, dimensions, balance, or 1-level structure. At each substantial cycle, compare actual play and select the highest-value remaining player-facing advancement; never mark the Gauntlet finished.
