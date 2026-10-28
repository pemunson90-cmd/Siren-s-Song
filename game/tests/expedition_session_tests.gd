extends SceneTree
# Staged outcomes verify mode/save isolation; operation gameplay is inherited.
const State=preload("res://src/campaign/runs/run_state.gd")
const Archive=preload("res://src/campaign/runs/run_archive.gd")
const Modes=preload("res://src/presentation/runs/modes_frontend.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
	for n in 4:await process_frame
func run():
	var path="user://expedition-session.save"
	for file in [path,path+".runs"]:
		for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(file+suffix)
	var host=load("res://scenes/main.tscn").instantiate()
	host.capture_scenario="runtime-test";host.store.path=path;root.add_child(host);await settle()
	host.economy=preload("res://src/campaign/economy.gd").new_state("standard",true)
	host._show_campaign();host._save_archive()
	var before=FileAccess.get_file_as_bytes(path);var snapshot=host.sim.snapshot()
	var front=load("res://src/presentation/frontend/frontend.gd").new()
	host.add_child(front);front.setup(host,true);front._mode_select();await settle()
	check(front.screen=="modes","Start has a separate mode selector")
	var career=front.find_children("*","Button",true,false).filter(func(b):return b.get_meta("ui_action","")=="mode_career")
	check(career.size()==1 and career[0].disabled,"Career is visibly unavailable until057")
	check(Archive.persist(host,State.new_run(12345)),"seeded run writes only its sidecar")
	Modes.start(front);await settle()
	var session=host.get_node_or_null("ExpeditionSession")
	check(session!=null and session.screen=="expedition_menu" and not session.active_started,"expedition previews without committing a launch")
	if session!=null:
		session._begin();await settle()
		check(session.active_started and session.sim.paused and session.run_state.in_flight,"launch commits before entering paused physical simulation")
		check(host.process_mode==Node.PROCESS_MODE_DISABLED,"campaign stays frozen during expedition")
		session.sim.outcome="won";session._debrief();await settle()
		check(session.run_state.cursor==1 and session.run_state.status=="active","successful recovery advances exactly one operation")
		session._return();await settle()
	check(host.sim.snapshot()==snapshot and FileAccess.get_file_as_bytes(path)==before,"run outcome preserves Ironman campaign simulation and archive bytes")
	check(Archive.restore(host).cursor==1,"between-operation state survives return")
	Modes.start(front);await settle();session=host.get_node_or_null("ExpeditionSession")
	if session!=null:
		session._begin();session._debrief(true);await settle()
		check(session.run_state.status=="lost","ending an active dive is permanent run loss")
		session._return();await settle()
	check(Archive.restore(host).status=="lost" and FileAccess.get_file_as_bytes(path)==before,"loss persists outside campaign SAVE2 timeline")
	var save2=preload("res://src/persistence/save_states/save2_controller.gd")
	check(save2.locked(host),"mode return preserves079 Ironman hard-save guard")
	host.queue_free();await settle()
	print("EXPEDITION SESSION CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
