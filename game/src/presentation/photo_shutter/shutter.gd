extends RefCounted
# WP-10 [AI-DESIGNED] SHUTTER behaviour. Seams:
#   camera_feed.gd  _draw_photo(): draws the control only when offered(); _gui_input(): press()
#   main.gd         _primary_action(): refuse(self) on its photographic-ready line, just
#                   before _order("camera"), after its armed-targeting cancel and held-task
#                   reason. The ring's PHOTO and the shutter both run that one function, so
#                   the checks run in the same order and a shutter press counts once.
# refuse() warns, then proceeds: the first press on a frame refusal_for() marks starts
# nothing and spends nothing; a second press on the same subject within
# Table.REPEAT_SECONDS exposes exactly as before (an exposure that starts spends film).
# REVERT: ShutterTable.enabled=false (no shutter, no warning; the ring as before).
const Table=preload("res://src/presentation/photo_shutter/shutter_table.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
const PhotoContext=preload("res://src/simulation/photo_context.gd")
const WorkTask=preload("res://src/presentation/work_task/work_task.gd")
# Last warning: {"key":subject identity, "at":seconds}. Presentation memory only, never saved.
static var warned:Dictionary={}

# True when the primary action is a photograph the selected craft can start now.
static func offered(sim,context:Dictionary)->bool:
	return Table.enabled and sim!=null and sim.capture_unit<0 and context.get("ready",false) and PhotoContext.is_photo(sim,context)

# Reason the next exposure of the selected craft cannot yield a usable frame, else "".
# Only a still subject framed WIDE whose required detail the viewfinder already marks
# FINE DETAIL is flagged: that row can never resolve in a WIDE frame. Every other case
# is left to the simulation's own exposure rules unchanged. `rows` lets the panel reuse
# the frame rows it already computed; without them the frame is computed here.
static func refusal_for(sim,context:Dictionary,rows=null)->String:
	if not offered(sim,context):return ""
	var target:int=int(context.get("target",-1))
	if target<0:return ""
	var o:Dictionary=Photo.obj(sim,target)
	if o.has("siren") or not Photo.applies(o):return ""
	var uid:int=sim.selected
	if str(Photo.settings(sim,uid).get("mode","wide"))!="wide":return ""
	if not rows is Array:rows=Photo.frame(sim,uid,o,0.0).get("rows",[])
	var required:Array=o.subject.get("required",[])
	var blocked:=func(r):return str(r.get("why","")).begins_with(Table.FIXED_WIDE_REASON)
	if required.is_empty():
		if not rows.is_empty() and rows.all(blocked):return Table.TEXT.refused%str(rows[0].label)
		return ""
	for r in rows:
		if r.id in required and blocked.call(r):return Table.TEXT.refused%str(r.label)
	return ""
static func refusal(sim)->String:
	if not Table.enabled or sim==null or sim.mission.is_empty():return ""
	return refusal_for(sim,sim.camera_context())

static func _key(sim,context:Dictionary)->String:
	return "%d|%d|%d|%d"%[sim.get_instance_id(),int(sim.mission.get("id",-1)),sim.selected,int(context.get("target",-1))]
static func _now()->float:
	return Time.get_ticks_msec()/1000.0

# Main is the node that owns the ring's PHOTO action.
static func host_of(node:Node)->Node:
	var at:Node=node
	while at!=null and not at.has_method("_primary_action"):at=at.get_parent()
	return at

# Called by Main._primary_action right before _order("camera"). Returns true when it
# held the exposure back and reported why; false when the order should go ahead.
static func refuse(host)->bool:
	if host==null or host.sim==null or not Table.enabled:return false
	var sim=host.sim
	var context:Dictionary=sim.camera_context()
	var reason:=refusal_for(sim,context)
	if reason.is_empty():warned={};return false
	var key:=_key(sim,context)
	if str(warned.get("key",""))==key and _now()-float(warned.get("at",-INF))<=Table.REPEAT_SECONDS:
		warned={};return false
	warned={"key":key,"at":_now()}
	sim.message=reason
	if host.get("mission_hud")!=null:host.mission_hud.task_result={"owner":WorkTask.NAMES[sim.selected],"ok":false,"text":reason}
	host._refresh()
	return true

# One tap on the shutter: exactly the ring's PHOTO action, Main._primary_action().
static func press(node:Node)->bool:
	var host:=host_of(node)
	if host==null or host.sim==null:return false
	host._primary_action()
	return true

# STOP EXPOSURE: the simulation has no order of its own that only ends an exposure. A new
# (replacing) route order ends it, so this plots a route to where the craft is: the craft
# stays put, the exposure ends, the film already spent stays spent. Queue mode would append
# instead of replace, so it is switched off for the one order and put back.
static func stop(node:Node)->bool:
	var host:=host_of(node)
	if host==null or host.sim==null or host.sim.capture_unit<0 or host.sim.capture_unit!=host.sim.selected:return false
	var sim=host.sim
	var queued:bool=sim.queue_mode
	if queued:host._order("queue")
	host._order("route",{"point":sim.units[sim.selected].pos})
	if queued:host._order("queue")
	var stopped:bool=sim.captures[sim.selected].is_empty()
	if stopped:sim.message=Table.TEXT.stopped
	host._refresh()
	return stopped

# Panel rectangle for the shutter in the header row, beside the FOLD toggle.
# Mirrored HUD puts it at the left end of the header, next to the left-hand dock.
static func rect(panel_width:float,touch_height:float,font_size:int,toggle:Rect2,mirrored:bool)->Rect2:
	var side:=maxf(Table.MIN_SIDE,touch_height)
	var width:=maxf(side*Table.WIDTH_PER_TOUCH,font_size*Table.CHARS_WIDE)
	var height:=maxf(side,toggle.size.y)
	if mirrored:return Rect2(8,4,width,height)
	return Rect2(toggle.position.x-width-8,4,width,height)
