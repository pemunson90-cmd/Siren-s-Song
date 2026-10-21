extends RefCounted
const ROLES=["interceptor","warden"]
static func initial()->Dictionary:return {"phase":"idle","remaining":0.,"cooldown":0.,"aim":Vector2.ZERO,"band":1,"patches":[],"hit":[]}
static func initialize(sim):
 for e in sim.sirens:
  if e.get("type","") in ROLES:e.industry=initial()
static func evidence(sim,e:Dictionary)->Dictionary:
 var candidates=sim.units.duplicate()
 var load=sim.Choir.body(sim)
 if not load.is_empty():candidates.append(load)
 for u in candidates:
  if not u.get("alive",false) or e.pos.distance_to(u.pos)>=(180. if u.silent else 290.):continue
  # Sight earns a point in a shared clear volume, including an incoming band.
  for band in sim.Depth.occupied(e):
   if band in sim.Depth.occupied(u) and sim.Depth.clear(sim,e.pos,u.pos,band):return {"pos":u.pos,"band":band}
 var heard=sim._heard_arrival(e)
 if not heard.is_empty():return {"pos":heard.goal,"band":heard.get("band",e.band)}
 if e.get("attention_time",0)>0:return {"pos":e.goal,"band":e.get("known_band",e.band)}
 return {}
static func advance(sim,e:Dictionary,dt:float):
 var state=e.industry
 e.vel=Vector2.ZERO;e.lock=0.;e.target=-1
 state.cooldown=maxf(0.,state.cooldown-dt);e["attention_time"]=maxf(0.,e.get("attention_time",0.)-dt)
 if e.get("pin_time",0)>0:e.pin_time=maxf(0.,e.pin_time-dt)
 if e.stun>0:
  e.stun=maxf(0.,e.stun-dt);state.phase="idle";state.remaining=0.;state.patches=[];state.hit=[];e.mode="PINNED" if e.get("pin_time",0)>0 else "DISRUPTED";return
 for patch in state.patches:patch.remaining=maxf(0.,patch.remaining-dt)
 state.patches=state.patches.filter(func(patch):return patch.remaining>0)
 for patch in state.patches:damage_patch(sim,patch,dt)
 if state.phase=="idle":
  e.mode="INTERCEPT LISTEN" if e.type=="interceptor" else "WARDEN IDLE"
  if state.cooldown>0:return
  var received=evidence(sim,e)
  if received.is_empty() or received.band!=e.band or e.pos.distance_to(received.pos)>500 or not sim.Depth.clear(sim,e.pos,received.pos,e.band,12):return
  state.aim=received.pos;state.band=received.band;state.phase="windup";state.remaining=2. if e.type=="interceptor" else 2.5;state.hit=[]
  e.angle=e.pos.angle_to_point(state.aim);e.mode="BURST WINDUP" if e.type=="interceptor" else "PRESSURE CHARGE"
  sim._noise(e.pos,450.,"INTERCEPTOR WINDUP" if e.type=="interceptor" else "WARDEN CHARGE",state.remaining,e.band)
  # Only local physical reception earns this consequential cue.
  for id in sim.units.size():
   var u=sim.units[id]
   if not u.alive:continue
   var arrivals=sim.band_acoustics[u.band].arrivals(u.pos,e.pos,450.*sim.Depth.transmission(u,e))
   if arrivals.is_empty():continue
   var direction=u.pos.direction_to(arrivals[0].goal)
   sim.events.append({"type":"carrier_received" if e.type=="interceptor" else "factory","receiver":id,"pos":u.pos+direction*180.,"direction":direction,"time":sim.elapsed})
  return
 state.remaining=maxf(0.,state.remaining-dt)
 if state.phase=="windup":
  e.mode="BURST WINDUP" if e.type=="interceptor" else "PRESSURE CHARGE"
  if state.remaining>0:return
  if e.type=="interceptor":state.phase="burst";state.remaining=2.
  else:
   if sim.Depth.clear(sim,e.pos,state.aim,state.band,12) and state.patches.size()<2:state.patches.append({"pos":state.aim,"band":state.band,"remaining":6.,"radius":85.})
   state.phase="recovery";state.remaining=4.;state.cooldown=10.;sim._noise(e.pos,650.,"WARDEN PRESSURE",1.,e.band)
 elif state.phase=="burst":
  e.mode="COMMITTED BURST"
  var next:Vector2=e.pos.move_toward(state.aim,200.*dt)
  if sim.Depth.clear(sim,e.pos,next,e.band,16):e.vel=(next-e.pos)/dt;e.pos=next
  else:state.remaining=0.
  for id in sim.units.size():
   var u=sim.units[id]
   if u.alive and id not in state.hit and sim.Depth.overlap(e,u) and u.pos.distance_to(e.pos)<35 and sim.Depth.clear(sim,e.pos,u.pos,e.band):
    state.hit.append(id)
    if id==0:sim.hull=maxf(0.,sim.hull-20.)
    else:u.battery=maxf(0.,u.battery-30.)
  var load=sim.Choir.body(sim)
  if not load.is_empty() and load.alive and 3 not in state.hit and sim.Depth.overlap(e,load) and load.pos.distance_to(e.pos)<35:state.hit.append(3);sim.Choir.damage(sim,20.)
  if state.remaining<=0 or e.pos.distance_to(state.aim)<2:state.phase="recovery";state.remaining=4.;state.cooldown=8.
 elif state.phase=="recovery":
  e.mode="BURST RECOVERY" if e.type=="interceptor" else "PRESSURE RECOVERY"
  if state.remaining<=0:state.phase="idle"
