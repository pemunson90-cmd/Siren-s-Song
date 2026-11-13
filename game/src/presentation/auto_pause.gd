extends RefCounted
# The one door for every pause the game makes by itself: the accessibility aids (first notice, lock
# warning, craft loss), and the trial rules of 2026-11-13 (trial_rules.gd): a new Siren lock, a finished
# route, a craft held by rock. Nothing else sets sim.paused=true on the player's behalf.
#
# It keeps three things so every automatic pause behaves alike:
#   - the reason the dive is held now (read by hud_words.pause_reason for the status line), dropped as soon
#     as the player resumes;
#   - the holds already paused for, so resuming never pauses again for the same hold (blocked);
#   - the dive it belongs to, so a new dive or a restored one starts with an empty memory.
# The tactical aids own the one instance (tactical_aids.auto_pause); the HUD reaches it through
# main.request_auto_pause().
const Words=preload("res://src/presentation/hud_words.gd")
const TrialRules=preload("res://src/trial_rules.gd")
var reason_key:=""
var reason_unit:=-1
var blocked:Dictionary={}
var mission=null
var clock:=-1.0
func _sync(sim)->void:
	if not is_same(mission,sim.mission) or sim.elapsed<clock:
		mission=sim.mission;blocked.clear();reason_key="";reason_unit=-1
	clock=sim.elapsed
# Pauses the dive. key names the reason line ("notice", "lock", "route_end", "blocked"; "" for none, when the
# message alone states it); unit is the craft the reason names; message, when given, replaces the status
# message. Returns true when this call is what stopped a running dive.
func request(host,key:String,unit:int=-1,message:String="")->bool:
	var sim=host.sim
	_sync(sim)
	if host.screen!="mission" or not sim.outcome.is_empty():return false
	var stopped:bool=not sim.paused
	sim.paused=true
	if not message.is_empty():sim.message=message
	if stopped:reason_key=key;reason_unit=unit
	return stopped
# The player resumed (or paused by hand): the reason no longer applies.
func clear()->void:
	reason_key="";reason_unit=-1
# The reason line for the dive as it is now, or "" when the player paused or the dive is running.
func line(sim)->String:
	if not sim.paused or reason_key.is_empty():
		reason_key="";return ""
	return Words.auto_pause_text(reason_key,str(sim.units[reason_unit].name).to_upper() if reason_unit>=0 and reason_unit<sim.units.size() else "")
# Trial rule 5: a craft that holds because rock blocks its leg (hand_pilot sets edge_hold when it holds)
# pauses the dive once for that hold. The hold ends when the craft's edge_hold is cleared by a new order.
func observe_blocked(host)->void:
	if not TrialRules.pause_when_blocked():return
	var sim=host.sim
	_sync(sim)
	if host.screen!="mission" or not sim.outcome.is_empty():return
	for i in sim.units.size():
		var u=sim.units[i]
		if not u.alive or str(u.get("edge_hold","")).is_empty():
			blocked.erase(i);continue
		if blocked.has(i):continue
		blocked[i]=true
		request(host,"blocked",i)
