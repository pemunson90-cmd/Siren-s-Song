extends RefCounted
const Depth=preload("res://src/simulation/depth_bands.gd")
const Sonar=preload("res://src/simulation/advanced_sonar.gd")
static func advance(sim,enemy,dt):
 if not enemy.has("sweep"):enemy.sweep={"cooldown":0.,"charge":0.,"emitting":0.,"pending":[],"strike":{}}
 enemy["attention_time"]=maxf(0.,enemy.get("attention_time",0.)-dt)
 var state=enemy.sweep
 state.emitting=maxf(0,state.emitting-dt)
 if enemy.stun>0 or enemy.get("pin_time",0)>0:
  enemy.stun=maxf(0,enemy.stun-dt);state.charge=0.;state.pending=[];state.strike={};enemy.mode="DISRUPTED";enemy.lock=0.;enemy.target=-1;return
 for n in range(state.pending.size()-1,-1,-1):
  var packet=state.pending[n]
  if packet.due>sim.elapsed:continue
  state.pending.remove_at(n)
  if enemy.pos.distance_to(packet.origin)>160 or packet.emitter_band not in Depth.occupied(enemy):continue
  enemy["last_known"]=packet.pos;enemy.goal=packet.pos;enemy["known_band"]=packet.band;enemy["attention_time"]=7.;enemy.suspicion=.6
  state.strike={"pos":packet.pos,"band":packet.band,"remaining":1.5};enemy.mode="RETURN STRIKE"
  # A single peer receives a local stale report over its own physical water path.
  for peer in sim.sirens:
   if peer==enemy or peer.stun>0 or peer.get("attention_time",0)>0:continue
   if Sonar.water_path(sim,peer,enemy,430).is_empty():continue
   peer.goal=packet.pos;peer["last_known"]=packet.pos;peer["known_band"]=packet.band;peer["attention_time"]=5.;peer.path_time=0.;peer.route=[];break
 if not state.strike.is_empty():
  state.strike.remaining-=dt
  if state.strike.remaining<=0:
   for i in sim.units.size():
    var u=sim.units[i]
    if u.alive and state.strike.band in Depth.occupied(u) and not Sonar.water_path(sim,enemy,{"pos":state.strike.pos,"band":state.strike.band},600.).is_empty() and u.pos.distance_to(state.strike.pos)<55 and Depth.clear(sim,enemy.pos,u.pos,state.strike.band):
     if i==0:sim.hull=maxf(0,sim.hull-22)
     else:u.battery=maxf(0,u.battery-28)
   state.strike={};enemy.mode="SEARCH"
 state.cooldown=maxf(0,state.cooldown-dt)
 if state.cooldown<=0:
  state.charge+=dt;enemy.mode="SWEEP CHARGING"
  if state.charge>=2.5:
   state.charge=0.;state.cooldown=12.;state.emitting=1.5;enemy.mode="ACTIVE SWEEP"
   sim._noise(enemy.pos,900.,"ACTIVE SWEEP",1.5,enemy.band)
   for i in sim.units.size():
    var u=sim.units[i]
    if not u.alive:continue
    var path=Sonar.water_path(sim,enemy,u,600.)
    if path.is_empty() or not path.direct:continue
    state.pending.append({"origin":enemy.pos,"emitter_band":enemy.band,"pos":u.pos,"band":u.transition.get("to",u.band),"due":sim.elapsed+2*path.length/Sonar.SOUND_SPEED,"time":sim.elapsed})
 Depth.pursue(sim,enemy)
 if enemy.get("attention_time",0)>0 and enemy.pos.distance_to(enemy.goal)>155:
  enemy.route=sim.path(enemy.pos,enemy.goal);sim._move(enemy,dt,38.,false,false)
 else:enemy.vel=Vector2.ZERO
static func valid(enemy,time)->bool:
 if not enemy.has("sweep"):return true
 var state=enemy.sweep
 if enemy.get("type")!="sweeper" or not state is Dictionary or not state.has_all(["cooldown","charge","emitting","pending","strike"]):return false
 for key in ["cooldown","charge","emitting"]:
  if not Sonar._number(state[key]) or state[key]<0:return false
 if state.cooldown>12 or state.charge>2.5 or state.emitting>1.5 or not state.pending is Array or state.pending.size()>3 or not state.strike is Dictionary:return false
 for packet in state.pending:
  if not packet is Dictionary or not packet.get("origin") is Vector2 or not packet.origin.is_finite() or packet.get("emitter_band") not in [0,1,2] or not packet.get("pos") is Vector2 or not packet.pos.is_finite() or packet.get("band") not in [0,1,2] or not Sonar._number(packet.get("due")) or packet.due<time or packet.due>time+4 or not Sonar._number(packet.get("time")) or packet.time<0 or packet.time>time:return false
 if not state.strike.is_empty():
  if not state.strike.get("pos") is Vector2 or not state.strike.pos.is_finite() or state.strike.get("band") not in [0,1,2] or not Sonar._number(state.strike.get("remaining")) or state.strike.remaining<=0 or state.strike.remaining>1.5:return false
 return true
