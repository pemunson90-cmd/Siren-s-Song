extends RefCounted
# The one door for every pause the game makes by itself: the accessibility aids (first notice, lock
# warning, craft loss), and the trial rules of 2026-11-13 (trial_rules.gd): a new Siren lock, a finished
# route, a craft held by rock or not getting anywhere on its route (no_progress.gd). Nothing else sets sim.paused=true on the player's behalf.
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
const NoProgress=preload("res://src/presentation/no_progress.gd")
var reason_key:=""
var reason_unit:=-1
var reason_extra:=""
var blocked:Dictionary={}
# Each craft's best distance to its next point and when it was reached, for the no-progress look (no_progress.gd).
var watch:Dictionary={}
var mission=null
var clock:=-1.0
func _sync(sim)->void:
	if not is_same(mission,sim.mission) or sim.elapsed<clock:
		mission=sim.mission;blocked.clear();watch.clear();reason_key="";reason_unit=-1;reason_extra=""
	clock=sim.elapsed
# Pauses the dive. key names the reason line ("notice", "lock", "route_end", "blocked"; "" for none, when the
# message alone states it); unit is the craft the reason names; message, when given, replaces the status
# message; extra is the second name some reason lines carry (the depth that is open). Returns true when this
# call is what stopped a running dive.
func request(host,key:String,unit:int=-1,message:String="",extra:String="")->bool:
	var sim=host.sim
	_sync(sim)
	if host.screen!="mission" or not sim.outcome.is_empty():return false
	var stopped:bool=not sim.paused
	sim.paused=true
	if not message.is_empty():sim.message=message
	if stopped:reason_key=key;reason_unit=unit;reason_extra=extra
	return stopped
# The player resumed (or paused by hand): the reason no longer applies.
func clear()->void:
	reason_key="";reason_unit=-1;reason_extra=""
# The reason line for the dive as it is now, or "" when the player paused or the dive is running.
func line(sim)->String:
	if not sim.paused or reason_key.is_empty():
		reason_key="";return ""
	return Words.auto_pause_text(reason_key,str(sim.units[reason_unit].name).to_upper() if reason_unit>=0 and reason_unit<sim.units.size() else "",reason_extra)
# Trial rule 5: a craft that holds because rock blocks its leg (hand_pilot sets edge_hold when it holds), or that has a
# route and is not getting anywhere (no_progress.gd), pauses the dive once for that hold, with the reason on the status
# line and in the status message. The hold ends when the craft moves again or its route is replaced or cleared.
func observe_blocked(host)->void:
	if not TrialRules.pause_when_blocked():return
	var sim=host.sim
	_sync(sim)
	if host.screen!="mission" or not sim.outcome.is_empty():return
	for i in sim.units.size():
		var u=sim.units[i]
		if not u.alive:
			blocked.erase(i);watch.erase(i);continue
		var held:bool=not str(u.get("edge_hold","")).is_empty()
		if held:watch.erase(i)
		elif not NoProgress.stalled(sim,i,watch):
			blocked.erase(i);continue
		if blocked.has(i):continue
		blocked[i]=true
		var why:Dictionary=NoProgress.why(sim,i,held)
		request(host,why.key,i,Words.stall_message(why.key,str(u.name).to_upper(),why.extra),why.extra)
