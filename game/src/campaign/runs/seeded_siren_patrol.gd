extends RefCounted
# AI-DESIGNED Expedition-only starting offsets along existing physical patrol paths.
# Revert: ENABLED=false. No save fields: ordinary Siren snapshot state retains phase.
# Station roles retain their post and return intent; sweepers retain the exact circuit.
const Table=preload("res://src/campaign/runs/run_table.gd")
const ENABLED=true
const MAX_PHASE_SECONDS=12.0
const PATROL_SPEED=25.0
const STATION_TETHER_FRACTION=.65
const LAUNCH_CLEARANCE=350.0
const ARRIVAL_DISTANCE=35.0
static func apply(sim,seed:int)->void:
	if not ENABLED or sim.mission.id not in Table.POOL:return
	for i in sim.sirens.size():
		var original:Dictionary=sim.sirens[i]
		if original.get("patrol_points",[]).is_empty():continue
		var rng=RandomNumberGenerator.new()
		# Independent stream: selection, scarcity, rewards and other Sirens consume none.
		rng.seed=seed ^ (int(sim.mission.id)+1)*73856093 ^ (i+1)*19349663
		var enemy=original.duplicate(true)
		var walking:bool=sim.Sweeper.walks_lane(enemy)
		var distance=MAX_PHASE_SECONDS*PATROL_SPEED
		if not walking:distance=minf(distance,float(enemy.get("tether",190.))*STATION_TETHER_FRACTION)
		distance*=rng.randf_range(.2,1.)
		sim._use_band(enemy.band)
		var route:Array=sim._patrol_route(enemy)
		var valid=true
		# _patrol_route skips repeated initial waypoints and uses physical navigation.
		# Follow that route rather than cutting a straight chord through terrain.
		while distance>0.001 and not route.is_empty():
			var target:Vector2=route[0].pos
			var remaining:float=enemy.pos.distance_to(target)
			var step=minf(distance,remaining)
			var point:Vector2=enemy.pos.move_toward(target,step)
			if not sim.Depth.clear(sim,enemy.pos,point,enemy.band,24.):valid=false;break
			if not walking and point.distance_to(enemy.home)>float(enemy.get("tether",190.)):valid=false;break
			enemy.angle=enemy.pos.angle_to_point(target);enemy.pos=point;distance-=step
			if remaining<=step+.001:route.pop_front()
			if route.is_empty():
				if not walking:break
				route=sim._patrol_route(enemy)
			elif enemy.pos.distance_to(enemy.goal)<ARRIVAL_DISTANCE and walking:
				route=sim._patrol_route(enemy)
		if not valid:continue
		for unit in sim.units:
			if enemy.pos.distance_to(unit.pos)<LAUNCH_CLEARANCE:valid=false;break
		if not valid:continue
		if not walking:
			enemy.goal=enemy.home;route=sim.path(enemy.pos,enemy.home)
			if enemy.pos.distance_to(enemy.home)>ARRIVAL_DISTANCE and route.is_empty():continue
		enemy.route=route;enemy.path_time=2.0
		sim.sirens[i]=enemy
	# Restore the public navigation/chart band for the selected craft.
	sim._use_band(sim.units[sim.selected].band)
