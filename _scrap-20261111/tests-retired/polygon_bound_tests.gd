extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Acoustics=preload("res://src/simulation/acoustic_paths.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 # Exact IEEE Vector2 from ordinary mission6's false collision at36.8667s.
 var point:Vector2=bytes_to_var("05000000dc6408447a58b244".hex_decode())
 var shape=Sim.rock_polygon(Rect2(1000,1720,1400,200))
 check(not Rect2(1000,1720,1400,200).has_point(point),"actual failing point is outside the distant polygon bounding rectangle")
 var s=Sim.new();s.start(0);s.mission.rocks=[Rect2(1000,1720,1400,200)];s._build_navigation()
 check(s.line_clear(point,point+Vector2(1,0)),"actual-byte outside point cannot falsely occlude an empty physical segment")
 var sound=Acoustics.new();sound.configure([shape],Vector2(2600,2600))
 check(sound.clear(point,point+Vector2(1,0)),"same outside-point pathology cannot falsely block acoustic visibility")
 # Uniform half-scale keeps the exact mantissas and puts the case inside old worlds.
 s.mission.rocks=[Rect2(500,860,700,100)];s._build_navigation();var scaled=point/2
 check(not s.blocked(scaled,12),"in-world scaled counterexample cannot stop a physically clear hull")
 check(s.line_clear(scaled,scaled+Vector2(1,0)),"in-world outside point remains clear for sight and route queries")
 check(s.blocked(Vector2(750,900),12) and not s.line_clear(Vector2(750,900),Vector2(750,850)),"real polygon interior still blocks hull and sight")
 check(s.blocked(Vector2(500,880),12),"positive hull radius still catches real minimum boundary")
 var p:Vector2=s.rock_shapes[0][0]
 check(s.blocked(p,12),"polygon top edge remains solid with inclusive bounding precheck")
 var old=s.snapshot();var restored=Sim.new();check(restored.restore(old) and restored.snapshot()==old and not restored.blocked(scaled,12),"restore rebuilds geometry bounds without new save fields")
 s.mission.rocks=[];s._build_navigation();check(not s.blocked(Vector2(750,900),12),"new terrain build removes stale cached polygon bounds")
 print("POLYGON BOUND CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
