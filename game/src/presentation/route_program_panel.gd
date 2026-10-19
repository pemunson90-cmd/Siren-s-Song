extends PanelContainer
var host
var selected_goal=0
var preview
var body:VBoxContainer
var rows:VBoxContainer
var info:Label
var point_info:Label
var mode_button:Button
var arrival_button:Button
var undo_button:Button
var delete_button:Button
var selected_row:Button
var row_scroll:ScrollContainer
var touch_height=48.0
var error_text=""
func _ready():
 mouse_filter=Control.MOUSE_FILTER_STOP;hide()
func button(parent,text,key,action):
 var b=Button.new();b.text=text;b.set_meta("action",key);b.custom_minimum_size.y=touch_height;b.size_flags_horizontal=Control.SIZE_EXPAND_FILL;b.focus_mode=Control.FOCUS_NONE;b.pressed.connect(action,CONNECT_DEFERRED);parent.add_child(b);return b
func label(parent,text):
 var l=Label.new();l.text=text;l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;parent.add_child(l);return l
func row(parent):
 var box=HBoxContainer.new();box.add_theme_constant_override("separation",6);parent.add_child(box);return box
func open(owner):
 host=owner;selected_goal=0;error_text="";show();rebuild()
func rebuild():
 for c in get_children():remove_child(c);c.queue_free()
 touch_height=host.ui_touch_height
 body=VBoxContainer.new();body.add_theme_constant_override("separation",8);add_child(body)
 var header=row(body);var heading=label(header,"ROUTE PROGRAM · PAUSED");heading.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 button(header,"DONE · STAY PAUSED","close",close)
 var crafts=row(body)
 for n in 3:
  var id=n;var b=button(crafts,host.sim.units[n].name,"craft"+str(n),func():host._order("select",{"unit":id});selected_goal=0;error_text="";rebuild())
  b.disabled=not host.sim.units[n].alive;b.modulate=Color("80d9cf") if n==host.sim.selected else Color.WHITE
 info=label(body,"")
 var content=row(body);content.size_flags_vertical=Control.SIZE_EXPAND_FILL
 preview=preload("res://src/presentation/route_program_preview.gd").new();preview.sim=host.sim;preview.custom_minimum_size=Vector2(160,70);preview.size_flags_vertical=Control.SIZE_EXPAND_FILL;preview.size_flags_horizontal=Control.SIZE_EXPAND_FILL;preview.size_flags_stretch_ratio=0.8;content.add_child(preview)
 preview.view_changed.connect(host._report_targets,CONNECT_DEFERRED)
 preview.point_chosen.connect(func(p):
  var count=host.sim.route_goals().size()
  apply("route_insert" if count==0 else "route_edit",{"index":0 if count==0 else selected_goal,"point":p}))
 var editor=VBoxContainer.new();editor.size_flags_horizontal=Control.SIZE_EXPAND_FILL;editor.size_flags_stretch_ratio=1.2;editor.add_theme_constant_override("separation",8);content.add_child(editor)
 row_scroll=ScrollContainer.new();row_scroll.custom_minimum_size.y=touch_height;row_scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;row_scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;editor.add_child(row_scroll)
 rows=VBoxContainer.new();rows.size_flags_horizontal=Control.SIZE_EXPAND_FILL;row_scroll.add_child(rows)
 point_info=label(editor,"")
 var modes=row(editor);mode_button=button(modes,"","propulsion",cycle_mode);arrival_button=button(modes,"","arrival",toggle_arrival)
 var edits=row(editor);button(edits,"INSERT","insert",insert_after);delete_button=button(edits,"DELETE","delete",func():apply("route_delete",{"index":selected_goal}));undo_button=button(edits,"UNDO","undo",func():apply("route_undo",{}))
 configure(host.size,host.ui_touch_height);refresh()
