extends PanelContainer
var host
var selected_goal=0
var preview
var body:VBoxContainer
var content:BoxContainer
var editor:BoxContainer
var edit_controls:VBoxContainer
var rows:VBoxContainer
var info:Label
var point_info:Label
var mode_button:Button
var arrival_button:Button
var task_button:Button
var choosing_task=false
var undo_button:Button
var delete_button:Button
var selected_row:Button
var row_scroll:ScrollContainer
var touch_height=48.0
var error_text=""
var layout_bounds=Vector2.ZERO
var reflow_view:Dictionary={}
var reflow_revision=0
func _ready():
 mouse_filter=Control.MOUSE_FILTER_STOP;hide()
func button(parent,text,key,action):
 var b=Button.new();b.text=text;b.set_meta("action",key);b.custom_minimum_size.y=touch_height;b.size_flags_horizontal=Control.SIZE_EXPAND_FILL;b.focus_mode=Control.FOCUS_NONE;b.pressed.connect(action,CONNECT_DEFERRED);parent.add_child(b)
 if parent==rows:b.mouse_filter=Control.MOUSE_FILTER_PASS
 return b
func label(parent,text):
 var l=Label.new();l.text=text;l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;parent.add_child(l);return l
func row(parent):
 var box=HBoxContainer.new();box.add_theme_constant_override("separation",6);parent.add_child(box);return box
func open(owner):
 host=owner;selected_goal=0;error_text="";choosing_task=false;show();rebuild()
func rebuild():
 choosing_task=false
 reflow_view.clear();reflow_revision+=1;layout_bounds=Vector2.ZERO
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
 content=BoxContainer.new();content.add_theme_constant_override("separation",8);content.size_flags_vertical=Control.SIZE_EXPAND_FILL;body.add_child(content)
 preview=preload("res://src/presentation/route_program_preview.gd").new();preview.sim=host.sim;preview.custom_minimum_size=Vector2(160,70);preview.size_flags_vertical=Control.SIZE_EXPAND_FILL;preview.size_flags_horizontal=Control.SIZE_EXPAND_FILL;preview.size_flags_stretch_ratio=1.5;content.add_child(preview)
 preview.view_changed.connect(host._report_targets,CONNECT_DEFERRED)
 preview.point_chosen.connect(func(p):
  var count=host.sim.route_goals().size()
  apply("route_insert" if count==0 else "route_edit",{"index":0 if count==0 else selected_goal,"point":p}))
 editor=BoxContainer.new();editor.vertical=true;editor.size_flags_horizontal=Control.SIZE_EXPAND_FILL;editor.add_theme_constant_override("separation",8);content.add_child(editor)
 row_scroll=ScrollContainer.new();row_scroll.custom_minimum_size.y=touch_height;row_scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL;row_scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;editor.add_child(row_scroll)
 rows=VBoxContainer.new();rows.size_flags_horizontal=Control.SIZE_EXPAND_FILL;row_scroll.add_child(rows)
 row_scroll.resized.connect(show_selected_row,CONNECT_DEFERRED);rows.resized.connect(show_selected_row,CONNECT_DEFERRED)
 edit_controls=VBoxContainer.new();edit_controls.size_flags_horizontal=Control.SIZE_EXPAND_FILL;edit_controls.add_theme_constant_override("separation",8);editor.add_child(edit_controls)
 point_info=label(edit_controls,"")
 var modes=row(edit_controls);mode_button=button(modes,"","propulsion",cycle_mode);arrival_button=button(modes,"","arrival",toggle_arrival);task_button=button(modes,"TASK\nNONE","task",toggle_tasks)
 var edits=row(edit_controls);button(edits,"INSERT","insert",insert_after);delete_button=button(edits,"DELETE","delete",func():apply("route_delete",{"index":selected_goal}));undo_button=button(edits,"UNDO","undo",func():apply("route_undo",{}))
 configure(host.size,host.ui_touch_height);refresh()
