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
 22:["Release sled, open its lane gate, recover Quietus.","The stalled sled takes damage at a shut gate.","CHOIR WORK acts on local machinery."],
 23:["Cycle LOCK A, B, C at their depths; recover Quietus.","The warden charges from received evidence.","Each equalizer opens the next shutter."],
 24:["Tow ballast to BYPASS or ISOLATE; recover Quietus.","Restoring the passage also feeds the bus.","First recovered placement commits the route."],
 25:["Escort sled to a dock, observe arrival, recover Quietus.","The sled stops when its escort leaves.","Keep a craft within 200m."],
 26:["Lift and recover the physical pressure spindle.","The west mouth seals 100s after lifting.","COOLING opens the south return."],
 27:["Chock counterweight, tow to cradle, recover core.","The loose load slides back downhill.","Chock at LOCK A before towing onward."],
 28:["Tow bell via both locks, LAND at west dock; recover.","The tow needs two decompression stops.","Release a tow before changing depth."],
 29:["Reconnect in the window, or DISMANTLE; recover Quietus.","The reconnect window lasts 150s.","LOCK C starts the reconnect sequence."]
}
const FOLD_LABELS={"show":"FITTINGS\nSHOW","hide":"FITTINGS\nHIDE"}
const STYLE={"margin":24.,"title":18,"goal":14,"photo":14}
static func applies(index:int)->bool:return enabled and ROWS.has(index)
static func goal(index:int,fallback:String)->String:
 if not applies(index):return fallback
 var row=ROWS[index]
 return "GOAL: %s\nDANGER: %s\nNEW THIS DIVE: %s"%row
