extends RefCounted
# Authored horizontal cold-water interface. This is a game-scale transmission
# approximation, not calibrated thermocline/refraction physics.
static func foundry() -> Array:
 return [{"area":Rect2(1000,780,320,120),"transmission":0.55,"close_range":120.0}]
static func valid_mission(mission:Dictionary)->bool:
 if not mission.has("thermal_revision") and not mission.has("thermal_fronts"):return true
 if mission.get("id",-1)!=3 or mission.get("acoustic_revision",0)!=1 or not mission.get("thermal_revision") is int or mission.thermal_revision!=1:return false
 var fronts=mission.get("thermal_fronts")
 if not fronts is Array or fronts.size()!=1:return false
 for front in fronts:
  if not front is Dictionary or not front.has_all(["area","transmission","close_range"]) or front.size()!=3:return false
  if not front.area is Rect2 or not front.area.position.is_finite() or not front.area.size.is_finite() or front.area.size.x<=0 or front.area.size.y<=0:return false
  if not Rect2(0,0,1600,960).encloses(front.area):return false
  for key in ["transmission","close_range"]:
   if not (front[key] is int or front[key] is float) or not is_finite(float(front[key])):return false
  if front.transmission<=0 or front.transmission>1 or front.close_range<0 or front.close_range>650:return false
 return true
static func inside(p:Vector2,area:Rect2)->bool:
 return p.x>area.position.x and p.x<area.end.x and p.y>area.position.y and p.y<area.end.y
static func at_distance(points:PackedVector2Array,distance:float)->Vector2:
 for i in points.size()-1:
  var length=points[i].distance_to(points[i+1])
  if distance<=length:return points[i].lerp(points[i+1],distance/maxf(0.00001,length))
  distance-=length
 return points[-1]
static func crossings(points:PackedVector2Array,area:Rect2)->int:
 var edges=[area.position,Vector2(area.end.x,area.position.y),area.end,Vector2(area.position.x,area.end.y)]
 var events:Array=[];var total=0.0
 for i in points.size()-1:
  var a=points[i];var b=points[i+1]
  for n in 4:
   var hit=Geometry2D.segment_intersects_segment(a,b,edges[n],edges[(n+1)%4])
   if hit!=null:events.append(total+a.distance_to(hit))
  total+=a.distance_to(b)
 events.sort();var last=-1.0;var count=0
 for event in events:
  if last>=0 and event-last<0.01:continue
  last=event
  # Sample along the entire polyline, not each segment: a tangent/corner touch
  # does not become two crossings when the path is subdivided there.
  var before=at_distance(points,maxf(0,event-0.05));var after=at_distance(points,minf(total,event+0.05))
  if inside(before,area)!=inside(after,area):count+=1
 return count
static func transmission(points:PackedVector2Array,fronts:Array)->float:
 if points.size()<2:return 1.0
 var result=1.0
 for front in fronts:
  if points[0].distance_to(points[-1])<front.close_range:continue
  result*=pow(front.transmission,crossings(points,front.area))
 return result
