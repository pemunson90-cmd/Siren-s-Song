extends Control
# Public chart information only. Revert: remove goal_marker seams in ocean_view.gd.
const STYLE={"margin":16.,"height":42.,"width":210.,"font":16,"step":48.}
var ocean
var info:Dictionary={}
# PERF (behavior identical): the marker rectangle depends only on the ocean size, the screen
# direction to the goal and the blocked UI rectangles, so the ~60 candidate points are sorted and
# scanned only when one of those changes (the edge points are also cached per ocean size).
# Distance and text are still recomputed every frame, and redraw is requested only when the
# shown info changed. The old inline implementation is the oracle in tests/goal_bearing_cache_tests.gd.
var _key:Array=[]
var _placed:Variant=null
var _edge_size:=Vector2.ZERO
var _edge_free:=Rect2()
var _edges:Array=[]
func _init():mouse_filter=Control.MOUSE_FILTER_IGNORE
func _clear():
 if not info.is_empty():info.clear()
 hide()
func _process(_dt):
 if ocean==null or ocean.sim==null or not ocean.presenting_mission or not ocean.sim.outcome.is_empty():_clear();return
 var sim=ocean.sim;var goals=ocean.observable_sites().filter(func(site):return not site.get("captured",false) and not site.get("own_origin",false))
 if goals.is_empty():goals=sim.extraction_corridors()
 if goals.is_empty():_clear();return
 var goal=goals[0];var target=ocean.screen_position(goal.pos)
 var bounds=Rect2(Vector2.ONE*STYLE.margin,ocean.size-Vector2.ONE*STYLE.margin*2)
 if bounds.grow(-STYLE.height).has_point(target):_clear();return
 var direction=(target-ocean.size/2).normalized()
 var key:Array=[ocean.size,direction,ocean.ui_blocked_rects]
 if key!=_key:
  _key=[ocean.size,direction,ocean.ui_blocked_rects.duplicate()];_placed=_place(bounds,direction)
 if _placed==null:_clear();return
 var metres=sim.units[0].pos.distance_to(goal.pos)
 var fresh={"rect":_placed,"distance":metres,"target":goal.pos,"direction":direction,"text":("SEARCH" if goal.get("unknown",false) else "GOAL")+" · %dm"%roundi(metres)}
 var changed=info!=fresh or not visible
 info=fresh
 if changed:show();queue_redraw()
func _place(bounds:Rect2,direction:Vector2)->Variant:
 var half=Vector2(minf(STYLE.width,bounds.size.x),STYLE.height)/2
 var free=bounds.grow_individual(-half.x,-half.y,-half.x,-half.y)
 var distance=(free.size/2).x/maxf(absf(direction.x),.0001)
 distance=minf(distance,(free.size/2).y/maxf(absf(direction.y),.0001))
 var preferred=free.get_center()+direction*distance
 if _edge_size!=ocean.size or _edge_free!=free:
  _edge_size=ocean.size;_edge_free=free;_edges=[]
  for x in range(0,int(free.size.x)+1,int(STYLE.step)):
   _edges.append(Vector2(free.position.x+x,free.position.y));_edges.append(Vector2(free.position.x+x,free.end.y))
  for y in range(0,int(free.size.y)+1,int(STYLE.step)):
   _edges.append(Vector2(free.position.x,free.position.y+y));_edges.append(Vector2(free.end.x,free.position.y+y))
 var candidates=[preferred];candidates.append_array(_edges)
 candidates.sort_custom(func(a,b):return a.distance_squared_to(preferred)<b.distance_squared_to(preferred))
 for point in candidates:
  var rect=Rect2(point-half,half*2)
  if ocean.ui_blocked_rects.any(func(block):return block.intersects(rect.grow(4))):continue
  return rect
 return null
func _draw():
 if info.is_empty():return
 var r:Rect2=info.rect
 draw_rect(r,Color(.015,.05,.07,.96));draw_rect(r,Color("72d9d3"),false,1.)
 var center=r.position+Vector2(22,r.size.y/2);var d:Vector2=info.direction
 draw_line(center-d*10,center+d*10,Color("e9cb8c"),2.,true)
 draw_polyline(PackedVector2Array([center+d*10-d.rotated(.65)*8,center+d*10,center+d*10-d.rotated(-.65)*8]),Color("e9cb8c"),2.,true)
 draw_string(ThemeDB.fallback_font,r.position+Vector2(44,27),info.text,HORIZONTAL_ALIGNMENT_LEFT,-1,STYLE.font,Color("a8d9d5"))
