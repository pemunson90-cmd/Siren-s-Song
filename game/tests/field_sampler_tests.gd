extends SceneTree
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 var path="res://src/equipment/field_sampler.gd"
 if not ResourceLoader.exists(path):check(false,"fitted field pod offers new compatible task without rewriting existing capture")
 else:
  var sampler=load(path)
  var fitted={"drone_a":"drone_sampler"};var compatible={"sampler_compatible":true,"duration":4.0}
  var before=compatible.duplicate(true);var fit_before=fitted.duplicate(true)
  check(sampler.capture_spec(1,fitted,compatible)=={"duration":8.0,"noise_radius":520.0},"sampler allows new remote work at doubled exposure and camera noise")
  check(sampler.capture_spec(0,fitted,compatible).is_empty(),"Quietus retains ordinary authored four-second task")
  check(sampler.capture_spec(2,fitted,compatible).is_empty() and sampler.capture_spec(1,{},compatible).is_empty(),"unfitted drone does not get other drone hardware")
  check(sampler.capture_spec(1,fitted,{"duration":4.0}).is_empty(),"existing camera/receiver jobs get no override or withdrawal")
  check(sampler.capture_spec(1,fitted,{"sampler_compatible":false}).is_empty(),"explicit incompatible task stays baseline")
  check(sampler.capture_spec(1,{"quietus":"drone_sampler"},compatible).is_empty(),"invalid fitted snapshot cannot activate sampler")
  check(sampler.capture_spec(-1,fitted,compatible).is_empty() and sampler.capture_spec(3,fitted,compatible).is_empty(),"unknown craft cannot use pod")
  check(fitted==fit_before and compatible==before,"pure spec does not grant gear or mutate authored task")
 print("FIELD SAMPLER CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
