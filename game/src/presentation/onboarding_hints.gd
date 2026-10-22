extends Control
# One-verb-at-a-time prompts in the opening operations. Each appears once per campaign, at the
# moment it matters. A prompt never pauses, blocks or auto-advances play; GOT IT only hides it.
const Text = preload("res://src/campaign/onboarding_text.gd")
const SWEEP := ["SWEEP WINDUP", "ACTIVE SWEEP", "RETURN CHARGE"]
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
		host.hints_seen.append(id); host._save_archive()
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
func _wanted() -> String:
	var sim = host.sim; var op: int = sim.mission.get("id", -1)
	if sim.mission.get("id", -1) > Text.MAX_OPERATION or not sim.outcome.is_empty(): return ""
	var cue := _sweep_cue()
	if not cue.is_empty() and not seen("sweep") and Text.applies("sweep", op): extra_line = cue; return "sweep"
	if not seen("noise") and Text.applies("noise", op) and sim.selected == 0 and sim.motion_radius(0) > 180: return "noise"
	var any_route: bool = sim.units.any(func(u): return not u.route.is_empty())
	if not seen("move") and Text.applies("move", op) and sim.elapsed < 1.0 and not any_route: return "move"
	if not seen("pause") and Text.applies("pause", op) and not sim.paused and sim.elapsed > 0.5 and sim.elapsed < 12.0: return "pause"
	if not seen("drone") and Text.applies("drone", op) and seen("move") and seen("pause") and sim.elapsed > 4.0 and sim.units[1].route.is_empty() and sim.units[2].route.is_empty() and not sim.paused: return "drone"
	return ""
func refresh(bounds: Vector2, h: float, font: int, top: float) -> void:
	var sim = host.sim
	if host.screen != "mission" or host.advanced_orders or host.decoy_armed or host.knock_armed:
		panel.hide(); return
	# A step the player has already taken retires its own prompt.
	if current == "move" and sim.units.any(func(u): return not u.route.is_empty()): dismiss()
	if current == "drone" and (not sim.units[1].route.is_empty() or not sim.units[2].route.is_empty()): dismiss()
	var wanted := _wanted()
	if not wanted.is_empty() and wanted != current and (current.is_empty() or wanted in ["sweep", "noise"]): show_hint(wanted)
	if current == "sweep" and extra_line.is_empty(): extra_line = _sweep_cue()
	if current.is_empty():
		panel.hide(); return
	label.text = Text.hint_text(current) + ("\n" + extra_line if not extra_line.is_empty() else "")
	label.add_theme_font_size_override("font_size", font); dismiss_button.add_theme_font_size_override("font_size", font)
	dismiss_button.custom_minimum_size = Vector2(h * 1.4, h)
	panel.custom_minimum_size = Vector2(minf(bounds.x - 24, 620.0), 0); panel.reset_size()
	panel.position = Vector2(12, top); panel.show()
