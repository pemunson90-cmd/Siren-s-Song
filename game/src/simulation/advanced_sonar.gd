extends RefCounted
const Depth=preload("res://src/simulation/depth_bands.gd")
const Equipment=preload("res://src/equipment/equipment_catalog.gd")
const Upgrades=preload("res://src/equipment/craft_upgrades.gd")
const Chart=preload("res://src/simulation/terrain_chart.gd")
const SOUND_SPEED=300.0 # Tactical time scale, bounded two-way travel; not calibrated ocean acoustics.
const MAX_HISTORY=72
const POWERS={"low":{"radius":440.,"cost":.4,"signature":750.},"high":{"radius":720.,"cost":1.2,"signature":1300.}}
static func initial()->Dictionary:
 return {"sector":"all","power":"low","pending":[],"history":[],"fixes":{},"clock":0.0,"listening_until":[-1.,-1.,-1.]}
static func configure(sim,args)->bool:
 if args.get("sector") not in ["all","forward"] or args.get("power") not in ["low","high"]:return false
 sim.sonar.sector=args.sector;sim.sonar.power=args.power
 sim.message="SONAR · %s · %s · next pulse uses selected heading"%[args.sector.to_upper(),args.power.to_upper()];return true
static func in_sector(origin:Vector2,point:Vector2,angle:float,sector:String)->bool:
 return sector=="all" or absf(angle_difference(angle,origin.angle_to_point(point)))<=PI/4
static func water_path(sim,receiver:Dictionary,source:Dictionary,radius:float)->Dictionary:
 var band=receiver.get("band",1)
 var reach=radius*Depth.transmission(receiver,source)
 var paths=sim.band_acoustics.get(band,sim.acoustic_paths).arrivals(receiver.pos,source.pos,reach)
 if paths.is_empty():return {}
 paths.sort_custom(func(a,b):return a.strength>b.strength)
 return paths[0]
static func emit(sim,station:int)->bool:
 var u=sim.units[station]
 if not u.transition.is_empty():sim.message="Settle depth before emitting";return false
 var settings=POWERS[sim.sonar.power];var prism=station==0 and Equipment.has(sim.mission.launch_equipment,0,"quietus_prism") and sim.sonar.sector=="forward"
 var cost=settings.cost*(2. if prism else 1.)*Upgrades.pulse_cost(sim.mission.launch_equipment,station)
 if (sim.oxygen if station==0 else u.battery)<cost:return false
 if station==0:sim.oxygen-=cost
 else:u.battery-=cost
 var radius=settings.radius*(1.4 if prism else 1.)
 # Receiver knows its own emission window, never how many hidden returns exist.
 sim.sonar.listening_until[station]=sim.elapsed+2*radius/SOUND_SPEED
 sim._noise(u.pos,settings.signature*(1.25 if prism else 1.),"ACTIVE SONAR",2.5,u.band)
 var sector=sim.sonar.sector;var angle=u.angle
 for id in sim.sirens.size():
  var enemy=sim.sirens[id]
  var path=water_path(sim,u,enemy,radius)
  if path.is_empty() or not in_sector(u.pos,path.points[1],angle,sector):continue
  # The returning packet contains only the emission-time reflection.
  sim.sonar.pending.append({"kind":"echo","due":sim.elapsed+2*path.length/SOUND_SPEED,"time":sim.elapsed,"station":station,"emitter_band":u.band,"enemy":id,"pos":enemy.pos,"band":enemy.band,"type":enemy.get("type","patroller"),"tone":enemy.acoustic_tone,"origin":u.pos,"direction":u.pos.direction_to(path.points[1]),"direct":path.direct})
 var chart=sim.depth_charts.get(u.band)
 if chart!=null:
  var sample=Chart.new();var config=sim.mission.duplicate()
  config["world_size"]=sim.world_size();config["launch_seed"]=Rect2(u.pos,Vector2.ZERO)
  sample.configure(config,Depth.shapes(sim,u.band));sample.observe([{"pos":u.pos,"radius":radius}],{})
  sim.sonar.pending.append({"kind":"terrain","due":sim.elapsed+2*radius/SOUND_SPEED,"time":sim.elapsed,"station":station,"band":u.band,"origin":u.pos,"angle":angle,"sector":sector,"chart":sample.snapshot()})
 return true
