extends RefCounted
# Only cached, eligible screen anchors enter this deterministic presentation layout.
static func layout(targets:Array,bounds:Rect2,touch:float,obstacles:Array) -> Array:
 var result=[];var ordered=targets.duplicate();ordered.sort_custom(func(a,b):return a.key<b.key)
 var gap=8.;var side=maxf(48,touch)
 for target in ordered:
  var centers=[]
  for ring in [1.,2.,3.]:
   for direction in [Vector2.RIGHT,Vector2.UP,Vector2.DOWN,Vector2.LEFT,Vector2(1,-1),Vector2(1,1),Vector2(-1,-1),Vector2(-1,1)]:centers.append(target.anchor+direction*(side*.75+gap)*ring)
  # Bounded fallback for an edge/obstacle cluster; never reduce a touch target.
  for y in range(int(bounds.position.y+side/2),int(bounds.end.y-side/2)+1,int(side+gap)):
   for x in range(int(bounds.position.x+side/2),int(bounds.end.x-side/2)+1,int(side+gap)):centers.append(Vector2(x,y))
  for center in centers:
   var box=Rect2(center-Vector2.ONE*side/2,Vector2.ONE*side)
   if not bounds.encloses(box):continue
   if obstacles.any(func(r):return r.intersects(box)):continue
   if result.any(func(a):return a.rect.grow(gap/2).intersects(box)):continue
   result.append({"key":target.key,"tag":target.tag,"anchor":target.anchor,"rect":box});break
 return result
