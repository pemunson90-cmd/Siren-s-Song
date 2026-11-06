# Siren's Song — Genre and Monetization Research

*Authored by Keel (Cowork). 2026-06-05. Inputs: SIRENS_SONG_SPEC.md v0.2, 25+ web sources cited inline. Treat numbers as orders of magnitude unless otherwise noted; sales data in this domain goes stale within months.*

---

## Section 1 — Genre identification and landscape

The spec describes a top-down 2D stealth game in which the player pilots a slow zero-kill submarine through an alien deep-sea facility, photographs objectives, and exfiltrates. Detection is a 0–100 suspicion scalar with four threshold states and a 4-second fairness valve. The enemies (Sirens) have no HP and cannot be killed; they instakill the player only when suspicion sustains at maximum past the valve. Drones are the primary safe camera; the sub-mounted fallback cam is deliberately dangerous because it forces close-range exposure. Tools (jam, EMP torpedo, knockdown torpedo) buy time at suspicion cost.

That description does not sit cleanly in any single existing genre bucket. It sits at the intersection of four. The accuracy of marketing copy and store-page tagging depends on naming that intersection correctly.

### Candidate 1 — Top-down 2D stealth

The closest mechanical kin in this bucket is **Mark of the Ninja** (Klei, 2012). Klei's design philosophy was to expose information that 3D stealth games normally hide — guard cones, sound radii as visible expanding circles, light/dark binary states — and built the game around the four-step loop *observe, plan, execute, react* ([Game Developer: Stealth in 2D — Design lessons from Mark of the Ninja](https://www.gamedeveloper.com/design/stealth-in-2d-design-lessons-from-i-mark-of-the-ninja-i-); [Wikipedia](https://en.wikipedia.org/wiki/Mark_of_the_Ninja)). Metacritic 90/100 on Xbox 360, 91/100 on PC. The "binary visibility" rule (lit = seen, dark = invisible) is structurally close to Siren's Song's "suspicion-state determines aggression" — Pat's game has more granularity (four states, not two) but the design principle is the same: collapse hidden state into something the player can reason about.

Where Siren's Song diverges: Mark of the Ninja's player can kill. The verbs are different. Siren's Song is non-lethal by invariant. Hotline Miami (2012, Dennaton) is the other obvious top-down reference, but it is a glass-cannon murder loop — both player and enemies die in one hit — and is mechanically opposite to Siren's Song's "neither side can kill" structure ([TechRadar retrospective](https://www.techradar.com/features/its-been-over-ten-years-but-indie-games-can-still-learn-a-lot-from-hotline-miami)). Useful as a tonal reference for tight top-down feel and as a counterexample for what Siren's Song deliberately is not.

