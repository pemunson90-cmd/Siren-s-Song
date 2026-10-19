extends SceneTree
const Content=preload("res://src/campaign/resolution_missions.gd")
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func authored_sim(id:int,history:Dictionary={}):
 # Data-unit fixture, not campaign/earned Main evidence. The campaign owner
 # installs this same authored Dictionary through the production registry.
 var sim=Sim.new();sim.start(0);sim.mission=Content.make(id,history)
 sim.sirens=sim.mission.sirens.duplicate(true);sim.known={};sim.contacts={}
 for n in 3:sim.units[n].pos=sim.mission.start+[Vector2.ZERO,Vector2(0,-100),Vector2(140,0)][n]
 sim._build_navigation()
 return sim
func vantage(sim,point:Vector2)->Vector2:
 for offset in [Vector2(0,180),Vector2(-180,0),Vector2(180,0),Vector2(0,-180),Vector2(0,120)]:
  var at=point+offset
  if not sim.blocked(at,25) and sim.line_clear(at,point) and not sim.path(sim.mission.start,at).is_empty():return at
 return Vector2.INF
func _initialize()->void:
 for id in [11,12,13]:
  var sim=authored_sim(id,{"completed":[9],"facts":{}})
  check(sim.units.all(func(u):return not sim.blocked(u.pos,25)),"all craft deploy in clear authored water for job%d"%id)
  for corridor in sim.mission.corridors:
   check(not sim.blocked(corridor.pos,25) and not sim.path(sim.mission.start,corridor.pos).is_empty(),"physical recovery corridor is navigable for job%d"%id)
  for source in sim.mission.signal_sources:
   check(not sim.blocked(source.pos,12) and vantage(sim,source.pos).is_finite(),"source has a legitimate clear reachable observation approach for job%d"%id)
  for site in sim.mission.objectives:
   check(not sim.blocked(site.pos,12) and vantage(sim,site.pos).is_finite(),"receiver/uplink has clear reachable camera approach for job%d"%id)
  for siren in sim.sirens:
   check(not sim.blocked(siren.pos,24) and siren.patrol_points.all(func(p):return not sim.blocked(p,24)),"ordinary authored patrol avoids terrain in job%d"%id)
 var shelf=authored_sim(11,{"completed":[10],"facts":{}})
 check(shelf.units.all(func(u):return not shelf.blocked(u.pos,25)),"Shelf-rejoined fleet starts in clear water")
 check(not shelf.path(shelf.mission.start,shelf.mission.corridors[0].pos).is_empty(),"Shelf-rejoined approach reaches the same actual confluence")
 print("RESOLUTION GEOMETRY CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
