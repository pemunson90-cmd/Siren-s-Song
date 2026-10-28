extends RefCounted
# Optional physical notes cache. Revert authoring with ENABLED=false; retain
# validation and custody support for existing dives. No equipment or stock grants.
const ENABLED=true
const OP=39
const IDS=["shelf_cache_1","shelf_cache_2","shelf_cache_3"]
const POS=Vector2(2450,1720)
const FACT="glass_record_39_cache"
const NOTE="Three physical cache pieces received at southeast recovery; the terrace service account is complete."
const Winch=preload("res://src/simulation/module_recovery.gd")
static func author(m:Dictionary)->void:
 if not ENABLED or m.id!=OP:return
 var pieces={}
 for i in IDS.size():pieces[IDS[i]]={"state":"site","carrier":-1,"pos":POS+Vector2(i*20,0),"band":1}
 m["optional_cache"]={"pieces":pieces,"jobs":[{},{},{}]}
 m.brief+="\nOptional three-piece service cache at (2450,1720), MIDDLE: each piece takes one free cargo place and a4s audible winch. A bare Fast hull or Heavy drone can take all three in one load; a standard two-place craft needs two trips, or share the load across the fleet. Use CACHE / UNLOAD at southeast recovery before finishing the photograph to make room. Receive all three for a recovered account on first return. Fitted cargo also uses capacity."
static func applies(sim)->bool:return sim.mission.has("optional_cache")
static func busy(sim,id:int)->bool:return applies(sim) and not sim.mission.optional_cache.jobs[id].is_empty()
static func pieces(sim)->Dictionary:return sim.mission.get("optional_cache",{}).get("pieces",{})
static func carried(sim,id:int)->int:
 return pieces(sim).values().filter(func(p):return p.state=="cargo" and p.carrier==id).size()
static func sites(sim)->Array:
 var result=[]
 for item in pieces(sim):
  var p=pieces(sim)[item]
  if p.state in ["site","wreck"]:result.append({"item":item,"name":item.replace("_"," ").to_upper(),"pos":p.pos,"band":p.band})
 return result
static func occupied(sim,id:int)->bool:
 return busy(sim,id) or not sim.captures[id].is_empty() or not sim.module_recovery_status().jobs[id].is_empty() or sim.Glass.busy(sim,id) or sim.Choir.busy(sim,id) or sim.Delivery.busy(sim,id) or sim.Witness.busy(sim,id) or sim.Chain.connected(sim,id)
static func context(sim,item:String,id:int)->Dictionary:
 var c={"ready":false,"reason":"Cache piece unavailable","active":false,"claimed_by":-1,"elapsed":0.,"duration":Winch.DURATION,"distance":0.,"range":Winch.RANGE,"noise_radius":Winch.NOISE}
 if id not in [0,1,2] or not pieces(sim).has(item):return c
 var p=pieces(sim)[item];var u=sim.units[id]
 for worker in 3:
  var job=sim.mission.optional_cache.jobs[worker]
  if job.get("item","")==item:c.claimed_by=worker;c.active=worker==id;c.elapsed=job.elapsed
 c.distance=u.pos.distance_to(p.pos)
 if not sim.outcome.is_empty():c.reason="Dive ended"
 elif not u.alive:c.reason="Craft lost"
 elif p.state not in ["site","wreck"]:pass
 elif c.claimed_by>=0:c.reason="Cache winch in progress"
 elif occupied(sim,id):c.reason="Finish this craft's active work"
 elif Winch.carried(sim,id)>=Winch.capacity(sim,id):c.reason="No free cargo place · %d / %d carried"%[Winch.carried(sim,id),Winch.capacity(sim,id)]
 elif u.band!=p.band or not u.transition.is_empty():c.reason="Settle at the piece's recorded depth"
 elif c.distance>Winch.RANGE:c.reason="Move within60m"
 elif not sim.Depth.clear(sim,u.pos,p.pos,u.band):c.reason="Terrain blocks winch"
 elif u.vel.length()>=2.:c.reason="Settle below2m/s"
 else:c.ready=true;c.reason="RECOVER CACHE ·4s audible · one cargo place"
 return c
