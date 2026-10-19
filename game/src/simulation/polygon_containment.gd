extends RefCounted
# Godot4.6.3 can report an outside point inside a distant polygon for particular
# float coordinates. Cache actual vertex bounds and reject the impossible case
# before that predicate; keep boundaries inclusive and all edge tests unchanged.
static func bounds_for(polygons:Array)->Array:
 var result=[]
 for polygon in polygons:
  var box=Rect2()
  if not polygon.is_empty():
   box=Rect2(polygon[0],Vector2.ZERO)
   for vertex in polygon:box=box.expand(vertex)
  result.append(box)
 return result
static func contains(point:Vector2,polygon:PackedVector2Array,box:Rect2)->bool:
 if polygon.is_empty() or point.x<box.position.x or point.y<box.position.y or point.x>box.end.x or point.y>box.end.y:return false
 return Geometry2D.is_point_in_polygon(point,polygon)
