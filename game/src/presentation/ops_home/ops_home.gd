extends RefCounted
# OPS HOME: rearrange existing menu controls, retaining launch callbacks/guards.
# Seams: CampaignFlow.show_campaign and Main._settings_menu (erase entry only).
# Revert: Table.enabled=false restores the old list and its erase entry.
# No progression, simulation or save writes. Recovered fold resets each visit;
# launch-detail preference lasts the session so comparisons retain their place.
# WP-37 layout: three groups (Continue, Operations, Prepare and review), then the difficulty
# line and the reach row. One column on tall screens; on a wide landscape screen Operations
# take the left column and everything else the right (LayoutMetrics.hub_wide decides).
# Operations are cards: a Button (keeps its action id and callback) with a text overlay.
const Table=preload("res://src/presentation/ops_home/ops_home_table.gd")
const UiStyle=preload("res://src/presentation/ui_style.gd")
const Metrics=preload("res://src/presentation/layout_metrics.gd")
const Options=preload("res://src/campaign/economy_options.gd")
const Prefs=preload("res://src/presentation/frontend/frontend_settings.gd")
const ArcTable=preload("res://src/campaign/arcs/arc_table.gd")
const GROUP_META="hub_group"
const SEPARATION=8
const GROUP_GAP=16
static func action(node)->String:
 return str(node.get_meta("ui_action",node.get_meta("action","")))
static func operation_id(node)->int:
 var key=action(node)
 if key.begins_with("mission"):return int(key.trim_prefix("mission"))
 if key.begins_with("expedition"):return int(key.trim_prefix("expedition"))
 return -1
# Tag the controls added since child index `from` so arrange can place them in a group.
static func mark(host,from:int,group:String)->void:
 var nodes=host.panel_box.get_children()
 for i in range(from,nodes.size()):nodes[i].set_meta(GROUP_META,group)
static func text_scale(host)->float:
 return host.ui_touch_height/48.*Prefs.text_scale()
static func heading(host,text:String)->Label:
 var label=Label.new();label.text=text;label.add_theme_font_size_override("font_size",roundi(Table.HEADING_SIZE*text_scale(host)))
 label.add_theme_color_override("font_color",UiStyle.ACCENT);label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 return label
static func column(separation:int=SEPARATION)->VBoxContainer:
 var box=VBoxContainer.new();box.add_theme_constant_override("separation",separation);box.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 return box
static func plain_arc_heading(arc:Dictionary,completed:Array,with_count:bool=true)->String:
 if not with_count:return "ARC %d: %s"%[arc.number,arc.name]
 return "ARC %d: %s (%d of %d recovered)"%[arc.number,arc.name,arc.ids.filter(func(id):return id in completed).size(),arc.ids.size()]
# What opens a locked operation (shared with the route map): the operation before it, by number and name.
static func lock_reason(id:int,titles:Array)->String:
 return "Recover %02d %s first"%[id,titles[id-1]] if id>0 else ""
# What a card shows for an operation row: number, name, state tag and (when locked) the reason.
static func card_data(host,button:Button)->Dictionary:
 var id=operation_id(button)
 if action(button).begins_with("mission"):
  var titles=host.Simulation.Missions.TITLES
  var state="RECOVERED" if id in host.completed else ("AVAILABLE" if id<=host.unlocked else "LOCKED")
  var reason=lock_reason(id,titles) if state=="LOCKED" else ""
  return {"id":id,"num":"%02d"%(id+1),"name":titles[id],"state":state,"reason":reason}
 var parts=str(button.text).rsplit(" · ",true,1)
 return {"id":id,"num":"%02d"%(id+1),"name":parts[0],"state":parts[1] if parts.size()>1 else "AVAILABLE","reason":""}
