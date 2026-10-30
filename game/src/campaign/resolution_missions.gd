extends RefCounted
# S3 PLACEHOLDERS (bible silent): unnamed "Kestrel sonar operator" witness role, "old ridge survey repeater" (service sluice), "old tracking float" (deep trace), a wrecked rig with a still-calling beacon (op 9 decoy), plant frames/feed line and a moving load in ops 3 and 5 (mechanics need an object, bible silent), the shelf variant's screen/baffle mechanic mapped onto the bunker blast-door approach, Brannock launch pickup. Aesthetics pass later.
# Working fiction. Registry, recovered-thread commits and runtime hooks belong
# to the campaign owner; this module consumes their recovered launch context.
const Witness=preload("res://src/simulation/witness_evacuation.gd")
const Recipient=preload("res://src/simulation/warning_recipient.gd")
const IDS=[11,12,13]
const FIELD_RECORDS=["divergence_confluence_packet","divergence_confluence_repeater","divergence_witness_packet","resolution_witness_sluice","resolution_warning_transmission","divergence_warning_reply"]

static func available(history:Dictionary)->Array:
 var completed=history.get("completed",[]);var facts=history.get("facts",{})
 if not completed is Array or not facts is Dictionary:return []
 if not (9 in completed or 10 in completed):return []
 var jobs=[11]
 if 11 in completed:
  if facts.get("confluence_route","")=="concealed":jobs.append(12)
  elif facts.get("confluence_route","")=="overt":jobs.append(13)
 return jobs

static func resolution(mission:Dictionary)->String:
 if not mission.get("recovered",false):return ""
 var id=mission.get("id",-1)
 if id==12 and (mission.get("witness_evacuation",{}).get("state","")!="landed" or preload("res://src/simulation/concealed_harbour.gd").recovered_facts(mission).is_empty()):return ""
 if id==13 and not mission.get("warning_recipient",{}).get("receipt",false):return ""
 var required=["witness_packet"] if id==12 else (["warning_transmission","warning_reply"] if id==13 else [])
 if required.is_empty():return ""
 var sites=mission.get("objectives",[])
 for site_id in required:
  if not sites.any(func(site):return site.get("site_id","")==site_id and site.get("captured",false)):return ""
 return "concealed_recovery" if id==12 else "overt_warning"

static func make(index:int,history:Dictionary={})->Dictionary:
 if index not in IDS:return {}
 var m=_base(index,history)
 if index==11:
  _confluence(m)
  preload("res://src/campaign/encounters/terrain.gd").seed_chart(m)
 elif index==12:_concealed(m)
 else:_overt(m)
 return m

static func _base(index:int,history:Dictionary)->Dictionary:
 var context={"thread":history.get("thread",""),"completed":history.get("completed",[]).duplicate(),"facts":history.get("facts",{}).duplicate(true),"references":history.get("references",{}).duplicate(true)}
 return {"id":index,"title":{11:"Confluence",12:"The Concealed Record",13:"The Open Warning"}[index],"depth":{11:4720,12:5180,13:3420}[index],"darkness":index==12,"world_size":Vector2(2400,2800),"region_revision":1,"acoustic_revision":1,"expedition_revision":2,"resolution_revision":1,"launch_context":context,"objectives":[],"sirens":[],"signal_sources":[],"signal_observations":[],"expedition_facts":{},"next_signal_time":0.0,"chosen_route":"","recovered":false,"withdrawal_armed":false,"required_site_ids":[]}

static func _confluence(m:Dictionary)->void:
 preload("res://src/campaign/confluence_region.gd").build(m)

