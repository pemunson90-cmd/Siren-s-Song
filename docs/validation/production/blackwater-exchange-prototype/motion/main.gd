extends "res://src/main.gd"
const Prototype=preload("res://proto/simulation.gd")
var exchange_mode="cycle"
var recording=false
func _ready():
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--exchange-mode="):exchange_mode=arg.trim_prefix("--exchange-mode=")
		if arg=="--exchange-recording":recording=true
	if exchange_mode not in ["baseline","cycle","direct"]:exchange_mode="cycle"
	capture_scenario="blackwater-prototype"
	super._ready()
	var feed=ocean.optical_feed
	feed.set_script(preload("res://proto/receiver_feed.gd"))
	feed.sim=sim
	store.path="user://blackwater-prototype-"+exchange_mode+".save"
	if not recording:
		capture_scenario="";_load_archive();sim.paused=true;_show_campaign()
func _scenario(_name:String):_start_mission(2)
func _start_mission(_index:int):
	sim=Prototype.new();sim.set_variant(exchange_mode)
	super._start_mission(2)
func _refresh():
	super._refresh()
	title_label.text="BLACKWATER / "+exchange_mode.to_upper()+" / ISOLATED PROTOTYPE"
	if exchange_mode!="baseline":
		order_buttons.camera.text="SAMPLE"
		for i in 3:
			if sim.capture_unit==i:unit_buttons[i].text=sim.units[i].name.to_upper()+"\nRECEIVING"
func _show_campaign():
	screen="menu";sim.paused=true;_clear_menu()
	_menu_text("BLACKWATER / EXPERIMENT",30)
	_menu_text("Comparison only. Unchanged threats, movement and equipment. Not a shipped campaign.",17)
	if active_started and sim.outcome.is_empty():_button(panel_box,"RESUME "+exchange_mode.to_upper(),_enter_water)
	_menu_text("BASELINE: two four-second noisy optical records. CYCLE: two settled hydrophone seconds within local carrier windows. DIRECT: continuous carrier; same two-second sample, no mandatory window wait.",17)
	_menu_text("Quiet reach: Quietus156m / drone214.5m, clear cover. SONAR can solicit a three-second replay within240m and clear cover. It keeps its existing noise and cooldown. Return Quietus after both records.",17)
	if exchange_mode!="baseline":
		for id in 2:
			if sim.mission.objectives[id].captured:_menu_text(sim.mission.objectives[id].name+" / "+sim.mission.objectives[id].evidence,17)
	for mode in ["baseline","cycle","direct"]:
		var chosen=mode
		_button(panel_box,"RESTART "+mode.to_upper(),func():exchange_mode=chosen;store.path="user://blackwater-prototype-"+chosen+".save";_start_mission(2);_enter_water())
	_button(panel_box,"AUDIO / SETTINGS",_settings_menu)
	call_deferred("_layout")
func _debrief():
	sim.paused=true;screen="debrief";_clear_menu()
	_menu_text("PROTOTYPE / "+sim.outcome.to_upper(),30)
	_menu_text("Hull %.0f%% · records %d/2 · active time %.1fs"%[sim.hull,sim.mission.objectives.filter(func(o):return o.captured).size(),sim.elapsed],18)
	_button(panel_box,"COMPARISON MENU",_show_campaign)
	call_deferred("_layout")
