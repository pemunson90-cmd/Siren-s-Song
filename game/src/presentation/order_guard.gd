extends Control
# Accidental-order safety for plain water taps and a short-lived undo for the last route order.
# A tap on water issues at once only when it replaces nothing. If the selected craft already has
# a route, hold or exposure under way, the tap sets a pending marker. GO replaces, ADD TO ROUTE
# extends, CANCEL drops it. Tapping the marker again also confirms. Time may stay paused throughout.
const UNDO_MS := 10000
var host
var pending := {}
var undo := {}
var panel: PanelContainer
var prompt: Label
var go_button: Button
var add_button: Button
var cancel_button: Button
var points_button: Button
var undo_button: Button
func setup(owner) -> void:
	host = owner; mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel = PanelContainer.new(); panel.mouse_filter = Control.MOUSE_FILTER_STOP; add_child(panel)
	var box := VBoxContainer.new(); box.add_theme_constant_override("separation", 6); panel.add_child(box)
	prompt = Label.new(); prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE; box.add_child(prompt)
	var row := HFlowContainer.new(); row.add_theme_constant_override("h_separation", 8); row.add_theme_constant_override("v_separation", 8); box.add_child(row)
	go_button = _button(row, "REPLACE ROUTE", func(): confirm(false), "order_go")
	add_button = _button(row, "ADD TO ROUTE", func(): confirm(true), "order_add")
	points_button = _button(row, "POINTS: PASS", func(): host._order("waypoint_mode"), "order_points")
	cancel_button = _button(row, "CANCEL", cancel, "order_cancel")
	undo_button = _button(self, "UNDO", do_undo, "order_undo")
	var chip := StyleBoxFlat.new(); chip.bg_color = Color(.018, .055, .075, .94); chip.border_color = Color("6bd5cb"); chip.set_border_width_all(1); chip.set_corner_radius_all(6)
	chip.content_margin_left = 12; chip.content_margin_right = 12; chip.content_margin_top = 8; chip.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", chip)
	undo_button.add_theme_stylebox_override("normal", chip)
	panel.hide(); undo_button.hide()
	panel.minimum_size_changed.connect(func():call_deferred("_fit_panel"))
func _button(parent: Node, text: String, action: Callable, id: String) -> Button:
	var b := Button.new(); b.text = text; b.focus_mode = Control.FOCUS_NONE; b.autowrap_mode = TextServer.AUTOWRAP_WORD
	b.pressed.connect(action, CONNECT_DEFERRED); b.set_meta("action", id); b.set_meta("ui_action", id); parent.add_child(b); return b
# True when a plain tap would discard something the player may still want.
func replaces_plan() -> bool:
	var sim = host.sim; var u = sim.units[sim.selected]
	if sim.queue_mode: return false
	return not u.route.is_empty() or u.hold != "" or sim.capture_feedback(sim.selected).unit >= 0
func stops_count() -> int:
	return host.sim.route_goals().size()
func tap_water(world: Vector2) -> void:
	var sim = host.sim
	if not pending.is_empty() and pending.unit == sim.selected:
		var near: float = host.ui_touch_height
		if host.ocean.screen_position(world).distance_to(host.ocean.screen_position(pending.point)) <= near:
			confirm(false); return
	if replaces_plan():
		pending = {"unit": sim.selected, "point": world}; undo = {}
		sim.message = "Marker set · GO replaces %s's orders, or tap elsewhere to move it" % sim.units[sim.selected].name
		host._refresh(); return
	host._order("route", {"point": world})
func confirm(append: bool) -> void:
	if pending.is_empty(): return
	var sim = host.sim; var point: Vector2 = pending.point; var unit: int = pending.unit
	pending = {}
	if sim.selected != unit: host._order("select", {"unit": unit})
	var before: bool = sim.queue_mode
	sim.queue_mode = append and not sim.units[unit].route.is_empty()
	host._order("route", {"point": point})
	sim.queue_mode = before
	host._refresh()
func cancel() -> void:
	pending = {}; host.sim.message = "Marker cancelled · orders unchanged"; host._refresh()
# Called by main before it issues a plain route order. Returns the restore record.
func capture() -> Dictionary:
	var sim = host.sim; var u = sim.units[sim.selected]
	return {"unit": sim.selected, "goals": sim.route_goals().duplicate(true), "hold": u.hold, "name": u.name}
