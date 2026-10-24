extends RefCounted
# Synchronous UI metrics extracted from main. Main retains the original entry
# points, mutable session state and Node-owned asynchronous capture lifetimes.
# Revert this PR to restore these bodies in main. No schema or rule changes.
static func emit_ui_metrics(host, snapshot: Dictionary={}) -> void:
	if snapshot.is_empty(): snapshot=host._ui_metrics()
	if OS.get_name()=="Android":
		if host.metrics_session.is_empty():host.metrics_session="%d-%d"%[OS.get_process_id(),Time.get_ticks_usec()]
		host.metrics_serial+=1
		for record in host.MetricsTransport.encode(snapshot,host.metrics_session,host.metrics_serial):print(record)
	else:print("SS_UI_METRICS ",JSON.stringify(snapshot))


static func rect_values(host, rect: Rect2) -> Array:
	return [snappedf(rect.position.x,0.001),snappedf(rect.position.y,0.001),snappedf(rect.size.x,0.001),snappedf(rect.size.y,0.001)]

static func planner_intent_metrics(host) -> Dictionary:
	# Only operator-owned state; never serialize the model's hidden enemy state.
	var own_units=[]
	for id in host.sim.units.size():
		var unit=host.sim.units[id]; var goals=[]
		for goal in host.sim.route_goals(id):
			goals.append({"pos":[goal.pos.x,goal.pos.y],"mode":goal.mode,"stop":goal.stop,"legacy":goal.get("legacy",false)})
		var own={"alive":unit.alive,"pos":[unit.pos.x,unit.pos.y],"velocity":[unit.vel.x,unit.vel.y],"battery":unit.battery,"silent":unit.silent,"hold":unit.hold,"goals":goals}
		if id>0:own["drive"]=unit.get("drone_drive","transit")
		own_units.append(own)
	return {"mission":host.mission_index,"paused":host.sim.paused,"selected":host.sim.selected,"elapsed":host.sim.elapsed,"oxygen":host.sim.oxygen,"hull":host.sim.hull,"tools":host.sim.tools.duplicate(),"queue":host.sim.queue_mode,"pass_through":host.sim.pass_through,"units":own_units}

static func ui_metrics(host, capture_phase: String="layout_only") -> Dictionary:
	var viewport=host.get_viewport_rect().size; var window=Vector2(host.get_window().size)
	var safe=Rect2(Vector2.ZERO,window)
	if OS.get_name()=="Android": safe=Rect2(DisplayServer.get_display_safe_area()).intersection(safe)
	var controls: Array=[]; var targets: Dictionary={}
	var planner_visible=host.screen=="program" and host.route_editor.is_visible_in_tree()
	if planner_visible:
		for control in host.route_editor.find_children("*","Button",true,false):
			if control.has_meta("action"): targets[control.get_meta("action")]=control
	elif host.hud.visible:
		targets=host.mission_hud.action_controls()
	elif host.get_node_or_null("ConfluenceResolution")!=null:
		for child in host.get_node("ConfluenceResolution").actions.get_children():
			if child is Button and child.has_meta("action"):targets[child.get_meta("action")]=child
	else:
		var candidates=host.menu.find_children("*","Button",true,false)+host.menu.find_children("*","Slider",true,false)
		for control in candidates: targets[control.get_meta("action",control.get_meta("ui_action",str(control.get_instance_id())))]=control
	for action in targets:
		var control=targets[action]
		if not control.is_visible_in_tree(): continue
		var visual:Rect2=control.get_global_rect(); var hit=visual.intersection(Rect2(Vector2.ZERO,viewport))
		var parent=control.get_parent()
		while parent!=null:
			if parent is Control and parent.clip_contents: hit=hit.intersection(parent.get_global_rect())
			parent=parent.get_parent()
		if not hit.has_area(): continue
		controls.append({"action":action,"visual_rect":host._rect_values(visual),"hit_rect":host._rect_values(hit),"clipped":not hit.is_equal_approx(visual)})
	var capture_state={"phase":capture_phase,"drawn_frame":Engine.get_frames_drawn(),"mission":host.mission_index,"paused":host.sim.paused,"selected":host.sim.selected,"capture_unit":host.sim.capture_unit,"hud_visible":host.hud.is_visible_in_tree(),"menu_visible":host.menu.is_visible_in_tree(),"optical_visible":host.ocean.optical_feed!=null and host.ocean.optical_feed.is_visible_in_tree()}
	var result={"schema":1,"screen":host.screen,"orders_page":"secondary" if host.advanced_orders else "primary","hud_layout":"radial","context_page":host.mission_hud.page if host.advanced_orders else "water","chart_view":{"mode":host.ocean.chart_camera.mode,"zoom":host.ocean.chart_camera.zoom,"center":[host.ocean.chart_camera.center.x,host.ocean.chart_camera.center.y]},"viewport":[viewport.x,viewport.y],"window":[window.x,window.y],"safe_rect":host._rect_values(safe),"density_dpi":host.ui_density_dpi(),"density_source":host.ui_density_source(),"chart_rect":host._rect_values(host.ocean.get_global_rect()),"scroll_rect":host._rect_values(host.scroll.get_global_rect().intersection(host.menu.get_global_rect()).intersection(Rect2(Vector2.ZERO,viewport))),"scroll_vertical":host.scroll.scroll_vertical,"settings_values":{"music":host.settings.get("music",0.5),"effects":host.settings.get("effects",0.8),"mute":host.settings.get("mute",false)},"capture_state":capture_state,"controls":controls}
	result["context_subject_kind"]=host.mission_hud.subject.get("subkind","site") if host.advanced_orders and host.mission_hud.page=="object" else ""
	if planner_visible:
		var preview=host.route_editor.preview; var camera=preview.chart_camera; var chart=preview.get_global_rect(); var scale=window/viewport
		result.chart_rect=host._rect_values(chart)
		result["planner"]={"preview_physical":host._rect_values(Rect2(chart.position*scale,chart.size*scale)),"zoom":camera.zoom,"center":[camera.center.x,camera.center.y],"intent":host._planner_intent_metrics()}
	return result

