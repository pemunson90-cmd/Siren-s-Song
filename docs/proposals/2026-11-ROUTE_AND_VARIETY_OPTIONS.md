# Route graph and late-operation variety: options for Pat

[AI-DESIGNED] proposal, written 2026-11-12 by the overhaul run. Nothing here is built and nothing here is a ruling. It contains no story text: operations are named by their existing titles and IDs only. Pat answers by letter in decision D-10 (`.fable/DECISIONS.md`).

## The problem, from evidence

- The specification asks for branching story routes "inspired by Star Fox": earlier play decides which later operations the player gets.
- Today the campaign has two real route forks. After operation 6 (The Divergence) the exit Quietus physically uses selects the deep thread (operations 7 and 9) or the shelf thread (8 and 10). After operation 11 (Confluence) the recovery mouth selects operation 12 or 13. From operation 14 to 34 every player flies the same core operations in the same order. The arc 5 fork that Pat approved on 29 October changes the recovery route inside two operations, not which operations are flown. (Source: `game/src/campaign/operation_catalog.gd`, `game/src/campaign/route_map/route_graph_table.gd`, `game/src/campaign/arcs/choir_fork.gd`.)
- The fleet diagnostic of 28 October classed 29 of 41 operations as waypoint runs for a bare fleet; later fixes raised pressure on some. The blind critic of 12 November found an optional operation with no Siren in range (grade A photo in eight commands) next to a core operation with three listening Sirens at the first photograph, and found no tool or fitting decisive in either (`.fable/COLD_REVIEW_6.md`, G5).
- Thirteen optional operations exist (20, 21, 26 to 29, 35 to 41). They hang off the spine as side trips.

## Part 1: which operations the player gets

| Option | What changes | What it costs | What it risks |
| --- | --- | --- | --- |
| **A. Alternates from what exists** | In arcs 4, 5 and 6, pair each of several core operations with an existing optional operation as its alternate. How the previous operation was recovered (which exit, which optional record, loud or quiet) selects one of the pair; the other becomes unavailable on that playthrough. No new operations. The route map shows the branch not taken. | Registry data (prerequisites, required facts) and route-map positions; a rule per fork; a pass over the endings so every path still reaches END OF LINE. Small now that operation metadata is in one table. | Optional operations were built easier than core ones, so some need their threat raised to stand in a core slot (Part 2). The total number of operations flown per playthrough drops slightly. |
| **B. Exit forks at arc ends** | Reuse the Divergence pattern: the last operation of arcs 4 and 5 gets two physical exits, and the exit used selects which of two opening operations the next arc starts with. Needs two new arc-opening operations. | Two new operations (geometry, Sirens, objectives, tests) plus the same registry work as A. | New content needs site and sequence approval from Pat before it lands. |
| **C. Same operations, different encounters** | Keep the spine. Earlier recovered facts select between two authored encounter layouts inside later operations (Siren roster and patrols, which objective is optional, which route is open). | An encounter variant per affected operation. The arc 5 fork already works this way. | It does not answer the specification's point: the player still gets the same operations. |
| **D. A then B** | Do A now for a real route graph at low cost, then add B's new operations when Pat has approved their sites. | A's cost now, B's later. | None beyond A's. |

Recommendation: **D**. A gives the route map real branches from content that is already built and tested, and it tells us whether branch choice is felt before any new operation is written.

For A, the pairs have to be chosen so that each alternate teaches or tests the same systems as the core operation it replaces. That pairing is a design list for Pat to see before it is built; it is not in this document because it depends on reading every paired operation closely.

## Part 2: the difficulty cliff and the waypoint problem

These do not change Siren senses, sight, lock, beam or damage. They change where Sirens are and what an operation asks for, which is authored content.

| Option | What changes |
| --- | --- |
| **P. Threat floor for optional operations** | Every optional operation gets at least one Siren whose patrol crosses the approach to its photograph or work site, so a bare run meets a Siren (the same bar item 139 set for four core operations: Hunt 20 or more, or one lock, and still finishable). |
| **Q. Fleet-required side objectives** | Each late operation gets one optional objective that only a second craft or a specific tool can complete in the time available, paid in the existing currencies. The core objective stays finishable bare, as Pat ruled on 28 October. |
| **R. Both** | P and Q together. |

Recommendation: **R**, after Part 1 is settled, because an alternate operation standing in a core slot needs P anyway.

## Part 3: rescued survivors

Pat's story ruling of 21 October makes the rescue subjects human survivors from drilling and military sites, and reserves characters, site sequence and ending conditions to Pat. Structurally, the systems that already carry people are: the witness pod (winch, carry, land; operations 12 and 41), the carried-survivor ascent rule (`game/src/simulation/survivor_ascent.gd`), cargo and the winch, and the "person" photograph findings shown as marks. A rescue in any operation can be built from those without new rules. Which operations hold survivors, and in what order, is Pat's sequence to give. No option is offered here.

## What this run did that helps

Work package WP-07 moved per-operation metadata (hunt cap, endurance, region, route-map position) into one table and added `docs/guides/ADD_AN_OPERATION.md`, so options A and B are registry and factory work, not edits across five files.
