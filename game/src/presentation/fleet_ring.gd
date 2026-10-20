extends RefCounted
# Screen-space own-craft instruments. These are status gauges, not acoustic ranges.
static func reserves(sim,id:int,oxygen_capacity:float)->Array:
 var rows=[{"label":"HULL","value":sim.hull,"capacity":100.},{"label":"O₂","value":sim.oxygen,"capacity":oxygen_capacity}] if id==0 else [{"label":"BAT","value":sim.units[id].battery,"capacity":100.}]
 for row in rows:
  row.fraction=clampf(row.value/maxf(1,row.capacity),0,1);row.critical=row.fraction<=.25
 return rows
static func edge_rect(anchor:Vector2,safe:Rect2,h:float,occupied:Array)->Rect2:
 var bearing=(anchor-safe.get_center()).normalized();var room=(safe.size-Vector2.ONE*h)/2
 var reach=minf(room.x/maxf(.001,absf(bearing.x)),room.y/maxf(.001,absf(bearing.y)))
 var desired=safe.get_center()+bearing*reach-Vector2.ONE*h/2
 var box=Rect2(desired.clamp(safe.position,safe.end-Vector2.ONE*h),Vector2.ONE*h)
 var horizontal=absf(box.position.y-safe.position.y)<1 or absf(box.end.y-safe.end.y)<1
 var candidates=[box]
 for step in range(1,ceili((safe.size.x if horizontal else safe.size.y)/(h*.5))):
  for side in [-1,1]:
   var delta=(Vector2.RIGHT if horizontal else Vector2.DOWN)*step*side*h*.5
   candidates.append(Rect2((box.position+delta).clamp(safe.position,safe.end-box.size),box.size))
 for candidate in candidates:
  if not occupied.any(func(r):return r.intersects(candidate.grow(4))):return candidate
 return box
static func draw_gauge(canvas:CanvasItem,center:Vector2,radius:float,rows:Array,selected:bool):
 var gap=.14;var width=3. if selected else 2.
 for i in rows.size():
  var row=rows[i];var start=-PI/2+i*TAU/rows.size()+gap;var length=TAU/rows.size()-gap*2
  var segments=16 if rows.size()==1 else 10
  for segment in segments:
   var a=start+length*segment/segments;var b=a+length/segments*.73
   var filled=(segment+.5)/segments<=row.fraction
   var color=Color("eaa779") if row.critical else Color("83d7ce") if i==0 else Color("83adc9")
   canvas.draw_arc(center,radius,a,b,5,color if filled else Color(.28,.46,.48,.38),width,true)
