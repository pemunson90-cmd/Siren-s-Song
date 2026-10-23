extends RefCounted
const SettingsStore = preload("res://src/persistence/settings_store.gd")
const FrontendSettings = preload("res://src/presentation/frontend/frontend_settings.gd")
const Frontend = preload("res://src/presentation/frontend/frontend.gd")
const CreditsText = preload("res://src/presentation/frontend/credits_text.gd")
const SaveStore = preload("res://src/persistence/save_store.gd")
const Soundscape = preload("res://src/audio/soundscape.gd")
const StubHost = preload("res://tests/frontend_stub_host.gd")
static func run(t: SceneTree) -> void:
	var dir := "user://frontend_test"
	DirAccess.make_dir_recursive_absolute(dir)
	# Settings: defaults, sanitizing, round trip, damage handling.
	var store := SettingsStore.new(); store.path = dir + "/settings.json"
	DirAccess.remove_absolute(store.path)
	t.check(store.load_settings() == SettingsStore.DEFAULTS, "missing settings file yields defaults")
	var clean := SettingsStore.sanitize({"master": 7, "music": -1, "effects": "x", "text_scale": 1.2, "haptics": 3, "high_contrast": true})
	t.check(clean.master == 1.0 and clean.music == 0.0 and clean.effects == 0.8, "volumes clamp or fall back")
	t.check(clean.text_scale == 1.15 and clean.haptics == true and clean.high_contrast == true, "text scale snaps and flags require booleans")
	t.check(store.save_settings({"master": 0.4, "music": 0.2, "effects": 0.6, "text_scale": 1.5, "high_contrast": true, "reduced_motion": true, "haptics": false}), "settings save")
	var back := store.load_settings()
	t.check(back.master == 0.4 and back.text_scale == 1.5 and back.reduced_motion and not back.haptics, "settings persist across load")
	var f := FileAccess.open(store.path, FileAccess.WRITE); f.store_string("{not json"); f.close()
	var damaged := store.load_settings()
	t.check(damaged == SettingsStore.DEFAULTS and not store.warning.is_empty(), "damaged settings fall back with a message")
	# Live application.
	var host = StubHost.new()
	t.root.add_child(host)
	FrontendSettings.apply({"master": 0.5, "music": 0.3, "effects": 0.7, "text_scale": 1.3, "high_contrast": true, "reduced_motion": true, "haptics": false}, host)
	t.check(is_equal_approx(AudioServer.get_bus_volume_db(0), linear_to_db(0.5)), "master bus volume applies live")
	t.check(host.sound.music_volume == 0.3 and host.sound.effects_volume == 0.7, "music and effects volumes reach the soundscape")
	t.check(host.theme.default_font_size == roundi(17 * 1.3), "text scale resizes theme fonts")
	t.check(host.theme.get_color("font_color", "Label") == Color("ffffff"), "high contrast brightens text")
	t.check(FrontendSettings.reduced_motion() and not FrontendSettings.vibrate(10), "reduced motion readable, haptics toggle blocks vibration")
	FrontendSettings.apply(SettingsStore.DEFAULTS, host)
	t.check(host.theme.default_font_size == 17 and FrontendSettings.vibrate(0), "defaults restore theme and haptics")
	AudioServer.set_bus_volume_db(0, 0.0); AudioServer.set_bus_mute(0, false)
	# Campaign profile classification and recovery.
	var save_path := dir + "/quietus.save"
	for suffix in ["", ".bak"]: DirAccess.remove_absolute(save_path + suffix)
	t.check(Frontend.inspect_profile(save_path).state == Frontend.Profile.NONE, "no archive is reported as none")
	var archive := SaveStore.new(); archive.path = save_path
	var ok := archive.save({"version": 1, "unlocked": 0, "completed": [], "settings": {}, "upgrade": "endurance"})
	t.check(ok and Frontend.inspect_profile(save_path).state == Frontend.Profile.OK, "valid archive is reported ok")
	var g := FileAccess.open(save_path, FileAccess.WRITE); g.store_string("garbage that is not an archive at all, padded out"); g.close()
	var info := Frontend.inspect_profile(save_path)
	t.check(info.state == Frontend.Profile.UNREADABLE and info.message.contains("untouched"), "incompatible archive gets a truthful message")
	var kept := Frontend.preserve_unreadable(save_path, 42)
	t.check(kept.size() == 1 and FileAccess.file_exists(save_path) and FileAccess.file_exists(kept[0]), "unreadable archive is copied aside and original retained")
	# Frontend screens.
	host.store.path = save_path
	var front = Frontend.new(); host.add_child(front)
	t.check(front.setup(host), "frontend sets up")
	var actions := _actions(front)
	t.check(actions.has("frontend_continue") and not actions.has("frontend_new_campaign") and actions.has("frontend_settings") and actions.has("frontend_credits"), "title offers continue, settings and credits while reset lives in Settings")
	t.check(front.find_child("ProfileNotice", true, false) != null and front.find_children("*", "Button", true, false)[0].disabled, "incompatible save shows notice and disables continue")
	front._credits_screen()
	var text := ""
	for child in front.column.get_children():
		if child is Label: text += child.text + "\n"
	t.check(text.contains("Creative Commons Attribution 3.0") and text.contains("Michael Brigida"), "credits render the CC-BY attribution")
	t.check(CreditsText.lines(Soundscape.ATTRIBUTION).size() > 8 and not text.contains("**"), "credits strip markdown markers only")
	front._settings_screen()
	for child in front.find_children("*", "Control", true, false):
		if child is Button or child is HSlider: t.check(child.custom_minimum_size.y >= 48.0, "settings control keeps full touch height")
	front.settings_store.path = dir + "/front_settings.json"
	front._set_value("high_contrast", true)
	front._persist()
	var persisted := SettingsStore.new(); persisted.path = front.settings_store.path
	t.check(FrontendSettings.current.high_contrast and persisted.load_settings().high_contrast, "settings screen changes apply live and persist")
	front._continue()
	t.check(front.get_parent() == null, "continue dismisses the overlay")
	front.free(); host.sound.free(); host.theme = null; host.free()
	FrontendSettings.apply(SettingsStore.DEFAULTS)
	for suffix in ["", ".bak", ".incompatible-42"]: DirAccess.remove_absolute(save_path + suffix)
static func _actions(node: Node) -> Array:
	var out := []
	for child in node.find_children("*", "Button", true, false):
		if child.has_meta("action"): out.append(child.get_meta("action"))
	return out
