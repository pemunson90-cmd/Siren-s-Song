extends RefCounted
# Occupied bunker sections receive real warnings, respond in their own time and
# supply a locally received account. Neither progress nor rendering tracks guards.
const ALARM=Vector2(1120,1480)
const FRONT=Rect2(600,1450,180,400)
const GALLERIES=[{"id":"west","name":"UPPER BUNKER SECTION","pos":Vector2(560,1000)}, {"id":"east","name":"LOWER BUNKER SECTION","pos":Vector2(1700,1200)}]
const ACCOUNT="The work-lights go behind pressure shutters. The returning account lists the watch crew sealed in the shore-end bunker, not firing coordinates. The bunker cannot be opened at once: this warning buys time to seal it. Carry the acknowledged call onward to the warning plant."
static func initial()->Dictionary:
 return {"seen":{},"warned_at":{},"receipts":[],"methods":{},"alarm_used":false,"front_known":false,"next_reply":0.0}
static func applies(m:Dictionary)->bool:return m.get("id")==8 and m.has("shelf_habitat")
static func build(m:Dictionary)->void:
 m.world_size=Vector2(2400,2400);m.start=Vector2(2140,400);m.extraction=Vector2(240,2160)
 m.rocks=[Rect2(-100,-100,2600,300),Rect2(-100,700,580,550),Rect2(1780,850,720,550),Rect2(780,1750,920,240),PackedVector2Array([Vector2(800,400),Vector2(1260,400),Vector2(1360,680),Vector2(1320,920),Vector2(1390,1120),Vector2(800,1120),Vector2(840,940),Vector2(760,720)])]
 m["shelf_habitat"]=initial();m["thermal_revision"]=1;m["thermal_fronts"]=[{"area":FRONT,"transmission":.5,"close_range":120.0}]
 m.objectives=[{"pos":ALARM,"name":"WATCH ACKNOWLEDGEMENTS","site_id":"warning_receiver","optical":"divergence_warning","captured":false,"kind":"habitat","evidence":ACCOUNT}]
 # 097: independent optional reception beside the western occupied section.
 # Quietus can visit it; a drone can listen while Quietus works the resonator.
 m.objectives.append({"pos":Vector2(560,1000),"name":"WEST SERVICE POWER ACCOUNT","site_id":"shelf_service","optical":"shelf_service","captured":false,"kind":"receiver","duration":4.,"optional":true,"evidence":"The west section's service account records the isolated reserve supply behind its closed pressure shutters."})
 m.corridors=[{"pos":m.extraction,"name":"WEST SHELF RECOVERY","route":"shelf"}]
 m.brief="Terrace windows beyond the shelf receiver still draw power. Carry Quietus’s warning to the watch crew in Port Ardent's shore-end bunker. Visit both section listening lips for quiet local delivery, or sound the charted COMMUNAL RESONATOR once: its1200m call offers a shorter work route but draws the hunter. A sent warning alone is not a returned acknowledgement; hear both replies. Drones can discover the sections and watch approaches. The shorter inner return crosses a mutually masking exhaust front; the longer outer contour preserves passive information. Bring Quietus and the watch acknowledgements to western recovery."
 m.record="Two sections of the bunker answered the warning. Their pressure shutters closed over the watch crew; Quietus carries a call toward living survivors, not an empty station's firing coordinates."
 m.brief+=" A separate MIDDLE receiver at the western section holds the optional WEST SERVICE POWER ACCOUNT. A drone can receive it while Quietus works the communal resonator."
static func complete(sim)->bool:return not applies(sim.mission) or sim.mission.shelf_habitat.receipts.size()==2
static func receiver(sim)->Dictionary:
 var craft=sim.units[sim.selected]
 for index in sim.mission.objectives.size():
  var site=sim.mission.objectives[index]
  if site.get("site_id","")!="shelf_service" or site.captured:continue
  if craft.alive and craft.pos.distance_to(site.pos)<240 and sim.line_clear(craft.pos,site.pos):
   return {"target":index,"ready":craft.vel.length()<12,"text":"WEST SERVICE ACCOUNT · passive decode4s · settle below12m/s"}
 return {"target":-1,"ready":false,"text":context(sim).account}
