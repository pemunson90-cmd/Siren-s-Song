extends "res://tests/fix2_menu_ui_tests.gd"
# Route map on the cover screen (2520x1080) and the inner screen (2184x1968), normal and 150% text:
# every region has a soft area and its name (known or not), reward/risk tags are present only where the player knows the operation,
# nothing is clipped or overlaps, nodes stay tappable.
const Table=preload("res://src/campaign/route_map/route_graph_table.gd")
const Arcs=preload("res://src/campaign/arcs/arc_table.gd")
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const View=preload("res://src/presentation/route_map/route_map_view.gd")
const LATE={"version":2,"route":"deep","routes":["deep"],"facts":{"deep":"Recovered branch account","confluence_route":"concealed","glass_choice":"service","choir_choice":"bypass","choir_people":"landed","choir_plant":"reconnect"},"completed":[6,7,9,11,12,14,15,16,17,18,19,22,23,24,25,30,31,32,33,34],"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":"deep"}
var case_label=""
var label_fonts:Dictionary={}
var touch_override:float=0.
func check(ok,label):super.check(ok,label+" "+case_label)
func open_map(game):
 View.open(game);await settle();await settle()
 return game.get_node_or_null("RouteMapView")
# The text a node button needs must fit inside its box once padded and wrapped the way the button wraps it.
func text_fits(button):
 var size:int=button.get_theme_font_size("font_size");var font=button.get_theme_default_font()
 var inner=button.size-Vector2.ONE*2.*button.get_theme_stylebox("normal").get_margin(SIDE_LEFT)
 var need=font.get_multiline_string_size(button.text,HORIZONTAL_ALIGNMENT_LEFT,inner.x,size,-1,TextServer.BREAK_WORD_BOUND|TextServer.BREAK_MANDATORY)
 return need.y<=inner.y+1.
func judge(view,known_arcs):
 var board=view.board;var rects=[]
 # The board gets most of a short, wide screen (the key and arc lines stand in a column beside it); the key stays inside the screen.
 var screen:Rect2=Rect2(Vector2.ZERO,view.size)
 if view.size.x>=view.size.y*Table.VIEW.wide_ratio:
  check(view.chart.size.y>=view.size.y*.5,"the board's visible height is at least half the screen "+str([view.chart.size.y,view.size.y]))
  check(view.legend_pan.position.x+view.legend_pan.size.x<=view.chart.position.x,"the key column does not overlap the board")
 check(screen.encloses(Rect2(view.legend_pan.position,view.legend_pan.size)) and screen.encloses(Rect2(view.chart.position,view.chart.size)),"key and board lie inside the screen")
 check(view.legend.get_children().size()==1+Arcs.ARCS.size(),"the key and one line per arc are all present")
 for id in board.boxes:rects.append(["node %d"%id,board.boxes[id]])
 var names=board.regions.map(func(region):return region.text)
 check(names==Arcs.ARCS.map(func(arc):return arc.name),"every region is named once, known or not "+str(names))
 for region in board.regions:
  check(region.font_size>=Table.OVERVIEW.font_floor,"region name "+region.text+" is at least 14 px")
  var rect:Rect2=region.rect;var arc=Arcs.ARCS.filter(func(candidate):return candidate.name==region.text)[0]
  check(Rect2(Vector2.ZERO,board.size).encloses(rect) and Rect2(Vector2.ZERO,board.size).encloses(region.area),"region "+region.text+" lies on the board")
  check(region.reached==view.graph.nodes.any(func(row):return row.id in arc.ids and row.state in ["AVAILABLE","RECOVERED"]),"region "+region.text+" is drawn stronger only when it is in play")
  check((rect.position.y>=region.area.end.y if region.below else rect.end.y<=region.area.position.y) and rect.position.x>=region.area.position.x,"region name "+region.text+" sits above (or, in the overview, under) its area")
  for other in rects:
   check(not rect.intersects(other[1]),"region name "+region.text+" does not cover "+other[0])
   # The area surrounds its own operations and touches no other region's operation.
   check(region.area.encloses(other[1]) if int(other[0].split(" ")[1]) in arc.ids else not region.area.intersects(other[1]),"region area "+region.text+" holds "+other[0]+" only if it belongs to it")
  for second in board.regions:
   if second.text!=region.text:
    check(not rect.intersects(second.rect),"region names "+region.text+"/"+second.text+" do not overlap")
    check(not rect.intersects(second.area) and not region.area.intersects(second.area),"region "+region.text+" and area "+second.text+" do not overlap")
 for row in view.graph.nodes:
  if row.mark and view.zoom>=Table.OVERVIEW.compact_below:
   var arc=Arcs.for_operation(row.id)
   view._select(row.id)
   check(view.detail.text==Table.DETAIL.not_charted%arc.name and view.detail.text.begins_with(arc.name+":"),"a mark names its region when tapped: "+view.detail.text)
   break
 # The drawn buttons (not just their boxes) never overlap each other, and no region name lies under one.
 var drawn=[]
 for id in view.buttons:drawn.append([id,Rect2(view.buttons[id].position,view.buttons[id].size)])
 for index in drawn.size():
  for other in range(index+1,drawn.size()):
   check(not drawn[index][1].intersects(drawn[other][1]),"nodes %d and %d do not overlap %s %s"%[drawn[index][0],drawn[other][0],drawn[index][1],drawn[other][1]])
 for region in board.regions:
  for item in drawn:check(not region.rect.intersects(item[1]),"region name "+region.text+" is not under node %d"%item[0])
 for row in view.graph.nodes:
  var button=view.buttons[row.id]
  var look:bool=button.get_meta("look_only",false)
  check((button.size.x>=48. and button.size.y>=48.) or look,"node %d is tappable or the overview is look-only"%row.id)
  check(button.get_theme_font_size("font_size")>=Table.OVERVIEW.font_floor,"node %d text is at least 14 px"%row.id)
  check(text_fits(button),"node %d text fits its box"%row.id)
  check(row.can_open==not row.tag.is_empty(),"node %d tag only when the operation can be opened"%row.id)
  if row.mark:check(button.text==Table.MARK_GLYPH,"unknown node %d shows no tag or name"%row.id)
  if row.can_open and view.zoom>=Table.OVERVIEW.compact_below:
   # A tag line follows title and state when the operation has counted work or opens a route (the last operations open none).
   var tag:String=view.tag_text(row)
   check(button.text.contains(row.label) and button.text.split("\n").size()>=(3 if not tag.is_empty() else 2) and button.text.ends_with(tag),"node %d shows title, state and tag"%row.id)
   # The map never counts Sirens: the briefing does not, and the dive reveals them by sound.
   check(not tag.contains("Siren") and not row.tag.has("sirens"),"node %d tag does not count Sirens"%row.id)
