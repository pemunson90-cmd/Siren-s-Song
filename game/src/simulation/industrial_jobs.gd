extends RefCounted
const Catalog=preload("res://src/campaign/operation_catalog.gd")
static func applies(m:Dictionary)->bool:return Catalog.supports(m.get("id",-1),"iron_choir") and m.get("iron_choir") is Dictionary
static func busy(sim,id:int)->bool:return applies(sim.mission) and not sim.mission.iron_choir.jobs[id].is_empty()
static func body(sim)->Dictionary:return sim.mission.iron_choir.load if applies(sim.mission) else {}
static func yoke(sim,id:int)->bool:return sim.Equipment.item_for(sim.mission.launch_equipment,id)=="drone_traction_yoke"
static func towing(sim,id:int)->bool:return not body(sim).is_empty() and body(sim).state=="towed" and body(sim).carrier==id
static func speed(sim,id:int,speed_value:float)->float:return minf(speed_value,22. if yoke(sim,id) else 28.) if towing(sim,id) else speed_value
static func noise(sim,id:int)->float:return minf(240.,sim.propulsion_speed(sim.units[id])*(8. if yoke(sim,id) else 4.)) if towing(sim,id) else 0.
static func actions(sim)->Array:
 if not applies(sim.mission):return []
 var result=[]
 for site in sim.mission.iron_choir.sites:
  if site.id!="release":result.append(site.id)
 if sim.mission.id in [22,25]:result.append_array(["east","west"])
 if not body(sim).is_empty() and sim.mission.id in [24,25,27,28]:result.append_array(["attach","release"])
 if not sim.mission.iron_choir.artifact.is_empty():result.append("recover")
 return result
static func context(sim,action:String,id:int=-1)->Dictionary:
 if id<0:id=sim.selected
 var result={"ready":false,"reason":"No industrial work here","pos":Vector2.ZERO,"duration":8.,"range":60.,"active":false,"elapsed":0.,"unit":id}
 if not applies(sim.mission) or action not in actions(sim):return result
 var state=sim.mission.iron_choir;var u=sim.units[id];var load=state.load;var a=state.artifact
 var matches=state.sites.filter(func(site):return site.id==action or (action in ["east","west"] and site.id=="release"))
 var site=matches[0] if not matches.is_empty() else {}
 result.pos=a.pos if action=="recover" else load.pos if action in ["attach","release"] else site.pos
 var band=a.band if action=="recover" else load.band if action in ["attach","release"] else site.band
 result.duration=4. if action=="recover" else 8.
 if not sim.outcome.is_empty():result.reason="Dive ended"
 elif not u.alive:result.reason="Craft lost"
 elif busy(sim,id):result.active=true;result.elapsed=state.jobs[id].elapsed;result.reason="Industrial work in progress"
 elif u.band!=band or not u.transition.is_empty():result.reason="Settle at the work's physical depth"
 elif u.pos.distance_to(result.pos)>60 or not sim.Depth.clear(sim,u.pos,result.pos,u.band):result.reason="Reach within60m through clear local water"
 elif u.vel.length()>=2:result.reason="Settle below2m/s"
 elif not sim.captures[id].is_empty() or not sim.module_recovery_status().jobs[id].is_empty() or sim.Glass.busy(sim,id) or sim.Witness.busy(sim,id) or sim.Delivery.busy(sim,id):result.reason="Finish this craft's other local work"
 elif action=="attach" and (load.state not in ["moored","free"] or (id!=0 and not yoke(sim,id))):result.reason="Bare Quietus or this drone's fitted traction yoke required"
 elif action=="release" and not towing(sim,id):result.reason="This craft has no attached load"
 elif action in ["east","west"] and load.state!="moored":result.reason="Voyage already deliberately started"
 elif action=="west" and sim.mission.id==25 and not state.sites[1].done:result.reason="Open or staff the western service berth first"
 elif action=="recover" and a.state not in ["site","wreck"]:result.reason="Material sealed, carried or recovered"
 elif action in ["bypass","isolate","cradle","land"] and (load.state!="towed" or load.carrier!=id or load.pos.distance_to(site.pos)>75):result.reason="Tow the real load locally to its receiving socket"
 elif not site.is_empty() and site.done:result.reason="Machinery work already complete"
 elif action in ["bypass","isolate","reconnect","dismantle"] and not state.choice.is_empty():result.reason="Local infrastructure choice already made"
 elif state.jobs.any(func(job):return not job.is_empty() and (job.action==action or (action in ["bypass","isolate","reconnect","dismantle"] and job.action in ["bypass","isolate","reconnect","dismantle"]))):result.reason="Another craft owns this physical work"
 else:result.ready=true;result.reason="LOCAL "+action.to_upper()+" · "+("4s winch" if action=="recover" else "8s audible work")
 return result
