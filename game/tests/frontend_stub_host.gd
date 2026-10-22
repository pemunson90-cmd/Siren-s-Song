extends Control
# Minimal stand-in for main.gd exposing the members the frontend touches.
const SaveStore = preload("res://src/persistence/save_store.gd")
const Soundscape = preload("res://src/audio/soundscape.gd")
var store = SaveStore.new()
var sound = Soundscape.new()
var settings = {"music": 0.5, "effects": 0.8, "mute": false}
var ui_touch_height := 48.0
var confirmed := false
func _theme() -> void:
	var t = Theme.new(); t.default_font_size = 17
	var b = StyleBoxFlat.new()
	for s in ["normal", "hover", "pressed", "focus"]: t.set_stylebox(s, "Button", b)
	t.set_stylebox("panel", "PanelContainer", b)
	t.set_color("font_color", "Label", Color("c3d5d6"))
	theme = t
func _layout() -> void: pass
func _show_campaign() -> void: pass
func _confirm_new_campaign() -> void: confirmed = true
