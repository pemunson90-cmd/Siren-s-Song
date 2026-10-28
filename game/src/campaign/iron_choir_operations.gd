extends RefCounted
const Patrol=preload("res://src/campaign/divergence_missions.gd")
const TITLES={22:"Hammerwake",23:"Pressure Stair",24:"Choir Cut",25:"Last Shift",26:"The Cold Hammer",27:"Counterweight Grave",28:"Names in the Bell",29:"Spare Lung"}
const L=preload("res://src/campaign/encounters/iron_layouts.gd")
# 094: authored approach posts reward planning, tools and parallel work.
# FLEET_PRESSURE=false restores reserve/briefing data; revert the roster diff separately.
# Combat and sensing rules are unchanged.
const FLEET_PRESSURE=true
const OXYGEN={22:420.,23:520.,24:520.,25:460.,26:320.,27:480.,28:360.,29:600.}
const FLEET_BRIEF={22:"Send a drone ahead to the lane gate while Quietus releases the freight. The west return patrol watches the unloaded approach; plan a short crossing or spend Disrupt.",23:"Stage drones at the upper equalizers while Quietus opens the lower stair. Each valve still needs its own depth. The middle post hears LOCK A; clear west after the valve before climbing the open shutter.",24:"A traction-yoke drone can tow through the service slit while Quietus scouts the receiving socket. Bare towing takes the outside circuit; a southern post watches the long outside tow.",25:"Send a drone to service the berth while Quietus reaches the release. Keep the escort close while the occupied sled passes the industrial guards.",26:"A drone can winch and return the spindle while Quietus watches the recovery approach. The middle approach is patrolled; dive before the post and plan the surfaced return.",27:"Stage a drone at the cradle for the exposed core while Quietus tows and chocks the counterweight. A post watches the pickup and recovery water; use the wide southern approach and return the real carrier.",28:"Tow the bell with Quietus and stage a drone at each mandatory stop. The nearby drone works while the bell stays at the station, leaving Quietus free to defend.",29:"Stage Quietus at RECONNECT and send a drone to throw the far breaker. A southern post watches the breaker-to-plant traverse; disruption widens the crossing."}
const T=preload("res://src/campaign/encounters/terrain.gd")
const ACCOUNTS={
 22:"Foreman Dale Rill / Hollins Field's hammer sled is stalled, not abandoned. Release it and beat it down its lane: it jams against the shut lane gate and takes damage until you work that gate. West lane gate is LOCK A, east is LOCK B.",
 23:"Lock keeper Nera Ash / Cycle LOCK A, then B, then C: each equalizer opens the next shutter at its own depth. A crowned warden charges pressure from received evidence; wait out its discharge or break its acquisition.",
 24:"Rill / The ballast is the switch. Tow it to BYPASS to restore the short passage and keep the reporting bus supplied, or to ISOLATE to cut the bus and keep the long outside water. The first recovered placement commits the last shift's route.",
 25:"Nera / Escort the last shift's evacuation sled to its dock: it only advances while a craft stays within 200m, and it holds the moment you leave. Choose the east shipping dock or the west service dock, then watch it arrive.",
 26:"Rill / Lift the pressure spindle from the deep sump. Lifting restarts the hammer and the west mouth seals in 100s, so leave by the mouth or work COOLING for the south return. Recover the physical spindle.",
 27:"Nera / A loose counterweight slides back downhill. Tow it up to the ledge, chock it at LOCK A, tow it on to the cradle, then winch the exposed traction core.",
 28:"Rill / The occupied bell must be towed through the S passage with two decompression stops at LOCK A and LOCK B, then landed at the western dock. Bare Quietus can tow the bell; its stops remain exposed to industrial guards.",
 29:"Nera / Two sites, one window. Throw the far breaker LOCK C, then RECONNECT the plant within 150s; or DISMANTLE the security feed in the west room alone. Recover your chosen local work account."}
static func supports_config(c:Dictionary)->bool:return c.size()==2 and c.get("history")==true and c.get("source_id",-1) in TITLES
static func supports_identity(id:int,c:Dictionary)->bool:return id==c.source_id
static func site(id:String,pos:Vector2,band:int=1,shape:Rect2=Rect2())->Dictionary:return {"id":id,"pos":pos,"band":band,"shape":shape,"done":false}
static func body(pos:Vector2,kind:String)->Dictionary:
 return {"pos":pos,"vel":Vector2.ZERO,"angle":0.,"route":[],"alive":true,"hull":100.,"silent":true,"name":kind.to_upper(),"band":1,"transition":{},"kind":kind,"state":"moored","carrier":-1,"trail":[]}