static func advance(sim,dt):
 for n in range(sim.sonar.pending.size()-1,-1,-1):
  var packet=sim.sonar.pending[n]
  if packet.due>sim.elapsed:continue
  sim.sonar.pending.remove_at(n)
  if not sim.units[packet.station].alive:continue
  # Receiver movement can miss a return; no magical fleet-wide remote receiver.
  if not Depth.overlap(sim.units[packet.station],{"band":packet.band if packet.kind=="terrain" else packet.emitter_band}) or sim.units[packet.station].pos.distance_to(packet.origin)>160:continue
  if packet.kind=="terrain":
   var chart=sim.depth_charts.get(packet.band)
   if chart==null:continue
   var returned=packet.chart
   for cell in returned.clear_cells:
    if in_sector(packet.origin,Vector2(cell)*40+Vector2(20,20),packet.angle,packet.sector):chart._clear(cell)
   for cell in returned.return_cells:
    if in_sector(packet.origin,Vector2(cell)*40+Vector2(20,20),packet.angle,packet.sector) and not chart.clear_cells.has(cell) and not _opened_since(sim,Rect2(Vector2(cell)*40,Vector2(40,40)),packet.time):chart._return(cell)
   for segment in returned.surface_segments:
    if not in_sector(packet.origin,(segment[0]+segment[1])*.5,packet.angle,packet.sector) or _opened_since(sim,Rect2(segment[0],Vector2.ZERO).expand(segment[1]).grow(1),packet.time):continue
    var key=chart._segment_key(segment)
    if not chart._surface_keys.has(key):chart._surface_keys[key]=true;chart.surface_segments.append(segment);chart.generation+=1
   if packet.band==1:sim.mission["terrain_chart"]=chart.snapshot()
  elif packet.kind=="echo":
   if packet.direct and (not sim.contacts.has(packet.enemy) or sim.contacts[packet.enemy].time<=packet.time):
    sim.contacts[packet.enemy]={"pos":packet.pos,"time":packet.time,"mode":"ECHO","lock":0.0,"angle":0.0,"target":-1,"type":packet.type,"band":packet.band,"seen_by":[],"source":"active","confidence":.9}
   _remember(sim,{"station":packet.station,"enemy":packet.enemy,"origin":packet.origin,"direction":packet.direction,"time":packet.time,"band":packet.band if packet.direct else -1,"confidence":.9 if packet.direct else .35,"tone":packet.tone,"classification":packet.type if packet.direct else "DIFFRACTED ECHO","direct":packet.direct,"kind":"echo"})
 sim.sonar.clock-=dt
 if sim.sonar.clock>0:return
 sim.sonar.clock=.6
 for station in sim.units.size():
  var u=sim.units[station]
  if not u.alive:continue
  var own=sim.motion_radius(station)
  var masking=1.+own/180.
  for id in sim.sirens.size():
   var enemy=sim.sirens[id]
   # Propulsion and genuine sweeper emission, never fabricated ghosts.
   var emission=900.0 if enemy.get("sweep",{}).get("emitting",0)>0 else 650.0 if not enemy.get("sweep",{}).get("strike",{}).is_empty() else 350.0 if enemy.get("sweep",{}).get("charge",0)>0 else 510.0
   var industry=enemy.get("type","") in ["interceptor","warden"]
   if industry:emission=450. if enemy.industry.phase=="windup" else 510. if enemy.industry.phase=="burst" else 110.
   var network=enemy.get("type","") in ["buoy","relay"]
   if network:emission=420. if enemy.get("network",{}).get("charge",0)>0 else 95.
   var path=water_path(sim,u,enemy,emission/masking)
   if path.is_empty():continue
   var direction=u.pos.direction_to(path.points[1])
   var confidence=clampf((path.strength-1.)*.45,.12,.85)
   var row={"station":station,"enemy":id,"origin":u.pos,"direction":direction,"time":sim.elapsed,"band":-1,"confidence":confidence,"tone":enemy.acoustic_tone,"classification":("ACTIVE SWEEP" if enemy.get("sweep",{}).get("emitting",0)>0 else "RETURN CHARGE" if not enemy.get("sweep",{}).get("strike",{}).is_empty() else "SWEEP WINDUP" if enemy.get("sweep",{}).get("charge",0)>0 else "MACHINERY" if confidence<.5 else "PROPULSION"),"direct":path.direct,"kind":"bearing"}
   if industry:
    row.classification=("BURST WINDUP" if enemy.type=="interceptor" else "PRESSURE CHARGE") if enemy.industry.phase=="windup" else "COMMITTED BURST" if enemy.industry.phase=="burst" else "STATION TONE"
   if network:
    row.classification=("LISTENER UPLINK" if enemy.type=="buoy" else "RELAY FORWARDING") if enemy.get("network",{}).get("charge",0)>0 else "STATION TONE"
    if enemy.get("network",{}).get("charge",0)>0 and not sim.sonar.history.any(func(old):return old.station==station and old.enemy==id and old.classification==row.classification and sim.elapsed-old.time<3.):
     sim.events.append({"type":"carrier_received" if enemy.type=="buoy" else "return_received","receiver":station,"direction":direction,"identity":"network","time":sim.elapsed})
   # Correlate an actual received motor tone; indistinguishable received
   # sources suppress positional inference instead of inventing a unique fix.
   var ambiguous=sim.sonar.history.any(func(old):return old.tone==row.tone and old.enemy!=id and sim.elapsed-old.time<=3.)
   if ambiguous:
    sim.sonar.fixes.erase(id)
    for old in sim.sonar.history:
     if old.tone==row.tone:sim.sonar.fixes.erase(old.enemy)
   if path.direct and not ambiguous:
    for previous in sim.sonar.history:
     if previous.tone!=row.tone or not previous.direct or previous.kind!="bearing" or sim.elapsed-previous.time>3.0:continue
     var baseline=u.pos.distance_to(previous.origin)
     var cross=absf(direction.cross(previous.direction))
     if baseline<75 or cross<.14:continue
     var fix=Geometry2D.line_intersects_line(u.pos,direction,previous.origin,previous.direction)
     if fix==null or fix.distance_to(u.pos)>510 or (fix-u.pos).dot(direction)<0:continue
     # Independent rays support an uncertain fix, never live tracking.
     sim.sonar.fixes[id]={"pos":fix,"time":sim.elapsed,"confidence":minf(confidence,previous.confidence),"band":-1}
   if row.classification=="ACTIVE SWEEP" and not sim.sonar.history.any(func(old):return old.enemy==id and old.station==station and old.classification=="ACTIVE SWEEP" and sim.elapsed-old.time<2.):
    sim.events.append({"type":"sweep_received","receiver":station,"direction":direction,"time":sim.elapsed})
   _remember(sim,row)
 for id in sim.sonar.fixes.keys():
  if sim.elapsed-sim.sonar.fixes[id].time>3:sim.sonar.fixes.erase(id)
