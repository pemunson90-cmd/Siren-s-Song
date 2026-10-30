# Siren's Song: whole-game plan, draft 1 (Claude S11, 2026-10-30T18:10-04:00)

Basis: critic 123 on build 26e09906, all regions (main O2 to G2, L1, side S1 to S3, staged Iron Choir C1, staged Trench T1/T2), the Haiku evidence base (51 clusters, Claude-reviewed), the late-verdict addendum, Astra REPORT, COLD_REVIEW_4. Still to fold in: root's COLD_REVIEW_5 and the Iron Choir C2 critic (running). Code facts below were read by Claude at claude/integration 05d09718.

## What the critics agree is good (do not break)
Fleet coordination under exposure: one craft draws a Siren, another records. Depth changes access. Physical cargo makes the trip home matter. Disrupt stun windows, delayed Survey, torpedo refusing a wasted shot, pause-and-restore across quit and relaunch, Calder's stopped drill wash. Protected rules (beam, 4 s lock, collision and damage, senses, sweeper, photo grading, endings, art direction) stay untouched by every package below.

## What is wrong, ranked by how much it costs the player
1. **The game says things that are not true or will not work.** "WITHDRAW AT SOUTH" is a fixed string (mission_hud.gd:111) shown on ops whose exit is north or east. ROUTE HERE and the work route aim at the object's own centre (mission_hud.gd:208/214/244), so they fail with "Rock or unsafe clearance" when the object sits on rock. Valve work reads CAMERA/PHOTO; a hydrophone decode reads CAMERA READY; machinery reads STARTED. Grey buttons never say why (range, band, settling, heading, prerequisite). Briefs list Disrupt charges the drone does not carry. Six critics, every region.
2. **What you tap is not what you get, and the board moves under your finger.** Your own craft hides its work site; labels and GOAL boxes become move orders; the chart re-fits when any panel opens; the Hunt box covers threat and lock text (three critics, top pick of one); at 150% text the craft defence actions cannot be reached.
3. **Extraction loses craft without asking.** Auto-recovery ends the dive with drones outside or mid-job (a 96% photo cut off); own craft collide on shared routes with no warning (13 hull points in one op).
4. **Travel is a stream of confirmations.** Terrain stops fire on new measurements that do not block the course (seven in a row in Silt).
5. **Prep screens bury the decision.** Fittings and Career put racks and history above the choice; dive-end screens drop time, hull and oxygen on some paths.
6. **It looks and sounds unfinished in places.** Title shows "PLACEHOLDER KEY ART"; machinery is gold boxes plus text; one cage icon for photo, valve and site; DEEP/SHALLOW charts are coarse next to MIDDLE; audio drops to five voices in dense play. No critic could judge audio at all.
7. **Late ops feel alike.** Late arcs reuse one factory pattern of machinery plus photo; photo value favours distance and tools over quality.

Not a game bug: the four critic stalls were the test driver dropping half-written commands (driver.gd:18).

## Pieces and the game each is judged against (blind, ratchet: keep only winners)
| Piece | Reference | The bar |
|---|---|---|
| Commands and status text | Into the Breach | every action shows its exact effect; a grey action says why |
| Chart and touch | Mini Motorways, Door Kickers | the board never jumps; a tap does one predictable thing |
| HUD and threat | Cold Waters | threat, lock and time are never covered |
| Fleet and extraction | FTL | nothing is lost without a clear last chance |
| Route flow | Door Kickers | stop only when a real decision exists |
| Prep and results | FTL hangar, Into the Breach squad screen | the decision is the first thing on screen |
| Look and sound | Iron Lung, Barotrauma, Mark of the Ninja | atmosphere, and sound that carries information |
| Mission variety | Into the Breach islands, Highfleet | each late op asks a different question |

## Work packages, in order
0. **Harness fix (root, not game work).** Driver returns an explicit parse-error result; sender and driver write temp-then-rename. Needed before any further critic run.
1. **Truthful commands (Claude lane, first).** Real exit names; legal approach points per work site; job-specific verbs; a named reason on every grey action; per-craft tool counts in the brief and the craft menu. Small, mostly text and target selection, verified in source.
2. **Stable board and clear threat (root lane, in parallel).** Tap ownership with an explicit chooser for overlapping targets; no chart re-fit on panel open; a reserved threat stack nothing covers; every craft action reachable at 150%.
1b. **Release controls (Claude lane, right after 1; Pat 30 Oct).** One-press travel shortcuts become test-only; in release play the player moves by planned legs, changes depth, works what is in reach and recalls drones. Handoff 127.
3. **Recovery manifest (Claude lane, after 1).** Per-craft in/out list before recovery triggers, hold or confirm when a craft is outside or working; own-fleet path conflict warning.
4. **Route flow (after 2).** "New measurement, course still clear" continues without a stop; a stop names the obstruction.
5. **Prep and results.** Fittings and Career decision first; full dive-end stats on every path.
6. **Look and sound, started now as read-only.** A blind side-by-side of our captures against the reference games, so graphics and audio are planned from evidence, not left last. Building waits for your art-direction calls.
7. **Late op variety.** Plan after 1 to 4 land, from a fresh critic.

Each package: before/after captures, one fresh blind critic against its reference, keep only if it wins. Never an APK unless you ask.

## Still unplayed by any critic
END OF LINE and the authored endings (merged in 125, not yet promoted), Glass Reach 5 to 9 in earned play, audio, phone feel and frame rate. After package 0, one critic plays the Trench through END OF LINE on the build carrying 125.
