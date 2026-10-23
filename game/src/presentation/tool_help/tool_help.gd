extends RefCounted
# Read-only touch explanations. Revert: remove ToolHelp seams in mission_hud.gd.
const HOLD_SECONDS = .5
const TEXT = {
 "decoy":"DECOY: place a noise source to draw Sirens away.",
 "emp":"DISRUPT: briefly interrupt nearby Sirens.",
 "recon":"SURVEY: inspect the local area with this craft.",
 "sonar_emit":"EMIT: spend reserve on an audible sonar pulse.",
 "sonar_sector":"SECTOR: choose all-around or forward sonar coverage.",
 "sonar_power":"POWER: choose low or high sonar pulse power.",
 "sonar_history":"HISTORY: read the sonar signals this craft has received."
}
var generation=0
func cancel():generation+=1
func arm(hud,button):
 cancel()
 if button==null or not TEXT.has(button.get_meta("action","")):return
 var ticket=generation
 await hud.get_tree().create_timer(HOLD_SECONDS).timeout
 if not is_instance_valid(hud) or ticket!=generation or not hud.host.advanced_orders:return
 hud.help_return=hud.page
 hud.help_text=TEXT[button.get_meta("action")]
 hud.help_consumed=true
 hud.open("order_help")
