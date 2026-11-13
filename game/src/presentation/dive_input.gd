extends RefCounted
# [AI-DESIGNED] A8 step 2 (code audit, Pat approved 2026-11-12): the one place
# that turns pointer, touch, mouse-wheel and keyboard events into dive actions.
# It used to live inside main.gd.
#
# What it does, unchanged: routes an event through the debug console, the
# optical feed, the HUD panels and the chart gesture, in that order; turns taps
# on the chart into torpedo shots, decoy drops or target pickers; zooms the
# chart; and handles Escape and Space. Each function takes the host (main.gd or
# a session subclass) and reaches the dive through the host's own fields and
# methods. main.gd keeps thin methods with the engine's names that forward here.
const ReleaseControls=preload("res://src/presentation/release_controls.gd")
static func input(host,event:InputEvent) -> void:
	if host.debug_console!=null and host.debug_console.input(event):host.get_viewport().set_input_as_handled();return
	if host.debug_console!=null and host.debug_console.panel.visible:return
	if host.screen!="mission":return
	if host.ocean.optical_feed.route_input(event):host.get_viewport().set_input_as_handled();return
	if host.mission_hud.contact_touch.feed(host.mission_hud.contact_scroll,event):host.get_viewport().set_input_as_handled();return
	if host.mission_hud.owns_pointer(event):host.get_viewport().set_input_as_handled();return
	if host.mission_hud.fleet.handle_input(event):host.get_viewport().set_input_as_handled();return
	if host.advanced_orders:
		host.map_gesture.cancel();host.knock_press.clear()
		if host.mission_hud.popup_input(event):host.get_viewport().set_input_as_handled()
		return
	if not host.map_gesture.active():return
	var pressed=(event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed)
	if pressed and (not host.ocean.get_global_rect().has_point(event.position) or host.mission_hud.blocks(event.position)):
		host.map_gesture.cancel();return
	if host._map_event(event):host.get_viewport().set_input_as_handled()
static func gui_input(host,event: InputEvent) -> void:
	if host.screen!="mission": return
	if event is InputEventMouse or event is InputEventScreenTouch or event is InputEventScreenDrag:
		if host.mission_hud.blocks(event.position+host.global_position):return
	if event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN] and event.pressed and Rect2(host.ocean.position,host.ocean.size).has_point(event.position):
		host.map_gesture.cancel(); host.ocean.zoom_at(1.2 if event.button_index==MOUSE_BUTTON_WHEEL_UP else 1.0/1.2,event.position-host.ocean.position); host._view_changed(); host.accept_event(); return
	var pressed=(event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT)
	if pressed and Rect2(host.ocean.position,host.ocean.size).has_point(event.position) and host._map_event(event,true): host.accept_event()
