extends Control
# One modal over the existing briefing/debrief, preserving their callbacks and finale.
# Revert Table.enabled=false. Save fields are optional booleans, absent means unseen.
const Table=preload("res://src/campaign/arcs/arc_table.gd")
const Recap=preload("res://src/campaign/arcs/arc_recap.gd")
const UiStyle=preload("res://src/presentation/ui_style.gd")
const Metrics=preload("res://src/presentation/layout_metrics.gd")
const ChartPreview=preload("res://src/presentation/chart_preview.gd")
const META="arc_seen"
const HEADING_SIZE=28
const KIND_INTRO="ARC %d · REGION ENTRY"
const KIND_OUTRO="ARC %d · RECOVERED, DEPARTURE"
# The arc text names its speaker as "Okafor, on Brannock:"; the card says who and where plainly.
const SPEAKER_OLD="Okafor, on Brannock: "
const SPEAKER="Okafor (Brannock Command):\n"
var frame:PanelContainer
var host
var previous_screen=""
var previous_menu_visible=false
static func write(main,data:Dictionary)->void:
 var seen=main.get_meta(META,{})
 for arc in Table.ARCS:
  if seen.get(arc.seen,false):data[arc.seen]=true
static func restore(main,data:Dictionary)->void:
 var seen={}
 for arc in Table.ARCS:seen[arc.seen]=data.get(arc.seen,false)==true
 main.set_meta(META,seen)
static func clear(main)->void:main.set_meta(META,{})
static func intro(main,id:int)->void:
 var arc=Table.for_operation(id)
 if not Table.enabled or arc.is_empty() or id!=arc.first:return
 var seen=main.get_meta(META,{})
 if seen.get(arc.seen,false):return
 seen[arc.seen]=true;main.set_meta(META,seen)
 present(main,arc,false);main._save_archive()
static func recovered(main,first:bool)->void:
 if not Table.enabled or not first or main.sim.outcome!="won" :return
 if main.mission_index>=6 and not main.sim.mission.get("recovered",false):return
 var arc=Table.for_operation(main.mission_index)
 if arc.is_empty() or main.mission_index not in arc.last:return
 # The alternative branch's last operation must not repeat the arc departure.
 if arc.number in [2,3]:
  var others=arc.last.filter(func(id):return id!=main.mission_index)
  if others.any(func(id):return id in main._campaign_completed()):return
 present(main,arc,true)
static func back(main)->bool:
 var card=main.get_node_or_null("ArcCard")
 if card==null:return false
 card.dismiss();return true
static func present(main,arc:Dictionary,outro:bool)->void:
 back(main)
 var card=load("res://src/presentation/arcs/arc_card.gd").new()
 card.name="ArcCard";main.add_child(card);card.setup(main,arc,outro)
func setup(main,arc:Dictionary,outro:bool)->void:
 host=main;previous_screen=main.screen;previous_menu_visible=main.menu.visible
 main.menu.hide()
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);mouse_filter=Control.MOUSE_FILTER_STOP
 var background=ColorRect.new();background.color=Color("07151e");background.mouse_filter=Control.MOUSE_FILTER_STOP;add_child(background);background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 # The same framed panel, width and margins as the briefing it covers (see _fit).
 frame=PanelContainer.new();add_child(frame)
 var box=VBoxContainer.new();box.add_theme_constant_override("separation",12);frame.add_child(box)
 var scroll=ScrollContainer.new();scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;box.add_child(scroll)
 var text=VBoxContainer.new();text.size_flags_horizontal=Control.SIZE_EXPAND_FILL;text.add_theme_constant_override("separation",16);scroll.add_child(text)
 var scale=main.ui_touch_height/48.0*preload("res://src/presentation/frontend/frontend_settings.gd").text_scale()
 var rows=[arc.name,KIND_OUTRO%arc.number if outro else KIND_INTRO%arc.number,arc.outro if outro else arc.intro.replace(SPEAKER_OLD,SPEAKER)]
 rows.append_array(Recap.lines(main.expedition))
 if outro:rows.append(preload("res://src/presentation/flow/campaign_flow.gd").stats_line(main.sim))
 for i in rows.size():
  var label=Label.new();label.text=rows[i];label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;label.add_theme_font_size_override("font_size",roundi((HEADING_SIZE if i==0 else 18)*scale))
  if i==1:label.add_theme_color_override("font_color",UiStyle.ACCENT)
  text.add_child(label)
 # The first operation of the region: its chart, under the arc name and kind line.
 if not outro and arc.has("first"):
  ChartPreview.attach(text,main.Simulation.Missions.make(arc.first,main._launch_context(arc.first)),main.size.y,scale,2)
 var next=main._button(box,"CONTINUE TO RECOVERY" if outro else "CONTINUE TO BRIEFING",dismiss,"arc_continue")
 next.custom_minimum_size=Vector2(48,maxf(48,main.ui_touch_height));next.add_theme_font_size_override("font_size",roundi(18*scale))
 next.grab_focus()
 _fit()
# Same geometry the briefing panel gets in Main._layout.
func _fit()->void:
 var width:float=Metrics.menu_width(host.size,host.get_meta("hub_wide",false),host.ui_touch_height)
 frame.position=Vector2(maxf(24,(host.size.x-width)/2),24);frame.size=Vector2(width,host.size.y-48)
func _process(_delta):
 _fit()
 if host.screen!=previous_screen or not Table.enabled:dismiss()
func dismiss()->void:
 if not is_inside_tree():return
 if host.screen==previous_screen:host.menu.visible=previous_menu_visible
 get_parent().remove_child(self);queue_free()
static func group_rows(main,parent:Node)->void:
 if not Table.enabled:return
 var completed=main._campaign_completed()
 for arc in Table.ARCS:
  var rows=parent.get_children().filter(func(node):return operation_id(node) in arc.ids)
  if rows.is_empty():continue
  var index=rows[0].get_index();var box=VBoxContainer.new();box.set_meta("arc_group",arc.number);parent.add_child(box);parent.move_child(box,index)
  var label=Label.new();label.text=Table.heading(arc,completed);label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;label.add_theme_font_size_override("font_size",roundi(16*main.ui_touch_height/48.0*preload("res://src/presentation/frontend/frontend_settings.gd").text_scale()));box.add_child(label)
  for row in rows:row.reparent(box)
static func operation_id(node)->int:
 return load("res://src/presentation/ops_home/ops_home.gd").operation_id(node)
