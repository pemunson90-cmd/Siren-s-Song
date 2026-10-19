extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 var s=Sim.new();s.start(0);s.units[0].pos=Vector2(400,500)
 check(not s.command("decoy") and s.tools.decoy==3 and s.noises.is_empty(),"default east landing in basalt rejects without spending")
 for point in [Vector2(560,500),Vector2(400,800),Vector2(-1,500),Vector2(NAN,500),"water"]:
  s=Sim.new();s.start(0);s.units[0].pos=Vector2(400,500)
  var before=s.snapshot();check(not s.command("decoy",{"point":point}) and s.snapshot()==before,"invalid target %s cannot spend or mutate active state"%str(point))
 s=Sim.new();s.start(0);s.units[0].pos=Vector2(400,500)
 check(s.command("decoy",{"point":Vector2(300,500)}) and s.tools.decoy==2,"pilot deliberately deploys at a reachable water point")
 check(s.noises.size()==1 and s.noises[0].pos==Vector2(300,500) and s.noises[0].radius==1100 and s.noises[0].time==15,"valid deployment retains finite15s1100m lure")
 var cover=Sim.new();cover.start(3);cover.units[0].pos=Vector2(880,710)
 check(not cover.command("decoy",{"point":Vector2(1040,710)}) and cover.tools.decoy==3,"nearby water behind solid basalt is not a teleport deployment")
 var edge=Sim.new();edge.start(0);edge.units[0].pos=Vector2(1470,900)
 check(not edge.command("decoy") and edge.tools.decoy==3,"default outside world rejects without spending")
 var ordinary=Sim.new();ordinary.start(0)
 check(ordinary.command("decoy") and ordinary.noises[0].pos==Vector2(300,800),"existing default API retains valid east160 deployment")
 var legacy=ordinary.snapshot();legacy.noises[0].pos=Vector2(560,500);legacy.noises[0].time=12.0
 var restored=Sim.new();check(restored.restore(legacy) and restored.snapshot()==legacy,"existing active legacy noise is preserved even at newly forbidden landing")
 restored.advance(2);check(restored.snapshot()==legacy,"pause preserves existing transmission lifetime")
 var drone=Sim.new();drone.start(0);drone.command("select",{"unit":1})
 check(drone.command("decoy",{"point":Vector2(240,700)}) and drone.tools.decoy==2,"selected drone can deliberately place its finite common buoy")
 print("DECOY DEPLOYMENT CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
