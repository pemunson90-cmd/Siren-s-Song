extends RefCounted
const Patrol=preload("res://src/campaign/divergence_missions.gd")
const TITLES={22:"Hammerwake",23:"Pressure Stair",24:"Choir Cut",25:"Last Shift",26:"The Cold Hammer",27:"Counterweight Grave",28:"Names in the Bell",29:"Spare Lung"}
const ROCKS={
 22:[Rect2(1050,700,450,1100),Rect2(1800,800,450,1000),Rect2(1500,1050,300,400)],
 23:[Rect2(800,550,400,700),Rect2(1400,1450,450,750),Rect2(1900,550,450,400)],
 24:[Rect2(1100,700,450,1400),Rect2(1850,700,400,650),Rect2(2250,1100,350,250)],
 25:[Rect2(1000,800,500,1000),Rect2(1800,650,500,750),Rect2(1900,1850,600,250)],
 26:[Rect2(900,500,400,1500),Rect2(1650,850,550,400),Rect2(1800,1700,450,450)],
 27:[Rect2(1000,1000,550,450),Rect2(1700,500,450,1400),Rect2(2300,1350,300,350)],
 28:[Rect2(1100,600,450,1250),Rect2(1850,1150,550,400),Rect2(1700,650,500,250)],
 29:[Rect2(900,900,650,500),Rect2(1750,600,450,1200),Rect2(2250,1700,400,400)]}
const ACCOUNTS={
 22:"Foreman Rill / The hammer train is stalled, not abandoned. Release its actual sled by the western service lane or the eastern shipping lane, observe the dock arrival, then bring your account home. The forked interceptors commit to what they last acquired; change your water during their windup.",
 23:"Lock keeper Nera / Three equalizers vent into separate pressure locks. Work them in any safe sequence; shutters truly open. A crowned warden charges local pressure from received evidence. Wait out its finite discharge, break its acquisition or use another band. Quietus alone can cycle every lock.",
 24:"Rill / The ballast is the switch. Tow it to BYPASS to restore the short gallery and leave the reporting bus supplied, or to ISOLATE to cut the bus and keep the long outside water. The first recovered placement commits Last Shift's actual route and relay support.",
 25:"Nera / Last shift is aboard the evacuation sled. Deliberately choose its east shipping refuge or west service refuge. No departure countdown runs before your order. Watch its actual arrival; the course announcement is not a tracker. Your returned ballast, people and plant accounts change local water, not distant fate.",
 26:"Rill / A pressure spindle rests in the deep cooling sump. A local noisy release opens the direct return; the longer outside passage needs no release. Recover the physical spindle, not its photograph. Our hammer measurements can turn it into a faster but louder pressure sleeve.",
 27:"Nera / Move the grounded counterweight to its receiving cradle, then winch the exposed traction core. Our pressure-lock measurements and the recovered material can build one drone traction yoke. A yoke steadies a load through service water; it cannot move a remote load.",
 28:"Rill / The maintenance bell is occupied. Attach locally, tow it through real water and LAND it at the western refuge. A returned landing account staffs Last Shift's west service berth. Quietus can carry the job alone; a fitted drone frees its pilot to scout.",
 29:"Nera / Reconnect the plant and Last Shift gains a current-assisted masked gallery, but its reporting feed stays alive. Dismantle the security feed and the powered western warden goes dark; no remote shield appears. Recover your chosen local work account."}
static func supports_config(c:Dictionary)->bool:return c.size()==2 and c.get("history")==true and c.get("source_id",-1) in TITLES
static func supports_identity(id:int,c:Dictionary)->bool:return id==c.source_id
static func site(id:String,pos:Vector2,band:int=1,shape:Rect2=Rect2())->Dictionary:return {"id":id,"pos":pos,"band":band,"shape":shape,"done":false}
static func body(pos:Vector2,kind:String)->Dictionary:
 return {"pos":pos,"vel":Vector2.ZERO,"angle":0.,"route":[],"alive":true,"hull":100.,"silent":true,"name":kind.to_upper(),"band":1,"transition":{},"kind":kind,"state":"moored","carrier":-1,"trail":[]}
