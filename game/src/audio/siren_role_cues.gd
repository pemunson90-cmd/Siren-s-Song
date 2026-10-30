extends RefCounted
# Short, restrained acoustic signatures. These are presentation cues only;
# the event remains on its original received-message bus and timing.
const SIGNATURES={"patroller":"role_patroller","hunter":"role_hunter","sentinel":"role_sentinel","sweeper":"role_sweeper","buoy":"role_buoy","relay":"role_relay","interceptor":"role_interceptor","warden":"role_warden"}
const CUES={
	"role_patroller":{"seconds":.34,"gain_db":-25.,"hz":[180.,250.],"noise":.02,"curve":1.2,"pulses":1},
	"role_hunter":{"seconds":.42,"gain_db":-26.,"hz":[95.,70.],"noise":.14,"curve":.9,"pulses":2},
	"role_sentinel":{"seconds":.28,"gain_db":-27.,"hz":[320.,390.],"noise":.01,"curve":1.6,"pulses":1},
	"role_sweeper":{"seconds":.48,"gain_db":-26.,"hz":[140.,260.],"noise":.22,"curve":.8,"pulses":3},
	"role_buoy":{"seconds":.32,"gain_db":-28.,"hz":[470.,320.],"noise":.03,"curve":1.4,"pulses":2},
	"role_relay":{"seconds":.38,"gain_db":-27.,"hz":[230.,340.],"noise":.05,"curve":1.1,"pulses":3},
	"role_interceptor":{"seconds":.3,"gain_db":-27.,"hz":[390.,160.],"noise":.18,"curve":1.3,"pulses":2},
	"role_warden":{"seconds":.46,"gain_db":-28.,"hz":[120.,185.],"noise":.03,"curve":.9,"pulses":1},
}
const PASSIVE_ROLES=["patroller","hunter","sentinel","warden"]
var mission_ref:Dictionary={}
var last_clock:float=-1.
var seen_bearings:Dictionary={}
static func signature(role:String)->String:return SIGNATURES.get(role,"")
static func identified_signature(sim,raw:Dictionary)->String:
	# Retain the received-message cue and its bus. Substitute a role recording only
	# after the same persisted first-hand identification used by contact rendering.
	var id=int(raw.get("enemy",-1));var identified=sim.sonar.get("identified",{})
	if id<0 or not identified.has(id) or raw.get("type","") not in ["carrier_received","return_received","sweep_received"]:return ""
	return signature(str(identified[id]))
func _bearing_key(row:Dictionary)->String:
	return "%d/%d/%.6f"%[int(row.get("station",-1)),int(row.get("enemy",-1)),float(row.get("time",-1.))]
func _baseline(sim,history:Array)->void:
	mission_ref=sim.mission;last_clock=float(sim.elapsed);seen_bearings.clear()
	for row in history:
		if row is Dictionary and row.get("kind","")=="bearing":seen_bearings[_bearing_key(row)]=true
func new_bearing_events(sim)->Array:
	# Bearing history is a bounded evidence view, so baseline it on first use,
	# mission replacement and rewind. Old rows never become fresh audio.
	var history:Array=sim.sonar.get("history",[])
	if not is_same(mission_ref,sim.mission) or sim.elapsed<last_clock:
		_baseline(sim,history);return []
	var present:Dictionary={};var result:Array=[];var identified:Dictionary=sim.sonar.get("identified",{})
	for row in history:
		if not row is Dictionary or row.get("kind","")!="bearing":continue
		var key=_bearing_key(row);present[key]=true
		if seen_bearings.has(key):continue
		# Consume each row even when its role is unknown, another craft received
		# it, the game is paused, or its receive window has elapsed.
		if int(row.get("enemy",-1))<0 or int(row.enemy)>=sim.sirens.size():continue
		var role=str(identified.get(int(row.enemy),""))
		if role not in PASSIVE_ROLES:continue
		result.append({"type":"carrier_received","receiver":int(row.station),"direction":row.direction,"enemy":int(row.enemy),"time":float(row.time),"pos":Vector2.ZERO})
	seen_bearings=present;last_clock=float(sim.elapsed)
	return result
