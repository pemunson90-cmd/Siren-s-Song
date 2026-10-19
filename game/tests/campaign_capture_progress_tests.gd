extends SceneTree
const Feed=preload("res://src/presentation/camera_feed.gd")
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func _initialize():call_deferred("run")
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func run():
 var feed_script=load("res://src/presentation/camera_feed.gd")
 check(feed_script.has_method("acquisition_progress"),"receiver display consumes actual public effective capture clock")
 if not feed_script.has_method("acquisition_progress"):finish();return
 var caption=Feed.fit_caption("WEST WARNING PREPARATION",270.,25)
 check(caption.ends_with("…") and ThemeDB.fallback_font.get_string_size(caption,HORIZONTAL_ALIGNMENT_LEFT,-1,25).x<=270.,"long receiver caption preserves reserved percentage space at unchanged font size")
 check(Feed.fit_caption("BERTH",270.,25)=="BERTH","short receiver captions remain complete")
 var sim=Sim.new()
 # Isolated capture-clock fixtures, not earned journeys or exposure outcomes.
 for unit in [1,0]:
  sim.start(10,"disruption",{"fitted":{"quietus":"","drone_a":"drone_sampler","drone_b":""}});sim.sirens=[]
  sim.units[unit].pos=Vector2(480,1080);sim.units[unit].vel=Vector2.ZERO;sim.command("select",{"unit":unit})
  check(sim.command("camera"),"actual compatible receiver starts for unit%d"%unit)
  sim.paused=false
  for n in (40 if unit==1 else 20):sim.advance(.1)
  var feedback=sim.capture_feedback()
  check(is_equal_approx(feedback.duration,8. if unit==1 else 4.),"public receiver duration reflects actual sampler8s versus Quietus4s")
  check(Feed.acquisition_progress(sim)>.48 and Feed.acquisition_progress(sim)<.52 and not sim.mission.objectives[0].captured,"half-complete actual acquisition cannot display100percent")
 sim.start(2);sim.sirens=[];sim.units[0].pos=sim.mission.objectives[0].pos+Vector2(0,80);sim.units[0].vel=Vector2.ZERO
 sim.paused=false
 for n in 8:sim.advance(.1)
 check(sim.command("camera"),"ordinary Blackwater exchange starts through actual command")
 for n in 10:sim.advance(.1)
 check(is_equal_approx(sim.capture_feedback().duration,2.) and Feed.acquisition_progress(sim)>.45 and Feed.acquisition_progress(sim)<.55,"ordinary two-second exchange progress keeps its own public clock")
 finish()
func finish():print("CAMPAIGN CAPTURE PROGRESS CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
