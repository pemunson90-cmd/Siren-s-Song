extends SceneTree
# PHOTO1 through the real Main: viewfinder state, archive viewer, intel and saves.
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run_sim(s,seconds):
	s.paused=false
	for n in ceili(seconds*60):s.advance(1./60)
	s.paused=true
func run():
	var game=load("res://scenes/main.tscn").instantiate();game.store.path="user://photo-ui.save"
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(game.store.path+suffix)
	root.add_child(game);game.set_process(false)
	game._start_mission(0);var s=game.sim;s.sirens=[]
	var spire=Vector2(1300,300);var facing=2.74
	s.units[0].pos=spire+Vector2.from_angle(facing)*110;s.units[0].angle=facing+PI
	run_sim(s,0.2) # Let the actual forward-camera discovery pulse acquire the subject.
	game.ocean.sim=s;game._refresh();game.ocean._process(0.0)
	check(game.ocean.optical_feed.visible,"viewfinder opens when a subject is in reach, before any exposure")
	check(game.order_buttons.camera.text=="PHOTO","camera control is labelled PHOTO for an optical subject")
	s.command("camera");run_sim(s,5)
	s.units[0].pos=spire+Vector2.from_angle(facing+PI)*110;s.units[0].angle=facing
	s.command("camera");run_sim(s,5)
	game._retain_evidence()
	var entry=game.recovered_evidence.get("spire",{})
	check(entry.get("shots",[]).size()==2,"two frames of one subject are retained in the archive")
	game._evidence_gallery(0,-1,true)
	var plates=game.panel_box.find_children("*","Control",true,false).filter(func(c):return c.get("vm") is Dictionary and not c.vm.is_empty())
	check(plates.size()==2,"compare mode shows two stored frames drawn from frame data")
	game._intel_screen()
	var text="\n".join(game.panel_box.find_children("*","Label",true,false).map(func(label):return label.text))
	check(text.contains("PHOTOGRAPHIC INTELLIGENCE") and text.contains("CAMERA RESEARCH"),"intel and research screen builds")
	# Film that comes home becomes intel and survives the save.
	s.outcome="won";s.mission["recovered"]=true
	game._debrief()
	check(game.photo_intel.has("spire_wreck") and game.photo_intel.has("spire_scoring"),"recovered film becomes persistent intel")
	check(game.store.load_game().get("intel",{}).has("spire_wreck"),"intel is written to the archive")
	game.photo_intel={};game.recovered_evidence={};game._load_archive()
	check(game.photo_intel.has("spire_wreck") and game.recovered_evidence.get("spire",{}).get("shots",[]).size()==2,"intel and stored frames restore through the real loader")
	game._new_campaign();check(game.photo_intel.is_empty(),"new campaign clears intel")
	game.queue_free();await process_frame
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://photo-ui.save"+suffix)
	print("PHOTO CAPTURE UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
