extends RefCounted
# Player route orders. Called only after Simulation.command's existing guards.
# The shared table records whether successful orders run the legacy finish hooks.
# Revert by inlining these cases and removing their table rows; no rule changes.
const Tuning=preload("res://src/simulation/tuning.gd")

static func command(sim, order: String, args: Dictionary) -> bool:
	var u=sim.units[sim.selected]
	match order:
		"select":
			var id=int(args.get("unit",0))
			if id<0 or id>=sim.units.size() or not sim.units[id].alive: return false
			sim.selected=id; sim._use_band(sim.units[id].band); sim.queue_mode=false
			sim.message="%s selected · next tap replaces route" % sim.units[id].name
		"waypoint_mode": sim.pass_through=not sim.pass_through; sim.message="Queued waypoints PASS through" if sim.pass_through else "Queued waypoints STOP before continuing"
		"queue": sim.queue_mode=not sim.queue_mode; sim.message="QUEUE: tap to add" if sim.queue_mode else "REPLACE: tap to set route"
		"route", "emergency":
			var append=sim.queue_mode and order!="emergency"
			var plan=sim.route_goals() if append else []
			if append and not plan.is_empty() and not plan.back().get("arrival_set",false): plan.back().stop=not sim.pass_through
			plan.append({"pos":args.get("point",u.pos),"stop":true,"mode":"inherit"})
			if not sim._install_program(u,plan,append,append and not u.route.is_empty()): sim.message="Rock or unsafe clearance. Choose open water."; return false
			if not append:
				u.hold=""
				sim.captures[sim.selected]={}
			if order=="emergency":
				sim.queue_mode=false; u.silent=false; u.erase("route_undo")
				if sim.selected>0 and u.has("drone_drive"):u.drone_drive="transit"
			sim.message="%s · %s route" % [u.name,"queued" if append else "replaced"]
		"route_edit", "route_insert", "route_delete", "route_undo":
			if not sim._edit_program(order,args): return false
		"order_undo":
			# Presentation-held restore of the last plain route order: prior goals and hold only.
			var prior=args.get("goals",[]);var prior_hold=args.get("hold","")
			if not prior is Array or not prior_hold is String or prior_hold not in ["","HOLD","CONTACT","DRONE",sim.DroneOperations.ARMED,sim.DroneOperations.STOPPED]:return false
			if prior.is_empty():
				u.route=[];u.erase("route_plan");u.erase("route_undo")
			elif not sim._install_program(u,prior,false):sim.message="Previous course is no longer safe.";return false
			u.hold=prior_hold;sim.message="%s · last order undone"%u.name
		"hold": u.hold="" if u.hold=="HOLD" else "HOLD"; sim.message="Holding position" if u.hold!="" else "Route released"
		"contact_hold":
			if u.hold in ["CONTACT",sim.DroneOperations.ARMED,sim.DroneOperations.STOPPED]:
				u.hold="";sim.message="%s · condition released · retained route resumes"%u.name
			elif sim.selected==0:u.hold="CONTACT";sim.message="Quietus fleet guard · hold while any fresh contact is observed"
			else:u.hold=sim.DroneOperations.ARMED;sim.message="%s SCOUT · stop on its own passive contact · release or replot to continue"%u.name
		"wait_drone": u.hold="" if u.hold=="DRONE" else "DRONE"; sim.message="Wait until a live drone reaches its final waypoint"
		"silent":
			u.silent=not u.silent
			# A direct propulsion command overrides the current programmed leg only.
			if sim.selected==0 and u.has("route_plan") and not u.route_plan.is_empty():
				_set_leg_mode(u,"silent" if u.silent else "cruise")
			sim.message=(("Low visual profile" if u.silent else "Open visual profile")+" · drone thrust target %dm/s"%(Tuning.DRONE_QUIET_SPEED if u.get("drone_drive","transit")=="quiet" else Tuning.DRONE_TRANSIT_SPEED)) if sim.selected>0 else ("Silent running" if u.silent else "Cruise thrust · increased noise")
		"drone_drive":
			var mode=args.get("mode","")
			if sim.selected==0 or mode not in ["quiet","transit"]:return false
			u.drone_drive=mode
			if u.has("route_plan") and not u.route_plan.is_empty():
				_set_leg_mode(u,"silent" if mode=="quiet" else "cruise")
			sim.message="%s · %s · visual profile unchanged"%[u.name,"QUIET42" if mode=="quiet" else "TRANSIT96"]
		"all_stop":return sim.AllStop.command(sim)
		_:return false
	return true

# Override the current programmed leg only, retaining later leg modes.
static func _set_leg_mode(u:Dictionary,mode:String)->void:
	u.route_plan[0].mode=mode
	for node in u.route:
		node.mode=u.route_plan[0].mode
		if node.get("goal",false):break