# Fully zoomed out: the whole board lies inside the chart; a look-only node zooms in on the tapped one instead of opening a briefing.
func overview(view,shape):
 # Stepping down from the opening zoom (the way a player presses −): once the board fits the chart it lies wholly inside the visible area.
 for step in 12:
  view._zoom(-1);await settle();await settle()
  if view.board.size.x<=view.chart.size.x+.5 and view.board.size.y<=view.chart.size.y+.5:
   check(view.board.get_global_rect().end.x<=view.chart.get_global_rect().end.x+.5 and view.board.get_global_rect().position.x>=view.chart.get_global_rect().position.x-.5,"zoom %.2f: the board that fits is not scrolled off the side %s %s"%[view.zoom,view.board.get_global_rect(),view.chart.get_global_rect()])
 for step in 12:view._zoom(-1)
 await settle();await settle()
 check(view.zoom==view.zoom_floor and view.zoom_floor<Table.VIEW.zoom_start,"the chart zooms out below the opening zoom "+str(view.zoom))
 check(view.board.size.x<=view.chart.size.x+.5 and view.board.size.y<=view.chart.size.y+.5,"the whole board fits the chart "+str([view.board.size,view.chart.size,view.zoom,view.zoom_floor,view.size]))
 check(view.chart.get_h_scroll_bar().max_value<=view.chart.size.x+.5 or not view.chart.get_h_scroll_bar().visible,"no sideways scrolling at the overview")
 # The board's right and bottom edges, as drawn on the screen, lie inside the chart's visible area (a scroll bar must not take the width).
 var shown:Rect2=view.chart.get_global_rect();var drawn:Rect2=view.board.get_global_rect()
 check(drawn.end.x<=shown.end.x+.5 and drawn.end.x<=view.get_global_rect().end.x+.5 and drawn.end.y<=shown.end.y+.5,"the whole board is on screen at the overview "+str([drawn,shown,view.size]))
 check(not view.chart.get_v_scroll_bar().visible and not view.chart.get_h_scroll_bar().visible,"no scroll bar at the overview")
 check(view.board.size.y>=view.chart.size.y*.9,"the overview uses the chart's height "+str([view.board.size,view.chart.size]))
 view.call("_focus_current");await settle()