static func command(sim,args:Dictionary)->bool:
 var action=args.get("action","");var c=context(sim,action)
 if not c.ready:sim.message=c.reason;return false
 var state=sim.mission.iron_choir;var load=state.load;var id=sim.selected
 if action=="attach":
  load.state="towed";load.carrier=id;load.trail=[sim.units[id].pos];load.route=[];sim.message="Physical tow attached · release before depth change";return true
 if action=="release":load.state="free";load.carrier=-1;load.trail=[];sim.message="Load released at its real position";return true
 if action in ["east","west"]:
  var destination=Vector2(2500,450) if sim.mission.id==22 else Vector2(2700,450) if action=="east" else Vector2(750,300)
  var points=[Vector2(750,2450),Vector2(2800,2450),Vector2(2800,450),destination] if action=="east" else [Vector2(750,600),Vector2(750,300),destination]
  sim._use_band(load.band);var from:Vector2=load.pos;var route=[]
  for point in points:
   var leg=sim.path(from,point)
   if leg.is_empty():sim._use_band(sim.units[id].band);sim.message="Physical freight course blocked";return false
   route.append_array(leg);from=point
  for n in route.size():route[n].stop=n==route.size()-1
  load.route=route;load.state="transit";load.destination=destination;state.route_choice=action
  sim._use_band(sim.units[id].band);sim._noise(c.pos,650.,"CHOIR BERTH RELEASE",6.,load.band);sim.message="Sled departs by "+action+" course · locally observe its actual refuge arrival";return true
 state.jobs[id]={"action":action,"pos":c.pos,"band":sim.units[id].band,"elapsed":0.,"duration":c.duration};sim.units[id].hold="HOLD"
 sim._noise(c.pos,520.,"RECOVERY WINCH" if action=="recover" else "CHOIR MACHINERY",c.duration,sim.units[id].band);sim.message=c.reason;return true
static func cancel_released(sim,id:int):
 if busy(sim,id) and sim.units[id].hold!="HOLD":sim.mission.iron_choir.jobs[id]={}
static func open_site(sim,site:Dictionary):
 site.done=true
 if site.shape.has_area():sim.mission.structures.erase(site.shape);sim._build_navigation();sim.opened_terrain(site.shape)
static func complete_work(sim,id:int,job:Dictionary):
 var state=sim.mission.iron_choir;var action=job.action;var a=state.artifact
 if action=="recover":a.state="cargo";a.carrier=id;a.pos=sim.units[id].pos;return
 for site in state.sites:
  if site.id==action:open_site(sim,site)
 if action in ["bypass","isolate","reconnect","dismantle"]:
  state.choice=action;sim.mission.expedition_facts["choir_choice" if sim.mission.id==24 else "choir_plant"]=action
 if action in ["bypass","isolate","cradle","land"]:
  state.load.state="seated";state.load.carrier=-1;state.load.trail=[];state.load.vel=Vector2.ZERO
  if action=="cradle":a.state="site"
  if action=="land":state.people_landed=true;sim.mission.expedition_facts.choir_people="landed"
 sim.events.append({"type":"warning_gate","pos":job.pos});sim.message="Industrial "+action+" physically complete"
static func tick(sim,dt:float):
 if not applies(sim.mission):return
 var state=sim.mission.iron_choir;var load=state.load;var a=state.artifact
 if not a.is_empty() and a.state=="cargo":
  var u=sim.units[a.carrier];a.pos=u.pos;a.band=u.band
  if not u.alive:a.state="wreck";a.carrier=-1
 if not load.is_empty() and load.alive:
  if load.state=="transit":
   sim._use_band(load.band);sim._move(load,dt,24.,false,false);sim._use_band(sim.units[sim.selected].band)
   if load.route.is_empty() and load.pos.distance_to(load.destination)<20 and load.vel.length()<2:load.state="arrived";state.arrived=true
  elif load.state=="towed":tow_tick(sim,load,dt)
 for id in 3:
  if state.jobs[id].is_empty():continue
  var job=state.jobs[id];var u=sim.units[id]
  if not u.alive or u.hold!="HOLD" or u.band!=job.band or not u.transition.is_empty() or u.pos.distance_to(job.pos)>60 or not sim.Depth.clear(sim,u.pos,job.pos,u.band):
   state.jobs[id]={}
   if u.hold=="HOLD":u.hold=""
   continue
  if u.vel.length()>=2:job.elapsed=0.;continue
  job.elapsed+=dt
  if job.elapsed+.000001>=job.duration:complete_work(sim,id,job);state.jobs[id]={};u.hold=""
 observe(sim)
 if complete(sim):sim.mission.expedition_facts["choir_"+str(sim.mission.id)]="physical "+sim.mission.title+" completed"
