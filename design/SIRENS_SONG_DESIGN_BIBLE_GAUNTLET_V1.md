# SIREN'S SONG
## Design Bible & Gauntlet Creative Authority
Version 1.0 · 18 October 2026

## 1. Purpose and source authority
This document translates the original *Deep Contact / Siren's Song* conversation, recovered specifications, playtest findings, existing builds, and October 2026 design decisions into a production-oriented creative brief. Its purpose is to preserve the game's identity while giving development agents substantial freedom to invent and execute.

**Authority hierarchy:** Pat's latest explicit decisions → this bible as amended → earlier explicit Pat decisions → ratified specifications → playtest evidence → historical assistant proposals → prototype implementation → fresh proposals. A working implementation establishes what was built; it does not automatically establish what the finished game should be.

**Provenance vocabulary:** `PAT` original idea or explicit decision; `TEST` Pat's direct playtest feedback; `SPEC` historically accepted functional spec; `CLAUDE` historical assistant proposal; `OCT` current October 2026 direction; `OPEN` authorized creative territory; `PROPOSED` this document's synthesis. The source map in §12 points to exact transcript turns.

## 2. Creative identity
*Siren's Song* is a single-player 2D tactical submarine stealth game for Android. The player is the lone pilot of an experimental American stealth submarine, **USS Quietus**, sent to investigate an alien underwater fabrication complex guarded by technologically superior entities called **Sirens**. The player operates a vulnerable submarine and coordinates torpedo-launched remote drones through imperfect sonar, acoustic intelligence, and intermittent visual feeds. The ocean is physically heavy; movement creates noise; perception creates exposure. The player succeeds through planning, reconnaissance, timing, distraction, and improvisation against overwhelming technological asymmetry. The production game will have multiple missions, progression, and a distinctive visual and sonic identity. `PAT`, `SPEC`, `OCT`.

**Player fantasy:** Be an ingenious but fragile human pilot confronting something immensely more capable, and return with knowledge that required real risk to obtain.

**Experience:** Unease, curiosity, methodical preparation, precarious confidence, disruption, adaptation, and earned extraction or discovery. The player should fear what remains unknown, while having enough consistent information to make meaningful choices. `PROPOSED` emotional articulation grounded in `TEST`.

## 3. Influences and what they contribute
| Influence | Provenance | Transferable quality |
|---|---|---|
| *Iron Lung* | `PAT` | Vulnerable submarine, limited visibility, photography, claustrophobic dread |
| *Duskers* | `PAT` | Remote drones, indirect reconnaissance, expendable equipment, information scarcity |
| *Door Kickers* | `OCT` | Route planning, tactical pause, coordinated orders during real-time execution |
| *Frozen Synapse* | `OCT` | Anticipatory planning and simultaneous consequences; fixed execution windows were tested and tactical pause preferred |
| *Alien: Isolation* | `CLAUDE` | Learnable, superior threat as design precedent |
| *Papers, Please* | `CLAUDE` | Evidence interpretation and consequential judgment; an optional historical idea to revisit |
| Underwater UAP / fabrication-unit folklore | `PAT` inspiration | An uncanny oceanic installation, human uncertainty, technological and institutional mystery |

The original inspiration screenshot is `sirens_song_provenance.zip/screenshots/16402.jpg`. It is an imaginative source, rather than evidence of an actual alien base. References guide qualities and mechanics; the resulting setting, systems, art, and narrative should express *Siren's Song*'s own identity.

## 4. Load-bearing gameplay principles
**Perceiving is being perceived.** Passive sonar is safe but limited; active sonar, recon, drones, and cameras offer information at a cost in exposure, resources, position, or time. `SPEC`.

**Moving is being heard.** Speed and propulsion create acoustic signatures. Silent running creates a tradeoff between concealment and maneuverability. `SPEC`, `TEST`.

**The ocean has inertia.** The submarine has limited turn rate, acceleration, momentum, and interactions with currents and obstacles. Player feedback rejected instant, weightless movement. `TEST`.

**Cover works both ways.** Terrain blocks line-of-sight and sonar. Visible occlusion shadows are an essential feedback discovery: logically correct hidden information felt broken until the player could see the shadows. `TEST`.

**Threats are superior but legible.** Sirens investigate, search, respond to sound and exposure, and can be evaded or disrupted. The original idea allowed limited disorientation or damage, while the accepted prototype emphasized nonlethal tools and an overwhelming alien response to aggression. Keep technological asymmetry central; proposals to broaden interference or limited damage are welcome when they preserve it. `PAT`, `SPEC`, `OPEN`.

**One pilot has finite attention.** When operating drones, the pilot is occupied away from direct submarine control. The submarine continues following its existing orders. This is a deliberate tactical risk, not a UI inconvenience. `OCT`.

