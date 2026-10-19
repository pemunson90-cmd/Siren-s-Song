extends RefCounted
const Sampler=preload("res://src/equipment/field_sampler.gd")
const Authored=preload("res://src/campaign/resolution_missions.gd")
# Once-only physical operations. No actor goals, perception or hidden positions
# are supplied to presentation, and opening never invalidates occupied water.
static func own_origin(site:Dictionary)->bool:return site.get("own_origin",false)==true
static func ready(sim,site:Dictionary,unit:int)->bool:
 return unit==0 and sim.units[0].alive and site.get("origin_region",Rect2()).has_point(sim.units[0].pos) and sim.units[0].vel.length()<12
static func begin(sim,site:Dictionary)->void:
 if sim.mission.id in [12,13] and (own_origin(site) or site.has("completion_open_structure")):
  site["attempt_origin"]=sim.units[sim.capture_unit].pos
static func receiving(sim,site:Dictionary,unit:int)->bool:
 # Old unpublished in-flight snapshots recorded this attempt under the old key.
 var origin=site.get("attempt_origin",site.get("transmission_origin",Vector2.INF))
 return ready(sim,site,unit) and sim.units[unit].pos.distance_to(origin)<8
static func complete(sim,site:Dictionary)->void:
 if own_origin(site):site["transmission_origin"]=site.get("attempt_origin",site.get("transmission_origin",sim.units[0].pos))
 var changed=false
 for gate in sim.mission.get("physical_gates",[]):
  if gate.id==site.get("completion_open_structure","") and not gate.opened:
   gate.opened=true;sim.mission.structures.erase(gate.closed_shape);changed=true
 if changed:sim._build_navigation()
 for source in sim.mission.get("signal_sources",[]):
  if source.id==site.get("completion_enable_source","") and not source.get("active",false) and site.has("completion_emission"):
   var origin:Vector2=site.get("transmission_origin",site.pos)
   if not sim.acoustic_paths.arrivals(source.pos,origin,site.completion_emission.radius).is_empty():
    source.active=true;source["request_origin"]=origin;source["request_time"]=sim.elapsed
 if site.has("completion_emission"):
  var sound=site.completion_emission
  var origin:Vector2=site.get("transmission_origin",site.pos)
  sim._noise(origin,sound.radius,sound.label,sound.duration)
  if sim.mission.id in [12,13]:site["completed_emission"]={"pos":origin,"time":sim.elapsed,"radius":sound.radius,"duration":sound.duration,"label":sound.label}
static func feedback(sim)->Dictionary:
 var result={"gates":[],"operations":[]}
 for gate in sim.mission.get("physical_gates",[]):result.gates.append({"id":gate.id,"pos":gate.closed_shape.get_center(),"rect":gate.closed_shape,"opened":gate.opened})
 var sites=sim.observable_sites()
 for index in sites.size():
  var site:Dictionary=sites[index]
  if not own_origin(site) and not site.has("completion_open_structure"):continue
  var active=sim.capture_target==index and sim.capture_unit>=0
  var unit:int=sim.capture_unit if active else sim.selected
  if not active and unit!=site.get("required_unit",unit) and Sampler.capture_spec(unit,sim.mission.get("launch_equipment",{}),site).is_empty():unit=site.get("required_unit",unit)
  var cost:Dictionary=site.get("completion_emission",{})
  var operation={"site_id":site.site_id,"name":site.name,"action":"TRANSMIT" if own_origin(site) else "ACTUATE","unit":unit,"duration":sim._capture_duration(site,unit),"optional":site.get("optional",false),"repeatable":own_origin(site),"completed":site.captured,"emission":cost.duplicate(true),"qualification":"Open-water emission reach; reception remains unknown."}
  var sampler=Sampler.capture_spec(unit,sim.mission.get("launch_equipment",{}),site)
  if not sampler.is_empty():operation["start_emission"]={"radius":sampler.noise_radius,"duration":2.0,"label":"CAMERA"}
  if active:
   operation["attempt"]={"unit":unit,"elapsed":sim.capture_time,"duration":operation.duration}
   if site.has("attempt_origin"):operation.attempt["origin"]=site.attempt_origin
   elif own_origin(site) and site.has("transmission_origin"):operation.attempt["origin"]=site.transmission_origin
  if site.has("completed_emission"):
   operation["last_completed"]=site.completed_emission.duplicate(true)
   operation.last_completed["age"]=maxf(0.0,sim.elapsed-site.completed_emission.time)
  result.operations.append(operation)
  if own_origin(site):
   result["transmission_region"]=site.origin_region
   # Old recorded attempts cannot prove the place/time of a completed send.
   if site.has("completed_emission"):result["transmission_origin"]=site.completed_emission.pos
 return result
