extends Control
# Water taps, the rock confirm bar and a short-lived undo for the last route order.
# WP-127: a water tap is one predictable thing. A craft with a route gets the tap as one more point at the end of the
# route; a craft with none gets a new route. No REPLACE / ADD / CANCEL card. Replacing the whole route is REPLACE ROUTE on the
# ROUTE page of the order wheel (replace_route). The only question left is a leg across charted rock: that leg is drawn red and a slim bar
# at the chart's edge (SEND ANYWAY / CANCEL) asks first. The bar covers none of the chart above it, and a tap on open water
# elsewhere just plots. UNDO takes back the last order and goes once the route it would restore to has ended.
# Main holds dive time while the bar is open.
const UiStyle := preload("res://src/presentation/ui_style.gd")
const UNDO_MS := 10000
const UNDO_MIN_FONT := 14 # never under the HUD's 14-point reading floor (the pause plate keeps the same floor)
const EXTRACTION_TEXT := "%s: heading to extraction."
const Words := preload("res://src/presentation/hud_words.gd")
const HandPilot := preload("res://src/simulation/hand_pilot/hand_pilot.gd")
const RED := Color("e0634f")
const MODE_MARGIN := 6.0
var host
var pending := {}
# WP-167: depth bands the player has sent a route into uncharted water at (SEND ANYWAY) in this dive; later route taps at that depth do not ask again.
var uncharted_ok := {}
var undo := {}
var panel: PanelContainer
var prompt: Label
var go_button: Button
var cancel_button: Button
var undo_button: Button
var mode_font := 16
func setup(owner) -> void:
	host = owner; mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel = PanelContainer.new(); panel.mouse_filter = Control.MOUSE_FILTER_STOP; add_child(panel)
	var row := HBoxContainer.new(); row.add_theme_constant_override("separation", 10); panel.add_child(row)
	prompt = Label.new(); prompt.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prompt.size_flags_horizontal = Control.SIZE_EXPAND_FILL; prompt.vertical_alignment = VERTICAL_ALIGNMENT_CENTER; prompt.custom_minimum_size.x = 120; row.add_child(prompt)
	go_button = _button(row, Words.TEXT.send_anyway, func(): confirm(), "order_go")
	cancel_button = _button(row, "CANCEL", cancel, "order_cancel")
	undo_button = _button(self, "UNDO", do_undo, "order_undo")
	var chip := StyleBoxFlat.new(); chip.bg_color = Color(.018, .055, .075, .94); chip.border_color = Color("6bd5cb"); chip.set_border_width_all(1); chip.set_corner_radius_all(6)
	chip.content_margin_left = 12; chip.content_margin_right = 12; chip.content_margin_top = 8; chip.content_margin_bottom = 8
	var bar := chip.duplicate(); bar.border_color = RED; bar.content_margin_top = 4; bar.content_margin_bottom = 4
	panel.add_theme_stylebox_override("panel", bar)
	undo_button.add_theme_stylebox_override("normal", chip)
	panel.hide(); undo_button.hide()
	panel.minimum_size_changed.connect(func():call_deferred("_fit_panel"))
func _button(parent: Node, text: String, action: Callable, id: String, b: Button = Button.new()) -> Button:
	b.text = text; b.focus_mode = Control.FOCUS_NONE; b.autowrap_mode = TextServer.AUTOWRAP_WORD
	b.pressed.connect(action, CONNECT_DEFERRED); b.set_meta("action", id); b.set_meta("ui_action", id); parent.add_child(b); UiStyle.apply_for(b, id); return b
# Stops still ahead for the selected craft. The last route node stays queued while the craft brakes onto it, so a
# craft already on its final stop has none ahead and no route to extend.
func stops_count() -> int:
	return stops_for(host.sim.selected)
func stops_for(id: int) -> int:
	var sim = host.sim; var u = sim.units[id]
	if u.route.is_empty(): return 0
	var count: int = sim.route_goals(id).size(); var node: Dictionary = u.route[0]
	var reached: bool = u.pos.distance_to(node.pos) < (9.0 if node.stop else 11.0) and (node.get("goal", false) or not u.has("route_plan"))
	return maxi(0, count - (1 if reached else 0))
const HOLD_NAMES := {"HOLD": "HOLD", "CONTACT": "IF CONTACT hold", "DRONE": "WAIT DRONE hold", "SCOUT": "SCOUT guard", "SCOUT_STOP": "SCOUT stop"}
static func stops_text(count: int) -> String:
	return "%d stop%s" % [count, "" if count == 1 else "s"]