static func _gallery(id:String)->Dictionary:
 for site in GALLERIES:
  if site.id==id:return site
 return {}
static func _local_reason(sim,pos:Vector2,range:float)->String:
 var q=sim.units[sim.selected]
 if not sim.outcome.is_empty():return "Dive ended"
 if sim.selected!=0:return "Quietus carries the verified warning; drones can scout the occupied mouths"
 if not q.alive:return "Quietus lost"
 if q.pos.distance_to(pos)>range:return "Bring Quietus within%dm · currently%dm"%[roundi(range),roundi(q.pos.distance_to(pos))]
 if not sim.line_clear(q.pos,pos):return "Terrain blocks the local connection"
 if q.vel.length()>=2:return "Settle below2m/s"
 if not sim.captures[0].is_empty() or sim._blackwater_recovery_busy(0) or sim._witness_recovery_busy(0):return "Finish Quietus's active work"
 return ""
static func context(sim)->Dictionary:
 if not applies(sim.mission):return {}
 var state=sim.mission.shelf_habitat;var sites=[]
 for site in GALLERIES:
  if not state.seen.has(site.id):continue
  var row=site.duplicate(true);row.merge(state.seen[site.id]);row.live=sim.elapsed-float(row.time)<.1;row["received"]=site.id in state.receipts
  var reason=_local_reason(sim,site.pos,100)
  if site.id in state.receipts:reason="Watch acknowledgement aboard"
  elif row.live and float(row.closing)>0:reason="Watch crew closing pressure shutters · listen for the local reply"
  row["action"]={"ready":reason.is_empty(),"reason":reason if not reason.is_empty() else "LOCAL WARNING ·100m direct pulse · one occupied section"};sites.append(row)
 var reason=_local_reason(sim,ALARM,60)
 if state.alarm_used:reason="Common alarm spent · local warnings remain available"
 return {"galleries":sites,"alarm":{"pos":ALARM,"used":state.alarm_used,"ready":reason.is_empty(),"reason":reason if not reason.is_empty() else "SOUND ALARM ·1200m/8s audible · one use"},"front":{"known":state.front_known,"area":FRONT},"receipts":state.receipts.duplicate(),"complete":complete(sim),"account":ACCOUNT if complete(sim) else "Two occupied sections · return their watch acknowledgements"}
static func command(sim,mode:String,id:String="")->bool:
 if not applies(sim.mission):return false
 var state=sim.mission.shelf_habitat
 var pos=ALARM;var radius=1200.0;var reason=""
 if mode=="local":
  var site=_gallery(id)
  if site.is_empty() or not state.seen.has(id):sim.message="Locate the occupied section with a live receiver first";return false
  pos=site.pos;radius=140.0;reason=_local_reason(sim,pos,100)
  if state.warned_at.has(id):reason="Section already warned · listen for its reply"
 else:
  reason=_local_reason(sim,ALARM,60)
  if state.alarm_used:reason="Common alarm already spent · local warnings remain available"
 if not reason.is_empty():sim.message=reason;return false
 var origin:Vector2=sim.units[0].pos if mode=="local" else ALARM
 if mode!="local":state.alarm_used=true
 var delivered=[]
 for site in GALLERIES:
  if mode=="local" and site.id!=id:continue
  if state.warned_at.has(site.id):continue
  if sim.acoustic_paths.arrivals(site.pos,origin,radius).is_empty():continue
  state.warned_at[site.id]=sim.elapsed;state.methods[site.id]="local" if mode=="local" else "common";delivered.append(site.id)
 sim._noise(origin,radius,"LOCAL SHELTER WARNING" if mode=="local" else "COMMON SHELTER ALARM",1.0 if mode=="local" else 8.0)
 sim.events.append({"type":"ping","pos":origin})
 sim.message="Local warning sent · listen for the section's reply" if mode=="local" else "Common alarm sounded · hunter can hear · listen for two watch replies"
 return true
