extends Control
# Title, settings and credits. Sits above the existing campaign menu; dismissing
# it hands control to the original boot path untouched. Layout is a single
# centered column in a scroll view, so it holds at Fold7 cover (tall, narrow)
# and inner (near square) aspect ratios without shrinking text or targets.
const SaveStore = preload("res://src/persistence/save_store.gd")
const SettingsStore = preload("res://src/persistence/settings_store.gd")
const FrontendSettings = preload("res://src/presentation/frontend/frontend_settings.gd")
const CreditsText = preload("res://src/presentation/frontend/credits_text.gd")
const Soundscape = preload("res://src/audio/soundscape.gd")
enum Profile { NONE, OK, RECOVERED, UNREADABLE }
var host: Control
var settings_store := SettingsStore.new()
var values: Dictionary = {}
var profile := Profile.NONE
var profile_message := ""
var column: VBoxContainer
var scroll: ScrollContainer
var screen := "title"
var save_timer: Timer
var drift := 0.0
var title_label: Label
# Classifies the campaign archive without modifying it.
static func inspect_profile(store_path: String) -> Dictionary:
	var probe := SaveStore.new()
	probe.path = store_path
	var data := probe.load_game()
	var exists := FileAccess.file_exists(store_path) or FileAccess.file_exists(store_path + ".bak")
	if not data.is_empty():
		if probe.warning.is_empty(): return {"state": Profile.OK, "message": ""}
		return {"state": Profile.RECOVERED, "message": probe.warning}
	if exists:
		return {"state": Profile.UNREADABLE, "message": "Your saved campaign could not be read. It may be damaged or from an incompatible version. The original files are untouched. Starting a new campaign copies them aside first, so nothing is lost."}
	return {"state": Profile.NONE, "message": ""}
# Copies unreadable archive files aside; returns the copies made.
static func preserve_unreadable(store_path: String, stamp: int) -> Array:
	var kept := []
	for suffix in ["", ".bak"]:
		var source: String = store_path + suffix
		if not FileAccess.file_exists(source): continue
		var target: String = "%s.incompatible-%d%s" % [store_path, stamp, suffix]
		if DirAccess.copy_absolute(source, target) == OK: kept.append(target)
	return kept
func setup(main: Control) -> bool:
	host = main
	values = settings_store.load_settings()
	FrontendSettings.apply(values, host)
	var info := inspect_profile(host.store.path)
	profile = info.state; profile_message = info.message
	name = "Frontend"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var backdrop := ColorRect.new(); backdrop.color = Color("04101a"); backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE; add_child(backdrop)
	scroll = ScrollContainer.new(); scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED; add_child(scroll)
	var margin := MarginContainer.new(); margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for side in ["left", "right", "top", "bottom"]: margin.add_theme_constant_override("margin_" + side, 32)
	scroll.add_child(margin)
	column = VBoxContainer.new(); column.add_theme_constant_override("separation", 14); column.size_flags_horizontal = Control.SIZE_SHRINK_CENTER; margin.add_child(column)
	save_timer = Timer.new(); save_timer.one_shot = true; save_timer.wait_time = 0.3; add_child(save_timer); save_timer.timeout.connect(_persist)
	resized.connect(_fit_column)
	_title_screen()
	return column != null
func _process(delta: float) -> void:
	# Any host navigation away from the boot menu (mission, briefing, ending) supersedes the overlay.
	if host != null and host.get("screen") != "menu": _dismiss(); return
	if title_label == null or not is_instance_valid(title_label) or screen != "title": return
	if FrontendSettings.reduced_motion(): drift = 0.0; title_label.modulate.a = 1.0; return
	drift += delta
	title_label.modulate.a = 0.82 + 0.18 * sin(drift * 1.1)
func touch_height() -> float:
	var h = host.get("ui_touch_height") if host != null else 48.0
	return maxf(48.0, float(h))
func _fit_column() -> void:
	if column == null: return
	column.custom_minimum_size.x = clampf(size.x - 64.0, 240.0, 620.0)
func _reset(next: String) -> void:
	screen = next; title_label = null
	for child in column.get_children(): column.remove_child(child); child.queue_free()
	_fit_column()
	scroll.scroll_vertical = 0
func _text(text: String, size_px: int = 17, color: Color = Color(0, 0, 0, 0)) -> Label:
	var l := Label.new(); l.text = text; l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", roundi(size_px * FrontendSettings.text_scale()))
	if color.a > 0: l.add_theme_color_override("font_color", color)
	column.add_child(l); return l
func _button(text: String, action: Callable, id: String, disabled := false) -> Button:
	var b := Button.new(); b.text = text; b.custom_minimum_size = Vector2(0, touch_height()); b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	b.focus_mode = Control.FOCUS_NONE; b.disabled = disabled
	b.set_meta("action", id); b.set_meta("ui_action", id)
	b.pressed.connect(action, CONNECT_DEFERRED); column.add_child(b); return b
