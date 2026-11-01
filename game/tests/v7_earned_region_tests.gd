extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Missions=preload("res://src/campaign/missions.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 var probe=Sim.new()
 if not probe.has_method("public_chart"):check(false,"existing Confluence has earned terrain authority")
 else:
  # 127 (Pat 2026-10-30): earned-chart brakes and chart stops are the dev/test autopilot path.
  var sim=Sim.new();sim.start(11,"disruption",{"context":{"thread":"deep","completed":[9]}})
  sim.mission["dev"]=true
  check(sim.mission.get("earned_terrain",false) and sim.mission.id==11,"existing campaign node enables functional terrain discovery")
  var original=sim.public_chart();var before=sim.snapshot()
  check(not original.clear_cells.is_empty() and original.surface_segments.is_empty(),"briefed clear launch basin alone starts surveyed")
  check(sim.player_path(sim.units[0].pos,Vector2(1100,1000)).size()==1,"unknown endpoint inside hidden central basalt accepts tentative intent")
  check(sim.snapshot()==before,"path and presentation queries cannot observe terrain")
  sim.command("route",{"point":sim.units[0].pos+Vector2(0,100)})
  var course=sim._course_prepare(sim.units[0],42.0,false)
  check(course.get("ground_cap",-1)>42,"confirmed water leaves room for current-assisted ground speed above engine thrust")
  sim.command("route_delete",{"index":0})
  sim.command("recon");check(sim.public_chart()==original,"paused survey arms without acquiring terrain")
  sim.paused=false;sim.advance(Sim.STEP)
  check(sim.public_chart()!=original,"unpaused sensor measurement earns terrain")
  check(sim.course_segments(0).is_empty(),"idle craft has no fabricated course")
  sim.paused=true;var saved=sim.snapshot();var restored=Sim.new()
  check(restored.restore(saved) and restored.public_chart()==sim.public_chart(),"current active region restores measured chart")
  var other=Sim.new();other.start(10)
  check(other.public_chart().is_empty(),"other existing operations keep their intended authored charts")
 print("V7 EARNED REGION CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