func configure(bounds:Vector2,h:float):
 touch_height=h;position=Vector2(16,16);size=Vector2(bounds.x-32,bounds.y-32);position.x=(bounds.x-size.x)/2
 if body==null:return
 for b in find_children("*","Button",true,false):
  b.custom_minimum_size.y=h;b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;b.add_theme_font_size_override("font_size",maxi(14,roundi(h*0.25)))
 for l in find_children("*","Label",true,false):l.add_theme_font_size_override("font_size",maxi(14,roundi(h*0.25)))
 if preview!=null:preview.configure_navigation(h,maxi(14,roundi(h*0.25)))
func refresh():
 var goals=host.sim.route_goals();selected_goal=clampi(selected_goal,0,maxi(0,goals.size()-1))
 var legacy=goals.any(func(goal):return goal.get("legacy",false))
 var fixed=host.sim.selected>0
 info.text=host.sim.units[host.sim.selected].name+(" · propulsion is FIXED96. STOP settles, then continues." if fixed else " · TO sets incoming propulsion. INHERIT keeps manual. STOP settles, then continues.")+("\nLegacy course retained; editing rebuilds to its final goal." if legacy else "")
 for c in rows.get_children():rows.remove_child(c);c.queue_free()
 selected_row=null
 for n in goals.size():
  var id=n;var goal=goals[n];var text="%d · %s · %s · %.0f, %.0f"%[n+1,("FIXED96" if fixed else goal.mode.to_upper()),"STOP" if goal.stop else "PASS",goal.pos.x,goal.pos.y]
  var b=button(rows,text,"goal"+str(n),func():selected_goal=id;refresh());b.mouse_filter=Control.MOUSE_FILTER_PASS;b.modulate=Color("80d9cf") if n==selected_goal else Color.WHITE
  if n==selected_goal:selected_row=b
 var empty=goals.is_empty();mode_button.disabled=empty or fixed;arrival_button.disabled=empty;delete_button.disabled=empty
 mode_button.text="FIXED96" if fixed else "TO: "+("—" if empty else goals[selected_goal].mode.to_upper())
 arrival_button.text="AT: "+("—" if empty else ("STOP" if goals[selected_goal].stop else "PASS"))
 undo_button.disabled=host.sim.units[host.sim.selected].get("route_undo",[]).is_empty()
 point_info.text=error_text if not error_text.is_empty() else ("Tap preview to add the first destination." if empty else "POINT %d / %d · tap preview to move"%[selected_goal+1,goals.size()])
 preview.selected_goal=selected_goal;preview.queue_redraw();call_deferred("configure",host.size,host.ui_touch_height);call_deferred("show_selected_row")
func show_selected_row():
 if is_instance_valid(selected_row):row_scroll.ensure_control_visible(selected_row)
func apply(order:String,args:Dictionary):
 var accepted=host.sim.command(order,args);error_text="" if accepted else host.sim.message;host._refresh();host._save_archive();refresh()
func cycle_mode():
 var goals=host.sim.route_goals()
 if goals.is_empty():return
 var modes=["inherit","cruise","silent"];apply("route_edit",{"index":selected_goal,"mode":modes[(modes.find(goals[selected_goal].mode)+1)%3]})
func toggle_arrival():
 var goals=host.sim.route_goals()
 if not goals.is_empty():apply("route_edit",{"index":selected_goal,"stop":not goals[selected_goal].stop})
func insert_after():
 var goals=host.sim.route_goals();var index=0 if goals.is_empty() else selected_goal+1
 var a:Vector2=host.sim.units[host.sim.selected].pos if goals.is_empty() else goals[selected_goal].pos
 var p:Vector2=a+Vector2(80,0) if index>=goals.size() else a.lerp(goals[index].pos,0.5)
 var before=goals.size();apply("route_insert",{"index":index,"point":p})
 if host.sim.route_goals().size()>before:selected_goal=index;refresh()
func close():
 hide();host.screen="mission";host.hud.show();host._layout();host._refresh()
