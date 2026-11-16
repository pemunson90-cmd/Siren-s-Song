extends SceneTree
# Optional frame cap is validated, saved with device settings, and applied live.
const Store = preload("res://src/persistence/settings_store.gd")
const FrontendSettings = preload("res://src/presentation/frontend/frontend_settings.gd")
var checks := 0
var failures := 0
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures += 1; printerr("FAIL ", label)
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var path := "user://frame-cap-settings-test.json"
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(path + suffix)
	var original_fps := Engine.max_fps
	check(Store.sanitize({}).frame_cap == 60, "older settings default to a 60 FPS cap")
	check(Store.sanitize({"frame_cap": 30}).frame_cap == 30, "30 FPS is accepted")
	check(Store.sanitize({"frame_cap": 60}).frame_cap == 60, "60 FPS is accepted")
	for invalid in ["30", 0, 29, 120, true]:
		check(Store.sanitize({"frame_cap": invalid}).frame_cap == 60, "invalid cap falls back to 60: " + str(invalid))
	var store := Store.new(); store.path = path
	var values := Store.DEFAULTS.duplicate(true); values.frame_cap = 30
	check(store.save_settings(values), "30 FPS cap writes to device settings")
	check(store.load_settings().frame_cap == 30, "30 FPS cap round-trips from device settings")
	FrontendSettings.apply(store.load_settings())
	check(Engine.max_fps == 30, "saved cap applies to the engine")
	values.frame_cap = 60
	FrontendSettings.apply(values)
	check(Engine.max_fps == 60, "changing the cap updates the engine immediately")
	Engine.max_fps = original_fps
	for suffix in ["", ".bak", ".tmp"]: DirAccess.remove_absolute(path + suffix)
	print("FRAME CAP SETTINGS CHECKS ", checks, " FAILURES ", failures)
	quit(1 if failures else 0)
