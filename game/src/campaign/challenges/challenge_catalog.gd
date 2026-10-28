extends RefCounted
# Fixed replays of recovered operations; these rows never modify the operation tables.
# All rule budgets and pars live here. Pars are authored targets, not a playtest verdict.
# Optional "route_pars":{"key":"<dot path in mission>","pars":{route:par}} scores by the route taken (Pat 27 Oct, lung_solo).
# Extension: add a row and, for a new photographic rule, its check in challenge_rules.gd.
# Revert: remove this folder, the frontend entry/session, and the small profile seams.
const Gear=preload("res://src/equipment/equipment_catalog.gd")
const RULES={
	"no_sonar":{"label":"PASSIVE ONLY","blocked":["ping","recon"]},
	"quietus_only":{"label":"QUIETUS ONLY","crafts":[0]},
	"no_tools":{"label":"NO CHARGES","blocked":["emp","decoy","recon","knock"]},
	"hull_intact":{"label":"INTACT HULL","min_hull":100.0},
	"no_losses":{"label":"EVERY CRAFT HOME","max_lost":0},
	"middle_only":{"label":"MIDDLE WATER","band":1},
	"one_tool":{"label":"ONE CHARGE","max_tools":1},
	"quiet_propulsion":{"label":"QUIET PROPULSION","loud_radius":430.0,"loud_limit":20.0},
	"time_limit":{"label":"FAST RECOVERY","max_time":360.0}
}
const ROWS=[
	{"id":"shelf_passive","op":0,"title":"SHELF / PASSIVE ONLY","loadout":"endurance","rule":"no_sonar","par":{"time":90.,"hull":100.,"tools":0}},
	{"id":"split_solo","op":1,"title":"SPLIT / QUIETUS ONLY","loadout":"endurance","rule":"quietus_only","par":{"time":210.,"hull":95.,"tools":0}},
	{"id":"foundry_no_charges","op":3,"title":"FOUNDRY / NO CHARGES","loadout":"survey","rule":"no_tools","par":{"time":120.,"hull":100.,"tools":0}},
	{"id":"well_intact","op":4,"title":"WELL / INTACT HULL","loadout":"endurance","rule":"hull_intact","par":{"time":160.,"hull":100.,"tools":0}},
	{"id":"song_fleet","op":5,"title":"SONG / EVERY CRAFT HOME","loadout":"disruption","rule":"no_losses","par":{"time":180.,"hull":90.,"tools":1}},
	{"id":"rendezvous_middle","op":7,"title":"RENDEZVOUS / MIDDLE WATER","loadout":"endurance","rule":"middle_only","par":{"time":180.,"hull":95.,"tools":0}},
	{"id":"wake_one_charge","op":9,"title":"WAKE / ONE CHARGE","loadout":"disruption","rule":"one_tool","context":{"thread":"deep"},"par":{"time":180.,"hull":90.,"tools":1}},
	{"id":"glass_passive","op":14,"title":"GLASS / PASSIVE ONLY","loadout":"endurance","rule":"no_sonar","par":{"time":210.,"hull":90.,"tools":0}},
	{"id":"reach_quiet","op":16,"title":"REACH / QUIET PROPULSION","loadout":"endurance","rule":"quiet_propulsion","par":{"time":240.,"hull":85.,"tools":0}},
	{"id":"glass_fast","op":19,"title":"GLASS / FAST RECOVERY","loadout":"survey","rule":"time_limit","par":{"time":240.,"hull":85.,"tools":0}},
	{"id":"stair_no_charges","op":23,"title":"STAIR / NO CHARGES","loadout":"endurance","rule":"no_tools","par":{"time":240.,"hull":90.,"tools":0}},
	{"id":"lung_solo","op":29,"title":"LUNG / QUIETUS ONLY","loadout":"endurance","rule":"quietus_only","par":{"time":110.,"hull":100.,"tools":0},
		"route_pars":{"key":"iron_choir.choice","pars":{"dismantle":{"time":110.,"hull":100.,"tools":0},"reconnect":{"time":300.,"hull":100.,"tools":0}}}}
]
static func all()->Array:
	return ROWS.duplicate(true)
static func get_challenge(id:String)->Dictionary:
	for row in ROWS:
		if row.id==id:return row.duplicate(true)
	return {}
static func unlocked(row:Dictionary,completed:Array)->bool:
	return row.get("op",-1) in completed
static func fitting(_row:Dictionary)->Dictionary:
	return Gear.default_loadout()
static func rule(row:Dictionary)->Dictionary:
	return RULES.get(row.get("rule",""),{}).duplicate(true)
static func description(row:Dictionary)->String:
	var r=rule(row)
	match row.rule:
		"no_sonar":return "No SONAR or SURVEY. Listen and use the camera."
		"quietus_only":return "Quietus works alone. Drones stay ashore."
		"no_tools":return "Use no DISRUPT, DECOY, SURVEY or TORPEDO charges."
		"hull_intact":return "Keep at least %d%% hull throughout the dive."%roundi(r.min_hull)
		"no_losses":return "Bring every launched craft home alive."
		"middle_only":return "Keep every craft in MIDDLE throughout the dive."
		"one_tool":return "Use at most %d DISRUPT, DECOY, SURVEY or TORPEDO charge."%r.max_tools
		"quiet_propulsion":return "Any craft with MOTION above %dm spends the shared %ds loud-propulsion budget."%[roundi(r.loud_radius),roundi(r.loud_limit)]
		"time_limit":return "Recover within %02d:%02d of running time. Tactical pause is unlimited."%[int(r.max_time)/60,int(r.max_time)%60]
	return ""
