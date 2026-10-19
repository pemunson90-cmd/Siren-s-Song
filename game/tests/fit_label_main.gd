extends "res://tests/density_main.gd"
var fixture_dpi:=95.0
func ui_density_dpi() -> float: return fixture_dpi
func ui_density_source() -> String: return "fit_label_desktop_or_recorded_android_fixture"
# Keep focused output readable; production diagnostics are unchanged.
func _report_targets() -> void: pass
