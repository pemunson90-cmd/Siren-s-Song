# DESIGN: Campaign depth (ops 6 to 29), photo-first. Proposal only.

## 1. Honest audit (from source on claude/integration bde5c0e)
Photo subjects exist on only 4 of the 24 ops (16, 17, 20, 22) in campaign/photo_ops.gd. Ops 6 to 15, 18, 19, 21 and 23 to 29 (20 ops) have no authored subject. Siren studies are the only camera use there.

**Blackwater / Cold Foundry / Well range (6 to 13).** Task: choose deep or shelf, ferry a tender, plant warning relays, then carry a witness or a warning to a recipient. Ops 12 and 13 are exclusive (concealed or overt) and pick the ending. Camera use: none. Op 8 even says "No camera hold is required". Op 6 to 11 are listening and signal-bearing jobs ("Observation orders", arrival arcs). Thin: stakes are decided by a choice, not by anything seen.

**Glass Reach 14 to 21.** Task: one received account per op (Vey), listener buoys, vanes, gates, winching material. 14 to 19 is a straight chain, 20 and 21 branch off 16 and 17. Photography: 16 Furnace Drift (hidden exhaust plume, thermal) and 17 Silt Archive (scour), which already feed op 19 and 25. 20 Prism Grave has an optional facets shot. Ops 14, 15, 18, 19, 21 have none. Thin because 15 Needle Strait is a channel plus buoys and the map is a flat list.

**Iron Choir 22 to 29.** Task: sleds, locks, towing a bell, a breaker, wardens. Photography: 22 only (lit window, a figure). Ops 23 to 29 have none. Core is 22 to 25, 26 to 29 are optional side jobs. 23 Pressure Stair has bulkhead locks and four rock shapes and no landmark to read. Industrial work has fully displaced recon, exactly the risk in Codex report 012.

Also: the ending screen fires at op 12 or 13 (endings.gd) with 4 outcomes, then ops 14 to 29 run after it. The "ending" is a text card (main.gd _show_ending).

## 2. Photography rework per band (data first, using photo_ops.gd rows, photo_findings, photo_intel effects, PRICED1 film and light tables)
The pattern for each: an unknown (hidden or unnamed) subject, a feature that only resolves from the right side, a finding on the chart, and an intel key that changes a later op. No new engine.

**Blackwater / Foundry / Well (6 to 13): "what are they doing" shots**
- 7 Rendezvous: the tender's hull from outside. Subject: the carrier hull (ship or sub, not named until framed). Reveals its door side (a finding of kind route: the quiet loading lane). Changes: op 9 and 12 start with that lane charted. Uses: unknown subject plus findings.
- 8 or 10 shelf chain: the three relay posts. Subject: the damaged post with a cycle feature (a lamp that blinks on a count). Photographed across the cycle (long observation, as base_cycle on op 3). Reveals: the gap in the blinking window. Changes: op 10 plant orders get a safe start time. Uses: the full-cycle observation rule that PHOTO1 already built.
- 11 Confluence: one Siren structure on the concealed vs overt approach. Photo: its front arc (Siren study). Reveals its patrol edge. Changes: op 12 or 13 guard timing shown on the chart. Uses: Siren studies plus the approved "small readable rule shift" on studying.

**Glass Reach (14 to 21): "what is the range doing" shots**
- 14 Glass Fence: a listener buoy lamp. Feature: its aspect arc (the lamp faces only one way). Finding: blind side. Changes: op 15 the same buoy type is drawn with its blind side. Uses: subject features with aspect arcs.
- 15 Needle Strait: the strain vane wall, hidden crack (needs tele lens, optional bonus per approved gating). Finding: a weak point (a vane you can release quietly). Changes: op 15 itself and op 21. Core job still finishable bare.
- 18 Lantern Lock and 19 Last Boat Out: a nameplate or keel mark on the wreck (person or route finding). Changes: which choice at 18 reads as safe, from fair evidence rather than a menu. 21 Range Locker: the locker door photographed from the shallow band for a latch finding (uses the DEPTH1 band field).

