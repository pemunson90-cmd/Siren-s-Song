# Cover cautious actual-play notes

Requested routing: inherited parent model; backend/effort telemetry unavailable.
Strategy: cautious, Quietus-focused; no builder history, source, scripted controller, or winning routes inspected.
Input: external live raw physical-pixel CLI at cover 2520x1080. Pause allowed.

## Startup
- 2026-10-20 00:02 UTC: started critic-cover-cautious against guidance-current.
- Startup blocker: start timed out waiting for ready.json; status timed out waiting for reply.json. Reported to harness owner planner_space and root before play.

## Operations
No game screen reached yet.

## Shelf Signal / tutorial0 (in progress)
- Actual menu/briefing recovered in new live session critic-cover-cautious-live. Read all briefing orders by repeated physical drag.
- Used FIT to survey full chart. Left both drones at extraction; used Quietus on default SILENT.
- Route chose lower passage beneath central rock, then east beneath upper-right rock to within camera range of gold Signal Spire.
- Camera action required unpause and a four-second exposure. Record secured; hull100, O2~117 visible; no enemy sighted and no losses.
- Returning diagonally below central rock to extraction; no sonar, disruption, torpedoes, survey, decoys, guard, route queue or drone orders used yet.
- Initial impression: touch command ring is readable, but live map begins highly zoomed with gold objective off-screen; FIT was essential. Briefing explained FIT sufficiently. Camera working while paused was clear only after bottom status said hold4seconds.
- COMPLETE: Archive Recovered. Debrief dive time01:16, hull100%, life support115%, no craft losses. Completion screenshot tutorial0-complete.png.
- Continuing NEXT DIVE immediately.

## Split Channel / tutorial1 (in progress)
- Briefing offers split drones/Quietus uplink or lone-sub circuit; chose cautious scout DroneA LOW visual profile up western arm before moving Quietus out of shelter. DroneB still held in recovery basin.
- Actual route: east below southern sill, then north in narrow lane west of central long wall, east of western cover rocks.
- Minor confusion: profile wedge text displays current state and selecting LOW toggled to OPEN; immediately switched back before movement. DroneA bottom status confirmed LOW profile.
- DroneA lost to S1 patrol in western lane before first image; Quietus command restored automatically, no restart/softlock.
- Quietus followed scout route silently; surveyed once from south lane approach, then encountered S1 beam warning2.4s. Disruption interrupted it; moved north. West image secured; second beam0.5s interrupted with last disruption. Brief cruise burst crossed northern saddle; restored SILENT on east arm.
- East image secured. S2 patrol threatened beam2.9s on lane descent; actual torpedo targeting UI offered FIRE and launch succeeded. Impact snaredS2 for8seconds. Cruise burst descended narrow lane, restored SILENT, six-second CAMERA/LINK secured UPLINK.
- Exit routed below central wall, through southern sill gap and west to recovery. FIT object/craft hit areas swallowed several intended nearby-water taps; FOCUS allowed precise plotting around the sill. No collisions/damage occurred.
- COMPLETE: Archive Recovered. Debrief dive time03:49, hull100%, life support107%. Loss: DroneA. Spent:2disruption,1survey,1torpedo. Unused:DroneB,3decoys,1survey,1torpedo, sonar, guard, route queue/plan.
- Completion evidence tutorial1-complete.png. Root requested switching to demand-render raw-input harness after operation to reduce contention, preserving exact save and frozen source.

## User audit pause / stopped
- Root's audit-pause message arrived immediately after starting demand driver with unchanged completed-operation save. No new operation entered. Inspected rendered menu: Shelf Signal RECOVERED; Split Channel RECOVERED; Blackwater Relay AVAILABLE; Cold Foundry LOCKED.
- Both old live and new demand sessions have been quit successfully. Latest session critic-cover-cautious-demand is stopped on menu, paused; no simulation/process left intentionally running.
- Frozen source branch gauntlet/docs/pass0-plan, SHA9d30dc83a1a2709dfa29948b35e72ee5b2297684.
- Preserved current profile: /workspace/Siren-s-Song-gauntlet-archives/live-input-harness-demand/sessions/critic-cover-cautious-demand/data/godot/app_userdata/Siren's Song/quietus.save
- Original profile remains at analogous live-input-harness/sessions/critic-cover-cautious-live path. SHA256 both26d76b9133db2b7fc60a9149b17cafc64021d180add37f84a49a4e079f43cecd, confirming unchanged transfer.
- Current last operation mission1/tutorial1 Split Channel WON; 03:49; hull100; oxygen107.271; DroneA lost, DroneB alive83.635%battery; tools3decoy,0disrupt,1torpedo,1survey. Fractional values from driver status recorded only after play; strategy used rendered UI.
- Exact next action after authorization/restart: start demand driver with this profile and frozen source, then tap physical1320,690 on visible03 Blackwater Relay AVAILABLE to open its briefing. No reset/source change.
