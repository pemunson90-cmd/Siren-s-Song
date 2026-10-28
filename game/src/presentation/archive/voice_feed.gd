extends RefCounted
# Shows recurring-voice lines through existing screens and the HUD log row, and keeps the
# received log in the archive. Presentation only; no simulation or rule writes.
# Seams (one line each): CampaignFlow.briefing and classic debrief, ExpeditionOperations.debrief,
# Main._refresh log row, Main._archive / _load_archive, CampaignFlow.new_campaign.
# Revert: voices_table.enabled=false (nothing shows, nothing saved), or remove those lines.
const Voices=preload("res://src/campaign/voices/voices.gd")
const Table=preload("res://src/campaign/voices/voices_table.gd")
const META="voice_log"
static func received(host)->Array:
	if not host.has_meta(META):host.set_meta(META,[])
	return host.get_meta(META)
# Briefing radio under the briefing text.
static func briefing(host,op:int)->void:
	if Voices.row(op,"brief").is_empty():return
	Voices.hear(received(host),op,"brief")
	host._menu_text(Voices.line(op,"brief"),16)
# Debrief line after a recovered operation.
static func debrief(host)->void:
	var mission=host.sim.mission
	if mission==null or host.sim.outcome!="won" or Voices.row(int(mission.id),"debrief").is_empty():return
	if mission.has("expedition_revision") and not mission.get("recovered",false):return
	Voices.hear(received(host),int(mission.id),"debrief")
	host._menu_text(Voices.line(int(mission.id),"debrief"),17)
# HUD log row text. A mid-dive message fires once on the player's own progress and stays for HOLD seconds.
static func log_text(host,message:String)->String:
	if not Table.enabled or host.screen!="mission" or host.sim.mission==null or not host.sim.outcome.is_empty():return message
	var op=int(host.sim.mission.get("id",-1))
	var dive=host.sim.get_instance_id()
	var state:Dictionary=host.get_meta("voice_mid",{})
	if state.get("dive",-1)!=dive:
		state={"dive":dive,"at":-1.0}
		host.set_meta("voice_mid",state)
	var log=received(host)
	if state.at<0.0 and not Voices.heard(log,op,"mid") and Voices.progress(host.sim.mission) and Voices.hear(log,op,"mid"):
		state.at=host.sim.elapsed
	if state.at>=0.0 and host.sim.elapsed-state.at<=Table.HOLD and host.sim.elapsed>=state.at:
		return "%s | %s"%[Voices.line(op,"mid"),message]
	return message
# ---- archive ---------------------------------------------------------------
static func write(host,data:Dictionary)->void:
	if Table.enabled and not received(host).is_empty():data[Voices.FIELD]=received(host).duplicate()
static func restore(host,saved:Dictionary)->void:
	var value=saved.get(Voices.FIELD,[])
	host.set_meta(META,value.duplicate() if Voices.valid(value) else [])
	if host.has_meta("voice_mid"):host.remove_meta("voice_mid")
static func clear(host)->void:
	host.set_meta(META,[])
