extends RefCounted
# WP-120 (Pat, 14 Nov: "question one should be 2X and 4x, especially for testing"): the dive's time speed.
# The speeds are in trial_rules.gd (TIME_SPEEDS), the words in hud_words.gd (SPEED). This file holds the one rule
# that says when the control may be used and the one loop that scales the simulation's step in every build.
#
# HUNTING means a Siren is aware of the player's craft, judged only from what the player can see (never from hidden
# Siren state, so the control cannot give a Siren away). It is true when any of these holds:
#  1. a received contact seen in the last CONTACT_AGE seconds is in mode INVESTIGATE, SEARCH, LOCKING or BEAM
#     (alerted to, searching for, locking or beaming a craft), and is not stunned and is not a lock on someone else's
#     recipient; this includes every lock warning (the lock card reads the same contacts);
# The Hunt meter alone does not count: a stirred meter is not a Siren hunting the player's craft.
# While hunting, speed is 1x: it drops at once, shows why, and never climbs back by itself.
#
# The debug console's `time` command sets the same host.time_speed (debug_console.gd time_scale) and marks it forced:
# a forced speed is a developer's choice and is not dropped by hunting.
const Rules=preload("res://src/trial_rules.gd")
const Hunt=preload("res://src/simulation/hunt_pressure/hunt_pressure.gd")
const Stun=preload("res://src/simulation/observed_stun.gd")
const ALERT_MODES=["INVESTIGATE","SEARCH","LOCKING","BEAM"]
const CONTACT_AGE=1.0
const CHUNK_CAP=0.25
static func hunting(sim)->bool:
	if sim==null or sim.mission.is_empty() or not sim.outcome.is_empty():return false
	for id in sim.contacts:
		var c=sim.contacts[id]
		if sim.elapsed-float(c.get("time",-1000.))>CONTACT_AGE or c.get("recipient_target",false):continue
		if c.get("mode","") in ALERT_MODES and Stun.remaining(c,sim.elapsed)<=0.:return true
	return false # WP-120: a stirred Hunt meter alone is not a Siren hunting the player (root, 14 Nov)
# The speed a tap on the control selects next (1 -> 2 -> 4 -> 1).
static func next(current:float)->float:
	var speeds:Array=Rules.time_speeds()
	for i in speeds.size():
		if is_equal_approx(float(speeds[i]),current):return float(speeds[(i+1)%speeds.size()])
	return float(speeds[0])
# A tap on the control. False (and nothing changes) while a Siren is hunting.
static func cycle(host)->bool:
	if hunting(host.sim):
		host.time_speed=1.0;return false
	host.time_speed=next(host.time_speed);host.time_forced=false;return true
# Called by the clock after every scaled chunk and each frame: hunting drops the speed to 1x at once.
static func guard(host)->bool:
	if host.time_speed>1.0 and not host.time_forced and hunting(host.sim):
		host.time_speed=1.0;return true
	return false
# The one scaled step used by release builds; the debug console's advance() does the same with its extra restorations.
static func advance(host,dt:float)->void:
	var sim=host.sim
	if host.get("time_speed")==null or is_equal_approx(host.time_speed,1.0): # a bare test host has no speed: 1x
		sim.advance(dt);return
	var remaining:float=minf(dt,CHUNK_CAP)*host.time_speed
	while remaining>0.000001 and sim.outcome.is_empty() and not sim.paused:
		var amount:float=minf(remaining,sim.STEP)
		sim.advance(amount);remaining-=amount
		if guard(host):break
