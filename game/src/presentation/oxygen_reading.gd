extends RefCounted
# WP-97: the oxygen words outside the pause plate (craft readout, dive result), written the way the plate writes
# them: percent of a full tank, then time left at the base drain ("87% ~3:10"). Read from the same source as the
# plate (sim.oxygen and the mission's base drain). The percent never goes over 100: an endurance fitting's extra
# tank shows as full, and the time left carries the difference.
const Endurance=preload("res://src/simulation/operation_endurance.gd")
static func percent(sim)->int:
	return clampi(roundi(float(sim.oxygen)),0,100)
static func time_left(sim)->String:
	var per_second:float=Endurance.oxygen_drain(sim.mission,1.0)
	if per_second<=0.0:return "--:--"
	var left:float=maxf(0.,float(sim.oxygen))/per_second
	return "~%d:%02d"%[int(left)/60,int(left)%60]
static func text(sim)->String:
	return "%d%% %s"%[percent(sim),time_left(sim)]
