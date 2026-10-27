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
const ReachTable=preload("res://src/presentation/frontend/menu_reach_table.gd")
enum Profile { NONE, OK, RECOVERED, UNREADABLE }
var profile_picker = preload("res://src/persistence/profiles/profile_picker.gd").new()
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
# MENU REACH contexts share this settings builder and its single values store.
# Embedded settings keep Operations' sticky Back and archive warning region.
var embedded_settings=false
var operations_entry=""
var settings_dirty=false
func setup_settings(main:Control)->void:
	host=main;embedded_settings=true;name="Frontend"
	settings_store.path=host.settings_path;values=FrontendSettings.current.duplicate(true)
	settings_store.load_settings() # Read warning provenance without replacing live choices.
	FrontendSettings.apply(values,host)
	profile=Profile.NONE if host._campaign_pristine() else Profile.OK
	column=host.panel_box;scroll=host.scroll
	save_timer=Timer.new();save_timer.one_shot=true;save_timer.wait_time=ReachTable.SAVE_DEBOUNCE;add_child(save_timer);save_timer.timeout.connect(_persist)
	_settings_screen()
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
func setup(main: Control, use_live_values:=false) -> bool:
	host = main
	profile_picker.setup(self)
	var saved=settings_store.load_settings()
	values = FrontendSettings.current.duplicate(true) if use_live_values else saved
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
	save_timer = Timer.new(); save_timer.one_shot = true; save_timer.wait_time = ReachTable.SAVE_DEBOUNCE; add_child(save_timer); save_timer.timeout.connect(_persist)
	resized.connect(_fit_column)
	_title_screen()
	return column != null
func _process(delta: float) -> void:
	# Any host navigation away from the boot menu (mission, briefing, ending) supersedes the overlay.
	if host != null and host.get("screen") != ("settings" if embedded_settings else "menu"): _dismiss(); return
	if title_label == null or not is_instance_valid(title_label) or screen != "title": return
	if FrontendSettings.reduced_motion(): drift = 0.0; title_label.modulate.a = 1.0; return
	drift += delta
	title_label.modulate.a = 0.82 + 0.18 * sin(drift * 1.1)
func touch_height() -> float:
	var h = host.get("ui_touch_height") if host != null else 48.0
	return maxf(48.0, float(h))
func _fit_column() -> void:
	if embedded_settings:return
	if column == null: return
	column.custom_minimum_size.x = clampf(size.x - 64.0, 240.0, 620.0)
func _reset(next: String) -> void:
	screen = next; title_label = null
	if embedded_settings:
		host._clear_menu();host.screen="settings"
	for child in column.get_children(): column.remove_child(child); child.queue_free()
	_fit_column()
	scroll.scroll_vertical = 0
func _text(text: String, size_px: int = 17, color: Color = Color(0, 0, 0, 0)) -> Label:
	if embedded_settings:
		var label=host._menu_text(text,size_px)
		if color.a>0:label.add_theme_color_override("font_color",color)
		return label
	var l := Label.new(); l.text = text; l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", roundi(size_px * FrontendSettings.text_scale()))
	if color.a > 0: l.add_theme_color_override("font_color", color)
	column.add_child(l); return l
func _button(text: String, action: Callable, id: String, disabled := false) -> Button:
	if embedded_settings:
		var logical={"frontend_back":"back","frontend_new_campaign":"new_campaign"}.get(id,id)
		var target=host.menu_footer if id=="frontend_back" else column
		var control=host._button(target,text,action,logical);control.disabled=disabled
		if target==host.menu_footer:target.show()
		return control
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
	if profile_picker.available():_button("PROFILES", profile_picker.show_picker, "frontend_profiles")
	_button("SETTINGS", _settings_screen, "frontend_settings")
	_button("CHALLENGES", func():load("res://src/presentation/frontend/challenges_frontend.gd").show(self), "frontend_challenges", profile==Profile.UNREADABLE)
	_button("CREDITS", _credits_screen, "frontend_credits")
