extends SceneTree
const T=preload("res://src/campaign/encounters/terrain.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func integral(p:PackedVector2Array)->bool:
 return p.size()>0 and Array(p).all(func(v):return v==v.round())
func run():
 var a=T.shard(Vector2(500,500),100.0,7,3)
 var b=T.shard(Vector2(500,500),100.0,7,3)
 check(a==b and a.size()==7,"shard is deterministic and has one vertex per side")
 check(a!=T.shard(Vector2(500,500),100.0,7,4),"shard seed changes the outline")
 check(integral(a),"shard vertices are rounded to whole pixels")
 var maxr=0.0
 for v in a:maxr=maxf(maxr,v.distance_to(Vector2(500,500)))
 check(maxr<=100.0+1.5,"shard never extends past its radius (rough 0.3)")
 var smooth=T.shard(Vector2.ZERO,80.0,6,1,0.0)
 check(smooth.size()==6 and Array(smooth).all(func(v):return absf(v.length()-80.0)<=1.0),"rough 0 gives a regular ring")
 var wide=T.shard(Vector2.ZERO,100.0,8,2,0.0,Vector2(2,1))
 var xs=Array(wide).map(func(v):return absf(v.x)).max();var ys=Array(wide).map(func(v):return absf(v.y)).max()
 check(xs>ys*1.5,"stretch widens the shard on x")
 # ridge: band along a polyline.
 var pts=[Vector2(0,0),Vector2(100,0),Vector2(200,0)]
 var r=T.ridge(pts,40.0)
 check(r.size()==6 and r==T.ridge(pts,40.0),"ridge outlines both sides of every point deterministically")
 var rv=T.ridge(pts,[20.0,60.0,20.0])
 check(rv.size()==6 and absf(rv[1].y)>absf(rv[0].y),"per-point width array makes the middle thicker")
 check(integral(r) and r!=T.ridge(pts,40.0,5),"ridge is rounded and seed dependent")
 # arc: annular sector, outer edge then inner edge reversed.
 var arc=T.arc(Vector2.ZERO,50.0,100.0,0.0,PI,6)
 check(arc.size()==14,"arc has 2*(steps+1) vertices")
 check(Array(arc.slice(0,7)).all(func(v):return absf(v.length()-100.0)<=1.0) and Array(arc.slice(7)).all(func(v):return absf(v.length()-50.0)<=1.0),"arc first half is the outer rim, second half the inner")
 check(arc[0]==Vector2(100,0) and arc[6].round()==Vector2(-100,0),"arc outer edge spans from to angles")
 check(T.arc(Vector2.ZERO,10,20,0,1,1).size()==4,"single step arc is a quad")
 check(T.wall([Vector2(0,0),Vector2(5,0),Vector2(5,5)]).size()==3,"wall copies explicit points")
 # layers: bands 0/1/2 sorted into rocks and depth geometry.
 var s1=T.wall([Vector2(0,0),Vector2(1,0),Vector2(1,1)]);var s2=T.shard(Vector2(9,9),5.0)
 var built=T.layers([[s1,[0,1]],[s2,T.ALL]])
 check(built.rocks.size()==2 and built.depth_geometry[0].rocks.size()==2 and built.depth_geometry[2].rocks.size()==1,"layers assign each solid to its bands")
 check(built.depth_geometry[2].rocks[0]==s2 and not built.depth_geometry[2].rocks.has(s1),"deep geometry holds only DEEP solids")
 var none=T.layers([])
 check(none.rocks.is_empty() and none.depth_geometry[0].rocks.is_empty() and none.depth_geometry[2].rocks.is_empty(),"no entries gives empty bands")
 var m={}
 T.apply(m,[[s1,[2]]])
 check(m.rocks.is_empty() and m.depth_geometry[2].rocks.size()==1,"apply writes rocks and depth geometry into the mission")
 print("TERRAIN CHECKS %d FAILURES %d"%[checks,failures])
 quit(1 if failures>0 else 0)