static func map_event(host,event: InputEvent,local_event: bool=false) -> bool:
	if event.device==InputEvent.DEVICE_ID_EMULATION: return false
	if event is InputEventScreenTouch and event.canceled: host.map_gesture.cancel(); host.knock_press.clear(); return true
	var kind=""; var index=-1; var point=Vector2.ZERO
	if event is InputEventScreenTouch:
		kind="press" if event.pressed else "release"; index=event.index; point=event.position
	elif event is InputEventScreenDrag:
		kind="move"; index=event.index; point=event.position
	elif event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
		kind="press" if event.pressed else "release"; point=event.position
	elif event is InputEventMouseMotion and host.map_gesture.active():
		kind="move"; point=event.position
	if kind.is_empty(): return false
	if local_event: point+=host.global_position
	if kind=="press" and not host.map_gesture.active():
		host.knock_press={"armed":host.knock_armed,"decoy":host.decoy_armed,"unit":host.sim.selected,"key":host.ocean.knock_aim_key(point-host.ocean.global_position) if host.knock_armed else -1}
	var action=host.map_gesture.feed(kind,index,point)
	if action.has("zoom"): host.ocean.zoom_at(action.zoom,action.anchor-host.ocean.global_position)
	if action.has("pan"): host.ocean.pan_chart(action.pan)
	if action.get("navigation",false): host._view_changed()
	if action.has("tap") and host.ocean.get_global_rect().has_point(action.tap) and not host.mission_hud.blocks(action.tap):
		if host.knock_armed or host.knock_press.get("armed",false):
			if host.knock_armed and host.knock_press.get("armed",false):host._target_knockdown(action.tap,host.knock_press.get("key",-1))
			host.knock_press.clear(); return true
		if host.decoy_armed or host.knock_press.get("decoy",false):
			if host.decoy_armed and host.knock_press.get("decoy",false) and host.knock_press.get("unit",-1)==host.sim.selected:
				host._order("decoy",{"point":host.ocean.map_position(action.tap-host.ocean.global_position)})
			host.knock_press.clear(); return true
		# UI review B6: an open contact card is closed by any other tap on the chart, and that tap does nothing else.
		var card=host.mission_hud.contact_card
		if card!=null and card.is_open():card.close();host.knock_press.clear();return true
		var targets=host.ocean.contexts_at(action.tap-host.ocean.global_position,host.ui_touch_height)
		# A drawn (observed) contact alone under the finger opens its card; beside a craft or site it is one more choice (contexts_at).
		if targets.size()==1 and targets[0].kind=="contact":
			if not host.ocean.information_at(action.tap-host.ocean.global_position):card.open(int(targets[0].key));return true
			targets=[]
		if not targets.is_empty():
			host.mission_hud.open_targets(targets);return true
		# Drawn information owns its tap even when it has no command target.
		if host.ocean.information_at(action.tap-host.ocean.global_position):return true
		var world=host.ocean.map_position(action.tap-host.ocean.global_position)
		if Rect2(Vector2.ZERO,host.ocean.world_size()).has_point(world): host.mission_hud.guard.tap_water(world)
	if action.has("ended") or action.has("tap"):host.knock_press.clear()
	return true
static func target_knockdown(host,point: Vector2,intended:int=-2) -> void:
	var chosen=host.ocean.knock_aim_key(point-host.ocean.global_position) if intended==-2 else intended
	if chosen<0 or not host.ocean.knock_visible_targets().any(func(c):return c.key==chosen):
		host.sim.message="Choose an S# FIRE box or a clear contact · no torpedo spent"
		for id in host.sim.contacts:
			var contact=host.sim.contacts[id]
			if host.sim.elapsed-contact.time>=.3:continue
			if host.ocean.screen_position(contact.pos).distance_to(point-host.ocean.global_position)>maxf(host.ui_touch_height/2,43*host.ocean.world_scale):continue
			if contact.get("mode","") in ["DISRUPTED","PINNED"]:
				host.sim.message="S%d %s · shot declined · no torpedo spent"%[int(id)+1,"stunned by EMP" if contact.mode=="DISRUPTED" else "already snared"]
				break
			var distance=host.sim.units[0].pos.distance_to(contact.pos)
			if distance>host.sim.KNOCK_RANGE:
				host.sim.message="S%d out of range · %dm / %dm · no torpedo spent"%[int(id)+1,ceili(distance),roundi(host.sim.KNOCK_RANGE)]
				break
		host.targeting_feedback=host.sim.message; host._refresh(); return
	host._order("knock",{"target":chosen})
static func chart_zoom(host,factor: float) -> void:
	host.map_gesture.cancel(); host.ocean.zoom_at(factor,host.ocean.size/2); host._view_changed()
static func view_changed(host) -> void:
	host._refresh()
	host._save_archive()
	ReleaseControls.debug_print(["SS_VIEW zoom=",snappedf(host.ocean.chart_camera.zoom,0.01)," center=",host.ocean.chart_camera.center])
	host.call_deferred("_report_targets")
static func unhandled_key(host,event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_ESCAPE:
		if host._frontend_back():host.get_viewport().set_input_as_handled();return
	if host.screen=="program":
		if event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE: host.route_editor.close()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		# SPACE pauses only live play; menus, briefing and settings never touch mission pause.
		if event.keycode==KEY_SPACE and host.screen=="mission": host._pause()
		if event.keycode==KEY_ESCAPE:
			if host.advanced_orders:host.mission_hud._back()
			elif host.knock_armed or host.decoy_armed:host._primary_action()
			else:host.sim.paused=true;host._show_campaign()