static func begin(sim,item:String)->bool:
 var c=context(sim,item,sim.selected)
 if not c.ready:sim.message=c.reason;return false
 sim.mission.optional_cache.jobs[sim.selected]={"item":item,"elapsed":0.}
 sim.units[sim.selected].hold="HOLD"
 sim._noise(sim.units[sim.selected].pos,Winch.NOISE,"RECOVERY WINCH",Winch.DURATION,sim.units[sim.selected].band)
 sim.message=c.reason;return true
static func release_if_unheld(sim,id:int)->void:
 if applies(sim):sim.mission.optional_cache.jobs[id]={}
static func tick(sim,dt:float)->void:
 if not applies(sim):return
 for item in pieces(sim):
  var p=pieces(sim)[item]
  if p.state=="cargo":
   var u=sim.units[p.carrier];p.pos=u.pos;p.band=u.band
   if not u.alive:p.state="wreck";p.carrier=-1;sim.message="Cache piece at lost carrier's actual position and depth"
  sim.mission.depth_cargo[item]=p.band
 for id in 3:
  var job=sim.mission.optional_cache.jobs[id]
  if job.is_empty():continue
  var p=pieces(sim)[job.item];var u=sim.units[id]
  if not sim.outcome.is_empty() or not u.alive or u.hold!="HOLD" or p.state not in ["site","wreck"] or u.band!=p.band or not u.transition.is_empty() or u.pos.distance_to(p.pos)>Winch.RANGE or not sim.Depth.clear(sim,u.pos,p.pos,u.band) or Winch.carried(sim,id)>=Winch.capacity(sim,id):
   release_if_unheld(sim,id)
   if u.hold=="HOLD":u.hold=""
   sim.message="Cache winch interrupted";continue
  if u.vel.length()>=2.:job.elapsed=0.;continue
  job.elapsed+=dt
  if job.elapsed+.000001>=Winch.DURATION:
   p.state="cargo";p.carrier=id;p.pos=u.pos;p.band=u.band
   release_if_unheld(sim,id);u.hold="";sim.message="Cache piece aboard "+u.name+" · CACHE / UNLOAD at recovery"
static func mouth(sim,id:int,speed:float=2.)->Dictionary:
 var u=sim.units[id]
 if not u.alive or u.band!=1 or not u.transition.is_empty() or u.vel.length()>=speed:return {}
 # Public authored mouths, independent of required photograph completion.
 for corridor in sim.mission.get("corridors",[]):
  if u.pos.distance_to(corridor.pos)<65 and sim.Depth.clear(sim,u.pos,corridor.pos,1):return corridor
 return {}
static func unload_context(sim)->Dictionary:
 var c={"ready":false,"reason":"Carry cache pieces to a recovery mouth in MIDDLE; settle below2m/s"}
 if not applies(sim) or not sim.outcome.is_empty():return c
 if carried(sim,sim.selected)>0 and not mouth(sim,sim.selected).is_empty() and not occupied(sim,sim.selected):c.ready=true;c.reason="Unload cache here; continue the photographic job"
 return c
static func receive(sim,id:int,corridor:Dictionary)->void:
 for p in pieces(sim).values():
  if p.state=="cargo" and p.carrier==id:p.state="received";p.carrier=-1;p.pos=corridor.pos;p.band=1
 if pieces(sim).values().all(func(p):return p.state=="received"):sim.mission.expedition_facts[FACT]=NOTE
static func recover(sim,corridor:Dictionary)->void:
 if not applies(sim):return
 for id in 3:
  var c=mouth(sim,id,12.)
  if not c.is_empty() and c.pos==corridor.pos:receive(sim,id,corridor)
static func transfer_ready(sim)->bool:
 var id=sim.selected
 if not applies(sim) or not sim.outcome.is_empty() or id not in [1,2] or carried(sim,id)==0 or occupied(sim,id) or occupied(sim,0) or Winch.carried(sim,0)>=Winch.capacity(sim,0):return false
 var u=sim.units[id];var q=sim.units[0]
 return u.alive and q.alive and u.band==q.band and u.transition.is_empty() and q.transition.is_empty() and u.vel.length()<2. and q.vel.length()<2. and u.pos.distance_to(q.pos)<=Winch.RANGE and sim.Depth.clear(sim,u.pos,q.pos,u.band)