static func valid(m:Dictionary,time:float=0.0)->bool:
 if m.get("id",-1) not in [12,13]:return not m.has("physical_gates")
 if not m.get("objectives") is Array or not m.get("signal_sources") is Array or not m.get("expedition_facts") is Dictionary or not m.get("signal_observations") is Array:return false
 for site in m.objectives:
  if not site is Dictionary or not site.get("captured") is bool:return false
  if site.has("attempt_origin"):
   var bounds=Rect2(Vector2.ZERO,m.world_size)
   if not site.attempt_origin is Vector2 or not site.attempt_origin.is_finite() or not bounds.has_point(site.attempt_origin):return false
   if own_origin(site) and not site.get("origin_region",Rect2()).has_point(site.attempt_origin):return false
  if site.has("completed_emission"):
   var emission=site.completed_emission;var cost=site.get("completion_emission",{})
   if not emission is Dictionary or emission.size()!=5 or not emission.has_all(["pos","time","radius","duration","label"]) or not site.captured or not cost is Dictionary or not cost.has_all(["radius","duration","label"]):return false
   if not emission.pos is Vector2 or not emission.pos.is_finite() or emission.pos!=site.get("transmission_origin",site.pos):return false
   if not (emission.time is int or emission.time is float) or not is_finite(emission.time) or emission.time<0 or emission.time>time:return false
   for key in ["radius","duration","label"]:
    if emission[key]!=cost[key]:return false
 for source in m.signal_sources:
  if not source is Dictionary or not source.has_all(["id","located"]) or not source.located is bool:return false
 var baseline=Authored.make(m.id,m.get("launch_context",{}))
 if m.id==12:
  if not m.get("physical_gates") is Array or m.physical_gates.size()!=1 or not m.get("structures") is Array:return false
  var gate=m.physical_gates[0];var expected=baseline.physical_gates[0]
  if not gate is Dictionary or not gate.has_all(["id","site_id","closed_shape","opened"]) or gate.id!=expected.id or gate.site_id!=expected.site_id or gate.closed_shape!=expected.closed_shape or not gate.opened is bool:return false
  var actuators=m.objectives.filter(func(o):return o.get("site_id","")==gate.site_id)
  if actuators.size()!=1 or actuators[0].captured!=gate.opened or actuators[0].get("completion_open_structure","")!=gate.id:return false
  if m.structures!=([] if gate.opened else [gate.closed_shape]):return false
 else:
  var senders=m.objectives.filter(func(o):return o.get("site_id","")=="warning_transmission")
  var sources=m.signal_sources.filter(func(s):return s.get("id","")=="warning_reply")
  if senders.size()!=1 or sources.size()!=1:return false
  var sender=senders[0];var source=sources[0]
  if not own_origin(sender) or sender.get("origin_region")!=baseline.objectives[0].origin_region or sender.get("completion_enable_source","")!="warning_reply" or not source.get("active") is bool or (source.active and not sender.captured):return false
  if source.active:
   if not source.has_all(["request_origin","request_time"]) or not source.request_origin is Vector2 or not source.request_origin.is_finite() or not sender.origin_region.has_point(source.request_origin):return false
   if not (source.request_time is int or source.request_time is float) or not is_finite(source.request_time) or source.request_time<0 or source.request_time>time:return false
  elif source.has("request_origin") or source.has("request_time"):return false
  if sender.captured and not sender.has("transmission_origin"):return false
  if sender.has("transmission_origin") and (not sender.transmission_origin is Vector2 or not sender.transmission_origin.is_finite() or not sender.origin_region.has_point(sender.transmission_origin)):return false
  if not source.active and (source.located or m.expedition_facts.has(source.id) or not m.signal_observations.is_empty()):return false
 return true