static func tow_tick(sim,load:Dictionary,dt:float):
 var u=sim.units[load.carrier]
 if not u.alive or u.band!=load.band or not u.transition.is_empty() or u.pos.distance_to(load.pos)>120:
  load.state="free";load.carrier=-1;load.trail=[];load.vel=Vector2.ZERO;return
 if load.trail.is_empty() or load.trail.back().distance_to(u.pos)>=4:load.trail.append(u.pos)
 var length=0.;var previous:Vector2=load.pos
 for point in load.trail:length+=previous.distance_to(point);previous=point
 var travel=minf(maxf(0.,length-35.),34.*dt);var old:Vector2=load.pos
 while travel>.001 and not load.trail.is_empty():
  var target:Vector2=load.trail[0];var step=load.pos.move_toward(target,travel);var distance=load.pos.distance_to(step)
  if not sim.Depth.clear(sim,load.pos,step,load.band,16. if yoke(sim,load.carrier) else 32.):break
  load.pos=step;travel-=distance
  if load.pos.distance_to(target)<.001:load.trail.pop_front()
 load.vel=(load.pos-old)/dt
 if load.vel.length()>1:load.angle=load.vel.angle()
 if load.trail.size()>256:load.state="free";load.carrier=-1;load.trail=[]
static func damage(sim,amount:float):
 var load=body(sim)
 if load.is_empty() or not load.alive:return
 load.hull=maxf(0.,load.hull-amount)
 if load.hull<=0:load.alive=false;load.vel=Vector2.ZERO;load.route=[];sim.outcome="lost";sim.paused=true;sim.message="Industrial load lost · retry preserves recovered campaign history"
static func observe(sim):
 if not applies(sim.mission):return
 var state=sim.mission.iron_choir;var load=state.load
 if not load.is_empty() and sim.visible(load.pos,load.band):
  state.seen={"pos":load.pos,"angle":load.angle,"hull":load.hull,"alive":load.alive,"band":load.band,"state":load.state,"carrier":load.carrier,"time":sim.elapsed,"name":load.name}
  if state.arrived:state.receipt=true
static func complete(sim)->bool:return complete_mission(sim.mission)
static func complete_mission(m:Dictionary)->bool:
 if not applies(m):return true
 var state=m.iron_choir
 match m.id:
  22,25:return state.receipt
  23:return state.sites.all(func(site):return site.done)
  24,29:return not state.choice.is_empty()
  26,27:return state.artifact.state in ["cargo","recovered"]
  28:return state.people_landed
 return false
static func can_extract(sim,corridor:Dictionary)->bool:
 if not applies(sim.mission):return true
 var a=sim.mission.iron_choir.artifact
 if a.is_empty():return true
 if a.state!="cargo":return false
 var u=sim.units[a.carrier]
 return u.alive and u.band==1 and u.transition.is_empty() and u.pos.distance_to(corridor.pos)<65 and u.vel.length()<12 and sim.Depth.clear(sim,u.pos,corridor.pos,u.band)
static func recover(sim,corridor:Dictionary):
 if not applies(sim.mission):return
 var state=sim.mission.iron_choir
 if not state.artifact.is_empty():state.artifact.state="recovered";state.artifact.carrier=-1;state.artifact.band=1;state.artifact.pos=corridor.pos;state.retrieved=true
static func status(sim)->Dictionary:
 if not applies(sim.mission):return {}
 var state=sim.mission.iron_choir;var load=state.seen.duplicate(true)
 if not load.is_empty():load.age=sim.elapsed-load.time
 var contexts={}
 for action in actions(sim):contexts[action]=context(sim,action)
 return {"load":load,"actions":contexts,"jobs":state.jobs.duplicate(true),"sites":state.sites.filter(func(site):return sim.visible(site.pos,site.band)).duplicate(true),"artifact":state.artifact.duplicate(true),"choice":state.choice,"receipt":state.receipt,"detail":"INDUSTRIAL WORK · "+sim.mission.title+"\n"+"\n".join(contexts.keys().map(func(action):return action.to_upper()+" · "+contexts[action].reason))}
