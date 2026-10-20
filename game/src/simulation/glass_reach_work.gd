extends RefCounted
const ITEMS={17:"silt_spindle",20:"prism_core",21:"keeper_wafer"}
static func applies(m:Dictionary)->bool:return m.has("glass_reach") and preload("res://src/campaign/operation_catalog.gd").supports(m.get("id",-1),"glass_reach")
static func busy(sim,id:int)->bool:return applies(sim.mission) and not sim.mission.glass_reach.job.is_empty() and sim.mission.glass_reach.job.unit==id
static func artifact(sim)->Dictionary:return sim.mission.glass_reach.artifact if applies(sim.mission) else {}
static func item(sim)->String:return "glass_"+artifact(sim).get("id","")
static func sites(sim)->Array:
 var a=artifact(sim)
 return [{"item":item(sim),"name":a.id.replace("_"," ").to_upper(),"pos":a.pos,"band":a.band}] if not a.is_empty() and a.state in ["site","wreck"] else []
static func decoder(sim)->bool:return sim.mission.launch_equipment.get("quietus","")=="quietus_decoder"
static func context(sim,action:String,unit:int=-1)->Dictionary:
 var result={"ready":false,"reason":"No Reach task here","pos":Vector2.ZERO,"duration":8.,"active":false,"elapsed":0.,"claimed_by":-1}
 if not applies(sim.mission):return result
 if unit<0:unit=sim.selected
 var state=sim.mission.glass_reach;var body=sim.units[unit];var a=state.artifact
 result.pos=a.pos if action=="recover" and not a.is_empty() else state.work_pos
 result.duration=4. if action=="recover" else 2. if action=="gate" and decoder(sim) else 8.
 var band=a.band if action=="recover" and not a.is_empty() else 1
 if not sim.outcome.is_empty():result.reason="Dive ended"
 elif not body.alive:result.reason="Craft lost"
 elif action=="recover" and (a.is_empty() or a.state not in ["site","wreck"]):result.reason="Material already carried or unavailable"
 elif action in ["service","sever"] and (sim.mission.id!=18 or not state.choice.is_empty()):result.reason="Anchorage choice already made or unavailable"
 elif action=="vane" and (sim.mission.id!=15 or not state.choice.is_empty()):result.reason="Vane already released or unavailable"
 elif action=="gate" and (sim.mission.id not in [18,19] or state.gate_open):result.reason="Service gate already open or unavailable"
 elif action not in ["recover","service","sever","vane","gate"]:pass
 elif not state.job.is_empty():
  result.active=state.job.unit==unit;result.claimed_by=state.job.unit;result.elapsed=state.job.elapsed;result.reason="Reach work in progress"
 elif body.band!=band or not body.transition.is_empty():result.reason="Settle at this work's recorded depth"
 elif body.pos.distance_to(result.pos)>(120. if action=="gate" and decoder(sim) else 60.):result.reason="Meet local work within60m (decoder gate120m)"
 elif not sim.Depth.clear(sim,body.pos,result.pos,body.band):result.reason="Terrain blocks local work"
 elif body.vel.length()>=2:result.reason="Settle below2m/s"
 elif not sim.captures[unit].is_empty() or not sim.module_recovery_status().jobs[unit].is_empty() or sim.Delivery.busy(sim,unit) or sim.Witness.busy(sim,unit):result.reason="Finish this craft's active work"
 else:result.ready=true;result.reason="RECOVER material ·4s audible" if action=="recover" else "LOCAL DECODER ·2s quiet" if action=="gate" and decoder(sim) else "LOCAL MACHINERY ·8s audible"
 return result
