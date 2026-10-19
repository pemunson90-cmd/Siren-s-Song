extends RefCounted
# Coarse low-frequency diffraction model, not a wave solver. Reuses the engine's
# AStar2D visibility graph. Rock is opaque; corners supply longer, weaker arrivals.
# No reflections yet. No player knowledge or listener truth enters presentation.
const Thermal=preload("res://src/simulation/thermal_front.gd")
var thermal_fronts:Array=[]
var shapes:Array=[]
var bounds:=Vector2.ZERO
var graph:=AStar2D.new()
var vertices:PackedVector2Array=[]
static func motion_radius(speed:float)->float:
	# v7's squared-speed curve, translated to current78m/s cruise/430m reference.
	# Real residual velocity counts even after a SILENT order; no toggle loophole.
	return 430.0*pow(maxf(0,speed)/78.0,2)
func configure(polygons:Array,world_bounds:Vector2,fronts:Array=[])->void:
	thermal_fronts=fronts.duplicate(true)
	shapes=polygons.duplicate(true);bounds=world_bounds;graph.clear();vertices.clear()
	for shape in shapes:
		for outline in Geometry2D.offset_polygon(shape,28.0,Geometry2D.JOIN_MITER):
			for p in outline:
				if p.x<=0 or p.y<=0 or p.x>=bounds.x or p.y>=bounds.y:continue
				if shapes.any(func(s):return Geometry2D.is_point_in_polygon(p,s)):continue
				vertices.append(p)
	for i in vertices.size():graph.add_point(i,vertices[i])
	for i in vertices.size():
		for j in range(i+1,vertices.size()):
			if clear(vertices[i],vertices[j]):graph.connect_points(i,j)
func clear(a:Vector2,b:Vector2)->bool:
	for shape in shapes:
		if Geometry2D.is_point_in_polygon(a,shape) or Geometry2D.is_point_in_polygon(b,shape):return false
		for i in shape.size():
			if Geometry2D.segment_intersects_segment(a,b,shape[i],shape[(i+1)%shape.size()])!=null:return false
	return true
func arrivals(listener:Vector2,source:Vector2,radius:float)->Array:
	if radius<=0 or listener.distance_to(source)>=radius:return []
	if clear(listener,source):
		var direct=_arrival(PackedVector2Array([listener,source]),radius)
		return [direct] if direct.strength>1.0 else []
	var start=vertices.size();var end=start+1
	graph.add_point(start,listener);graph.add_point(end,source)
	for i in vertices.size():
		if clear(listener,vertices[i]):graph.connect_points(start,i)
		if clear(source,vertices[i]):graph.connect_points(end,i)
	var result:Array=[]
	# At most two distinct bearing families. Nearby corner alternatives are not
	# independent arrivals. Removing their first legs exposes the other branch.
	for branch in 2:
		var points=graph.get_point_path(start,end)
		if points.size()<3:break
		var arrival=_arrival(points,radius)
		if arrival.strength>1.0:result.append(arrival)
		var direction=listener.direction_to(points[1])
		for id in graph.get_point_connections(start):
			if direction.dot(listener.direction_to(graph.get_point_position(id)))>cos(deg_to_rad(35)):
				graph.disconnect_points(start,id)
	graph.remove_point(start);graph.remove_point(end)
	return result
func _arrival(points:PackedVector2Array,radius:float)->Dictionary:
	var length=0.0;var turn=0.0
	for i in range(points.size()-1):
		length+=points[i].distance_to(points[i+1])
		if i>0:turn+=absf(points[i-1].direction_to(points[i]).angle_to(points[i].direction_to(points[i+1])))
	var direct=points.size()==2
	# Range and cumulative bend reduce amplitude. This is a tunable game-scale
	# approximation, not a claim of calibrated underwater transmission loss.
	var strength=radius*exp(-0.35*turn)/maxf(1,length)*Thermal.transmission(points,thermal_fronts)
	var goal=points[1]
	if direct:goal=points[0]+points[0].direction_to(points[1])*maxf(80,roundf(length/80.0)*80)
	return {"points":points,"length":length,"strength":strength,"direct":direct,"goal":goal}
static func choose(options:Array,seed:int)->Dictionary:
	if options.is_empty():return {}
	var total=0.0
	for a in options:total+=pow(a.strength,2)
	var sample=float(posmod(seed*1103515245+12345,65521))/65521.0*total
	for a in options:
		sample-=pow(a.strength,2)
		if sample<=0:return a
	return options.back()