static func valid(data:Dictionary)->bool:
 if not Catalog.supports(data.mission.get("id",-1),"iron_choir"):return not data.mission.has("iron_choir")
 var state=data.mission.get("iron_choir")
 if not state is Dictionary or not state.has_all(["sites","jobs","load","seen","choice","arrived","receipt","artifact","retrieved","route_choice","people_landed"]):return false
 if not state.sites is Array or state.sites.size()>3 or not state.jobs is Array or state.jobs.size()!=3 or not state.load is Dictionary or not state.seen is Dictionary or not state.artifact is Dictionary or state.choice not in ["","bypass","isolate","reconnect","dismantle"] or state.route_choice not in ["","east","west"]:return false
 var template=Catalog.make(data.mission.id,data.mission.get("launch_context",{})).iron_choir
 var bounds=Rect2(Vector2.ZERO,data.mission.world_size)
 if state.size()!=template.size() or state.sites.size()!=template.sites.size() or state.load.is_empty()!=template.load.is_empty() or state.artifact.is_empty()!=template.artifact.is_empty():return false
 for index in state.sites.size():
  if not state.sites[index] is Dictionary:return false
  for key in ["id","pos","band","shape"]:
   if state.sites[index].get(key)!=template.sites[index][key]:return false
 for flag in ["arrived","receipt","retrieved","people_landed"]:
  if not state[flag] is bool:return false
 for site in state.sites:
  if not site is Dictionary or not site.get("id") is String or not site.get("pos") is Vector2 or not site.get("shape") is Rect2 or site.get("band") not in [0,1,2] or not site.get("done") is bool:return false
 for id in 3:
  var job=state.jobs[id]
  if not job is Dictionary:return false
  if job.is_empty():continue
  if job.size()!=5 or not job.has_all(["action","pos","band","elapsed","duration"]) or not job.action is String or not job.pos is Vector2 or job.band not in [0,1,2] or not data.units[id].alive or data.units[id].hold!="HOLD":return false
  if job.action not in state.sites.map(func(site):return site.id)+["recover"] or not bounds.has_point(job.pos):return false
  if not number(job.elapsed) or not number(job.duration) or job.duration!=(4. if job.action=="recover" else 8.) or job.elapsed<0 or job.elapsed>job.duration:return false
 if not state.load.is_empty():
  var load=state.load
  if not load.has_all(["pos","vel","angle","route","alive","hull","band","transition","kind","state","carrier","trail"]) or not load.pos is Vector2 or not load.vel is Vector2 or not load.route is Array or not load.trail is Array or load.trail.size()>256 or load.band not in [0,1,2] or not number(load.hull) or load.hull<0 or load.hull>100:return false
  if not bounds.has_point(load.pos) or not load.vel.is_finite() or not number(load.angle) or not load.alive is bool or load.kind!=template.load.kind or not load.transition is Dictionary or not load.transition.is_empty():return false
  for point in load.trail:
   if not point is Vector2 or not bounds.has_point(point):return false
  for waypoint in load.route:
   if not waypoint is Dictionary or not waypoint.get("pos") is Vector2 or not bounds.has_point(waypoint.pos) or not waypoint.get("stop") is bool:return false
  if load.state in ["transit","arrived"] and (not load.get("destination") is Vector2 or not bounds.has_point(load.destination)):return false
  if load.state not in ["moored","free","towed","transit","arrived","seated"] or load.carrier not in [-1,0,1,2] or (load.state=="towed")!=(load.carrier>=0):return false
 if not state.artifact.is_empty():
  var a=state.artifact
  if not a.has_all(["id","pos","band","state","carrier"]) or a.id not in ["pressure_spindle","traction_core"] or not a.pos is Vector2 or a.band not in [0,1,2] or a.state not in ["sealed","site","wreck","cargo","recovered"] or a.carrier not in [-1,0,1,2] or (a.state=="cargo")!=(a.carrier>=0):return false
  if not bounds.has_point(a.pos) or a.id!=template.artifact.id or (a.state=="cargo" and not data.units[a.carrier].alive):return false
  if state.retrieved!=(a.state=="recovered"):return false
 if not state.seen.is_empty():
  var seen=state.seen
  if not seen.has_all(["pos","angle","hull","alive","band","state","carrier","time","name"]) or not seen.pos is Vector2 or not bounds.has_point(seen.pos) or not number(seen.time) or seen.time<0 or seen.time>data.get("elapsed",0.) or not number(seen.angle) or not number(seen.hull) or seen.hull<0 or seen.hull>100 or not seen.alive is bool or seen.band not in [0,1,2]:return false
 if data.mission.get("recovered",false) and not complete_mission(data.mission):return false
 return true
static func number(n)->bool:return (n is int or n is float) and is_finite(n)
