extends RefCounted
const Patrol=preload("res://src/campaign/divergence_missions.gd")
const TITLES={14:"Glass Fence",15:"Needle Strait",16:"Furnace Drift",17:"Silt Archive",18:"Lantern Lock",19:"Last Boat Out",20:"Prism Grave",21:"Range Locker"}
const ROCKS={
 14:[Rect2(700,500,300,1250),Rect2(1440,350,300,1450),Rect2(1000,1100,440,240)],
 15:[Rect2(650,250,360,1400),Rect2(1370,750,380,1400),Rect2(1020,1650,350,180)],
 16:[Rect2(550,600,400,500),Rect2(1200,350,600,400),Rect2(1100,1450,700,350)],
 17:[Rect2(600,500,1200,350),Rect2(700,1250,1050,350),Rect2(950,850,300,400)],
 18:[Rect2(600,500,350,1300),Rect2(1450,650,400,1100),Rect2(950,650,500,200)],
 19:[Rect2(600,500,350,1400),Rect2(1450,500,350,1400),Rect2(950,1200,500,300)],
 20:[Rect2(550,600,550,400),Rect2(1400,400,350,1200),Rect2(700,1500,450,300)],
 21:[Rect2(700,350,400,1250),Rect2(1400,700,450,400),Rect2(1100,1650,700,250)]}
const RECORD_POS={14:Vector2(380,400),15:Vector2(2000,450),16:Vector2(2000,1250),17:Vector2(2000,1000),18:Vector2(1150,450),19:Vector2(2000,350),20:Vector2(1250,1250),21:Vector2(2000,1450)}
const WORK_POS={15:Vector2(1200,450),17:Vector2(2000,1050),18:Vector2(1150,450),19:Vector2(1200,800),20:Vector2(1250,1250),21:Vector2(2000,1450)}
const ACCOUNTS={
 14:"Dr. Tomas Vey / These floats are the Varne range's hydrophone fence. They listen to engines, not loyalties. Their lamps rise before a report. Deep water under the western teeth gives a slow quiet passage; the central opening is shorter and watched.",
 15:"Vey / The shallow strain vanes hold the listening fence taut. Release one locally and the western strait falls quiet. Deep water bypasses the vane wall but reaches the eastern repeater. A disabled listener cannot finish its charged report.",
 16:"Vey / This thermal atlas belongs to the range's cooling plant. The crossflow carries hot exhaust and sound around the central piers. Take the measured atlas home; its material spectrum may explain the prisms in the western wreck field.",
 17:"Vey / The archive spindle is the range's physical record. Its reception note is not the spindle itself. Winch it to a living craft and bring that carrier to recovery; losing the carrier leaves the same spindle in that water.",
 18:"Vey / The sealed habitat's lock needs its service bus. Restore the sheltered passage and the survivors can use the short water, but the listening relay stays supplied. Sever the reporting spur and the fence loses the channel; they take the longer outside passage. Quietus must carry the selected station account home.",
 19:"Vey / The last boat's local register is received. It names one boat out, not every vessel beyond the Reach. Cross the listening chain, hear the northern register, and choose either physical recovery mouth.",
 20:"Vey / A cracked directional prism remains in the grave. A photograph identifies it; only the recovered crystal supplies the material. The furnace atlas lets us cut one Quietus fitting: greater directional reach at higher pulse cost and a shared hardware slot.",
 21:"Vey / The range's service wafer is still in its sealed locker. Recover that material with the silt ledger and we can cut a local decoder. It opens a measured service gate quietly from nearby; it is no remote authority over the network."}