# A tap on a region (its name or its area) at the overview zooms in centred on that region, whichever region it is.
func region_tap(view):
 for index in [3,0,5]:
  var name:String=Arcs.ARCS[index].name
  for step in 12:view._zoom(-1)
  await settle();await settle()
  var region=view.board.regions.filter(func(candidate):return candidate.text==name)[0]
  check(view.tap_board(region.rect.get_center()),"a tap on the name "+name+" is taken")
  await settle();await settle()
  var fresh=view.board.regions.filter(func(candidate):return candidate.text==name)[0]
  var visible:Rect2=Rect2(Vector2(view.chart.scroll_horizontal,view.chart.scroll_vertical),view.chart.size)
  check(view.zoom>=Table.OVERVIEW.look_zoom and visible.has_point(fresh.area.get_center()),"the tap on "+name+" zooms in with that region in view "+str([visible,fresh.area]))
  var wanted:Vector2=fresh.area.get_center()-view.chart.size*.5
  var reachable:bool=wanted.x>=0. and wanted.y>=0. and wanted.x<=view.board.size.x-view.chart.size.x and wanted.y<=view.board.size.y-view.chart.size.y
  check(not reachable or visible.get_center().distance_to(fresh.area.get_center())<=2.,"the tap on "+name+" centres that region "+str([visible.get_center(),fresh.area.get_center()]))
# A real tap: a touch press and release through the viewport (with the emulated mouse a touch screen also sends), not a direct call.
func real_tap(point:Vector2)->void:
 for down in [true,false]:
  var touch=InputEventScreenTouch.new();touch.index=0;touch.position=point;touch.pressed=down;root.push_input(touch,true)
  var mouse=InputEventMouseButton.new();mouse.device=InputEvent.DEVICE_ID_EMULATION;mouse.position=point;mouse.button_index=MOUSE_BUTTON_LEFT;mouse.pressed=down;mouse.button_mask=MOUSE_BUTTON_MASK_LEFT if down else 0;root.push_input(mouse,true)
  await settle()
# The point to tap on a node: its centre, scrolled into the chart first.
func scroll_to_node(view,id:int)->Vector2:
 view._center_on(view.board.centers[id]);await settle();await settle()
 return view.buttons[id].get_global_rect().get_center()
# Real taps at several zooms: an available or recovered node opens its briefing wherever it is tappable, a locked node says what opens it.
func input_taps(view,fixture:String,shape):
 var zooms:Array=[1.,.7,.6,.5,view.zoom_floor]
 var base_text:String=Table.DETAIL.hint
 for z in zooms:
  view.zoom=clampf(z,view.zoom_floor,Table.VIEW.zoom_max);view._nodes(view._touch_height());await settle();await settle()
  var tappable:bool=view.buttons.values().all(func(button):return not button.get_meta("look_only",false))
  var wanted:Array=view.graph.nodes.filter(func(row):return row.can_open)
  var locked:Array=view.graph.nodes.filter(func(row):return row.state=="LOCKED" and not row.mark)
  if not tappable:
   check(view.buttons[wanted[0].id].get_meta("look_only",false) or view.buttons[wanted[0].id].size.x>=48.,"zoom %.2f: the node is look-only only when under the touch size"%view.zoom)
   continue
  if not locked.is_empty():
   var point=await scroll_to_node(view,locked[0].id)
   await real_tap(point)
   check(view.detail.text.contains("locked") and view.get_parent()!=null,"zoom %.2f: a real tap on a locked node says what opens it: %s"%[view.zoom,view.detail.text])
  var id:int=wanted[0].id
  var point=await scroll_to_node(view,id)
  var game=view.host;var shown_zoom:float=view.zoom
  await real_tap(point)
  await settle();await settle()
  check(game.screen!="route_map" and not is_instance_valid(view),"zoom %.2f: a real tap on available or recovered node %d opens its briefing (screen %s)"%[shown_zoom,id,game.screen])
  if not is_instance_valid(view) or game.screen!="route_map":
   game._show_campaign();await settle()
   view=await open_map(game)
   if view==null:return null
 return view
