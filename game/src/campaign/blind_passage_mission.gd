extends RefCounted
# Connected navigation job. Registry, chart observation/routing and physical
# handoff/return hooks are owned by the model worker and remain separately gated.
const ID=14

static func carried_evidence(context:Dictionary)->String:
 var completed=context.get("completed",[]);var facts=context.get("facts",{})
 if not completed is Array or not facts is Dictionary:return ""
 if 12 in completed and facts.get("resolution","")=="concealed_recovery" and facts.get("confluence_route","")=="concealed":return "concealed_recovery"
 if 13 in completed and facts.get("resolution","")=="overt_warning" and facts.get("confluence_route","")=="overt":return "overt_warning"
 return ""

static func can_launch(context:Dictionary)->bool:
 return not carried_evidence(context).is_empty()

static func delivery_ready(mission:Dictionary)->bool:
 var evidence=carried_evidence(mission.get("launch_context",{}))
 return mission.get("id",-1)==ID and not evidence.is_empty() and mission.get("carried_evidence","")==evidence and mission.get("handoff_complete",false)==true

static func make(index:int,context:Dictionary={})->Dictionary:
 if index!=ID:return {}
 var history={"thread":context.get("thread",""),"completed":context.get("completed",[]).duplicate(),"facts":context.get("facts",{}).duplicate(true),"references":context.get("references",{}).duplicate(true)}
 if context.has("terrain_notes"):history["terrain_notes"]=context.terrain_notes.duplicate(true)
 var evidence=carried_evidence(history)
 var m={"id":ID,"title":"Blind Passage","depth":3980,"darkness":false,"world_size":Vector2(2400,3000),"region_revision":1,"terrain_chart_revision":1,"chart_geometry_revision":1,"delivery_revision":1,"acoustic_revision":1,"start":Vector2(300,2700),"launch_seed":Rect2(80,2400,520,520),"handoff_sector":Rect2(1880,80,440,440),"handoff_pos":Vector2(2100,300),"withdrawal_pos":Vector2(300,2700),"extraction":Vector2(300,2700),"handoff_complete":false,"recovered":false,"withdrawal_armed":false,"launch_context":history,"carried_evidence":evidence,"objectives":[],"required_site_ids":[],"sirens":[]}
 # The long west bypass, central dogleg and exposed east bypass are real water.
 # No topology beyond the launch seed is briefed or prefilled into chart state.
 m.rocks=[Rect2(900,520,440,1000),Rect2(900,1860,440,400),Rect2(320,1280,580,240),Rect2(1660,1520,440,240),Rect2(1660,760,840,240),Rect2(700,2220,420,240),Rect2(1580,2140,520,260),Rect2(260,400,520,220)]
 m.brief="Carry the %s through Blind Passage to the announced northern handoff basin, then bring Quietus back to deployment. The launch waters are surveyed. Extend the chart with local observations, a scouting drone or finite SURVEY. Plan through confirmed water and use what you learn for the return."%("sealed witness account" if evidence=="concealed_recovery" else "received warning exchange" if evidence=="overt_warning" else "recovered account")
 m.record="Quietus carried the recovered account through newly charted water and returned from the announced handoff basin. A passage survey now accompanies the recovered account. The recipient's intent and the account's wider consequences remain unresolved."
 _patrol(m,Vector2(620,1780),[Vector2(620,1780),Vector2(500,1640),Vector2(300,1720),Vector2(420,2100)])
 _patrol(m,Vector2(1480,1220),[Vector2(1480,1220),Vector2(1480,1700),Vector2(1560,1880),Vector2(1780,1960)])
 return m

static func _patrol(m:Dictionary,pos:Vector2,points:Array)->void:
 m.sirens.append({"pos":pos,"home":pos,"goal":pos,"vel":Vector2.ZERO,"route":[],"angle":0.0,"mode":"PATROL","suspicion":0.0,"stun":0.0,"lock":0.0,"target":-1,"patrol":m.sirens.size(),"path_time":0.0,"type":"patroller","patrol_points":points,"patrol_index":0})
