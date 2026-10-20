extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func step(s,seconds):
 s.paused=false
 for n in ceili(seconds*60):s.advance(1./60)
func _initialize():
 var s=Sim.new();s.start(0)
 check(s.mission.has("endurance"),"mission launch carries its explicit endurance budget")
 var before=s.snapshot();s.advance(10)
 check(s.snapshot()==before,"tactical pause freezes oxygen and battery")
 step(s,10)
 check(120-s.oxygen>3,"oxygen use is meaningful on actual operation timescale")
 check(100-s.units[1].battery>1.5,"idle electronics still consume a bounded battery reserve")
 var fitted=Sim.new();fitted.start(0,"endurance",{"fitted":{"quietus":"","drone_a":"drone_deep_cells","drone_b":""}});step(fitted,10)
 check(is_equal_approx(100-s.units[1].battery,2*(100-fitted.units[1].battery)),"deep cells double the equipped drone's actual energy reserve")
 check(is_equal_approx(fitted.units[2].battery,s.units[2].battery),"one hardware item does not improve the other drone")
 if not s.mission.has("endurance"):
  print("OPERATION ENDURANCE CHECKS ",checks," FAILURES ",failures);quit(1);return
 var restored=Sim.new();s.paused=true
 check(restored.restore(s.snapshot()) and restored.mission.endurance==s.mission.endurance and restored.oxygen==s.oxygen,"current save retains launch budget and spent air")
 var active=Sim.new();active.start(0);active.command("select",{"unit":1});active.command("route",{"point":Vector2(380,700)});step(active,2)
 var idle=Sim.new();idle.start(0);step(idle,2)
 check(active.units[1].battery<idle.units[1].battery,"actual propulsion costs more battery than holding")
 var Endurance=load("res://src/simulation/operation_endurance.gd")
 var world={"id":1,"launch_equipment":{"quietus":"","drone_a":"","drone_b":""},"endurance":Endurance.profile(1)}
 var idle_cost=Endurance.battery_drain(world,1,0,1)
 check(Endurance.battery_drain(world,1,40,1)>idle_cost,"counterthrust effort costs energy even at zero ground speed")
 check(world.endurance.oxygen_seconds>229 and Endurance.profile(12).oxygen_seconds>world.endurance.oxygen_seconds,"observed slow Split and longer concealed route have practical fallback time")
 print("OPERATION ENDURANCE CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
