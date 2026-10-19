extends RefCounted
# Working fiction. Registry, recovered-thread commits and runtime hooks belong
# to the campaign owner; this module consumes their recovered launch context.
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
 var required=["witness_packet"] if id==12 else (["warning_transmission","warning_reply"] if id==13 else [])
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
 var deep=m.launch_context.thread=="deep" or (m.launch_context.thread.is_empty() and 9 in m.launch_context.completed)
 m.start=Vector2(2100,2460) if deep else Vector2(280,2460)
 m.extraction=Vector2(280,220)
 m.rocks=[Rect2(-100,1950,950,220),Rect2(1370,1950,1200,220),Rect2(980,620,380,1120),Rect2(180,1180,400,300),Rect2(1680,1180,400,300),Rect2(940,-100,400,460)]
 m.signal_sources=[_source("confluence_packet","LIVE CONFLUENCE MEMORY",Vector2(600,760),"The recovered return and the surface acknowledgement meet in the same dispatch memory. The fracture warning can be brought out as a concealed witness record, or forwarded through the open warning chain. Neither carrier says that the guarded water is safe.",[.8,1.6,.8]),_source("confluence_repeater","ABANDONED DISPATCH REPEATER",Vector2(1880,720),"This station repeats an old dispatch. Its clear voice is a retained recording, not the living packet needed at Confluence.",[1.6,.8,1.6],false)]
 m.required_site_ids=["confluence_packet"]
 m.corridors=[{"pos":m.extraction,"name":"CONCEALED ASCENT","route":"concealed"},{"pos":Vector2(2080,220),"name":"OPEN WARNING PASSAGE","route":"overt"}]
 m.brief="The routes rejoin around a divided listening basin. Two carriers occupy the divided basin; one is an old repeater. Their positions are not charted, and the southern staging water may receive neither. Move your receivers to investigate the arms. Find and recover the live dispatch memory. If a cadence is actually received, a recovered RETURN reference and fitted correlator can compare it; MATCH identifies a pattern, not a safe route or a guaranteed early cue. Without it, investigate the two arms or spend a finite local survey. Only the live memory completes this job. Then take Quietus through CONCEALED ASCENT to recover a private witness, or OPEN WARNING PASSAGE to commit the next job to forwarding the warning. The physical exit is the choice; replay does not rewrite an already committed thread."
 m.record="A living dispatch links the evacuation route and the warning chain. Quietus recovered enough to choose an operation, not a target list. The chosen physical passage commits this thread's next job."
 _patrol(m,Vector2(760,1110),[Vector2(760,1110),Vector2(720,780),Vector2(420,620),Vector2(760,1640)])
 _patrol(m,Vector2(1590,1060),[Vector2(1590,1060),Vector2(1590,1640),Vector2(2180,1640),Vector2(2180,680)])

static func _concealed(m:Dictionary)->void:
 m.world_size=Vector2(2400,3000);m.start=Vector2(2060,2680);m.extraction=Vector2(2260,2700)
 m.rocks=[Rect2(720,2160,940,240),Rect2(1900,2160,600,240),Rect2(920,600,350,1200),Rect2(-100,1500,620,230),Rect2(1500,1300,900,180),Rect2(1320,360,340,420),Rect2(300,300,180,260)]
 var gate=Rect2(1660,2160,240,240)
 m.physical_gates=[{"id":"witness_service_sluice","closed_shape":gate,"site_id":"witness_sluice","opened":false}];m.structures=[gate]
 m.signal_sources=[_source("witness_packet","SEALED WITNESS MEMORY",Vector2(1840,760),"Quietus receives the concealed witness memory. The packet preserves the observed evacuation and the human warning together; it does not reveal where a surviving pilot will surface.",[.8,1.6,.8])]
 var actuator=_receiver("witness_sluice","SERVICE SLUICE CONTROL",Vector2(1780,2040),"The local actuator retracts the man-made service sluice. Its finite motor run is audible; the open passage changes the return route without silencing or ordering any patrol.")
 actuator.merge({"optional":true,"completion_open_structure":"witness_service_sluice","completion_emission":{"radius":1100.0,"label":"SERVICE SLUICE MOTOR","duration":8.0}});m.objectives=[actuator]
 m.required_site_ids=["witness_packet"]
 m.corridors=[{"pos":m.extraction,"name":"CONCEALED RECOVERY BASIN","route":"concealed"}]
 m.brief="Confluence's concealed passage leads to a witness store beyond the southern overhang. Recover its local packet and return to the southeast basin. The long western detour works with the service sluice shut and needs no transmission or machinery. Alternatively, operate the charted SERVICE SLUICE CONTROL on its north side: an audible motor permanently opens the man-made passage for a shorter return. It never closes or crushes craft. Quietus can operate it in four seconds; a fitted drone sampler can work independently in eight audible seconds, if it survives. The actuator is optional and does not replace the witness. Decide whether the changed route is worth making the machinery heard, then bring the packet home. Active tools remain available; no hidden purity score invalidates recovery."
 m.record="The witness record returns without forwarding its source through the warning chain. The service sluice, if opened, remains an actual route through the overhang; the unannounced western detour remains a valid alternative. This resolves the concealed operation, not the fate of the ocean."
 _patrol(m,Vector2(700,1140),[Vector2(700,1140),Vector2(700,700),Vector2(780,480),Vector2(820,1900)])
 _patrol(m,Vector2(1780,1780),[Vector2(1780,1780),Vector2(2100,1780),Vector2(2100,1580),Vector2(1380,1580)])

