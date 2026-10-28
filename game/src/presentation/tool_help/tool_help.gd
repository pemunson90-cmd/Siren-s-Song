extends Node
# Read-only touch explanations. Revert: remove ToolHelp seams in mission_hud.gd.
const HOLD_SECONDS = .5 # Default; SETDEPTH presets apply it when the hold arms.
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const Depth=preload("res://src/presentation/frontend/settings_depth.gd")
const TEXT = {
 "decoy":"DECOY: place a noise source to draw Sirens away.",
 "emp":"DISRUPT: briefly interrupt nearby Sirens.",
 "recon":"SURVEY: inspect the local area with this craft.",
 "sonar_emit":"EMIT: spend reserve on an audible sonar pulse.",
 "sonar_sector":"SECTOR: choose all-around or forward sonar coverage.",
 "sonar_power":"POWER: choose low or high sonar pulse power.",
 "sonar_history":"HISTORY: read the sonar signals this craft has received.",
 "sonobuoy":"SONOBUOY: drop a passive listener here for 90 s. Its bearings give direction, never range.",
 "silt_screen":"SILT SCREEN: an audible release blocks sight through this band for 25 s, for your craft and Sirens.",
 "hull_patch":"HULL PATCH: audible work repairs up to 30% collision hull damage on live Quietus. It cannot repair other damage.",
 "relay_buoy":"RELAY BUOY: an audible chirp extends drone passive reach by 35% within 420m for three minutes. Quietus is unchanged."
}
var hud
var timer:Timer
var key=""
func setup(owner):
 hud=owner
 timer=Timer.new();timer.one_shot=true;timer.wait_time=HOLD_SECONDS;add_child(timer)
 timer.timeout.connect(_show)
func cancel():
 key=""
 if timer!=null:timer.stop()
func arm(_hud,button):
 cancel()
 if button==null or not TEXT.has(button.get_meta("action","")):return
 key=button.get_meta("action");timer.start(Depth.hold_seconds(Settings.current))
func _show():
 if not is_instance_valid(hud) or not hud.host.advanced_orders or not TEXT.has(key):return
 hud.help_return=hud.page
 hud.help_text=TEXT[key]
 hud.help_consumed=true
 hud.open("order_help")