# What UNDO restores, named before the press.
static func restore_text(record: Dictionary) -> String:
	var goals: Array = record.get("goals", []); var hold: String = record.get("hold", "")
	var text := "no route" if goals.is_empty() else stops_text(goals.size())
	if hold != "": text += " + " + HOLD_NAMES.get(hold, hold)
	return text
# WP-127: what a water tap does for the selected craft now; printed beside the craft and on the status strip.
func tap_mode_text() -> String:
	var sim = host.sim; var u = sim.units[sim.selected]
	if sim.DroneBay.aboard(u): return Words.TEXT.tap_mode_deploy
	return Words.TEXT.tap_mode_add if stops_count() > 0 else Words.TEXT.tap_mode_set
# WP-52: true when the straight leg this tap would plot (from the craft, or from the end of its route when the
# tap adds to it) crosses charted rock. Hand piloting through a risk stays the player's right; the bar's SEND ANYWAY
# (or a second tap on the marker) sends it. Dev dives path-find around rock, so they never warn.
func leg_crosses_rock(world: Vector2, append: bool) -> bool:
	var sim = host.sim; var u = sim.units[sim.selected]
	if not HandPilot.release(sim): return false
	# A leg added to a route starts where the queued route ends.
	var origin: Vector2 = u.route.back().pos if append and not u.route.is_empty() else u.pos
	sim._use_band(u.band)
	return HandPilot.crosses_rock(sim, origin, world)
# WP-166: the same check for water the chart holds neither as clear nor as rock at the upper or lower depth (not the middle one).
func leg_uncharted(world: Vector2, append: bool) -> bool:
	var sim = host.sim; var u = sim.units[sim.selected]
	if not HandPilot.release(sim): return false
	if uncharted_ok.has(int(u.band)): return false # WP-167: already chosen at this depth in this dive
	var origin: Vector2 = u.route.back().pos if append and not u.route.is_empty() else u.pos
	return sim.leg_uncharted(sim.selected, origin, world)
# WP-166: a depth order into a depth whose chart does not cover the craft's own spot waits for SEND ANYWAY. Returns true when it holds the order.
func hold_depth(args: Dictionary) -> bool:
	var sim = host.sim
	if args.get("confirmed", false) or not HandPilot.release(sim) or not sim.outcome.is_empty(): return false
	var band: int = int(args.get("band", -1))
	if band < 0 or band > 2 or not sim.depth_uncharted(sim.selected, band): return false
	pending = {"unit": sim.selected, "depth": band}; undo = {}
	sim.message = Words.TEXT.unscanned_depth_strip
	host._refresh(); return true
# Whether a tap now adds to the selected craft's route (it has stops ahead) rather than setting a new one.
func adds_now() -> bool:
	return stops_count() > 0 and not host.sim.units[host.sim.selected].route.is_empty()
func tap_water(world: Vector2) -> void:
	var sim = host.sim
	if pending.has("point") and pending.unit == sim.selected:
		var near: float = host.ui_touch_height
		if host.ocean.screen_position(world).distance_to(host.ocean.screen_position(pending.point)) <= near:
			confirm(); return
	var append := adds_now()
	if leg_crosses_rock(world, append):
		pending = {"unit": sim.selected, "point": world, "append": append}; undo = {}
		sim.message = Words.TEXT.rock_strip # WP-117: the bar carries the sentence; the strip does not repeat it
		host._refresh(); return
	if leg_uncharted(world, append):
		pending = {"unit": sim.selected, "point": world, "append": append, "uncharted": true, "band": int(sim.units[sim.selected].band)}; undo = {}
		sim.message = Words.TEXT.unscanned_strip
		host._refresh(); return
	pending = {}
	var before: bool = sim.queue_mode
	sim.queue_mode = append
	host._order("route", {"point": world}) # TRAVEL:water_leg
	sim.queue_mode = before
	host._refresh()
# WP-45: a tap on the extraction circle or its label is a water tap on the extraction point, with its own status line.
func tap_extraction() -> void:
	var sim = host.sim
	tap_water(sim.mission.extraction)
	if pending.is_empty() and not sim.units[sim.selected].route.is_empty():
		sim.message = EXTRACTION_TEXT % sim.units[sim.selected].name.to_upper(); host._refresh()