func configure(bounds:Vector2,h:float):
 if preview!=null and bounds!=layout_bounds:
  # BoxContainer changes can produce several intermediate preview sizes. Retain
  # the inspected view until both container axes have finished sorting.
  if reflow_view.is_empty():reflow_view={"center":preview.chart_camera.center,"navigation_revision":preview.navigation_revision}
  layout_bounds=bounds;reflow_revision+=1;call_deferred("restore_reflow_view",reflow_revision)
 touch_height=h;position=Vector2(16,16);size=Vector2(bounds.x-32,bounds.y-32);position.x=(bounds.x-size.x)/2
 if body==null:return
 # Reflow the same controls: a full-width chart over a compact editing strip
 # on the inner display, with a chart/list column layout on the wide cover.
 # Keeping the preview alive retains its camera and cancels gestures on resize.
 var stacked=bounds.x/bounds.y<1.6
 content.vertical=stacked;editor.vertical=not stacked
 editor.size_flags_vertical=Control.SIZE_FILL if stacked else Control.SIZE_EXPAND_FILL
 row_scroll.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 row_scroll.custom_minimum_size.y=h*(3 if choosing_task else 1)+(roundi(h*.25)+24 if choosing_task else 0)
 row_scroll.size_flags_stretch_ratio=0.9 if stacked else 1.0
 edit_controls.size_flags_stretch_ratio=1.1 if stacked else 1.0
 for b in find_children("*","Button",true,false):
  b.custom_minimum_size.y=h;b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;b.add_theme_font_size_override("font_size",maxi(14,roundi(h*0.25)))
 for l in find_children("*","Label",true,false):l.add_theme_font_size_override("font_size",maxi(14,roundi(h*0.25)))
 if preview!=null:preview.configure_navigation(h,maxi(14,roundi(h*0.25)))
func restore_reflow_view(revision:int):
 for n in 2:await get_tree().process_frame
 if revision!=reflow_revision or reflow_view.is_empty():return
 # New navigation during the sort wins over restoring the previous view.
 if preview.navigation_revision==reflow_view.navigation_revision:preview.chart_camera.center=reflow_view.center
 reflow_view.clear();preview.configure_navigation(touch_height,maxi(14,roundi(touch_height*0.25)))
 show_selected_row()
