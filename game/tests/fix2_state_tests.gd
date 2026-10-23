extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Stun=preload("res://src/simulation/observed_stun.gd")
const Context=preload("res://src/simulation/photo_context.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 var s=Sim.new();s.start(0)
 var original=s.snapshot();var ready={"target":0,"ready":true,"text":"MISSION JOB"}
 check(Context.resolve(s,ready)==ready and s.snapshot()==original,"ready mission work has priority without writes")
 var legacy=original.duplicate(true)
 for c in legacy.get("contacts",{}).values():c.erase("observed_stun")
 check(Sim.valid_snapshot(legacy),"older contacts without a stun clock remain valid")
 var c={"time":4.,"observed_stun":12.}
 check(is_equal_approx(Stun.remaining(c,6.),10.),"the countdown uses only its observed clock and age")
 var bad=original.duplicate(true);bad.contacts={0:{"observed_stun":INF}}
 check(not Sim.valid_snapshot(bad),"a nonfinite optional stun clock is rejected")
 bad.contacts[0].observed_stun=-1.
 check(not Sim.valid_snapshot(bad),"a negative optional stun clock is rejected")
 var path="res://src/presentation/loss_summary.gd"
 check(ResourceLoader.exists(path),"a loss has an observed-state explanation")
 if ResourceLoader.exists(path):
  var Summary=load(path)
  s.outcome="lost";s.message=s.VAPORIZED_TEXT;s.hull=0.;s.elapsed=10.
  s.contacts={0:{"time":10.,"pos":s.units[0].pos+Vector2(140,0),"lock":4.,"target":0,"mode":"BEAM"}}
  var before=s.snapshot();var text=Summary.line(s)
  check("140 m" in text and "last" in text.to_lower(),"a beam loss uses observed range with honest attribution")
  check(s.snapshot()==before,"explaining a loss never changes the snapshot")
  s.contacts={};check(not "140" in Summary.line(s),"an unseen cause never invents a measured range")
  s.oxygen=0.;s.message="Quietus lost."
  check("Life support" in Summary.line(s),"empty oxygen gives its own observed cause")
 print("FIX2 STATE CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
