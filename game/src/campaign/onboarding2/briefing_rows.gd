extends RefCounted
# 029 mechanical briefing data, not operation logic or narrative. Revert with
# enabled=false, or remove the campaign_flow hooks and this folder. No save fields;
# the full original brief and local-order instructions remain in FIELD MANUAL.
static var enabled=true
const ROWS={
 3:["Photograph FURNACE and LAUNCH CRADLE; recover Quietus.","Open plant water offers little cover.","DEEP bypasses basalt, not the plant."],
 4:["Collect the well's three records; recover Quietus.","The hunter follows noise.","Depth changes the approach."],
 5:["Record crown and wakes; LISTEN in the lee; recover.","Only Quietus can take the listening record.","Hold LISTEN for six seconds."],
 6:["Locate a carrier and recover through its named exit.","Received bearings can bend around rock.","The physical exit selects your route."],
 7:["Confirm the berthing carrier with Quietus; recover north.","A sentinel holds the berthing water.","RELEASE BERTH moves the tender, audibly."],
 8:["Deliver warning, hear both replies, recover Quietus.","The resonator call draws the hunter.","Sending alone is not acknowledgement."],
 9:["Receive the live return with Quietus; recover north.","A bearing or cadence does not prove safety.","Close scouting works without a correlator."],
 10:["Power and route the warning; commission and recover.","Moving the power craft cuts its umbilical.","Backup power lets Quietus work alone."],
 11:["Receive the live transmission; choose a recovery mouth.","Currents help approaches and resist returns.","The exit commits the next operation."],
 12:["LAND WITNESS, finish the received task, recover Quietus.","Winching and machinery are audible.","A lost carrier leaves a recoverable pod."],
 13:["Transmit, hear reply, escort launch, hear arrival, recover.","Recipient destruction fails the dive.","The launch needs an explicit departure order."],
 14:["Receive the account in MIDDLE; recover Quietus.","Buoys report real noise through relays.","Depth offers alternate crossings."],
 15:["Release a vane, receive its account, recover Quietus.","Charged listeners can forward a report.","Use local REACH WORK for machinery."],
 16:["Receive the thermal atlas; recover Quietus.","Crossflow carries exhaust and sound.","The intake valve is optional."],
 17:["Receive the account and recover the physical spindle.","A lost carrier leaves the spindle behind.","Quietus and cargo must reach recovery."],
 18:["Choose SERVICE or SEVER SPUR, receive account, recover.","Restored service also supplies the relay.","First recovery commits the choice."],
 19:["Hear the northern register and recover Quietus.","Listening relays still forward noise reports.","Earlier lock work changes the route."],
 20:["Receive the account and recover the physical prism.","Photographing it does not recover material.","Material and atlas unlock a fitting."],
 21:["Receive the account and recover the service wafer.","Quiet gate access is local, never remote.","The wafer and ledger unlock a decoder."],
 22:["Release sled, open its lane gate, recover Quietus.","The stalled sled takes damage at a shut gate; a patrol watches recovery.","Send a drone to the gate while Quietus releases the sled."],
 23:["Cycle LOCK A, B, C at their depths; recover Quietus.","The middle post hears LOCK A; clear west before climbing.","Stage drones at upper valves; each still needs its own depth."],
 24:["Tow ballast to BYPASS or ISOLATE; recover Quietus.","A southern post watches bare towing; restoring the passage feeds the bus.","A traction-yoke drone fits the service slit; bare tow goes outside."],
 25:["Escort sled to a dock, observe arrival, recover Quietus.","The sled stops without its escort; industrial guards watch its voyage.","Send a drone to service the berth while Quietus reaches release."],
 26:["Lift and recover the physical pressure spindle.","The middle approach is patrolled; the mouth seals 100s after lifting.","Dive early; a drone can winch while Quietus stays clear."],
 27:["Chock counterweight, tow to cradle, recover core.","The loose load slides downhill; a post watches pickup and recovery.","A drone can wait at the core while Quietus tows the weight."],
 28:["Tow bell via both locks, LAND at west dock; recover.","The tow needs two decompression stops.","A nearby drone can work each stop while Quietus keeps the tow."],
 29:["Reconnect in the window, or DISMANTLE; recover Quietus.","The southern post watches the crossing; reconnect lasts 150s.","Stage Quietus at RECONNECT; a drone throws LOCK C."],
 30:["Photograph SCOUR EDGE in MIDDLE; recover Quietus.","A patrol approaches the exposure lane.","Scout the unresolved DEEP return with a drone; its 36s image costs Quietus a detour."],
 31:["Photograph the survivor marks in MIDDLE; recover north.","The shaft post watches the approach.","A drone can resolve and record the SHALLOW terminals while Quietus works."],
 32:["Shut in the well, photograph the breach, recover its core.","The long shaft return spends most of a bare oxygen reserve.","A drone records the nameplate while Quietus works; plan the material return at DEEP."],
 33:["Equalize the gallery, photograph its people, recover the reed.","The southern post watches the equalizer approach.","Scout the western scoring with a drone while Quietus opens the gallery."],
 34:["Work all three machines in order; photograph the junction.","The west return crosses warden pressure.","Send a drone for the impact face; recover both drones and their modules."],
 35:["Photograph the keel and recover the physical plate.","A deep post watches the north approach.","The wellhead seal halves lift work; the lift opens the short south return."],
 36:["Photograph the deep guard window; recover west.","A middle post watches the long west recovery approach.","A tuner drone can silence the breaker and open the central return."],
 37:["Photograph the trawler in DEEP; recover Quietus.","The SHALLOW bonus costs another depth crossing.","A window photograph confirms life, not rescue."],
 38:["Photograph the saddle underside in DEEP; recover.","The sluice motor is audible across 1400m.","Recover at the southeast mouth in MIDDLE."],
 39:["Photograph the exhaust joint in MIDDLE; recover.","The exhaust front masks both sides' sound.","The northern contour passes optional numbers."],
 40:["Photograph the western divide in MIDDLE; recover.","The eastern bonus needs a sixteen-second exposure.","The optional sluice opens a noisy short return."]
}
const FOLD_LABELS={"show":"FITTINGS\nSHOW","hide":"FITTINGS\nHIDE"}
const STYLE={"margin":24.,"title":18,"goal":14,"photo":14}
static func applies(index:int)->bool:return enabled and ROWS.has(index)
static func goal(index:int,fallback:String)->String:
 if not applies(index):return fallback
 var row=ROWS[index]
 return "GOAL: %s\nDANGER: %s\nNEW THIS DIVE: %s"%row