static func command(sim,args:Dictionary)->bool:
 if not applies(sim.mission):return false
 var action=args.get("action","")
 if action=="withdraw":
  var q=sim.units[0]
  if sim.selected!=0 or not q.alive or q.band!=1 or not q.transition.is_empty() or q.vel.length()>=2 or q.pos.distance_to(sim.mission.extraction)>65:return false
  sim.outcome="withdrawn";sim.paused=true;sim.message="Reach withdrawal · field notes retained; no new recovery or material research";return true
 if action=="transfer":return transfer(sim,args.get("carrier",sim.selected))
 var c=context(sim,action)
 if not c.ready:sim.message=c.reason;return false
 sim.mission.glass_reach.job={"unit":sim.selected,"action":action,"elapsed":0.,"duration":c.duration,"pos":c.pos,"band":sim.units[sim.selected].band}
 sim.units[sim.selected].hold="HOLD"
 if not (action=="gate" and decoder(sim)):sim._noise(sim.units[sim.selected].pos,520.,"RECOVERY WINCH" if action=="recover" else "REACH MACHINERY",c.duration,sim.units[sim.selected].band)
 sim.message=c.reason;return true
static func transfer(sim,carrier)->bool:
 var a=artifact(sim)
 if not carrier is int or carrier not in [1,2] or a.is_empty() or a.state!="cargo" or a.carrier!=carrier or sim.selected not in [0,carrier]:return false
 var u=sim.units[carrier];var q=sim.units[0]
 if not u.alive or not q.alive or u.band!=q.band or not u.transition.is_empty() or not q.transition.is_empty() or u.vel.length()>=2 or q.vel.length()>=2 or u.pos.distance_to(q.pos)>60 or not sim.Depth.clear(sim,u.pos,q.pos,u.band):return false
 if busy(sim,0) or busy(sim,carrier) or not sim.captures[0].is_empty() or not sim.captures[carrier].is_empty():return false
 a.carrier=0;a.pos=q.pos;a.band=q.band;sim.message="Physical Reach material transferred locally to Quietus";return true
static func open_gate(sim):
 var state=sim.mission.glass_reach
 if not state.has("gate"):return
 sim.mission.structures.erase(state.gate);state.gate_open=true;sim._build_navigation();sim.opened_terrain(state.gate);sim._use_band(sim.units[sim.selected].band)
static func tick(sim,dt:float):
 if not applies(sim.mission):return
 var state=sim.mission.glass_reach;var a=state.artifact
 if not a.is_empty() and a.state=="cargo":
  var body=sim.units[a.carrier];a.pos=body.pos;a.band=body.band
  if not body.alive:a.state="wreck";a.carrier=-1;sim.message="Reach material at lost carrier position · recover its actual depth"
 if not a.is_empty():sim.mission.depth_cargo[item(sim)]=a.band
 if state.job.is_empty():return
 var job=state.job;var u=sim.units[job.unit]
 var custody=job.action!="recover" or (a.state in ["site","wreck"] and a.band==job.band and a.pos==job.pos)
 if not u.alive or u.hold!="HOLD" or u.band!=job.band or not u.transition.is_empty() or not custody or u.pos.distance_to(job.pos)>(120. if job.action=="gate" and decoder(sim) else 60.) or not sim.Depth.clear(sim,u.pos,job.pos,u.band):
  state.job={}
  if u.hold=="HOLD":u.hold=""
  sim.message="Reach work interrupted";return
 if u.vel.length()>=2:job.elapsed=0.;return
 job.elapsed+=dt
 if job.elapsed+.000001<job.duration:return
 if job.action=="recover":a.state="cargo";a.carrier=job.unit;a.pos=u.pos;sim.message="Physical material aboard "+u.name+" · recover carrier or TRANSFER locally to Quietus"
 elif job.action in ["service","sever","vane"]:
  state.choice=job.action
  if job.action=="service":open_gate(sim)
  else:
   for enemy in sim.sirens:
    if enemy.get("type","")=="buoy":enemy.stun=maxf(enemy.stun,120.);enemy.network.packet={};enemy.network.charge=0.
  if sim.mission.id==18:
   sim.mission.expedition_facts.glass_choice=job.action
   sim.mission.objectives[0].captured=true;recorded(sim,sim.mission.objectives[0]);sim._record_secured(sim.mission.objectives[0],job.unit)
  sim.message="Local service water opened; reporting spur remains supplied" if job.action=="service" else "Local reporting spur interrupted; outside water remains open"
 elif job.action=="gate":open_gate(sim);sim.message="Local service gate opened"
 state.job={};u.hold=""