# A real tap on empty region area at the overview zooms on the region; the same tap away from the overview does not.
func input_region_tap(view):
 for step in 12:view._zoom(-1)
 await settle();await settle()
 var free:Vector2=Vector2.ZERO;var found:bool=false
 for region in view.board.regions:
  for fx in range(1,40):
   for fy in range(1,40):
    var probe:Vector2=region.area.position+region.area.size*Vector2(fx/40.,fy/40.)
    if view.board.boxes.values().all(func(box:Rect2):return not box.grow(2.).has_point(probe)):free=probe;found=true;break
   if found:break
  if found:break
 check(found,"an empty spot lies inside the region area at the overview")
 if not found:return
 var before:float=view.zoom
 view._center_on(free);await settle();await settle()
 await real_tap(view.board.get_global_transform()*free)
 await settle();await settle()
 check(view.zoom>before and view.host.screen=="route_map","a real tap on empty region area zooms on the region only "+str([before,view.zoom,view.host.screen,free,view.board.get_global_transform()*free,view.board.get_global_rect(),view.chart.get_global_rect()]))
func look_tap(view):
 var spots=view.buttons.values().filter(func(button):return button.get_meta("look_only",false))
 var look_at=Table.OVERVIEW.look_zoom
 if not spots.is_empty():
  check(view.detail.text==Table.DETAIL.look,"the overview says taps zoom in first: "+view.detail.text)
  var id:int=view.buttons.keys().filter(func(key):return view.buttons[key].get_meta("look_only",false)).front()
  view._select(id);await settle();await settle()
  check(view.get_parent()!=null and view.host.screen=="route_map" and view.zoom>=look_at,"a tap in the overview zooms in instead of opening a briefing")
  check(view.buttons.values().all(func(button):return button.size.x>=48. and button.size.y>=48.),"after zooming in every node is tappable")
func map_case(shape,scale):
 case_label=str([shape,scale,touch_override])
 root.size=shape;await settle()
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"))
 game.capture_scenario="runtime-test";game.store.path="user://routemap79-%d.save"%shape.x
 if shape.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
 root.add_child(game);await settle();game.set_process(false)
 var prior=Settings.text_scale();Settings.current["text_scale"]=scale;game._layout()
 # A phone's own touch height (the critic's inner screen drew 108 px buttons at 130%) replaces the desktop default when set.
 if touch_override>0.:game.ui_touch_height=touch_override
 game.active_started=false
 for fixture in ["fresh","late"]:
  case_label=str([shape,scale,fixture])
  game.completed=[] if fixture=="fresh" else [0,1,2,3,4,5];game.unlocked=0 if fixture=="fresh" else 5
  game.expedition={} if fixture=="fresh" else LATE.duplicate(true)
  game._show_campaign();await settle()
  var view=await open_map(game)
  check(view!=null,"route map opens")
  if view==null:continue
  var known=Arcs.ARCS.filter(func(arc):return view.graph.nodes.any(func(row):return row.id in arc.ids and row.label!="UNKNOWN"))
  check(fixture!="fresh" or known.map(func(arc):return arc.number)==[1],"a fresh profile names only the opening region")
  check(fixture!="late" or known.size()==6,"a late profile names every region")
  check(view.board.regions.size()==Arcs.ARCS.size(),"every region has an area even when it is not yet known")
  judge(view,known)
  # Node labels at the opening zoom follow the text size setting.
  var label_font:int=view.buttons[0].get_theme_font_size("font_size")
  if scale==1.:label_fonts[[shape,fixture]]=label_font
  elif label_fonts.has([shape,fixture]):check(label_font>label_fonts[[shape,fixture]],"node labels grow with the text size setting %d > %d"%[label_font,label_fonts[[shape,fixture]]])
  if fixture=="late":
   for step in 4:view._zoom(1)
   await settle();await settle()
   case_label=str([shape,scale,fixture,"zoom 2"])
   judge(view,known)
  view=await input_taps(view,fixture,shape)
  if view==null:continue
  await overview(view,shape)
  case_label=str([shape,scale,fixture,"overview"])
  judge(view,known)
  await input_region_tap(view)
  await region_tap(view)
  for step in 12:view._zoom(-1)
  await settle();await settle()
  await look_tap(view)
  await view._back();await settle()
 game.queue_free();await settle();Settings.current["text_scale"]=prior
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://routemap79-%d.save"%shape.x+suffix)
func run():
 for touch in [0.,108.]:
  touch_override=touch
  for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:
   for scale in [1.,1.3,1.5]:await map_case(shape,scale)
 print("ROUTE MAP LAYOUT CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
