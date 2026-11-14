extends Control
# One seam: entry(host) in main._show_campaign. No progression or save writes.
# Revert with Table.enabled=false; the existing operations list remains intact.
const Graph=preload("res://src/campaign/route_map/route_graph.gd")
const Table=preload("res://src/campaign/route_map/route_graph_table.gd")
const Preferences=preload("res://src/presentation/frontend/frontend_settings.gd")
const OpsHome=preload("res://src/presentation/ops_home/ops_home.gd")
# A key of coloured samples (Table.KEY_ORDER, colours from Table.COLORS and MARK_COLOR); each arc then gets one line of counts.
const LEGEND_JOIN=" · "
const LEGEND_GAP=4
const LEGEND_LINE_PAD=4
class Board extends Control:
 const Palette=preload("res://src/campaign/route_map/route_graph_table.gd")
 var graph:Dictionary={}
 var centers:Dictionary={}
 var boxes:Dictionary={}
 # One entry per region: {"text","key" (tint),"rect" (the name's own area),"area" (the soft region behind its operations),"reached","font_size"}.
 var regions:Array=[]
 var stroke:float=Palette.VIEW.stroke
 func _draw():
  var font=get_theme_default_font()
  var look:Dictionary=Palette.REGION_AREA
  for region in regions:
   var tint=Color(Palette.REGION_TINTS[region.key])
   var style=StyleBoxFlat.new();style.set_corner_radius_all(look.corner);style.set_border_width_all(1)
   style.bg_color=Color(tint,look.fill if region.reached else look.fill_dim);style.border_color=Color(tint,look.line if region.reached else look.line_dim)
   draw_style_box(style,region.area)
  for region in regions:
   var name_color:=Color(Palette.REGION_COLOR);name_color.a=1. if region.reached else look.name_dim
   draw_string(font,region.rect.position+Vector2(0,font.get_ascent(region.font_size)),region.text,HORIZONTAL_ALIGNMENT_LEFT,-1,region.font_size,name_color)
  for edge in graph.get("edges",[]):draw_line(centers[edge.from],centers[edge.to],Color(Palette.THEME.edge),stroke,true)
  for edge in graph.get("rumors",[]):draw_dashed_line(centers[edge.from],centers[edge.to],Color(Palette.COLORS["KNOWN FROM PHOTOS"]),stroke,Palette.VIEW.line_dash,true)
  for row in graph.get("nodes",[]):
   var rect:Rect2=boxes[row.id];var color=Color(Palette.MARK_COLOR if row.mark else Palette.COLORS[row.state])
   if row.state=="KNOWN FROM PHOTOS":
    for side in [[rect.position,Vector2(rect.end.x,rect.position.y)],[Vector2(rect.end.x,rect.position.y),rect.end],[rect.end,Vector2(rect.position.x,rect.end.y)],[Vector2(rect.position.x,rect.end.y),rect.position]]:draw_dashed_line(side[0],side[1],color,stroke,Palette.VIEW.node_dash,true)
   else:draw_rect(rect,color,false,stroke)
var host
var graph:Dictionary={}
var buttons:Dictionary={}
var chart:ScrollContainer
var board:Board
var header:HBoxContainer
var legend:VBoxContainer
var legend_pan:ScrollContainer
var key:HFlowContainer
var legend_button:Button
var legend_open:bool=false	# WP-116: folded by default so the chart gets the room
var detail:Label
var zoom:float=Table.VIEW.zoom_start
var zoom_floor:float=Table.VIEW.zoom_start
var fitted_size=Vector2.ZERO
var fitted_touch=0.
var fitted_scale=0.
var shown_scroll:=Vector2i(-1,-1)	# the scroll the last zoom set
var focus:Vector2=Vector2(.5,.5)	# WP-111: where the player is looking, as a fraction of the board
static func entry(main)->void:
 if Table.enabled:main._button(main.panel_box,"ROUTE MAP",func():open(main),"route_map")
