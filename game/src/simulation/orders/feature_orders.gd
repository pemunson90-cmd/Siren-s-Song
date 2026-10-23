extends RefCounted
# Feature orders. Simulation.command retains each original guard seam.
# The shared table records whether successful orders run the legacy finish hooks.
# Revert by inlining these cases and removing their table rows; no rule changes.

static func command(sim, order: String, args: Dictionary) -> bool:
	match order:
		"choir_action":return sim.Choir.command(sim,args)
		"glass_action":return sim.Glass.command(sim,args)
		"depth":return sim.Depth.command(sim,args.get("band"))
		"sonar_mode":return sim.Sonar.configure(sim,args)
		"wake_playback":return sim.Wake.play(sim)
		"shelf_warn":return sim.Shelf.command(sim,"local",args.get("site",""))
		"shelf_alarm":return sim.Shelf.command(sim,"common")
		"chain_power":return sim.Chain.command(sim,args.mode) if args.get("mode") in ["connect","disconnect","backup"] else false
		"chain_route":return sim.Chain.command(sim,args.output) if args.get("output") in ["service","mast"] else false
		"chain_send":return sim.Chain.command(sim,"send")
		"blackwater_handoff":
			if not args.get("carrier") is int:return false
			return sim.Delivery.handoff(sim,args.carrier)
		"concealed_tow":return sim.Concealed.command(sim,args.get("action",""))
		"witness_land":return sim.Witness.land(sim)
		"warning_gate":return sim.Recipient.open_gate(sim)
		"warning_depart":return sim.Recipient.depart(sim,args.get("course",""))
		"salvage":
			if not args.get("item") is String:return false
			if not sim.salvage_context(args.item).get("ready",false):sim.message=sim.salvage_context(args.item).get("reason","Salvage unavailable");return false
			if args.item.begins_with("glass_"):return sim.Glass.command(sim,{"action":"recover"})
			if sim.Witness.handles(sim,args.item):return sim.Witness.begin(sim,args.item)
			return sim.Delivery.begin(sim,args.item) if args.item.begins_with("blackwater_buffer_") else sim.ModuleRecovery.begin(sim,args.item)
		"rendezvous_release":return sim.Rendezvous.release(sim)
		"depart":
			var context=sim.departure_context()
			if not context.available or not args.get("confirm") is bool:return false
			if args.has("corridor"):
				var expected=args.corridor
				if not expected is Dictionary or expected.get("pos")!=context.corridor.pos or expected.get("route","")!=context.corridor.get("route",""):return false
			if not args.confirm:sim.ModuleRecovery.defer(sim,context);sim.message="Recovery continues · route remaining module carriers, then depart";return true
			return sim._try_extract(context.corridor,true)
		_:return false