# SEND ANYWAY (or a second tap on the marker): the leg the bar showed, added or set exactly as the check read it.
func confirm() -> void:
	if pending.is_empty(): return
	var sim = host.sim; var unit: int = pending.unit
	if pending.has("depth"):
		var band: int = pending.depth; pending = {}
		if sim.selected != unit: host._order("select", {"unit": unit})
		host._order("depth", {"band": band, "confirmed": true}); return
	var point: Vector2 = pending.point
	var append: bool = pending.get("append", false)
	if pending.get("uncharted", false): uncharted_ok[int(pending.get("band", sim.units[unit].band))] = true # WP-167
	pending = {}
	if sim.selected != unit: host._order("select", {"unit": unit})
	var before: bool = sim.queue_mode
	sim.queue_mode = append and not sim.units[unit].route.is_empty()
	host._order("route", {"point": point}) # TRAVEL:water_leg_confirm
	sim.queue_mode = before
	host._refresh()
func cancel() -> void:
	pending = {}; host.sim.message = "Marker cancelled · orders unchanged"; host._refresh()
# WP-127: REPLACE ROUTE on the ROUTE page. The route is cleared (UNDO restores it) and the next water taps plot a new one.
func replace_route() -> void:
	var sim = host.sim; var u = sim.units[sim.selected]
	if stops_count() == 0:
		host.mission_hud.dismiss(); sim.message = Words.TEXT.replace_none % u.name; host._refresh(); return
	var record := capture(); var hold: String = u.hold
	pending = {}
	host._order("order_undo", {"goals": [], "hold": hold})
	if not sim.units[record.unit].route.is_empty(): return
	sim.message = Words.TEXT.replace_done % u.name
	record["keep"] = true; arm_undo(record); host._refresh()
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
	pending = {}; undo = {}; uncharted_ok = {}
func blocks(point: Vector2) -> bool:
	return (panel.visible and panel.get_global_rect().has_point(point)) or (undo_button.visible and undo_button.get_global_rect().has_point(point))
# WP-127: UNDO belongs to a route that is still being flown. Once the route it would undo has ended (the craft reached its last stop,
# or was lost) the chip goes, so it never offers to go "back to no route" for a route that finished by itself.
func undo_stale() -> bool:
	var sim = host.sim
	if undo.is_empty(): return false
	if Time.get_ticks_msec() > undo.until or undo.unit >= sim.units.size(): return true
	if not sim.units[undo.unit].alive: return true
	# REPLACE ROUTE cleared the route on purpose: its UNDO waits out the timer instead.
	return stops_for(undo.unit) == 0 and not undo.get("keep", false)
func refresh(bounds: Vector2, h: float, font: int, floor_y: float) -> void:
	var sim = host.sim
	mode_font = maxi(UNDO_MIN_FONT, font - 2)
	if undo_stale(): undo = {}
	if not pending.is_empty() and (pending.unit != sim.selected or not sim.units[pending.unit].alive or host.advanced_orders): pending = {}
	panel.visible = not pending.is_empty() and not host.advanced_orders
	undo_button.visible = pending.is_empty() and not undo.is_empty() and not host.advanced_orders
	if panel.visible:
		prompt.text = Words.TEXT.rock_bar
		if pending.has("depth"): prompt.text = Words.TEXT.unscanned_depth_bar % sim.Depth.NAMES[pending.depth]
		elif pending.get("uncharted", false): prompt.text = Words.TEXT.unscanned_bar
		go_button.text = Words.TEXT.send_anyway
		for b in [go_button, cancel_button, prompt]: b.add_theme_font_size_override("font_size", font)
		for b in [go_button, cancel_button]:
			b.autowrap_mode = TextServer.AUTOWRAP_OFF # one line: the bar is slim
			var widest: float = b.get_theme_font("font").get_string_size(b.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font).x
			b.custom_minimum_size = Vector2(maxf(h * 1.2, widest + b.get_theme_stylebox("normal").get_minimum_size().x + 2), h)
		# Only as wide as its words: a slim bar, never a strip across the chart. It wraps only when the chart is narrower than the words.
		var face = prompt.get_theme_font("font")
		var wanted: float = face.get_string_size(prompt.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font).x + 10.0 + go_button.custom_minimum_size.x + cancel_button.custom_minimum_size.x + 20.0 + panel.get_theme_stylebox("panel").get_minimum_size().x
		prompt.custom_minimum_size.x = 120.0
		panel.custom_minimum_size = Vector2(minf(wanted, bounds.x - 24), 0); panel.reset_size()
		place(bounds.x, floor_y, h)
	if undo_button.visible:
		# Two lines at every text size: UNDO, then what it restores. The detail line shrinks to fit the chart instead of wrapping.
		var detail := "%s back to %s" % [undo.name, restore_text(undo)]
		undo_button.text = "UNDO\n" + detail; undo_button.autowrap_mode = TextServer.AUTOWRAP_OFF
		var undo_font := font; var undo_margin: float = undo_button.get_theme_stylebox("normal").get_minimum_size().x
		var undo_face = undo_button.get_theme_font("font")
		while undo_font > UNDO_MIN_FONT and undo_face.get_string_size(detail, HORIZONTAL_ALIGNMENT_LEFT, -1, undo_font).x + undo_margin > bounds.x - 24: undo_font -= 1
		undo_button.add_theme_font_size_override("font_size", undo_font)
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
	# The deferred fit can move the bar after mission_hud's own overlap check; the tip card yields as it does there.
	if hud.hints.panel.visible and hud.hints.panel.get_global_rect().intersects(panel.get_global_rect()): hud.hints.panel.hide()
