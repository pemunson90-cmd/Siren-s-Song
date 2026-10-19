extends RefCounted
# Working fiction. Registry, recovered-thread commits and runtime hooks belong
# to the campaign owner; this module consumes their recovered launch context.
const IDS=[11,12,13]
const FIELD_RECORDS=["divergence_confluence_packet","divergence_confluence_repeater","divergence_witness_packet","divergence_witness_repeater","resolution_warning_west","resolution_warning_east","resolution_warning_uplink"]

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
 var required=["witness_packet"] if id==12 else (["warning_west","warning_east","warning_uplink"] if id==13 else [])
 if required.is_empty():return ""
 var sites=mission.get("objectives",[])
 for site_id in required:
  if not sites.any(func(site):return site.get("site_id","")==site_id and site.get("captured",false)):return ""
 return "concealed_recovery" if id==12 else "overt_warning"

static func make(index:int,history:Dictionary={})->Dictionary:
 if index not in IDS:return {}
 var m=_base(index,history)
 if index==11:_confluence(m)
 elif index==12:_concealed(m)
 else:_overt(m)
 return m

static func _base(index:int,history:Dictionary)->Dictionary:
 var context={"thread":history.get("thread",""),"completed":history.get("completed",[]).duplicate(),"facts":history.get("facts",{}).duplicate(true),"references":history.get("references",{}).duplicate(true)}
 return {"id":index,"title":{11:"Confluence",12:"The Concealed Record",13:"The Open Warning"}[index],"depth":{11:4720,12:5180,13:3420}[index],"darkness":index==12,"world_size":Vector2(2400,2800),"region_revision":1,"acoustic_revision":1,"expedition_revision":2,"resolution_revision":1,"launch_context":context,"objectives":[],"sirens":[],"signal_sources":[],"signal_observations":[],"expedition_facts":{},"next_signal_time":0.0,"chosen_route":"","recovered":false,"withdrawal_armed":false,"required_site_ids":[]}

static func _confluence(m:Dictionary)->void:
 m.start=Vector2(2100,2460) if 9 in m.launch_context.completed else Vector2(280,2460)
 m.extraction=Vector2(280,220)
 m.rocks=[Rect2(-100,1950,950,220),Rect2(1370,1950,1200,220),Rect2(980,620,380,1120),Rect2(180,1180,400,300),Rect2(1680,1180,400,300),Rect2(940,-100,400,460)]
 m.signal_sources=[_source("confluence_packet","LIVE CONFLUENCE MEMORY",Vector2(600,760),"The recovered return and the surface acknowledgement meet in the same dispatch memory. The fracture warning can be brought out as a concealed witness record, or forwarded through the open warning chain. Neither carrier says that the guarded water is safe.",[.8,1.6,.8]),_source("confluence_repeater","ABANDONED DISPATCH REPEATER",Vector2(1880,720),"This station repeats an old dispatch. Its clear voice is a retained recording, not the living packet needed at Confluence.",[1.6,.8,1.6],false)]
 m.required_site_ids=["confluence_packet"]
 m.corridors=[{"pos":m.extraction,"name":"CONCEALED ASCENT","route":"concealed"},{"pos":Vector2(2080,220),"name":"OPEN WARNING PASSAGE","route":"overt"}]
 m.brief="The routes rejoin around a divided listening basin. Two carriers reach the southern approach; one is an old repeater. Their positions are not charted. Find and recover the live dispatch memory. An actually recovered RETURN reference and a fitted correlator may distinguish received cadences before a close fix; MATCH identifies a pattern, not a safe route. Without it, investigate the two arms or spend a finite local survey. Only the live memory completes this job. Then take Quietus through CONCEALED ASCENT to recover a private witness, or OPEN WARNING PASSAGE to commit the next job to forwarding the warning. The physical exit is the choice; replay does not rewrite an already committed thread."
 m.record="A living dispatch links the evacuation route and the warning chain. Quietus recovered enough to choose an operation, not a target list. The chosen physical passage commits this thread's next job."
 _patrol(m,Vector2(760,1110),[Vector2(760,1110),Vector2(720,780),Vector2(420,620),Vector2(760,1640)])
 _patrol(m,Vector2(1590,1060),[Vector2(1590,1060),Vector2(1590,1640),Vector2(2180,1640),Vector2(2180,680)])

