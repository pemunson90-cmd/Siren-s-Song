extends Control
# One seam: entry(host) in main._show_campaign. No progression or save writes.
# Revert with Table.enabled=false; the existing operations list remains intact.
const Graph=preload("res://src/campaign/route_map/route_graph.gd")
const Table=preload("res://src/campaign/route_map/route_graph_table.gd")
const Preferences=preload("res://src/presentation/frontend/frontend_settings.gd")
class Board extends Control:
 const Palette=preload("res://src/campaign/route_map/route_graph_table.gd")
 var graph:Dictionary={}
 var centers:Dictionary={}
 var boxes:Dictionary={}
 func _draw():
  for edge in graph.get("edges",[]):draw_line(centers[edge.from],centers[edge.to],Color(Palette.THEME.edge),Palette.VIEW.stroke,true)
  for edge in graph.get("rumors",[]):draw_dashed_line(centers[edge.from],centers[edge.to],Color(Palette.COLORS["KNOWN FROM PHOTOS"]),Palette.VIEW.stroke,Palette.VIEW.line_dash,true)
  for row in graph.get("nodes",[]):
   var rect:Rect2=boxes[row.id];var color=Color(Palette.COLORS[row.state])
   if row.state=="KNOWN FROM PHOTOS":
    for side in [[rect.position,Vector2(rect.end.x,rect.position.y)],[Vector2(rect.end.x,rect.position.y),rect.end],[rect.end,Vector2(rect.position.x,rect.end.y)],[Vector2(rect.position.x,rect.end.y),rect.position]]:draw_dashed_line(side[0],side[1],color,Palette.VIEW.stroke,Palette.VIEW.node_dash,true)
   else:draw_rect(rect,color,false,Palette.VIEW.stroke)
var host
var graph:Dictionary={}
var buttons:Dictionary={}
var chart:ScrollContainer
var board:Board
var header:HBoxContainer
var legend:ScrollContainer
var detail:Label
var zoom:float=Table.VIEW.zoom_min
var fitted_size=Vector2.ZERO
var fitted_touch=0.
var fitted_scale=0.
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
 _button(header,"CURRENT",_focus_current,"route_map_current",Table.VIEW.current_width)
 _button(header,"−",func():_zoom(-1),"route_map_zoom_out")
 _button(header,"+",func():_zoom(1),"route_map_zoom_in")
 legend=ScrollContainer.new();legend.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;add_child(legend)
 var legend_rows=VBoxContainer.new();legend_rows.size_flags_horizontal=Control.SIZE_EXPAND_FILL;legend.add_child(legend_rows)
 var arcs=preload("res://src/campaign/arcs/arc_table.gd")
 if arcs.enabled:
  for arc in arcs.ARCS:
   var arc_title=Label.new();arc_title.text=arcs.heading(arc,host._campaign_completed());arc_title.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;legend_rows.add_child(arc_title)
   var states=[]
   for state in ["RECOVERED","AVAILABLE","LOCKED","KNOWN FROM PHOTOS"]:
    var count=graph.nodes.filter(func(row):return row.id in arc.ids and row.state==state).size()
    if count>0:states.append("%s %d"%[state,count])
   var summary=Label.new();summary.text=" / ".join(states);summary.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;legend_rows.add_child(summary)
 else:
  var label=Label.new();label.text="RECOVERED / AVAILABLE / LOCKED / KNOWN FROM PHOTOS";label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;legend_rows.add_child(label)
 chart=ScrollContainer.new();chart.name="ChartPan";add_child(chart)
 board=Board.new();board.mouse_filter=Control.MOUSE_FILTER_PASS;board.graph=graph;chart.add_child(board)
 detail=Label.new();detail.text="Drag to pan. + / − changes chart size. CURRENT finds the next available branch. Tap an available operation for its briefing.";detail.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;add_child(detail)
 _fit()
 call_deferred("_focus_current")
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
 legend.position=Vector2(margin,h+margin*Table.VIEW.legend_margin);legend.size=Vector2(size.x-margin*2,h*Table.VIEW.legend_height);legend.add_theme_font_size_override("font_size",_font(h,Table.VIEW.legend_font))
 for label in legend.find_children("*","Label",true,false):label.add_theme_font_size_override("font_size",_font(h,Table.VIEW.legend_font))
 chart.position=Vector2(margin,h*Table.VIEW.chart_top+margin);chart.size=Vector2(size.x-margin*2,maxf(h,size.y-h*Table.VIEW.chart_reserve-margin*2))
 detail.position=Vector2(margin,chart.position.y+chart.size.y+margin);detail.size=Vector2(size.x-margin*2,h);detail.add_theme_font_size_override("font_size",_font(h,Table.VIEW.detail_font))
 _nodes(h);queue_redraw()