**Iron Choir (22 to 29): "who is here" shots, tied to people and machines**
- 23 Pressure Stair: the three lock shutters. Subject: shutter indicator lamps, a cycle feature (order A, B, C shown by lamp colour). Reveals the sequence before you spend oxygen. Changes: the brief stops stating the order.
- 24 Choir Cut: the ballast switch at BYPASS vs ISOLATE. Photograph the bus cable run. Finding: which side the reporting bus feeds. Changes: the choice becomes informed. 
- 26 to 29: one optional tight shot each: spindle wear (26), counterweight slide mark (27), bell hull name (28, person finding), security feed room (29). Each files one intel key for the ending layer.
Keep about 1 photo task per 2 other tasks so rescue and towing stay.

## 3. Campaign route map (self-contained module)
Screen: new `presentation/route_map/route_map_view.gd` (draws), `campaign/route_map/route_graph.gd` (data), `campaign/route_map/route_graph_table.gd` (node positions, labels, edges). One seam: `main._show_campaign()` gets one line, a button "ROUTE MAP" that opens the view; the flat list stays as fallback. It reads `Catalog.definition(id).prerequisites`, `prerequisite_mode`, `required_facts`, `route`, and `Campaign.available(completed, expedition)`. No new save fields required.
Nodes (30): 6 at the left, fork to 7 (deep) and 8 (shelf), merge at 11, fork to 12 or 13, then 14 to 19 line, side spurs 20 and 21 off 16 and 17, 19 to 22, 22 to 23 to 24 to 25 with 26 to 29 as small side nodes. Ops 0 to 5 are one grouped node.
States per node: RECOVERED (filled), AVAILABLE (lit ring), LOCKED (dark, name hidden, shape only), KNOWN-FROM-PHOTOS (dashed ring, name shown, from a photo intel key). Example: Silt Archive film (silt_scour) draws a dotted line from 17 toward 19. A node's name appears only when its prerequisite is recovered OR a photo finding mentions it. Add a `reveals` column to the table: `{intel_key: [node ids]}`. Fair information: reveal is a label and a rumour line drawn, never a free reward.
Tap targets 64 px minimum.

## 4. Endings (structure only)
Today: 4 endings from `confluence_route` (concealed/overt) times `selected_thread` (deep/shelf), resolved in endings.gd at op 12 or 13, before 14 to 29.
Proposed: keep `resolve()` as is; add a second layer `ending_epilogues` in a new `campaign/endings_photo.gd` that reads `photo_intel` keys and Glass/Iron facts (glass_choice at 18, choir_choice at 24, choir_people 28, choir_plant 29) and picks one of the 4 as a variant. Example: three or more siren_* keys filed unlocks a variant; none filed gives the blind variant. Needs Pat: whether the true ending moves to after op 25, and what an ending even is (scene vs card). The ending card could become an annotated photo wall of the player's best film (reads the archive, no new text).

## 5. Art and atmosphere minimum for thin ops
Existing tools: terrain.gd (shard, ridge, arc), `structures`, thermal_fronts, basalt.png, photo_scene lamp and snow. Data only:
- Blackwater/Well: 2 landmark silhouettes each (a wreck ridge, a relay tower as ridge plus lamp glow), one lit colour per op.
- Glass Reach: buoys with visible lamp cones, a cold blue palette, 4 to 6 vertical glass spires drawn as ridge shapes.
- Iron Choir: lock frames as arc shapes with lamp colours, a warm ember light on works (glow in subject), moving sled lamp.
Cap: 3 to 5 landmarks per op, each with a glow value, so black water has places in it.

## 6. Build order
- **M1 (small, 1 PR): photo rows.** About 14 new rows in photo_ops.gd on ops 7, 8, 10, 11, 14, 15, 18, 21, 23, 24 plus optional 26 to 29, with intel keys and apply_effects in photo_intel.gd. Must follow PRICED1 and DEPTH1 landing.
- **M2: route map module** (section 3), independent of M1; shows photo reveals once M1 exists.
- **M3: landmarks (section 5) and ending layer (section 4).**
Do NOT build: new photo engine, annotation tool, new save objective types (the op 3 bug), a Siren study requirement on core ops, text for story.

## Questions for Pat (recommendation)
1. Should the ending move to after op 25? Yes, recommend a final pair after Iron Choir core.
2. Should film ever gate a route? No, informative only.
3. Keep 12 and 13 as the fork? Yes.
4. Who are the figures photographed (person findings)? Your call; keep them human survivors.
5. Ending as scene or annotated photo wall? Photo wall first.
6. Do Siren studies change timing on core ops? Recommend small and readable only, as already approved.
