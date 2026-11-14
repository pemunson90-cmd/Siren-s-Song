extends RefCounted
# WP-121 (Pat, 14 Nov 2026: "there can be an audio warning for proximity and ram speed"). A read-only look at one craft:
# is it heading into rock the player has charted or measured, and how close? It changes nothing in the dive; ramming
# rock and its hull damage stay exactly as simulation.gd has them. Only the player's own chart is read (the surface
# faces and return cells the craft's sensors earned, terrain_chart.gd), never the hidden shapes.
# "Ramming" asks the simulation's own collision rule (collision_damage, COLLISION_SAFE_SPEED): the speed would hurt the hull.
const Names=preload("res://src/names.gd")
# Seconds of travel at the craft's present speed inside which a rock ahead is announced. Tuning for the warning only.
const WARN_SECONDS:=5.0
# Never announce beyond this reach, and never closer than this reach (a slow craft still gets a short warning).
const MAX_RANGE:=420.0
const MIN_RANGE:=45.0
# Slower than this the craft is not "heading" anywhere.
const MIN_SPEED:=4.0
# Half-width of the path read ahead: the hull radius (simulation.gd COLLISION_HULL_CLEARANCE is two radii).
const HALF_WIDTH:=12.0
# {"state": "", "rock" or "ramming", "urgency": 0..1 (1 = about to hit), "distance": metres to the rock, "seconds": time to it}
static func read(sim,unit_id:int)->Dictionary:
	var none:={"state":"","urgency":0.0,"distance":-1.0,"seconds":-1.0}
	if unit_id<0 or unit_id>=sim.units.size() or not sim.outcome.is_empty():return none
	var u=sim.units[unit_id]
	if not u.alive or sim.DroneBay.aboard(u):return none
	var speed:float=u.vel.length()
	if speed<MIN_SPEED:return none
	var heading:Vector2=u.vel/speed
	var reach:float=clampf(speed*WARN_SECONDS,MIN_RANGE,MAX_RANGE)
	var distance:float=_distance(sim,u,heading,reach)
	if distance<0.0:return none
	var seconds:float=distance/speed
	var urgency:float=clampf(1.0-distance/reach,0.0,1.0)
	# Only Quietus has a hull to lose (simulation.gd _hull_strike); the rule is read, not copied.
	var hurts:bool=u.name==Names.UNIT_QUIETUS and sim.collision_damage(speed)>0.0
	return {"state":"ramming" if hurts else "rock","urgency":urgency,"distance":distance,"seconds":seconds}
# The most urgent reading among the player's craft: {"unit", plus read()'s fields}, or an empty state.
static func worst(sim)->Dictionary:
	var best:={"state":"","urgency":0.0,"distance":-1.0,"seconds":-1.0,"unit":-1}
	for i in sim.units.size():
		var r:Dictionary=read(sim,i)
		if r.state=="":continue
		var rank:int=2 if r.state=="ramming" else 1
		var best_rank:int=2 if best.state=="ramming" else (1 if best.state!="" else 0)
		if rank>best_rank or (rank==best_rank and r.urgency>best.urgency):best=r.duplicate();best["unit"]=i
	return best
# Metres along the heading to the first charted face within reach, or -1.
static func _distance(sim,u:Dictionary,heading:Vector2,reach:float)->float:
	var chart=sim.depth_charts.get(u.band) if not sim.depth_charts.is_empty() else sim.terrain_chart
	var faces:Array=[]
	if chart!=null:faces=chart.surface_segments
	elif u.band==1:
		# The opening operations are authored with a complete chart (parity_rules.gd CHARTED_OPERATIONS): every rock
		# face is already on the player's chart there, so the rock outlines are the charted faces.
		for polygon in sim.rock_shapes:
			for n in polygon.size():faces.append(PackedVector2Array([polygon[n],polygon[(n+1)%polygon.size()]]))
	if faces.is_empty():return -1.0
	var side:Vector2=heading.orthogonal()*HALF_WIDTH
	var best:=-1.0
	for offset in [Vector2.ZERO,side,-side]:
		var a:Vector2=u.pos+offset;var b:Vector2=a+heading*reach
		for segment in faces:
			var mid:Vector2=(segment[0]+segment[1])*0.5
			if mid.distance_to(u.pos)>reach+HALF_WIDTH+20.0:continue
			var hit=Geometry2D.segment_intersects_segment(a,b,segment[0],segment[1])
			if hit==null:continue
			var d:float=a.distance_to(hit)
			if best<0.0 or d<best:best=d
	return best