static func _concealed(m:Dictionary)->void:
 m["witness_evacuation"]=Witness.initial()
 m.world_size=Vector2(2400,3000);m.start=Vector2(2060,2680);m.extraction=Vector2(2260,2700)
 m.rocks=[Rect2(720,2160,940,240),Rect2(1900,2160,600,240),Rect2(920,600,350,1200),Rect2(-100,1500,620,230),Rect2(1500,1300,900,180),Rect2(1320,360,340,420),Rect2(300,300,180,260)]
 var gate=Rect2(1660,2160,240,240)
 m.physical_gates=[{"id":"witness_service_sluice","closed_shape":gate,"site_id":"witness_sluice","opened":false}];m.structures=[gate]
 m.signal_sources=[_source("witness_packet","OCCUPIED WITNESS CAPSULE",Witness.BERTH,"Kestrel's escape capsule waits at the witness berth, sailors alive inside. Local WINCH loads it onto a real fleet craft; LAND it at the southeast lift point. Carrier loss ejects this same sealed pod for local recovery.",[.8,1.6,.8])]
 var actuator=_receiver("witness_sluice","SERVICE SLUICE CONTROL",Vector2(1780,2040),"The local actuator retracts the man-made service sluice. Its finite motor run is audible; the open passage changes the return route without silencing or ordering any patrol.")
 actuator.merge({"optional":true,"completion_open_structure":"witness_service_sluice","completion_emission":{"radius":1100.0,"label":"SERVICE SLUICE MOTOR","duration":8.0}});m.objectives=[actuator]
 m.required_site_ids=["witness_packet"]
 preload("res://src/simulation/concealed_harbour.gd").build(m)
 m.corridors=[{"pos":m.extraction,"name":"CONCEALED RECOVERY BASIN","route":"concealed"}]
 m.brief="Confluence's concealed passage leads to Kestrel's escape capsule beyond the southern overhang. WINCH its occupied witness capsule onto Quietus or either bare drone: settle below 2m/s within 60m with clear line of sight for one audible four-second winch. Carry the living witness to the southeast basin and explicitly LAND WITNESS there; Quietus must also return. If a carrier is lost, its sealed pressure pod ejects at that own-craft position and the same witness can be winched aboard another craft. The occupied pod remains sealed for recovery. Recovered kit at the same wreck shares that single winch. The long western detour works with the service sluice shut and needs no transmission or machinery. Alternatively, operate the charted SERVICE SLUICE CONTROL on its north side: an audible motor permanently opens the man-made passage for a shorter return. It never closes or crushes craft. Quietus can operate it in four seconds; a fitted drone sampler can work independently in eight audible seconds, if it survives. The actuator is optional and does not replace the witness. Decide whether the changed route is worth making the machinery heard, then bring the occupied capsule home. Active tools remain available; no hidden purity score invalidates recovery."
 m.brief+=" Kestrel's sonar operator knows what holds the trench mouth: an old tracking float, still sending. Reserve air to act on her account before bringing the capsule home." if m.concealed_harbour.thread=="deep" else " Kestrel's sonar operator identifies the collapsed screen at Port Ardent. On Quietus use ATTACH TOW, tow it to a named cradle, then SEAT HERE to clear the service mouth or baffle the north entrance. Receive the bunker watch's reply; there is no separate CUT order."
 m.record="The sailors' account returns without being forwarded through the warning chain. The service sluice, if opened, remains an actual route through the overhang; the unannounced western detour remains a valid alternative. This resolves the concealed operation, not who else is still down there."
 _patrol(m,Vector2(700,1140),[Vector2(700,1140),Vector2(700,700),Vector2(780,480),Vector2(820,1900)])
 _patrol(m,Vector2(1780,1780),[Vector2(1780,1780),Vector2(2100,1780),Vector2(2100,1580),Vector2(1380,1580)])
 m.sirens[1].type="sentinel";m.sirens[1]["tether"]=190.0
 if m.concealed_harbour.thread=="shelf":
  var watch=m.sirens[1];watch.pos=Vector2(1320,1070);watch.home=watch.pos;watch.goal=watch.pos;watch.patrol_points=[watch.pos]
  m.brief+=" A Siren sentinel listens outside the bunker approach. The western return has a moving patrol."
 else:m.brief+=" A Siren sentinel holds the water north of the sluice; the western route has a moving patrol."

