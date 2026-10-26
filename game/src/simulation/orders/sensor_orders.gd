extends RefCounted
# Player sensors orders. Called only after Simulation.command's existing guards.
# The shared table records whether successful orders run the legacy finish hooks.
# Revert by inlining these cases and removing their table rows; no rule changes.
const Tuning=preload("res://src/simulation/tuning.gd")

static func command(sim, order: String, args: Dictionary) -> bool:
	var u=sim.units[sim.selected]
	match order:
		"ping":
			if sim.ping_time>0: return false
			if not sim.Sonar.emit(sim,sim.selected):return false
			sim.ping_time=Tuning.PING_FEEDBACK_TIME; sim.ping_origin=u.pos; sim.events.append({"type":"ping","pos":u.pos}); sim.message="Pulse away · wait for physical echoes · emission audible"
			sim._observe()
			if sim.mission.get("blackwater_revision",0)==1:
				var answered=false
				for target in sim.mission.objectives:
					if not target.captured and u.band==1 and u.pos.distance_to(target.pos)<Tuning.RELAY_RANGE and sim.Depth.clear(sim,u.pos,target.pos,1) and sim.Sonar.in_sector(u.pos,target.pos,u.angle,sim.sonar.sector):
						target.replay_until=sim.elapsed+Tuning.RELAY_REPLAY_TIME;answered=true
				if answered:sim.message="SONAR emitted · local relay replay 3s · settle and SAMPLE"
		"recon":
			if sim.tools.recon<=0: return false
			if sim.mission.has("world_size"):sim.mission["survey_origin"]=u.pos
			sim.tools.recon-=1; sim.recon_time=Tuning.RECON_TIME; sim._noise(u.pos,Tuning.RECON_NOISE,"RECON UPLINK",Tuning.RECON_NOISE_TIME,u.band); sim.message="Local 560m survey · 8 seconds" if sim.mission.has("world_size") else "Wide survey uplink · 8 seconds"; sim.SignalField.observe(sim,true); sim.Consequences.observe(sim,true); sim.events.append({"type":"recon","pos":u.pos}); sim._observe()
		_:return false
	return true