static func observe(sim)->void:
 if not applies(sim.mission):return
 var state=sim.mission.shelf_habitat
 if sim.visible(FRONT.get_center()) or sim.visible(FRONT.position+Vector2(0,60)):state.front_known=true
 for site in GALLERIES:
  if sim.passive_receivers(site.pos).is_empty() and not (sim.recon_time>0 and preload("res://src/simulation/world_region.gd").survey_visible(sim,site.pos)):continue
  var closing=state.warned_at.has(site.id)
  var phase=clampf((sim.elapsed-float(state.warned_at.get(site.id,sim.elapsed)))/2.0,0,1) if closing else 0.0
  var first=not state.seen.has(site.id)
  state.seen[site.id]={"time":sim.elapsed,"closing":phase,"live":true}
  if first:sim.message=site.name+" occupied · work-lights moving behind pressure windows · Quietus can warn locally"
static func tick(sim)->void:
 if not applies(sim.mission):return
 observe(sim)
 var state=sim.mission.shelf_habitat
 if sim.elapsed<state.next_reply:return
 state.next_reply=sim.elapsed+.5
 for site in GALLERIES:
  if not state.warned_at.has(site.id) or sim.elapsed-float(state.warned_at[site.id])<2 or site.id in state.receipts:continue
  var listeners=[]
  for index in sim.units.size():
   var unit=sim.units[index]
   if not unit.alive:continue
   var arrivals=preload("res://src/simulation/thermal_front.gd").arrivals(sim,unit,site.pos,850.0) if sim.mission.get("thermal_revision",0)==1 else sim.acoustic_paths.arrivals(unit.pos,site.pos,850.0)
   if not arrivals.is_empty():listeners.append({"receiver":index,"direction":unit.pos.direction_to(arrivals[0].goal)})
  if listeners.is_empty():continue
  state.receipts.append(site.id)
  sim.events.append({"type":"return_received","receiver":listeners[0].receiver,"direction":listeners[0].direction,"identity":"shelter","time":sim.elapsed})
  sim.message=site.name+" watch reply received · section sealed"
 if complete(sim) and not sim.mission.objectives[0].captured:
  sim.mission.objectives[0].captured=true;sim._record_secured(sim.mission.objectives[0],0)
  sim.mission.record=ACCOUNT+"\n"+result(sim.mission)
  sim.message="Both occupied sections answered · watch account aboard · choose the masked inner trench or the longer outer return"
static func result(mission:Dictionary)->String:
 var state=mission.get("shelf_habitat",{})
 if state.get("receipts",[]).size()!=2:return ""
 var used=state.get("methods",{}).values()
 return "Both bunker sections received the common alarm and answered." if used.all(func(method):return method=="common") else "Both bunker sections received close local warnings and answered." if used.all(func(method):return method=="local") else "The common call and a close local warning reached both bunker sections; both answered."
static func valid(data:Dictionary)->bool:
 var m=data.mission
 if m.get("id")!=8:return not m.has("shelf_habitat")
 var state=m.get("shelf_habitat")
 if not state is Dictionary or not state.has_all(["seen","warned_at","receipts","methods","alarm_used","front_known","next_reply"]):return false
 if not state.seen is Dictionary or not state.warned_at is Dictionary or not state.methods is Dictionary or not state.receipts is Array or not state.alarm_used is bool or not state.front_known is bool:return false
 if not state.next_reply is float or state.next_reply<0:return false
 for id in state.warned_at:
  if _gallery(id).is_empty() or not state.warned_at[id] is float or state.warned_at[id]<0 or state.warned_at[id]>data.get("elapsed",0) or state.methods.get(id) not in ["local","common"]:return false
 for id in state.receipts:
  if not state.warned_at.has(id):return false
 if state.receipts.size()>2 or state.receipts.count("west")>1 or state.receipts.count("east")>1:return false
 for id in state.seen:
  if _gallery(id).is_empty() or not state.seen[id] is Dictionary or not state.seen[id].has_all(["time","closing","live"]):return false
 return not m.objectives.is_empty() and m.objectives[0].captured==(state.receipts.size()==2)