static func _overt(m:Dictionary)->void:
 m["warning_recipient"]=Recipient.initial()
 m.world_size=Vector2(2800,2600);m.start=Vector2(420,2320);m.extraction=Vector2(2420,240)
 m.rocks=[Rect2(1080,980,600,860),Rect2(100,700,700,220),Rect2(1960,800,940,220),Rect2(1000,-100,500,400),Rect2(280,1530,500,220),Rect2(1880,1880,520,200)]
 # A real sheltered berth prevents a forced pre-release escort timer. The
 # western access remains open to a bare Quietus; east transit leaves cover.
 m.rocks.append_array([Rect2(1600,520,500,100),Rect2(1600,340,80,60),Rect2(1600,240,200,100),Rect2(1960,240,260,100),Rect2(2100,340,100,280)])
 m.physical_gates=[{"id":"warning_service_gate","site_id":"warning_service","closed_shape":Recipient.GATE,"opened":false}];m.structures=[Recipient.GATE]
 var sector=Rect2(300,1000,2200,700)
 m.objectives=[{"site_id":"warning_transmission","name":"WARNING TRANSMISSION SECTOR","pos":Vector2(500,1120),"kind":"transmitter","own_origin":true,"origin_region":sector,"required_unit":0,"duration":6.0,"captured":false,"unit_requirement":"Quietus must carry and transmit the recovered warning.","optical":"resolution_warning_transmission","evidence":"Quietus sends Kestrel's position and air count from its chosen spot. A receiver on the surface begins to answer; the reply proves the call was heard, not that the water is safe. Every second of the transmission is loud.","completion_emission":{"radius":2000.0,"label":"WARNING CHAIN TRANSMISSION","duration":8.0},"completion_enable_source":"warning_reply"}]
 var reply=_source("warning_reply","LOCAL WARNING ACKNOWLEDGEMENT",Vector2(1840,440),"Brannock's boat acknowledges the call. Its waiting launch can take the exposed eastern crossing or the sheltered north service route; sailing remains a separate order.",[1.2,.6,1.2]);reply.active=false;m.signal_sources=[reply]
 # 097 / patterns 1,2: these already registered accounts are optional work.
 # A sampler drone can collect the approach record and work the service gate
 # while Quietus carries out the transmission and the initial reply itself.
 var west=_receiver("warning_west","WEST CABLE SERVICE ACCOUNT",Vector2(700,2100),"The shore cable's western service account records the launch crew's reserve power, independently of the transmitted warning.")
 west.optional=true
 m.objectives.append(west)
 var pickup=_receiver("warning_uplink","PICKUP SERVICE ACCOUNT",m.extraction,"The pickup station receives the launch crew's local service account after the crossing.")
 m.objectives.append(pickup)
 m.required_site_ids=["warning_transmission","warning_reply"]
 m.corridors=[{"pos":m.extraction,"name":"NORTHEAST WARNING RECOVERY","route":"overt"}]
 m.brief="Kestrel's position is aboard. Choose Quietus’s transmission origin inside the charted sector; settle and use CAMERA / TRANSMIT for six seconds. The 2000m call follows actual water paths: a completed emission can miss behind terrain, so reposition and retry if no reply arrives. Find the local acknowledgement by received bearings or close observation, then receive it with Quietus. Brannock's unarmored launch waits in the northern breakwater berth. It never leaves automatically. Tap its measured hull and deliberately choose EXPOSED, an ungated passage around the south breakwater into the eastern watch, or SHELTERED, a shorter route through the north service gate. Open that physical gate locally within 60m, clear line and below 2m/s; its release is audible 650m for six seconds. An earned Warning Chain service receipt can instead ride this newly received warning to operate the connected gate. Bare Quietus needs no proof, fitted kit or finite tool for the manual sheltered route. Drones can scout, release the gate, protect the launch or observe its arrival; Quietus must transmit, receive the initial reply and recover independently. Protect the recipient’s actual hull with terrain or finite tools. Receive its real arrival at the northeast pickup and recover Quietus there. Recipient destruction fails the dive; retry remains available. Announced courses are plans, never live tracking."
 m.record="The call reached Brannock's launch. It made the chosen crossing to the northeast pickup, and Quietus recovered after hearing it arrive. The call was loud, and everything on the shelf heard it."
 m.brief+=" LISTEN at PICKUP SERVICE ACCOUNT to bring the launch crew's account aboard. The optional WEST CABLE SERVICE ACCOUNT can be received by Quietus or a fitted sampler drone while another craft works the warning and gate."
 _patrol(m,Vector2(760,1140),[Vector2(760,1140),Vector2(460,1140),Vector2(460,1460),Vector2(900,1460)])
 _patrol(m,Vector2(2020,1340),[Vector2(2020,1340),Vector2(1840,1520),Vector2(2320,1520),Vector2(2320,1120)])
 _patrol(m,Vector2(2260,440),[Vector2(2260,440)])
 m.sirens[1].type="hunter"
 m.sirens[2].type="sentinel";m.sirens[2]["tether"]=190.0
 m.brief+=" An eastern Siren hunter reacts to local evidence while a sentinel holds the northern basin."

static func _source(id:String,label:String,pos:Vector2,evidence:String,cadence:Array,confirm:bool=true)->Dictionary:
 return {"id":id,"label":label,"pos":pos,"optical":"divergence_"+id,"evidence":evidence,"located":false,"cadence":cadence,"confirm":confirm,"sampler_compatible":confirm}

static func _receiver(id:String,label:String,pos:Vector2,evidence:String)->Dictionary:
 return {"site_id":id,"name":label,"pos":pos,"kind":"receiver","required_unit":0,"duration":4.0,"captured":false,"sampler_compatible":true,"optical":"resolution_"+id,"evidence":evidence}

static func _patrol(m:Dictionary,pos:Vector2,points:Array)->void:
 m.sirens.append({"pos":pos,"home":pos,"goal":pos,"vel":Vector2.ZERO,"route":[],"angle":0.0,"mode":"PATROL","suspicion":0.0,"stun":0.0,"lock":0.0,"target":-1,"patrol":m.sirens.size(),"path_time":0.0,"type":"patroller","patrol_points":points,"patrol_index":0})

static func supports_config(config:Dictionary)->bool:
 var source=config.get("source_id",-1)
 return config.size()==2 and config.get("history")==true and source in IDS