func _nodes(h):
 for child in board.get_children():board.remove_child(child);child.queue_free()
 buttons.clear();board.centers.clear();board.boxes.clear()
 var node_size=Vector2(h*Table.VIEW.width_touch,h*Table.VIEW.height_touch)*zoom
 var gap=h*Table.VIEW.gap_touch*zoom;var margin=Table.VIEW.margin;var extent=Vector2.ZERO
 for row in graph.nodes:
  var point:Vector2=row.position*(node_size+Vector2(gap,gap))+Vector2(margin,margin)
  var id:int=row.id
  var button=_button(board,"%02d  %s\n%s"%[id+1,row.label,row.state],func():_select(id),"route_map_op_%d"%id)
  button.position=point;button.size=node_size;button.custom_minimum_size=node_size;button.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;button.mouse_filter=Control.MOUSE_FILTER_PASS
  button.add_theme_font_size_override("font_size",roundi(_font(h,Table.VIEW.font_touch)*zoom))
  button.disabled=not row.can_open and row.state!="KNOWN FROM PHOTOS"
  var style=StyleBoxFlat.new();style.bg_color=Color(Table.THEME.recovered_fill if row.state=="RECOVERED" else Table.THEME.node_fill);style.set_content_margin_all(Table.VIEW.padding)
  for state in ["normal","hover","pressed","disabled"]:button.add_theme_stylebox_override(state,style)
  button.add_theme_color_override("font_color",Color(Table.COLORS[row.state]));buttons[id]=button
  var border=Vector2.ONE*Table.VIEW.stroke
  board.centers[id]=point+node_size*.5;board.boxes[id]=Rect2(point-border,node_size+border*2)
  extent=extent.max(point+node_size+Vector2(margin,margin))
 board.custom_minimum_size=extent;board.size=extent;board.queue_redraw()
func _zoom(direction:int):
 var previous=zoom;zoom=clampf(zoom+direction*Table.VIEW.zoom_step,Table.VIEW.zoom_min,Table.VIEW.zoom_max)
 if zoom==previous:return
 var center=Vector2(chart.scroll_horizontal,chart.scroll_vertical)+chart.size*.5
 _nodes(_touch_height())
 chart.set_deferred("scroll_horizontal",roundi(center.x*zoom/previous-chart.size.x*.5));chart.set_deferred("scroll_vertical",roundi(center.y*zoom/previous-chart.size.y*.5))
func _focus_current():
 var available=graph.nodes.filter(func(row):return row.state=="AVAILABLE")
 var recovered=host.completed+host.expedition.get("completed",[])
 var id:int=available[0].id if not available.is_empty() else recovered.back() if not recovered.is_empty() else 0
 if not board.centers.has(id):return
 var center:Vector2=board.centers[id]
 chart.set_deferred("scroll_horizontal",roundi(center.x-chart.size.x*.5));chart.set_deferred("scroll_vertical",roundi(center.y-chart.size.y*.5))
func _select(id:int):
 var row=graph.nodes.filter(func(node):return node.id==id)[0]
 if row.can_open:
  _dismiss();host._briefing(id)
 elif row.state=="KNOWN FROM PHOTOS":detail.text=row.label+": known from recovered film. Its route is not available yet."
func _unhandled_key_input(event):
 if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_ESCAPE:get_viewport().set_input_as_handled();_back()
func _back():
 host._show_campaign();_dismiss()
func _dismiss():
 set_process(false)
 if get_parent()!=null:get_parent().remove_child(self)
 queue_free()
