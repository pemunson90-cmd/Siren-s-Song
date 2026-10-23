extends RefCounted
# Player photo orders. Called only after Simulation.command's existing guards.
# The shared table records whether successful orders run the legacy finish hooks.
# Revert by inlining these cases and removing their table rows; no rule changes.
const Tuning=preload("res://src/simulation/tuning.gd")

static func command(sim, order: String, args: Dictionary) -> bool:
	var u=sim.units[sim.selected]
	match order:
		"frame":
			return sim.Photo.set_frame(sim,sim.selected,args)
		"camera":
			if not sim.module_recovery_status().jobs[sim.selected].is_empty() or sim.Delivery.busy(sim,sim.selected) or sim.Witness.busy(sim,sim.selected) or sim.Glass.busy(sim,sim.selected) or sim.Choir.busy(sim,sim.selected) or sim._warning_chain_busy(sim.selected):sim.message="Finish this craft's wreck recovery first";return false
			var context=sim.camera_context()
			if not context.ready: sim.message=context.text; return false
			var photo_target:int=context.target if context.target>=0 else sim.Photo.siren_objective(sim,context.siren)
			if photo_target<0:sim.message="No available photographic subject";return false
			var target=sim.Photo.obj(sim,photo_target)
			sim.captures[sim.selected]={"target":photo_target,"elapsed":0.0}; u.hold="HOLD"
			sim.Operations.begin(sim,target,sim.selected)
			if sim.Photo.applies(target):
				sim.Photo.begin(sim,sim.selected,photo_target)
				if target.captured:sim.Recon.action(sim.mission,Tuning.REPEAT_PHOTO_ACTION)
			sim.message="%s · hold %.0f seconds"%["Hydrophone reception" if target.get("kind","")=="exchange" else ("Passive hydrophone decode" if target.get("kind","")=="receiver" else ("Archive uplink" if target.get("kind","")=="uplink" else "Warning transmission" if sim.Operations.own_origin(target) else "Camera exposure")),sim._capture_duration(target,sim.selected)]
			if target.get("kind","") not in ["receiver","exchange","transmitter"] or not sim.Sampler.capture_spec(sim.selected,sim.mission.get("launch_equipment",{}),target).is_empty():
				sim._noise(u.pos,sim.Photo.noise_radius(sim,sim.selected) if sim.Photo.applies(target) else Tuning.PHOTO_FALLBACK_NOISE,"CAMERA",Tuning.PHOTO_NOISE_TIME,u.band);sim.noises.back()["record"]=photo_target
			sim.events.append({"type":"camera","pos":u.pos})
		_:return false
	return true
