extends SceneTree
# PHOTO RULES through the real Main: the chart draws the loop clock, the post
# return clock and the window check from the player's findings and last contacts
# without error, and draws nothing before anything is studied.
const Photo=preload("res://src/simulation/photo_capture.gd")
const Findings=preload("res://src/simulation/photo_findings.gd")
const LoopClock=preload("res://src/photo_rules/loop_clock.gd")
const PostClock=preload("res://src/photo_rules/post_clock.gd")
const WindowCheck=preload("res://src/photo_rules/window_check.gd")
var checks=0
var failures=0
var game
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
	for n in 4:await process_frame
func run():
	root.size=Vector2i(1280,720);await process_frame;await process_frame
	game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="runtime-test";root.add_child(game)
	game.store.path="user://rules-ui.save"
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(game.store.path+suffix)
	await settle()
	game.hints_seen=["move","pause","drone","sweep","noise"]
	game._start_mission(3);await settle()
	var s=game.sim;s.units[1].alive=false;s.units[2].alive=false
	game.ocean.sim=s;game._refresh();game.ocean.queue_redraw();await settle()
	check(LoopClock.entries(s).is_empty() and PostClock.entries(s).is_empty() and WindowCheck.entries(s).is_empty(),"nothing is clocked before anything is studied")
	# Studied: a loop, a post, a cycle and a lane, with recent sightings.
	Photo.state(s);s.sirens[0]["type"]="patroller"
	var pts:Array=s.sirens[0].patrol_points.map(func(p):return Findings.pt(p))
	pts.append(pts[0])
	var hatch=s.mission.objectives[2]
	Findings.file(s,[
		Findings.make("loop_0","loop","S1 PATROL LOOP · 4 turns",0.7,3,1,{"pts":pts}),
		Findings.make("post_1","post","S2 SENTINEL · holds its post",0.7,3,1,{"pos":Findings.pt(s.sirens[1].home),"r":190.0}),
		Findings.make("frame_cycle:hatch","cycle","BAY HATCHES",0.7,3,1,{"pos":Findings.pt(hatch.pos),"period":30.0,"open":7.0,"phase":0.0}),
		Findings.make("load:frames","route","LOAD LANE",0.7,3,1,{"pts":[Findings.pt(Vector2(1320,770)),Findings.pt(Vector2(1540,880))]})])
	for i in 2:
		s.contacts[i]={"pos":s.sirens[i].pos+(Vector2(300,0) if i==1 else Vector2.ZERO),"time":s.elapsed,"mode":"INVESTIGATE" if i==1 else "PATROL","lock":0.0,"angle":0.0,"target":-1,"type":str(s.sirens[i].type),"band":s.sirens[i].band,"transition":{},"source":"optical","confidence":1.0}
	check(LoopClock.entries(s).size()==1 and PostClock.entries(s).size()==1 and WindowCheck.entries(s).size()==1,"a loop, a post and a window are clocked once studied")
	game._refresh();game.ocean.queue_redraw();await settle()
	await process_frame
	check(game.ocean.is_inside_tree(),"the chart draws the clocks without error")
	# The camera text carries the window check when framing the hatches.
	s.units[0].pos=hatch.pos+Vector2(-120,0);s.units[0].angle=0.0;s.units[0].vel=Vector2.ZERO;s.units[0].band=1;s._use_band(1)
	s.camera_context()
	game._refresh();game.ocean.queue_redraw();await settle()
	check(WindowCheck.camera_line(s,hatch.pos).contains("you arrive in"),"the hatches carry the route-aware line")
	game.queue_free();await process_frame
	for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://rules-ui.save"+suffix)
	print("PHOTO RULES UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