static func build(c:Dictionary,history:Dictionary={})->Dictionary:
 if not supports_config(c):return {}
 var id=c.source_id;var start=Vector2(300,2350)
 var m={"id":id,"title":TITLES[id],"depth":4600,"darkness":false,"region_revision":1,"world_size":Vector2(3000,2720),"start":start,"extraction":start,"rocks":ROCKS[id].duplicate(true),"structures":[],"sirens":[],"acoustic_revision":1,"expedition_revision":2,"signal_sources":[],"signal_observations":[],"expedition_facts":{},"next_signal_time":0.,"chosen_route":"","recovered":false,"withdrawal_armed":false,"required_site_ids":[],"launch_context":history.duplicate(true),"endurance":{"oxygen_seconds":1000.,"drone_seconds":720.},"record":ACCOUNTS[id],"objectives":[],"corridors":[{"pos":start,"name":"CHOIR SOUTH RECOVERY","route":"deep"}]}
 m.depth_geometry={0:{"rocks":ROCKS[id].slice(1)},2:{"rocks":ROCKS[id].slice(0,2)}}
 var state={"sites":[],"jobs":[{},{},{}],"load":{},"seen":{},"choice":"","arrived":false,"receipt":false,"artifact":{},"retrieved":false,"route_choice":"","people_landed":false}
 match id:
  22:
   state.load=body(Vector2(750,2100),"freight sled");state.sites=[site("release",Vector2(750,2050))]
  23:
   state.sites=[site("lock_a",Vector2(650,1900),1,Rect2(500,1750,300,70)),site("lock_b",Vector2(1250,1350),1,Rect2(1180,1160,500,70)),site("lock_c",Vector2(2400,650),1,Rect2(2250,450,400,70))]
  24:
   state.load=body(Vector2(750,2100),"ballast");state.sites=[site("bypass",Vector2(2450,500)),site("isolate",Vector2(2500,1850))]
  25:
   state.load=body(Vector2(750,2100),"occupied evacuation sled");state.sites=[site("release",Vector2(750,2050)),site("service",Vector2(750,600),1,Rect2(600,450,300,70))]
   if history.get("facts",{}).get("choir_choice","")=="bypass" or history.get("facts",{}).get("choir_people","")=="landed":state.sites[1].done=true
  26:
   state.sites=[site("cooling",Vector2(1400,600),2,Rect2(1300,700,350,70))]
   state.artifact={"id":"pressure_spindle","pos":Vector2(1450,500),"band":2,"state":"site","carrier":-1}
  27:
   state.load=body(Vector2(750,1750),"counterweight");state.sites=[site("cradle",Vector2(1250,700))]
   state.artifact={"id":"traction_core","pos":Vector2(1250,650),"band":1,"state":"sealed","carrier":-1}
  28:
   state.load=body(Vector2(750,2100),"occupied maintenance bell");state.sites=[site("land",Vector2(700,500))]
  29:state.sites=[site("reconnect",Vector2(2450,500)),site("dismantle",Vector2(2450,500))]
 for work in state.sites:
  if work.shape.has_area() and not work.done:m.structures.append(work.shape)
 if id==24:m.structures.append_array([Rect2(1550,1400,100,600),Rect2(1700,1400,150,600)])
 if id==25:m.structures.append_array([Rect2(1500,1400,100,350),Rect2(1650,1400,150,350)])
 m.iron_choir=state
 if id==25:
  if history.get("facts",{}).get("choir_plant","")=="reconnect":
   m.currents=[{"center":Vector2(650,1300),"radius":650.,"velocity":Vector2(0,-12)}];m.thermal_revision=1;m.thermal_fronts=[{"area":Rect2(400,600,450,1450),"transmission":.55,"close_range":90.}]
  m.record+=" Recovered workers staff the service berth." if history.get("facts",{}).get("choir_people","")=="landed" else " No recovered crew landing is assumed; local manual service is available."
 Patrol._patrol(m,Vector2(1600,2200),[Vector2(1600,2200),Vector2(1650,2300)]);m.sirens[-1].type="interceptor";m.sirens[-1].band=1
 Patrol._patrol(m,Vector2(2450,1500) if id==24 else Vector2(2450,1200),[]);m.sirens[-1].type="warden";m.sirens[-1].band=2 if id in [23,26] else 1
 if id in [24,25]:
  Patrol._patrol(m,Vector2(1650,550),[]);m.sirens[-1].type="relay"
  if id==25 and history.get("facts",{}).get("choir_choice","")=="isolate":m.sirens.pop_back()
 if id==25 and history.get("facts",{}).get("choir_plant","")=="dismantle":m.sirens.remove_at(1)
 m.brief=ACCOUNTS[id]+"\nCraft → CHOIR WORK, or tap acquired machinery/load. All work is local and interruptible; peer selection does not move equipment or cargo. Manual Quietus towing uses wide water; a fitted drone yoke buys a narrower slower noisy load route. Release a tow before changing depth. No receiver exposure substitutes for physical work. The south recovery mouth stays available after the job."
 return m
