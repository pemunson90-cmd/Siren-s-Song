extends Control
# Accidental-order safety for plain water taps and a short-lived undo for the last route order.
# A tap on water issues at once only when it replaces nothing. If the selected craft already has
# a route, hold or exposure under way, the tap sets a pending marker. REPLACE ROUTE replaces,
# ADD TO ROUTE extends (offered only when there is a route), CANCEL drops it. Tapping the marker
# again also replaces. Main holds dive time while this dialog is open.
const UiStyle := preload("res://src/presentation/ui_style.gd")
const UNDO_MS := 10000
# C8: the switch stays on one line and names its state; ON stops at each added point, OFF keeps moving through it.
const POINTS_TEXT := "STOP AT EACH NEW POINT · %s"
var host
var pending := {}
var undo := {}
var panel: PanelContainer
var prompt: Label
var go_button: Button
var add_button: Button
var cancel_button: Button
var points_button: CheckButton
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
	points_button = _button(row, POINTS_TEXT % "ON", func(): host._order("waypoint_mode"), "order_points", CheckButton.new())
	cancel_button = _button(row, "CANCEL", cancel, "order_cancel")
	undo_button = _button(self, "UNDO", do_undo, "order_undo")
	var chip := StyleBoxFlat.new(); chip.bg_color = Color(.018, .055, .075, .94); chip.border_color = Color("6bd5cb"); chip.set_border_width_all(1); chip.set_corner_radius_all(6)
	chip.content_margin_left = 12; chip.content_margin_right = 12; chip.content_margin_top = 8; chip.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", chip)
	undo_button.add_theme_stylebox_override("normal", chip)
	panel.hide(); undo_button.hide()
	panel.minimum_size_changed.connect(func():call_deferred("_fit_panel"))
func _button(parent: Node, text: String, action: Callable, id: String, b: Button = Button.new()) -> Button:
	b.text = text; b.focus_mode = Control.FOCUS_NONE; b.autowrap_mode = TextServer.AUTOWRAP_WORD
	b.pressed.connect(action, CONNECT_DEFERRED); b.set_meta("action", id); b.set_meta("ui_action", id); parent.add_child(b); UiStyle.apply_for(b, id); return b
# True when a plain tap would discard something the player may still want.
func replaces_plan() -> bool:
	var sim = host.sim; var u = sim.units[sim.selected]
	if sim.queue_mode: return false
	return stops_count() > 0 or u.hold != "" or sim.capture_feedback(sim.selected).unit >= 0
# Stops still ahead. The last route node stays queued while the craft brakes onto it, so a
# craft already on its final stop has none ahead and no route to replace.
func stops_count() -> int:
	var sim = host.sim; var u = sim.units[sim.selected]
	if u.route.is_empty(): return 0
	var count: int = sim.route_goals().size(); var node: Dictionary = u.route[0]
	var reached: bool = u.pos.distance_to(node.pos) < (9.0 if node.stop else 11.0) and (node.get("goal", false) or not u.has("route_plan"))
	return maxi(0, count - (1 if reached else 0))
const HOLD_NAMES := {"HOLD": "HOLD", "CONTACT": "IF CONTACT hold", "DRONE": "WAIT DRONE hold", "SCOUT": "SCOUT guard", "SCOUT_STOP": "SCOUT stop"}
static func stops_text(count: int) -> String:
	return "%d stop%s" % [count, "" if count == 1 else "s"]
# What the selected craft is doing now, read from live state each refresh.
func orders_text() -> String:
	var sim = host.sim; var u = sim.units[sim.selected]; var parts := []
	if stops_count() > 0: parts.append("has a route (%s)" % stops_text(stops_count()))
	if u.hold != "": parts.append("is on %s" % HOLD_NAMES.get(u.hold, u.hold))
	if sim.capture_feedback(sim.selected).unit >= 0: parts.append("has camera work under way")
	return " and ".join(parts) if not parts.is_empty() else "has no orders now"
# What UNDO restores, named before the press.
static func restore_text(record: Dictionary) -> String:
	var goals: Array = record.get("goals", []); var hold: String = record.get("hold", "")
	var text := "no route" if goals.is_empty() else stops_text(goals.size())
	if hold != "": text += " + " + HOLD_NAMES.get(hold, hold)
	return text
func tap_water(world: Vector2) -> void:
	var sim = host.sim
	if not pending.is_empty() and pending.unit == sim.selected:
		var near: float = host.ui_touch_height
		if host.ocean.screen_position(world).distance_to(host.ocean.screen_position(pending.point)) <= near:
			confirm(false); return
	if replaces_plan():
		pending = {"unit": sim.selected, "point": world}; undo = {}
		sim.message = "Marker set · REPLACE ROUTE replaces %s's orders%s · tap elsewhere to move the marker" % [sim.units[sim.selected].name, ", ADD TO ROUTE extends its route" if not sim.units[sim.selected].route.is_empty() else ""]
		host._refresh(); return
	host._order("route", {"point": world}) # TRAVEL:water_leg
