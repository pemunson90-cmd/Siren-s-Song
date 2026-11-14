extends SceneTree
# WP-107: every rock the route check or a collision uses is drawn as rock, on every authored mission,
# and a craft beside a wall can pull away from it (dev pathfinder and release straight legs).
const Sim=preload("res://src/simulation/simulation.gd")
const Catalog=preload("res://src/campaign/operation_catalog.gd")
const ChartCache=preload("res://src/presentation/chart_cache/chart_geometry_cache.gd")
const EarnedChart=preload("res://src/presentation/earned_chart_view.gd")
const Pilot=preload("res://src/simulation/hand_pilot/hand_pilot.gd")
var checks=0
var failures=0
class Canvas:
	extends RefCounted
	var rects=[]
	var lines=[]
	func draw_rect(rect,color,filled=true,width=1.):rects.append(rect)
	func draw_line(a,b,color,width=1.):lines.append([a,b])
func check(ok,label):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
	var ids=Catalog.registered_ids()
	check(ids.size()>=42,"every authored mission is covered ("+str(ids.size())+")")
	ChartCache.enabled=false # the plain per-cell path records every draw call
	var orphans_seen=0
	for id in ids:
		var s=Sim.new();s.start(id)
		if s.terrain_chart==null:
			_public_rocks(s,id)
		else:
			s.terrain_chart.observe([],{"pos":s.world_size()/2.,"radius":6000.})
			orphans_seen+=_chart_rocks(s,id)
	print("ROCK DRAWN: stone blocks needed for faceless return cells across missions: ",orphans_seen)
	ChartCache.enabled=true
	_synthetic()
	_crossing_point()
	_pull_away()
	print("ROCK DRAWN CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
# A mission with public terrain draws mission rocks (depth_geometry of the band, else mission.rocks), as ocean_view does.
func _public_rocks(s,id):
	for band in 3:
		var drawn=[]
		for r in s.mission.get("depth_geometry",{}).get(band,{}).get("rocks",s.mission.rocks):drawn.append(s.rock_polygon(r))
		var used=s.band_shapes[band]
		var same=used.size()==drawn.size()
		for n in used.size():same=same and n<drawn.size() and used[n]==drawn[n]
		check(same,"mission %d band %d: every rock used by routes and collisions is a drawn rock"%[id,band])
# An earned-chart mission draws faces and stone blocks; after a full survey every return cell and every rock edge shows.
func _chart_rocks(s,id)->int:
	var data=s.public_chart();var canvas=Canvas.new()
	EarnedChart.draw_terrain(canvas,data,1.)
	var uncovered=0
	for key in data.return_cells:
		var rect=Rect2(Vector2(key)*40.,Vector2(40,40));var covered=canvas.rects.has(rect)
		for line in canvas.lines:
			if covered:break
			covered=rect.grow(1.).has_point(line[0]) or rect.grow(1.).has_point(line[1]) or ChartCache._crosses(rect,line[0],line[1])
		if not covered:uncovered+=1
	check(uncovered==0,"mission %d: every return cell the route check treats as rock is drawn (%d not)"%[id,uncovered])
	var shapes=s.rock_shapes.duplicate()
	for r in s.Depth.structures(s,1):shapes.append(PackedVector2Array([r.position,Vector2(r.end.x,r.position.y),r.end,Vector2(r.position.x,r.position.y+r.size.y)]))
	var world=Rect2(Vector2.ZERO,s.world_size());var missing=0
	for polygon in shapes:
		for n in polygon.size():
			var a=polygon[n];var b=polygon[(n+1)%polygon.size()];var mid=(a+b)*.5
			if not world.has_point(a) or not world.has_point(b):continue
			var best=1000000.
			for line in canvas.lines:best=minf(best,mid.distance_to(Geometry2D.get_closest_point_to_segment(mid,line[0],line[1])))
			if best>12.:missing+=1
	check(missing==0,"mission %d: every rock and structure edge appears on the chart once surveyed (%d missing)"%[id,missing])
	return ChartCache.orphans(data).size()
func _synthetic():
	var faceless={"generation":1,"cell_size":40.,"clear_cells":[],"return_cells":[Vector2i(5,5),Vector2i(2,2)],"surface_segments":[PackedVector2Array([Vector2(100,100),Vector2(120,100)])]}
	var orphans=ChartCache.orphans(faceless)
	check(orphans==[Rect2(200,200,40,40)],"a return cell with no drawn face gets a stone block; one a face crosses does not")
	var canvas=Canvas.new();ChartCache.enabled=false;EarnedChart.draw_terrain(canvas,faceless,1.);ChartCache.enabled=true
	check(canvas.rects.has(Rect2(200,200,40,40)) and not canvas.rects.has(Rect2(80,80,40,40)),"the plain chart path draws that block")
	var cache=ChartCache.request(Canvas.new(),"wp107",faceless,[],func(_t):return Color.WHITE)
	check(cache.orphan_rects==[Rect2(200,200,40,40)],"the cached chart path builds the same block")
func _crossing_point():
	var s=Sim.new();s.start(3);s.terrain_chart.observe([],{"pos":s.world_size()/2.,"radius":6000.})
	var tried=0;var good=0;var clear=0
	for poly in s.rock_shapes:
		for n in poly.size():
			var a=poly[n];var b=poly[(n+1)%poly.size()];var edge=(a+b)*.5;var way=(b-a).normalized().orthogonal()
			for sign in [1.,-1.]:
				var out=way*sign;var from=edge+out*100.;var to=edge-out*30.
				if not _open(s,edge+out*13.5,from) or not s.terrain_chart.is_clear(from) or not Rect2(Vector2.ONE*30,s.world_size()-Vector2.ONE*60).has_point(from):continue
				tried+=1
				var at=Pilot.rock_point(s,from,to)
				if at!=null and from.distance_to(at)>30. and from.distance_to(at)<from.distance_to(to)-5.:good+=1

				if s.terrain_chart.is_clear(edge+out*70.) and Pilot.rock_point(s,from,edge+out*70.)==null:clear+=1
	check(tried>=3 and good==tried,"the red tag sits where the leg first meets rock, not at the leg's middle (%d of %d)"%[good,tried])
	check(clear>=3,"a leg that stops short of the wall has no rock point (%d)"%clear)
# True when the water from a to b (both ends included) is clear of rock by the hull's full routing margin.
func _open(s,a:Vector2,b:Vector2)->bool:
	for k in range(0,21):
		var p=a.lerp(b,k/20.)
		if p.distance_to(a)>=30. and s.blocked(p,24):return false
	return not s.blocked(b,24)
# A craft stopped beside a wall: legs pointing away are accepted, legs into the wall are not (dev pathfinder and release legs).
func _pull_away():
	for dev in [true,false]:
		var s=Sim.new();s.start(3);s.mission["dev"]=dev
		s.terrain_chart.observe([],{"pos":s.world_size()/2.,"radius":6000.})
		var tried=0;var away=0;var into=0
		for poly in s.rock_shapes:
			for n in poly.size():
				var a=poly[n];var b=poly[(n+1)%poly.size()];var edge=(a+b)*.5;var out=(b-a).normalized().orthogonal()
				for sign in [1.,-1.]:
					var way=out*sign;var pos=edge+way*13.5
					if s.blocked(pos,12) or not _open(s,pos,pos+way*150.) or s.terrain_chart.point_blocked(pos+way*150.) or not Rect2(Vector2.ONE*60,s.world_size()-Vector2.ONE*120).has_point(pos+way*150.):continue
					tried+=1
					s.units[0].pos=pos;s.units[0].vel=Vector2.ZERO;s.units[0].route=[];s.units[0].erase("route_plan")
					if s.command("route",{"point":pos+way*150.}):away+=1
					s.units[0].route=[];s.units[0].erase("route_plan")
					if not s.command("route",{"point":edge-way*30.}):into+=1
		check(tried>=3,"mission 3 has walls to test beside (dev=%s, %d)"%[dev,tried])
		check(away==tried,"a craft beside a wall can take a route leading away (dev=%s, %d of %d)"%[dev,away,tried])
		check(into==tried,"a route into the rock is still refused (dev=%s, %d of %d)"%[dev,into,tried])