static func build(c:Dictionary,history:Dictionary={})->Dictionary:
 if not supports_config(c):return {}
 var id=c.source_id;var start=Vector2(300,2350)
 var m={"id":id,"title":TITLES[id],"depth":4600,"darkness":false,"region_revision":1,"world_size":Vector2(3000,2720),"start":start,"extraction":start,"rocks":[],"structures":[],"sirens":[],"acoustic_revision":1,"expedition_revision":2,"signal_sources":[],"signal_observations":[],"expedition_facts":{},"next_signal_time":0.,"chosen_route":"","recovered":false,"withdrawal_armed":false,"required_site_ids":[],"launch_context":history.duplicate(true),"endurance":{"oxygen_seconds":1000.,"drone_seconds":720.},"record":ACCOUNTS[id],"objectives":[],"corridors":[{"pos":start,"name":"CHOIR SOUTH RECOVERY","route":"deep"}]}
 if FLEET_PRESSURE:m.endurance.oxygen_seconds=OXYGEN[id]
 T.apply(m,L.entries(id))
 var state={"sites":[],"jobs":[{},{},{}],"load":{},"seen":{},"choice":"","arrived":false,"receipt":false,"artifact":{},"retrieved":false,"route_choice":"","people_landed":false,"stamp":-1.,"sealed":false}
 match id:
  22:
   state.load=body(Vector2(750,2100),"freight sled");state.sites=[site("release",Vector2(750,2050)),site("lock_a",Vector2(1800,390)),site("lock_b",Vector2(2800,1300))]
  23:
   state.sites=[site("lock_a",Vector2(650,1900),1,Rect2(500,1750,300,70)),site("lock_b",Vector2(1250,1350),0,Rect2(1180,1160,500,70)),site("lock_c",Vector2(2400,650),2,Rect2(2250,450,400,70))]
  24:
   state.load=body(Vector2(750,2100),"ballast");state.sites=[site("bypass",Vector2(2450,500)),site("isolate",Vector2(2500,1850))]
  25:
   state.load=body(Vector2(750,2100),"occupied evacuation sled");state.sites=[site("release",Vector2(750,2050)),site("service",Vector2(750,600),1,Rect2(600,450,300,70))]
   if history.get("facts",{}).get("choir_choice","")=="bypass" or history.get("facts",{}).get("choir_people","")=="landed":state.sites[1].done=true
  26:
   state.sites=[site("cooling",Vector2(1400,600),2,Rect2(1300,700,350,70))]
   state.artifact={"id":"pressure_spindle","pos":Vector2(1450,500),"band":2,"state":"site","carrier":-1}
  27:
   state.load=body(Vector2(750,1750),"counterweight");state.sites=[site("lock_a",Vector2(750,1250)),site("cradle",Vector2(1250,700))]
   state.artifact={"id":"traction_core","pos":Vector2(1250,650),"band":1,"state":"sealed","carrier":-1}
  28:
   state.load=body(Vector2(750,2100),"occupied maintenance bell");state.sites=[site("lock_a",Vector2(650,1250)),site("lock_b",Vector2(900,850)),site("land",Vector2(700,500))]
  29:state.sites=[site("lock_c",Vector2(700,2250)),site("reconnect",Vector2(2450,500)),site("dismantle",Vector2(700,1250))]
 for work in state.sites:
  if work.shape.has_area() and not work.done:m.structures.append(work.shape)
 m.structures.append_array(L.structures(id))
 m.iron_choir=state
 # A staffed berth removes the long service detour, so its authored air load is smaller.
 if FLEET_PRESSURE and id==25 and state.sites[1].done:m.endurance.oxygen_seconds=320.
 if id==25:
  if history.get("facts",{}).get("choir_plant","")=="reconnect":
   m.currents=[{"center":Vector2(650,1300),"radius":650.,"velocity":Vector2(0,-12)}];m.thermal_revision=1;m.thermal_fronts=[{"area":Rect2(400,600,450,1450),"transmission":.55,"close_range":90.}]
  m.record+=" Recovered workers staff the service berth." if history.get("facts",{}).get("choir_people","")=="landed" else " No recovered crew landing is assumed; local manual service is available."
 L.roster(m,id,history)
 m.brief=ACCOUNTS[id]+("\n"+FLEET_BRIEF[id] if FLEET_PRESSURE else "")+"\nCraft → CHOIR WORK, or tap acquired machinery/load. All work is local and interruptible; peer selection does not move equipment or cargo. Manual Quietus towing uses wide water; a fitted drone yoke buys a narrower slower noisy load route. Release a tow before changing depth. No receiver exposure substitutes for physical work. The south recovery mouth stays available after the job."
 return m
