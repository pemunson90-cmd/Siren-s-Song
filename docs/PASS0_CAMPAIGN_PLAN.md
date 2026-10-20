# Pass 0 — the whole game, rough

Build this campaign once at rough quality, then evaluate the whole experience.

## Playable graph
`0 → 1 → 2 → 3 → 4 → 5 → 6`
At6, take the deep exit: `7 → 9 → 11`; or the shelf exit: `8 → 10 → 11`.
At11, recover concealed through12 or transmit openly through13.
Replay the campaign from a fresh start to take every combination.

| Node | Function | Enemy roster | Initial status |
|---|---|---|---|
|0–5|Six-operation tutorial; preserve existing roles and mechanics|Patroller, sentinel, hunter, glider|rough|
|6 Divergence|Choose deep evacuation or shelf warning route|Patrollers|rough|
|7 Deep Rendezvous|Confirm evacuation berth; recover Quietus baffles|Sentinel, patroller|rough|
|8 Shelf Return|Deliver warning; recover drone survey array|Hunter, patroller|rough|
|9 Wake Crossing|Carry the evacuation packet forward|Hunter, patroller|rough|
|10 Warning Chain|Prepare both receivers and transmit|Sentinel, patroller|rough|
|11 Confluence|Choose concealed recovery or public warning|Thread-dependent sentinel or hunter, patroller|rough|
|12 Concealed Record|Recover witness through the sluice or detour|Sentinel, patroller|rough|
|13 Open Warning|Choose a transmission origin and recover reply|Hunter, sentinel, patroller|rough|
|Deep+12: Silent Exodus|Evacuees escape with their route hidden|Distinct ending screen|unbuilt|
|Deep+13: Beacon Pact|Evacuees organize a public safe channel|Distinct ending screen|unbuilt|
|Shelf+12: Hidden Harbour|Shelters evacuate covertly|Distinct ending screen|unbuilt|
|Shelf+13: Surface Reckoning|Surface disaster averted; corridor exposed|Distinct ending screen|unbuilt|

## Persistent capability upgrades
Fit one hardware item per craft slot before launching; capability persists into later missions.
Tutorial5 unlocks Quietus vector drive (faster cruise) and drone deep cells (longer field endurance).
Deep7 unlocks Quietus baffles (reduced actual movement emission).
Shelf8 unlocks drone survey array (longer ordinary passive/chart reach).
Existing correlator and sampler remain optional recovered tools.

## Build and evaluate
Implement reachable graph, mixed rosters, upgrades, four endings and fresh-campaign access concurrently with explicit file ownership.
One merge reviewer checks crashes, softlocks, unfinishable branches and current-save corruption; existing PR smoke gates apply.
Fresh critics play every branch to every ending through actual injected touch on both phone views.
Then evaluate the whole game and prioritize the audit’s Stakes, One real operation and Instruments passes from that evidence.
Only the user ends the Gauntlet. Placeholder presentation and rough balance are accepted during Pass0.
