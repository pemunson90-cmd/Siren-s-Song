extends Control
# Revert display: remove MissionHUD hint installation/refresh; retain Text and
# hints_seen validation, shared pricing hints and tests. No one-line off flag.
# One-verb-at-a-time prompts and first-use tips. Each appears once per campaign, at the
# moment it matters. A prompt never blocks or auto-advances play; GOT IT only hides it. The one
# exceptions are the first lock and heard-investigation warnings, which each pause once.
# WP-51 rules (this file is the one queue): one card at a time, in one fixed place while it is up. While a warning
# shows (lock card or first notice) only the tip that explains it may show; any other tip waits, hidden, and comes
# back only if its moment is still open (_moment_open), otherwise it is dropped. The card owns every tap on it and
# within one touch height of GOT IT (blocks()), so a tap near it never reaches the chart.
const Text = preload("res://src/campaign/onboarding_text.gd")
const Bay = preload("res://src/simulation/drone_bay/drone_bay.gd")
const WARNING_TIPS := ["warning", "sweep"]
const SWEEP := [preload("res://src/simulation/sweeper_senses.gd").WARNING]
const PricedHints = preload("res://src/presentation/photo_pricing/photo_pricing_hints.gd")
const FieldTools = preload("res://src/equipment/field_tools.gd")
var host
var panel: PanelContainer
var label: Label
var dismiss_button: Button
var current := ""
var extra_line := ""
# Read-only first-use observations; no simulation, session or new save fields.
# Revert 067 by removing these observations/menu tip and the first_* text rows.
var observed_mission: Dictionary = {}
var observed_counts: Dictionary = {}
var pending_first_use: Dictionary = {}  # id -> sim time its moment was last seen; dropped after Text.FIRST_USE_MOMENT
var drones_aboard_at_start := false
var parked := false  # the showing tip is hidden for a warning and waits for its moment to be checked
var placed_top := -1.0  # the card's one place while it is up (set at its first refresh)
var touch := 0.0
var menu_dismiss: Button
func setup(owner) -> void:
	host = owner; mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel = PanelContainer.new(); panel.mouse_filter = Control.MOUSE_FILTER_STOP; add_child(panel)
	var style := StyleBoxFlat.new(); style.bg_color = Color(.018, .055, .075, .95); style.border_color = Color("e9cb8c"); style.set_border_width_all(1); style.set_corner_radius_all(6)
	style.content_margin_left = 14; style.content_margin_right = 14; style.content_margin_top = 10; style.content_margin_bottom = 10
	panel.add_theme_stylebox_override("panel", style)
	var row := HBoxContainer.new(); row.add_theme_constant_override("separation", 12); panel.add_child(row)
	label = Label.new(); label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; label.size_flags_horizontal = Control.SIZE_EXPAND_FILL; label.mouse_filter = Control.MOUSE_FILTER_IGNORE; row.add_child(label)
	dismiss_button = Button.new(); dismiss_button.text = "GOT IT"; dismiss_button.focus_mode = Control.FOCUS_NONE
	dismiss_button.pressed.connect(dismiss, CONNECT_DEFERRED); dismiss_button.set_meta("action", "hint_dismiss"); dismiss_button.set_meta("ui_action", "hint_dismiss"); row.add_child(dismiss_button)
	panel.hide()
func _process(_delta: float) -> void:
	# The HUD is hidden in menus, but this component still observes the existing
	# screen and recovered-material state. Menu controls own layout and touch.
	if host == null or host.screen not in ["research", "economy"] or seen("first_research"): return
	if host.expedition.get("research", {}).get("materials", []).is_empty(): return
	var box = host.panel_box
	var first: int = mini(1, box.get_child_count())
	var tip = host._menu_text(Text.hint_text("first_research"), 15)
	box.move_child(tip, first)
	var got_it = host._button(box, "GOT IT", func():
		if is_instance_valid(tip): tip.queue_free()
		if is_instance_valid(menu_dismiss): menu_dismiss.queue_free(), "hint_dismiss")
	menu_dismiss = got_it
	box.move_child(got_it, first + 1)
	host.hints_seen.append("first_research")