func arm_undo(record: Dictionary) -> void:
	if record.is_empty(): return
	record["until"] = Time.get_ticks_msec() + UNDO_MS; undo = record
func do_undo() -> void:
	if undo.is_empty(): return
	var sim = host.sim; var record := undo; undo = {}; pending = {}
	if sim.selected != record.unit: host._order("select", {"unit": record.unit})
	host._order("order_undo", {"goals": record.goals, "hold": record.hold})
func reset() -> void:
	pending = {}; undo = {}
func blocks(point: Vector2) -> bool:
	return (panel.visible and panel.get_global_rect().has_point(point)) or (undo_button.visible and undo_button.get_global_rect().has_point(point))
func refresh(bounds: Vector2, h: float, font: int, floor_y: float) -> void:
	var sim = host.sim
	if not undo.is_empty() and (Time.get_ticks_msec() > undo.until or undo.unit >= sim.units.size()): undo = {}
	if not pending.is_empty() and (pending.unit != sim.selected or not sim.units[pending.unit].alive or host.advanced_orders): pending = {}
	panel.visible = not pending.is_empty() and not host.advanced_orders
	undo_button.visible = pending.is_empty() and not undo.is_empty() and not host.advanced_orders
	var width := bounds.x - 24 if host.mission_hud.text_scale >= 1.5 else minf(bounds.x - 24, 720.0)
	if panel.visible:
		var stops := stops_count()
		prompt.text = "%s already has orders%s. New route to the marker?" % [sim.units[sim.selected].name, " (%d stop%s)" % [stops, "" if stops == 1 else "s"] if stops > 0 else ""]
		go_button.text = "REPLACE ROUTE"; add_button.text = "ADD TO ROUTE"; add_button.disabled = sim.units[sim.selected].route.is_empty()
		points_button.text = "ADDED POINTS: PASS THROUGH" if sim.pass_through else "ADDED POINTS: STOP AT EACH"
		for b in [go_button, add_button, points_button, cancel_button, prompt]:
			b.add_theme_font_size_override("font_size", font)
			if b is Button:
				var widest := 0.0
				for word in b.text.split(" ", false): widest = maxf(widest, b.get_theme_font("font").get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, font).x)
				b.custom_minimum_size = Vector2(maxf(h * 1.55, widest + b.get_theme_stylebox("normal").get_minimum_size().x + 2), h)
		panel.custom_minimum_size = Vector2(width, 0); panel.reset_size()
		panel.position = Vector2((bounds.x - panel.size.x) / 2, maxf(host.mission_hud.threat_floor(), maxf(h * 2, floor_y - panel.size.y - 10)))
	if undo_button.visible:
		undo_button.text = "UNDO  ·  %s order" % undo.name
		undo_button.add_theme_font_size_override("font_size", font)
		undo_button.custom_minimum_size = Vector2(h * 3.2, h); undo_button.reset_size()
		undo_button.position = Vector2((bounds.x - undo_button.size.x) / 2, maxf(host.mission_hud.threat_floor(), maxf(h * 2, floor_y - undo_button.size.y - 10)))
	queue_redraw()
# Wrapped containers settle their minimum height after the width is assigned.
func _fit_panel() -> void:
	if not panel.visible or host == null: return
	panel.reset_size()
	var hud = host.mission_hud
	var floor_y: float = hud.intent.position.y if hud.intent.visible else host.size.y
	panel.position = Vector2((host.ocean.chart_width() - panel.size.x) / 2, maxf(hud.threat_floor(), maxf(host.ui_touch_height * 2, floor_y - panel.size.y - 10)))
func _draw() -> void:
	if pending.is_empty() or host == null or not panel.visible: return
	var unit = host.sim.units[pending.unit]
	var from: Vector2 = host.ocean.screen_position(unit.pos); var to: Vector2 = host.ocean.screen_position(pending.point)
	var colour := Color("efc28d")
	draw_dashed_line(from, to, Color(colour, .8), 2.0, 8.0)
	draw_arc(to, host.ui_touch_height * .42, 0, TAU, 40, colour, 2.5)
	draw_line(to - Vector2(10, 0), to + Vector2(10, 0), colour, 2.0); draw_line(to - Vector2(0, 10), to + Vector2(0, 10), colour, 2.0)
