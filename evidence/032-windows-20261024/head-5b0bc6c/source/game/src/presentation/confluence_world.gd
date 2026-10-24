extends RefCounted
# Physical relief from the public chart only. An individual return never closes
# a rock mass: material stops at each measured segment's exact endpoints.
const BASALT=preload("res://assets/materials/basalt.png")
const FOUNDRY=preload("res://assets/structures/foundry.png")
const CYAN=Color("63c9cc")
const AMBER=Color("d1a15d")

static func draw_terrain(view,chart:Dictionary,scale:float,visible:Rect2=Rect2(-100000,-100000,200000,200000))->void:
 var cell=float(chart.get("cell_size",40.))
 for key in chart.get("clear_cells",[]):
  var rect=Rect2(Vector2(key)*cell,Vector2.ONE*cell)
  if not visible.intersects(rect):continue
  # Surveyed water has a physical sediment floor; these details have no route,
  # sensing or obstacle meaning and never enter an unmeasured neighbouring cell.
  var seed_value=absi(int(key.x)*73856093 ^ int(key.y)*19349663)
  var shade=float(seed_value%17)/17.
  view.draw_rect(rect,Color(.062+shade*.008,.148+shade*.018,.163+shade*.02,.88))
  if scale<.36:continue
  for n in 2:
   var y=rect.position.y+9.+n*15.+float(seed_value%5)
   var x=rect.position.x+5.+float(seed_value%7)
   view.draw_line(Vector2(x,y),Vector2(rect.end.x-5.,y-3.),Color(.19,.32,.33,.15),.8)
  if seed_value%5==0:
   var p=rect.get_center()+Vector2(float(seed_value%9)-4.,float((seed_value/9)%9)-4.)
   view.draw_colored_polygon(PackedVector2Array([p+Vector2(-3,1),p+Vector2(-1,-2),p+Vector2(3,-1),p+Vector2(4,2),p+Vector2(0,3)]),Color("263e40"))
 for face in chart.get("surface_segments",[]):
  if face.size()!=2 or not face[0].is_finite() or not face[1].is_finite():continue
  var a:Vector2=face[0];var b:Vector2=face[1]
  var bounds=Rect2(Vector2(minf(a.x,b.x),minf(a.y,b.y)),Vector2(absf(b.x-a.x),absf(b.y-a.y))).grow(24.)
  if not visible.intersects(bounds):continue
  var length=a.distance_to(b)
  if length<.001:continue
  var along=(b-a)/length
  # Consistently wound production polygons encode the inward side. Relief is
  # a shallow material edge, never a guessed roof or a hidden polygon fill.
  var inward=-along.orthogonal()
  var depth=18.
  var wall=PackedVector2Array([a,b,b+inward*depth,a+inward*depth])
  view.draw_colored_polygon(wall,Color("13292e"))
  var uv=PackedVector2Array()
  for p in wall:uv.append(p/150.)
  view.draw_polygon(wall,PackedColorArray([Color(.40,.54,.53)]),uv,BASALT)
  view.draw_line(a+inward*depth,b+inward*depth,Color("091a21"),2.)
  view.draw_line(a,b,Color("71918a"),1.7/maxf(.65,scale))
  if scale<.32:continue
  # Short transverse seams give columnar basalt a readable side/strata rhythm.
  for n in maxi(1,int(length/7.)):
   var at=(float(n)+.35)/maxi(1,int(length/7.))
   var p=a.lerp(b,at)
   view.draw_line(p+inward*2.,p+inward*(depth-2.),Color("0a1a21"),1.4)
   view.draw_line(p+along*1.6+inward*4.,p+along*1.6+inward*12.,Color(.35,.48,.46,.45),.8)
  view.draw_line(a+inward*7.,b+inward*7.,Color(.31,.41,.38,.42),.8)

