extends RefCounted
# MENU REACH: reuse the frontend settings renderer and existing overlay screens.
# Seams: CampaignFlow.show_campaign, Main._settings_menu/_set_accessibility.
# Revert: Table.enabled=false restores legacy settings and removes new entries.
# No simulation commands, direct campaign writes or new setting/save keys.
const Table=preload("res://src/presentation/frontend/menu_reach_table.gd")
const Front=preload("res://src/presentation/frontend/frontend.gd")
static func entries(host)->void:
 if not Table.enabled:return
 # Share the existing bottom Settings row so navigation cannot push the
 # selected stock and all three comparison rows above the scrolled viewport.
 var nav=HBoxContainer.new();nav.add_theme_constant_override("separation",Table.NAV_GAP);host.panel_box.add_child(nav)
 var controls=[]
 for node in host.panel_box.get_children():
  if node is Button and node.get_meta("action","")=="settings":
   node.text="SETTINGS";node.reparent(nav);controls.append(node)
 for row in Table.ENTRIES:
  var destination=row[2]
  controls.append(host._button(nav,row[0],func():open(host,destination),row[1]))
 for control in controls:
  control.size_flags_horizontal=Control.SIZE_EXPAND_FILL
  control.custom_minimum_size.x=maxf(control.custom_minimum_size.x,host.ui_touch_height)
  control.mouse_filter=Control.MOUSE_FILTER_PASS
static func dismiss_existing(host)->void:
 var front=host.get_node_or_null("Frontend")
 if front!=null:front._dismiss()
static func settings(host)->bool:
 if not Table.enabled:return false
 dismiss_existing(host)
 var front=Front.new();host.add_child(front);front.setup_settings(host)
 return true
static func open(host,destination:String)->void:
 dismiss_existing(host)
 var front=Front.new();front.settings_store.path=host.settings_path;host.add_child(front);front.setup(host,true)
 front.operations_entry=destination
 if not host._campaign_pristine():front.profile=Front.Profile.OK
 if destination=="settings":front._settings_screen()
 elif destination=="credits":front._credits_screen()
 elif destination=="challenges":preload("res://src/presentation/frontend/challenges_frontend.gd").show(front)
 else:front._title_screen()
