extends SceneTree
# Losing this boundary would expose unseen geography or advance a failed dive.
class Canvas:
 extends RefCounted
 var vertices=[]
 var rectangles=[]
 func draw_rect(rect,_color,_filled=true,_width=-1):rectangles.append(rect)
 func draw_texture_rect(_texture,rect,_tile=false,_modulate=Color.WHITE,_transpose=false):rectangles.append(rect)
 func draw_colored_polygon(points,_color):vertices.append_array(points)
 func draw_polygon(points,_colors,_uvs=PackedVector2Array(),_texture=null):vertices.append_array(points)
 func draw_line(a,b,_color,_width=-1,_antialiased=false):vertices.append_array([a,b])
 func draw_polyline(points,_color,_width=-1,_antialiased=false):vertices.append_array(points)
 func draw_circle(p,r,_color,_filled=true,_width=-1,_antialiased=false):vertices.append_array([p-Vector2.ONE*r,p+Vector2.ONE*r])
 func draw_arc(p,r,_from,_to,_segments,_color,_width=-1,_antialiased=false):vertices.append_array([p-Vector2.ONE*r,p+Vector2.ONE*r])
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 var world=load("res://src/presentation/confluence_world.gd")
 check(world!=null,"Confluence renders observed physical relief")
 if world==null:finish();return
 var canvas=Canvas.new()
 world.draw_terrain(canvas,{"cell_size":40.,"clear_cells":[],"return_cells":[Vector2i(2,2)],"surface_segments":[]},1.)
 check(canvas.vertices.is_empty() and canvas.rectangles.is_empty(),"ambiguous returns never become solid rock")
 world.draw_terrain(canvas,{"clear_cells":[],"surface_segments":[PackedVector2Array([Vector2(100,100),Vector2(120,100)])]},1.)
 check(not canvas.vertices.is_empty(),"one observed patch receives physical material and strata")
 check(canvas.vertices.all(func(p):return p.x>=99.99 and p.x<=120.01 and absf(p.y-100)<=24.),"relief cannot connect or extrapolate beyond measured patch endpoints")
 var empty=Canvas.new()
 world.draw_landmarks(empty,{},1.)
 check(empty.vertices.is_empty() and empty.rectangles.is_empty(),"no earned landmark DTO draws no factory")
 var factory=Canvas.new();var footprint=Rect2(560,600,760,360)
 world.draw_landmarks(factory,{"landmarks":[{"kind":"factory","rect":footprint}]},1.)
 check(factory.vertices.is_empty() and factory.rectangles.is_empty(),"carrier identity alone cannot reveal an unobserved factory footprint")
 world.draw_landmarks(factory,{"landmarks":[{"kind":"factory","rect":footprint}],"surface_segments":[PackedVector2Array([Vector2(900,960),Vector2(880,960)])]},1.)
 check(not factory.vertices.is_empty() and factory.vertices.all(func(p):return footprint.grow(.01).has_point(p)) and factory.rectangles.all(func(r):return footprint.encloses(r)),"industrial relief stays inside its actual measured footprint face")
 var result=load("res://src/presentation/confluence_resolution.gd")
 check(result!=null,"Confluence has a distinct resolution scene")
 if result==null:finish();return
 check(result.recovery({"route":"","facts":{}},[]).is_empty(),"incomplete recovery cannot present a successful consequence")
 check(result.recovery({"route":"concealed","facts":{}},[]).is_empty(),"a route alone cannot invent a recovered living dispatch")
 var concealed=result.recovery({"route":"concealed","thread":"deep","service_opened":false,"facts":{"confluence_packet":"The living dispatch was recovered."}},[{"alive":true},{"alive":false},{"alive":true}])
 var overt=result.recovery({"route":"overt","thread":"shelf","service_opened":true,"facts":{"confluence_packet":"The living dispatch was recovered."}},[{"alive":true},{"alive":true},{"alive":true}])
 check(concealed.get("route")=="concealed" and "CONCEALED" in concealed.get("title",""),"concealed physical recovery is represented directly")
 check(overt.get("route")=="overt" and "WARNING" in overt.get("title",""),"overt physical recovery has a distinct consequence")
 check(concealed.get("drones",[])==[2] and overt.get("drones",[])==[1,2],"aftermath preserves actual surviving own craft")
 check(not "opened" in concealed.get("service","").to_lower() and "opened" in overt.get("service","").to_lower(),"service consequence follows the operated gate")
 check(concealed.get("facts",{})=={"confluence_packet":"The living dispatch was recovered."},"scene retains only the actually recovered facts")
 finish()
func finish():
 print("CONFLUENCE PRESENTATION CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