**Intravenous** (2021) and the "stealth shooter" descendants of Hotline Miami exist on itch.io and Steam ([NeoGAF on Intravenous](https://www.neogaf.com/threads/intravenous-a-top-down-hotline-miami-esque-stealth-shooter-released-today.1614113/)). They are mechanically lethal, so they are tonal cousins, not direct kin.

### Candidate 2 — Submarine simulator

The submarine-sim genre splits two ways: hard sim (UBOAT, Cold Waters, Silent Service, Dangerous Waters, Wolfpack) and submarine-flavored horror (Iron Lung, Barotrauma, Still Wakes the Deep). Siren's Song is firmly the second branch, with one important divergence: it is **top-down**, not first-person interior. That alone removes it from 95% of submarine-game expectations.

**Cold Waters** (Killerfish, 2017) holds roughly 87% positive on Steam from ~4,200 reviews, with 100k–200k owners — a clean niche success ([SteamSpy](https://steamspy.com/app/541210); [Steambase](https://steambase.io/games/cold-waters/reviews)). It is real-time Cold War sub combat and shares almost nothing mechanical with Siren's Song. **UBOAT** (Deep Water Studio, full release 2024) sold close to 1 million copies after a five-year Early Access run, 84% positive on ~25k reviews ([UBOAT Steam page](https://store.steampowered.com/app/494840/UBOAT/); [PCGamesN](https://www.pcgamesn.com/uboat/steam-lowest-price)). Both prove the submarine-sim audience exists but expects WW2/Cold War realism, crew management, depth gauges, torpedo solutions. Siren's Song serves none of that. Using "submarine sim" in tagging would draw the wrong audience and produce refund-rate damage.

The horror branch is the right reference. **Iron Lung** (David Szymanski, 2022) is the most useful single anchor for Pat's project. It is a one-shift, single-objective, you-cannot-see-the-world-except-through-the-camera submarine horror game. The core insight — *the camera is the only way to see* and *every observation is a deliberate, costly act* — is the same insight Siren's Song's perception system implements with sonar instead of ultrasound ([Wikipedia](https://en.wikipedia.org/wiki/Iron_Lung_(video_game)); [Bloody Disgusting via aggregated reviews](https://goldplatedgames.com/2022/04/20/review-iron-lung/)). Iron Lung sold under-the-radar at $5 from March 2022, then spiked by ~3x during the OceanGate Titan incident in June 2023 — a brutal reminder that submarine horror is small but real ([HuffPost](https://www.huffpost.com/entry/horror-based-submarine-game-titan-search_n_6495317fe4b095a2925c8483); [PC Gamer](https://www.pcgamer.com/iron-lung-dev-weirded-out-by-their-game-being-linked-to-the-titanic-sub-story-and-sales-spiking-this-feels-so-wrong/)). A movie adaptation followed.

**Barotrauma** (Undertow/FakeFish, full release 2023) is 95% positive on ~28k reviews with estimated ~$39M lifetime revenue — but it is multiplayer crew co-op, not single-player, and its 2D side-view is closer to FTL than Siren's Song's top-down ([Barotrauma Steam page](https://store.steampowered.com/app/602960/Barotrauma/); [Gamalytic](https://gamalytic.com/game/602960)). Reference for "2D submarine niche has real revenue when execution is strong," counterexample for the rest.

### Candidate 3 — Asymmetric-information / hide-and-seek stealth

**Hunt: Showdown** (Crytek, 2018) is the modern gold standard for sound-as-information. The whole match is structured around audio readability: footsteps, gunshot direction, disturbed environmental triggers (crows, dogs, chains), and HRTF-based 3D positioning via Crytek's CrySpatial system ([Hunt: Showdown audio dev insight](https://www.huntshowdown.com/news/dev-insight-a-deep-dive-into-3d-audio-in-hunt); [PC Gamer on Hunt's sound design](https://www.pcgamer.com/lets-hear-it-for-hunt-showdowns-incredible-sound-design/)). Hunt is multiplayer PvPvE, but the underlying design principle — *every observation makes you observable, and the game lives in that tension* — is what Pat means by "perceiving is being perceived." The clearest single-line gameplay frame in Siren's Song is, in fact, Hunt: Showdown's design ethos translated to single-player against unkillable AI.

**Splinter Cell** (Ubisoft) — the Chaos Theory (2005) AI overhaul introduced environment-aware NPCs and remembered events; the "last known position" mechanic Pat references in the spec was popularized later in **Conviction** (2010), where it becomes an explicit on-screen silhouette the AI investigates after losing line-of-sight ([Wikipedia: Chaos Theory](https://en.wikipedia.org/wiki/Tom_Clancy's_Splinter_Cell:_Chaos_Theory)). Pat's Hunter Siren ("dormant until Alert, then actively pursues last-known contact, fast") is structurally a Splinter Cell Conviction enemy translated to 2D top-down with sonar instead of vision cones. This is the clearest single-mechanic borrow in the whole design.

**Thief: The Dark Project** (Looking Glass, 1998) is the historical root — the first stealth game to use light/shadow and sound radius as first-class mechanics ([Game Developer: Building the original Thief's stealth system](https://www.gamedeveloper.com/design/building-the-original-i-thief-s-i-revolutionary-stealth-system); [Sneaky Bastards design analysis](http://sneakybastards.net/stealthreview/thief-design-analysis-part-1/)). The "Light Gem" visibility meter is a UI ancestor of Siren's Song's suspicion meter — diegetic visibility state rendered as a single legible scalar.

### Candidate 4 — Survival horror with environmental dread

**SOMA** (Frictional Games, 2015) is set in an underwater research facility; ~1M copies sold by 2021 ([Wikipedia](https://en.wikipedia.org/wiki/Soma_(video_game))). Mechanically distant (first-person, narrative-led, monster-evasion sections optional) but tonally relevant — the "alien-tech-meets-abandoned-facility" frame is the same family Siren's Song is fishing in. **Subnautica** (Unknown Worlds, 2018) sold 5M+ copies by January 2020, demonstrating that alien-ocean exploration has a real and large audience ([Wikipedia](https://en.wikipedia.org/wiki/Subnautica); [Game Studies academic article on Subnautica's dread design](https://gamestudies.org/2404/articles/evans)). Subnautica's "Leviathans" are unkillable apex predators that exist mainly to enforce zone fear — that is the single closest design-language overlap to the Sirens, even though Subnautica is first-person 3D and Siren's Song is top-down 2D.

### Candidate 5 — Tactical roguelike with limited information

**FTL: Faster Than Light** (Subset, 2012) and **Into the Breach** (Subset, 2018) are reference points for "perfect information / no RNG" tactical design — Into the Breach in particular ([Wikipedia: Into the Breach](https://en.wikipedia.org/wiki/Into_the_Breach); [Game Developer: How Subset designed Into the Breach](https://www.gamedeveloper.com/design/video-how-subset-games-designed-i-into-the-breach-i-)). FTL raised over $200k on Kickstarter against a $10k goal and funded Subset for a decade ([Wikipedia: FTL](https://en.wikipedia.org/wiki/FTL:_Faster_Than_Light)). Siren's Song is not a roguelike in v1 (single hand-authored site per the spec build leash), but the "every threat is legible, every death is the player's fault, no hidden detection" principle in Siren's Song §10 is identical to Subset's stated design philosophy.

### Candidate 6 — Asymmetric multiplayer hunter

Mentioned in the brief; ruling it out. Dead by Daylight, Hunt's PvP layer, and similar 1v4 designs would explode the single-file HTML constraint and contradict the spec's "one playable build, no multi-level, no networking" leash. Not viable in v1.

### Best-fit primary genre and secondary tags

**Primary genre tag:** *top-down stealth*. This is the most discoverable, accurate, and least misleading bucket. Use it on itch.io tags and Steam categories.

**Secondary positioning ("X-meets-Y"):** *Iron Lung meets Mark of the Ninja*, with *Hunt: Showdown's "perception costs" design ethos* and *Splinter Cell's last-known-position AI* underneath. That is a four-name elevator pitch; for store copy, "Mark of the Ninja underwater, with unkillable enemies" is the cleanest single-sentence positioning that signals genre while flagging the central novelty.

**What to avoid in tagging:** "submarine simulator" (wrong audience expectations — they want torpedo solutions and crew management), "horror" (the spec is stealth-tension, not jump-scare; over-promising horror invites the wrong reviewers), "roguelike" (v1 is not procedural), "survival" (oxygen is a bound, not a primary loop).

The single most-load-bearing precedent in the field is **Iron Lung** specifically — both as a positive reference (small, tightly-scoped, single-objective, one developer, charged $5, found an audience) and as a market test (proves submarine-horror niche exists and can move units in the low five figures with the right framing). Keep it close.

---

## Section 2 — Mechanics worth pulling (IP-safe)

Game mechanics are not copyrightable in the US — only specific expressions (character names, art, dialogue, code, distinctive visual designs) are protected. This is settled law (*Tetris Holding v. Xio Interactive*, *Atari v. Amusement World*). Pat can borrow any mechanic listed below as long as he writes his own code, designs his own visuals, and uses his own character/place names. None of the following requires licensing.

The selection bar for each candidate: does it serve at least one of the six invariants (no kill-path, suspicion-as-spine, perceiving-costs, tools-buy-time, fairness-valve, function-before-form) and fit in a single-file HTML build?

Caveat on the IP-safe framing. *Tetris Holding v. Xio Interactive* (D.N.J. 2012) is the load-bearing US precedent: the court held game mechanics and rules are not copyrightable, but specific expressive elements (visual design, layouts, distinctive arrangements) are ([Wikipedia: Tetris Holding v. Xio Interactive](https://en.wikipedia.org/wiki/Tetris_Holding,_LLC_v._Xio_Interactive,_Inc.); [Cole Schotz analysis](https://www.coleschotz.com/tetris-defeats-the-clones-in-copyright-infringement-battle/)). The line is: borrow the rule, write your own code, draw your own art, name your own characters. Don't replicate distinctive visual language (the Tetromino color scheme, the L-piece arrangement on a 10-wide field) verbatim. Every mechanic listed below is on the safe side of that line.

### 2.1 Sound propagation / audio readability as primary information

**Source:** Hunt: Showdown (Crytek), Thief: The Dark Project (Looking Glass), Splinter Cell series.

**The mechanic:** sound events emit a propagation radius. Player perceives those events through directional/spatial cues. NPCs investigate disturbed audio. Distance, occlusion, and surface type modulate detection. ([Hunt: Showdown audio dev insight](https://www.huntshowdown.com/news/dev-insight-a-deep-dive-into-3d-audio-in-hunt); [PlayStation Blog: Hunt sound design](https://blog.playstation.com/2020/02/17/listen-closely-insight-into-the-sound-design-of-hunt-showdown/); [Game Developer: Thief stealth system](https://www.gamedeveloper.com/design/building-the-original-i-thief-s-i-revolutionary-stealth-system))

**IP safety:** Pure mechanic. No expression-borrow.

**Fit with Siren's Song:** Direct. Sonar *is* audio propagation. The active ping already costs +25 suspicion because it announces the player; that is sound-readability translated to the suspicion spine. Extending this: drone movement could emit a low-level "noise" radius that Sirens in Curious state can detect at close range; collision with terrain could spike a small one-time suspicion event ("you scraped a wall — a Patroller heard it"). The cost stays in the suspicion currency the spec already defines.

**Implementation cost:** Low. The propagation math is already in the active-ping fade. Adding event-based one-shot emitters (drone moves, hull collisions, weapon fire) reuses the same data structures.

**Risk:** Don't let this proliferate. Two or three named audio-event types is plenty. The Thief mistake is fine-grained surface types (stone vs. carpet vs. metal) which adds depth at the cost of legibility — exactly what Pat's invariant #5 warns against.

**Recommended:** YES. This is the single most fundamental borrow available. The spec already implements ~70% of it; the remaining 30% is event audio from non-ping sources.

### 2.2 Last-known-position AI search

**Source:** Splinter Cell: Conviction (Ubisoft, 2010) made it iconic; Mark of the Ninja and Hitman use variants. ([Wikipedia: Splinter Cell: Chaos Theory](https://en.wikipedia.org/wiki/Tom_Clancy's_Splinter_Cell:_Chaos_Theory))

**The mechanic:** when an NPC loses LOS on the player, they investigate the last point they perceived the player at, not the player's current position. A visible silhouette/ghost marker (Conviction) or a search pattern around that point (most stealth games) communicates the AI's belief state.

**IP safety:** Pure mechanic. The visual representation (Conviction's white ghost figure) is the expression; the rule is not protected.

**Fit with Siren's Song:** Direct, and explicitly named in the spec's Hunter description. The Hunter "pursues last-known contact" — this is exactly the mechanic. Extending it: when a Siren enters Alert from a ping, mark the ping location as the search point. When the Siren reaches it without finding the player, they enter a small radial search pattern, then de-escalate. This converts the active-ping cost into a reasoning chain ("they're heading to where I pinged from — if I move now I'm safe") which is the legibility the spec demands.

**Implementation cost:** Low to medium. Storage is one Vec2 per Siren plus a state-machine branch.

**Recommended:** YES. Already partly implemented per the build leash. Worth polishing in the tuning pass.

### 2.3 "Show what enemies can see" UI affordances

**Source:** Mark of the Ninja's vision cones, audible-sound expanding circles, alert states rendered as enemy-head icons ([Game Developer: Stealth in 2D — Design lessons from Mark of the Ninja](https://www.gamedeveloper.com/design/stealth-in-2d-design-lessons-from-i-mark-of-the-ninja-i-)).

**The mechanic:** render the enemy's perceptual state on-screen so the player can plan against it instead of guessing.

**IP safety:** Pure mechanic. Vision cones predate Mark of the Ninja by decades.

**Fit with Siren's Song:** Strong. Pat's spec calls out detection legibility as the single most important tuning dial. Rendering each Siren's detection radius (or its current behavioral state via a halo color: green/yellow/red mapped to Curious/Alert/Hostile) makes every death traceable. Klei went further and showed sound circles propagating in real time; Pat could show ping waves expanding and fading, with Sirens in range visually reacting.

**Implementation cost:** Low. Pure render layer.

**Risk:** This is Form, not Function. Invariant #6 says no aesthetic work until systems tune out. The *data* should be in the model now (each Siren exposes detection_radius and current_state); the *rendering* is a debug overlay during dev that becomes the production UI later.

**Recommended:** YES, as debug overlay now, production UI in the form pass.

### 2.4 Iron Lung-style narrative compression

**Source:** Iron Lung (Szymanski, 2022). One submersible, one objective (photograph 10 coordinates), one shift, no respawn, runtime ~45 minutes, $5 price point ([Wikipedia: Iron Lung](https://en.wikipedia.org/wiki/Iron_Lung_(video_game))).

**The mechanic:** the entire game is a single self-contained shift with a stated objective list, no persistent meta-progression, no overworld, no menus beyond start/restart. Story emerges from environmental fragments and the briefing.

**IP safety:** Pure structural pattern.

**Fit with Siren's Song:** Exact match. Pat's spec §11 already commits to one hand-authored site, photograph N objectives, extract. Iron Lung is the proof-of-market that this exact shape sells.

**Implementation cost:** Zero — this is the existing architecture.

**Recommended:** Already in. The lesson is that Pat should resist *adding* meta-progression / multiple shifts / unlocks in v1, even when it feels like the obvious next step. Iron Lung's small scope is what made it shippable for one developer, marketable as a $5 indie, and viral when the OceanGate story hit. Siren's Song should look like a deliberate one-shift game in marketing, not a stripped-down RPG.

### 2.5 Mission types that fit the suspicion spine (post-v1)

The spec ships one mission type: recon (photograph + extract). Mission templates that reuse the suspicion engine with different objective shapes are content additions, not architecture changes:

- **Sabotage** — plant device at the power core, extract before detection. Planting spikes suspicion +30, forcing a hot return leg. The cleanest second mission because it stress-tests the suspicion engine in the opposite direction (force a high-suspicion act mid-mission and survive).
- **Extraction** — drone-tow a downed beacon home. Forces drone-management trade-offs (the tow drone can't also photograph).
- **Witness** — civilian shipping passes overhead; you must avoid detection by *both* Sirens and the surface ship. Second detection axis. Save for v3+.
- **Escort** — surface a returning research drone through escalating Siren presence.

All are pure structural patterns (IP-safe; mission verbs are unprotectable). **Recommended:** sabotage as the second mission, the rest deferred. Each adds content cost, not engine cost.

### 2.6 Loadouts, environmental hazards, proc-gen, meta-progression (deferred or rejected)

Compressed because they're all either post-v1 or out-of-scope:

- **Loadouts / multiple sub classes** (FTL Kestrel-A/-B, Hunt's hunter variants). Plausible v2 add for replayability; conflicts with v1's "one playable build."
- **Thermocline / environmental hazards** (Cold Waters models thermoclines as sonar layers; Subnautica uses thermal vents). Recommended even in v1 if time allows — a thermocline that halves ping range below it is a near-free positional lever on the perception system. One additional terrain-layer type, low implementation cost.
- **Procedural maps** (FTL, Spelunky). Direct conflict with spec §11 ("ONE hand-authored site. No proc-gen.") and §10 ("no RNG ambush"). Reject for v1. Possible v2 if and only if Siren legibility is provably deterministic across generated layouts, which is hard.
- **Roguelike meta-progression** (FTL ship unlocks, Hades' mirror). Conflicts with the one-shift spec shape. Post-v1, lightest possible meta — "complete mission to unlock harder mission" — fits the spirit; anything heavier breaks the invariants.

### Top-three pulls explicit recommendation

1. **Hunt: Showdown / Thief-style audio-event readability** (§2.1). Cheapest and most spec-aligned. Extends the suspicion spine without inventing new currency.
2. **Splinter Cell-style last-known-position search with state-halo rendering** (§2.2 + §2.3). The Hunter Siren is already this; render its belief state and the game becomes a chess match. This is the single highest-leverage UX improvement available.
3. **Thermocline environmental layer** (§2.7). One terrain-type addition that creates positional strategy without adding new verbs. The "submarine genre marker" that signals to discoverability that this is not just *Mark of the Ninja in water*.

The fourth pull, if there's time: **sabotage as second mission type** (§2.5) to prove the suspicion engine generalizes beyond recon. That is the work that turns Siren's Song from "a prototype" into "a small commercial release."

---

## Section 3 — Aesthetic and IP risk assessment

### Title check: "Siren's Song"

The phrase "Siren's Song" is heavily used in gaming and adjacent media, but no exact-match game-title trademark surfaced in available searches. Findings:

- **Sker Ritual: Siren's Song** — a DLC pack for Sker Ritual (Wales Interactive). DLC names typically don't trademark-block standalone titles in the same class, but the phrase is now associated with a horror-adjacent game property. ([Sker Ritual: Siren's Song on Steam](https://store.steampowered.com/app/2323211/Sker_Ritual__Sirens_Song/))
- **Voiceless: A Siren's Song** — a Choice of Games interactive fiction WIP. Different genre, different platform, different exact title. Low overlap risk. ([Choice of Games forum](https://forum.choiceofgames.com/t/voiceless-a-sirens-song-wip-updated-4-14-2025/142710))
- **Siren's Song Games** — Meghan Cross's small tabletop publisher (narrative RPGs). Class 41 (entertainment services) overlap is plausible if she ever filed; results don't confirm she has. ([Indie Press Revolution](https://www.indiepressrevolution.com/xcart/Sirens-Song-Games/))
- USPTO does not return cleanly via WebSearch; the legacy TESS interface was retired in 2023 and replaced by a cloud-based search at [tmsearch.uspto.gov](https://tmsearch.uspto.gov/). Web search cannot directly query it ([USPTO: retiring TESS](https://www.uspto.gov/subscription-center/2023/retiring-tess-what-know-about-new-trademark-search-system)).

**Recommendation:** Before any commercial release, Pat (or his attorney) should run the actual USPTO search himself at [tmsearch.uspto.gov](https://tmsearch.uspto.gov/) for "Siren's Song" in classes **9** (downloadable software, including video games) and **41** (entertainment services, including game services). A common-law search (Google for "siren's song" game) should also surface anything not in USPTO. The Sker Ritual DLC is the highest-noise item that surfaced; it is not standalone game, but Wales Interactive holds the parent mark and may have objections if Siren's Song looked horror-adjacent enough to confuse.

**Title hedge alternatives**, ranked by distinctiveness:
1. **Deep Contact** — Pat's working title before v0.2. Clean, less crowded, signals the conspiracy-USO frame. The downside Pat already named (too plain, no hook) is real but recoverable with subtitle.
2. **The Quiet Depth** / **Silent Witness** / **Below Listening** — register-appropriate but generic.
3. **Lullaby** — short, distinctive, audio-thematic, almost certainly contested in some media class.
4. **Aphotic** (the scientific term for the lightless deep-ocean zone) — almost certainly available, signals the setting, has the "discoverable single word" property Iron Lung benefited from.

Pat's call. "Siren's Song" is probably fine for itch.io release; revisit before Steam if going commercial.

### "Sirens" as alien-guardian framing

The bigger IP risk is *Siren as a creature category*, not the title phrase. The word is unprotectable but specific design directions are:

- **Borderlands Sirens** are a copyrighted character class — six tattooed humans with phase-based powers, a sequence of named character heirs (Lilith, Maya, Amara, Vex) ([Borderlands Wiki: Siren](https://borderlands.fandom.com/wiki/Siren)). Avoid: humanoid female forms with elaborate tattoos, phase/teleport powers, anything in a yellow/purple Borderlands palette. The word itself is fine; the design language is not.
- **Subnautica Leviathans** are the closest functional analog to Pat's Sirens — apex unkillable predators that enforce zone fear ([Game Studies on Subnautica's blended design](https://gamestudies.org/2404/articles/evans)). Subnautica's Leviathans are specifically aquatic megafauna with distinct silhouettes (Reaper, Ghost, Sea Dragon). Pat's Sirens should not visually evoke those specific creatures. The *role* (unkillable zone-enforcer) is mechanic — not protectable. The *silhouette* is expression — protect against accidental reproduction.
- **SOMA's WAU** is a different category (AI-substrate intelligence) and not a meaningful collision risk ([Wikipedia: SOMA](https://en.wikipedia.org/wiki/Soma_(video_game))).
- **PS2's Siren** (Sony's survival horror) and its 2024 PS4/PS5 re-release ([TechTimes](https://www.techtimes.com/articles/307832/20241011/ps2s-siren-horror-game-set-drop-ps4-ps5-version-perfect-this-halloween-2024.htm)) uses "Siren" as the title singular. Sony likely has Class 9/41 protections on that mark for a horror game. Worth a separate USPTO check on plain "Siren" vs. "Siren's Song" possessive form — distinct phrases legally but consumer-confusion is the standard, not exact-match.
- Mythological Sirens (Homer's Odyssey) are public domain and any "Sirens lure with song" framing is unprotectable.

**Recommendation:** When Pat does the form pass, make the Sirens *not humanoid* and *not female-coded* — bioluminescent abyssal silhouettes, alien-engineered guardian drones, or fully alien biology. That sidesteps both Borderlands and Sony Siren design overlap. The mythological "song that lures sailors" framing is fine to reference in lore as long as it's translated into something else (low-frequency hull resonance, ultrasonic pulses, alien-tech standing waves). Avoid named characters, avoid recognizable Subnautica silhouettes.

### The "alien deep-sea factory" framing

The USO (Unidentified Submerged Object) conspiracy meme is folkloric/public-domain. The "underwater factory built by Them" frame appears in conspiracy media for decades — Pat is safe to use it.

The two adjacent properties to keep distance from:
- **Subnautica's Precursor / Architect ruins** — alien biotech, specific silhouettes, the "Aurora crashed into something ancient" framing.
- **SOMA's PATHOS-II** — abandoned underwater human facility going wrong, not alien.

Siren's Song's *alien* facility (not human) is more distinct from SOMA, and its *factory* (operational, guarded) is more distinct from Subnautica's *ancient ruins*. The framing is already on safer ground than Pat may have assumed.

**Net title recommendation:** "Siren's Song" is usable for itch.io release. Run the USPTO search before Steam. Sker Ritual DLC is the only notable noise. Don't make the Sirens humanoid or evoke Subnautica's Leviathans visually, and the genre overlap risk drops to ordinary indie levels.

---

## Section 4 — Monetization paths

The spec ships as a single ~100KB HTML file with desktop and mobile control parity. That artifact constrains and enables which paths are realistic. Each path below is assessed on five axes: setup effort, revenue model, realistic earnings band for a 1-developer no-marketing-budget release, risks, and whether it preserves the single-file shape.

### 4.1 itch.io — pay-what-you-want or fixed-price

Hours of setup: drop the HTML, write a description, set price, mark it as HTML5 project for in-browser play. itch.io's cut is configurable (10% default, 0% available). PWYW, fixed price, bundles, demo+premium gating all supported ([itch.io revenue calculator](https://generalistprogrammer.com/tools/itchio-revenue-calculator); [Generalist Programmer how-to](https://generalistprogrammer.com/tutorials/how-to-make-money-on-itchio-indie-game-guide)).

The brutal earnings reality: most itch.io games earn under $100 lifetime. The 2023 platform average was ~$1,200 per title, but the median is far lower — heavily hit-skewed ([itch community discussion](https://itch.io/t/1048532/how-much-money-is-earned-on-itchio)). With active marketing, $500–$5,000 lifetime is the realistic band for a well-executed niche game. Sustained $5k–$50k over a year or two is achievable but uncommon. Realistic year-1 base case for Pat: $100–$500. Anything beyond is upside.

Discovery on itch is weaker than Steam — "collections" are the wishlist substitute without automated demo→full notifications ([itch community thread](https://itch.io/t/1962450/how-about-something-like-steams-wishlist-option)). Traffic comes from external posts (Twitter, Reddit, Discord). Single-file fit is perfect. **Verdict: correct first move.** Cost-to-list is near zero; even base-case earnings validate the loop before any harder distribution work.

### 4.2 Steam — desktop release via Electron wrap

Days to weeks: Electron or NW.js wraps the HTML into a desktop binary; Codecks shipped a hit Steam HTML5 game via this path and Phaser's official guide covers it ([Phaser](https://phaser.io/news/2025/03/publishing-web-games-on-steam-with-electron); [Codecks](https://www.codecks.io/blog/2019/creating-a-hit-steam-game-in-html5/); [Gamedev.js tutorial](https://gamedevjs.com/tutorials/publishing-web-games-on-steam-with-electron/)). Then: $100 Steamworks fee, capsule art, description, ~30s trailer, build pipelines for Win/Mac/Linux, age-rating self-cert. Valve takes 30% (sliding down at higher revenue tiers — for Pat's scale, assume flat 30%).

Steam's distribution is brutally power-law. 2024: 18,324 releases, 75% earned <50 reviews ([gamedevreports / Steam in 2024](https://gamedevreports.substack.com/p/how-to-market-a-game-steam-in-2024)). Only ~3,000–4,000 games yearly reach 50–1,000 reviews. Zukowski's "Gold tier" benchmark: ~1,000 reviews ≈ $150k gross revenue, requiring 30k–50k launch wishlists. A 1-dev no-marketing release lands in the <50 reviews bucket, $200–$2,000 lifetime. Iron Lung pre-spike was modestly above this; the OceanGate spike and Markiplier film are not strategy.

Risks: Steam's marketing demand is its own job. Without an existing wishlist base, you go invisible 24 hours post-launch. Electron wrap adds ~100MB Chromium runtime to distribution but preserves the HTML source. **Verdict:** real but high-effort. Only worth it after itch.io proves the loop and Pat has a month for marketing prep.

### 4.3 Mobile — PWA wrap via Capacitor

A few hours to a few days for a Capacitor or PWABuilder wrap into iOS/Android binaries ([Capacitor PWA docs](https://capacitorjs.com/docs/web/progressive-web-apps); [Capgo: transform PWA](https://capgo.app/blog/transform-pwa-to-native-app-with-capacitor/)). Step 8 mobile control parity makes this small work. Then: Apple Developer Program ($99/yr ongoing), Google Play Console ($25 one-time), store listings, screenshots, age ratings.

The honest gap: I don't have solid 2024–25 median-earnings data for premium one-developer mobile games with no marketing. The historical pattern is that paid-upfront mobile is essentially dead for unknown indies — App Store and Play Store algorithms favor F2P with ads, and ad revenue at indie volume is nothing. Realistic band: $0–$200 year one. App Store review can reject wrapped PWAs as "low quality." Apple's $99/yr is real overhead if the game earns $0.

Single-file fit is perfect (Capacitor wraps the existing HTML). **Verdict:** defer until itch proves an audience. Only worth the $99/yr and 2 days of work if there's a list of people asking for mobile.

### 4.4 Patreon + Ko-fi (passive support layer)

**Patreon:** Hours to set up. Platform-wide creator average is ~$3,000/month but heavily skewed by top creators ([Sci-Tech Today: Patreon Stats 2025](https://www.sci-tech-today.com/stats/patreon-statistics-updated/)); the gaming slice supported 5,200 indie devs with $120M in 2023, ~$23k/year average ([Wayline: indie dev income](https://www.wayline.io/blog/realistically-how-much-does-an-indie-game-dev-make-per-year)). Realistic Pat band without an existing audience: $0–$50/month first six months. Patreon is a content-output commitment (devlogs, builds, posts) — a job inside the job. Worth a $0-tier "support if you want" link from itch.io; don't build the strategy around it.

**Ko-fi tip jar:** Hours to set up, zero ongoing commitment, one-time tips. Whatever organic tipping comes from itch readers — lunch money in the base case, low five-figure annual if the game catches. Free to add, no reason not to. Strictly additive.

### 4.5 Web Monetization API / Interledger

Coil sunset operations in 2023. The Web Monetization spec moved to a W3C Working Draft (March 2025) and Interledger maintains a browser extension and a Fynbos wallet provider ([Web Monetization spec](https://webmonetization.org/specification/); [WM August 2024 updates](https://community.interledger.org/interledger/web-monetization-august-2024-updates-2pn6); [WM Wrapped 2025](https://interledger.org/developers/blog/web-monetization-wrapped-2025/); [Chris Coyier on WM's trajectory](https://chriscoyier.net/2024/01/24/what-happened-with-the-web-monetization-api/)). The user-side install base is sub-1% of any browser audience. Pennies to single dollars for a game-shaped audience. **Skip.** Re-evaluate if browser-native adoption ever lands.

### 4.6 Demo + premium expansion model

Free demo (the current build) + paid expansion (more sites, more Siren types, more missions) is a common indie pattern. Conflicts with v1's "one hand-authored site, no proc-gen" leash — Pat would need to build v2 content first. The cleanest version: ship the current single-site game free as a public demo on itch; build a v2 with 3–5 sites and the §2.5 mission variants as a paid Steam/itch release. Roughly a year of work, but the strongest commercial trajectory available.

### 4.7 Bandcamp soundtrack sales

Bandcamp pays artists ~82% on average; 100% on Bandcamp Fridays ([Chartlex 2026](https://www.chartlex.com/blog/money/how-to-sell-music-on-bandcamp-2026)). Per a GDC talk, indie composers reported figures like $150 Bandcamp / $400 Steam OST / ~$0 streaming for a single album ([GDC Vault: OST profitability](https://gdcvault.com/play/1029183/Independent-Games-Summit-Get-Your); [Bandcamp Daily: indie game soundtracks](https://daily.bandcamp.com/features/interview-indie-game-soundtracks); [AV Club: Bandcamp as game soundtrack HQ](https://www.avclub.com/bandcamp-video-game-soundtracks)). The overall video game music market is growing ($1.3B in 2024 → projected $2.2B by 2032 per [Intel Market Research](https://www.intelmarketresearch.com/video-game-music-market-11671)) but indie game OST is sub-percent. Only relevant if Pat composes the soundtrack himself. Treat as side merchandise, not revenue.

### 4.8 Web game portals — Poki, CrazyGames, Newgrounds

**Setup effort:** Submit HTML build, integrate their SDK, agree to exclusivity terms.

**Revenue model:** Ad revenue share. Specifics are not public. CrazyGames offers a +50% revenue share bonus for 2-month launch exclusivity with their SDK. Y8 publishes the structure most clearly: 50% of page-ads without their SDK, 50% of in-game ads with SDK, with multiplayer/feature bonuses ([Hology: Navigating Web Gaming Platforms](https://hology.app/blog/web-gaming-1); [IndieGameBusiness: Web Gaming for Indie Developers](https://indiegamebusiness.com/web-gaming-for-indie-developers/); [GameDeveloper: The huge, hidden web game market](https://www.gamedeveloper.com/business/the-huge-hidden-web-game-market-no-one-talks-about-and-how-to-get-in-)).

**Realistic earnings:** First-game web titles can earn $500–$3,000/month on the major portals if accepted and promoted ([IndieGameBusiness](https://indiegamebusiness.com/web-gaming-for-indie-developers/)). Acceptance is curated — Poki and CrazyGames screen submissions for quality. This is more realistic monthly income than itch.io for a single dev, by a meaningful margin.

**Risks:** Portal acceptance is gated. Siren's Song's stealth-tension design is *not* the typical casual web-portal game — those favor short loops, low cognitive demand, hyper-replayability. Pat's design is closer to a 30-minute experience than a 3-minute snack. Realistic acceptance is uncertain.

**Single-file preservation:** Perfect.

**Verdict:** Worth submitting to Poki and CrazyGames as a screening test. Free to try. If accepted, the monthly ad-share income could exceed everything else combined.

### 4.9 Game jams as discovery

**Setup effort:** Free entry.

**Revenue model:** None directly. Discovery vector.

**Notable examples:** Friday Night Funkin' originated in a Ludum Dare submission ([Wikipedia: Ludum Dare](https://en.wikipedia.org/wiki/Ludum_Dare)). The GMTK Game Jam (mechanics-themed, annual) draws thousands of entries and significant YouTube coverage ([Outlook Respawn: Ultimate Game Jam Guide](https://respawn.outlookindia.com/gaming/gaming-guides/ultimate-game-jam-guide-join-learn-and-build-your-first-game)).

**Verdict:** Siren's Song doesn't fit a typical jam theme retroactively. But if Pat builds a stripped-down 48-hour-style "Siren's Song: prologue" version targeted at a future jam theme, the discovery upside is real. Skip for now.

### Monetization summary table

| Path | Effort | Year-1 base case | Year-1 upside | Single-file safe |
|---|---|---|---|---|
| itch.io PWYW | Hours | $100–$500 | $5k–$50k | Yes |
| Steam (Electron wrap) | Weeks | $200–$2,000 | $50k+ | Mostly |
| Mobile PWA (Capacitor) | Days | $0–$200 | $1k–$5k | Yes |
| Patreon | Hours | $0–$600/yr | $5k+/yr | Yes |
| Ko-fi tip jar | Hours | $0–$100 | $1k+ | Yes |
| Web Monetization API | Hours | $0–$10 | $50 | Yes |
| Demo + paid expansion | Months | $0 (v1 free) | $5k–$30k | Yes |
| Bandcamp OST | Days (if composed) | $0–$50 | $500+ | Yes |
| Web portals (Poki etc.) | Days | $0 (if rejected) | $6k–$36k/yr if accepted | Yes |
| Game jams | Days | $0 | Discovery | Yes |

The realistic recommended stack for Pat: **itch.io + Patreon link + Ko-fi link + Poki/CrazyGames submission**, ship the v1 free or PWYW, see what traction looks like over 3 months, then decide whether Steam is worth the prep effort. That stack is ~1 week of total work and preserves the single-file constraint.

---

## Section 5 — Survival check / hard truths

### The Iron Lung benchmark (because it matters)

The most useful single comparison Pat has access to is Iron Lung's actual numbers. Per a third-party Steam revenue estimator, Iron Lung has generated approximately **$2.18M gross / $643k net to developer** over its lifetime since March 2022 ([Steam Revenue Calculator: Iron Lung](https://steam-revenue-calculator.com/app/1846170/iron-lung)). That number is inflated by the OceanGate sales spike and a subsequent Markiplier-directed film adaptation that grossed $8.9M opening weekend ([Variety: Iron Lung box office](https://variety.com/2026/film/box-office/box-office-iron-lung-send-help-melania-1236644154/); [GameSpot on the film](https://www.gamespot.com/articles/markipliers-iron-lung-video-game-movie-already-made-back-11x-its-budget/1100-6538045/)). The pre-spike trajectory was steady but modest — probably $40k–$80k net in year one. That's a hit, by indie sub-genre standards. The very best realistic outcome for a tightly-scoped solo submarine-horror game is the Iron Lung trajectory: low five-figures year one, six figures lifetime if something catches.

What this means for Pat: a base-case successful Siren's Song release earns *less than Iron Lung's pre-spike year-one number*. The path to $100/month sustained income is real but narrow. The path to $10,000 lifetime is realistic with effort. The path to "this replaces day-job income" is closed unless Siren's Song catches a viral moment, which is not a strategy you can plan for.

### The submarine niche is small. Top-down stealth is bigger. Together: novel.

Cold Waters at 100k–200k owners with $20+ pricing is a meaningful niche success. UBOAT at ~1M sold is the high end. Both serve a specific buyer (the milsim/sub-sim fan) Siren's Song does not target. Mark of the Ninja sold strongly across multiple platforms but it's 13 years old and the 2D-stealth audience has fragmented into split followers of Klei, Hotline Miami derivatives, immersive sims, and roguelike adjacents. The submarine-horror niche specifically (Iron Lung, Still Wakes the Deep, Barotrauma's solo modes) is small but reliable — it shows up for atmosphere games at the $5–$15 price point.

What Siren's Song offers that none of these games does:

**Unique selling proposition #1 — the suspicion meter as continuous threat scalar in a stealth game.** Most stealth games are state-based: hidden / suspicious / alarmed. Splinter Cell uses discrete states with thresholds. Siren's Song's continuous-suspicion-with-decay-curve creates a tension graph the player can read in real time. The closest analog is **SpyParty** (Chris Hecker), where suspicion is the entire game ([gamesradar: revival of social stealth](https://www.gamesradar.com/inside-the-revival-of-social-stealth-games/)) — but SpyParty is multiplayer asymmetric and has been in development for over a decade. Pat owns the single-player, AI-driven, continuous-suspicion design space and that space is genuinely underused.

**Unique selling proposition #2 — zero-kill stealth with unkillable enemies.** Stealth games with non-violent options exist (Dishonored's low-chaos, Hitman's pacifist runs, Mark of the Ninja's New Game+) but every one of those games still gives the player a kill verb. Siren's Song removes the kill verb on both sides. That asymmetric design — both sides forbidden from killing except in one specific lore-justified instakill condition — is genuinely uncommon. Undertale's mercy system is the most-cited example of non-violent design, and that was a viral phenomenon. Pat's design is a different shape (mercy is the only option, not a player choice) but lives in the same uncommon design space.

**Unique selling proposition #3 — perceiving is being perceived as a literal mechanic.** Most stealth games make perception free for the player and costly for the AI. Siren's Song makes player perception *itself* costly. Hunt: Showdown got close to this with audio (your gunshot is your detection). Siren's Song takes it further: every form of sight has a price. That's the entire game in one sentence, and it's a clean elevator pitch.

These three USPs together are the differentiation. A Steam store description should lead with the third, support with the second, and explain with the first.

### The honest path to $100/month sustained

It looks like this:
1. Ship to itch.io as PWYW with a "minimum $0, suggested $3" pricing. Free path stays open for word-of-mouth; paid path captures the players who want to support.
2. Post the game to /r/IndieDev, /r/WebGames, /r/IncrementalGames, /r/SubmarineGames (small but engaged), and 1–2 Discord communities (Hunt: Showdown's strategy crowd, Iron Lung's horror crowd).
3. Submit to Poki and CrazyGames. Their accept/reject is the single biggest financial fork in this plan.
4. Cross-post the build to itch's HTML5 collections. itch.io has curators; getting featured there is a real possibility for a well-made stealth game.
5. Maintain a one-paragraph devlog every 2 weeks. Don't make it a job; make it a touchpoint.
6. **If Poki or CrazyGames takes it:** the $100/month threshold is plausible by month 4–6, based on the IndieGameBusiness reported range for first-game web titles ($500–$3,000/month). Plan to keep the game updated quarterly to maintain placement.
7. **If neither takes it:** itch.io + Patreon + Ko-fi will get to $10–$40/month with consistent effort, which is closer to honest indie reality than $100. Reaching $100 from itch.io alone requires either a viral moment or a paid Steam release later.

The failure mode: ship, post once to Twitter, get 5 upvotes, never touch it again. That is the path 75% of itch.io releases follow ([the 2024 Steam landscape numbers extend the pattern to Steam](https://shahriyarshahrabi.medium.com/the-2024-indie-game-landscape-why-luck-plays-a-major-role-in-success-on-steam-c6cbc1868c35)).

### The path to $10/month

Significantly easier. Ship to itch.io PWYW. Add Ko-fi tip link. Post on 3 communities once. Walk away. Realistic outcome: $0–$30/month average over 18 months for a well-made well-scoped game. The Iron Lung-style word-of-mouth tail keeps small revenue trickling for years if the game has a clean identity. That base case is achievable with maybe 20 hours of marketing-prep work after the game ships.

### Three concrete differentiators worth doubling down on

1. **The suspicion meter as the only HUD.** Render the meter as the most prominent screen element, larger than the hull or oxygen indicators (which are status, not threat). Stealth games with iconic central HUD elements — Thief's Light Gem, Mark of the Ninja's vision cones, Hitman's Instinct — got identity from a single readable element. Siren's Song's spec already has the suspicion meter as the spine; lean into it visually when the form pass arrives. This is the single image that should appear in every screenshot, store capsule, and gif clip.
2. **"You cannot kill anything. Nothing can kill you — until you give it a reason."** Use this as the elevator-pitch tagline. It captures the asymmetric design and the player-agency promise in one sentence. It also signals genre clearly enough that the wrong audience self-selects away.
3. **The drone-as-eyes architecture.** Most stealth games are first-person to the player character. Siren's Song has the player watching the player. That third-person-camera-as-tool framing is rare; Duskers built its entire identity on it ([Duskers Steam page](https://store.steampowered.com/app/254320/Duskers/) at 89% positive, 1,939 reviews). Don't hide it — lead screenshots with the drone-cam view, not the sub-cam view.

### If I were Pat

Step 9 in the build sequence should be a small polish pass on Siren detection-radius rendering (mechanic §2.3) and one audio-event pass on drone movement (mechanic §2.1) — that's the third USP made concrete. Step 10 is the form pass: clean pixel art for the sub, drones, three Siren silhouettes, the facility, and the HUD. Function-first is already done.

After that: itch.io release as PWYW with a "support the dev" suggested $3 price. Single tweet to whatever networks Pat is on. Cross-post to /r/WebGames and itch's HTML5 discovery feed. Submit to Poki and CrazyGames the same week. Add a Ko-fi tip link on the itch page.

Don't do Steam in 2026. Steam is the right move *after* itch and web-portal data tells Pat what the audience actually looks like. The $100 Steamworks fee plus the marketing-prep month is real overhead that's only worth it if there's an audience to point at it. Iron Lung went straight to Steam and worked, but Szymanski had a small existing audience from his prior horror games (*Dusk* connections, prior itch releases). Pat does not yet have that base. Build it first.

Don't build mobile native until someone asks for it. The PWA already runs on mobile browsers per Step 8. Mobile-native distribution adds $99/yr Apple Developer Program plus Google Play setup plus store-listing work for an addressable market that, for premium-priced indie mobile, is essentially zero.

The realistic 18-month commercial outcome: a game that exists, has a small but real player base in the low thousands, generates $20–$200/month in mixed itch + Patreon + Ko-fi income, and provides Pat with a portfolio piece and a public-facing case study for the suspicion-mechanic design space. The unrealistic but possible outcome: Poki or CrazyGames accepts it, the game finds a stealth-puzzle audience, and the monthly revenue clears $1,000 by month 9. The unlikely but not-impossible outcome: a streamer plays it, the suspicion mechanic becomes the talking point, and a Steam port becomes obviously worth the effort. The unrealistic outcome: this replaces HVAC income. Don't plan for that, but don't preempt-reject it either.

The single thing that determines which outcome happens is whether the suspicion meter feels good to read. Pat's spec already names this as the most-important tuning dial. Land it, and everything else follows.

---

## Sources

- [Bandcamp Daily: The Cottage Industry of Indie Game Soundtracks](https://daily.bandcamp.com/features/interview-indie-game-soundtracks)
- [AV Club: How Bandcamp became the "headquarters" for video game soundtracks](https://www.avclub.com/bandcamp-video-game-soundtracks)
- [Borderlands Wiki: Siren](https://borderlands.fandom.com/wiki/Siren)
- [Capacitor docs: Building Progressive Web Apps](https://capacitorjs.com/docs/web/progressive-web-apps)
- [Capgo: Transform Your PWA to a Native App with Capacitor](https://capgo.app/blog/transform-pwa-to-native-app-with-capacitor/)
- [Chartlex: How to Sell Music on Bandcamp in 2026](https://www.chartlex.com/blog/money/how-to-sell-music-on-bandcamp-2026)
- [Choice of Games forum: Voiceless: A Siren's Song WIP](https://forum.choiceofgames.com/t/voiceless-a-sirens-song-wip-updated-4-14-2025/142710)
- [Codecks: Ultimate list of all tools we used to create a hit HTML5 game on Steam](https://www.codecks.io/blog/2019/creating-a-hit-steam-game-in-html5/)
- [Cole Schotz: Tetris Defeats the Clones in Copyright Infringement Battle](https://www.coleschotz.com/tetris-defeats-the-clones-in-copyright-infringement-battle/)
- [Chris Coyier: What happened with the Web Monetization API?](https://chriscoyier.net/2024/01/24/what-happened-with-the-web-monetization-api/)
- [Duskers on Steam](https://store.steampowered.com/app/254320/Duskers/)
- [Game Developer: Building the original Thief's revolutionary stealth system](https://www.gamedeveloper.com/design/building-the-original-i-thief-s-i-revolutionary-stealth-system)
- [Game Developer: Stealth in 2D — Design lessons from Mark of the Ninja](https://www.gamedeveloper.com/design/stealth-in-2d-design-lessons-from-i-mark-of-the-ninja-i-)
- [Game Developer: The huge, hidden web game market](https://www.gamedeveloper.com/business/the-huge-hidden-web-game-market-no-one-talks-about-and-how-to-get-in-)
- [Game Developer: Video — How Subset Games designed Into the Breach](https://www.gamedeveloper.com/design/video-how-subset-games-designed-i-into-the-breach-i-)
- [Gamalytic: Barotrauma stats](https://gamalytic.com/game/602960)
- [Gamedev.js: Publishing web games on Steam with Electron](https://gamedevjs.com/tutorials/publishing-web-games-on-steam-with-electron/)
- [GameDevReports: How to Market a Game — Steam in 2024](https://gamedevreports.substack.com/p/how-to-market-a-game-steam-in-2024)
- [GameSpot: Iron Lung Movie Made Back 11x Its Budget](https://www.gamespot.com/articles/markipliers-iron-lung-video-game-movie-already-made-back-11x-its-budget/1100-6538045/)
- [Game Studies: Too Afraid to Go Deeper — Subnautica's blended design](https://gamestudies.org/2404/articles/evans)
- [GamesRadar: Inside the revival of social stealth games](https://www.gamesradar.com/inside-the-revival-of-social-stealth-games/)
- [Gold-Plated Games: Iron Lung review](https://goldplatedgames.com/2022/04/20/review-iron-lung/)
- [Generalist Programmer: How to Make Money on Itch.io](https://generalistprogrammer.com/tutorials/how-to-make-money-on-itchio-indie-game-guide)
- [Generalist Programmer: Itch.io Revenue Calculator](https://generalistprogrammer.com/tools/itchio-revenue-calculator)
- [Hology: Navigating Web Gaming Platforms for Indie Developers](https://hology.app/blog/web-gaming-1)
- [HuffPost: Horror Game 'Iron Lung' Sales Surged During Titan Search](https://www.huffpost.com/entry/horror-based-submarine-game-titan-search_n_6495317fe4b095a2925c8483)
- [Hunt: Showdown audio dev insight](https://www.huntshowdown.com/news/dev-insight-a-deep-dive-into-3d-audio-in-hunt)
- [Hunt: Showdown audio recap and Update 2.4](https://www.huntshowdown.com/news/dev-insight-audio-design-recap-what-s-new-in-update-24)
- [IndieGameBusiness: Web Gaming for Indie Developers](https://indiegamebusiness.com/web-gaming-for-indie-developers/)
- [Indie Press Revolution: Siren's Song Games](https://www.indiepressrevolution.com/xcart/Sirens-Song-Games/)
- [Intel Market Research: Video Game Music Market Outlook 2025–2032](https://www.intelmarketresearch.com/video-game-music-market-11671)
- [Interledger Community: Web Monetization August 2024 updates](https://community.interledger.org/interledger/web-monetization-august-2024-updates-2pn6)
- [Interledger Foundation: Web Monetization Wrapped 2025](https://interledger.org/developers/blog/web-monetization-wrapped-2025/)
- [itch.io community: How much money is earned on itch.io](https://itch.io/t/1048532/how-much-money-is-earned-on-itchio)
- [itch.io community: How about something like Steam's Wishlist Option?](https://itch.io/t/1962450/how-about-something-like-steams-wishlist-option)
- [Medium / Shahriar Shahrabi: The 2024 Indie Game Landscape](https://shahriyarshahrabi.medium.com/the-2024-indie-game-landscape-why-luck-plays-a-major-role-in-success-on-steam-c6cbc1868c35)
- [PC Gamer: Iron Lung dev weirded-out by Titanic sub sales spike](https://www.pcgamer.com/iron-lung-dev-weirded-out-by-their-game-being-linked-to-the-titanic-sub-story-and-sales-spiking-this-feels-so-wrong/)
- [PC Gamer: Let's hear it for Hunt: Showdown's incredible sound design](https://www.pcgamer.com/lets-hear-it-for-hunt-showdowns-incredible-sound-design/)
- [PCGamesN: UBOAT lowest Steam price](https://www.pcgamesn.com/uboat/steam-lowest-price)
- [Phaser: Publishing Web Games on Steam with Electron](https://phaser.io/news/2025/03/publishing-web-games-on-steam-with-electron)
- [PlayStation Blog: Listen Closely — Insight into the Sound Design of Hunt: Showdown](https://blog.playstation.com/2020/02/17/listen-closely-insight-into-the-sound-design-of-hunt-showdown/)
- [Outlook Respawn: Ultimate Game Jam Guide](https://respawn.outlookindia.com/gaming/gaming-guides/ultimate-game-jam-guide-join-learn-and-build-your-first-game)
- [Sci-Tech Today: Patreon Statistics 2025](https://www.sci-tech-today.com/stats/patreon-statistics-updated/)
- [Sker Ritual: Siren's Song DLC on Steam](https://store.steampowered.com/app/2323211/Sker_Ritual__Sirens_Song/)
- [Sneaky Bastards: Thief Design Analysis Part 1 — Light, Sound, and Stealth Systems](http://sneakybastards.net/stealthreview/thief-design-analysis-part-1/)
- [SteamSpy: Cold Waters](https://steamspy.com/app/541210)
- [Steam Revenue Calculator: Iron Lung](https://steam-revenue-calculator.com/app/1846170/iron-lung)
- [Steambase: Cold Waters reviews](https://steambase.io/games/cold-waters/reviews)
- [SubSim review: Cold Waters](https://www.subsim.com/subsim-review-cold-waters/)
- [TechRadar: Over 10 years later, Hotline Miami remains the indie games gold standard](https://www.techradar.com/features/its-been-over-ten-years-but-indie-games-can-still-learn-a-lot-from-hotline-miami)
- [TechTimes: PS2's Siren PS4/PS5 release Halloween 2024](https://www.techtimes.com/articles/307832/20241011/ps2s-siren-horror-game-set-drop-ps4-ps5-version-perfect-this-halloween-2024.htm)
- [UBOAT on Steam](https://store.steampowered.com/app/494840/UBOAT/)
- [USPTO: Retiring TESS — what to know about the new trademark search system](https://www.uspto.gov/subscription-center/2023/retiring-tess-what-know-about-new-trademark-search-system)
- [USPTO Trademark Search](https://tmsearch.uspto.gov/)
- [Variety: Iron Lung Box Office](https://variety.com/2026/film/box-office/box-office-iron-lung-send-help-melania-1236644154/)
- [Wayline: Realistically, How Much Does an Indie Game Dev Make Per Year](https://www.wayline.io/blog/realistically-how-much-does-an-indie-game-dev-make-per-year)
- [Web Monetization Specification (W3C Working Draft)](https://webmonetization.org/specification/)
- [Wikipedia: FTL: Faster Than Light](https://en.wikipedia.org/wiki/FTL:_Faster_Than_Light)
- [Wikipedia: Into the Breach](https://en.wikipedia.org/wiki/Into_the_Breach)
- [Wikipedia: Iron Lung (video game)](https://en.wikipedia.org/wiki/Iron_Lung_(video_game))
- [Wikipedia: Ludum Dare](https://en.wikipedia.org/wiki/Ludum_Dare)
- [Wikipedia: Mark of the Ninja](https://en.wikipedia.org/wiki/Mark_of_the_Ninja)
- [Wikipedia: SOMA](https://en.wikipedia.org/wiki/Soma_(video_game))
- [Wikipedia: Subnautica](https://en.wikipedia.org/wiki/Subnautica)
- [Wikipedia: Tetris Holding, LLC v. Xio Interactive, Inc.](https://en.wikipedia.org/wiki/Tetris_Holding,_LLC_v._Xio_Interactive,_Inc.)
- [Wikipedia: Tom Clancy's Splinter Cell: Chaos Theory](https://en.wikipedia.org/wiki/Tom_Clancy's_Splinter_Cell:_Chaos_Theory)
- [Wikipedia: Uboat (video game)](https://en.wikipedia.org/wiki/Uboat_(video_game))
- [GDC Vault: Get Your Money! An Indie Dev's Guide to OST Profitability](https://gdcvault.com/play/1029183/Independent-Games-Summit-Get-Your)
