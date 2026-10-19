extends SceneTree
const Front=preload("res://src/simulation/thermal_front.gd")
const Paths=preload("res://src/simulation/acoustic_paths.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func transmission(points:Array)->float:return Front.transmission(PackedVector2Array(points),Front.foundry())
func _initialize():
 check(is_equal_approx(transmission([Vector2(860,840),Vector2(1420,840)]),0.55*0.55),"crossing both sides weakens a supported arrival twice")
 check(is_equal_approx(transmission([Vector2(860,840),Vector2(1000,840),Vector2(1200,840),Vector2(1320,840),Vector2(1420,840)]),0.55*0.55),"polyline subdivision at a boundary cannot double-count attenuation")
 check(transmission([Vector2(900,880),Vector2(1000,780),Vector2(1100,680)])==1.0,"touching a thermal corner tangentially does not cross it")
 check(transmission([Vector2(900,780),Vector2(1400,780)])==1.0,"travel along a boundary does not invent repeated losses")
 check(is_equal_approx(transmission([Vector2(900,680),Vector2(1000,780),Vector2(1100,880)]),0.55),"entering through a corner is one crossing")
 check(transmission([Vector2(1050,800),Vector2(1250,880)])==1.0 and transmission([Vector2(800,800),Vector2(800,940)])==1.0,"same-side direct reception remains unmasked")
 check(transmission([Vector2(990,840),Vector2(600,600),Vector2(1010,840)])==1.0,"close bypass uses emitter/listener separation even with subdivided indirect path")
 var path=[Vector2(900,740),Vector2(1080,870),Vector2(1420,840)];var reverse=path.duplicate();reverse.reverse()
 check(is_equal_approx(transmission(path),transmission(reverse)),"thermal transmission is reciprocal across a bent path")
 var rock=PackedVector2Array([Vector2(1080,700),Vector2(1200,700),Vector2(1200,840),Vector2(1080,840)])
 var ordinary=Paths.new();ordinary.configure([rock],Vector2(1600,960));var thermal=Paths.new();thermal.configure([rock],Vector2(1600,960),Front.foundry())
 var plain=ordinary.arrivals(Vector2(900,760),Vector2(1420,760),6000);var modified=thermal.arrivals(Vector2(900,760),Vector2(1420,760),6000)
 check(plain.size()==2 and modified.size()==2,"front can change competing arrival weights while preserving supported water paths")
 var unchanged=false;var weaker=false;var safe=true
 for arrival in modified:
  for original in plain:
   if arrival.points==original.points:
    unchanged=unchanged or is_equal_approx(arrival.strength,original.strength);weaker=weaker or arrival.strength<original.strength
  for i in arrival.points.size()-1:safe=safe and thermal.clear(arrival.points[i],arrival.points[i+1])
 check(unchanged and weaker and safe,"only the crossing branch weakens and no path cuts through basalt")
 var repeated=thermal.arrivals(Vector2(900,760),Vector2(1420,760),6000)
 check(modified==repeated and Paths.choose(modified,7)==Paths.choose(repeated,7),"field and bearing choice are deterministic without graph mutation leaks")
 var no_front=Paths.new();no_front.configure([],Vector2(1600,960));var with_front=Paths.new();with_front.configure([],Vector2(1600,960),Front.foundry())
 check(not no_front.arrivals(Vector2(860,840),Vector2(1420,840),1000).is_empty() and with_front.arrivals(Vector2(860,840),Vector2(1420,840),1000).is_empty(),"attenuated unsupported direct arrival is rejected instead of reporting a fictitious listener goal")
 print("THERMAL TRANSMISSION CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
