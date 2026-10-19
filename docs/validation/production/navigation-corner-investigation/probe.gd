extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Routes=preload("res://tests/campaign_scenarios.gd")
func _initialize():
 var s=Sim.new();s.start(2,"disruption");s.units[1].alive=false;s.units[2].alive=false
 var ok=true
 for id in [0,1]:
  ok=ok and Routes.move(s,s.mission.objectives[id].pos+Vector2(0,140))
  ok=ok and s.command("camera")
  for n in 45:s.advance(0.1)
  print("NAV_SETUP target=",id," ok=",ok," time=",s.elapsed," pos=",s.units[0].pos," vel=",s.units[0].vel," captured=",s.mission.objectives[id].captured)
 if not ok:quit(1);return
 var u=s.units[0];var origin=u.pos;var path=s.path(origin,s.mission.extraction)
 print("NAV_PLAN origin=",origin," angle=",u.angle," vel=",u.vel," origin_blocked24=",s.blocked(origin,24)," route=",path)
 var point=origin
 for n in path.size():
  print("NAV_SEGMENT index=",n," from=",point," to=",path[n].pos," safe24=",s.segment_safe(point,path[n].pos,24)," safe12=",s.segment_safe(point,path[n].pos,12));point=path[n].pos
 s.command("route",{"point":s.mission.extraction});s.paused=false
 for n in 1800:
  var before={"pos":u.pos,"vel":u.vel,"angle":u.angle,"route":u.route.duplicate(true)}
  s.advance(0.1)
  if u.route.is_empty() and u.vel.length()<2:
   print("NAV_FINAL before=",before," after_pos=",u.pos," elapsed=",s.elapsed," message=",s.message," outcome=",s.outcome);break
 quit()