static func draw_landmarks(view,context:Dictionary,scale:float)->void:
 for landmark in context.get("landmarks",[]):
  if not landmark is Dictionary or landmark.get("kind","")!="factory" or not landmark.get("rect") is Rect2:continue
  var rect:Rect2=landmark.rect
  if not rect.position.is_finite() or not rect.size.is_finite() or not rect.has_area():continue
  var faces=[];var measured=0.
  for face in context.get("surface_segments",[]):
   if face.size()!=2:continue
   var a:Vector2=face[0];var b:Vector2=face[1]
   if not rect.grow(.01).has_point(a) or not rect.grow(.01).has_point(b):continue
   var on_x=(is_equal_approx(a.x,rect.position.x) and is_equal_approx(b.x,rect.position.x)) or (is_equal_approx(a.x,rect.end.x) and is_equal_approx(b.x,rect.end.x))
   var on_y=(is_equal_approx(a.y,rect.position.y) and is_equal_approx(b.y,rect.position.y)) or (is_equal_approx(a.y,rect.end.y) and is_equal_approx(b.y,rect.end.y))
   if on_x or on_y:faces.append(face);measured+=a.distance_to(b)
  # A real finite survey can earn the whole manufactured boundary. Local
  # carrier discovery alone identifies industry, never its hidden footprint.
  if measured>=2.*(rect.size.x+rect.size.y)-.1:_factory(view,rect,scale)
  else:
   for face in faces:_factory_face(view,face,rect,scale)

static func _factory_face(view,face:PackedVector2Array,rect:Rect2,scale:float)->void:
 var a:Vector2=face[0];var b:Vector2=face[1]
 var inward=-a.direction_to(b).orthogonal()
 var points=PackedVector2Array([a,b,b+inward*18.,a+inward*18.])
 var uv=PackedVector2Array()
 for p in points:uv.append((p-rect.position)/rect.size)
 view.draw_colored_polygon(points,Color("253a3f"))
 view.draw_polygon(points,PackedColorArray([Color(.62,.78,.78)]),uv,FOUNDRY)
 var midpoint=a.lerp(b,.5)
 var bay=floori((midpoint.x-rect.position.x)/80.)+floori((midpoint.y-rect.position.y)/80.)
 var light=CYAN if bay%3==0 else AMBER
 view.draw_line(a+inward*2.,b+inward*2.,Color("557174"),2.)
 view.draw_line(a+inward*7.,b+inward*7.,Color(light,.75),1.5/maxf(.65,scale))
 view.draw_line(midpoint+inward*3.,midpoint+inward*16.,Color("0b1c24"),2.)
 if preload("res://src/presentation/art/art_table.gd").enabled:preload("res://src/presentation/art/art_renderer.gd").face(view,a,b,inward,scale)

