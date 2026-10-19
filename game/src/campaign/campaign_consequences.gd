extends RefCounted
# Small recovered campaign extension. Notes never enter launch knowledge or grants.
const ITEMS=["quietus_correlator","drone_sampler"]
const EMPTY_FIT={"quietus":"","drone_a":"","drone_b":""}
static func upgrade(previous:Dictionary)->Dictionary:
 var p=previous.duplicate(true)
 if p.is_empty():return p
 p.version=2
 for key in ["notes","references"]:
  if not p.has(key):p[key]={}
 for key in ["entitlements","history"]:
  if not p.has(key):p[key]=[]
 if not p.has("selected_thread"):p.selected_thread=""
 return p
static func retain(previous:Dictionary,mission:Dictionary)->Dictionary:
 var p=upgrade(previous)
 if p.is_empty():return p
 for key in mission.get("expedition_facts",{}):p.notes[key]=mission.expedition_facts[key]
 return p
static func recovered(previous:Dictionary,mission:Dictionary)->Dictionary:
 var p=retain(previous,mission)
 if p.is_empty() or not mission.get("recovered",false):return p
 if mission.get("consequence_revision",0)==1:
  if mission.id==7 and cadence_valid(mission.get("measured_reference",[])):
   if "quietus_correlator" not in p.entitlements:p.entitlements.append("quietus_correlator")
   p.references.return_cadence=mission.measured_reference.duplicate()
  if mission.id==8 and mission.objectives.all(func(o):return o.captured):
   if "drone_sampler" not in p.entitlements:p.entitlements.append("drone_sampler")
 if mission.id>=9:p=commit(p,mission.id,mission.get("launch_equipment",EMPTY_FIT))
 if mission.id==11 and not p.facts.has("confluence_route") and mission.get("chosen_route","") in ["concealed","overt"]:p.facts.confluence_route=mission.chosen_route
 return p
static func context(p:Dictionary)->Dictionary:
 return {"thread":p.get("selected_thread",""),"completed":p.get("completed",[]).duplicate(),"facts":p.get("facts",{}).duplicate(true),"references":p.get("references",{}).duplicate(true)}
static func commit(previous:Dictionary,id:int,fitted:Dictionary)->Dictionary:
 var p=upgrade(previous)
 if p.is_empty() or id<9:return p
 if p.selected_thread.is_empty():p.selected_thread="deep" if id==9 else "shelf"
 # Only successful recovery calls this commitment. Replays keep the first outcome.
 if not p.history.any(func(h):return h.mission==id):p.history.append({"mission":id,"thread":p.selected_thread,"fitted":fitted.duplicate(true)})
 return p
static func fitting_valid(fit)->bool:
 if not fit is Dictionary or fit.size()!=3 or not fit.has_all(EMPTY_FIT.keys()):return false
 if fit.quietus not in ["","quietus_correlator"]:return false
 for slot in ["drone_a","drone_b"]:
  if fit[slot] not in ["","drone_sampler"]:return false
 return fit.drone_a.is_empty() or fit.drone_b.is_empty()
static func cadence_valid(value)->bool:
 if not value is Array or value.size()<2 or value.size()>8:return false
 for interval in value:
  if not (interval is int or interval is float) or not is_finite(interval) or interval<=0 or interval>10:return false
 return true
static func valid(p:Dictionary)->bool:
 if not p.has_all(["notes","entitlements","references","history","selected_thread"]) or not p.notes is Dictionary or p.notes.size()>16 or not p.entitlements is Array or p.entitlements.size()>2 or not p.references is Dictionary or not p.history is Array or p.history.size()>5 or p.selected_thread not in ["","deep","shelf"]:return false
 for key in p.notes:
  if not key is String or not p.notes[key] is String:return false
 var seen=[]
 for item in p.entitlements:
  if item not in ITEMS or item in seen:return false
  seen.append(item)
 if p.references.size()>1:return false
 if not p.references.is_empty() and (not p.references.has("return_cadence") or not cadence_valid(p.references.return_cadence) or "quietus_correlator" not in p.entitlements):return false
 if "quietus_correlator" in p.entitlements and (7 not in p.completed or not p.references.has("return_cadence")):return false
 if "drone_sampler" in p.entitlements and 8 not in p.completed:return false
 seen=[]
 for h in p.history:
  if not h is Dictionary or not h.has_all(["mission","thread","fitted"]) or h.mission not in [9,10,11,12,13] or h.mission in seen or h.thread not in ["deep","shelf"] or h.thread!=p.selected_thread or not fitting_valid(h.fitted):return false
  for item in h.fitted.values():
   if not item.is_empty() and item not in p.entitlements:return false
  seen.append(h.mission)
 return true
