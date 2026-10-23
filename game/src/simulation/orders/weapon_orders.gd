extends RefCounted
# Player weapons orders. Called only after Simulation.command's existing guards.
# The shared table records whether successful orders run the legacy finish hooks.
# Revert by inlining these cases and removing their table rows; no rule changes.
const Tuning=preload("res://src/simulation/tuning.gd")

static func command(sim, order: String, args: Dictionary) -> bool:
	var u=sim.units[sim.selected]
	match order:
		"emp":
			if sim.tools.emp<=0: return false
			sim.tools.emp-=1
			for s in sim.sirens:
				if s.pos.distance_to(u.pos)<Tuning.EMP_RADIUS*sim.Depth.transmission(u,s): s.stun=Tuning.EMP_STUN; s.lock=0.0; s.target=-1; s.erase("recipient_target"); s.mode="PINNED" if s.get("pin_time",0)>0 else "DISRUPTED"
			sim._noise(u.pos,Tuning.WEAPON_NOISE,"DISRUPTION",Tuning.WEAPON_NOISE_TIME,u.band); sim.message="Disruption pulse · 12 second recovery window"; sim.events.append({"type":"emp","pos":u.pos})
		"knock":
			var id=args.get("target",null)
			var eligible=sim.knockdown_targets().any(func(c):return c.key==id) if id is int else false
			if sim.tools.get("knock",0)<=0 or not eligible or id<0 or id>=sim.sirens.size(): sim.message="Knockdown needs a fresh contact within 150m and a clear path."; return false
			var target=sim.sirens[id]
			var launch_band=sim._knock_band(sim.contacts[id])
			if target.stun>0 or launch_band not in sim.Depth.occupied(target) or not sim.contact_visible(target) or u.pos.distance_to(target.pos)>sim.KNOCK_RANGE or not sim.Depth.clear(sim,u.pos,target.pos,launch_band,3): sim.message="Knockdown target unavailable · no torpedo spent."; return false
			sim.tools.knock-=1
			sim.projectiles.append({"pos":u.pos,"angle":u.angle,"target":id,"aim":target.pos,"life":sim.TORPEDO_LIFE,"noise_clock":0.0,"band":launch_band})
			sim._noise(u.pos,Tuning.WEAPON_NOISE,"KNOCKDOWN",Tuning.WEAPON_NOISE_TIME,u.band); sim.events.append({"type":"knock","pos":u.pos})
			sim.message="Torpedo launched at S%d · pin on impact · emission audible"%(id+1)
		"decoy":
			var point=args.get("point",u.pos+Vector2(sim.DECOY_RANGE,0))
			if not sim.decoy_target_valid(point): sim.message="Decoy needs clear water within 160m and a clear path · no charge spent"; return false
			sim.tools.decoy-=1; sim._noise(point,Tuning.DECOY_NOISE,"DECOY",Tuning.DECOY_TIME,u.band); sim.message="Decoy launched · 15s transmission"; sim.events.append({"type":"decoy","pos":u.pos})
		_:return false
	return true
