extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;print("FAIL ",label)
func _initialize():
 var sim=Sim.new();sim.start(12,"disruption",{"fitted":{"quietus":"","drone_a":"drone_sampler","drone_b":""}})
 check(sim.has_method("capture_feedback"),"capture exposes actual duration to presentation")
 if not sim.has_method("capture_feedback"):quit(1);return
 check(sim.capture_feedback().duration==0,"inactive capture has no progress duration")
 sim.units[1].pos=sim.mission.objectives[0].pos+Vector2(0,80);sim.command("select",{"unit":1});sim.command("emp");sim.command("camera")
 sim.paused=false
 for i in 60:sim.advance(1.0/60)
 var sample=sim.capture_feedback()
 check(sample.duration==8 and sample.elapsed>0.99 and sample.elapsed<1.01 and sample.unit==1 and sample.target==0,"sampler progress reports real eight-second work")
 var restored=Sim.new();check(restored.restore(sim.snapshot()) and restored.capture_feedback()==sample,"restored fitted progress retains effective duration")
 for id in [0,2]:
  var legacy=Sim.new();legacy.start(id);legacy.captures[0]={"target":0,"elapsed":0.0}
  check(legacy.capture_feedback().duration==(2.0 if id==2 else 4.0),"legacy photograph/exchange duration unchanged")
 print("CAPTURE FEEDBACK CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
