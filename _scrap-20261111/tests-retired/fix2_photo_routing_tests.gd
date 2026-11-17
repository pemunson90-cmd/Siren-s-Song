extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func fresh(id):
 var s=Sim.new();s.start(id)
 var u=s.units[0];u.band=1;u.vel=Vector2.ZERO;u.transition={}
 # Source-known optical fixture: a real unobstructed same-band contact.
 for angle in [0.,PI/2.,PI,3.*PI/2.]:
  var point=u.pos+Vector2.from_angle(angle)*60.
  if s.Depth.clear(s,u.pos,point,1):
   s.sirens[0].pos=point;s.sirens[0].band=1;s.sirens[0].transition={};u.angle=angle;break
 s._observe();return s
func _initialize():
 for id in [5,6,7,8,9,21,22,23,24,25,26,27,28]:
  var s=fresh(id)
  check(Photo.siren_candidate(s,0)>=0,"op%d has a physically eligible observed Siren"%id)
  var before=s.snapshot();var ctx=s.camera_context()
  check(s.snapshot()==before,"camera routing reads without mutating op%d"%id)
  check(ctx.ready and ctx.get("target",-1)==-2,"op%d offers the same-band Siren study"%id)
  if ctx.get("target",-1)==-2:
   check(s.command("camera") and s.captures[0].get("target",-1)>=Photo.STUDY,"op%d ordinary PHOTO starts its study"%id)
   var work=s.captures[0].duplicate(true);s.camera_context()
   check(s.captures[0]==work,"an active exposure is preserved")
  s=fresh(id);s.units[0].band=2
  check(s.camera_context().get("target",-1)!=-2,"op%d rejects cross-band Siren study"%id)
 for id in [7,8]:
  var s=fresh(id);var u=s.units[0]
  var optional={"pos":s.sirens[0].pos,"name":"OPTIONAL FRAME","captured":false,"optional":true,"kind":"","subject":Photo.default_subject()}
  s.mission.objectives.append(optional)
  var target=s.mission.objectives.size()-1
  check(s.camera_context().get("target",-1)==target,"op%d offers a discovered optional frame"%id)
  check(s.command("camera") and s.captures[0].get("target",-1)==target,"op%d starts the optional photograph"%id)
 var s=fresh(10);s.mission.warning_chain.power="umbilical";s.mission.warning_chain.unit=0
 check(s.camera_context().get("target",-1)!=-2,"a powered plant keeps its existing work context")
 print("FIX2 PHOTO ROUTING CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