func craft_rect(h: float) -> Rect2:
	var at: Vector2 = host.ocean.screen_position(host.sim.units[host.sim.selected].pos)
	return Rect2(at - Vector2.ONE * h * .6, Vector2.ONE * h * 1.2)
func marker_rect(h: float) -> Rect2:
	if pending.is_empty() or not pending.has("point"): return Rect2()
	var at: Vector2 = host.ocean.screen_position(pending.point)
	return Rect2(at - Vector2.ONE * h * .55, Vector2.ONE * h * 1.1)
# The bar sits on the chart's bottom edge, above the status strip; it moves along that edge, then to the top edge (below PAUSE and any threat
# banner), only when it would cover the craft or the marker.
func place(width: float, floor_y: float, h: float) -> void:
	var dims := panel.size; var top := maxf(host.mission_hud.threat_floor(), h * 2)
	var bottom := maxf(top, floor_y - dims.y - 10)
	var left := clampf(12.0, 0.0, maxf(0.0, width - dims.x)); var centre := clampf((width - dims.x) / 2, 0.0, maxf(0.0, width - dims.x)); var right := maxf(0.0, width - dims.x - 12.0)
	var avoid: Array[Rect2] = [craft_rect(h).grow(h * .25)]
	if pending.has("point"): avoid.append(marker_rect(h).grow(h * .25))
	var best := Vector2(centre, bottom); var least := INF
	for at in [Vector2(centre, bottom), Vector2(centre, top), Vector2(left, bottom), Vector2(right, bottom), Vector2(left, top), Vector2(right, top)]:
		var rect := Rect2(at, dims); var covered := 0.0
		for area in avoid:
			var over := rect.intersection(area); covered += over.size.x * over.size.y
		if covered < least: least = covered; best = at
		if covered == 0.0: break
	panel.position = best
func _draw() -> void:
	if host == null: return
	if pending.has("point") and panel.visible:
		var unit = host.sim.units[pending.unit]
		var from: Vector2 = host.ocean.screen_position(unit.pos); var to: Vector2 = host.ocean.screen_position(pending.point)
		if pending.get("append", false) and not unit.route.is_empty(): from = host.ocean.screen_position(unit.route.back().pos)
		# WP-127: the leg the bar asks about is red, as every leg across charted rock is.
		var tone: Color = Color("d3b77c") if pending.get("uncharted", false) else RED # WP-166: uncharted water is amber, rock is red
		draw_dashed_line(from, to, Color(tone, .95), 3.0, 8.0)
		draw_arc(to, host.ui_touch_height * .42, 0, TAU, 40, tone, 2.5)
		draw_line(to - Vector2(10, 0), to + Vector2(10, 0), tone, 2.0); draw_line(to - Vector2(0, 10), to + Vector2(0, 10), tone, 2.0)
	_draw_mode()
	_draw_chart_label()
# WP-127: the tap mode, a small label above the selected craft.
func mode_visible() -> bool:
	var sim = host.sim
	return sim.outcome.is_empty() and not host.advanced_orders and not panel.visible and sim.units[sim.selected].alive and host.screen == "mission"
