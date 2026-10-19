extends SceneTree
const Ocean=preload("res://src/presentation/ocean_view.gd")
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;print("FAIL ",label)
func _initialize():
 var view=Ocean.new();var s=Sim.new();s.start(4);view.sim=s
 if not view.has_method("selected_heading_marker"):
  check(false,"selected owned craft has readable current-heading geometry independent of route")
  view.free();print("HEADING CHECKS ",checks," FAILURES ",failures);quit(1);return
 for selected in [0,1]:
  s.selected=selected;var u=s.units[selected]
  var heading_ok=true;var bow_clear=true;var scale_ok=true
  for scale in [0.25,0.7,2.8]:
   view.world_scale=scale;view.feedback_font_size=22
   for angle in [-PI/2,0.0,PI/2,PI,0.731]:
    u.angle=angle;var marker=view.selected_heading_marker();var direction=Vector2.from_angle(angle);var axis=(marker[1]-(marker[0]+marker[2])/2).normalized()
    heading_ok=heading_ok and axis.dot(direction)>0.9999
    var half=66.0 if selected==0 else 21.0
    bow_clear=bow_clear and (marker[0]-u.pos).dot(direction)*scale>half*scale
    scale_ok=scale_ok and absf(marker[1].distance_to((marker[0]+marker[2])/2)*scale-22)<0.001
  check(heading_ok,"current bow direction stays correct through both turn directions and zoom")
  check(bow_clear,"marker clears selected hull geometry")
  check(scale_ok,"zoom preserves screen-sized cue")
  var before=view.selected_heading_marker();u.route=[{"pos":u.pos-Vector2.from_angle(u.angle)*100,"stop":true}];u.vel=-Vector2.from_angle(u.angle)*78
  s.contacts[0]={"pos":u.pos,"time":s.elapsed,"mode":"BEAM","lock":9.0};s.sirens.clear()
  check(view.selected_heading_marker()==before,"opposite desired route, drift and contact state do not masquerade as current heading")
  var snapshot=s.snapshot();view.selected_heading_marker();check(s.snapshot()==snapshot,"presentation geometry is read-only")
  u.alive=false;check(view.selected_heading_marker().is_empty(),"no bow mark on lost selected craft");u.alive=true
 view.sim=null;check(view.selected_heading_marker().is_empty(),"no marker without a dive")
 view.free();print("HEADING CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
