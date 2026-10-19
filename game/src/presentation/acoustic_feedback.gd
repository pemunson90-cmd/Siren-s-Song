extends RefCounted
# Read-only instrument copy, never an estimate of hidden enemy reception.
static func rows(feedback: Dictionary) -> Array:
	var names: Array=[]; var decoys: Array=[]; var pulses: Array=[]
	for u in feedback.motion:
		var name=u.name.replace("DRONE ","D-")
		if feedback.get("revision",0)==1:name+=" "+("<1m" if u.radius<1 else "%dm"%roundi(u.radius))
		names.append(name)
	for n in feedback.pulses:
		if n.label=="DECOY":decoys.append("%ds"%ceili(n.time))
		else:pulses.append(n)
	var tool_text="none"
	if pulses.size()==1:
		tool_text="%s %ds"%[{"ACTIVE SONAR":"SONAR","RECON UPLINK":"SURVEY","DISRUPTION":"DISRUPT","CAMERA":"CAMERA","KNOCKDOWN":"KNOCKDOWN","TORPEDO RUN":"TORPEDO"}.get(pulses[0].label,pulses[0].label),ceili(pulses[0].time)]
	elif not pulses.is_empty():
		var remaining=0.0
		for n in pulses:remaining=maxf(remaining,n.time)
		tool_text="%d active · up to %ds"%[pulses.size(),ceili(remaining)]
	var result=["MOTION NOISE · %s"%(" / ".join(names) if not names.is_empty() else ("idle" if feedback.get("revision",0)==1 else "below threshold")),"DECOYS · %s"%(" / ".join(decoys) if not decoys.is_empty() else "none") ]
	if not pulses.is_empty():result.append("TOOL PULSES · %s"%tool_text)
	if feedback.get("thermal",false):result.append("OPEN RANGE · COLD FRONT weakens sound + passive contacts")
	elif feedback.get("revision",0)==1:result.append("OPEN WATER · basalt bends/weakens sound · enemy reception unknown")
	else:result.append("Enemy reception unknown")
	return result