static func card(host,button:Button,data:Dictionary,primary:bool)->Control:
 var ts=Prefs.text_scale();var h=host.ui_touch_height
 var state:String=data.state
 var wrap=MarginContainer.new();wrap.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 # The wrapper carries the id so arc grouping and the recovered fold treat it as the operation row.
 wrap.set_meta("ui_action",action(button));wrap.set_meta("card_button",button)
 button.set_meta("card_title",data.name)
 var parent=button.get_parent()
 if parent!=null:parent.remove_child(button)
 wrap.add_child(button)
 button.text="";button.size_flags_horizontal=Control.SIZE_EXPAND_FILL;button.mouse_filter=Control.MOUSE_FILTER_PASS
 UiStyle.apply(button,UiStyle.NORMAL)
 var fill=UiStyle.BUTTON_FILL;var border=UiStyle.BUTTON_BORDER;var width=1
 var name_color=UiStyle.TEXT;var tag_color=UiStyle.ACCENT
 if state=="AVAILABLE":
  border=UiStyle.ACCENT;width=2
  if primary:fill=UiStyle.HOVER_FILL
 elif state=="RECOVERED":
  fill=Color("0c2024");name_color=UiStyle.QUIET_TEXT;tag_color=UiStyle.QUIET_TEXT
 else:name_color=UiStyle.DISABLED_TEXT;tag_color=UiStyle.DISABLED_TEXT
 if state!="LOCKED":
  button.add_theme_stylebox_override("normal",UiStyle._box(fill,border,width))
  button.add_theme_stylebox_override("hover",UiStyle._box(UiStyle.HOVER_FILL,UiStyle.HOVER_BORDER,2))
 var inner=MarginContainer.new();inner.mouse_filter=Control.MOUSE_FILTER_IGNORE
 for side in ["left","right"]:inner.add_theme_constant_override("margin_"+side,16)
 for side in ["top","bottom"]:inner.add_theme_constant_override("margin_"+side,6)
 wrap.add_child(inner)
 var row=HBoxContainer.new();row.mouse_filter=Control.MOUSE_FILTER_IGNORE;row.add_theme_constant_override("separation",12);inner.add_child(row)
 var left=VBoxContainer.new();left.mouse_filter=Control.MOUSE_FILTER_IGNORE;left.size_flags_horizontal=Control.SIZE_EXPAND_FILL;left.size_flags_vertical=Control.SIZE_SHRINK_CENTER;left.add_theme_constant_override("separation",0);row.add_child(left)
 var title=Label.new();title.text="%s   %s"%[data.num,data.name];title.mouse_filter=Control.MOUSE_FILTER_IGNORE;title.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 title.add_theme_font_size_override("font_size",maxi(17,roundi(h*.29*ts)));title.add_theme_color_override("font_color",name_color);left.add_child(title)
 if not data.reason.is_empty():
  var why=Label.new();why.text=data.reason;why.mouse_filter=Control.MOUSE_FILTER_IGNORE;why.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
  why.add_theme_font_size_override("font_size",maxi(14,roundi(h*.21*ts)));why.add_theme_color_override("font_color",UiStyle.DISABLED_TEXT);left.add_child(why)
 var tag=Label.new();tag.text=state;tag.mouse_filter=Control.MOUSE_FILTER_IGNORE;tag.size_flags_vertical=Control.SIZE_SHRINK_CENTER
 tag.add_theme_font_size_override("font_size",maxi(14,roundi(h*.23*ts)));tag.add_theme_color_override("font_color",tag_color);row.add_child(tag)
 return wrap
