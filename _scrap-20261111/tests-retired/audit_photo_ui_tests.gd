extends SceneTree
const Photo=preload("res://src/simulation/photo_capture.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
	var game=load("res://scenes/main.tscn").instantiate();game.store.path="user://audit-photo-ui.save"
	root.add_child(game);game.set_process(false);game._start_mission(0)
	var s=game.sim
	var caption=game.mission_hud.camera_caption() if game.get("mission_hud")!=null else []
	# The host's HUD is available through the chart control (Main.hud).
	if caption.is_empty():
		for child in game.get_children():
			if child.has_method("camera_caption"):caption=child.camera_caption();break
	check(not " ".join(caption).contains("SIGNAL SPIRE"),"unresolved camera caption preserves the unknown identity")
	s.sirens=s.sirens.slice(0,1);s.sirens[0].pos=Vector2(780,560);s.sirens[0].stun=100.;s.sirens[0].angle=0.
	s.units[0].pos=Vector2(900,560);s.units[0].angle=PI;s.units[0].vel=Vector2.ZERO
	s.units[1].alive=false;s.units[2].alive=false;s.paused=false
	for i in 24:s.advance(1./60.)
	s.paused=true
	check(s.command("camera"),"Main accepts the normal Siren camera action")
	game._refresh()
	check(game.unit_buttons[0].text.contains("PHOTO"),"Main refresh resolves a Siren study through the photo target contract")
	check(game.mission_hud.fleet._ordinary_task(0).contains("PHOTO"),"fleet task displays the same study")
	s.paused=false
	for i in 9*60:s.advance(1./60.)
	s.paused=true;game._refresh()
	check(s.mission.photo.shots.size()==1,"Siren exposure completes into film through the real host")
	game.queue_free();await process_frame
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://audit-photo-ui.save"+suffix)
	print("AUDIT PHOTO UI CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures else 0)
