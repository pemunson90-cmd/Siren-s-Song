# External footage preparation · ratified Addendum B

**Status: sources found; actual motion inspection and comparison remain pending.** No footage was downloaded or watched, no 10–20 second interval was selected, and no external win/loss verdict is claimed. Metadata, transcripts and stills are not motion review. No reference material enters `game/`.

[Source inventory](SOURCES.json) records exact official URLs, Steam movie IDs/HLS URLs, index-reported video names/dates, version uncertainty and access results. Public Steam media requests were rejected by the executor proxy with **HTTP CONNECT 403**. Approved web tools retrieved source metadata, but did not provide inspectable motion. A bounded search found the [official Barotrauma press page](https://barotraumagame.com/press/); opening it returned **502 Bad Gateway**, and no separately hosted inspectable video was obtained. No alternate proxy, remote CI or access-control bypass was used.

## Candidate sources, not reviewed segments

| Dimension | Candidate official video | Source context |
| --- | --- | --- |
| Sonar, moving threats and submarine dread | [Barotrauma Overview Trailer · Daedalic](https://www.youtube.com/watch?v=c0JmXvbvxq8) | Indexed as 13 March 2023, 3:17, 1.0 overview. Steam also lists `FeatureTrailer1.0_EN`, movie 256935387. Same edit is not verified; exact gameplay patch unknown. |
| Route planning, waypoints, conditional orders and touch UI | [Door Kickers Launch Trailer · KillHouse Games](https://www.youtube.com/watch?v=swp9d9tqg7M) | Indexed as 20 October 2014, 1:57. Steam movie 2035064. Launch-era original game; actual control platform/patch and suitable segment still need inspection. |
| Visible noise and learnable detection | [Mark of the Ninja: Remastered teaser · Klei](https://www.youtube.com/watch?v=sZ7ogfkR3hQ) | Indexed as 27 March 2018. Steam separately lists full Remastered trailer movie 256730179. Do not conflate the edits or assume a teaser demonstrates the needed mechanics. |

These are candidate official sources, not confirmation that any particular timestamp contains a matched comparison. The Steam API metadata itself is available through the web connector; successful metadata retrieval does not establish that media can be viewed here or that any current mobile store listing is playable.

## First comparison brief: support Addendum A

The production lead owns actual source-labeled Siren's Song clips after role RED→GREEN. The first useful dimension is **observable enemy attention over time**: response to an audible event, loss of visual contact, local search and return to station, plus a no-input world clip distinguishing an active patroller from an intentionally dormant hunter/guard.

Once reference motion is accessible, inspect enough of the Barotrauma source to select an actual 10–20 second segment showing the same dimension. Record exact start/end timestamps and what is observed; do not infer the creature's internal state from a promotional cut. Sonar-only and creature-exterior shots may require separate comparisons rather than pretending one clip proves both. Compare clarity/intent and dread, not identical enemy rules, combat, multiplayer balance or art direction.

Next, select Door Kickers planning and Mark of the Ninja noise segments by the same method. Preserve each game's own context and Siren's Song's nonlethal identity. Any later expanded reference set follows [the ratified reusable critic brief](../../CRITIC_BRIEF.md); Silent Hunter remains an unconfirmed title.

For each real comparison retain: source SHA/scenario/device/viewport/input state; reference URL/title/version and exact timestamps; the paired actual clips; blinding feasibility and prior identity knowledge; one-dimension observations, explicit losses and next bounded improvement in `BASELINE_AND_EXPERIMENTS.md`. A fresh critic may perform honest limited blinding where feasible; this preparer already knows source identities. No missing-media score or verdict should be recorded as a loss/win.

## Historical Android-source correction

The unchanged Addendum B summarizes Door Kickers' Android launch as tablet-only. KillHouse's [4 September 2015 official post](https://inthekillhouse.com/you-can-now-kick-doors-on-android/) explicitly says it was **also playable on phablets, 5.7+ inch large phones**; comments describe tablet or very large phone support. Preserve that distinction rather than turning a historical shorthand into a fixed phone-screen design limit. This is not a current-store check, a Fold7 comfort result or a recommendation to purchase/play. Current regional/platform availability must be verified before any such recommendation.

Requested worker: explicit `gpt-6.1-sol`; actual backend/usage/cost telemetry unavailable. No nested agents, gameplay edits, new infrastructure, paid acquisition, external messages or CI. Continue production A with this external-footage gap visible; do not represent the mandated footage comparison as completed.
