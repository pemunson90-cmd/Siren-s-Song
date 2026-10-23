extends RefCounted
# Independent geometric measurement for NAV1 fixtures, not game navigation.
static func distance_to_segment(point,a,b):return point.distance_to(Geometry2D.get_closest_point_to_segment(point,a,b))
static func leg_clearance(s,a,b):
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
static func route_clearance(s,origin,route):
 var minimum=INF
 for node in route:
  minimum=minf(minimum,leg_clearance(s,origin,node.pos));origin=node.pos
 return minimum
