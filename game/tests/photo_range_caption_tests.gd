extends SceneTree
# WP-10: the ring's camera caption and the simulation's refusal name one camera
# range. Reproduces the blind-play case: refused near op 0's lead with "the camera
# reaches 240m" while the caption showed 304m, the distance to the hidden source.
const Photo=preload("res://src/simulation/photo_capture.gd")
var checks=0
var failures=0
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func numbers(text:String)->Array:
	var found=[]
	var rx=RegEx.new();rx.compile("(\\d+)m")
	for m in rx.search_all(text):found.append(int(m.get_string(1)))
	return found
func run():
	var game=load("res://scenes/main.tscn").instantiate();game.store.path="user://wp10-range-%d.save"%Time.get_ticks_usec()
	root.add_child(game);game.set_process(false);game._start_mission(0)
	var s=game.sim;s.sirens=[]
	var o:Dictionary=s.mission.objectives[0]
	check(Photo.stage(o)=="lead","op 0 opens with its source as a charted lead")
	var lead:Vector2=Photo.lead_pos(o)
	var away:Vector2=(lead-o.pos).normalized()
	var u=s.units[0];u.pos=lead+away*212.0;u.vel=Vector2.ZERO;u.angle=u.pos.angle_to_point(lead)+PI
	var hidden:int=roundi(u.pos.distance_to(o.pos))
	var reach:int=roundi(Photo.reach(s,0))
	game._refresh()
	var context=s.camera_context()
	check(not context.get("ready",true) and ("reaches %dm"%reach) in str(context.text),"the simulation refuses with the camera reach (setup)")
	var caption:Array=game.mission_hud.camera_caption()
	var line:String=str(caption[2]) if caption.size()>2 else ""
	check(line.begins_with("NOT READY"),"caption still says NOT READY before the tap")
	check(hidden not in numbers(line),"caption does not show the distance to the hidden source (%dm)"%hidden)
	check(numbers(line)==[reach] and "REACH" in line,"caption names the same camera reach as the refusal")
	var path="res://src/presentation/photo_shutter/range_caption.gd"
	var Range=load(path) if ResourceLoader.exists(path) else null
	check(Range!=null,"the range caption module exists")
	if Range!=null:
		Range.enabled=false
		caption=game.mission_hud.camera_caption()
		check(caption.size()>2 and str(caption[2])=="NOT READY · %dm"%hidden,"switch off: the caption returns to the base line exactly")
		Range.enabled=true
	# A resolved subject: the caption labels distance and reach, matching the refusal pair.
	o.erase("unknown")
	u.pos=o.pos+Vector2.from_angle(o.subject.facing)*300.0;u.angle=u.pos.angle_to_point(o.pos)
	game._refresh();context=s.camera_context()
	caption=game.mission_hud.camera_caption();line=str(caption[2]) if caption.size()>2 else ""
	var refused:Array=numbers(str(context.text))
	check(not context.ready and refused.size()>=2,"out of reach the simulation names distance and range (setup)")
	check(numbers(line)==refused.slice(0,2) and "REACH" in line,"caption shows the refusal's distance and range, labelled")
	u.pos=o.pos+Vector2.from_angle(o.subject.facing)*100.0;u.angle=u.pos.angle_to_point(o.pos)
	game._refresh();caption=game.mission_hud.camera_caption();line=str(caption[2]) if caption.size()>2 else ""
	check(line.begins_with("READY") and numbers(line)==[roundi(u.pos.distance_to(o.pos)),reach],"in reach the caption reads READY with distance and reach")
	game.queue_free();await process_frame
	print("PHOTO RANGE CAPTION CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
