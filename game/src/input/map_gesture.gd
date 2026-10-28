extends RefCounted
const DRAG_THRESHOLD=14.0 # Default; SETDEPTH presets apply it through threshold().
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Depth=preload("res://src/presentation/frontend/settings_depth.gd")
static func threshold()->float: return Depth.drag_threshold(Settings.current)
var touches: Dictionary={}
var origin:=Vector2.ZERO
var dragged:=false
var was_multi:=false
func active() -> bool: return not touches.is_empty()
func cancel() -> void:
	touches.clear(); dragged=false; was_multi=false
func feed(kind: String,index: int,point: Vector2) -> Dictionary:
	if kind=="press":
		if touches.has(index): return {}
		if touches.is_empty(): origin=point; dragged=false; was_multi=false
		touches[index]=point
		if touches.size()>1: was_multi=true; dragged=true
		return {}
	if not touches.has(index): return {}
	if kind=="release":
		var tap=touches.size()==1 and not dragged and not was_multi and origin.distance_to(point)<=threshold()
		touches.erase(index)
		if touches.is_empty():
			var navigation=dragged or was_multi; cancel()
			return {"tap":point} if tap else {"ended":true,"navigation":navigation}
		return {}
	if kind!="move": return {}
	var previous:Vector2=touches[index]
	var old=touches.values(); touches[index]=point
	if touches.size()>=2:
		var keys=touches.keys()
		if index not in [keys[0],keys[1]]: return {}
		var next=touches.values(); var a:Vector2=old[0]; var b:Vector2=old[1]; var c:Vector2=next[0]; var d:Vector2=next[1]
		return {"zoom":c.distance_to(d)/maxf(1,a.distance_to(b)),"anchor":(a+b)/2,"pan":(c+d-a-b)/2}
	if origin.distance_to(point)>threshold(): dragged=true
	return {"pan":point-previous} if dragged else {}
