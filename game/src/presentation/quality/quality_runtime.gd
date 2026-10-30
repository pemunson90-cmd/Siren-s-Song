extends RefCounted
# QUALITY integration seam. Revert by dropping Main's process/refresh calls.
# Wall-time sampling never changes simulation speed, FPS cap or the selected tier.
const Governor=preload("res://src/presentation/quality/quality_governor.gd")
const Table=preload("res://src/presentation/quality/quality_table.gd")
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Store=preload("res://src/persistence/settings_store.gd")
var governor=Governor.new()
var last_tick:int=0
var wall_seconds:=0.0
var last_context:int=0
var last_visual:int=0
var notice:PanelContainer
func process(host, _dt:float)->void:
	var now=Time.get_ticks_usec()
	wall_seconds=float(now-last_tick)/1000000.0 if last_tick>0 else 0.0
	last_tick=now
	var context=hash([host.screen,host.sim.mission.id]) if host.sim.mission!=null else 0
	var eligible=host.screen=="mission" and not host.sim.paused and context==last_context and DisplayServer.window_is_focused()
	last_context=context
	governor.observe_frame(wall_seconds,Settings.current.quality,eligible)
	if host.ocean!=null:
		host.ocean.quality_tier=Settings.current.quality
		host.ocean.quality_gesture_active=host.map_gesture.active()
	if not governor.suggestion().is_empty() and not is_instance_valid(notice):_build_notice(host)
	if is_instance_valid(notice):
		notice.visible=host.screen=="mission" and not governor.suggestion().is_empty()
		notice.position=Vector2(12,host.ocean.instrument_top+host.ui_touch_height*2.8)
		# Shrink back to the current minimum after width-driven text wrapping.
		notice.size=Vector2(maxf(1,host.size.x-24),0)
func refresh(host,periodic:bool)->bool:
	if not periodic:
		governor.invalidate()
		if host.ocean!=null:host.ocean.quality_gate.invalidate();host.ocean.queue_redraw()
	var visual=hash([host.sim.selected,host.sim.message,host.sim.paused,host.sim.queue_mode,host.advanced_orders,host.knock_armed,host.decoy_armed,host.size])
	var changed=visual!=last_visual
	last_visual=visual
	var redraw=not periodic or governor.should_redraw(wall_seconds,host.sim.paused,changed,false,host.map_gesture.active())
	return redraw
func _build_notice(host)->void:
	notice=PanelContainer.new();notice.name="QualitySuggestion";host.hud.add_child(notice)
	var box=VBoxContainer.new();notice.add_child(box)
	var label=Label.new();label.text="LOW EFFECTS may improve frame rate.";label.autowrap_mode=TextServer.AUTOWRAP_WORD;label.size_flags_horizontal=Control.SIZE_EXPAND_FILL;box.add_child(label)
	for row in [["USE LOW EFFECTS","quality_accept"],["DISMISS","quality_dismiss"]]:
		var b=Button.new();b.text=row[0];b.size_flags_horizontal=Control.SIZE_EXPAND_FILL;b.custom_minimum_size.y=host.ui_touch_height
		b.custom_minimum_size.x=host.ui_touch_height*1.6;b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
		b.set_meta("ui_action",row[1]);box.add_child(b)
		if row[1]=="quality_accept":b.pressed.connect(func():_accept(host),CONNECT_DEFERRED)
		else:b.pressed.connect(func():governor.dismiss();notice.hide(),CONNECT_DEFERRED)
func _accept(host)->void:
	var store=Store.new();store.path=host.settings_path
	var values=store.load_settings();values.quality=Table.LOW_EFFECTS
	# Explicit consent, using the ordinary settings store; report disk failures.
	Settings.apply(values,host)
	if not store.save_settings(values):host.sim.message=store.warning
	governor.dismiss();notice.hide();host._refresh()
