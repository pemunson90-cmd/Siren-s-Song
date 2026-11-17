extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func _initialize():
 var s=Sim.new();s.start(0)
 check(s.has_method("propulsion_speed"),"simulation distinguishes engine speed from current-assisted ground motion")
 if failures:finish();return
 check(is_equal_approx(s.propulsion_speed({"vel":Vector2(3,4)}),5),"no-current motion uses ordinary velocity")
 check(is_equal_approx(s.propulsion_speed({"vel":Vector2(50,0),"water_velocity":Vector2(20,0)}),20),"assisted ground speed does not invent engine noise")
 check(is_equal_approx(s.propulsion_speed({"vel":Vector2.ZERO,"water_velocity":Vector2(-24,0)}),24),"ground-still counterthrust retains real engine noise")
 finish()
func finish():
 print("CURRENT PROPULSION CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
