extends SceneTree
const View=preload("res://src/presentation/earned_chart_view.gd")
const Ocean=preload("res://src/presentation/ocean_view.gd")
const Preview=preload("res://src/presentation/route_program_preview.gd")
const Sim=preload("res://src/simulation/simulation.gd")
class Canvas:
 extends RefCounted
 var rectangles=[]
 var lines=[]
 func draw_rect(rect,color):rectangles.append(rect)
 func draw_line(a,b,color,width):lines.append([a,b])
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 var canvas=Canvas.new()
 var face=PackedVector2Array([Vector2(100,100),Vector2(120,100)])
 View.draw_terrain(canvas,{"clear_cells":[],"return_cells":[Vector2i(2,2)],"surface_segments":[face]},1.)
 check(canvas.rectangles.is_empty() and canvas.lines.size()==2,"physical first face renders without artificial RETURN-cell silhouettes")
 var sim=Sim.new();sim.start(11);sim.command("route",{"point":Vector2(1800,1200)})
 check(not View.chart(sim).is_empty() and View.segments(sim,0).any(func(part):return not part.confirmed),"world and planner share earned terrain and tentative course")
 check(not View.status(sim,0).is_empty(),"charted course provides ordinary frontier/intent status")
 var ocean=Ocean.new();ocean.sim=sim;var preview=Preview.new();preview.sim=sim
 check(ocean.observable_sites()==sim.observable_sites() and preview.world_size()==sim.world_size(),"current public ocean and planner compose with Confluence")
 ocean.free();preview.free()
 print("V7 EARNED VIEW CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