func _title_screen() -> void:
	_reset("title")
	title_label = _text("SIREN'S SONG", 42, Color("80d9cf"))
	_text("ONE PILOT. TWO DRONES. AN OCEAN THAT LISTENS.", 14)
	if not profile_message.is_empty():
		var notice := _text(profile_message, 16, Color("efc28d")); notice.name = "ProfileNotice"
	if profile == Profile.NONE:
		# First launch: there is nothing to continue and nothing to erase.
		_button("START GAME", _new_campaign, "frontend_new_campaign")
	else:
		_button("CONTINUE", _continue, "frontend_continue", profile == Profile.UNREADABLE)
		_button("ERASE PROGRESS · NEW CAMPAIGN", _new_campaign, "frontend_new_campaign")
	_button("SETTINGS", _settings_screen, "frontend_settings")
	_button("CREDITS", _credits_screen, "frontend_credits")
func _dismiss() -> void:
	set_process(false)
	if get_parent() != null: get_parent().remove_child(self)
	queue_free()
func _continue() -> void:
	_dismiss()
func _new_campaign() -> void:
	if profile == Profile.UNREADABLE:
		var kept := preserve_unreadable(host.store.path, int(Time.get_unix_time_from_system()))
		if kept.is_empty():
			_title_screen()
			var warn := _text("Could not copy the unreadable archive aside, so no new campaign was started. Check device storage.", 16, Color("efc28d")); warn.name = "ProfileNotice"
			return
		_dismiss(); host._show_campaign()
	elif profile == Profile.NONE:
		_dismiss(); host._show_campaign()
	else:
		_dismiss(); host._confirm_new_campaign()
func _settings_screen() -> void:
	_reset("settings")
	_text("SETTINGS", 32, Color("80d9cf"))
	_text("Saved on this device, separate from your campaign.", 14)
	if not settings_store.warning.is_empty(): _text(settings_store.warning, 15, Color("efc28d"))
	for row in [["master", "MASTER VOLUME"], ["music", "MUSIC VOLUME"], ["effects", "EFFECTS VOLUME"]]:
		var key: String = row[0]
		var caption := _text("%s  %d%%" % [row[1], roundi(values[key] * 100)], 17)
		var slider := HSlider.new(); slider.min_value = 0; slider.max_value = 1; slider.step = 0.05; slider.value = values[key]
		slider.custom_minimum_size.y = touch_height(); slider.set_meta("ui_action", "setting_" + key); column.add_child(slider)
		slider.value_changed.connect(func(v: float): _set_value(key, v); caption.text = "%s  %d%%" % [row[1], roundi(v * 100)])
	_text("TEXT SIZE", 17)
	var sizes := HBoxContainer.new(); sizes.add_theme_constant_override("separation", 8); column.add_child(sizes)
	for s in SettingsStore.TEXT_SCALES:
		var scale: float = s
		var b := Button.new(); b.text = "%d%%" % roundi(scale * 100); b.custom_minimum_size = Vector2(0, touch_height()); b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.focus_mode = Control.FOCUS_NONE; b.set_meta("ui_action", "text_scale_%d" % roundi(scale * 100)); b.toggle_mode = true; b.button_pressed = is_equal_approx(values.text_scale, scale)
		b.pressed.connect(func(): _set_value("text_scale", scale); _settings_screen(), CONNECT_DEFERRED); sizes.add_child(b)
	for row in [["high_contrast", "HIGH CONTRAST"], ["reduced_motion", "REDUCED MOTION"], ["haptics", "HAPTICS"]]:
		var key: String = row[0]; var label: String = row[1]
		_button("%s: %s" % [label, "ON" if values[key] else "OFF"], func(): _set_value(key, not values[key]); _settings_screen(), "setting_" + key)
	_button("RESET TO DEFAULTS", func(): values = SettingsStore.DEFAULTS.duplicate(); _set_value("master", 1.0); _settings_screen(), "settings_reset")
	_button("BACK", _title_screen, "frontend_back")
func _set_value(key: String, v: Variant) -> void:
	values[key] = v
	values = SettingsStore.sanitize(values)
	FrontendSettings.apply(values, host)
	if save_timer.is_inside_tree(): save_timer.start()
	else: _persist()
func _persist() -> void:
	settings_store.save_settings(values)
func _credits_screen() -> void:
	_reset("credits")
	_text("CREDITS", 32, Color("80d9cf"))
	_text("SIREN'S SONG  /  AUDIO ATTRIBUTION", 14)
	for line in CreditsText.lines(Soundscape.ATTRIBUTION):
		_text(line.text, 20 if line.heading else 15, Color("80d9cf") if line.heading else Color(0, 0, 0, 0))
	_button("BACK", _title_screen, "frontend_back")
