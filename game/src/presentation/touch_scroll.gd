extends RefCounted
# Explicit touch ownership for instrument scroll regions. A chart finger never
# transfers into a panel; a panel swipe cannot activate an underlying command.
var pointer=999
var start:=Vector2.ZERO
var previous:=Vector2.ZERO
var dragged=false
func feed(scroll:ScrollContainer,event:InputEvent,tap:Callable=Callable())->bool:
 if not scroll.is_visible_in_tree():pointer=999;return false
 if not (event is InputEventScreenTouch or event is InputEventScreenDrag or event is InputEventMouse):return false
 var inside=scroll.get_global_rect().has_point(event.position)
 if event is InputEventMouse and event.device==InputEvent.DEVICE_ID_EMULATION:return inside or pointer!=999
 var id=event.index if event is InputEventScreenTouch or event is InputEventScreenDrag else -1
 var press=(event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT)
 var release=(event is InputEventScreenTouch and not event.pressed) or (event is InputEventMouseButton and not event.pressed and event.button_index==MOUSE_BUTTON_LEFT)
 if press:
  if pointer!=999 or not inside:return false
  pointer=id;start=event.position;previous=start;dragged=false;return true
 if pointer!=id:return false
 if event is InputEventScreenTouch and event.canceled:pointer=999;return true
 if release:
  pointer=999
  if not dragged and inside and tap.is_valid():tap.call(start,event.position)
  return true
 if event is InputEventScreenDrag or event is InputEventMouseMotion:
  if start.distance_to(event.position)>preload("res://src/input/map_gesture.gd").threshold():dragged=true
  if dragged:scroll.scroll_vertical-=roundi(event.position.y-previous.y)
  previous=event.position;return true
 return false
