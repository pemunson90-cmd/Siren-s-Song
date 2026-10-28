extends RefCounted
# Live application of player settings. `current` is readable from any system
# (reduced motion, haptics, contrast) without a reference to the frontend.
const SettingsStore = preload("res://src/persistence/settings_store.gd")
const Depth = preload("res://src/presentation/frontend/settings_depth.gd")
static var current: Dictionary = SettingsStore.DEFAULTS.duplicate()
static func master_db(v: float) -> float:
	return linear_to_db(maxf(0.001, v))
static func reduced_motion() -> bool:
	return current.get("reduced_motion", false)
static func text_scale() -> float:
	return current.get("text_scale", 1.0)
# Haptics go through here so the toggle is honored everywhere. Returns whether a pulse was requested.
static func vibrate(ms: int) -> bool:
	if not current.get("haptics", true): return false
	if OS.get_name() == "Android": Input.vibrate_handheld(Depth.pulse_ms(ms, current))
	return true
static func apply(values: Dictionary, host: Control = null) -> void:
	current = SettingsStore.sanitize(values)
	Engine.max_fps = current.frame_cap
	AudioServer.set_bus_volume_db(0, master_db(current.master))
	AudioServer.set_bus_mute(0, current.master <= 0.0)
	if host == null: return
	if host.get("sound") != null:
		host.sound.music_volume = current.music; host.sound.effects_volume = current.effects
		host.sound.alerts_volume = current.alerts; host.sound.messages_volume = current.messages
		host.sound.muted = current.master<=0.0
		host.sound.night_mode = current.night_mode
	if host.get("settings") is Dictionary:
		host.settings["music"] = current.music; host.settings["effects"] = current.effects
		host.settings["mute"] = current.master<=0.0
	host.set_meta("reduced_motion", current.reduced_motion)
	host.set_meta("haptics", current.haptics)
	_theme(host)
	if host.is_inside_tree(): host.call_deferred("_layout")
# Rebuilds the base theme, then layers text size and contrast on top.
static func _theme(host: Control) -> void:
	host._theme()
	var t: Theme = host.theme
	t.default_font_size = roundi(17 * current.text_scale)
	if current.high_contrast:
		for state in ["normal", "hover", "pressed", "focus"]:
			var box := t.get_stylebox(state, "Button").duplicate() as StyleBoxFlat
			box.bg_color = Color("000000") if state == "normal" else Color("1d3a3f")
			box.border_color = Color("ffffff") if state != "pressed" else Color("ffd34d")
			box.set_border_width_all(2)
			t.set_stylebox(state, "Button", box)
		for color_name in ["font_color", "font_hover_color", "font_pressed_color"]:
			t.set_color(color_name, "Button", Color("ffffff"))
		t.set_color("font_disabled_color", "Button", Color("a9b8b8"))
		t.set_color("font_color", "Label", Color("ffffff"))
		var panel := t.get_stylebox("panel", "PanelContainer").duplicate() as StyleBoxFlat
		panel.bg_color = Color("000000"); panel.border_color = Color("ffffff")
		t.set_stylebox("panel", "PanelContainer", panel)
