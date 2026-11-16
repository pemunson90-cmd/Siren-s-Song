extends RefCounted
const Names=preload("res://src/names.gd")
# Player weapons orders. Called only after Simulation.command's existing guards.
# The shared table records whether successful orders run the legacy finish hooks.
# Revert by inlining these cases and removing their table rows; no rule changes.
const Tuning=preload("res://src/simulation/tuning.gd")
const HudWords=preload("res://src/presentation/hud_words.gd") # WP-137: the lock-broken message

static func command(sim, order: String, args: Dictionary) -> bool:
	var u=sim.units[sim.selected]
	match order:
		"emp":
			if sim.tools.emp<=0: return false
			# WP-16 (Pat, 2026-11-12; v7 line 254): with no Siren in range the charge is kept.
			if sim.ParityRules.on(sim.mission,"disrupt_needs_target") and not sim.sirens.any(func(s):return s.pos.distance_to(u.pos)<Tuning.EMP_RADIUS*sim.Depth.transmission(u,s)):
				sim.message="No Siren within EMP range · charge kept";return false
			sim.tools.emp-=1
			for s in sim.sirens:
				if s.pos.distance_to(u.pos)<Tuning.EMP_RADIUS*sim.Depth.transmission(u,s): s.stun=Tuning.EMP_STUN; s["emp_hit"]=true; s.lock=0.0; s.target=-1; s.erase("recipient_target"); s.mode="PINNED" if s.get("pin_time",0)>0 else "DISRUPTED"
			sim._noise(u.pos,Tuning.WEAPON_NOISE,Names.NOISE_EMP,Tuning.WEAPON_NOISE_TIME,u.band); sim.message="EMP pulse · 12 second recovery window"; sim.events.append({"type":"emp","pos":u.pos})
		"knock":
			var id=args.get("target",null)
			var eligible=sim.knockdown_targets().any(func(c):return c.key==id) if id is int else false
			if sim.tools.get("knock",0)<=0 or not eligible or id<0 or id>=sim.sirens.size(): sim.message="Knockdown needs a fresh contact within 150m and a clear path."; return false
			var target=sim.sirens[id]
			var launch_band=sim._knock_band(sim.contacts[id])
			if target.stun>0 or launch_band not in sim.Depth.occupied(target) or not sim.contact_visible(target) or u.pos.distance_to(target.pos)>sim.KNOCK_RANGE or not sim.Depth.clear(sim,u.pos,target.pos,launch_band,3): sim.message="Knockdown target unavailable · no torpedo spent."; return false
			sim.tools.knock-=1
			sim.projectiles.append({"pos":u.pos,"angle":u.angle,"target":id,"aim":target.pos,"life":sim.TORPEDO_LIFE,"noise_clock":0.0,"band":launch_band})
			sim._noise(u.pos,Tuning.WEAPON_NOISE,Names.NOISE_KNOCKDOWN,Tuning.WEAPON_NOISE_TIME,u.band); sim.events.append({"type":"knock","pos":u.pos})
			sim.message="Torpedo launched at S%d · pin on impact · emission audible"%(id+1)
		"decoy":
			var point=args.get("point",u.pos+Vector2(sim.DECOY_RANGE,0))
			if not sim.decoy_target_valid(point): sim.message="Decoy needs clear water within 160m and a clear path · no charge spent"; return false
			# WP-137 (Pat, 15 Nov 2026): a decoy breaks a lock that is counting down on a Siren that hears it.
			var broken:Array=sim.decoy_lock_breakers(point,u.band)
			sim.tools.decoy-=1; sim._noise(point,Tuning.DECOY_NOISE,Names.NOISE_DECOY,Tuning.DECOY_TIME,u.band); sim.message="Decoy launched · 15s transmission"; sim.events.append({"type":"decoy","pos":u.pos})
			for id in broken:
				var s=sim.sirens[id]
				s.lock=0.0; s.target=-1; s.erase("recipient_target"); s["decoy_draw"]=Tuning.DECOY_TIME
				s.goal=point; s["last_known"]=point; s.mode="INVESTIGATE"; s.suspicion=maxf(s.suspicion,0.45); s["attention_time"]=sim.Sweeper.attention(s); s["search_index"]=0
				sim.events.append({"type":"lock_broken","siren":id,"pos":s.pos})
				# WP-148: the player's own contact record of this lock ends with it (the message above says so), so the lock
				# card closes and offers nothing more even while the dive is paused (a paused clock keeps the record fresh).
				if sim.contacts.has(id) and sim.contacts[id].get("mode","")=="LOCKING":sim.contacts[id]["lock"]=0.0;sim.contacts[id]["target"]=-1;sim.contacts[id]["mode"]="INVESTIGATE"
			if not broken.is_empty():sim.message=HudWords.lock_broken(broken);sim.mission["decoy_breaks"]=int(sim.mission.get("decoy_breaks",0))+broken.size() # WP-152: tally for the debrief line
		_:return false
	return true
