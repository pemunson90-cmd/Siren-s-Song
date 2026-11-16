extends SceneTree
# WP-122: PHOTO stays on the wheel beside a job (LINK, TRANSMIT...) that holds the camera context.
# A craft beside a charted own-origin job and a photo subject offers both, and each starts its own work.
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 8:await process_frame
# Mission 1: the uplink (a non-photo LINK job) is listed first, ready, with a relay photo subject beside it.
# The camera context frames the job first; photo_context frames the relay.
func stage(sim)->void:
 var uplink=sim.mission.objectives[2];var relay=sim.mission.objectives[0];var far=sim.mission.objectives[1]
 uplink["requires"]=[];far.pos=uplink.pos+Vector2(900,900)
 relay.pos=uplink.pos+Vector2(40,0);relay.captured=false
 sim.mission.objectives=[uplink,far,relay]
 sim.units[0].pos=uplink.pos;sim.units[0].vel=Vector2.ZERO;sim.units[0].band=1
func run():
 root.size=Vector2i(2520,1080);await settle()
 var g=load("res://scenes/main.tscn").instantiate();g.set_script(load("res://tests/density_main.gd"));g.capture_scenario="radial-hud"
 root.add_child(g);await settle();g.set_process(false)
 g._start_mission(1);await settle()
 var sim=g.sim;var h=g.mission_hud
 stage(sim);sim.selected=0;sim.paused=true;g._refresh();await settle()
 var rule=preload("res://src/simulation/photo_context.gd")
 var held=sim.camera_context();var photo=sim.photo_context()
 check(int(held.get("target",-1))==0 and not rule.is_photo(sim,held),"the uplink job holds the camera context")
 check(int(photo.get("target",-1))==2 and rule.is_photo(sim,photo) and photo.ready,"the photo subject beside it is still framed by photo_context")
 check(h.operation_beside_photo(sim),"the wheel sees a job beside a photo subject")
 check(g.order_buttons.camera.text=="PHOTO" and not g.order_buttons.camera.disabled,"the camera slot reads PHOTO: "+g.order_buttons.camera.text)
 check(h.extra.operation.text.contains("LINK") and h.command_controls().has(h.extra.operation),"the job has its own segment: "+h.extra.operation.text)
 check(h.command_controls().has(g.order_buttons.camera),"PHOTO is on the wheel")
 # PHOTO starts the photograph, not the job.
 g._primary_action();await settle()
 check(int(sim.captures[0].get("target",-1))==2,"PHOTO starts the frame on the relay, not the uplink")
 # The job's own segment starts the job (a fresh sim state).
 sim.captures[0]={};sim.units[0].hold="";g._refresh();await settle()
 g._order("camera");await settle()
 check(int(sim.captures[0].get("target",-1))==0,"the job segment starts the uplink job")
 # With no job in reach there is one camera slot and no extra segment.
 sim.captures[0]={};sim.mission.objectives[0].pos=Vector2(40,40);sim.mission.objectives[0].captured=true
 g._refresh();await settle()
 check(not h.operation_beside_photo(sim) and not h.command_controls().has(h.extra.operation),"no job: no extra segment")
 print("PHOTO BESIDE JOB CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
