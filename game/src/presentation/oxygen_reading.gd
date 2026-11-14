extends RefCounted
# WP-97: the oxygen words outside the pause plate (craft readout, dive result), written the way the plate writes
# them: percent of a full tank, then time left at the base drain ("87% ~3:10"). Read from the same source as the
# plate (sim.oxygen and the mission's base drain). The percent never goes over 100: an endurance fitting's extra
# tank shows as full, and the time left carries the difference.
const Endurance=preload("res://src/simulation/operation_endurance.gd")
static func percent(sim)->int:
	return clampi(roundi(float(sim.oxygen)),0,100)
# WP-121: whole seconds of air left at the base drain, or -1 when nothing drains. time_left() below is written from it,
# so Okafor's debrief line and the result's "~2:29" always come from one figure.
static func seconds_left(sim)->int:
	var per_second:float=Endurance.oxygen_drain(sim.mission,1.0)
	if per_second<=0.0:return -1
	return int(maxf(0.,float(sim.oxygen))/per_second)
static func time_left(sim)->String:
	var left:int=seconds_left(sim)
	if left<0:return "--:--"
	return "~%d:%02d"%[left/60,left%60]
# WP-98: a loadout's tank size is a capacity against the standard tank, never "oxygen left" ("O₂ 120%" read as over full).
static func tank(percent_of_standard:int)->String:
	return "O₂ tank %d%% of standard"%percent_of_standard
static func text(sim)->String:
	return "%d%% %s"%[percent(sim),time_left(sim)]
