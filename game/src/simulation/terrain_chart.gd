extends RefCounted
# Only certified water and first physical returns enter this public authority.
# Hidden shapes are read exclusively by observe()/seed, never by player routing.
const TILE=40.0
const CLEARANCE=24.0
var dimensions=Vector2.ZERO
var clear_cells:Dictionary={}
var return_cells:Dictionary={}
var surface_segments:Array=[]
var generation=0
var _shapes:Array=[]
var _bounds:Array=[]
var _surface_keys:Dictionary={}
var _grid:AStarGrid2D
var _grid_generation=-1
func configure(mission:Dictionary,shapes:Array,saved:Dictionary={})->void:
 dimensions=mission.world_size
 _shapes=shapes.duplicate(true);_bounds=[]
 for polygon in _shapes:_bounds.append(_box(polygon))
 clear_cells={};return_cells={};surface_segments=[];_surface_keys={};generation=0;_grid_generation=-1
 if not saved.is_empty():
  clear_cells=saved.clear_cells.duplicate();return_cells=saved.return_cells.duplicate();surface_segments=saved.surface_segments.duplicate(true);generation=saved.generation
  for segment in surface_segments:_surface_keys[_segment_key(segment)]=true
  _build_grid();return
 var seed:Rect2=mission.launch_seed
 for cell in _cells(seed):
  var rect=_rect(cell)
  if seed.encloses(rect) and _water(rect.grow(CLEARANCE)):_clear(cell)
 _build_grid()
# A witnessed opening retires measurements of that physical door. It does not
# certify the water beyond it; live sensors still have to earn that water.
func open_structure(rect:Rect2,shapes:Array)->void:
 _shapes=shapes.duplicate(true);_bounds=[]
 for polygon in _shapes:_bounds.append(_box(polygon))
 for cell in return_cells.keys():
  if rect.grow(1).intersects(_rect(cell),true):return_cells.erase(cell)
 var retained=[];_surface_keys={}
 for segment in surface_segments:
  if rect.grow(1).has_point(segment[0]) and rect.grow(1).has_point(segment[1]):continue
  retained.append(segment);_surface_keys[_segment_key(segment)]=true
 surface_segments=retained;generation+=1;_grid_generation=-1
func snapshot()->Dictionary:
 return {"generation":generation,"clear_cells":clear_cells.duplicate(),"return_cells":return_cells.duplicate(),"surface_segments":surface_segments.duplicate(true)}
func public_chart()->Dictionary:
 return {"generation":generation,"cell_size":TILE,"world_size":dimensions,"clear_cells":clear_cells.keys(),"return_cells":return_cells.keys(),"surface_segments":surface_segments.duplicate(true)}
func observe(receivers:Array,survey:Dictionary)->void:
 for receiver in receivers:
  var origin:Vector2=receiver.pos;var radius:float=receiver.radius
  for cell in _cells(Rect2(origin-Vector2.ONE*radius,Vector2.ONE*radius*2)):
   if clear_cells.has(cell) or return_cells.has(cell):continue
   var rect=_rect(cell).grow(CLEARANCE)
   if _within(rect,origin,radius) and _water(rect) and _seen_rect(origin,rect):_clear(cell)
  _first_surfaces(origin,radius)
 if not survey.is_empty():
  var origin:Vector2=survey.pos;var radius:float=survey.radius
  for cell in _cells(Rect2(origin-Vector2.ONE*radius,Vector2.ONE*radius*2)):
   var rect=_rect(cell)
   if not _within(rect.grow(CLEARANCE),origin,radius):continue
   if _water(rect.grow(CLEARANCE)):_clear(cell)
   elif not _water(rect):_return(cell)
  # Survey can earn every actual face in the finite disk, including occluded faces.
  _first_surfaces(origin,radius,true)
func _first_surfaces(origin:Vector2,radius:float,survey:bool=false)->void:
 var disk=Rect2(origin-Vector2.ONE*radius,Vector2.ONE*radius*2)
 for i in _shapes.size():
  if not disk.intersects(_bounds[i],true):continue
  var polygon:PackedVector2Array=_shapes[i]
  for n in polygon.size():
   var a=polygon[n];var b=polygon[(n+1)%polygon.size()]
   var steps=maxi(1,int(ceil(a.distance_to(b)/20.0)))
   for step in steps:
    var first=a.lerp(b,float(step)/steps);var last=a.lerp(b,float(step+1)/steps)
    if first.distance_to(origin)>radius or last.distance_to(origin)>radius or not Rect2(Vector2.ZERO,dimensions).has_point(first) or not Rect2(Vector2.ZERO,dimensions).has_point(last):continue
    if not survey:
     var near_a=first.move_toward(origin,0.05);var near_b=last.move_toward(origin,0.05)
     var triangle=Geometry2D.convex_hull(PackedVector2Array([origin,near_a,near_b]))
     if not _unobstructed(triangle):continue
    var segment=PackedVector2Array([first,last]);var key=_segment_key(segment)
    if not _surface_keys.has(key):
     _surface_keys[key]=true;surface_segments.append(segment);generation+=1
    _return(Vector2i(first.lerp(last,0.5)/TILE))