func _observe_first_use() -> void:
	var sim = host.sim
	if not is_same(observed_mission, sim.mission):
		observed_mission = sim.mission
		observed_counts = sim.mission.get("field_tools", {}).get("counts", {}).duplicate()
		pending_first_use.clear()
		drones_aboard_at_start = sim.units.size() > 1 and sim.units.slice(1).all(func(u): return Bay.aboard(u))
	if sim.units.any(func(u): return not u.get("transition", {}).is_empty()):
		_queue_first_use("first_depth")
	if sim.sonar.get("listening_until", []).any(func(until): return until > sim.elapsed):
		_queue_first_use("first_emit")
	var counts: Dictionary = sim.mission.get("field_tools", {}).get("counts", {})
	for id in FieldTools.field_ids():
		if counts.has(id) and observed_counts.has(id) and counts[id] < observed_counts[id]:
			_queue_first_use("first_field_tool")
	observed_counts = counts.duplicate()
func _queue_first_use(id: String) -> void:
	if not seen(id): pending_first_use[id] = host.sim.elapsed
func seen(id: String) -> bool:
	return id in host.hints_seen
func show_hint(id: String) -> void:
	# A tip that was parked for a warning and is replaced by the warning's own tip is not lost: it may return.
	if parked and not current.is_empty() and current != id: host.hints_seen.erase(current)
	current = id; extra_line = ""; parked = false; placed_top = -1.0
	if not seen(id):
		host.hints_seen.append(id)  # saved with the next ordinary archive write
func dismiss() -> void:
	current = ""; parked = false; placed_top = -1.0; panel.hide()
# The card and one touch height round GOT IT belong to the card: a tap there never reaches the chart.
func zones() -> Array:
	return [panel.get_global_rect(), dismiss_button.get_global_rect().grow(touch)]
func blocks(point: Vector2) -> bool:
	return panel.visible and zones().any(func(zone): return zone.has_point(point))
# Whether another control (a global rectangle) sits in the card's tap area, where the card would take its taps.
func overlaps(rect: Rect2) -> bool:
	return panel.visible and zones().any(func(zone): return zone.intersects(rect))
# The drone tip's moment: every drone is still aboard (or, in a dive that starts them in the water, none has a route
# or is lost). Once a drone is deployed, ordered or lost the advice is over.
func _drone_moment() -> bool:
	for id in range(1, host.sim.units.size()):
		var u = host.sim.units[id]
		if Bay.lost(u) or not u.route.is_empty() or (drones_aboard_at_start and not Bay.aboard(u)): return false
	return true
# Whether a parked tip's reason to show is still true; if not it is dropped, never shown late.
func _moment_open(id: String) -> bool:
	var sim = host.sim
	match id:
		"move": return not sim.units.any(func(u): return not u.route.is_empty())
		"pause": return sim.elapsed < Text.PAUSE_MOMENT
		"drone": return _drone_moment()
		"noise": return sim.selected == 0 and sim.motion_radius(0) > Text.NOISE_RADIUS
	return id.begins_with("priced_") and not PricedHints.stale(sim, id)
func _sweep_cue() -> String:
	var sim = host.sim
	for row in sim.Sonar.feedback(sim, sim.selected).rows:
		if sim.elapsed - row.time > 1.2 or row.classification not in SWEEP: continue
		var bearing := fposmod(rad_to_deg(atan2(row.direction.x, -row.direction.y)), 360.)
		return "Now: %03d degrees, heard %.1fs ago." % [roundi(bearing) % 360, sim.elapsed - row.time]
	return ""
# Read only fresh receiver-earned contacts; a lock on any living own craft matters.
func _warning_now() -> bool:
	var sim = host.sim
	for id in sim.contacts:
		var c = sim.contacts[id]; var target = int(c.get("target", -1))
		var age = sim.elapsed - float(c.time)
		if age < 0 or age >= .3 or target < 0 or target >= sim.units.size(): continue
		if c.get("recipient_target", false) or not sim.units[target].alive: continue
		if c.get("mode", "") not in ["LOCKING", "BEAM"] or c.get("lock", 0) <= 0: continue
		if sim.Depth.sight(sim, c, sim.units[target]): return true
	return false
