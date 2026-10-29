extends RefCounted
# OPS HOME: rearrange existing menu controls, retaining launch callbacks/guards.
# Seams: CampaignFlow.show_campaign and Main._settings_menu (erase entry only).
# Revert: Table.enabled=false restores the old list and its erase entry.
# No progression, simulation or save writes. Recovered fold resets each visit;
# launch-detail preference lasts the session so comparisons retain their place.
const Table=preload("res://src/presentation/ops_home/ops_home_table.gd")
static func action(node)->String:
 return str(node.get_meta("ui_action",node.get_meta("action","")))
static func operation_id(node)->int:
 var key=action(node)
 if key.begins_with("mission"):return int(key.trim_prefix("mission"))
 if key.begins_with("expedition"):return int(key.trim_prefix("expedition"))
 return -1
static func arrange(host)->void:
 if not Table.enabled:return
 var recovered=[];var next=null;var resume=null;var quick=[];var later_available=false
 var completed=host._campaign_completed()
 # The former three decorative headings can fill a cover display at 150% text.
 var headings=host.panel_box.get_children().slice(0,3)
 headings[0].text="OPERATIONS"
 headings[0].add_theme_font_size_override("font_size",roundi(Table.HEADING_SIZE*host.ui_touch_height/48.*preload("res://src/presentation/frontend/frontend_settings.gd").text_scale()))
 headings[1].hide();headings[2].hide()
 for node in host.panel_box.get_children():
  var id=operation_id(node)
  if id>=0:
   if id>=6 and id not in completed:later_available=true
   if id in completed:recovered.append(node)
   elif not node.disabled and next==null:next=node
  if action(node)=="resume":resume=node
  if action(node) in ["route_map","fittings","economy"]:quick.append(node)
 var top=HBoxContainer.new();top.add_theme_constant_override("separation",Table.GAP);host.panel_box.add_child(top);host.panel_box.move_child(top,3)
 # An always-present slot prevents every operation row moving when Resume appears.
 if resume==null:
  resume=host._button(host.panel_box,Table.TEXT.idle,func():pass,"resume_placeholder");resume.disabled=true
 else:resume.text=Table.TEXT.resume
 resume.reparent(top);resume.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 var target=next
 var primary=host._button(top,Table.TEXT.next if target!=null else Table.TEXT.complete,func():
  if is_instance_valid(target):target.pressed.emit()
 ,"next_operation")
 primary.disabled=target==null;primary.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 primary.size_flags_stretch_ratio=Table.NEXT_STRETCH
 primary.mouse_filter=Control.MOUSE_FILTER_PASS
 # Default disabled padding differs from the game's active button style.
 # Match their geometry so changing Resume availability cannot rewrap the row.
 for control in [resume,primary]:control.add_theme_stylebox_override("disabled",control.get_theme_stylebox("normal"))
 var shortcuts=HBoxContainer.new();shortcuts.add_theme_constant_override("separation",Table.GAP);host.panel_box.add_child(shortcuts);host.panel_box.move_child(shortcuts,4)
 for node in quick:node.reparent(shortcuts);node.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 for node in quick:
  if action(node)=="fittings":node.text="FITTINGS"
  if action(node)=="economy":node.text="SUPPLIES"
 preload("res://src/presentation/archive/archive_nav.gd").entry(host,shortcuts.get_index()+1)
 var dossier=host._button(host.panel_box,"SIREN DOSSIER",func():load("res://src/presentation/siren_dossier/siren_dossier.gd").show(host),"siren_dossier")
 dossier.custom_minimum_size.y=maxf(dossier.custom_minimum_size.y,host.ui_touch_height)
 for node in host.panel_box.get_children():
  if action(node)=="archive":
   # Keep both dossier entry points while sharing one vertical slot. This
   # preserves an actually exposed disabled mission row at dense layouts.
   var index=node.get_index();var row=HBoxContainer.new()
   row.add_theme_constant_override("separation",Table.GAP)
   host.panel_box.add_child(row);host.panel_box.move_child(row,index)
   node.reparent(row);dossier.reparent(row)
   for button in [node,dossier]:
    button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
    button.custom_minimum_size.x=maxf(button.custom_minimum_size.x,host.ui_touch_height)
   break
 var group=VBoxContainer.new();group.add_theme_constant_override("separation",Table.GAP);host.panel_box.add_child(group)
 var fold=host._button(host.panel_box,Table.TEXT.fold%recovered.size(),func():group.visible=not group.visible;host.call_deferred("_layout"),"recovered_fold")
 for node in recovered:node.reparent(group)
 preload("res://src/presentation/arcs/arc_card.gd").group_rows(host,group)
 var after=shortcuts.get_index()+1
 for node in host.panel_box.get_children():
  if node is Label and node.text=="BEYOND THE WARNING / OPERATIONS":
   # Recovered rows have their own fold; keep this heading only for later work
   # still listed here. At large text the otherwise empty heading spans three lines.
   node.visible=later_available and not preload("res://src/campaign/arcs/arc_table.gd").enabled
   after=node.get_index()+1
  if operation_id(node)>=0:after=node.get_index()+1
 host.panel_box.move_child(fold,after);host.panel_box.move_child(group,fold.get_index()+1)
 group.visible=recovered.size()<Table.FOLD_THRESHOLD
 fold.disabled=recovered.is_empty()
 # Detailed stock comparisons remain reachable without filling the home screen.
 var details=[];var collecting=false;var start=-1
 for node in host.panel_box.get_children():
  if action(node)=="siren_dossier":continue
  if node is Label and node.text.begins_with("NEXT DIVE / RETRY"):
   collecting=true;start=node.get_index()
  if collecting:details.append(node)
  if action(node)=="loadout":break
 if start>=0:
  var stock=VBoxContainer.new();stock.add_theme_constant_override("separation",Table.GAP);host.panel_box.add_child(stock)
  var stock_fold=host._button(host.panel_box,"LAUNCH DETAILS / LOADOUT",func():stock.visible=not stock.visible;host.set_meta("ops_home_details_open",stock.visible);host.call_deferred("_layout"),"launch_details")
  for node in details:node.reparent(stock)
  host.panel_box.move_child(stock_fold,start);host.panel_box.move_child(stock,start+1);stock.visible=host.get_meta("ops_home_details_open",false)
 # Folded controls must retain a full touch-sized minimum before first layout.
 for control in host.panel_box.find_children("*","Button",true,false):
  control.custom_minimum_size.x=maxf(control.custom_minimum_size.x,host.ui_touch_height)
static func settings_entry(host)->void:
 if Table.enabled and not host._campaign_pristine():host._button(host.panel_box,"ERASE PROGRESS · NEW CAMPAIGN",host._confirm_new_campaign,"new_campaign")