# New-region public sensing. Old6..8 SignalField and saved clocks remain untouched.
static func observe(sim,active:bool=false)->void:
 var m=sim.mission
 if m.get("expedition_revision",0)!=2:return
 if not active and sim.elapsed<float(m.next_signal_time):return
 if not active:m.next_signal_time=sim.elapsed+0.75
 var observations=[]
 for track in m.signal_sources.size():
  var source=m.signal_sources[track]
  if not sim.passive_receivers(source.pos).is_empty() or (active and preload("res://src/simulation/world_region.gd").survey_visible(sim,source.pos)):
   if not source.located:
    source.located=true;m.expedition_facts[source.id]=source.evidence
    var site={"pos":source.pos,"name":source.label,"site_id":source.id,"captured":not source.get("confirm",false),"evidence":source.evidence,"optical":source.get("optical",source.id)}
    if source.get("confirm",false):site.merge({"kind":"receiver","required_unit":0,"duration":4.0,"sampler_compatible":source.get("sampler_compatible",false)})
    m.objectives.append(site);sim.message=source.label+" locally identified · packet reception is a separate task" if source.get("confirm",false) else source.label+" locally identified · field note retained"
  for receiver in sim.units.size():
   var unit=sim.units[receiver]
   if not unit.alive:continue
   var arrivals=sim.acoustic_paths.arrivals(unit.pos,source.pos,1200.0)
   if arrivals.is_empty():continue
   var arrival=arrivals[0]
   var reading={"receiver":receiver,"origin":unit.pos,"direction":unit.pos.direction_to(arrival.goal),"time":sim.elapsed,"uncertainty":0.18 if arrival.direct else 0.65,"label":"UNRESOLVED CARRIER","cadence":source.cadence.duplicate(),"track":track}
   var previous=m.signal_observations.filter(func(r):return r.receiver==receiver and r.get("track",-1)==track)
   if previous.is_empty() or sim.elapsed-previous[0].time>2:
    sim.events.append({"type":"carrier_received","receiver":receiver,"direction":reading.direction,"identity":"carrier","time":sim.elapsed})
   observations.append(reading)
 for old in m.signal_observations:
  if sim.elapsed-old.time<30 and not observations.any(func(r):return r.receiver==old.receiver and r.track==old.track):observations.append(old)
 m.signal_observations=observations
static func corridors(sim)->Array:
 var result=[]
 for source in sim.mission.get("corridors",[]):
  var copy=source.duplicate(true);copy.available=sim.all_records();result.append(copy)
 return result
static func extract(sim)->void:
 if sim.mission.get("expedition_revision",0)!=2 or not sim.outcome.is_empty() or sim.units[0].vel.length()>=12:return
 for corridor in corridors(sim):
  if corridor.available and sim.units[0].pos.distance_to(corridor.pos)<65:
   sim.mission.chosen_route=corridor.route;sim.mission.recovered=true;sim.outcome="won";sim.paused=true;sim.message="Recovered / "+corridor.name;sim.events.append({"type":"extraction","pos":sim.units[0].pos});return
static func valid_mission(m:Dictionary,time:float)->bool:
 if m.get("expedition_revision",0)!=2 or m.id not in [9,10,11,12,13] or not is_finite(time) or time<0:return false
 if not m.has_all(["signal_sources","signal_observations","expedition_facts","next_signal_time","chosen_route","recovered","corridors","required_site_ids","launch_context"]):return false
 if not m.signal_sources is Array or m.signal_sources.size()>4 or not m.signal_observations is Array or m.signal_observations.size()>12 or not m.expedition_facts is Dictionary or not m.launch_context is Dictionary:return false
 if not m.recovered is bool or m.chosen_route not in ["","deep","shelf","concealed","overt"]:return false
 if not (m.next_signal_time is int or m.next_signal_time is float) or not is_finite(m.next_signal_time) or m.next_signal_time<0 or m.next_signal_time>time+0.751:return false
 var dimensions=preload("res://src/simulation/world_region.gd").size_of(m)
 var bounds=Rect2(Vector2.ZERO,dimensions)
 var ids=[]
 for source in m.signal_sources:
  if not source is Dictionary or not source.has_all(["id","label","pos","evidence","located","cadence"]) or not source.id is String or source.id in ids or not source.label is String or not source.evidence is String or not source.located is bool or not source.pos is Vector2 or not bounds.has_point(source.pos) or not cadence_valid(source.cadence):return false
  ids.append(source.id)
  if source.located!=m.expedition_facts.has(source.id):return false
  if source.located and (m.expedition_facts[source.id]!=source.evidence or not m.objectives.any(func(o):return o.get("site_id","")==source.id and o.pos==source.pos)):return false
 for reading in m.signal_observations:
  if not reading is Dictionary or not reading.has_all(["receiver","origin","direction","time","uncertainty","label","cadence","track"]):return false
  if not reading.receiver is int or reading.receiver not in [0,1,2] or not reading.origin is Vector2 or not bounds.has_point(reading.origin) or not reading.direction is Vector2 or not reading.direction.is_finite() or reading.direction.length()>1.001:return false
  if not reading.track is int or reading.track<0 or reading.track>=m.signal_sources.size() or reading.label!="UNRESOLVED CARRIER" or not cadence_valid(reading.cadence):return false
  for key in ["time","uncertainty"]:
   if not (reading[key] is float or reading[key] is int) or not is_finite(reading[key]):return false
  if reading.time<0 or reading.time>time or reading.uncertainty<0 or reading.uncertainty>PI:return false
 if not m.required_site_ids is Array or m.required_site_ids.size()>8:return false
 for id in m.required_site_ids:
  if not id is String:return false
 if not m.corridors is Array or m.corridors.is_empty() or m.corridors.size()>2:return false
 for c in m.corridors:
  if not c is Dictionary or not c.has_all(["pos","name","route"]) or not c.pos is Vector2 or not bounds.has_point(c.pos) or not c.name is String or c.route not in ["deep","shelf","concealed","overt"]:return false
 if m.has("launch_equipment") and not fitting_valid(m.launch_equipment):return false
 if m.recovered and (m.chosen_route.is_empty() or m.objectives.is_empty() or not m.objectives.all(func(o):return o.captured) or not m.required_site_ids.all(func(id):return m.objectives.any(func(o):return o.get("site_id","")==id and o.captured))):return false
 return true
