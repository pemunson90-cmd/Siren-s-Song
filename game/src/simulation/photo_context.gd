extends RefCounted
# Read-only fallback after mission jobs: available optional frames, then visible Sirens.
# Seam: Simulation.camera_context, before existing band/rules/pricing annotations.
# Revert: remove that call and this module; no saved fields or game rules change.
const Photo=preload("res://src/simulation/photo_capture.gd")
const Band=preload("res://src/photo_depth/band_photo.gd")
static func resolve(sim,context:Dictionary)->Dictionary:
 if context.get("ready",false) or sim.captures.any(func(work):return not work.is_empty()):return context
 var u=sim.units[sim.selected]
 if not Band.can_shoot(sim,u):return context
 if sim.Chain.applies(sim.mission) and sim.mission.warning_chain.power!="off":return context
 var best=-1;var score=INF
 for id in sim.mission.objectives.size():
  var o=sim.mission.objectives[id]
  if not o.get("optional",false) or not Photo.applies(o) or Photo.stage(o)=="lead":continue
  if o.captured and Photo.seen_before(sim,id).size()>=o.subject.features.size():continue
  if not Band.can_shoot(sim,u,o) or u.pos.distance_to(o.pos)>Photo.reach(sim,sim.selected):continue
  if not sim.Depth.optical_clear(sim,u.pos,o.pos,u.band):continue
  var aim=absf(angle_difference(u.angle,u.pos.angle_to_point(o.pos)))+u.pos.distance_to(o.pos)/2000.
  if aim<score:best=id;score=aim
 if best>=0:
  return {"target":best,"ready":true,"text":"READY · %s · exposure %.0fs"%[Photo.label(sim.mission.objectives[best]),sim._capture_duration(sim.mission.objectives[best],sim.selected)]}
 var siren=Photo.siren_candidate(sim,sim.selected)
 if siren<0:return context
 return {"target":-2,"siren":siren,"ready":true,"text":"READY · S%d %s · PHOTO 8s · observe its form and movement from clear water"%[siren+1,str(sim.sirens[siren].get("type","patroller")).to_upper()]}
# Presentation gives PHOTO priority only for the same resolved photographic context.
static func is_photo(sim,context:Dictionary)->bool:
 var target=int(context.get("target",-1))
 if target==-2:return true
 return target>=0 and Photo.target_valid(sim.mission,target) and Photo.applies(Photo.obj(sim,target))
