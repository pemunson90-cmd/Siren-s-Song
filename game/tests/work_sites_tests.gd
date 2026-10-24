extends SceneTree
const W=preload("res://src/campaign/encounters/work_sites.gd")
const FinalMarks=preload("res://src/campaign/encounters/final_marks.gd")
const FinalSurvey=preload("res://src/campaign/encounters/final_survey.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 var l=W.listen("k1","Account",Vector2(5,6),"ev")
 check(l.kind=="receiver" and l.required_unit==0 and l.duration==4.0 and not l.captured,"listen is a Quietus receiver task, 4 s, uncaptured")
 check(l.site_id=="k1" and l.optical=="k1" and l.evidence=="ev" and not l.has("subject"),"listen keys site and optical on the same id with no subject")
 check(W.listen("k","n",Vector2.ZERO,"e",9.0).duration==9.0,"listen duration is overridable")
 var subject={"viewpoint":Vector2(1,1)}
 var ph=W.photo("p1","Shot",Vector2(1,2),"ev",subject)
 check(ph.kind=="" and ph.subject==subject and not ph.has("optional") and ph.duration==4.0,"photo carries its subject and is required by default")
 var opt=W.photo("p2","Shot",Vector2.ZERO,"e",{},2.0,true)
 check(opt.optional==true and opt.duration==2.0,"photo optional flag and duration are set when asked")
 var fx=W.sluice(Rect2(1,2,3,4))
 var mach=W.machine("m1","Valve",Vector2(7,7),fx)
 check(mach.duration==8.0 and mach.glass_effect==fx and not mach.has("kind") and not mach.has("optional"),"machine work lasts 8 s and has no receiver kind")
 var mopt=W.machine("m2","V",Vector2.ZERO,fx,true,3.0)
 check(mopt.optional and mopt.duration==3.0,"machine optional and duration are overridable")
 check(fx.open==[Rect2(1,2,3,4)] and fx.noise.radius==900.0 and fx.noise.label=="REACH MACHINERY" and fx.noise.duration==6.0,"sluice opens its rect with the default noise")
 var s2=W.sluice(Rect2(),"HAMMER",300.0)
 check(s2.noise.label=="HAMMER" and s2.noise.radius==300.0,"sluice label and radius are overridable")
 var c=W.cargo("sled",Vector2(10,10))
 check(c.state=="site" and c.carrier==-1 and c.band==1 and c.id=="sled","cargo starts at its site with no carrier on MIDDLE")
 check(l.kind!=ph.kind and ph.has("subject") and mach.has("glass_effect") and not l.has("glass_effect"),"listen, photo and machine tasks do not share discriminators")
 # Final-pair layouts: same shape contract.
 for layout in [FinalMarks.layout(),FinalSurvey.layout()]:
  var world=Rect2(Vector2.ZERO,layout.world_size)
  check(world.has_point(layout.start) and world.has_point(layout.recovery),"start and recovery lie inside the world")
  check(world.has_point(layout.core) and world.has_point(layout.bonus),"core and bonus marks lie inside the world")
  check(layout.core_band in [0,1,2] and layout.bonus_band in [0,1,2] and layout.core_band!=layout.bonus_band,"core and bonus sit in different valid bands")
  check(layout.structures.size()==2 and layout.structures[0].get_center().distance_to(layout.core)<120.0 and layout.structures[1].get_center().distance_to(layout.bonus)<120.0,"each mark sits beside its own structure")
  check(layout.terrain.size()==3 and layout.terrain.all(func(t):return t[0].size()>=3 and t[1].all(func(b):return b in [0,1,2])),"terrain entries are polygons with valid bands")
  check(layout.sirens.size()==2 and layout.sirens.all(func(s):return s.has("patrol_points")),"two guards in the shared patrol format")
  check(not layout.structures.any(func(r):return r.has_point(layout.start) or r.has_point(layout.recovery)),"the craft does not start or recover inside a structure")
 check(FinalMarks.layout()==FinalMarks.layout() and FinalSurvey.layout()==FinalSurvey.layout(),"layouts are deterministic")
 check(FinalMarks.layout().core_label!=FinalSurvey.layout().core_label,"the two final layouts are labelled differently")
 print("WORK SITES CHECKS %d FAILURES %d"%[checks,failures])
 quit(1 if failures>0 else 0)