static func arrange(host)->void:
 if not Table.enabled:return
 var box=host.panel_box
 var wide=Metrics.hub_wide(host.size,host.ui_touch_height,Prefs.text_scale())
 host.set_meta("hub_wide",wide)
 var completed=host._campaign_completed()
 preload("res://src/presentation/archive/archive_nav.gd").entry(host)
 host._button(box,"SIREN DOSSIER",func():load("res://src/presentation/siren_dossier/siren_dossier.gd").show(host),"siren_dossier")
 var children=box.get_children()
 # Detailed stock comparisons (from the loadout line through the cycle button) stay behind LOADOUT.
 var details=[];var start=-1;var finish=-1
 for i in children.size():
  var node=children[i]
  if start<0 and node is Label and node.text.begins_with("Loadout:"):start=i
  if start>=0 and finish<0 and action(node)=="loadout":finish=i
 if start>=0 and finish>=start:details=children.slice(start,finish+1)
 var cards=[];var ops_labels=[];var prepare={};var extras=[];var diff=[];var notes=[];var hint=null;var resume=null;var reach=null
 for i in children.size():
  var node=children[i]
  if node in details:continue
  var key=action(node)
  # The former three decorative headings are replaced by the group headings.
  if i<3 and node is Label:node.hide();continue
  if operation_id(node)>=0 and node is Button:cards.append(node)
  elif node is Label and (node.text.begins_with("BEYOND THE WARNING") or node.text.begins_with("SORLEY'S SIGNAL")):ops_labels.append(node)
  elif key=="resume":resume=node
  elif key in ["route_map","fittings","economy","archive","siren_dossier","save2_home"]:prepare[key]=node
  elif node.get_meta(GROUP_META,"")=="difficulty":diff.append(node)
  elif node.get_meta(GROUP_META,"")=="continue":hint=node
  elif node.get_meta(GROUP_META,"")=="note":notes.append(node)
  elif node is HBoxContainer and node.get_children().any(func(c):return action(c)=="settings"):reach=node
  else:extras.append(node)
 # Which card is the next thing to do, and which open rows exist (for the current-branch shortcut).
 var next=null;var open_rows={};var datas={}
 for node in cards:
  var data=card_data(host,node);datas[node]=data
  if data.id not in completed and not node.disabled:
   if next==null:next=node
   if not open_rows.has(data.id):open_rows[data.id]=node
 var wrappers=[];var recovered=[];var later_available=false
 for node in cards:
  var data=datas[node]
  if data.id>=6 and data.id not in completed:later_available=true
  var wrapper=card(host,node,data,node==next)
  wrappers.append(wrapper)
  if data.id in completed:recovered.append(wrapper)
 # --- Operations ---
 var ops=column();ops.add_child(heading(host,"OPERATIONS"))
 for label in ops_labels:label.reparent(ops)
 for wrapper in wrappers:
  if wrapper not in recovered:ops.add_child(wrapper)
 preload("res://src/presentation/arcs/arc_card.gd").group_rows(host,ops)
 var group=column()
 for wrapper in recovered:group.add_child(wrapper)
 preload("res://src/presentation/arcs/arc_card.gd").group_rows(host,group)
 var fold=host._button(ops,Table.TEXT.fold%recovered.size(),func():group.visible=not group.visible;host.call_deferred("_layout"),"recovered_fold")
 ops.add_child(group)
 group.visible=recovered.size()<Table.FOLD_THRESHOLD
 fold.disabled=recovered.is_empty()
 for holder in [ops,group]:
  for node in holder.get_children():
   if node.has_meta("arc_group"):
    var arc=ArcTable.ARCS[int(node.get_meta("arc_group"))-1];var label=node.get_child(0)
    if label is Label:
     # The count is stated once, over the open rows; the RECOVERED fold names the arc only (critic 13 Nov saw it twice).
     label.text=plain_arc_heading(arc,completed,holder==ops);label.add_theme_font_size_override("font_size",roundi(14*text_scale(host)))
 # --- Continue ---
 var cont=column()
 var top=HBoxContainer.new();top.add_theme_constant_override("separation",Table.GAP)
 if resume!=null:
  resume.text=Table.named(Table.TEXT.resume,"%02d"%(host.mission_index+1),str(host.sim.mission.title)) if host.sim!=null and host.sim.mission!=null else Table.TEXT.resume
  resume.reparent(top);resume.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 var target=next
 var primary_text=Table.TEXT.complete+"\n"+Table.TEXT.complete_note
 if target!=null:
  var next_data=datas[target];primary_text=Table.named(Table.TEXT.next,next_data.num,next_data.name)
 var primary=host._button(top,primary_text,func():
  if is_instance_valid(target):target.pressed.emit()
 ,"next_operation")
 primary.disabled=target==null;primary.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 primary.size_flags_stretch_ratio=Table.NEXT_STRETCH
 primary.mouse_filter=Control.MOUSE_FILTER_PASS
 # Match disabled geometry to the active style so changing Resume availability cannot rewrap the row.
 for control in [resume,primary]:
  if control!=null and control.get_meta("ui_role","NORMAL")!="MAIN":control.add_theme_stylebox_override("disabled",control.get_theme_stylebox("normal"))
  # Both buttons are exactly two lines (heading, then the operation) whatever the width: a long title is trimmed, never wrapped,
  # so the row keeps one height with or without Resume.
  if control!=null:control.autowrap_mode=TextServer.AUTOWRAP_OFF;control.text_overrun_behavior=TextServer.OVERRUN_TRIM_ELLIPSIS;control.clip_text=true
 var branch_id=preload("res://src/presentation/current_branch.gd").pick(completed,open_rows.keys())
 var branch=null
 if branch_id>=0 and open_rows[branch_id]!=next:
  var branch_row=open_rows[branch_id]
  branch=host._button(cont,"CONTINUE CURRENT BRANCH · "+str(branch_row.get_meta("card_title","")),func():
   if is_instance_valid(branch_row):branch_row.pressed.emit()
  ,"current_branch")
 var continue_head=HBoxContainer.new();continue_head.add_theme_constant_override("separation",Table.GAP)
 var continue_label=heading(host,"CONTINUE");continue_label.size_flags_horizontal=Control.SIZE_EXPAND_FILL;continue_label.size_flags_vertical=Control.SIZE_SHRINK_CENTER;continue_head.add_child(continue_label)
 var title=null
 if Table.TOP_TITLE:
  # WP-14: reuses the bottom-row TITLE callback (MenuReach.open "title"); WP-37: top of the panel, top-right when wide.
  title=host._button(continue_head,"TITLE",func():preload("res://src/presentation/frontend/menu_reach.gd").open(host,"title"),"ops_title")
  title.size_flags_horizontal=Control.SIZE_SHRINK_END
  title.custom_minimum_size=Vector2(maxf(title.custom_minimum_size.x,host.ui_touch_height*3.),title.custom_minimum_size.y)
 cont.add_child(top);cont.move_child(top,0)
 if branch!=null:cont.move_child(branch,1)
 # "Resuming keeps this dive's equipment..." speaks of a dive in progress: it is read only beside RESUME. Without a
 # dive it keeps its space (so RESUME appearing never moves the rows) but is not drawn.
 if hint!=null:hint.reparent(cont);hint.modulate.a=1.0 if resume!=null else 0.0
 # --- Prepare and review ---
 var prep=column();prep.add_child(heading(host,"PREPARE AND REVIEW"))
 var column_width=(host.size.x-Metrics.MENU_MARGIN-Metrics.MENU_PANEL_PADDING-Metrics.MENU_COLUMN_GAP)/2. if wide else Metrics.menu_width(host.size,false)-Metrics.MENU_PANEL_PADDING
 var grid=GridContainer.new();grid.columns=3 if column_width>=host.ui_touch_height*6.5 and Prefs.text_scale()<=1.25 else 2
 grid.add_theme_constant_override("h_separation",Table.GAP);grid.add_theme_constant_override("v_separation",Table.GAP);grid.size_flags_horizontal=Control.SIZE_EXPAND_FILL;prep.add_child(grid)
 var names={"fittings":"FITTINGS","economy":"SUPPLIES","archive":"FIELD RECORDS"}
 for key in ["route_map","fittings","economy","archive","siren_dossier","save2_home"]:
  if not prepare.has(key):continue
  var node=prepare[key];if names.has(key):node.text=names[key]
  node.reparent(grid);node.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 if not details.is_empty():
  var stock=column();stock.visible=host.get_meta("ops_home_details_open",false)
  var stock_fold=host._button(grid,"LOADOUT",func():stock.visible=not stock.visible;host.set_meta("ops_home_details_open",stock.visible);host.call_deferred("_layout"),"launch_details")
  stock_fold.size_flags_horizontal=Control.SIZE_EXPAND_FILL
  for node in details:node.reparent(stock)
  prep.add_child(stock)
 for node in extras:node.reparent(prep)
 for node in notes:node.reparent(prep)
 # --- Difficulty ---
 var difficulty=column()
 var preset=""
 if host.economy.has("preset"):preset=Options.label(host.economy).replace("CUSTOM / ","CUSTOM ")
 var picking=diff.any(func(node):return action(node).begins_with("eco_pick"))
 difficulty.add_child(heading(host,"DIFFICULTY" if picking or preset.is_empty() else "DIFFICULTY: "+preset))
 for node in diff:node.reparent(difficulty)
 # --- Assemble ---
 if wide:
  var columns=HBoxContainer.new();columns.add_theme_constant_override("separation",int(Metrics.MENU_COLUMN_GAP));box.add_child(columns)
  var left=column(GROUP_GAP);var right=column(GROUP_GAP)
  columns.add_child(left);columns.add_child(right)
  left.add_child(ops)
  right.add_child(continue_head);right.add_child(cont);right.add_child(prep);right.add_child(difficulty)
  # The reach row spans both columns along the bottom, so its five buttons are not squeezed into half the width.
  if reach!=null:box.move_child(reach,box.get_child_count()-1)
 else:
  if title!=null:title.reparent(box);title.size_flags_horizontal=Control.SIZE_SHRINK_BEGIN
  if title!=null:box.move_child(title,0)
  box.add_child(continue_head);box.add_child(cont);box.add_child(ops);box.add_child(prep);box.add_child(difficulty)
  if reach!=null:box.move_child(reach,box.get_child_count()-1)
 # Hub rows are 48dp touch targets (LayoutMetrics.dense_height); folded controls keep a full minimum before first layout.
 for control in box.find_children("*","Button",true,false):
  control.set_meta("dense_height",true)
  control.custom_minimum_size.y=Metrics.dense_height(host.ui_touch_height)
  control.custom_minimum_size.x=maxf(control.custom_minimum_size.x,host.ui_touch_height)
  control.mouse_filter=Control.MOUSE_FILTER_PASS
static func settings_entry(host)->void:
 if Table.enabled and not host._campaign_pristine():host._button(host.panel_box,"ERASE PROGRESS · NEW CAMPAIGN",host._confirm_new_campaign,"new_campaign")
