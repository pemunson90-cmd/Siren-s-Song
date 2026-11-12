extends RefCounted
# WP-10 [AI-DESIGNED] SHUTTER behaviour. Seams:
#   camera_feed.gd  _draw_photo(): draws the control from rect(); _gui_input(): press()
#   mission_hud.gd  nothing; the ring's PHOTO keeps calling Main._primary_action().
# press() issues the ring's own order through Main._primary_action(), so the shutter
# runs the same checks in the same order (held task, armed targeting, camera
# context, film). The only addition is refusal(), which reads the viewfinder rows
# the panel already shows and spends nothing. REVERT: ShutterTable.enabled=false.
const Table=preload("res://src/presentation/photo_shutter/shutter_table.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
const PhotoContext=preload("res://src/simulation/photo_context.gd")
const WorkTask=preload("res://src/presentation/work_task/work_task.gd")

# Reason the next exposure of the selected craft cannot yield a usable frame, else "".
# Only a still subject framed WIDE whose required detail the viewfinder already marks
# FINE DETAIL is refused: that row can never resolve in a WIDE frame, so the exposure
# would only spend film and make shutter noise. Every other case is left to the
# simulation's own exposure rules unchanged.
static func refusal(sim)->String:
	if not Table.enabled or sim==null or sim.mission.is_empty():return ""
	if sim.capture_unit>=0:return ""
	var context:Dictionary=sim.camera_context()
	if not context.get("ready",false) or not PhotoContext.is_photo(sim,context):return ""
	var target:int=int(context.get("target",-1))
	if target<0:return ""
	var o:Dictionary=Photo.obj(sim,target)
	if o.has("siren") or not Photo.applies(o):return ""
	var uid:int=sim.selected
	if str(Photo.settings(sim,uid).get("mode","wide"))!="wide":return ""
	var rows:Array=Photo.frame(sim,uid,o,0.0).get("rows",[])
	var required:Array=o.subject.get("required",[])
	var blocked:=func(r):return str(r.get("why","")).begins_with(Table.FIXED_WIDE_REASON)
	if required.is_empty():
		if not rows.is_empty() and rows.all(blocked):return Table.TEXT.refused%str(rows[0].label)
		return ""
	for r in rows:
		if r.id in required and blocked.call(r):return Table.TEXT.refused%str(r.label)
	return ""

# Main is the node that owns the ring's PHOTO action.
static func host_of(node:Node)->Node:
	var at:Node=node
	while at!=null and not at.has_method("_primary_action"):at=at.get_parent()
	return at

# One tap on the shutter. Returns true when the ring's action was issued.
static func press(node:Node)->bool:
	var host:=host_of(node)
	if host==null or host.sim==null:return false
	var sim=host.sim
	var reason:=refusal(sim)
	if not reason.is_empty():
		sim.message=reason
		if host.get("mission_hud")!=null:host.mission_hud.task_result={"owner":WorkTask.NAMES[sim.selected],"ok":false,"text":reason}
		host._refresh()
		return false
	host._primary_action()
	return true

# Panel rectangle for the shutter in the header row, beside the FOLD toggle.
# Mirrored HUD puts it at the left end of the header, next to the left-hand dock.
static func rect(panel_width:float,touch_height:float,font_size:int,toggle:Rect2,mirrored:bool)->Rect2:
	var side:=maxf(Table.MIN_SIDE,touch_height)
	var width:=maxf(side*Table.WIDTH_PER_TOUCH,font_size*Table.CHARS_WIDE)
	var height:=maxf(side,toggle.size.y)
	if mirrored:return Rect2(8,4,width,height)
	return Rect2(toggle.position.x-width-8,4,width,height)
