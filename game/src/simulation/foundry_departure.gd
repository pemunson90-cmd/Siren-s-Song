extends RefCounted
# One authored deep-transit projection, below the pilot's operating plane.
# Its lamp is a sight observation; its motor uses normal supported sound paths.
# Not a solid obstacle, shield, target or general traffic/escort system.
const WARMUP=20.0
const LAUNCH=24.0
const SPEED=18.0
const ORIGIN=Vector2(1320,770)
const DESTINATION=Vector2(1540,880)
static func end_time()->float:return LAUNCH+ORIGIN.distance_to(DESTINATION)/SPEED
static func valid(mission:Dictionary,time)->bool:
 if not mission.has("departure_revision"):return true
 return mission.id==3 and mission.get("acoustic_revision",0)==1 and mission.get("thermal_revision",0)==1 and mission.departure_revision is int and mission.departure_revision==1 and (time is float or time is int) and is_finite(float(time)) and time>=0
static func active(sim)->bool:
 return sim.mission.get("departure_revision",0)==1 and sim.outcome.is_empty() and sim.elapsed>=WARMUP and sim.elapsed<end_time()
static func position(time:float)->Vector2:return ORIGIN.move_toward(DESTINATION,maxf(0,time-LAUNCH)*SPEED)
static func radius(time:float)->float:return 700.0 if time>=LAUNCH else 400.0
static func emit(sim)->void:
 # Derive cadence from the saved simulation clock; no new restore timer or
 # catch-up burst. Existing event decay/pause semantics remain authoritative.
 if active(sim) and roundi(sim.elapsed/sim.STEP)%12==0:
  sim._noise(position(sim.elapsed),radius(sim.elapsed),"DEEP MOTOR",0.25,2)
  # Reuse the existing industrial timbre, at most once per six seconds and
  # only for the selected receiver. Pan by its received bearing, not truth.
  if roundi(sim.elapsed/sim.STEP)%360==0:
   var report=feedback(sim)
   if not report.is_empty() and report.receivers.has(sim.selected):
    var sector=["E","SE","S","SW","W","NW","N","NE"].find(report.receivers[sim.selected])
    sim.events.append({"type":"factory","pos":sim.units[sim.selected].pos+Vector2.from_angle(sector*PI/4)*220,"industrial":true})
static func feedback(sim)->Dictionary:
 if not active(sim):return {}
 var source=position(sim.elapsed);var receivers={};var lit=false
 for i in sim.units.size():
  var u=sim.units[i]
  if not u.alive:continue
  var options=preload("res://src/simulation/thermal_front.gd").arrivals(sim,u,source,radius(sim.elapsed)*sim.Depth.transmission(u,{"band":2}))
  if not options.is_empty():
   # A bent arrival supplies its first bearing, never a through-rock source dot.
   var arrival=options[0]
   for option in options:
    if option.strength>arrival.strength:arrival=option
   var angle=u.pos.angle_to_point(arrival.points[1])
   receivers[i]=["E","SE","S","SW","W","NW","N","NE"][posmod(roundi(angle/(PI/4)),8)]
  var sight=(240.0 if i==0 else 330.0)*(0.65 if sim.mission.darkness else 1.0)
  if u.pos.distance_to(source)<sight and sim.Depth.clear(sim,u.pos,source,u.band):lit=true
 if receivers.is_empty() and not lit:return {}
 var result={"moving":sim.elapsed>=LAUNCH,"receivers":receivers,"lit":lit}
 if lit:
  result["pos"]=source;result["angle"]=ORIGIN.angle_to_point(DESTINATION)
  result["fade"]=clampf((end_time()-sim.elapsed)/2.0,0,1)
 return result
