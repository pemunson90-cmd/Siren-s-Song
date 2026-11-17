extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func _initialize():
 # 127 (Pat 2026-10-30): earned-chart brakes and chart stops are the dev/test autopilot path.
 var s=Sim.new();s.start(11,"disruption",{"context":{"thread":"deep","completed":[9]}})
 s.mission["dev"]=true
 var goal=Vector2(1100,1000)
 check(s.command("route",{"point":goal}),"a hidden-rock endpoint accepts tentative course intent")
 for tick in 600:s._move(s.units[0],1.0/60,42,false,true,true)
 check(not s.units[0].route.is_empty() and not s.units[0].route_plan.is_empty(),"physical hidden geometry cannot silently erase tentative intent")
 check(s.terrain_chart.is_clear(s.units[0].pos),"unobserved route advances only inside its certified launch prefix")
 var flow=Sim.new();flow.start(11,"disruption",{"context":{"thread":"deep","completed":[9]}})
 flow.mission["dev"]=true
 flow.mission.currents=[{"center":flow.units[0].pos,"radius":800.0,"velocity":Vector2(0,-24)}]
 flow.units[0]["water_velocity"]=Vector2.ZERO;flow.units[0].vel=Vector2(0,-24);flow.units[0].angle=-PI/2
 check(flow.command("route",{"point":flow.units[0].pos+Vector2(0,-500)}),"flow-assisted unknown course is accepted")
 for tick in 1200:flow._move(flow.units[0],1.0/60,42,false,true,true)
 check(flow.terrain_chart.is_clear(flow.units[0].pos) and not flow.units[0].has("chart_stop"),"current cannot carry craft beyond confirmed water or invent an obstacle latch")
 check(not flow.units[0].get("route_plan",[]).is_empty() and flow.units[0].vel.length()<2,"frontier brake keeps the full program while countering local flow")
 check(flow.propulsion_speed(flow.units[0])>5,"stopped frontier craft still pays physical counterthrust")
 var positions=[]
 for velocity in [Vector2.ZERO,Vector2(24,0)]:
  var clear=Sim.new();clear.start(0);clear.mission.rocks=[];clear.mission["structures"]=[]
  clear.mission["world_size"]=Vector2(1600,960);clear.mission["earned_terrain"]=true
  clear.mission["launch_seed"]=Rect2(80,80,1440,800)
  clear.mission["currents"]=[{"center":Vector2(700,800),"radius":1000.0,"velocity":velocity}]
  clear._build_navigation();clear._configure_terrain();clear.units[0].pos=Vector2(400,800);clear.units[0].angle=0;clear.units[0]["water_velocity"]=Vector2.ZERO
  clear.command("route",{"point":Vector2(1200,800)})
  for tick in 480:clear._move(clear.units[0],1.0/60,42,false,true,true)
  positions.append(clear.units[0].pos.x)
 check(positions[1]>positions[0]+50,"ample observed water retains axial current assistance instead of capping all ground motion to engine speed")
 print("CURRENT CHART SEAM CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