static func _overt(m:Dictionary)->void:
 m.world_size=Vector2(2800,2600);m.start=Vector2(420,2320);m.extraction=Vector2(2420,240)
 m.rocks=[Rect2(1080,980,600,860),Rect2(100,700,700,220),Rect2(1960,800,940,220),Rect2(1000,-100,500,400),Rect2(280,1530,500,220),Rect2(1880,1880,520,200)]
 var sector=Rect2(300,1000,2200,700)
 m.objectives=[{"site_id":"warning_transmission","name":"WARNING TRANSMISSION SECTOR","pos":Vector2(500,1120),"kind":"transmitter","own_origin":true,"origin_region":sector,"required_unit":0,"duration":6.0,"captured":false,"unit_requirement":"Quietus must carry and transmit the recovered warning.","optical":"resolution_warning_transmission","evidence":"Quietus sends the recovered Confluence packet from its actual chosen position. A local receiver begins replying; the return identifies reception, not the receiver's allegiance or safe water.","completion_emission":{"radius":1100.0,"label":"WARNING CHAIN TRANSMISSION","duration":8.0},"completion_enable_source":"warning_reply"}]
 var reply=_source("warning_reply","LOCAL WARNING ACKNOWLEDGEMENT",Vector2(1840,440),"Quietus receives the local acknowledgement after sending Confluence's warning. The station has answered; its identity, intent and the wider chain remain uncertain.",[1.2,.6,1.2]);reply.active=false;m.signal_sources=[reply]
 m.required_site_ids=["warning_transmission","warning_reply"]
 m.corridors=[{"pos":m.extraction,"name":"NORTHEAST WARNING RECOVERY","route":"overt"}]
 m.brief="Confluence's warning is already aboard. Choose where Quietus will speak inside the charted transmission sector: its western arm offers an early origin, while the eastern arm brings the submarine closer to the northern response water. The central breakwater separates approaches and sound paths. CAMERA / TRANSMIT uses Quietus's actual position, not a fixed uplink: settle for six seconds while the warning is sent. The finite transmission is audible at that origin. Only then does a local station begin replying. Use actual received bearings or a close observation to find and receive that acknowledgement, then return Quietus through northeast recovery. Drones may investigate the response or cover another approach; they cannot speak for Quietus. A reply does not certify identity, allegiance or a safe withdrawal."
 m.record="Quietus chose where to send the warning, received a local answer, and returned with that exchange. The receiver has become an active participant rather than an unexplained chart mark. The message offers a warning instead of a firing solution; what the wider chain does with it remains unresolved."
 _patrol(m,Vector2(760,1140),[Vector2(760,1140),Vector2(460,1140),Vector2(460,1460),Vector2(900,1460)])
 _patrol(m,Vector2(2020,1340),[Vector2(2020,1340),Vector2(1840,1520),Vector2(2320,1520),Vector2(2320,1120)])
 _patrol(m,Vector2(1720,600),[Vector2(1720,600),Vector2(1900,460),Vector2(2240,460),Vector2(2060,680)])

static func _source(id:String,label:String,pos:Vector2,evidence:String,cadence:Array,confirm:bool=true)->Dictionary:
 return {"id":id,"label":label,"pos":pos,"optical":"divergence_"+id,"evidence":evidence,"located":false,"cadence":cadence,"confirm":confirm,"sampler_compatible":confirm}

static func _receiver(id:String,label:String,pos:Vector2,evidence:String)->Dictionary:
 return {"site_id":id,"name":label,"pos":pos,"kind":"receiver","required_unit":0,"duration":4.0,"captured":false,"sampler_compatible":true,"optical":"resolution_"+id,"evidence":evidence}

static func _patrol(m:Dictionary,pos:Vector2,points:Array)->void:
 m.sirens.append({"pos":pos,"home":pos,"goal":pos,"vel":Vector2.ZERO,"route":[],"angle":0.0,"mode":"PATROL","suspicion":0.0,"stun":0.0,"lock":0.0,"target":-1,"patrol":m.sirens.size(),"path_time":0.0,"type":"patroller","patrol_points":points,"patrol_index":0})