func mode_rect() -> Rect2:
	var text := tap_mode_text(); var face := ThemeDB.fallback_font
	var width := face.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, mode_font).x + 2 * MODE_MARGIN
	var tall := face.get_height(mode_font) + MODE_MARGIN
	var at: Vector2 = host.ocean.screen_position(host.sim.units[host.sim.selected].pos)
	var chart := Rect2(Vector2.ZERO, Vector2(host.ocean.chart_width(), size.y))
	var rect := Rect2(at + Vector2(host.ui_touch_height * .2 - width, -host.ui_touch_height * 1.7 - tall), Vector2(width, tall)) # above the craft's ring and left of its readout: the extraction label sits below it at a dive's start
	rect.position.x = clampf(rect.position.x, chart.position.x + 4, maxf(4.0, chart.size.x - width - 4))
	rect.position.y = clampf(rect.position.y, 4.0, maxf(4.0, chart.size.y - tall - 4))
	return rect
func _draw_mode() -> void:
	if not mode_visible(): return
	var rect := mode_rect(); var face := ThemeDB.fallback_font
	draw_rect(rect, Color(.018, .055, .075, .82)); draw_rect(rect, Color("6bd5cb", .6), false, 1.0)
	draw_string(face, rect.position + Vector2(MODE_MARGIN, face.get_ascent(mode_font) + MODE_MARGIN * .5), tap_mode_text(), HORIZONTAL_ALIGNMENT_LEFT, -1, mode_font, Color("bfeee8"))
# WP-166 (Pat, 16 Nov 2026): the chart draws one depth at a time, the selected craft's. A small label says which, kept clear of every control,
# card, craft and label (the avoid lists the tip card uses); it takes the first corner of the chart that is free.
func chart_label_text() -> String:
	var sim = host.sim
	return Words.TEXT.chart_depth % sim.Depth.NAMES[clampi(int(sim.units[sim.selected].band), 0, 2)]
func chart_label_rect() -> Rect2:
	var hud = host.mission_hud
	var text := chart_label_text(); var face := ThemeDB.fallback_font
	var width := face.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, mode_font).x + 2 * MODE_MARGIN
	var tall := face.get_height(mode_font) + MODE_MARGIN
	var avoid: Array = hud._tip_avoid() + hud._card_rects()
	var controls: Array = hud.command_controls() + [hud.close_button, hud.focus_button, host.pause_button, host.advanced_button, host.speed_button] + host.zoom_buttons + [hud.order_dock]
	for c in controls:
		if is_instance_valid(c) and c.is_visible_in_tree(): avoid.append(Rect2(c.global_position - global_position, c.size).grow(4.0))
	if panel.visible: avoid.append(Rect2(panel.global_position - global_position, panel.size))
	var chart_w: float = host.ocean.chart_width(); var top: float = maxf(hud.threat_floor(), host.pause_button.position.y + host.pause_button.size.y + 6.0)
	var floor_y: float = hud.intent.position.y if hud.intent.visible else size.y
	var spots := [Vector2(6, top), Vector2(chart_w - width - 6, top), Vector2(6, floor_y - tall - 6), Vector2(chart_w - width - 6, floor_y - tall - 6), Vector2(chart_w * .5 - width * .5, top), Vector2(chart_w * .5 - width * .5, floor_y - tall - 6)]
	var best := Rect2(spots[0], Vector2(width, tall)); var least := INF
	for at in spots:
		var rect := Rect2(at, Vector2(width, tall)); var covered := 0.0
		for area in avoid:
			var over: Rect2 = rect.intersection(area); covered += over.size.x * over.size.y
		if covered < least: least = covered; best = rect
		if covered == 0.0: break
	return best
func _draw_chart_label() -> void:
	if host.screen != "mission" or not host.sim.outcome.is_empty() or host.advanced_orders: return
	var rect := chart_label_rect(); var face := ThemeDB.fallback_font
	draw_rect(rect, Color(.018, .055, .075, .72)); draw_rect(rect, Color("6bd5cb", .45), false, 1.0)
	draw_string(face, rect.position + Vector2(MODE_MARGIN, face.get_ascent(mode_font) + MODE_MARGIN * .5), chart_label_text(), HORIZONTAL_ALIGNMENT_LEFT, -1, mode_font, Color("bfeee8"))
