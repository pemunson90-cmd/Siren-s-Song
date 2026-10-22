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
 # The nearest edge may be full while another edge still has clear water.
 for x in range(ceili(safe.size.x/(h*.5))+1):
  for y in [safe.position.y,safe.end.y-h]:
   candidates.append(Rect2(Vector2(clampf(safe.position.x+x*h*.5,safe.position.x,safe.end.x-h),y),Vector2.ONE*h))
 for y in range(ceili(safe.size.y/(h*.5))+1):
  for x in [safe.position.x,safe.end.x-h]:
   candidates.append(Rect2(Vector2(x,clampf(safe.position.y+y*h*.5,safe.position.y,safe.end.y-h)),Vector2.ONE*h))
 for candidate in candidates:
  if safe.encloses(candidate) and not occupied.any(func(r):return r.intersects(candidate.grow(4))):return candidate
 return Rect2()
# Shared command-ring placement. Move the existing projection as one unit;
# its canonical centre still drives drawing, sector picking and button input.
static func command_center(anchor:Vector2,safe:Rect2,half:Vector2,protected:Array)->Vector2:
 var low=safe.position+half;var high=(safe.end-half).max(low)
 var desired=anchor.clamp(low,high);var best=desired;var distance=INF
 var xs=[low.x,desired.x,high.x];var ys=[low.y,desired.y,high.y]
 for rect in protected:
  xs.append(clampf(rect.position.x-half.x-8,low.x,high.x));xs.append(clampf(rect.end.x+half.x+8,low.x,high.x))
  ys.append(clampf(rect.position.y-half.y-8,low.y,high.y));ys.append(clampf(rect.end.y+half.y+8,low.y,high.y))
 for x in xs:
  for y in ys:
   var candidate=Vector2(x,y);var box=Rect2(candidate-half,half*2)
   if not safe.encloses(box) or protected.any(func(r):return r.intersects(box.grow(3))):continue
   var score=candidate.distance_squared_to(anchor)
   if score<distance:best=candidate;distance=score
 return best
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