func refresh():
 var goals=host.sim.route_goals();selected_goal=clampi(selected_goal,0,maxi(0,goals.size()-1))
 var legacy=goals.any(func(goal):return goal.get("legacy",false))
 var drone=host.sim.selected>0;var unit=host.sim.units[host.sim.selected]
 info.text=unit.name+(" · DRIVE %s · %s PROFILE\nTO sets incoming drive; INHERIT keeps current. STOP settles, then continues."%["QUIET42" if unit.get("drone_drive","transit")=="quiet" else "TRANSIT96","LOW" if unit.silent else "OPEN"] if drone else " · TO sets incoming propulsion. INHERIT keeps manual. STOP settles, then continues.")+("\nLegacy course retained; editing rebuilds to its final goal." if legacy else "")
 if goals.any(func(goal):return goal.has("task_site")):info.text=info.text.replace("STOP settles, then continues.","STOP waits for chosen work.")
 for c in rows.get_children():rows.remove_child(c);c.queue_free()
 selected_row=null
 if choosing_task:
  label(rows,"POINT %d · LOCAL RECEIVER WORK"%[selected_goal+1])
  button(rows,"NONE · settle, then continue","task_none",func():apply("route_edit",{"index":selected_goal,"task_site":""}))
  for option in task_options():
   var site_id=option.site_id
   button(rows,option.name+"\n"+task_cost(option),"task_"+site_id,func():apply("route_edit",{"index":selected_goal,"task_site":site_id}))
  button(rows,"BACK · KEEP CURRENT TASK","task_back",func():choosing_task=false;refresh())
 else:
  for n in goals.size():
   var id=n;var goal=goals[n];var text="%d · %s · %s · %.0f, %.0f"%[n+1,mode_label(goal.mode,drone),"STOP" if goal.stop else "PASS",goal.pos.x,goal.pos.y]
   if goal.has("task_site"):text+=" · TASK RECEIVE"
   var b=button(rows,text,"goal"+str(n),func():selected_goal=id;refresh());b.mouse_filter=Control.MOUSE_FILTER_PASS;b.modulate=Color("80d9cf") if n==selected_goal else Color.WHITE
   if n==selected_goal:selected_row=b
 # Never expose the large chooser minimum and editing strip together: Godot
 # would grow this PanelContainer beyond the viewport before the next sort.
 if choosing_task:
  edit_controls.hide();row_scroll.custom_minimum_size.y=touch_height*3+roundi(touch_height*.25)+24
 else:
  row_scroll.custom_minimum_size.y=touch_height;edit_controls.show()
 var empty=goals.is_empty();mode_button.disabled=empty;arrival_button.disabled=empty;delete_button.disabled=empty
 mode_button.text="TO: "+("—" if empty else mode_label(goals[selected_goal].mode,drone))
 arrival_button.text="AT: "+("—" if empty else ("STOP" if goals[selected_goal].stop else "PASS"))
 undo_button.disabled=host.sim.units[host.sim.selected].get("route_undo",[]).is_empty()
 point_info.text=error_text if not error_text.is_empty() else ("Tap preview to add the first destination." if empty else "POINT %d / %d · tap preview to move"%[selected_goal+1,goals.size()])
 var options=task_options();var attached=not empty and goals[selected_goal].has("task_site")
 task_button.visible=not empty and (goals[selected_goal].stop or attached) and (not options.is_empty() or attached)
 task_button.text="TASK\nRECEIVE" if attached else "TASK\nNONE"
 if error_text.is_empty() and not empty and not goals[selected_goal].stop and not options.is_empty():point_info.text+="\nSet AT: STOP to choose a local receiver task."
 if choosing_task:point_info.text="POINT %d · CHOOSE LOCAL RECEIVER WORK\nThe queued route continues after actual acquisition."%[selected_goal+1]
 elif error_text.is_empty() and attached:
  var goal=goals[selected_goal];var description=goal.task_site
  for site in host.sim.observable_sites():
   if site.get("site_id","")==goal.task_site:description=site.name;break
  for option in options:
   if option.site_id==goal.task_site:description+=" · %ds %s"%[roundi(option.duration),"audible" if option.audible else "quiet"];break
  var blocked=unit.get("task_run",{}).get("phase","")=="blocked" and unit.get("task_run",{}).get("site_id","")==goal.task_site
  point_info.text=("BLOCKED · "+description+"\nTASK: rearm · NONE: remove · guards stay set.") if blocked else "TASK · "+description+"\nThen queued route · guards retain priority."
 preview.selected_goal=selected_goal;preview.queue_redraw();call_deferred("configure",host.size,host.ui_touch_height);call_deferred("show_selected_row")
func mode_label(mode:String,drone:bool) -> String:
 return ("QUIET42" if mode=="silent" else "TRANSIT96" if mode=="cruise" else "INHERIT") if drone else mode.to_upper()
func show_selected_row():
 if is_instance_valid(selected_row):row_scroll.ensure_control_visible(selected_row)
func apply(order:String,args:Dictionary):
 choosing_task=false
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

func task_options()->Array:
 var goals=host.sim.route_goals()
 if goals.is_empty() or not host.sim.has_method("task_options"):return []
 return host.sim.task_options(host.sim.selected,goals[selected_goal].pos)
func task_cost(option:Dictionary)->String:
 return "%ds · %s"%[roundi(option.duration),"AUDIBLE FIELD SAMPLE" if option.audible else "QUIET RECEPTION"]
func toggle_tasks():
 choosing_task=not choosing_task;refresh()
 if choosing_task:row_scroll.set_deferred("scroll_vertical",0)
