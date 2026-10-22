extends RefCounted
# Challenge constraints read own state and run after the inherited fixed tick.
# Future photo rules belong here and in the catalog; use filed observations, not hidden actors.
# Revert with challenge_run.gd; there are no calls from the ordinary Simulation.
const EPSILON=0.000001
const FINITE_TOOLS=["emp","decoy","recon","knock"]
static func before(run,order:String,args:Dictionary)->String:
	var p=run.policy
	if order in p.get("blocked",[]):return "CHALLENGE · "+p.label
	if order=="select" and p.has("crafts") and int(args.get("unit",-1)) not in p.crafts:return "CHALLENGE · drones are ashore"
	if order=="depth" and p.has("band") and int(args.get("band",-1))!=int(p.band):return "CHALLENGE · stay in MIDDLE"
	if order in FINITE_TOOLS and p.has("max_tools") and run.tools_used()>=int(p.max_tools):return "CHALLENGE · charge budget spent"
	return ""
static func observe(run,dt:float)->void:
	if not run.policy.has("loud_limit"):return
	for id in run.launched:
		if run.units[id].alive and run.motion_radius(id)>float(run.policy.loud_radius):
			run.loud_time+=dt;return
static func violation(run)->String:
	var p=run.policy
	if p.has("min_hull") and run.hull+EPSILON<float(p.min_hull):return "CHALLENGE · hull target broken"
	if p.has("max_lost") and run.lost_craft()>int(p.max_lost):return "CHALLENGE · a launched craft was lost"
	if p.has("max_time") and run.elapsed>float(p.max_time)+EPSILON:return "CHALLENGE · time limit reached"
	if p.has("max_tools") and run.tools_used()>int(p.max_tools):return "CHALLENGE · charge budget exceeded"
	if p.has("loud_limit") and run.loud_time>float(p.loud_limit)+EPSILON:return "CHALLENGE · loud-propulsion budget spent"
	if p.has("band"):
		for id in run.launched:
			if run.units[id].alive and (run.units[id].band!=int(p.band) or (not run.units[id].transition.is_empty() and int(run.units[id].transition.to)!=int(p.band))):return "CHALLENGE · left MIDDLE water"
	return ""
static func status(run)->String:
	var p=run.policy
	if p.has("max_time"):return "%s · %ds LEFT"%[p.label,ceili(maxf(0,float(p.max_time)-run.elapsed))]
	if p.has("loud_limit"):return "%s · LOUD %.1f / %.0fs"%[p.label,run.loud_time,p.loud_limit]
	if p.has("max_tools"):return "%s · CHARGES %d / %d"%[p.label,run.tools_used(),p.max_tools]
	return p.get("label","")