static func complete(sim)->bool:
 if not applies(sim.mission):return true
 var state=sim.mission.glass_reach
 if sim.mission.id in [15,18] and state.choice.is_empty():return false
 return state.artifact.is_empty() or state.artifact.state in ["cargo","recovered"]
static func can_extract(sim,corridor:Dictionary)->bool:
 var a=artifact(sim)
 if a.is_empty():return true
 if a.state!="cargo":return false
 var u=sim.units[a.carrier]
 return u.alive and u.band==1 and u.transition.is_empty() and u.vel.length()<12 and u.pos.distance_to(corridor.pos)<65 and sim.Depth.clear(sim,u.pos,corridor.pos,u.band)
static func recover(sim,corridor:Dictionary):
 var a=artifact(sim)
 if a.is_empty():return
 a.state="recovered";a.carrier=-1;a.band=1;a.pos=corridor.pos;sim.mission.glass_reach.retrieved=true
static func recorded(sim,o:Dictionary):
 if applies(sim.mission) and o.get("site_id","").begins_with("glass_record_"):sim.mission.expedition_facts[o.site_id]=o.evidence
static func status(sim)->Dictionary:
 if not applies(sim.mission):return {}
 var a=artifact(sim);var actions={}
 for action in ["recover","service","sever","vane","gate"]:actions[action]=context(sim,action)
 return {"actions":actions,"artifact":a.duplicate(true),"work_pos":sim.mission.glass_reach.work_pos,"choice":sim.mission.glass_reach.choice,"detail":"REACH WORK · "+("material "+a.get("state","")+" / "+a.get("id","") if not a.is_empty() else "local machinery / "+sim.mission.glass_reach.choice)+"\n"+"\n".join(actions.keys().map(func(k):return k.to_upper()+" · "+actions[k].reason))}
static func valid(data:Dictionary)->bool:
 var m=data.mission
 if not applies(m):return not m.has("glass_reach")
 var state=m.glass_reach
 if not state is Dictionary or not state.has_all(["work_pos","job","choice","gate_open","artifact","retrieved"]) or not state.work_pos is Vector2 or not state.job is Dictionary or state.choice not in ["","service","sever","vane"] or not state.gate_open is bool or not state.artifact is Dictionary or not state.retrieved is bool:return false
 var a=state.artifact
 if m.id in ITEMS:
  if a.size()!=5 or a.get("id")!=ITEMS[m.id] or a.get("state") not in ["site","cargo","wreck","recovered"] or not a.get("pos") is Vector2 or not Rect2(Vector2.ZERO,m.world_size).has_point(a.pos) or a.get("band") not in [0,1,2] or not a.get("carrier") is int:return false
  if a.state=="cargo" and (a.carrier not in [0,1,2] or not data.units[a.carrier].alive):return false
  if a.state!="cargo" and a.carrier!=-1:return false
  if state.retrieved!=(a.state=="recovered") or (state.retrieved and data.get("outcome","")!="won"):return false
 elif not a.is_empty():return false
 var job=state.job
 if not job.is_empty():
  if job.size()!=6 or job.get("unit") not in [0,1,2] or job.get("action") not in ["recover","service","sever","vane","gate"] or job.get("band") not in [0,1,2] or not job.get("pos") is Vector2:return false
  for k in ["elapsed","duration"]:
   if not (job.get(k) is int or job.get(k) is float) or not is_finite(job[k]):return false
  if job.duration not in [2.,4.,8.] or job.elapsed<0 or job.elapsed>job.duration or not data.units[job.unit].alive or data.units[job.unit].hold!="HOLD" or not data.captures[job.unit].is_empty():return false
 return true
