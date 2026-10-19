extends RefCounted
const SURVEY=preload("res://src/simulation/world_region.gd")
static func observe(sim,active:bool=false)->void:
 var m=sim.mission
 if m.get("expedition_revision",0)!=1:return
 if not active and sim.elapsed<float(m.next_signal_time):return
 if not active:m.next_signal_time=sim.elapsed+0.75
 var observations=[]
 for source in m.signal_sources:
  var receivers=sim.passive_receivers(source.pos)
  if not receivers.is_empty() or (active and SURVEY.survey_visible(sim,source.pos)):_locate(sim,source)
  for id in sim.units.size():
   var unit=sim.units[id]
   if not unit.alive:continue
   var arrivals=sim.acoustic_paths.arrivals(unit.pos,source.pos,900.0)
   if arrivals.is_empty():continue
   var arrival=arrivals[0];var direction:Vector2=unit.pos.direction_to(arrival.goal)
   observations.append({"receiver":id,"origin":unit.pos,"direction":direction,"time":sim.elapsed,"uncertainty":0.18 if arrival.direct else 0.65,"label":source.label})
 # Retain old samples as old samples when a receiver leaves the carrier's reach.
 for old in m.signal_observations:
  if sim.elapsed-old.time<30 and not observations.any(func(r):return r.receiver==old.receiver and r.label==old.label):observations.append(old)
 m.signal_observations=observations
static func _locate(sim,source:Dictionary)->void:
 if source.located:return
 source.located=true
 sim.mission.expedition_facts[source.id]=source.evidence
 var objective={"pos":source.pos,"name":source.label,"site_id":source.id,"captured":not source.get("confirm",false),"evidence":source.evidence,"optical":"divergence_"+source.id}
 if source.get("confirm",false):objective.merge({"kind":"receiver","required_unit":0,"duration":4.0})
 sim.mission.objectives.append(objective)
 sim.message="%s located · %s"%[source.label,"Quietus LISTEN confirms the rendezvous" if source.get("confirm",false) else "route interpretation recorded; choose its physical exit or investigate the other carrier"]
static func readings(sim)->Array:
 var result=sim.mission.get("signal_observations",[]).duplicate(true)
 for reading in result:reading["age"]=maxf(0,sim.elapsed-reading.time)
 return result
static func corridors(sim)->Array:
 var result=[]
 for corridor in sim.mission.get("corridors",[]):
  var copy=corridor.duplicate(true)
  copy["available"]=sim.mission.expedition_facts.has(copy.route) if sim.mission.id==6 else (not sim.mission.objectives.is_empty() and sim.all_records())
  result.append(copy)
 return result
static func extract(sim)->void:
 var m=sim.mission
 if m.get("expedition_revision",0)!=1 or not sim.outcome.is_empty():return
 if sim.units[0].pos.distance_to(m.start)>180:m.withdrawal_armed=true
 if sim.units[0].vel.length()>=12:return
 for corridor in corridors(sim):
  if corridor.available and sim.units[0].pos.distance_to(corridor.pos)<65:
   m.chosen_route=corridor.route;m.recovered=true;sim.outcome="won";sim.paused=true;sim.message="%s reached · expedition archive recovered"%corridor.name;sim.events.append({"type":"extraction","pos":sim.units[0].pos});return
 if m.id==6 and m.withdrawal_armed and sim.units[0].pos.distance_to(m.extraction)<65:
  sim.outcome="withdrawn";sim.paused=true;sim.message="Incomplete withdrawal · field observations retained; no expedition route or module awarded"
static func valid(m:Dictionary,time:float)->bool:
 if not m.has("expedition_revision"):return m.id<6
 if not is_finite(time) or time<0:return false
 if m.id not in [6,7,8] or m.expedition_revision!=1:return false
 if not m.has_all(["signal_sources","signal_observations","expedition_facts","next_signal_time","chosen_route","recovered","withdrawal_armed","corridors"]):return false
 if not m.signal_sources is Array or m.signal_sources.size()>2 or not m.signal_observations is Array or m.signal_observations.size()>6 or not m.expedition_facts is Dictionary:return false
 if not m.recovered is bool or not m.withdrawal_armed is bool or m.chosen_route not in ["","deep","shelf"]:return false
 if not (m.next_signal_time is float or m.next_signal_time is int) or not is_finite(m.next_signal_time) or m.next_signal_time<0 or m.next_signal_time>time+0.751:return false
 var dimensions=preload("res://src/simulation/world_region.gd").size_of(m)
 for source in m.signal_sources:
  if not source is Dictionary or not source.has_all(["id","label","pos","evidence","located"]) or source.id not in ["deep","shelf","rendezvous"] or not source.label is String or not source.evidence is String or not source.located is bool or not source.pos is Vector2 or not SURVEY.contains(source.pos,dimensions):return false
 var sources={}
 for source in m.signal_sources:
  if sources.has(source.id):return false
  sources[source.id]=source
 var expected=["deep","shelf"] if m.id==6 else (["rendezvous"] if m.id==7 else [])
 if sources.size()!=expected.size() or not expected.all(func(id):return sources.has(id)):return false
 for fact in m.expedition_facts:
  if not sources.has(fact) or not sources[fact].located or m.expedition_facts[fact]!=sources[fact].evidence:return false
 for source in m.signal_sources:
  if source.located!=m.expedition_facts.has(source.id):return false
  var sites=m.objectives.filter(func(o):return o.get("site_id","")==source.id and o.pos==source.pos)
  if sites.size()!=(1 if source.located else 0):return false
 for reading in m.signal_observations:
  if not reading is Dictionary or not reading.has_all(["receiver","origin","direction","time","uncertainty","label"]):return false
  if not reading.receiver is int or reading.receiver<0 or reading.receiver>2 or not reading.origin is Vector2 or not SURVEY.contains(reading.origin,dimensions) or not reading.direction is Vector2 or not reading.direction.is_finite() or reading.direction.length()>1.001:return false
  for key in ["time","uncertainty"]:
   if not (reading[key] is float or reading[key] is int) or not is_finite(reading[key]):return false
  if reading.time<0 or reading.time>time or reading.uncertainty<0 or reading.uncertainty>PI or not reading.label is String:return false
 if not m.corridors is Array or m.corridors.is_empty() or m.corridors.size()>2:return false
 for corridor in m.corridors:
  if not corridor is Dictionary or not corridor.has_all(["pos","name","route"]) or not corridor.pos is Vector2 or not SURVEY.contains(corridor.pos,dimensions) or not corridor.name is String or corridor.route not in ["deep","shelf"]:return false
 if m.recovered and (m.chosen_route.is_empty() or (m.id==6 and not m.expedition_facts.has(m.chosen_route)) or (m.id!=6 and (m.objectives.is_empty() or not m.objectives.all(func(o):return o.captured)))):return false
 return true