func _segment_key(segment:PackedVector2Array)->String:
 return str(segment[0])+":"+str(segment[1])
func _clear(cell:Vector2i)->void:
 if return_cells.has(cell) or clear_cells.has(cell):return
 clear_cells[cell]=true;generation+=1
func _return(cell:Vector2i)->void:
 if not _inside(cell) or return_cells.has(cell):return
 clear_cells.erase(cell);return_cells[cell]=true;generation+=1
func _inside(cell:Vector2i)->bool:
 return cell.x>=0 and cell.y>=0 and cell.x<int(dimensions.x/TILE) and cell.y<int(dimensions.y/TILE)
func _rect(cell:Vector2i)->Rect2:
 return Rect2(Vector2(cell)*TILE,Vector2.ONE*TILE)
func _cells(rect:Rect2)->Array:
 var result=[];var low=Vector2i((rect.position/ TILE).floor());var high=Vector2i((rect.end/TILE).floor())
 for y in range(maxi(0,low.y),mini(int(dimensions.y/TILE),high.y+1)):
  for x in range(maxi(0,low.x),mini(int(dimensions.x/TILE),high.x+1)):result.append(Vector2i(x,y))
 return result
func _corners(rect:Rect2)->PackedVector2Array:
 return PackedVector2Array([rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)])
func _within(rect:Rect2,origin:Vector2,radius:float)->bool:
 for p in _corners(rect):
  if p.distance_squared_to(origin)>radius*radius:return false
 return true
func _water(rect:Rect2)->bool:
 if not Rect2(Vector2.ZERO,dimensions).encloses(rect):return false
 return _unobstructed(_corners(rect))
func _seen_rect(origin:Vector2,rect:Rect2)->bool:
 var points=_corners(rect);points.append(origin)
 return _unobstructed(Geometry2D.convex_hull(points))
func _unobstructed(polygon:PackedVector2Array)->bool:
 var box=_box(polygon)
 for i in _shapes.size():
  if box.intersects(_bounds[i],true) and _touches(polygon,_shapes[i]):return false
 return true
static func _box(polygon:PackedVector2Array)->Rect2:
 var result=Rect2(polygon[0],Vector2.ZERO)
 for point in polygon:result=result.expand(point)
 return result
static func _touches(a:PackedVector2Array,b:PackedVector2Array)->bool:
 if (_box(b).has_point(a[0]) and Geometry2D.is_point_in_polygon(a[0],b)) or (_box(a).has_point(b[0]) and Geometry2D.is_point_in_polygon(b[0],a)):return true
 for n in a.size():
  for k in b.size():
   if Geometry2D.segment_intersects_segment(a[n],a[(n+1)%a.size()],b[k],b[(k+1)%b.size()])!=null:return true
 return false
func is_clear(point:Vector2)->bool:
 return clear_cells.has(Vector2i((point/TILE).floor()))
# DDA boundaries give exact contiguous clear coverage; no skipped corner cell.
func clear_distance(a:Vector2,b:Vector2)->float:
 if not is_clear(a):return 0.0
 var delta=b-a;var length=delta.length()
 if length<0.00001:return 0.0
 var times=[0.0,1.0]
 for axis in 2:
  if absf(delta[axis])<0.00001:continue
  var low=int(floor(minf(a[axis],b[axis])/TILE));var high=int(ceil(maxf(a[axis],b[axis])/TILE))
  for value in range(low,high+1):
   var t=(value*TILE-a[axis])/delta[axis]
   if t>0 and t<1:times.append(t)
 times.sort()
 for n in range(times.size()-1):
  if not is_clear(a.lerp(b,(times[n]+times[n+1])*0.5)):return length*times[n]
 return length
func clear_disk(origin:Vector2,radius:float)->bool:
 if not Rect2(Vector2.ZERO,dimensions).encloses(Rect2(origin-Vector2.ONE*radius,Vector2.ONE*radius*2)):return false
 for cell in _cells(Rect2(origin-Vector2.ONE*radius,Vector2.ONE*radius*2)):
  var nearest=origin.clamp(_rect(cell).position,_rect(cell).end)
  if nearest.distance_squared_to(origin)<=radius*radius and not clear_cells.has(cell):return false
 return true
