extends RefCounted
# One bounded, uncertain received area per listener. Relays never sample craft.
const ROLES=["buoy","relay"]
const LIFETIME=12.0
const GRID=160.0
static func initial()->Dictionary:return {"packet":{},"charge":0.,"cooldown":0.,"last":""}
static func initialize(sim):
 for e in sim.sirens:
  if e.get("type","") in ROLES:e["network"]=initial()
static func key(p:Dictionary)->String:return "%d:%.6f"%[p.origin,p.born]
static func link(sim,a:Dictionary,b:Dictionary)->bool:
 return not sim.band_acoustics[a.band].arrivals(a.pos,b.pos,700.*sim.Depth.transmission(a,b)).is_empty()
static func heard(sim,e:Dictionary)->Dictionary:
 var candidates=[]
 for id in sim.units.size():
  var u=sim.units[id]
  if u.alive and e.band in sim.Depth.occupied(u) and sim.propulsion_speed(u)>12:
   candidates.append({"pos":u.pos,"radius":minf(650.,sim.motion_radius(id)*1.6)})
 for noise in sim.noises:
  if noise.band==e.band and noise.label in ["ACTIVE SONAR","CAMERA","DISRUPTION","KNOCKDOWN","TORPEDO RUN","DECOY","RECOVERY WINCH","REACH MACHINERY"]:candidates.append(noise)
 for candidate in candidates:
  var arrivals=sim.band_acoustics[e.band].arrivals(e.pos,candidate.pos,candidate.radius)
  if arrivals.is_empty():continue
  var arrival=arrivals[0];var point=(candidate.pos if arrival.direct else arrival.goal)/GRID
  point=(point.round()*GRID).clamp(Vector2.ONE*80,sim.world_size()-Vector2.ONE*80)
  return {"point":point,"band":e.band,"born":sim.elapsed,"expires":sim.elapsed+LIFETIME,"origin":sim.sirens.find(e),"hops":0}
 return {}
static func advance(sim,dt:float):
 var dispatch=[]
 for e in sim.sirens:
  if e.get("type","") not in ROLES:continue
  var state=e.network
  state.cooldown=maxf(0.,state.cooldown-dt);e.vel=Vector2.ZERO;e.lock=0.;e.target=-1
  if e.get("pin_time",0)>0:e.pin_time=maxf(0.,e.pin_time-dt)
  if e.stun>0:
   e.stun=maxf(0.,e.stun-dt);state.packet={};state.charge=0.;e.mode="PINNED" if e.get("pin_time",0)>0 else "DISRUPTED";continue
  if not state.packet.is_empty() and state.packet.expires<=sim.elapsed:state.packet={};state.charge=0.
  if e.type=="buoy" and state.packet.is_empty() and state.cooldown<=0:
   var packet=heard(sim,e)
   if not packet.is_empty():
    state.packet=packet;state.last=key(packet);state.charge=0.
    sim._noise(e.pos,320.,"BUOY REPORT WINDUP",2.,e.band)
  if state.packet.is_empty():e.mode="LISTENING" if e.type=="buoy" else "RELAY IDLE";continue
  if state.cooldown>0:e.mode="LISTENING" if e.type=="buoy" else "RELAY IDLE";continue
  e.mode="BUOY CHARGING" if e.type=="buoy" else "RELAY CHARGING";state.charge+=dt
  if state.charge+0.000001>=(2. if e.type=="buoy" else 3.):
   dispatch.append({"sender":e,"packet":state.packet.duplicate(true)})
   state.packet={};state.charge=0.;state.cooldown=LIFETIME
   sim._noise(e.pos,700.,"RELAY FORWARD",1.5,e.band)
 # Separate receive/forward turns prevent array-order zero-delay propagation.
 for sent in dispatch:
  var packet=sent.packet;var sender=sent.sender
  for peer in sim.sirens:
   if peer==sender or peer.stun>0 or not link(sim,sender,peer):continue
   if peer.get("type","")=="relay":
    var state=peer.network
    if packet.hops>=2 or state.cooldown>0 or not state.packet.is_empty() or state.last==key(packet):continue
    state.packet=packet.duplicate(true);state.packet.hops+=1;state.last=key(packet);state.charge=0.
    sim._noise(peer.pos,380.,"BUOY REPORT WINDUP",3.,peer.band)
   elif peer.get("type","") not in ROLES and peer.get("target",-1)<0:
    peer.goal=packet.point;peer["last_known"]=packet.point;peer["known_band"]=packet.band
    peer["attention_time"]=minf(8.,packet.expires-sim.elapsed);peer.suspicion=maxf(peer.suspicion,.35);peer.mode="INVESTIGATE";peer.path_time=0.;peer.route=[]
static func feedback(sim)->Array:
 var rows=[]
 for id in sim.contacts:
  var c=sim.contacts[id]
  if c.get("type","") in ROLES:rows.append({"key":id,"type":c.type,"pos":c.pos,"band":c.band,"time":c.time,"mode":c.mode})
 return rows
static func valid(data:Dictionary)->bool:
 for e in data.sirens:
  if e.get("type","") not in ROLES:
   if e.has("network"):return false
   continue
  if not e.get("network") is Dictionary:return false
  var state=e.network
  if state.size()!=4 or not state.get("packet") is Dictionary or not state.get("last") is String or state.last.length()>64:return false
  for k in ["charge","cooldown"]:
   if not (state.get(k) is int or state.get(k) is float) or not is_finite(state[k]) or state[k]<0 or state[k]>(3. if k=="charge" else LIFETIME):return false
  var packet=state.packet
  if packet.is_empty():continue
  if packet.size()!=6 or not packet.get("point") is Vector2 or not packet.point.is_finite() or not Rect2(Vector2.ZERO,data.mission.world_size).has_point(packet.point):return false
  if packet.get("band") not in [0,1,2] or not packet.get("origin") is int or packet.origin<0 or packet.origin>=data.sirens.size() or not packet.get("hops") is int or packet.hops<0 or packet.hops>2:return false
  for k in ["born","expires"]:
   if not (packet.get(k) is int or packet.get(k) is float) or not is_finite(packet[k]):return false
  if packet.born<0 or packet.born>data.elapsed or packet.expires<=data.elapsed or absf(packet.expires-packet.born-LIFETIME)>.001:return false
 return true
