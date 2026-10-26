extends SceneTree
# PERF fix 1 equivalence: AcousticPaths.clear() now skips polygons whose bounding box misses
# the segment's box. The old straightforward clear() lives below as the oracle. Timing is printed, never asserted.
const Sim=preload("res://src/simulation/simulation.gd")
const Fast=preload("res://src/simulation/acoustic_paths.gd")
const PolygonContainment=preload("res://src/simulation/polygon_containment.gd")
class Oracle extends "res://src/simulation/acoustic_paths.gd":
	func clear(a:Vector2,b:Vector2)->bool:
		for index in shapes.size():
			var shape=shapes[index]
			if PolygonContainment.contains(a,shape,shape_bounds[index]) or PolygonContainment.contains(b,shape,shape_bounds[index]):return false
			for i in shape.size():
				if Geometry2D.segment_intersects_segment(a,b,shape[i],shape[(i+1)%shape.size()])!=null:return false
		return true
var checks=0
var failures=0
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
	var rng=RandomNumberGenerator.new();rng.seed=20260524
	for op in [0,6,16,19]:
		var s=Sim.new();s.start(op,"endurance")
		var polys=s.Depth.shapes(s,1)
		var old=Oracle.new();var fast=Fast.new()
		var at=Time.get_ticks_usec();old.configure(polys,s.world_size(),[]);var t_old=Time.get_ticks_usec()-at
		at=Time.get_ticks_usec();fast.configure(polys,s.world_size(),[]);var t_new=Time.get_ticks_usec()-at
		check(old.vertices==fast.vertices,"op %d same vertices"%op)
		check(old.graph.get_point_count()==fast.graph.get_point_count(),"op %d same graph points"%op)
		var same_edges=true
		for i in old.vertices.size():
			if old.graph.get_point_connections(i)!=fast.graph.get_point_connections(i):same_edges=false;break
		check(same_edges,"op %d same graph edges"%op)
		var world:Vector2=s.world_size()
		var pairs=0;var diffs=0;var blocked=0;var tc_old=0;var tc_new=0
		var points:Array=[]
		# Random, degenerate and vertex-touching segments.
		for n in 1500:
			var a=Vector2(rng.randf_range(0,world.x),rng.randf_range(0,world.y))
			var b=a+Vector2(rng.randf_range(-400,400),rng.randf_range(-400,400))
			points.append([a,b])
		for n in 100:
			var a=Vector2(rng.randf_range(0,world.x),rng.randf_range(0,world.y));points.append([a,a])
		for shape in polys:
			for v in shape:
				var other=v+Vector2(rng.randf_range(-250,250),rng.randf_range(-250,250))
				points.append([v,other]);points.append([other,v])
				points.append([v,v+Vector2(30,0)]);points.append([v+Vector2(-60,0),v+Vector2(60,0)])
		for pair in points:
			at=Time.get_ticks_usec();var r1=old.clear(pair[0],pair[1]);tc_old+=Time.get_ticks_usec()-at
			at=Time.get_ticks_usec();var r2=fast.clear(pair[0],pair[1]);tc_new+=Time.get_ticks_usec()-at
			pairs+=1
			if r1!=r2:diffs+=1
			if not r1:blocked+=1
		check(diffs==0,"op %d clear() identical on %d segments (%d blocked)"%[op,pairs,blocked])
		var adiffs=0;var an=0;var ta_old=0;var ta_new=0
		for x in range(60,int(world.x)-60,90):
			for y in range(60,int(world.y)-60,90):
				var p=Vector2(x,y);var q=p+Vector2(280,140)
				at=Time.get_ticks_usec();var r1=old.arrivals(p,q,900.0);ta_old+=Time.get_ticks_usec()-at
				at=Time.get_ticks_usec();var r2=fast.arrivals(p,q,900.0);ta_new+=Time.get_ticks_usec()-at
				an+=1
				if var_to_str(r1)!=var_to_str(r2):adiffs+=1
		check(adiffs==0,"op %d arrivals() byte-identical on %d grid pairs"%[op,an])
		print("TIMING op %d configure old=%d us new=%d us | clear x%d old=%d us new=%d us | arrivals x%d old=%d us new=%d us (%.2fx)"%[op,t_old,t_new,pairs,tc_old,tc_new,an,ta_old,ta_new,float(ta_old)/maxf(1.0,ta_new)])
	# Grazing sweep (review finding): long segments passing a hair outside every polygon's bounding box edge, where
	# Godot's segment_intersects_segment tolerance can still report a hit. Old and new must agree for every offset.
	var graze_total:=0;var graze_diff:=0
	for op in [0,1,6,16]:
		var gs=Sim.new();gs.start(op,"endurance")
		for band in 3:
			var gpolys=gs.Depth.shapes(gs,band)
			var go=Oracle.new();var gf=Fast.new()
			go.configure(gpolys,gs.world_size(),[]);gf.configure(gpolys,gs.world_size(),[])
			var world=gs.world_size()
			for poly in gpolys:
				if poly.size()==0:continue
				var box:=Rect2(poly[0],Vector2.ZERO)
				for v in poly:box=box.expand(v)
				for d in [0.0005,0.002,0.01,0.04,0.2,0.9,1.5]:
					var segs=[[Vector2(box.position.x-d,0),Vector2(box.position.x-d,world.y)],[Vector2(box.end.x+d,0),Vector2(box.end.x+d,world.y)],[Vector2(0,box.position.y-d),Vector2(world.x,box.position.y-d)],[Vector2(0,box.end.y+d),Vector2(world.x,box.end.y+d)]]
					for sg in segs:
						graze_total+=1
						if go.clear(sg[0],sg[1])!=gf.clear(sg[0],sg[1]):graze_diff+=1
	check(graze_diff==0,"grazing segments identical on %d cases (%d differ)"%[graze_total,graze_diff])
	# Empty and single-polygon edge cases.
	var e_old=Oracle.new();var e_new=Fast.new()
	e_old.configure([],Vector2(1000,1000));e_new.configure([],Vector2(1000,1000))
	check(e_old.clear(Vector2(1,1),Vector2(900,900))==e_new.clear(Vector2(1,1),Vector2(900,900)),"no polygons stays clear")
	var tri=PackedVector2Array([Vector2(100,100),Vector2(300,100),Vector2(200,300)])
	e_old.configure([tri],Vector2(1000,1000));e_new.configure([tri],Vector2(1000,1000))
	for pair in [[Vector2(100,100),Vector2(50,50)],[Vector2(0,100),Vector2(100,100)],[Vector2(0,200),Vector2(150,200)],[Vector2(150,150),Vector2(160,160)],[Vector2(0,0),Vector2(99,99)],[Vector2(300,100),Vector2(400,100)],[Vector2(0,100),Vector2(400,100)]]:
		check(e_old.clear(pair[0],pair[1])==e_new.clear(pair[0],pair[1]),"edge case %s"%[pair])
	print("ACOUSTIC PATH CULL CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
