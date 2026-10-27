extends SceneTree
# Night mode stays opt-in for existing settings and reaches the live Soundscape.
const SettingsStore = preload("res://src/persistence/settings_store.gd")
const FrontSettings = preload("res://src/presentation/frontend/frontend_settings.gd")
const Soundscape = preload("res://src/audio/soundscape.gd")
const RegionAudioTable = preload("res://src/audio/region_audio_table.gd")
class SettingsHost extends Control:
	var sound
	func _theme() -> void:
		theme = Theme.new()
var checks := 0
var failures := 0
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		printerr("FAIL ", label)
func effect_index(label: String) -> int:
	for index in AudioServer.get_bus_effect_count(0):
		if AudioServer.get_bus_effect(0, index).resource_name == label:
			return index
	return -1
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var previous := FrontSettings.current.duplicate(true)
	var previous_enabled: bool = RegionAudioTable.enabled
	RegionAudioTable.enabled = true
	check(not SettingsStore.sanitize({}).night_mode, "old settings default night mode off")
	check(not SettingsStore.sanitize({"night_mode": "true"}).night_mode, "string cannot enable night mode")
	check(not SettingsStore.sanitize({"night_mode": 1}).night_mode, "number cannot enable night mode")
	var store := SettingsStore.new()
	store.path = "user://regional-settings-tests.json"
	for suffix in ["", ".tmp"]:
		DirAccess.remove_absolute(store.path + suffix)
	check(not store.load_settings().night_mode, "missing settings default night mode off")
	var old_file := FileAccess.open(store.path, FileAccess.WRITE)
	old_file.store_string('{"version":1,"music":0.25}')
	old_file.close()
	check(not store.load_settings().night_mode, "old on-disk settings default night mode off")
	var host := SettingsHost.new()
	host.sound = Soundscape.new()
	root.add_child(host.sound)
	for enabled in [true, false]:
		var values := SettingsStore.DEFAULTS.duplicate()
		values.night_mode = enabled
		check(store.save_settings(values), "saves night mode %s" % enabled)
		var loaded := store.load_settings()
		check(loaded.night_mode == enabled, "disk roundtrip night mode %s" % enabled)
		FrontSettings.apply(loaded, host)
		check(FrontSettings.current.night_mode == enabled, "current reflects night mode %s" % enabled)
		check(host.sound.night_mode == enabled, "apply forwards night mode %s to Soundscape" % enabled)
		host.sound._sync_night_mode()
		var night_index := effect_index("SirenNightMode")
		if enabled:
			check(night_index >= 0 and AudioServer.get_bus_effect(0, night_index) is AudioEffectCompressor, "enabled night mode installs live master compressor")
			check(night_index >= 0 and effect_index("SirenPeakGuard") > night_index, "night compressor precedes live peak guard")
		else:
			check(night_index == -1, "disabled night mode removes live compressor")
	FrontSettings.apply({"night_mode": true}, host)
	host.sound._sync_night_mode()
	RegionAudioTable.enabled = false
	host.sound._sync_night_mode()
	check(effect_index("SirenNightMode") == -1, "disabled region table removes night compressor")
	FrontSettings.apply({"night_mode": "true"}, host)
	check(not host.sound.night_mode and not FrontSettings.current.night_mode, "apply sanitizes corrupt night mode")
	host.sound.free()
	host.free()
	RegionAudioTable.enabled = previous_enabled
	FrontSettings.apply(previous)
	for suffix in ["", ".tmp"]:
		DirAccess.remove_absolute(store.path + suffix)
	print("REGIONAL SETTINGS CHECKS ", checks, " FAILURES ", failures)
	quit(1 if failures else 0)