func confirm(append: bool) -> void:
	if pending.is_empty(): return
	var sim = host.sim; var point: Vector2 = pending.point; var unit: int = pending.unit
	pending = {}
	if sim.selected != unit: host._order("select", {"unit": unit})
	var before: bool = sim.queue_mode
	sim.queue_mode = append and not sim.units[unit].route.is_empty()
	host._order("route", {"point": point}) # TRAVEL:water_leg_confirm
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
		prompt.text = "%s %s. New route to the marker? Dive time is held until you choose." % [sim.units[sim.selected].name, orders_text()]
		go_button.text = "REPLACE ROUTE"; add_button.text = "ADD TO ROUTE"
		# ADD and its pass/stop choice exist only when there is a route to add to.
		var can_add: bool = stops > 0 and not sim.units[sim.selected].route.is_empty()
		add_button.visible = can_add; add_button.disabled = not can_add; points_button.visible = can_add
		points_button.set_pressed_no_signal(not sim.pass_through); points_button.text = POINTS_TEXT % ("OFF" if sim.pass_through else "ON"); points_button.autowrap_mode = TextServer.AUTOWRAP_OFF
		for b in [go_button, add_button, points_button, cancel_button, prompt]:
			b.add_theme_font_size_override("font_size", font)
			if b is Button:
				var widest := 0.0
				for word in ([b.text] if b is CheckButton else b.text.split(" ", false)): widest = maxf(widest, b.get_theme_font("font").get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, font).x)
				var mark: float = b.get_theme_icon("checked").get_width() + b.get_theme_constant("h_separation") if b is CheckButton else 0.0
				b.custom_minimum_size = Vector2(maxf(h * 1.55, widest + mark + b.get_theme_stylebox("normal").get_minimum_size().x + 2), h)
		panel.custom_minimum_size = Vector2(width, 0); panel.reset_size()
		place(bounds.x, floor_y, h)
	if undo_button.visible:
		undo_button.text = "UNDO  ·  %s back to %s" % [undo.name, restore_text(undo)]
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
	place(host.ocean.chart_width(), floor_y, host.ui_touch_height)
	# The deferred fit can move the dialog after mission_hud's own overlap check; the tip card yields as it does there.
	if hud.hints.panel.visible and hud.hints.panel.get_global_rect().intersects(panel.get_global_rect()): hud.hints.panel.hide()
# WP-35: the dialog covers neither the selected craft nor the pending marker. The bottom centre comes first;
# then the top centre (below PAUSE and any threat banner); then the same two rows at the left or right edge.
func craft_rect(h: float) -> Rect2:
	var at: Vector2 = host.ocean.screen_position(host.sim.units[host.sim.selected].pos)
	return Rect2(at - Vector2.ONE * h * .6, Vector2.ONE * h * 1.2)
func marker_rect(h: float) -> Rect2:
	if pending.is_empty(): return Rect2()
	var at: Vector2 = host.ocean.screen_position(pending.point)
	return Rect2(at - Vector2.ONE * h * .55, Vector2.ONE * h * 1.1)
func place(width: float, floor_y: float, h: float) -> void:
	var dims := panel.size; var top := maxf(host.mission_hud.threat_floor(), h * 2)
	var bottom := maxf(top, floor_y - dims.y - 10)
	var left := clampf(12.0, 0.0, maxf(0.0, width - dims.x)); var centre := clampf((width - dims.x) / 2, 0.0, maxf(0.0, width - dims.x)); var right := maxf(0.0, width - dims.x - 12.0)
	var avoid: Array[Rect2] = [craft_rect(h).grow(h * .25)]
	if not pending.is_empty(): avoid.append(marker_rect(h).grow(h * .25))
	var best := Vector2(centre, bottom); var least := INF
	for at in [Vector2(centre, bottom), Vector2(centre, top), Vector2(left, bottom), Vector2(right, bottom), Vector2(left, top), Vector2(right, top)]:
		var rect := Rect2(at, dims); var covered := 0.0
		for area in avoid:
			var over := rect.intersection(area); covered += over.size.x * over.size.y
		if covered < least: least = covered; best = at
		if covered == 0.0: break
	panel.position = best
func _draw() -> void:
	if pending.is_empty() or host == null or not panel.visible: return
	var unit = host.sim.units[pending.unit]
	var from: Vector2 = host.ocean.screen_position(unit.pos); var to: Vector2 = host.ocean.screen_position(pending.point)
	var colour := Color("efc28d")
	draw_dashed_line(from, to, Color(colour, .8), 2.0, 8.0)
	draw_arc(to, host.ui_touch_height * .42, 0, TAU, 40, colour, 2.5)
	draw_line(to - Vector2(10, 0), to + Vector2(10, 0), colour, 2.0); draw_line(to - Vector2(0, 10), to + Vector2(0, 10), colour, 2.0)
