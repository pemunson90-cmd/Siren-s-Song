extends SceneTree
# 118/121 integration: an off-centre subject must leave a valid trench even
# when only a few pixels remain beside it. No capture or grading inputs change.
const Subjects=preload("res://src/presentation/photo_subjects.gd")
var checks:=0
var failures:=0
func check(ok:bool,label:String)->void:
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
class Canvas extends Control:
	var contexts:Array=[]
	var drawn:=0
	func _draw()->void:
		for g in contexts:
			g.ci=self
			Subjects._trench(g,g.x)
			drawn+=1
func _initialize()->void:call_deferred("run")
func run()->void:
	var rect:=Rect2(10,20,300,180)
	var x:=rect.end.x-3.0;var base:=rect.position.y+rect.size.y*0.72;var s:=100.0
	var old:=PackedVector2Array([Vector2(x,base-s*0.06),Vector2(rect.end.x,base-s*0.08),rect.end,Vector2(x+s*0.1,rect.end.y)])
	check(Geometry2D.triangulate_polygon(old).is_empty(),"original near-edge trench reproduces crossed sides")
	var fixed:=Subjects.trench_polygon(rect,x,base,s)
	check(fixed.size()==4 and Geometry2D.triangulate_polygon(fixed).size()==6,"near-edge trench is a complete triangulatable quad")
	check(fixed[0]==old[0] and fixed[1]==old[1] and fixed[2]==old[2],"repair preserves trench lip and right edge")
	var ordinary_x:=100.0
	var ordinary:=PackedVector2Array([Vector2(ordinary_x,base-s*0.06),Vector2(rect.end.x,base-s*0.08),rect.end,Vector2(ordinary_x+s*0.1,rect.end.y)])
	check(Subjects.trench_polygon(rect,ordinary_x,base,s)==ordinary,"ordinary trench composition is byte-identical")
	for size in [Vector2.ZERO,Vector2(0,180),Vector2(300,0),Vector2(-1,180)]:
		check(Subjects.trench_polygon(Rect2(Vector2.ZERO,size),0,0,100).is_empty(),"empty or inverted drawing area skips trench")
	check(Subjects.trench_polygon(rect,x,base,0).is_empty(),"zero subject scale skips trench")
	check(Subjects.trench_polygon(rect,x,rect.end.y+10,100).is_empty(),"trench below image skips drawing")
	check(Subjects.trench_polygon(rect,rect.end.x-2,base,100).is_empty(),"existing two-pixel edge cutoff retained")
	var canvas:=Canvas.new();root.add_child(canvas)
	for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:
		root.size=shape;canvas.size=Vector2(shape);canvas.contexts.clear()
		for text_scale in [1.0,1.5]:
			# Wide archive and narrow dock contexts, including translated origins.
			for size in [Vector2(300,180),Vector2(190,480)*text_scale,Vector2(shape)*0.4]:
				var r:=Rect2(Vector2(17,23),size)
				var valid:=true;var unchanged:=true;var samples:=0
				for scale in [16.0,100.0,size.y*0.62]:
					for gap in [2.001,3.0,5.0,10.0,scale*0.1,scale*0.2,scale, size.x]:
						var left:float=r.end.x-maxf(2.001,gap);var floor_y:float=r.position.y+size.y*0.72
						var pts:=Subjects.trench_polygon(r,left,floor_y,scale)
						valid=valid and pts.size()==4 and Geometry2D.triangulate_polygon(pts).size()==6
						if pts.size()==4:
							valid=valid and pts[3].x<r.end.x and pts[3].x>=left
							if gap>=scale*0.2:unchanged=unchanged and is_equal_approx(pts[3].x,left+scale*0.1)
						canvas.contexts.append({"rect":r,"x":left,"base":floor_y,"s":scale,"al":1.0,"lit":1.0})
						samples+=1
				check(valid,"%s text %.1f rect %s: %d trenches triangulate"%[shape,text_scale,size,samples])
				check(unchanged,"%s text %.1f rect %s: ordinary slopes retained"%[shape,text_scale,size])
		canvas.drawn=0;canvas.queue_redraw()
		await process_frame;await process_frame
		check(canvas.drawn==canvas.contexts.size(),"native draw submits every trench on %s"%shape)
	canvas.queue_free();await process_frame
	print("PHOTO TRENCH GEOMETRY CHECKS ",checks," FAILURES ",failures)
	quit(1 if failures else 0)