static func damage_patch(sim,patch:Dictionary,dt:float):
 for id in sim.units.size():
  var u=sim.units[id]
  if u.alive and patch.band in sim.Depth.occupied(u) and u.pos.distance_to(patch.pos)<patch.radius and sim.Depth.clear(sim,patch.pos,u.pos,patch.band):
   if id==0:sim.hull=maxf(0.,sim.hull-8.*dt)
   else:u.battery=maxf(0.,u.battery-10.*dt)
 var load=sim.Choir.body(sim)
 if not load.is_empty() and load.alive and patch.band in sim.Depth.occupied(load) and load.pos.distance_to(patch.pos)<patch.radius and sim.Depth.clear(sim,patch.pos,load.pos,patch.band):sim.Choir.damage(sim,8.*dt)
static func patches(sim)->Array:
 var result=[]
 # Presentation receives only a currently visible pressure field, not hidden aim.
 for e in sim.sirens:
  if e.get("type","")!="warden":continue
  for patch in e.industry.patches:
   if sim.visible(patch.pos,patch.band):result.append(patch.duplicate())
 return result
static func valid(data:Dictionary)->bool:
 for e in data.sirens:
  if e.get("type","") not in ROLES:
   if e.has("industry"):return false
   continue
  var state=e.get("industry")
  if not state is Dictionary or state.size()!=7 or state.get("phase") not in ["idle","windup","burst","recovery"] or not state.get("aim") is Vector2 or not state.aim.is_finite() or state.get("band") not in [0,1,2] or not state.get("patches") is Array or state.patches.size()>2 or not state.get("hit") is Array or state.hit.size()>4:return false
  for key in ["remaining","cooldown"]:
   if not number(state.get(key)) or state[key]<0 or state[key]>(4. if key=="remaining" else 10.):return false
  for id in state.hit:
   if not id is int or id not in [0,1,2,3]:return false
  for patch in state.patches:
   if not patch is Dictionary or patch.size()!=4 or not patch.get("pos") is Vector2 or not patch.pos.is_finite() or patch.get("band") not in [0,1,2] or not number(patch.get("remaining")) or patch.remaining<=0 or patch.remaining>6 or patch.get("radius")!=85.:return false
 return true
static func number(n)->bool:return (n is int or n is float) and is_finite(n)