static func _opened_since(sim,rect:Rect2,time:float)->bool:
 for opening in sim.mission.depth_openings:
  if opening.time>time and opening.rect.grow(1).intersects(rect,true):return true
 return false
static func _remember(sim,row):
 sim.sonar.history.append(row)
 if sim.sonar.history.size()>MAX_HISTORY:sim.sonar.history.pop_front()
static func feedback(sim,station:int)->Dictionary:
 var rows=[]
 for row in sim.sonar.history:
  if row.station==station and sim.elapsed-row.time<=20:rows.append(row.duplicate())
 return {"rows":rows,"own_noise":sim.motion_radius(station),"sector":sim.sonar.sector,"power":sim.sonar.power,"listening":maxf(0.,sim.sonar.listening_until[station]-sim.elapsed)}
static func valid(data)->bool:
 var fitting=data.mission.get("launch_equipment",{})
 if not fitting is Dictionary:return false
 var state=data.get("sonar")
 if not state is Dictionary or not state.has_all(["sector","power","pending","history","fixes","clock","listening_until"]) or state.sector not in ["all","forward"] or state.power not in ["low","high"]:return false
 if not state.pending is Array or state.pending.size()>128 or not state.history is Array or state.history.size()>MAX_HISTORY or not state.fixes is Dictionary:return false
 if not _number(state.clock) or state.clock<0 or state.clock>.601:return false
 var time=data.get("elapsed",0.)
 if not state.listening_until is Array or state.listening_until.size()!=3:return false
 for station in 3:
  var until=state.listening_until[station]
  var reach=POWERS.high.radius*(1.4 if station==0 and Equipment.has(fitting,0,"quietus_prism") else 1.)
  if not _number(until) or (until!=-1. and (until<0 or until>time+2*reach/SOUND_SPEED+.001)):return false
 for packet in state.pending:
  if not packet is Dictionary or not packet.has_all(["kind","due","time","station","band","origin"]) or packet.kind not in ["echo","terrain"]:return false
  if not _number(packet.due) or not _number(packet.time) or packet.time<0 or packet.time>time or packet.due<time or packet.due>time+2*POWERS.high.radius*(1.4 if packet.get("station",-1)==0 and Equipment.has(fitting,0,"quietus_prism") else 1.)/SOUND_SPEED+.001:return false
  if not packet.station is int or packet.station<0 or packet.station>2 or not packet.band is int or packet.band<0 or packet.band>2 or not packet.origin is Vector2 or not packet.origin.is_finite():return false
  if packet.kind=="echo":
   if not packet.get("emitter_band") is int or packet.emitter_band not in [0,1,2] or not packet.get("enemy") is int or packet.enemy<0 or packet.enemy>=data.sirens.size() or not packet.get("pos") is Vector2 or not packet.pos.is_finite() or not _number(packet.get("tone")) or packet.tone<40 or packet.tone>2000 or not packet.get("direction") is Vector2 or not packet.direction.is_finite() or packet.direction.length()<.99 or packet.direction.length()>1.01 or not packet.get("direct") is bool or packet.get("type") not in ["patroller","sentinel","hunter","sweeper","buoy","relay","interceptor","warden"]:return false
  else:
   var config=data.mission.duplicate();config["world_size"]=data.mission.get("world_size",Vector2(1600,960))
   if packet.get("sector") not in ["all","forward"] or not _number(packet.get("angle")) or not Chart.valid_state(packet.get("chart"),config):return false
 for row in state.history:
  if not row is Dictionary or not row.has_all(["station","enemy","origin","direction","time","band","confidence","classification","direct","kind","tone"]):return false
  if not _number(row.tone) or row.tone<40 or row.tone>2000:return false
  if not row.station is int or row.station<0 or row.station>2 or not row.enemy is int or row.enemy<0 or row.enemy>=data.sirens.size():return false
  if not row.origin is Vector2 or not row.origin.is_finite() or not row.direction is Vector2 or not row.direction.is_finite() or row.direction.length()<.99 or row.direction.length()>1.01:return false
  if not _number(row.time) or row.time<0 or row.time>time or not _number(row.confidence) or row.confidence<0 or row.confidence>1 or row.band not in [-1,0,1,2] or not row.direct is bool or not row.classification is String or row.kind not in ["echo","bearing"]:return false
 for id in state.fixes:
  var fix=state.fixes[id]
  if not id is int or id<0 or id>=data.sirens.size() or not fix is Dictionary or not fix.get("pos") is Vector2 or not fix.pos.is_finite() or not _number(fix.get("time")) or fix.time<0 or fix.time>time or not _number(fix.get("confidence")) or fix.confidence<0 or fix.confidence>1 or fix.get("band")!=-1:return false
 return true
static func _number(value)->bool:return (value is int or value is float) and is_finite(float(value))