func point_blocked(point:Vector2,margin:float=CLEARANCE)->bool:
 if point.x<margin or point.y<margin or point.x>dimensions.x-margin or point.y>dimensions.y-margin:return true
 var cell=Vector2i((point/TILE).floor())
 if return_cells.has(cell):return true
 if clear_cells.has(cell):return false # Whole footprint already certifies24m.
 # A speculative cell touching a measured face lacks a certified hull corridor.
 # This is derived solely from public occupancy, never hidden geometry.
 for y in range(cell.y-1,cell.y+2):
  for x in range(cell.x-1,cell.x+2):
   if return_cells.has(Vector2i(x,y)):return true
 return false
func segment_safe(a:Vector2,b:Vector2,margin:float=CLEARANCE)->bool:
 if point_blocked(a,margin) or point_blocked(b,margin):return false
 var delta=b-a;var times=[0.0,1.0]
 for axis in 2:
  if absf(delta[axis])<0.00001:continue
  var low=int(floor(minf(a[axis],b[axis])/TILE));var high=int(ceil(maxf(a[axis],b[axis])/TILE))
  for value in range(low,high+1):
   var t=(value*TILE-a[axis])/delta[axis]
   if t>0 and t<1:times.append(t)
 times.sort()
 for n in range(times.size()-1):
  if point_blocked(a.lerp(b,(times[n]+times[n+1])*0.5),margin):return false
 return true
func _build_grid()->void:
 if _grid_generation==generation:return
 _grid=AStarGrid2D.new();_grid.region=Rect2i(Vector2i.ZERO,Vector2i(dimensions/TILE));_grid.cell_size=Vector2.ONE*TILE;_grid.offset=Vector2.ONE*TILE/2
 _grid.diagonal_mode=AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES;_grid.update()
 for y in int(dimensions.y/TILE):
  _grid.set_point_solid(Vector2i(0,y));_grid.set_point_solid(Vector2i(int(dimensions.x/TILE)-1,y))
 for x in int(dimensions.x/TILE):
  _grid.set_point_solid(Vector2i(x,0));_grid.set_point_solid(Vector2i(x,int(dimensions.y/TILE)-1))
 for cell in return_cells:
  for near in _cells(_rect(cell).grow(CLEARANCE+TILE)):
   if point_blocked(Vector2(near)*TILE+Vector2.ONE*TILE/2):_grid.set_point_solid(near,true)
 _grid_generation=generation
func player_path(a:Vector2,b:Vector2)->Array:
 if point_blocked(b):return []
 if segment_safe(a,b):return [{"pos":b,"stop":true}]
 _build_grid()
 var first=Vector2i((a/TILE).floor());var last=Vector2i((b/TILE).floor())
 if not _grid.is_in_boundsv(first) or not _grid.is_in_boundsv(last) or _grid.is_point_solid(first) or _grid.is_point_solid(last):return []
 var points=_grid.get_point_path(first,last);var raw:Array=[]
 for n in range(1,points.size()):raw.append(points[n])
 raw.append(b)
 var result=[];var origin=a;var at=0
 while at<raw.size():
  var furthest=-1
  for n in range(at,raw.size()):
   if segment_safe(origin,raw[n]):furthest=n
  if furthest<0:return []
  result.append({"pos":raw[furthest],"stop":furthest==raw.size()-1});origin=raw[furthest];at=furthest+1
 return result
static func valid_state(value,mission:Dictionary)->bool:
 if not value is Dictionary or value.size()!=4 or not value.has_all(["generation","clear_cells","return_cells","surface_segments"]):return false
 if not value.generation is int or value.generation<0:return false
 if not value.clear_cells is Dictionary or not value.return_cells is Dictionary or not value.surface_segments is Array or value.surface_segments.size()>16000:return false
 var dimensions:Vector2=mission.world_size;var grid=Vector2i(dimensions/TILE)
 if value.clear_cells.size()+value.return_cells.size()>grid.x*grid.y:return false
 for cells in [value.clear_cells,value.return_cells]:
  for cell in cells:
   if not cell is Vector2i or cell.x<0 or cell.y<0 or cell.x>=grid.x or cell.y>=grid.y or cells[cell]!=true:return false
 for cell in value.clear_cells:
  if value.return_cells.has(cell):return false
 for segment in value.surface_segments:
  if not segment is PackedVector2Array or segment.size()!=2:return false
  for point in segment:
   if not point.is_finite() or not Rect2(Vector2.ZERO,dimensions).grow(1).has_point(point):return false
  if segment[0].distance_to(segment[1])>20.01:return false
 return true
