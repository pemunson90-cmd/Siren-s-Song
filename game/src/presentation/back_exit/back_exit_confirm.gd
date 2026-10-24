extends Node
# BACK1 (handoff 041): double-Back to exit from the top Operations screen only.
# FLAG: set TABLE.enabled=false to make Back on Operations inert (never quits);
#   REVERT: remove the one seam line in main.gd _android_back and delete this
#   folder and its test; project.godot quit_on_go_back=false then still stops
#   an accidental single-Back quit.
# Narrow seam: main.gd _android_back calls handle(host) once, after the frontend
# overlay and before the existing one-level-back rules. Every other screen,
# and the in-dive Escape behavior, never reach this module.
const TABLE := {
	"enabled": true,
	"screens": ["menu"],  # only the top-level Operations screen
	"window_ms": 2500,  # second Back inside this window quits
	"toast_text": "Press Back again to exit",
	"toast_ms": 2500,
	"toast_bottom_margin": 120.0,
	"toast_font_size": 20,
}
var quit_hook: Callable = _quit_app  # tests replace this; never quits the test run
var clock: Callable = Time.get_ticks_msec  # tests replace this for the window
var armed := false
var last_press_ms := 0
var quit_requests := 0  # observable count of confirmed exits
var toast: Label
var toast_timer: Timer

func _quit_app() -> void:
	get_tree().quit()

# Returns true when Back was consumed here (toast shown or exit confirmed).
func handle(host) -> bool:
	if not TABLE.enabled: return false
	if not host.screen in TABLE.screens:
		if armed: _expire()  # leaving Operations disarms, so a later Back cannot quit by surprise
		return false
	var now: int = clock.call()
	if armed and now - last_press_ms <= TABLE.window_ms:
		armed = false
		_hide_toast()
		quit_requests += 1
		quit_hook.call()
		return true
	armed = true
	last_press_ms = now
	_show_toast(host)
	return true

func _show_toast(host) -> void:
	if toast == null:
		toast = Label.new()
		toast.name = "BackExitToast"
		toast.text = TABLE.toast_text
		toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
		toast.z_index = 200
		toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		toast.add_theme_font_size_override("font_size", TABLE.toast_font_size)
		toast.add_theme_color_override("font_color", Color("e8f6f4"))
		var box := StyleBoxFlat.new()
		box.bg_color = Color(0.02, 0.09, 0.12, 0.92)
		box.set_corner_radius_all(8)
		box.content_margin_left = 18; box.content_margin_right = 18
		box.content_margin_top = 10; box.content_margin_bottom = 10
		toast.add_theme_stylebox_override("normal", box)
		toast.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM, Control.PRESET_MODE_MINSIZE)
		toast.offset_top -= TABLE.toast_bottom_margin; toast.offset_bottom -= TABLE.toast_bottom_margin
		host.add_child(toast)
		toast_timer = Timer.new(); toast_timer.one_shot = true
		toast_timer.timeout.connect(_expire); add_child(toast_timer)
	toast.show()
	toast_timer.start(TABLE.toast_ms / 1000.0)

func _expire() -> void:
	armed = false
	_hide_toast()

func _hide_toast() -> void:
	if toast != null: toast.hide()