static func supports_config(c:Dictionary)->bool:return c.size()==2 and c.get("history")==true and c.get("source_id",-1) in TITLES
static func supports_identity(id:int,c:Dictionary)->bool:return id==c.source_id
static func build(c:Dictionary,history:Dictionary={})->Dictionary:
 if not supports_config(c):return {}
 var id=c.source_id;var pos=RECORD_POS[id];var key="glass_record_"+str(id)
 var m={"id":id,"title":TITLES[id],"depth":4100,"darkness":false,"region_revision":1,"world_size":Vector2(2400,2400),"start":Vector2(250,2100),"extraction":Vector2(250,2100),"rocks":ROCKS[id].duplicate(true),"structures":[],"sirens":[],"acoustic_revision":1,"expedition_revision":2,"signal_sources":[],"signal_observations":[],"expedition_facts":{},"next_signal_time":0.,"chosen_route":"","recovered":false,"withdrawal_armed":false,"required_site_ids":[key],"launch_context":history.duplicate(true),"endurance":{"oxygen_seconds":720.,"drone_seconds":480.},"record":ACCOUNTS[id]}
 m.objectives=[{"pos":pos,"name":TITLES[id].to_upper()+" / RECEIVED ACCOUNT","site_id":key,"captured":false,"kind":"receiver","required_unit":0,"duration":6. if id==19 else 4.,"optical":key,"evidence":ACCOUNTS[id]}]
 m.corridors=[{"pos":m.extraction,"name":"SOUTH REACH RECOVERY","route":"deep"}]
 if id==19:m.corridors.append({"pos":Vector2(2150,2150),"name":"EAST REACH RECOVERY","route":"shelf"})
 m.depth_geometry={0:{"rocks":ROCKS[id].duplicate(true)},2:{"rocks":ROCKS[id].duplicate(true)}}
 # Each layer changes an actual crossing, while the outside water stays open.
 m.depth_geometry[2].rocks.remove_at(0)
 m.depth_geometry[0].rocks.remove_at(1)
 m.depth_geometry[0].rocks.append(Rect2(950,1800,500,150))
 m.glass_reach={"work_pos":WORK_POS.get(id,pos),"job":{},"choice":"","gate_open":false,"artifact":{},"retrieved":false}
 if id in [17,20,21]:
  m.glass_reach.artifact={"id":{17:"silt_spindle",20:"prism_core",21:"keeper_wafer"}[id],"pos":WORK_POS[id],"band":1,"state":"site","carrier":-1}
 if id in [18,19]:
  m.glass_reach["gate"]=Rect2(1020,900,360,120);m.structures.append(m.glass_reach.gate)
 if id==16:
  m.currents=[{"center":Vector2(1200,1200),"radius":1800.,"velocity":Vector2(14,6)}]
  m.thermal_revision=1;m.thermal_fronts=[{"area":Rect2(950,750,450,680),"transmission":.45,"close_range":90.}]
 if id==19:
  var prior=history.get("facts",{}).get("glass_choice","")
  if prior=="service":m.structures.clear();m.glass_reach.gate_open=true
  m.record+=" The recovered Lantern Lock account left the service water open." if prior=="service" else " Lantern Lock's reporting spur was severed; the outer return remains available." if prior=="sever" else " No recovered anchorage choice is assumed."
 # The network occupies the tempting inner water, with an armed investigator nearby.
 var guard={14:Vector2(1200,1550),16:Vector2(1850,1850),17:Vector2(1300,1750),20:Vector2(1250,1850),21:Vector2(1950,1900)}.get(id,Vector2(1200,1550))
 Patrol._patrol(m,guard,[guard,guard+Vector2(80,0),guard+Vector2(0,100)])
 m.sirens[0].band=1;m.sirens[0].type="sentinel";m.sirens[0].tether=160.
 Patrol._patrol(m,Vector2(1200,1950),[]);m.sirens[-1].type="buoy";m.sirens[-1].band=1
 Patrol._patrol(m,Vector2(1400,2050) if id==21 else Vector2(1250,2050),[]);m.sirens[-1].type="relay";m.sirens[-1].band=2 if id in [15,16,21] else 1
 if id==19 and history.get("facts",{}).get("glass_choice","")=="sever":m.sirens.pop_back()
 if id in [15,21]:
  Patrol._patrol(m,Vector2(1850,2200),[]);m.sirens[-1].type="hunter";m.sirens[-1].band=2
 if id in [16,19]:
  Patrol._patrol(m,Vector2(1850,1900),[]);m.sirens[-1].type="sweeper";m.sirens[-1].band=2
 m.brief=ACCOUNTS[id]+"\nKeep Quietus and its account together. Local records and machinery work in settled MIDDLE. The bare outside water avoids the central network; other bands open shorter inner crossings. Buoys hear real engines and emissions; relays forward stale uncertain reports after a charge. Quiet, masking, terrain, depth, relocation or physical disruption can break that chain. Return to a named recovery mouth."
 if id in [15,18,19]:m.brief+=" Tap a craft → REACH WORK for local machinery. Manual work takes8 audible seconds; a recovered fitted decoder can open the18/19 service gate quietly."
 if id in [17,20,21]:m.brief+=" Tap the marked material → RECOVER, or craft → REACH WORK. Winch4s within60m; carriers must recover in MIDDLE within65m of the chosen mouth, or transfer locally to Quietus. A lost carrier leaves its physical cargo at the lost position."
 if id==18:m.brief+=" REACH WORK offers RESTORE SERVICE or SEVER SPUR. First recovery commits the real consequence in Last Boat Out."
 var prior=history.get("facts",{}).get("resolution","")
 if not prior.is_empty():m.brief+=" Previous received outcome: "+{"concealed_recovery":"Kestrel's survivors were carried out by craft.","overt_warning":"Brannock's launch reached the northeast pickup."}.get(prior,"the earlier local account remains in the archive.")
 return m