**Pause grants thought, not omniscience.** Unlimited tactical pause is the selected foundation. The simulation is continuous when running, and plans encounter inertia, unknown contacts, delayed actions, and changing conditions. `OCT`.

## 5. Submarine and tactical commands
The submarine is commanded through routes and orders rather than twitch steering. Multiple waypoints are a confirmed improvement. Assisted navigation should competently execute orders within physical and known-sensor limits; conditional commands let the pilot specify behaviors such as waiting, going silent, or reacting to detected contacts. `OCT`.

**Essential playtest lesson:** A route-append state persisted when the player returned from drone control to make an emergency escape. The attempted escape was appended instead of replacing the route; the submarine slowed at intermediate waypoints and was vaporized. Separate *pass-through* and *stop* waypoints. Make route append, replace, and emergency override obvious and dependable. Consequences should follow decisions and physical constraints, not hidden input state. `TEST` (October drone-command experiment).

**Creative latitude:** Agents may invent touch-first path drawing, contextual command palettes, waypoint conditions, speed intentions, emergency actions, autopilot behaviors, warning systems, station transitions, and accessibility affordances. They should test real Android usability. Whether station-switching has an in-game time cost is `OPEN`.

## 6. Drones and reconnaissance
Drones extend vision and reach into hostile water. Historically they were limited, expendable, torpedo-launched units for scouting, photographing targets, and possible distraction. The original prototype evolved from single-use camera-like drones to retaskable units; October experiments established the desire for independently commanded simultaneous drones. `PAT`, `SPEC`, `OCT`.

**Design requirement:** Drones must enable tactical decisions beyond merely acting as vulnerable cameras. The player can coordinate their activity with submarine navigation. Losses should matter. The historical sub-mounted fallback camera ensured that losing drones did not automatically make a mission impossible. `PAT`, `SPEC`.

**Authorized inventions:** Drone roles and types, communications, sensor packages, battery/endurance, autonomy, conditional orders, recovery and repair, progression, decoy mechanics, special mission tools, and tradeoffs between direct operation and delegated behavior. `OPEN`. Build for the one-pilot premise and limited information.

## 7. Sirens, equipment, and stealth
The original enemy roster included Patroller, Sentinel, and Hunter, each with different behavior. These are starting vocabulary, not a required final roster. Sirens can investigate sonar pings, engine noise, decoys, and drone activity, retain last-known positions, and react to rising alert. `SPEC`.

Historical equipment includes active sonar, recon-plane call-ins, EMP area stun, a single-target knockdown torpedo using a snare and downward thrust, decoys, and proposed jamming. Preserve recon's strategic value: Pat explicitly rejected removing it because its wide reveal was brief and the visible map was limited. `PAT`, `SPEC`.

The accepted prototype's kill rule required an active, unstunned Siren with line-of-sight before vaporization; cover and disruption could interrupt the kill. The later Hunt proposal added escalation stages and survivable hull grazing, which were implemented in v7 without a documented completed post-v7 balance playtest. `SPEC`, `CLAUDE`, implementation evidence. Agents may redesign thresholds, pacing, and enemy ecology while preserving readable danger and recoverable mistakes.

## 8. Campaign and progression — creative expansion
The four-photo alien-factory mission is a validated **prototype scenario**. The finished game should offer multiple missions, evolving objectives, progression, meaningful differences between environments, a rising dramatic arc, and a satisfying conclusion or campaign resolution. `OCT`.

**Agents are expressly empowered to invent:** Mission structures, reconnaissance tasks, anomalies, exploration, infiltration and extraction variants, environmental hazards, alien installations, human command intrigue, drone/equipment progression, persistent consequences, encounter generation, narrative fragments, endings, and replay systems. `OPEN`.

Each addition should deepen at least one signature pressure: imperfect information, acoustic exposure, divided attention, physical navigation, resource scarcity, or asymmetry against the alien presence. A new mechanic should have a reason to exist in *this* game.

The earliest *Deep Contact* concept featured classification of ambiguous sonar returns. That was a `CLAUDE` proposal rather than a later ratified main loop. Agents may explore evidence interpretation as a mission type if it adds meaningful decisions.

## 9. Visual and audio design
**Production direction:** Begin with 2D Android. Pixel-art top-down *Iron Lung* was Pat's original imagined form; the current prototype uses luminous sonar geometry. Explore both histories in the visual language. Full 3D was set aside for the present budget. `PAT`, `OCT`.

The visual exploration handoff proposes three complementary registers: **Abyssal Phosphor** (legible tactical sonar), **Cold War Ghost Signal** (human experimental-sub instrumentation), and **Bioluminescent Monolith** (strange alien structures and camera revelations). These are creative starting points. Agents may discover a stronger cohesive direction through actual image generation and rendered builds. `PROPOSED`.

