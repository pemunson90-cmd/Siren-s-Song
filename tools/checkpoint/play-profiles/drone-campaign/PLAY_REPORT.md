# Drone campaign actual-play record — stopped for audit

Fresh actual play, cover fixture 2520×1080, physical injected input only. No game implementation, builder history, technical routes, game callbacks, Sim commands or edited state were read/used. Tactical pause was used extensively. Requested routing: Sol6.1 ultra; backend telemetry unavailable. Dummy audio, desktop cover fixture; no human enjoyment, headphone/audio or physical Fold7 ergonomics verdict.

## Provenance and preservation

- Source path: `/workspace/Siren-s-Song-resolution-operations`.
- Both driver `source.json` records say SHA `a824280b14b5a20b0dfb9e8c4380edc710f61bd8`, game tree `805d337b05201e4629e795e48da62bb5ed33fb32`. Current branch reported by Git: `gauntlet/feature/campaign-endings`. Dispatch described merged production `137bf44`; root was told of the recorded provenance difference. This critic did not inspect history or implementation to reconcile it.
- Fresh session: `critic-drone-campaign`, old driver. Its raw directory is preserved as `original-session/` here.
- At mission02 122.0833 seconds, after visible PAUSE saved, quit and copied the genuine profile unchanged into demand-rendering session `critic-drone-campaign-demand`. Chose the visible RESUME ACTIVE MISSION menu option. Verified elapsed time, hull100, both drones dead, tools and positions preserved. Both driver provenance records show the same source/game tree.
- Demand session raw directory is preserved as `demand-session/` here. It contains inputs, requests, responses, screenshots, log and genuine profile. This driver uses an atomic raw tap; root described it as the same game source.
- Audit pause received at mission02 134.5167 seconds. Already paused; captured and quit without any further gameplay input. Both Godot sessions have been quit.

## Mission01 — Shelf Signal

Won on first attempt at **52.5833 seconds**, hull100, life support117.0787, Drone A lost, Drone B alive at96.244% battery. Quietus never left extraction. Tools remained decoy3/disrupt2/torpedo2/survey2.

Read the briefing and orders, entered paused, selected FIT. Chose Drone A to scout below the central rock, then northeast into the channel below the upper-right rock. Physical waypoint taps included `(1280,730)` then `(1760,555)`. At15.48 seconds A had stopped at the east bend. I tapped the spire expecting a route, but it opened an OBJECT ring; I did not notice the lack of movement until the next pause. A was lost near20.5 seconds to S1 patrol, newly visible in that channel. Quietus hull stayed100.

Sent Drone B around the south perimeter using `(2000,1030)`, then up the east side with `(2015,370)`. This avoided the patrol and the lower rock. Tapped the spire, chose CAMERA in its object ring, read the four-second exposure instruction and unpaused. The archive recovered at52.58 seconds; Quietus was already home. Debrief says a manufactured pulse is counting the seconds between our pings.

Unused: Quietus movement, Drone A/B sonar, drone tools, route queue, route-program editing beyond opening and exiting it, decoy, disrupt, torpedo and survey. I did not hear audio.

## Mission02 — Split Channel (unfinished due audit stop)

At stop: **134.5167 seconds**, hull76.9, life support112.52685, Quietus alive in cruise near the northern saddle, both drones dead. Tools decoy3/disrupt1/torpedo2/survey2. WEST relay photographed; EAST relay and UPLINK ANCHOR still unfinished. No ending reached or rated.

Briefing: photograph WEST and EAST relays, then Quietus to the sheltered UPLINK ANCHOR for a six-second CAMERA/LINK. Read the western/eastern arms and northern saddle description. Selected FIT. Both drones were restored for the new mission.

Drone B went east underneath the start rock to `(1220,990)`, then north up the narrow middle channel with `(1190,350)`. At25.55 seconds B was beside the small central rock. I intended a west-relay approach, tapped a point close to the relay and again opened its OBJECT ring rather than issuing movement. B stayed exposed and died around29.5 seconds to S1. I had not yet learned to use the object ring's explicit ROUTE HERE.

Drone A followed the south gap to `(1220,990)`, north to `(1210,750)`, then northwest to `(1060,440)`, approaching the small rock from below-left. At50.4 seconds I opened WEST relay and explicitly chose ROUTE HERE. S1 killed A around53.3 seconds on that approach. The bottom message explicitly restored Quietus command and said submarine camera remained available; this prevented me from assuming a softlock.

Quietus followed the south gap, then the western approach. It remained in silent42 drive for much of this movement. I used one sonar pulse after correcting an initial menu-position mistake. Near122 seconds it reached WEST relay without damage. Migrated to the demand driver at this paused checkpoint.

On resume I accidentally toggled cruise while learning the clamped command-ring position. Opened Quietus CAMERA/LINK and held for four seconds. WEST relay became blue/recovered. S1 attacked during the exposure; hull fell to86.8 and then76.9 before the next pause. Used TOOLS → DISRUPT (the displayed instruction says twelve-second recovery window) and routed Quietus southeast to `(1190,330)`, the northern saddle between the upper and lower central rocks. Hull stayed76.9 during this escape. Audit stop arrived at the next pause before the eastward leg.

Unused in mission02 so far: decoys, torpedoes, survey, drone tools, deliberate cruise/silent comparison, route queues/programs, EAST relay, UPLINK ANCHOR and extraction. No campaign story branch, upgrade or ending has yet appeared. Evacuation investigation/discreet recovery remains the intended story choice if offered later.

## Main observed friction (seen content only)

1. Object hit areas at FIT are much larger than their art. Two planned movement taps became object-ring selections. I failed to notice that goals were unchanged and unpaused, losing a drone in each mission. These are actual player mistakes encouraged by the input presentation, not claims of broken route transport.
2. Command rings are large and clamp away from the craft. Guessing a familiar sector at a different clamp position selected an unintended action or closed the menu. This consumed substantial real time while paused and obscured map context. The early old driver also added seconds per command and rendered continuously; demand rendering improved this substantially.
3. A newly discovered patrol can kill a drone within a few seconds while it is stationary. The visible S1 role/state/last-seen label helps after contact, but my first two losses were understood after the next pause. I have not evaluated whether a more practiced drone strategy avoids all these losses.
4. Quietus camera fallback and the explicit loss message let the mission continue after both drones died. Disrupt's visible twelve-second window produced an understandable escape.
5. Mission01's drone camera completion was satisfying as a functional remote-objective loop, but human enjoyment is unmeasured. Mission02 already required materially different routing and a Quietus uplink; the rest of the campaign is unseen.

## Exact recovery

Latest genuine profile (also copied under `demand-session/`):

`/workspace/Siren-s-Song-gauntlet-archives/live-input-harness-demand/sessions/critic-drone-campaign-demand/data/godot/app_userdata/Siren's Song/quietus.save`

Start a new unique demand-driver session with `--shape cover --source /workspace/Siren-s-Song-resolution-operations --profile` pointing to that profile. Inspect the initial screenshot and choose the visible RESUME ACTIVE MISSION button (previous physical position `(1330,355)`). Verify mission02,134.5167 seconds, hull76.9 and both drones lost. The next intended physical input after resume is **tap `(1576,335)` on EAST RELAY**, inspect its object ring and choose **ROUTE HERE** (previous clamped top sector around `(1576,240)`). This is an intended next action, not an executed/verified route. Decide subsequent tactics from the resulting visible screenshot.

Last actual frame: `demand-session/1792456299579606069.png`. All earlier input and response records remain beside it.
