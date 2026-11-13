extends RefCounted
# [AI-DESIGNED] A8 step 3 (code audit, Pat approved 2026-11-12): campaign save
# handling. It used to live inside main.gd.
#
# What it does, unchanged: builds the save dictionary from the host's state,
# writes it (with one deferred retry when the first write fails), shows or
# hides the "progress not saved" / archive notice panel, and loads a saved game
# back into the host at startup. Each function takes the host (main.gd or a
# session subclass) and reaches state through host fields. Calls to other save
# methods go through the host so a session's override still runs. main.gd keeps
# thin methods with the same names that forward here.
const SaveStore=preload("res://src/persistence/save_store.gd")
const ReleaseControls=preload("res://src/presentation/release_controls.gd")
const DevState=preload("res://src/debug/dev_state.gd")
const FleetInventory=preload("res://src/campaign/fleet_inventory.gd")
const Economy=preload("res://src/campaign/economy.gd")
static func archive(host) -> Dictionary:
	var data={"version":SaveStore.VERSION,"unlocked":host.unlocked,"completed":host.completed.duplicate(),"upgrade":host.upgrade,"settings":host.settings.duplicate(),"evidence":host.recovered_evidence.duplicate(true),"active":host.sim.snapshot(),"chart_view":host.ocean.chart_camera.snapshot()}
	if not host.photo_records.is_empty():data["photo_records"]=host.photo_records.duplicate(true)
	if not host.photo_intel.is_empty():data["intel"]=host.photo_intel.duplicate(true)
	if not host.expedition.is_empty():data["expedition"]=host.expedition.duplicate(true)
	if not host.fleet.is_empty():data["fleet"]=host.fleet.duplicate(true)
	data["economy"]=host.economy.duplicate(true)
	if not host.hints_seen.is_empty():data["hints_seen"]=host.hints_seen.duplicate()
	if not host.early_reward.is_empty():data["early_reward"]=host.early_reward.duplicate(true)
	preload("res://src/presentation/first_siren_cue/cue_archive.gd").write(host,data)
	data["tactical_pause_history"]=host.tactical_aids.saved_history()
	preload("res://src/presentation/arcs/arc_card.gd").write(host,data)
	preload("res://src/presentation/finale/finale.gd").write(host,data)
	preload("res://src/presentation/archive/voice_feed.gd").write(host,data)
	preload("res://src/persistence/save_states/save2_controller.gd").write(host,data)
	DevState.write(host,data)
	preload("res://src/equipment/tool_racks.gd").write_archive(data,host.tool_racks)
	data["equipment"]=preload("res://src/equipment/equipment_catalog.gd").canonical(host.fitted_equipment)
	return data
static func save_archive(host) -> void:
	host._write_archive(false)
static func retry_archive(host)->void:
	if not host.save_retry_pending:return
	host.save_retry_pending=false
	host._write_archive(true)
static func write_archive(host,retry:bool)->void:
	if not host.capture_scenario.is_empty() or host.sim.mission==null:return
	host._sync_craft_upgrades()
	if host.store.save(host._archive()):
		host.save_retry_pending=false;host.save_error=""
		ReleaseControls.debug_print(["SS_SAVE ok mission=",host.mission_index," time=",snappedf(host.sim.elapsed,0.01)," paused=",host.sim.paused," completed=",host.completed," unlocked=",host.unlocked])
	elif retry:
		host.save_error=host.store.warning;host.sim.message=host.save_error
		ReleaseControls.debug_print(["SS_SAVE retry_failed reason=",host.store.warning," active.captures=",host.sim.captures])
	else:
		ReleaseControls.debug_print(["SS_SAVE retry_pending reason=",host.store.warning," active.captures=",host.sim.captures])
		if not host.save_retry_pending:
			host.save_retry_pending=true;host.call_deferred("_retry_archive")
	host._update_archive_status()
static func dismiss_archive_warning(host)->void:
	host.archive_warning="";host._update_archive_status()
static func update_archive_status(host)->void:
	if host.archive_status==null:return
	var lines=[]
	if not host.save_error.is_empty():lines.append("PROGRESS NOT SAVED\n"+host.save_error+"\nCurrent progress is held in this session only.")
	if not host.archive_warning.is_empty():lines.append("ARCHIVE NOTICE\n"+host.archive_warning)
	var text="\n\n".join(lines);var changed=host.archive_status_text.text!=text
	host.archive_status_text.text=text;host.archive_status.visible=not text.is_empty()
	host.save_retry_button.visible=not host.save_error.is_empty();host.archive_dismiss_button.visible=not host.archive_warning.is_empty()
	if changed:host.call_deferred("_layout")
static func load_archive(host) -> void:
	var saved=host.store.load_game()
	DevState.restore(host,saved)
	preload("res://src/presentation/arcs/arc_card.gd").restore(host,saved)
	preload("res://src/presentation/finale/finale.gd").restore(host,saved)
	if not saved.is_empty():
		host.unlocked=saved.unlocked; host.completed=saved.completed; host.upgrade=saved.upgrade; host.settings=saved.settings
		host.early_reward=saved.get("early_reward",{}).duplicate(true)
		host.expedition=saved.get("expedition",{}).duplicate(true)
		host.fleet=saved.get("fleet",{}).duplicate(true)
		host.photo_intel=saved.get("intel",{}).duplicate(true)
		host.fitted_equipment=preload("res://src/equipment/equipment_catalog.gd").canonical(saved.get("equipment",{}))
		host.fitted_equipment=FleetInventory.reconcile_fitting(host.fitted_equipment,FleetInventory.available(host._equipment_entitlements(),host.fleet))
		host.tool_racks=preload("res://src/equipment/tool_racks.gd").migrated(saved)
		host.economy=Economy.Losses.migrated(saved.economy) if saved.has("economy") else Economy.legacy_state(host.fitted_equipment)
		host.fitted_equipment=Economy.Losses.fitting(host.economy,FleetInventory.reconcile_fitting(host.fitted_equipment,FleetInventory.available(host._equipment_entitlements(),host.fleet,host.economy)))
		host.recovered_evidence=saved.get("evidence",{})
		host.photo_records=saved.get("photo_records",{}).duplicate(true)
		preload("res://src/presentation/archive/voice_feed.gd").restore(host,saved)
		host.hints_seen=saved.get("hints_seen",[]).duplicate()
		preload("res://src/presentation/first_siren_cue/cue_archive.gd").restore_types(host,saved)
		if saved.get("active") is Dictionary and host.sim.restore(saved.active):
			host.tactical_aids.restore_history(saved.get("tactical_pause_history"))
			preload("res://src/presentation/first_siren_cue/cue_archive.gd").restore(host,saved)
			host.active_started=true; host.mission_index=host.sim.mission.id; host.ocean.sim=host.sim
			host.ocean._sync_camera()
			var chart_view=saved.get("chart_view",{})
			if chart_view is Dictionary:host.ocean.chart_camera.restore(chart_view)
			ReleaseControls.debug_print(["SS_RESTORE ok mission=",host.mission_index," time=",snappedf(host.sim.elapsed,0.01)," paused=",host.sim.paused," completed=",host.completed," unlocked=",host.unlocked])
	preload("res://src/persistence/save_states/save2_controller.gd").restore(host,saved)
	host.sound.music_volume=host.settings.get("music",0.5); host.sound.effects_volume=host.settings.get("effects",0.8); host.sound.muted=host.settings.get("mute",false)
	if not host.store.warning.is_empty():host.archive_warning=host.store.warning;host.sim.message=host.store.warning
	host._update_archive_status()
