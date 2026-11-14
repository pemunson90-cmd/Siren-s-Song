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
func check(ok,label):super.check(ok,label+" "+case_label)
func open_map(game):
 View.open(game);await settle();await settle()
 return game.get_node_or_null("RouteMapView")
# The text a node button needs must fit inside its box once padded and wrapped the way the button wraps it.
func text_fits(button):
 var size:int=button.get_theme_font_size("font_size");var font=button.get_theme_default_font()
 var inner=button.size-Vector2.ONE*2.*Table.VIEW.padding
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
  var rect:Rect2=region.rect;var arc=Arcs.ARCS.filter(func(candidate):return candidate.name==region.text)[0]
  check(Rect2(Vector2.ZERO,board.size).encloses(rect) and Rect2(Vector2.ZERO,board.size).encloses(region.area),"region "+region.text+" lies on the board")
  check(region.reached==view.graph.nodes.any(func(row):return row.id in arc.ids and row.state in ["AVAILABLE","RECOVERED"]),"region "+region.text+" is drawn stronger only when it is in play")
  check(rect.end.y<=region.area.position.y and rect.position.x>=region.area.position.x,"region name "+region.text+" sits above its area")
  for other in rects:
   check(not rect.intersects(other[1]),"region name "+region.text+" does not cover "+other[0])
   # The area surrounds its own operations and touches no other region's operation.
   check(region.area.encloses(other[1]) if int(other[0].split(" ")[1]) in arc.ids else not region.area.intersects(other[1]),"region area "+region.text+" holds "+other[0]+" only if it belongs to it")
  for second in board.regions:
   if second.text!=region.text:
    check(not rect.intersects(second.rect),"region names "+region.text+"/"+second.text+" do not overlap")
    check(not rect.intersects(second.area) and not region.area.intersects(second.area),"region "+region.text+" and area "+second.text+" do not overlap")
 for row in view.graph.nodes:
  if row.mark:
   var arc=Arcs.for_operation(row.id)
   view._select(row.id)
   check(view.detail.text==Table.DETAIL.not_charted%arc.name and view.detail.text.begins_with(arc.name+":"),"a mark names its region when tapped: "+view.detail.text)
   break
 for row in view.graph.nodes:
  var button=view.buttons[row.id]
  check(button.size.x>=48. and button.size.y>=48.,"node %d is tappable"%row.id)
  check(text_fits(button),"node %d text fits its box"%row.id)
  check(row.can_open==not row.tag.is_empty(),"node %d tag only when the operation can be opened"%row.id)
  if row.mark:check(button.text==Table.MARK_GLYPH,"unknown node %d shows no tag or name"%row.id)
  if row.can_open:
   # A tag line follows title and state when the operation has counted work or opens a route (the last operations open none).
   var tag:String=view.tag_text(row)
   check(button.text.contains(row.label) and button.text.split("\n").size()>=(3 if not tag.is_empty() else 2) and button.text.ends_with(tag),"node %d shows title, state and tag"%row.id)
   # The map never counts Sirens: the briefing does not, and the dive reveals them by sound.
   check(not tag.contains("Siren") and not row.tag.has("sirens"),"node %d tag does not count Sirens"%row.id)
func map_case(shape,scale):
 case_label=str([shape,scale])
 root.size=shape;await settle()
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"))
 game.capture_scenario="runtime-test";game.store.path="user://routemap79-%d.save"%shape.x
 if shape.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
 root.add_child(game);await settle();game.set_process(false)
 var prior=Settings.text_scale();Settings.current["text_scale"]=scale;game._layout()
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
  if fixture=="late":
   for step in 4:view._zoom(1)
   await settle();await settle()
   case_label=str([shape,scale,fixture,"zoom 2"])
   judge(view,known)
  await view._back();await settle()
 game.queue_free();await settle();Settings.current["text_scale"]=prior
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://routemap79-%d.save"%shape.x+suffix)
func run():
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  for scale in [1.,1.5]:await map_case(shape,scale)
 print("ROUTE MAP LAYOUT CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