static func open(main)->void:
 if not Table.enabled:return
 main._clear_menu();main.menu.hide();main.screen="route_map"
 var view=load("res://src/presentation/route_map/route_map_view.gd").new();view.name="RouteMapView";main.add_child(view);view.setup(main)
func setup(main)->void:
 host=main;set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);mouse_filter=Control.MOUSE_FILTER_STOP
 graph=Graph.build(host.completed,host.expedition,host.photo_intel,host.unlocked)
 header=HBoxContainer.new();header.add_theme_constant_override("separation",Table.VIEW.header_gap);add_child(header)
 _button(header,"BACK",_back,"route_map_back",Table.VIEW.back_width)
 var title=Label.new();title.text="ROUTE MAP";title.size_flags_horizontal=Control.SIZE_EXPAND_FILL;header.add_child(title)
 legend_button=_button(header,Table.VIEW.legend_label,_toggle_legend,"route_map_legend",Table.VIEW.legend_width) # WP-116: the legend opens on demand
 _button(header,"CURRENT",_focus_current,"route_map_current",Table.VIEW.current_width)
 _button(header,"−",func():_zoom(-1),"route_map_zoom_out")
 _button(header,"+",func():_zoom(1),"route_map_zoom_in")
 # The key and arc lines sit in a pan: a column beside the board on a wide screen (scrolls if the text is large), a strip above it otherwise.
 legend_pan=ScrollContainer.new();legend_pan.name="LegendPan";legend_pan.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;add_child(legend_pan)
 legend=VBoxContainer.new();legend.add_theme_constant_override("separation",LEGEND_GAP);legend_pan.add_child(legend)
 _build_key()
 var arcs=preload("res://src/campaign/arcs/arc_table.gd")
 if arcs.enabled:
  for arc in arcs.ARCS:
   var states=[OpsHome.plain_arc_heading(arc,host._campaign_completed())]
   for state in ["AVAILABLE","LOCKED","KNOWN FROM PHOTOS"]:
    var count=graph.nodes.filter(func(row):return row.id in arc.ids and row.state==state).size()
    if count>0:states.append("%d %s"%[count,state.to_lower()])
   var summary=Label.new();summary.text=LEGEND_JOIN.join(states);summary.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;legend.add_child(summary)
 chart=ScrollContainer.new();chart.name="ChartPan";add_child(chart)
 board=Board.new();board.mouse_filter=Control.MOUSE_FILTER_PASS;board.graph=graph;board.gui_input.connect(_board_input);chart.add_child(board)
 detail=Label.new();detail.text=Table.DETAIL.hint;detail.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;add_child(detail)
 _fit()
 call_deferred("_focus_current")
func _toggle_legend()->void: # WP-116
 legend_open=not legend_open;_remember_focus();_fit();_show_focus()
func _key_color(name:String)->Color:return Color(Table.MARK_COLOR if name==Table.NOT_CHARTED else Table.COLORS[name])
func _build_key():
 key=HFlowContainer.new();key.add_theme_constant_override("h_separation",Table.KEY_SWATCH.item_gap);key.add_theme_constant_override("v_separation",LEGEND_GAP);legend.add_child(key)
 for name in Table.KEY_ORDER:
  var item=HBoxContainer.new();item.add_theme_constant_override("separation",Table.KEY_SWATCH.gap);item.name="Key"+name.replace(" ","");key.add_child(item)
  var sample=Label.new();sample.text=Table.MARK_GLYPH if name==Table.NOT_CHARTED else "■";sample.add_theme_color_override("font_color",_key_color(name));item.add_child(sample)
  var word=Label.new();word.text=name;item.add_child(word)