**Audio is functional:** Engine and throttle sound, sonar pings and returns, muffled Siren cues, deep pressure and hull creaks, alerts, drone sounds, camera capture, disruption effects, and silence. Sound can provide actionable information beyond what is visible. `SPEC`.

**Procedural assets welcome:** Seafloor patterns, sonar effects, distortion, currents, particles, architecture, props, shaders, and sound. Mix generated systems with authored assets where effective. Favor memorable composition, clear gameplay readability, atmosphere, and reliable mobile performance over sheer asset quantity.

## 10. Gauntlet autonomy charter
**Creative constitution:** Preserve the lone human pilot, vulnerable submarine and drone command, alien technological asymmetry, imperfect perception, acoustic stealth, tactical planning, and investigation-driven identity. Treat these as identity-level constraints subject to Pat's explicit revision.

**Autonomous agent territory:** Choose engine and architecture; implement gameplay; design levels, missions, enemies, equipment, progression, UI, audio, and art; research and reuse maintained tools; generate assets; test; critique; iterate; refactor; and ship playable Android milestones. Agents may replace prototype implementations when doing so serves the game better.

**Bring to Pat for decision:** A change to the core player fantasy, shift away from 2D/tactical pause as the primary mode, conventional combat replacing investigative stealth, major incompatible narrative directions, major cost commitments, or an identity-level creative fork. Routine design and implementation decisions belong to the agents.

**Provisional agent roles:** Codex as lead builder, Claude Code for creative exploration and external review, Astra selectively for difficult visual/technical problems. Roles are empirical and may be reassigned based on results. `OCT`.

**Gauntlet loop:** Give the lead the bible, source archive, repository, and reference assets. Let it decompose work; build a real production game; run automated tests and capture screenshots/gameplay; have independent critics inspect actual output; fix consequential issues; integrate and verify Android builds; repeat while quality improves within the usage budget. Criticism should distinguish factual defects, aesthetic judgments, speculative preferences, and departures from the game's identity.

**Milestone evidence:** APK, screenshots or recordings, test results, what changed, what remains weak, and any actual decision Pat must make. Maintain a concise phone-readable progress workbench in the repository. Avoid requiring Pat to relay every small test result.

**Budget discipline:** Prefer automated checks, proven libraries, meaningful review milestones, and sequential agents when cheaper. Use higher-cost reasoning where it materially improves results. Keep a runnable baseline and version-controlled alternatives.

## 11. Success criteria
A successful *Siren's Song* is a coherent, multi-mission Android game with a distinctive look and sound, satisfying tactical planning, readable stealth rules, meaningful drone coordination, interesting progression, and a campaign that reaches a conclusion.

Players should be able to explain what their plan was, why it failed or succeeded, what information they lacked, and what they would try differently. Visual polish should enhance the experience of uncertainty and discovery. The player's decisions should matter more than interface confusion. Alien superiority should remain palpable even when the player outsmarts an encounter.

## 12. Provenance map and source package
**Primary archive:** `sirens_song_provenance.zip`, including `CHAT_TRANSCRIPT.md`, `PROVENANCE_README.md`, original screenshot, recovered v0.1/v0.2 specs, and prototype lineage. The README documents verbatim text, replaced code dumps, and archive limitations.

**Current handoff:** `sirens_song_handoff.zip` with functional v0.3 spec, dev notes, pressure proposal, v6 anchor and v7 playable HTML. **Additional October evidence:** tactical pause and drone-command experiments and Pat's playtest feedback in the planning conversation.

**Key transcript anchors:**
- Turns 0–9: underwater UAP/fabrication-unit inspiration and early *Deep Contact* ideas.
- Turns 12–18: genre references; Pat's pixel-art top-down *Iron Lung* + *Duskers*-lite vision at turn 18.
- Turns 20–31: submarine, drones, recon, limited combat, photo objective, functional spec and fallback-camera decisions.
- Turns 34–44: movement, obstacles, suspicion, ping investigation, sonar occlusion, and playtest validation.
- Turns 48–65: visual improvements, EMP/kill rule, speed/noise feedback, drone/decoy controls, and interface strain.
- Turns 71–105: enemy patrol, pause-on-log, bug audits, recon retention, drone redesign and retasking.
- Turns 107–111: flat/uneven difficulty, request for stronger game-design judgment, and preference against frantic pacing.
- Turns 114–127: interface repairs and provenance/handoff packaging.

**Amendment convention:** Record every identity-level decision with date, source, what changed, and why. Agents may keep implementation decisions in normal repo logs. When history conflicts, preserve provenance and ask only where the conflict affects the creative target.
