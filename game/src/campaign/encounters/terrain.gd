extends RefCounted
# Deterministic authored-terrain builders. Shapes are fixed data at build time;
# a layered list assigns each solid to the depth bands it actually occupies.
const ALL=[0,1,2]
# Irregular glassy solid around a centre. Same arguments always give the same shape.
static func shard(c:Vector2,r:float,sides:int=7,seed:int=0,rough:float=.3,stretch:Vector2=Vector2.ONE)->PackedVector2Array:
 var p=PackedVector2Array()
 for n in sides:
  var k=1.-rough+rough*(.5+.5*sin(seed*12.9898+n*78.233))
  p.append((c+Vector2.from_angle(TAU*n/sides+seed*.37)*r*k*stretch).round())
 return p
# A thick band traced along a gentle polyline; width may vary per point.
static func ridge(points:Array,width,seed:int=0)->PackedVector2Array:
 var left=[];var right=[]
 for n in points.size():
  var a:Vector2=points[maxi(0,n-1)];var b:Vector2=points[mini(points.size()-1,n+1)]
  var normal=(b-a).normalized().orthogonal()
  var w:float=(width[n] if width is Array else width)*.5*(1.+.18*sin(seed*3.1+n*1.7))
  left.append((points[n]+normal*w).round());right.push_front((points[n]-normal*w).round())
 return PackedVector2Array(left+right)
# Annular sector, used for crater rims and curved walls with deliberate breaches.
static func arc(c:Vector2,inner:float,outer:float,from:float,to:float,steps:int=6)->PackedVector2Array:
 var p=PackedVector2Array()
 for n in steps+1:p.append((c+Vector2.from_angle(lerpf(from,to,float(n)/steps))*outer).round())
 for n in range(steps,-1,-1):p.append((c+Vector2.from_angle(lerpf(from,to,float(n)/steps))*inner).round())
 return p
# Closed outline from explicit points, for hand-placed walls.
static func wall(points:Array)->PackedVector2Array:return PackedVector2Array(points)
# [[shape,bands],...] -> MIDDLE rocks plus explicit SHALLOW/DEEP geometry.
static func layers(entries:Array)->Dictionary:
 var bands={0:[],1:[],2:[]}
 for entry in entries:
  for band in entry[1]:bands[band].append(entry[0])
 return {"rocks":bands[1],"depth_geometry":{0:{"rocks":bands[0]},2:{"rocks":bands[2]}}}
static func apply(m:Dictionary,entries:Array)->void:
 var built=layers(entries);m.rocks=built.rocks;m.depth_geometry=built.depth_geometry
# Shared opening chart window for operations with earned terrain discovery.
static func seed_chart(m:Dictionary)->void:
 m["earned_terrain"]=true
 m["launch_seed"]=Rect2(m.start-Vector2(160,200),Vector2(480,480)).intersection(Rect2(Vector2.ONE*40,m.world_size-Vector2.ONE*80))
