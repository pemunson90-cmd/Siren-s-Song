extends Control
signal point_chosen(point:Vector2)
var sim
var selected_goal=0
var presses:Dictionary={}
var dragged=false
var multi=false
func _ready():
 mouse_filter=Control.MOUSE_FILTER_STOP;clip_contents=true
func chart_rect() -> Rect2:
 var fitted=Vector2(1600,960)*minf(size.x/1600,size.y/960)
 return Rect2((size-fitted)/2,fitted)
func _gui_input(event):
 if event.device==InputEvent.DEVICE_ID_EMULATION:return
 var key=-1;var p=Vector2.ZERO;var down=false;var up=false
 if event is InputEventScreenTouch:
  key=event.index;p=event.position;down=event.pressed;up=not down
  if event.canceled:presses.clear();return
 elif event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
  p=event.position;down=event.pressed;up=not down
 elif event is InputEventScreenDrag:
  key=event.index;p=event.position
 elif event is InputEventMouseMotion:p=event.position
 else:return
 if down:
  if presses.is_empty():dragged=false;multi=false
  presses[key]=p
  if presses.size()>1:multi=true
 elif up and presses.has(key):
  var valid=not dragged and not multi and presses[key].distance_to(p)<14 and chart_rect().has_point(p)
  presses.erase(key)
  if valid:
   var chart=chart_rect();var world=(p-chart.position)/chart.size*Vector2(1600,960)
   point_chosen.emit(Vector2(clampf(world.x,24,1576),clampf(world.y,24,936)))
 elif presses.has(key) and presses[key].distance_to(p)>14:dragged=true
 accept_event()
func _draw():
 draw_rect(Rect2(Vector2.ZERO,size),Color("06131c"))
 if sim==null:return
 var chart=chart_rect();var scale=chart.size/Vector2(1600,960)
 draw_set_transform(chart.position)
 for cell in sim.known:
  var world=Vector2(cell)*40
  draw_rect(Rect2(world*scale,Vector2(40,40)*scale),Color("2b3b40") if sim.blocked(world+Vector2(20,20),0) else Color("102c36"))
 var u=sim.units[sim.selected];var previous:Vector2=u.pos*scale
 for node in u.route:
  var p:Vector2=node.pos*scale;draw_line(previous,p,Color("527f83"),1);previous=p
 var goals=sim.route_goals();var font=ThemeDB.fallback_font
 for n in goals.size():
  var goal=goals[n];var p:Vector2=goal.pos*scale
  var color=Color("88ded6") if goal.mode!="cruise" else Color("e2c586")
  draw_circle(p,8 if n==selected_goal else 5,color,false,2)
  draw_string(font,p+Vector2(10,0),str(n+1),HORIZONTAL_ALIGNMENT_LEFT,-1,16,color)
 draw_circle(u.pos*scale,5,Color.WHITE)
 draw_set_transform(Vector2.ZERO)
 draw_rect(chart,Color("40646b"),false,1)