func _dismiss() -> void:
	_flush_pending()
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
	_button("BACK TO OPERATIONS" if embedded_settings else "BACK", _return, "frontend_back")
	_text("SETTINGS", 32, Color("80d9cf"))
	_text("Saved on this device, separate from your campaign.", 14)
	if not settings_store.warning.is_empty(): _text(settings_store.warning, 15, Color("efc28d"))
	for row in [["master", "MASTER VOLUME"], ["music", "MUSIC VOLUME"], ["effects", "EFFECTS VOLUME"]]:
		var key: String = row[0]
		var caption := _text("%s  %d%%" % [row[1], roundi(values[key] * 100)], 17)
		var slider := HSlider.new(); slider.min_value = 0; slider.max_value = 1; slider.step = 0.05; slider.value = values[key]
		slider.custom_minimum_size.y = touch_height(); slider.set_meta("ui_action", ("volume_" if embedded_settings else "setting_") + key); column.add_child(slider)
		slider.value_changed.connect(func(v: float): _set_value(key, v); caption.text = "%s  %d%%" % [row[1], roundi(v * 100)])
	_text("TEXT SIZE", 17)
	var sizes := HBoxContainer.new(); sizes.add_theme_constant_override("separation", 8); column.add_child(sizes)
	for s in SettingsStore.TEXT_SCALES:
		var scale: float = s
		var b := Button.new(); b.text = "%d%%" % roundi(scale * 100); b.custom_minimum_size = Vector2(0, touch_height()); b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.focus_mode = Control.FOCUS_NONE; b.set_meta("ui_action", "text_scale_%d" % roundi(scale * 100)); b.toggle_mode = true; b.button_pressed = is_equal_approx(values.text_scale, scale)
		b.pressed.connect(func(): _set_value("text_scale", scale); _settings_screen(), CONNECT_DEFERRED); sizes.add_child(b)
	var audio_modes := HBoxContainer.new(); audio_modes.add_theme_constant_override("separation", 8); column.add_child(audio_modes)
	var mute_button := _button("MUTE: %s" % ("ON" if values.master<=0 else "OFF"),_toggle_mute,"mute")
	var night_button := _button("NIGHT MODE: %s" % ("ON" if values.night_mode else "OFF"), func(): _set_value("night_mode", not values.night_mode); _settings_screen(), "setting_night_mode")
	for button in [mute_button, night_button]:
		button.reparent(audio_modes); button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for row in [["high_contrast", "HIGH CONTRAST"], ["reduced_motion", "REDUCED MOTION"], ["haptics", "HAPTICS"], ["safe_palette", "SAFE PALETTE"], ["audio_captions", "AUDIO CAPTIONS"]]:
		var key: String = row[0]; var label: String = row[1]
		_button("%s: %s" % [label, "ON" if values[key] else "OFF"], func(): _set_value(key, not values[key]); _settings_screen(), "setting_" + key)
	if host.has_method("_save_archive"):
		_button("SHOW FIRST-DIVE TIPS AGAIN",func():host.hints_seen=[];host._save_archive();_settings_screen(),"reset_tips")
	_button("RESET TO DEFAULTS", func(): values = SettingsStore.DEFAULTS.duplicate(); _set_value("master", 1.0); _settings_screen(), "settings_reset")
	if profile != Profile.NONE:
		_button("ERASE PROGRESS · NEW CAMPAIGN", _new_campaign, "frontend_new_campaign")
	if embedded_settings:host.call_deferred("_layout")
func _toggle_mute()->void:
	var remembered=float(host.get_meta(ReachTable.UNMUTE_META,SettingsStore.DEFAULTS.master))
	_set_value("master",0. if values.master>0 else remembered)
	_settings_screen()
func _return()->void:
	if embedded_settings or (not operations_entry.is_empty() and screen==operations_entry):
		_dismiss();host._show_campaign()
	else:_title_screen()
func _set_value(key: String, v: Variant) -> void:
	var previous_master=float(values.master)
	values[key] = v
	values = SettingsStore.sanitize(values)
	settings_dirty=true
	# Keep the last audible level across renderer recreation in this session.
	# No settings/save key: master remains the only persisted volume source.
	if key=="master":
		var remembered=float(values.master) if values.master>0 else previous_master
		if remembered>0:host.set_meta(ReachTable.UNMUTE_META,remembered)
	FrontendSettings.apply(values, host)
	if save_timer.is_inside_tree(): save_timer.start()
	else: _persist()
func _persist() -> void:
	settings_dirty=not settings_store.save_settings(values)
func _flush_pending()->void:
	if not settings_dirty:return
	if is_instance_valid(save_timer):save_timer.stop()
	_persist()
func _exit_tree()->void:
	# Timers stop as their parent exits; keep the last visible choice on disk.
	_flush_pending()
func _notification(what:int)->void:
	if what in [NOTIFICATION_APPLICATION_PAUSED,NOTIFICATION_APPLICATION_FOCUS_OUT,NOTIFICATION_WM_WINDOW_FOCUS_OUT]:_flush_pending()
func _credits_screen() -> void:
	_reset("credits")
	_button("BACK", _return, "frontend_back")
	_text("CREDITS", 32, Color("80d9cf"))
	_text("SIREN'S SONG  /  AUDIO ATTRIBUTION", 14)
	for line in CreditsText.lines(Soundscape.ATTRIBUTION):
		_text(line.text, 20 if line.heading else 15, Color("80d9cf") if line.heading else Color(0, 0, 0, 0))
# Main routes Android Back and Escape here before changing the campaign underneath.
func back() -> void:
	if screen.begins_with("profile"):profile_picker.back();return
	if screen == "challenge_details":
		load("res://src/presentation/frontend/challenges_frontend.gd").show(self)
	elif screen != "title" or not operations_entry.is_empty():
		_return()