func _wanted(warning: bool = false) -> String:
	var sim = host.sim; var op: int = sim.mission.get("id", -1)
	if not sim.outcome.is_empty(): return ""
	_observe_first_use()
	if not seen("warning") and Text.applies("warning", op) and _warning_now(): return "warning"
	var cue := _sweep_cue()
	if not cue.is_empty() and not seen("sweep") and Text.applies("sweep", op): extra_line = cue; return "sweep"
	# A first-use tip whose moment has passed is dropped, never shown late.
	for id in pending_first_use.keys():
		if sim.elapsed - float(pending_first_use[id]) > Text.FIRST_USE_MOMENT or sim.elapsed < float(pending_first_use[id]): pending_first_use.erase(id)
	# While a warning shows, no tip but the one that explains it.
	if warning: return ""
	for id in pending_first_use:
		if not seen(id) and Text.applies(id, op): return id
	if op > Text.MAX_OPERATION: return ""
	if not seen("noise") and Text.applies("noise", op) and _moment_open("noise"): return "noise"
	var any_route: bool = sim.units.any(func(u): return not u.route.is_empty())
	if not seen("move") and Text.applies("move", op) and sim.elapsed < 1.0 and not any_route: return "move"
	if not seen("pause") and Text.applies("pause", op) and not sim.paused and sim.elapsed > 0.5 and _moment_open("pause"): return "pause"
	if not seen("drone") and Text.applies("drone", op) and seen("move") and seen("pause") and sim.elapsed > 4.0 and _drone_moment() and not sim.paused: return "drone"
	return PricedHints.wanted(sim, op, seen)
func refresh(bounds: Vector2, h: float, font: int, top: float) -> void:
	var sim = host.sim
	if host.screen != "mission":
		panel.hide(); return
	touch = h
	# A step the player has already taken, or a moment that has passed, retires its own prompt.
	if current == "move" and sim.units.any(func(u): return not u.route.is_empty()): dismiss()
	if current == "drone" and not _drone_moment(): dismiss()
	if current.begins_with("priced_") and PricedHints.stale(sim, current): dismiss()
	var warning: bool = host.ocean.warning_showing()
	if not warning and parked:
		parked = false
		if not _moment_open(current): dismiss()
	var wanted := _wanted(warning)
	if warning and not current.is_empty() and current not in WARNING_TIPS and wanted not in WARNING_TIPS:
		parked = true; panel.hide(); return
	var busy: bool = host.advanced_orders or host.decoy_armed or host.knock_armed
	if busy and wanted not in WARNING_TIPS and current not in WARNING_TIPS:
		panel.hide(); return
	if not wanted.is_empty() and wanted != current and (current.is_empty() or wanted in WARNING_TIPS):
		show_hint(wanted)
		if wanted in WARNING_TIPS:
			# Independent saved acknowledgements; GOT IT never resumes time.
			sim.paused = true; host.call_deferred("_refresh")
	if current == "sweep" and extra_line.is_empty(): extra_line = _sweep_cue()
	if current.is_empty():
		panel.hide(); return
	# Give wrapped text its actual width before container minimum-size measurement.
	# Otherwise the first frame can retain a one-character-wide, screen-tall card.
	var width := minf(bounds.x - 24, 620.0)
	label.custom_minimum_size.x = maxf(1, width - 40 - h * 1.4)
	label.size.x = label.custom_minimum_size.x
	label.text = Text.hint_text(current) + ("\n" + extra_line if not extra_line.is_empty() else "")
	label.add_theme_font_size_override("font_size", font); dismiss_button.add_theme_font_size_override("font_size", font)
	dismiss_button.custom_minimum_size = Vector2(h * 1.4, h)
	panel.custom_minimum_size = Vector2(width, 0); panel.reset_size()
	# The card keeps its place while it is up, but never above the floor under the pause and FLEET plates: a plate
	# that grows after the card was first placed (its wording or text size changed) would otherwise sit under the
	# card's tap area and lose its taps.
	placed_top = maxf(placed_top, top)
	panel.position = Vector2(12, placed_top); panel.show(); move_to_front()
