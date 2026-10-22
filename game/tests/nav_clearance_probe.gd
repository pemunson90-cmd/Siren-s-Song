extends SceneTree
# Source-known diagnostic: independently measures planned line/terrain distances.
# No gameplay outcome or balance conclusions; --sweep expands the sampled endpoints.
const Sim=preload("res://src/simulation/simulation.gd")
var checks=0
var failures=0
func distance_to_segment(point,a,b):return point.distance_to(Geometry2D.get_closest_point_to_segment(point,a,b))
func leg_clearance(s,a,b):
 var dimensions=s.world_size()
 var margin=minf(minf(a.x,b.x),minf(a.y,b.y))
 margin=minf(margin,minf(dimensions.x-maxf(a.x,b.x),dimensions.y-maxf(a.y,b.y)))
 for polygon in s.Depth.shapes(s,1):
  var box=Rect2(polygon[0],Vector2.ZERO)
  for vertex in polygon:box=box.expand(vertex)
  for point in [a,b]:
   if box.grow(.001).has_point(point) and Geometry2D.is_point_in_polygon(point,polygon):return 0.
  for n in polygon.size():
   var first=polygon[n];var last=polygon[(n+1)%polygon.size()]
   if Geometry2D.segment_intersects_segment(a,b,first,last)!=null:return 0.
   margin=minf(margin,minf(minf(distance_to_segment(a,first,last),distance_to_segment(b,first,last)),minf(distance_to_segment(first,a,b),distance_to_segment(last,a,b))))
 return margin
func route_clearance(s,origin,route):
 var minimum=INF
 for node in route:
  minimum=minf(minimum,leg_clearance(s,origin,node.pos));origin=node.pos
 return minimum
func _initialize():
 var sweep="--sweep" in OS.get_cmdline_user_args()
 for operation in [0,1,3,4,5]:
  var s=Sim.new();s.start(operation);var origin=s.units[0].pos
  var endpoints=[s.mission.extraction]
  for target in s.mission.objectives:
   endpoints.append(target.pos+Vector2(0,210));endpoints.append(target.pos+Vector2(-210,0))
  if sweep:
   for y in range(80,int(s.world_size().y),80):
    for x in range(80,int(s.world_size().x),80):endpoints.append(Vector2(x,y))
  var accepted=0;var clipped=0;var tight=0;var minimum=INF
  for endpoint in endpoints:
   var route=s.player_path(origin,endpoint)
   if route.is_empty():continue
   accepted+=1;checks+=1
   var clearance=route_clearance(s,origin,route);minimum=minf(minimum,clearance)
   if clearance<12.-.001:
    clipped+=1;failures+=1
    if clipped<=3:printerr("CLIPPED ",operation," from=",origin," to=",endpoint," clearance=",clearance," route=",route)
   elif clearance<24.-.001:
    tight+=1
    if tight<=2:print("TIGHT ",operation," from=",origin," to=",endpoint," clearance=",clearance," route=",route)
  print("NAV PROBE op=",operation," accepted=",accepted," clipped=",clipped," below_planner_margin=",tight," minimum=",minimum)
 print("NAV CLEARANCE PROBE CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