static func _concealed(m:Dictionary)->void:
 m.world_size=Vector2(2400,3000);m.start=Vector2(2060,2680);m.extraction=Vector2(240,2700)
 m.rocks=[Rect2(720,2160,1780,240),Rect2(920,600,350,1200),Rect2(-100,1500,620,230),Rect2(1500,1300,900,180),Rect2(1320,360,340,420),Rect2(300,300,180,260)]
 m.signal_sources=[_source("witness_packet","SEALED WITNESS MEMORY",Vector2(560,680),"Quietus recovers the witness memory without broadcasting its origin. The packet preserves the observed evacuation and the human warning together; it does not reveal where the surviving pilot will surface.",[.8,1.6,.8]),_source("witness_repeater","EMPTY MEMORY ECHO",Vector2(1900,940),"An empty station still repeats the dispatch. Its abandoned echo is useful context, not the concealed witness packet.",[1.6,.8,1.6],false)]
 m.required_site_ids=["witness_packet"]
 m.corridors=[{"pos":m.extraction,"name":"WESTERN QUIET RECOVERY","route":"concealed"}]
 m.brief="Recover the sealed witness and bring Quietus back through the western recovery basin. The southern overhang separates deployment from the long return; the central spine separates the live memory from an empty repeating station. A received RETURN reference with the fitted correlator may identify which branch deserves a close approach. Quietus can always investigate and decode the real packet itself. A fitted drone sampler can do the compatible local field work, but its eight-second exposure is audible and the drone must survive to finish. There is no transmission task here: keep the witness's origin private while planning your physical return. Active tools remain available when survival needs them; no hidden purity score invalidates the recovery."
 m.record="The witness record returns without transmitting its source coordinates through the warning chain. The concealed recovery preserves an independent account of what Quietus observed. This resolves one operation, not the fate of the ocean."
 _patrol(m,Vector2(700,1140),[Vector2(700,1140),Vector2(700,700),Vector2(780,480),Vector2(820,1900)])
 _patrol(m,Vector2(1780,1780),[Vector2(1780,1780),Vector2(2100,1780),Vector2(2100,1580),Vector2(1380,1580)])

static func _overt(m:Dictionary)->void:
 m.world_size=Vector2(2800,2600);m.start=Vector2(420,2320);m.extraction=Vector2(2420,240)
 m.rocks=[Rect2(1080,980,600,860),Rect2(100,700,700,220),Rect2(1960,800,940,220),Rect2(1000,-100,500,400),Rect2(280,1530,500,220),Rect2(1880,1880,520,200)]
 m.objectives=[_receiver("warning_west","WEST CHAIN RECEIVER",Vector2(660,1250),"The western receiver holds the first part of the verified warning, prepared locally without a long-range broadcast."),_receiver("warning_east","EAST CHAIN RECEIVER",Vector2(2120,1420),"The eastern receiver holds the second part. Both local packets are needed before Quietus can forward a coherent warning.")]
 var uplink={"site_id":"warning_uplink","name":"WARNING CHAIN UPLINK","pos":Vector2(1400,560),"kind":"uplink","required_unit":0,"duration":4.0,"captured":false,"requires":[0,1],"requirement":"Prepare WEST and EAST receiver packets before transmitting.","unit_requirement":"Quietus must carry and transmit the assembled warning.","optical":"resolution_warning_uplink","evidence":"Quietus forwards the assembled fracture warning through the open chain. Its finite transmission is physically audible; an acknowledgement is not a promise that the route home is safe.","completion_emission":{"radius":1100.0,"label":"WARNING CHAIN TRANSMISSION","duration":8.0}}
 m.objectives.append(uplink);m.required_site_ids=["warning_west","warning_east","warning_uplink"]
 m.corridors=[{"pos":m.extraction,"name":"NORTHEAST WARNING RECOVERY","route":"overt"}]
 m.brief="Carry the warning across a divided transmission field. Prepare WEST and EAST local receiver packets, then bring Quietus to the northern uplink and transmit. The two arms can be worked in parallel by fitted drone samplers; each needs eight audible seconds and a living craft, while Quietus's four-second receiver remains the fallback. Plan the submarine's central approach while watching those field operations. The uplink requires both packets and Quietus, emits an ordinary finite warning transmission, and leaves you a real withdrawal to the northeast. Cover, disruption and decoys retain their ordinary costs. No recipient is revealed or ordered to ignore you by sending the warning."
 m.record="The assembled warning travels through the open chain. Quietus returns with the acknowledgement and the cost of having spoken. The message offers a warning instead of a firing solution; what others do with it remains unresolved."
 _patrol(m,Vector2(760,1140),[Vector2(760,1140),Vector2(460,1140),Vector2(460,1460),Vector2(900,1460)])
 _patrol(m,Vector2(2020,1340),[Vector2(2020,1340),Vector2(1840,1520),Vector2(2320,1520),Vector2(2320,1120)])
 _patrol(m,Vector2(1720,600),[Vector2(1720,600),Vector2(1900,460),Vector2(2240,460),Vector2(2060,680)])

static func _source(id:String,label:String,pos:Vector2,evidence:String,cadence:Array,confirm:bool=true)->Dictionary:
 return {"id":id,"label":label,"pos":pos,"optical":"divergence_"+id,"evidence":evidence,"located":false,"cadence":cadence,"confirm":confirm,"sampler_compatible":confirm}

static func _receiver(id:String,label:String,pos:Vector2,evidence:String)->Dictionary:
 return {"site_id":id,"name":label,"pos":pos,"kind":"receiver","required_unit":0,"duration":4.0,"captured":false,"sampler_compatible":true,"optical":"resolution_"+id,"evidence":evidence}

static func _patrol(m:Dictionary,pos:Vector2,points:Array)->void:
 m.sirens.append({"pos":pos,"home":pos,"goal":pos,"vel":Vector2.ZERO,"route":[],"angle":0.0,"mode":"PATROL","suspicion":0.0,"stun":0.0,"lock":0.0,"target":-1,"patrol":m.sirens.size(),"path_time":0.0,"type":"patroller","patrol_points":points,"patrol_index":0})
