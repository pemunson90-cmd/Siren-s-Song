extends RefCounted
const Authored=preload("res://src/campaign/resolution_missions.gd")
# Once-only physical operations. No actor goals, perception or hidden positions
# are supplied to presentation, and opening never invalidates occupied water.
static func own_origin(site:Dictionary)->bool:return site.get("own_origin",false)==true
static func ready(sim,site:Dictionary,unit:int)->bool:
 return unit==0 and sim.units[0].alive and site.get("origin_region",Rect2()).has_point(sim.units[0].pos) and sim.units[0].vel.length()<12
static func begin(sim,site:Dictionary)->void:
 if own_origin(site):site["transmission_origin"]=sim.units[0].pos
static func receiving(sim,site:Dictionary,unit:int)->bool:
 return ready(sim,site,unit) and site.has("transmission_origin") and sim.units[unit].pos.distance_to(site.transmission_origin)<8
static func complete(sim,site:Dictionary)->void:
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
  sim._noise(site.get("transmission_origin",site.pos),sound.radius,sound.label,sound.duration)
static func feedback(sim)->Dictionary:
 var result={"gates":[]}
 for gate in sim.mission.get("physical_gates",[]):result.gates.append({"id":gate.id,"pos":gate.closed_shape.get_center(),"opened":gate.opened})
 for site in sim.observable_sites():
  if own_origin(site):
   result["transmission_region"]=site.origin_region
   if site.has("transmission_origin"):result["transmission_origin"]=site.transmission_origin
 return result
static func valid(m:Dictionary,time:float=0.0)->bool:
 if m.id not in [12,13]:return not m.has("physical_gates")
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
  var sources=m.signal_sources.filter(func(s):return s.id=="warning_reply")
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
