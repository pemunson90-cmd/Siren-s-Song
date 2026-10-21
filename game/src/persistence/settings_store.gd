extends RefCounted
# Player settings, stored apart from campaign archives so a damaged or replaced
# campaign never resets accessibility or audio choices, and vice versa.
const VERSION := 1
const TEXT_SCALES := [1.0, 1.15, 1.3, 1.5]
const DEFAULTS := {"version": VERSION, "master": 1.0, "music": 0.5, "effects": 0.8, "text_scale": 1.0, "high_contrast": false, "reduced_motion": false, "haptics": true}
var path := "user://settings.json"
var warning := ""
static func sanitize(raw: Variant) -> Dictionary:
	var out := DEFAULTS.duplicate()
	if not raw is Dictionary: return out
	for key in ["master", "music", "effects"]:
		var v = raw.get(key, out[key])
		if (v is float or v is int) and is_finite(float(v)): out[key] = clampf(float(v), 0.0, 1.0)
	var scale = raw.get("text_scale", 1.0)
	if scale is float or scale is int:
		var best := 1.0
		for s in TEXT_SCALES:
			if absf(s - float(scale)) < absf(best - float(scale)): best = s
		out.text_scale = best
	for key in ["high_contrast", "reduced_motion", "haptics"]:
		if raw.get(key) is bool: out[key] = raw[key]
	return out
func load_settings() -> Dictionary:
	warning = ""
	if not FileAccess.file_exists(path): return DEFAULTS.duplicate()
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null or f.get_length() > 65536:
		warning = "Settings file could not be read. Defaults are in use."
		return DEFAULTS.duplicate()
	var json := JSON.new()
	var parsed = json.data if json.parse(f.get_as_text()) == OK else null
	if not parsed is Dictionary:
		warning = "Settings file was damaged. Defaults are in use; your campaign is unaffected."
		return DEFAULTS.duplicate()
	return sanitize(parsed)
func save_settings(values: Dictionary) -> bool:
	var clean := sanitize(values)
	var f := FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if f == null:
		warning = "Settings could not be saved. Check device storage."
		return false
	f.store_string(JSON.stringify(clean)); f.flush(); f.close()
	if FileAccess.file_exists(path): DirAccess.remove_absolute(path)
	if DirAccess.rename_absolute(path + ".tmp", path) != OK:
		warning = "Settings could not be committed."
		return false
	warning = ""
	return true