static func command(sim,args:Dictionary)->bool:
 if not applies(sim) or not sim.outcome.is_empty():return false
 var id=sim.selected;var u=sim.units[id]
 match args.get("action",""):
  "unload":
   var c=unload_context(sim)
   if not c.ready:sim.message=c.reason;return false
   receive(sim,id,mouth(sim,id));sim.message="Physical cache cargo received · places freed · photography remains the job";return true
  "transfer":
   if not transfer_ready(sim):return false
   for p in pieces(sim).values():
    if p.state=="cargo" and p.carrier==id and Winch.carried(sim,0)<Winch.capacity(sim,0):p.carrier=0;p.pos=sim.units[0].pos;p.band=sim.units[0].band
   sim.message="Cache cargo transferred locally to Quietus";return true
  "drop":
   if not u.alive or not u.transition.is_empty() or occupied(sim,id):return false
   for p in pieces(sim).values():
    if p.state=="cargo" and p.carrier==id:p.state="wreck";p.carrier=-1;p.pos=u.pos;p.band=u.band;sim.message="Cache piece released at this craft's position and depth";return true
 return false
static func blocks(sim,order:String)->bool:
 return busy(sim,sim.selected) and order in ["camera","salvage","glass_action","choir_action","blackwater_handoff","witness_land","chain_power","chain_route","chain_send"]
static func valid(data:Dictionary)->bool:
 var m=data.mission
 if not m.has("optional_cache"):return true # Old active dives stay loadable.
 var s=m.optional_cache
 if m.id!=OP or not s is Dictionary or s.size()!=2 or not s.get("pieces") is Dictionary or s.pieces.size()!=IDS.size() or not s.get("jobs") is Array or s.jobs.size()!=3:return false
 var counts=[0,0,0];var received=0
 for item in IDS:
  var p=s.pieces.get(item)
  if not p is Dictionary or p.size()!=4 or p.get("state") not in ["site","cargo","wreck","received"] or not p.get("carrier") is int or not p.get("pos") is Vector2 or not p.pos.is_finite() or not Rect2(Vector2.ZERO,m.world_size).has_point(p.pos) or not p.get("band") is int or p.band not in [0,1,2]:return false
  if p.state=="cargo":
   if p.carrier not in [0,1,2] or not data.units[p.carrier].alive:return false
   counts[p.carrier]+=1
  elif p.carrier!=-1:return false
  if p.state=="received":
   received+=1
   if p.band!=1 or not m.get("corridors",[]).any(func(c):return c.pos==p.pos):return false
  if p.state=="site" and (p.band!=1 or p.pos!=POS+Vector2(IDS.find(item)*20,0)):return false
 if m.expedition_facts.get(FACT,"")!=(NOTE if received==3 else ""):return false
 var claimed=[]
 for id in 3:
  # Count existing physical cargo too, without constructing a simulation.
  var total=counts[id]
  for module in m.get("module_recovery",{}).get("modules",{}).values():
   if module.state=="cargo" and module.unit==id:total+=1
  for key in ["glass_reach","iron_choir"]:
   var a=m.get(key,{}).get("artifact",{})
   if a.get("state","")=="cargo" and a.get("carrier",-1)==id:total+=1
  if total>Winch.capacity_data(m,id):return false
  var job=s.jobs[id]
  if not job is Dictionary:return false
  if job.is_empty():continue
  if job.size()!=2 or job.get("item") not in IDS or job.item in claimed or s.pieces[job.item].state not in ["site","wreck"] or not (job.get("elapsed") is int or job.get("elapsed") is float) or not is_finite(job.elapsed) or job.elapsed<0 or job.elapsed>Winch.DURATION:return false
  if not data.units[id].alive or data.units[id].hold!="HOLD" or not data.captures[id].is_empty() or not m.module_recovery.jobs[id].is_empty() or total>=Winch.capacity_data(m,id):return false
  claimed.append(job.item)
 return true
