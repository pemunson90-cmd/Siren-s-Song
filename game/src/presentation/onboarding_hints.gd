extends Control
# Revert display: remove MissionHUD hint installation/refresh; retain Text and
# hints_seen validation, shared pricing hints and tests. No one-line off flag.
# One-verb-at-a-time prompts in the opening operations. Each appears once per campaign, at the
# moment it matters. A prompt never blocks or auto-advances play; GOT IT only hides it. The one
# exceptions are the first lock and heard-investigation warnings, which each pause once.
const Text = preload("res://src/campaign/onboarding_text.gd")
const SWEEP := [preload("res://src/simulation/sweeper_senses.gd").WARNING]
const PricedHints = preload("res://src/presentation/photo_pricing/photo_pricing_hints.gd")
var host
var panel: PanelContainer
var label: Label
var dismiss_button: Button
var current := ""
var extra_line := ""
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
func seen(id: String) -> bool:
	return id in host.hints_seen
func show_hint(id: String) -> void:
	current = id; extra_line = ""
	if not seen(id):
		host.hints_seen.append(id)  # saved with the next ordinary archive write
func dismiss() -> void:
	current = ""; panel.hide()
func blocks(point: Vector2) -> bool:
	return panel.visible and panel.get_global_rect().has_point(point)
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
func _wanted() -> String:
	var sim = host.sim; var op: int = sim.mission.get("id", -1)
	if sim.mission.get("id", -1) > Text.MAX_OPERATION or not sim.outcome.is_empty(): return ""
	if not seen("warning") and Text.applies("warning", op) and _warning_now(): return "warning"
	var cue := _sweep_cue()
	if not cue.is_empty() and not seen("sweep") and Text.applies("sweep", op): extra_line = cue; return "sweep"
	if not seen("noise") and Text.applies("noise", op) and sim.selected == 0 and sim.motion_radius(0) > 180: return "noise"
	var any_route: bool = sim.units.any(func(u): return not u.route.is_empty())
	if not seen("move") and Text.applies("move", op) and sim.elapsed < 1.0 and not any_route: return "move"
	if not seen("pause") and Text.applies("pause", op) and not sim.paused and sim.elapsed > 0.5 and sim.elapsed < 12.0: return "pause"
	if not seen("drone") and Text.applies("drone", op) and seen("move") and seen("pause") and sim.elapsed > 4.0 and sim.units[1].route.is_empty() and sim.units[2].route.is_empty() and not sim.paused: return "drone"
	return PricedHints.wanted(sim, op, seen)
func refresh(bounds: Vector2, h: float, font: int, top: float) -> void:
	var sim = host.sim
	if host.screen != "mission":
		panel.hide(); return
	# A step the player has already taken retires its own prompt.
	if current == "move" and sim.units.any(func(u): return not u.route.is_empty()): dismiss()
	if current == "drone" and (not sim.units[1].route.is_empty() or not sim.units[2].route.is_empty()): dismiss()
	if current.begins_with("priced_") and PricedHints.stale(sim, current): dismiss()
	var wanted := _wanted()
	var busy: bool = host.advanced_orders or host.decoy_armed or host.knock_armed
	if busy and wanted not in ["warning", "sweep"] and current not in ["warning", "sweep"]:
		panel.hide(); return
	if not wanted.is_empty() and wanted != current and (current.is_empty() or wanted in ["warning", "sweep", "noise"]):
		show_hint(wanted)
		if wanted in ["warning", "sweep"]:
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
	panel.position = Vector2(12, top); panel.show(); move_to_front()