static func _factory(view,r:Rect2,scale:float)->void:
 # Every buttress/light stays in the earned physical collision footprint.
 # The monumental mass gains identity from its architecture, never a UI halo.
 view.draw_rect(r,Color("0a1921"))
 var inset=minf(r.size.x,r.size.y)*.055
 var deck=r.grow(-inset)
 view.draw_rect(deck,Color("253b3f"))
 view.draw_texture_rect(FOUNDRY,deck,false,Color(.94,1.,1.))
 var bays=6
 for bay in bays:
  var x=deck.position.x+deck.size.x*(float(bay)+.08)/bays
  var width=deck.size.x*.025
  var tower=Rect2(x,deck.position.y,width,deck.size.y)
  view.draw_colored_polygon(PackedVector2Array([tower.position,tower.position+Vector2(width,0),tower.end,tower.end-Vector2(width*.7,0)]),Color("172b31"))
  view.draw_line(tower.position+Vector2(width*.14,inset),tower.position+Vector2(width*.14,tower.size.y-inset),Color("516363"),maxf(1.,width*.05))
  var tint=CYAN if bay in [0,3,5] else AMBER
  view.draw_line(tower.position+Vector2(width*.62,inset*1.6),tower.end-Vector2(width*.38,inset*1.6),Color(tint,.75),maxf(1.,width*.05))
  if scale>=.3:
   for row in 4:
    var p=tower.position+Vector2(width*.34,tower.size.y*(.18+row*.19))
    view.draw_line(p,p+Vector2(width*.42,0),Color("4b6060"),1.)
 for row in [.12,.82]:
  var y=deck.position.y+deck.size.y*row
  view.draw_line(Vector2(deck.position.x,y),Vector2(deck.end.x,y),Color("3a5054"),maxf(2.,inset*.20))
 var crown=deck.position+deck.size*Vector2(.25,.47)
 var radius=deck.size.y*.105
 view.draw_arc(crown,radius,-PI*.9,PI*.45,36,Color(AMBER,.65),maxf(1.,inset*.075))
 view.draw_circle(crown,radius*.15,Color("c7a265"))
 # Water-facing machinery is within the actual footprint, with no fictitious pier.
 for n in 8:
  var x=r.position.x+r.size.x*(.07+n*.12)
  var at=Vector2(x,r.end.y-inset*.55)
  view.draw_line(at-Vector2(0,inset*.3),at+Vector2(0,inset*.3),CYAN if n%3==0 else AMBER,maxf(1.5,inset*.13))

 if preload("res://src/presentation/art/art_table.gd").enabled:preload("res://src/presentation/art/art_renderer.gd").factory(view,r,scale)

static func draw_hunter(view,phase:float,shade:Color)->void:
 # A pointed articulated predator. Patrollers and sentinels retain the ray body.
 var spine=PackedVector2Array()
 for n in 10:
  var x=-58.+n*13.
  var tail_weight=1.-float(n)/9.
  spine.append(Vector2(x,sin(phase*1.9-n*.65)*8.*tail_weight))
 var hull=PackedVector2Array()
 for n in spine.size():
  var width=2.+sin(float(n)/9.*PI)*12.
  hull.append(spine[n]+Vector2(0,-width))
 hull.append(Vector2(66,0))
 for n in range(spine.size()-1,-1,-1):
  var width=2.+sin(float(n)/9.*PI)*12.
  hull.append(spine[n]+Vector2(0,width))
 view.draw_colored_polygon(hull,Color(.018,.034,.042,shade.a))
 view.draw_polyline(hull,Color(.31,.37,.39,shade.a),1.2,true)
 # The trailing length is a thin luminous filament, outside the compact hull.
 # It cannot read as a second large collision body or a new weapon reach.
 var tail=PackedVector2Array([spine[0],Vector2(-76,sin(phase*1.9+.7)*9.),Vector2(-93,sin(phase*1.9+1.5)*11.)])
 view.draw_polyline(tail,Color(.31,.42,.43,shade.a*.65),1.2,true)
 for side in [-1,1]:
  view.draw_colored_polygon(PackedVector2Array([Vector2(36,side*7),Vector2(-6,side*32),Vector2(-36,side*38),Vector2(-20,side*11)]),Color(.035,.055,.065,shade.a))
  view.draw_line(Vector2(27,side*10),Vector2(-27,side*33),Color(.57,.16,.10,shade.a),1.7)
 for n in range(2,9):
  var center:Vector2=spine[n]
  var width=3.+sin(float(n)/9.*PI)*9.
  view.draw_line(center+Vector2(-4,-width),center+Vector2(2,0),Color(.28,.37,.39,shade.a),1.2)
  view.draw_line(center+Vector2(2,0),center+Vector2(-4,width),Color(.17,.23,.26,shade.a),1.2)
 view.draw_polyline(PackedVector2Array([spine[1],spine[3],spine[5],Vector2(58,0)]),Color(.63,.12,.08,shade.a),2.,true)
 view.draw_line(Vector2(53,-3),Vector2(62,0),Color(.98,.30,.12,shade.a),2.)
 view.draw_circle(Vector2(60,0),2.8,Color(.99,.47,.22,shade.a))