# Measured the way the flow wraps: items fill a line until the next one would pass the width.
func _key_height(h:float,width:float)->float:
 var font_size:=_font(h,Table.KEY_SWATCH.font);var lines:=1;var used:=0.
 var font=key.get_theme_default_font()
 for name in Table.KEY_ORDER:
  var item_width:float=font.get_string_size("■ "+name,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x+Table.KEY_SWATCH.gap
  if used>0 and used+item_width>width:
   lines+=1;used=0.
  used+=item_width+Table.KEY_SWATCH.item_gap
 for label in key.find_children("*","Label",true,false):label.add_theme_font_size_override("font_size",font_size)
 return lines*(font.get_height(font_size)+Table.KEY_SWATCH.line_pad)+(lines-1)*LEGEND_GAP
func _button(parent,text,action,id,width=1.)->Button:
 var button=Button.new();button.text=text;button.focus_mode=Control.FOCUS_NONE;button.set_meta("ui_action",id);button.set_meta("width_touch",width);button.pressed.connect(action,CONNECT_DEFERRED);parent.add_child(button);return button
func _process(_delta):
 if host==null:return
 if host.screen!="route_map":_dismiss();return
 if not Table.enabled:_back();return
 if fitted_size!=size or fitted_touch!=host.ui_touch_height or fitted_scale!=Preferences.text_scale():_fit()
func _draw():draw_rect(Rect2(Vector2.ZERO,size),Color(Table.THEME.background))
func _touch_height()->float:return maxf(Table.VIEW.min_target,host.ui_touch_height)*Preferences.text_scale()
func _font(h:float,factor:float)->int:return roundi(maxf(Table.VIEW.font_min*Preferences.text_scale(),h*factor))
func _fit():
 fitted_size=size;fitted_touch=host.ui_touch_height;fitted_scale=Preferences.text_scale()
 var h=_touch_height();var margin=Table.VIEW.margin
 header.position=Vector2(margin,margin);header.size=Vector2(size.x-margin*2,h)
 for control in header.get_children():
  control.add_theme_font_size_override("font_size",_font(h,Table.VIEW.header_font))
  if control is Button:control.custom_minimum_size=Vector2(h*control.get_meta("width_touch"),h)
 # The legend takes the height its wrapped lines need (measured, so nothing is cut); the chart gets the rest.
 var full:float=size.x-margin*2
 var wide:bool=size.x>=size.y*Table.VIEW.wide_ratio
 var width:float=roundf(full*Table.VIEW.column_share) if wide else full
 var legend_height:float=_key_height(h,width)+LEGEND_GAP
 key.custom_minimum_size.x=width
 for label in legend.get_children().filter(func(node):return node is Label):
  var font_size:=_font(h,Table.VIEW.legend_font);label.add_theme_font_size_override("font_size",font_size)
  label.custom_minimum_size.x=width
  legend_height+=label.get_theme_font("font").get_multiline_string_size(label.text,HORIZONTAL_ALIGNMENT_LEFT,width,font_size,-1,TextServer.BREAK_WORD_BOUND|TextServer.BREAK_MANDATORY).y+LEGEND_LINE_PAD+LEGEND_GAP
 legend.custom_minimum_size=Vector2(width,legend_height)
 var top:float=h+margin*2
 var bottom:float=h+margin*2
 legend_button.text=Table.VIEW.legend_open_label if legend_open else Table.VIEW.legend_label
 legend_pan.visible=legend_open
 if not legend_open:
  # WP-116: folded, the chart takes the whole width (and, on a narrow screen, the strip's height).
  legend_pan.position=Vector2(margin,top);legend_pan.size=Vector2.ZERO
  chart.position=Vector2(margin,top);chart.size=Vector2(full,maxf(h,size.y-top-bottom))
 elif wide:
  # Beside the board: the column takes what its lines need up to the board's height and scrolls past that.
  var room:float=maxf(h,size.y-top-bottom)
  legend_pan.position=Vector2(margin,top);legend_pan.size=Vector2(width,minf(legend_height,room))
  chart.position=Vector2(margin*2+width,top);chart.size=Vector2(full-width-margin,room)
 else:
  legend_pan.position=Vector2(margin,h+margin);legend_pan.size=Vector2(width,legend_height)
  chart.position=Vector2(margin,legend_pan.position.y+legend_height+margin)
  chart.size=Vector2(width,maxf(h,size.y-chart.position.y-bottom))
 detail.add_theme_font_size_override("font_size",_font(h,Table.VIEW.detail_font));detail.position=Vector2(margin,chart.position.y+chart.size.y+margin);detail.size=Vector2(size.x-margin*2,h)
 # Wrapped Label minimum height is recomputed after its width/font changes.
 # Apply the bounded height after that deferred update, including first layout.
 detail.set_deferred("size",Vector2(size.x-margin*2,h))
 zoom_floor=_fit_zoom(h);zoom=clampf(zoom,zoom_floor,Table.VIEW.zoom_max)
 _nodes(h);queue_redraw()
# Sizes at one zoom: the same numbers lay out the nodes and measure the board, so the overview fit and the drawn board agree.
func _metrics(h:float,z:float)->Dictionary:
 var node_size:Vector2=Vector2(h*Table.VIEW.width_touch,h*Table.VIEW.height_tagged)*z
 var gap:float=h*Table.VIEW.gap_touch*z;var area_pad:float=h*Table.REGION_AREA.pad*z;var margin:float=Table.VIEW.margin
 # In the overview the gaps are thin: lines and region padding shrink with them so areas never reach a neighbour's node.
 var stroke:float=maxf(1.,minf(Table.VIEW.stroke,gap*Table.OVERVIEW.stroke_share))
 if z<Table.OVERVIEW.compact_below:area_pad=minf(area_pad,gap*Table.OVERVIEW.pad_share)
 var region_size:int=maxi(Table.OVERVIEW.font_floor,roundi(_font(h,Table.VIEW.region_font)*z))
 var band:float=board.get_theme_default_font().get_height(region_size)+Table.VIEW.region_pad+area_pad
 var far:Vector2=Vector2.ZERO
 for row in graph.nodes:far=far.max(row.position)
 var pitch:Vector2=node_size+Vector2(gap,gap)
 var origin:Vector2=Vector2(margin+area_pad,margin+band)
 var foot:float=(band-area_pad) if z<Table.OVERVIEW.compact_below else 0.
 var tail:Vector2=Vector2(margin+area_pad,margin+area_pad+foot)
 # In the overview the width sets the zoom, so the rows take the chart's free height: the gap between rows grows (never past
 # row_stretch node heights), which keeps crowded columns apart and uses the board area.
 if z<Table.OVERVIEW.compact_below and far.y>0.:
  var free:float=chart.size.y*Table.OVERVIEW.fit_slack-(origin.y+far.y*pitch.y+node_size.y+tail.y)
  pitch.y+=clampf(free/far.y,0.,node_size.y*Table.OVERVIEW.row_stretch)
 return {"stroke":stroke,"node_size":node_size,"region_size":region_size,"area_pad":area_pad,"origin":origin,"pitch":pitch,"extent":origin+far*pitch+node_size+tail}
# The smallest zoom: the whole board inside the chart, or zoom_start when it already fits at that zoom.
func _fit_zoom(h:float)->float:
 var z:float=Table.VIEW.zoom_start
 for step in 6:
  var extent:Vector2=_metrics(h,z)["extent"]
  var ratio:float=minf(chart.size.x/extent.x,chart.size.y/extent.y)
  if ratio>=1. and z>=Table.VIEW.zoom_start:return Table.VIEW.zoom_start
  z=clampf(z*ratio*Table.OVERVIEW.fit_slack,Table.OVERVIEW.zoom_floor,Table.VIEW.zoom_start)
 # The fit is not exactly linear (padding, text floors), so check the result and keep shrinking until the board really fits
 # the chart's visible area: the width left after a scroll bar the board would otherwise need, and the height.
 for step in Table.OVERVIEW.fit_guard_steps:
  var extent:Vector2=_metrics(h,z)["extent"]
  var room:Vector2=chart.size-Vector2(chart.get_v_scroll_bar().get_combined_minimum_size().x if extent.y>chart.size.y else 0.,0.)
  if (extent.x<=room.x and extent.y<=room.y) or z<=Table.OVERVIEW.zoom_floor:break
  z=maxf(Table.OVERVIEW.zoom_floor,z*Table.OVERVIEW.fit_guard_shrink)
 return z
func _look_only(node_size:Vector2)->bool:return minf(node_size.x,node_size.y)<Table.OVERVIEW.min_target
func _nodes(h):
 for child in board.get_children():board.remove_child(child);child.queue_free()
 buttons.clear();board.centers.clear();board.boxes.clear()
 var m:Dictionary=_metrics(h,zoom);var node_size:Vector2=m.node_size;var area_pad:float=m.area_pad;var origin:Vector2=m.origin;var region_size:int=m.region_size
 var stroke:float=m.stroke;board.stroke=stroke
 var pitch:Vector2=m.pitch;var font=board.get_theme_default_font()
 var compact:bool=zoom<Table.OVERVIEW.compact_below;var look:bool=_look_only(node_size)
 var node_font:int=maxi(Table.OVERVIEW.font_floor,roundi(_font(h,Table.VIEW.font_touch)*zoom))
 for row in graph.nodes:
  var point:Vector2=row.position*pitch+origin
  var id:int=row.id
  # A node not yet charted is a small mark centred where its box would be; every node takes the tap.
  var cell:Vector2=Vector2.ONE*minf(node_size.x,node_size.y) if row.mark else node_size
  var spot:Vector2=point+(node_size-cell)*.5
  var button=_button(board,_face(row,compact,node_size),func():_select(id),"route_map_op_%d"%id)
  button.position=spot;button.size=cell;button.custom_minimum_size=cell
  # A face of one short word never wraps: its box is the node's own size and cannot grow past it (a wrapping Button grew to two lines and overlapped its neighbours).
  var wraps:bool=not row.mark and (not compact or node_size.x>=Table.OVERVIEW.title_min_width)
  button.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART if wraps else TextServer.AUTOWRAP_OFF;button.clip_text=not wraps
  button.mouse_filter=Control.MOUSE_FILTER_PASS
  button.set_meta("look_only",look)
  button.add_theme_font_size_override("font_size",node_font)
  var style=StyleBoxFlat.new();style.bg_color=Color(Table.THEME.recovered_fill if row.state=="RECOVERED" else Table.THEME.node_fill);style.set_content_margin_all(Table.OVERVIEW.padding if compact else Table.VIEW.padding)
  for state in ["normal","hover","pressed","disabled"]:button.add_theme_stylebox_override(state,style)
  button.add_theme_color_override("font_color",Color(Table.MARK_COLOR if row.mark else Table.COLORS[row.state]));buttons[id]=button
  # Sized last: a Button grows to its minimum under the default theme and does not shrink back when the node's own look is applied.
  button.reset_size();button.size=cell
  var border=Vector2.ONE*stroke
  board.centers[id]=point+node_size*.5;board.boxes[id]=Rect2(spot-border,cell+border*2)
 board.regions=_regions(region_size,font,area_pad)
 board.custom_minimum_size=m.extent;board.size=m.extent;board.queue_redraw()
 if look:detail.text=Table.DETAIL.look
 elif detail.text==Table.DETAIL.look:detail.text=Table.DETAIL.hint
# What a node shows: the full face (number, title, state, tag), or compact (number, and the title while the box is wide enough); colour carries the state.
func _face(row:Dictionary,compact:bool,node_size:Vector2)->String:
 if row.mark:return Table.MARK_GLYPH
 if not compact:return "%02d  %s\n%s%s"%[row.id+1,row.label,row.state,tag_text(row)]
 return "%02d  %s"%[row.id+1,row.label] if node_size.x>=Table.OVERVIEW.title_min_width else "%02d"%(row.id+1)
# The tag (empty for an operation the player cannot open): the work on one line, then what recovering it opens.
static func tag_text(row:Dictionary)->String:
 if row.tag.is_empty():return ""
 var work:Array=[];var reward:Array=[]
 for part in [["photo",row.tag.photos,work],["task",row.tag.tasks,work],["opens",row.tag.opens,reward]]:
  if part[1]>0:part[2].append(Table.TAG[part[0]][0 if part[1]==1 else 1]%part[1])
 var lines:Array=[Table.TAG.join.join(work),Table.TAG.join.join(reward)].filter(func(line):return not line.is_empty())
 return "\n"+"\n".join(lines) if not lines.is_empty() else ""
# Every region is drawn: a padded area around its operations and its name above the area, left-aligned. The key above the board
# already names every region, so nothing is revealed. A region with an operation available or recovered is "reached" and drawn stronger.
func _regions(font_size:int,font:Font,pad:float)->Array:
 var result:Array=[];var arcs=preload("res://src/campaign/arcs/arc_table.gd")
 if not arcs.enabled:return result
 for arc in arcs.ARCS:
  var members=graph.nodes.filter(func(row):return row.id in arc.ids)
  if members.is_empty():continue
  var hull:Rect2=board.boxes[members[0].id]
  for row in members:hull=hull.merge(board.boxes[row.id])
  var area:Rect2=hull.grow(pad)
  var text:String=arc.name;var size:=Vector2(font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x,font.get_height(font_size))
  var reached:bool=members.any(func(row):return row.state in ["AVAILABLE","RECOVERED"])
  var corner:float=Table.REGION_AREA.corner*.5
  result.append({"text":text,"key":arc.region,"rect":Rect2(Vector2(area.position.x+corner,area.position.y-Table.VIEW.region_pad-size.y),size),"area":area,"reached":reached,"font_size":font_size,"below":false})
 # A name wider than its area can run into a neighbour (overview): it then moves under its area, where the board keeps a band for it.
 for region in result:
  if result.any(func(other):return other!=region and region.rect.intersects(other.area)):
   region.rect.position.y=region.area.end.y+Table.VIEW.region_pad;region.below=true
 return result
# A mark says which region it lies in; an operation outside every region keeps the plain wording.
static func not_charted_text(id:int)->String:
 var arc:Dictionary=preload("res://src/campaign/arcs/arc_table.gd").for_operation(id)
 return Table.DETAIL.not_charted%arc.name if not arc.is_empty() else Table.DETAIL.not_charted_plain
 # WP-111: the board's size changes with the zoom and its scroll range follows a frame later, so the old code
 # (scroll now, scale by the zoom ratio) clamped to the old range and, at the overview where nothing scrolls,
 # forgot where the player was looking. The view's centre is kept as a fraction of the board (`focus`): zoom
 # out then in returns to the same spot, and a tap on a region or operation sets it too.
func _zoom(direction:int):
 var previous=zoom;zoom=clampf(zoom+direction*Table.VIEW.zoom_step,zoom_floor,Table.VIEW.zoom_max)
 if zoom==previous:return
 _remember_focus()
 _nodes(_touch_height())
 _show_focus()
# The view's centre as a fraction of the board, per axis. An axis that does not scroll (the whole board is in view) keeps the earlier focus.
func _remember_focus()->void:
 # Where the last zoom put the scroll is not the player's own look: keep that zoom's focus, so edge clamping never drifts a round trip.
 if Vector2i(chart.scroll_horizontal,chart.scroll_vertical)==shown_scroll:return
 for axis in 2:
  var span:float=board.size[axis]
  if span>chart.size[axis]+1.:focus[axis]=((chart.scroll_horizontal if axis==0 else chart.scroll_vertical)+chart.size[axis]*.5)/span
func _show_focus()->void:
 await get_tree().process_frame
 if not is_inside_tree() or chart==null:return
 chart.scroll_horizontal=roundi(focus.x*board.size.x-chart.size.x*.5);chart.scroll_vertical=roundi(focus.y*board.size.y-chart.size.y*.5)
 shown_scroll=Vector2i(chart.scroll_horizontal,chart.scroll_vertical)
# Overview taps are honest: nodes there are under the touch minimum, so the first tap only zooms in on the tapped one.
func _look_closer(id:int):
 zoom=clampf(maxf(zoom,Table.OVERVIEW.look_zoom),zoom_floor,Table.VIEW.zoom_max)
 _nodes(_touch_height())
 _center_on(board.centers[id])
# The chart's scroll range follows the board's new size one frame later: scrolling before that clamps to the old range
# (the overview has none), which showed the left edge, the first region, whatever was tapped. So wait a frame, then centre.
func _center_on(point:Vector2)->void:
 await get_tree().process_frame
 if not is_inside_tree() or chart==null:return
 focus=point/board.size	# WP-111: remembered, so a later zoom keeps this spot
 chart.scroll_horizontal=roundi(point.x-chart.size.x*.5);chart.scroll_vertical=roundi(point.y-chart.size.y*.5)
# A tap on the overview that lands on a region's area or name (not on an operation) zooms in on that region.
func _board_input(event:InputEvent)->void:
 if event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT and tap_board(event.position):board.accept_event()
func tap_board(point:Vector2)->bool:
 if zoom>=Table.OVERVIEW.compact_below:return false
 # A node's own box belongs to the node: its press passes up to the board (the buttons let the chart pan), and taking it here
 # zoomed on the region and freed the button before its release, so a tap on an open operation never opened its briefing.
 if board.boxes.values().any(func(box:Rect2):return box.has_point(point)):return false
 for region in board.regions:
  if region.area.has_point(point) or region.rect.has_point(point):
   zoom=clampf(maxf(zoom,Table.OVERVIEW.look_zoom),zoom_floor,Table.VIEW.zoom_max)
   _nodes(_touch_height())
   for fresh in board.regions:
    if fresh.text==region.text:_center_on(fresh.area.get_center())
   return true
 return false
func _focus_current():
 var available=graph.nodes.filter(func(row):return row.state=="AVAILABLE")
 var recovered=host.completed+host.expedition.get("completed",[])
 var id:int=available[0].id if not available.is_empty() else recovered.back() if not recovered.is_empty() else 0
 # Audit 091 F9: centre the operation continuing the most recently advanced branch.
 var branch=preload("res://src/presentation/current_branch.gd").pick(recovered,available.map(func(row):return row.id))
 if branch>=0:id=branch
 if not board.centers.has(id):return
 var center:Vector2=board.centers[id]
 focus=center/board.size	# WP-111: remembered for the zoom buttons
 chart.set_deferred("scroll_horizontal",roundi(center.x-chart.size.x*.5));chart.set_deferred("scroll_vertical",roundi(center.y-chart.size.y*.5))
func _select(id:int):
 if buttons.has(id) and buttons[id].get_meta("look_only",false):_look_closer(id);return
 var row=graph.nodes.filter(func(node):return node.id==id)[0]
 if row.can_open:
  _dismiss();host._briefing(id)
 elif row.mark:detail.text=not_charted_text(id)
 elif row.state=="KNOWN FROM PHOTOS":detail.text=Table.DETAIL.photos%row.label
 else:detail.text=Table.DETAIL.locked%[row.label,OpsHome.lock_reason(id,host.Simulation.Missions.TITLES)]
func _unhandled_key_input(event):
 if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_ESCAPE:get_viewport().set_input_as_handled();_back()
func _back():
 host._show_campaign();_dismiss()
func _dismiss():
 set_process(false)
 if get_parent()!=null:get_parent().remove_child(self)
 queue_free()
