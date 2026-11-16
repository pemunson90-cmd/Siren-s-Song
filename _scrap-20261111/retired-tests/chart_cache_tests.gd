extends SceneTree
# WP-20 (A3): chart terrain is built once per chart generation and redrawn from
# a cache. This suite proves, without a screen, that the cached geometry matches
# the chart, that it is rebuilt exactly when something it depends on changes,
# and that turning the switch off takes the old per-cell path.
const Cache=preload("res://src/presentation/chart_cache/chart_geometry_cache.gd")
const EarnedChart=preload("res://src/presentation/earned_chart_view.gd")
const RegionArt=preload("res://src/presentation/art/region_renderer.gd")
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
var checks=0
var failures=0
class Canvas extends RefCounted:
	var rects=0
	var lines=0
	var meshes=0
	var multilines=0
	var widths:Array=[]
	func draw_rect(_r,_c,_f=true,_w=-1.):rects+=1
	func draw_line(_a,_b,_c,_w=-1.):lines+=1
	func draw_mesh(_m,_t):meshes+=1
	func draw_multiline(_p,_c,w=-1.):multilines+=1;widths.append(w)
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func chart(generation:int)->Dictionary:
	var clear=[]
	for y in 6:
		for x in 7:clear.append(Vector2i(x,y))
	return {"generation":generation,"cell_size":40.,"clear_cells":clear,"return_cells":[],"surface_segments":[PackedVector2Array([Vector2(10,10),Vector2(50,12)]),PackedVector2Array([Vector2(50,12),Vector2(60,90)]),PackedVector2Array([Vector2(1,1)]),PackedVector2Array([Vector2(0,5),Vector2(7,5),Vector2(9,9)])]}
func fill_color(_tile)->Color:return Color(.1,.2,.3,.7)
func _initialize():call_deferred("run")
func run():
	var view=Canvas.new()
	var data=chart(1)
	var cache=Cache.request(view,"t",data,[],fill_color)
	# (a) one quad per clear cell at the right rectangle, one entry per two-point segment.
	check(cache.quads.size()==data.clear_cells.size()*4,"one quad (4 vertices) per clear cell")
	check(cache.colors.size()==cache.quads.size(),"one colour per vertex")
	var rectangles_ok=true
	for i in data.clear_cells.size():
		var origin=Vector2(data.clear_cells[i])*40.
		var want=[origin,origin+Vector2(40,0),origin+Vector2(40,40),origin+Vector2(0,40)]
		for k in 4:
			if cache.quads[i*4+k]!=want[k]:rectangles_ok=false
	check(rectangles_ok,"every quad covers exactly its cell rectangle")
	check(cache.mesh!=null and cache.mesh.get_surface_count()==1,"cells are one mesh surface")
	check(cache.face_points.size()==4,"two-point surface segments only: 2 entries of 2 endpoints")
	check(cache.face_points[0]==Vector2(10,10) and cache.face_points[1]==Vector2(50,12) and cache.face_points[2]==Vector2(50,12) and cache.face_points[3]==Vector2(60,90),"segment endpoints unchanged")
	# (b) same generation returns the same object, no rebuild.
	var again=Cache.request(view,"t",chart(1),[],fill_color)
	check(again==cache and cache.rebuilds==1,"same generation: same cache object, one rebuild")
	for n in 5:Cache.request(view,"t",chart(1),[],fill_color)
	check(cache.rebuilds==1,"repeated requests never rebuild")
	# Zoom is not part of the key: widths are passed at draw time.
	var canvas=Canvas.new()
	EarnedChart.draw_terrain(canvas,chart(1),1.)
	EarnedChart.draw_terrain(canvas,chart(1),2.5)
	var earned_cache=canvas.get_meta(Cache.META)["earned"]
	check(earned_cache.rebuilds==1,"zoom change does not rebuild")
	check(is_equal_approx(canvas.widths[0],7.) and is_equal_approx(canvas.widths[2],7./2.5),"stone width is 7 world units at scale 1 and 7/scale after zoom")
	check(canvas.rects==0 and canvas.lines==0 and canvas.meshes==2 and canvas.multilines==4,"two frames: one mesh and two batched calls each, no per-cell calls")
	# (c) new generation, changed style, changed contrast rebuild.
	Cache.request(view,"t",chart(2),[],fill_color)
	check(cache.rebuilds==2,"new generation rebuilds")
	Cache.request(view,"t",chart(2),[Color.RED],fill_color)
	check(cache.rebuilds==3,"changed style rebuilds")
	var saved=Settings.current.get("high_contrast",false)
	Settings.current["high_contrast"]=not saved
	Cache.request(view,"t",chart(2),[Color.RED],fill_color)
	check(cache.rebuilds==4,"changed contrast setting rebuilds")
	Settings.current["high_contrast"]=saved
	Cache.request(view,"t",chart(2),[Color.RED],fill_color)
	check(cache.rebuilds==5,"restoring the contrast setting rebuilds again")
	var fewer=chart(2);fewer.clear_cells=fewer.clear_cells.slice(0,3)
	Cache.request(view,"t",fewer,[Color.RED],fill_color)
	check(cache.rebuilds==6 and cache.quads.size()==12,"same counter but different cells rebuilds")
	# Another dive on the same view: same generation, same counts, other cells and faces.
	var moved=chart(2);moved.clear_cells=moved.clear_cells.slice(0,3);moved.clear_cells[2]=Vector2i(30,20)
	Cache.request(view,"t",moved,[Color.RED],fill_color)
	check(cache.rebuilds==7 and cache.quads[8]==Vector2(1200,800),"same counter and counts but a different cell rebuilds")
	var bent=moved.duplicate(true);bent.surface_segments[0]=PackedVector2Array([Vector2(10,10),Vector2(55,12)])
	Cache.request(view,"t",bent,[Color.RED],fill_color)
	check(cache.rebuilds==8 and cache.face_points[1]==Vector2(55,12),"same counter and counts but a different rock face rebuilds")
	Cache.request(view,"t",bent.duplicate(true),[Color.RED],fill_color)
	check(cache.rebuilds==8,"an equal copy of the chart does not rebuild")
	# Region path: styled chart uses the cache too.
	var style={"floor":Color(.1,.2,.2),"stone":Color(.4,.5,.5),"edge":Color(.7,.8,.8)}
	var region=Canvas.new()
	RegionArt.chart_terrain(region,chart(3),1.,style)
	check(region.rects==0 and region.lines==0 and region.meshes==1 and region.multilines==2,"region chart draws from the cache")
	# (d) switch off: old per-cell path.
	Cache.enabled=false
	var old=Canvas.new()
	EarnedChart.draw_terrain(old,chart(1),1.)
	check(old.rects==42 and old.lines==4 and old.meshes==0 and old.multilines==0 and not old.has_meta(Cache.META),"ENABLED false: one rect per cell, two lines per face, no cache")
	var old_region=Canvas.new()
	RegionArt.chart_terrain(old_region,chart(3),1.,style)
	check(old_region.rects==42 and old_region.lines==4 and old_region.meshes==0,"ENABLED false: region path is the old one")
	Cache.enabled=true
	# A chart without a generation counter is never cached.
	var bare=Canvas.new()
	var no_gen=chart(1);no_gen.erase("generation")
	EarnedChart.draw_terrain(bare,no_gen,1.)
	check(bare.rects==42 and not bare.has_meta(Cache.META),"chart without a generation draws uncached")
	check(Cache.ENABLED==true,"switch constant ships on")
	print("CHART CACHE CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
