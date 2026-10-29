extends RefCounted
const Table=preload("res://src/presentation/quality/quality_table.gd")
var _headless:bool
var _dirty:=true
var _idle_seconds:=0.0
var _was_idle:=false
func _init(headless:bool=DisplayServer.get_name()=="headless")->void:
	_headless=headless
# Idle draw gate; does not disable input processing, timers or simulation.
# invalidate() must be called for discrete visual changes before the next draw.
func invalidate()->void:
	_dirty=true
func should_redraw(seconds:float,idle:bool,changed:bool=false,animated_overlay:bool=false,gesture_active:bool=false)->bool:
	# Bypass throttling headless, preserving callers' existing technical probes.
	if _headless:return true
	if not idle:
		_was_idle=false;_idle_seconds=0.0;_dirty=false;return true
	if is_finite(seconds) and seconds>0.0:_idle_seconds+=seconds
	var redraw:=not _was_idle or _dirty or changed or animated_overlay or gesture_active or _idle_seconds+0.000001>=Table.IDLE_HEARTBEAT_SECONDS
	_was_idle=true
	if redraw:_idle_seconds=0.0;_dirty=false
	return redraw
