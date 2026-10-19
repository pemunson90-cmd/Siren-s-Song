extends RefCounted
# Read-only instrument copy, never an estimate of hidden enemy reception.
static func rows(feedback: Dictionary) -> Array:
	var names: Array=[]; var decoys: Array=[]; var pulses: Array=[]
	for u in feedback.motion:names.append(u.name.replace("DRONE ","D-"))
	for n in feedback.pulses:
		if n.label=="DECOY":decoys.append("%ds"%ceili(n.time))
		else:pulses.append(n)
	var tool_text="none"
	if pulses.size()==1:
		tool_text="%s %ds"%[{"ACTIVE SONAR":"SONAR","RECON UPLINK":"SURVEY","DISRUPTION":"DISRUPT","CAMERA":"CAMERA"}[pulses[0].label],ceili(pulses[0].time)]
	elif not pulses.is_empty():
		var remaining=0.0
		for n in pulses:remaining=maxf(remaining,n.time)
		tool_text="%d active · up to %ds"%[pulses.size(),ceili(remaining)]
	var result=["MOTION NOISE · %s"%(" / ".join(names) if not names.is_empty() else "below threshold"),"DECOYS · %s"%(" / ".join(decoys) if not decoys.is_empty() else "none") ]
	if not pulses.is_empty():result.append("TOOL PULSES · %s"%tool_text)
	result.append("Enemy reception unknown")
	return result
