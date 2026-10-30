extends Control
const HuntMeter=preload("res://src/presentation/hunt_meter.gd")
const FeatureViews=preload("res://src/presentation/feature_views.gd")
const Shelf=preload("res://src/presentation/shelf_habitat_view.gd")
const Wake=preload("res://src/presentation/wake_crossing_view.gd")
const Operations=preload("res://src/presentation/operation_instruments.gd")
const Equipment=preload("res://src/presentation/equipment_context.gd")
const Expedition=preload("res://src/presentation/expedition_view.gd")
const Recovery=preload("res://src/presentation/module_recovery_view.gd")
const Cache=preload("res://src/presentation/optional_cache_view.gd")
const Rendezvous=preload("res://src/presentation/rendezvous_view.gd")
const WarningChain=preload("res://src/presentation/warning_chain_view.gd")
const Delivery=preload("res://src/presentation/blackwater_delivery_view.gd")
const Recipient=preload("res://src/presentation/warning_recipient_view.gd")
const Concealed=preload("res://src/presentation/concealed_harbour_view.gd")
const Witness=preload("res://src/presentation/witness_evacuation_view.gd")
const CenterLayout=preload("res://src/presentation/radial_layout/center_layout.gd")
const StatusView=preload("res://src/presentation/status_text/status_view.gd")
const AllStop=preload("res://src/simulation/all_stop/all_stop.gd")
const WorkTask=preload("res://src/presentation/work_task/work_task.gd")
# A tap opens an object-owned projection. A separate tap chooses an action.
var host
var blocker:Control
var close_button:Button
var focus_button:Button
var instrument_button:Button
var sonar_waterfall:Control
var instrument_info:Label
var intent:Label
var alarm:Label
var warning_style:StyleBoxFlat
var pressure_style:StyleBoxFlat
var measurement_style:StyleBoxFlat
var sheet_body:VBoxContainer
var sheet_fit_pending=false
var sheet_scroll:ScrollContainer
var details_return="water"
var sheet_pointers:Dictionary={}
var sheet:PanelContainer
var page="craft"
var subject:Dictionary={}
var center=Vector2.ZERO
var anchor=Vector2.ZERO
var ring_radius=150.
var ring_buttons:Array=[]
var extra:Dictionary={}
var instruments_open=false
var owned_touches:Dictionary={}
var draining_popup=false
var sector_press:Button
var popup_gesture=preload("res://src/input/map_gesture.gd").new()
var touch_height=48.
var fleet
var recovery_box:VBoxContainer
var recovery_buttons:Array=[]
var guard
var chart_choice
var hints
var text_scale=1.0
var caption_rects:Array=[]
var tool_help=preload("res://src/presentation/tool_help/tool_help.gd").new()
var help_return="tools"
var help_text=""
var help_consumed=false
# 119: chosen object work, last work result, and a pending craft/object choice.
var task:Dictionary={}
var task_result:Dictionary={}
var choose_units:Array=[]
var choose_next="object"
func setup(owner):
 host=owner;mouse_filter=Control.MOUSE_FILTER_IGNORE
 add_child(tool_help);tool_help.setup(self)
 blocker=Control.new();blocker.mouse_filter=Control.MOUSE_FILTER_STOP;add_child(blocker);blocker.gui_input.connect(_outside)
 for key in host.order_buttons:
  var b=host.order_buttons[key];b.reparent(self);b.set_meta("action",key)
 for i in host.unit_buttons.size():
  var b=host.unit_buttons[i];b.reparent(self);b.set_meta("action",["sub","droneA","droneB"][i]);b.pressed.connect(_selected_craft,CONNECT_DEFERRED)
 host.pause_button.reparent(self);host.pause_button.set_meta("action","pause")
 host.advanced_button.reparent(self);host.advanced_button.set_meta("action","more_orders")
 host.advanced_button.pressed.disconnect(host._toggle_advanced);host.advanced_button.pressed.connect(func():open("fleet"),CONNECT_DEFERRED)
 for i in host.zoom_buttons.size():
  host.zoom_buttons[i].reparent(self);host.zoom_buttons[i].set_meta("action",["zoom_out","zoom_in","fit"][i])
 focus_button=host._button(self,"FOCUS",host._focus_craft,"focus")
 extra.audio_log=host._button(self,"AUDIO\nLOG",func():_extra("audio_log"),"audio_log")
 close_button=host._button(self,"BACK",_back,"radial_back")
 preload("res://src/presentation/field_tool_view.gd").setup(self)
 Cache.setup(self)
 for entry in [["tools_menu","TOOLS"],["route_menu","ROUTE"],["guard_menu","GUARD"],["inspect","STATUS"],["route_here","ROUTE HERE"],["arrivals","ARRIVALS"],["view_menu","VIEW"],["salvage","RECOVER\n4s AUDIBLE"],["rendezvous_release","RELEASE BERTH\n950m / 6s"]]:
  var key=entry[0];extra[key]=host._button(self,entry[1],func():_extra(key),key)
 extra.all_stop=host._button(self,"ALL STOP",func():host._order("all_stop");open("route"),"all_stop")
 extra.shelf_warn=host._button(self,"LOCAL WARNING\n100m / QUIETUS",func():host._order("shelf_warn",{"site":subject.get("site","")}),"shelf_warn")
 extra.shelf_alarm=host._button(self,"SOUND ALARM\n1200m / ONCE",func():host._order("shelf_alarm"),"shelf_alarm")
 for entry in [["depth_menu","DEPTH / SONAR"],["depth_up","SHALLOWER"],["depth_down","DEEPER"],["sonar_sector","SECTOR"],["sonar_power","POWER"],["sonar_emit","EMIT SONAR"],["sonar_history","HISTORY"]]:
  var key=entry[0];extra[key]=host._button(self,entry[1],func():_extra(key),key)
 for pair in [["work","REACH WORK"],["recover","RECOVER\nMATERIAL"],["transfer","TRANSFER\nTO QUIETUS"],["service","RESTORE\nSERVICE"],["sever","SEVER\nSPUR"],["vane","RELEASE\nVANE"],["gate","OPEN\nLOCAL GATE"],["withdraw","WITHDRAW\nAT SOUTH"],["route","ROUTE TO\nREACH WORK"]]:
  var key="glass_"+pair[0];extra[key]=host._button(self,pair[1],func():_extra(key),key)
 for action in ["work","route","attach","release","east","west","lock_a","lock_b","lock_c","bypass","isolate","service","cooling","cradle","land","reconnect","dismantle","recover"]:
  var key="choir_"+action;var text={"work":"CHOIR WORK","route":"ROUTE TO\nLOCAL WORK","east":"START EAST\nVOYAGE","west":"START WEST\nVOYAGE","attach":"ATTACH\nPHYSICAL TOW","release":"RELEASE\nTOW","recover":"WINCH\nMATERIAL"}.get(action,action.replace("_"," ").to_upper())
  extra[key]=host._button(self,text,func():_extra(key),key)
 for i in 3:
  var unit_key="choose_unit_%d"%i;extra[unit_key]=host._button(self,WorkTask.NAMES[i]+"\nORDERS",func():_extra(unit_key),unit_key)
 extra.choose_object=host._button(self,"OBJECT",func():_extra("choose_object"),"choose_object")
 extra.wake_playback=host._button(self,"PLAY OLD LOOP\nONCE ·15s",func():host._order("wake_playback"),"wake_playback")
 for entry in [["warning_exposed","EXPOSED\nUNGATED COURSE"],["warning_sheltered","SHELTERED\nSERVICE COURSE"],["warning_gate","OPEN SERVICE\n650m / 6s"]]:
  var key=entry[0];extra[key]=host._button(self,entry[1],func():_extra(key),key)
 for entry in [["concealed_attach","ATTACH TOW"],["concealed_release","RELEASE TOW"],["concealed_seat","SEAT HERE"],["concealed_work","WITNESS ACCOUNT"]]:
  var key=entry[0];extra[key]=host._button(self,entry[1],func():_extra(key),key)
 instrument_button=extra.inspect
 extra.witness_land=host._button(self,"LAND\nWITNESS",func():host._order("witness_land"),"witness_land")
 for entry in [["blackwater_handoff","TRANSFER\nTO Q"],["blackwater_data","DATA\nTRANSFER"],["blackwater_a","TRANSFER A\nTO QUIETUS"],["blackwater_b","TRANSFER B\nTO QUIETUS"]]:
  var key=entry[0];extra[key]=host._button(self,entry[1],func():_extra(key),key)
 for entry in [["connect","CONNECT\nSHORE"],["disconnect","DISCONNECT"],["backup","START BACKUP\n900m / 6s"],["service","OPEN SERVICE"],["mast","NORTH MAST"],["send","SEND WARNING"]]:
  var key="chain_"+entry[0];extra[key]=host._button(self,entry[1],func():_extra(key),key)
 sheet=PanelContainer.new();add_child(sheet)
 var style=StyleBoxFlat.new();style.bg_color=Color(.018,.055,.075,.94);style.border_color=Color("477b80");style.set_border_width_all(1);style.content_margin_left=18;style.content_margin_right=18;style.content_margin_top=16;style.content_margin_bottom=16;sheet.add_theme_stylebox_override("panel",style)
 measurement_style=StyleBoxFlat.new();measurement_style.bg_color=Color(.018,.055,.075,.92);measurement_style.border_color=Color("477b80");measurement_style.set_border_width_all(1);measurement_style.set_corner_radius_all(8)
 sheet_scroll=ScrollContainer.new();sheet_scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;sheet.add_child(sheet_scroll)
 sheet_body=VBoxContainer.new();var body=sheet_body;body.size_flags_horizontal=Control.SIZE_EXPAND_FILL;body.add_theme_constant_override("separation",8);sheet_scroll.add_child(body);body.minimum_size_changed.connect(_schedule_sheet_fit)
 host.title_label.reparent(body);host.title_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 host.detail_label.reparent(body);host.detail_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 sonar_waterfall=preload("res://src/presentation/sonar_history.gd").new();sonar_waterfall.custom_minimum_size=Vector2(220,100);sonar_waterfall.mouse_filter=Control.MOUSE_FILTER_IGNORE;body.add_child(sonar_waterfall);sonar_waterfall.hide()
 instrument_info=host._label(body,"",18);instrument_info.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 recovery_box=VBoxContainer.new();recovery_box.add_theme_constant_override("separation",8);body.add_child(recovery_box);recovery_box.hide()
 alarm=host._label(self,"",18);alarm.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;alarm.mouse_filter=Control.MOUSE_FILTER_IGNORE
 var alert_style=StyleBoxFlat.new();alert_style.bg_color=Color(.12,.025,.015,.94);alert_style.border_color=Color("b26b52");alert_style.set_border_width_all(1);alert_style.content_margin_left=10;alert_style.content_margin_right=10;alarm.add_theme_stylebox_override("normal",alert_style)
 warning_style=alert_style
 pressure_style=StyleBoxFlat.new();pressure_style.bg_color=Color(0,0,0,0);pressure_style.content_margin_left=10;pressure_style.content_margin_right=10
 intent=host._label(self,"",18);intent.mouse_filter=Control.MOUSE_FILTER_IGNORE;intent.text_overrun_behavior=TextServer.OVERRUN_NO_TRIMMING;intent.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 fleet=preload("res://src/presentation/fleet_instruments.gd").new();add_child(fleet);fleet.setup(host);host.ocean.fleet_instruments=fleet
 guard=preload("res://src/presentation/order_guard.gd").new();add_child(guard);guard.setup(host)
 chart_choice=preload("res://src/presentation/chart_stop_choice.gd").new();add_child(chart_choice);chart_choice.setup(host)
 hints=preload("res://src/presentation/onboarding_hints.gd").new();add_child(hints);hints.setup(host)
func _selected_craft():
 if host.advanced_orders:open("craft",{"kind":"craft","unit":host.sim.selected,"pos":host.sim.units[host.sim.selected].pos})
func open_recovery(destinations:Array):
 for b in recovery_buttons:b.free()
 recovery_buttons.clear()
 for destination in destinations:
  var point:Vector2=destination.pos
  var readiness="FIELD NOTES ONLY" if destination.get("withdrawal",false) else "RECOVERY AVAILABLE" if destination.get("available",false) else "APPROACH · NOT READY"
  var b=host._button(recovery_box,destination.name+"\n"+readiness,func():host._order("route",{"point":point}),"recovery_%d"%recovery_buttons.size())
  # Only popup_gesture may commit a choice; emulated GUI releases can follow a cancelled touch.
  b.mouse_filter=Control.MOUSE_FILTER_IGNORE
  recovery_buttons.append(b)
 open("recovery",{"kind":"craft","unit":host.sim.selected,"pos":host.sim.units[host.sim.selected].pos})
func open(next:String="craft",context:Dictionary={}):
 tool_help.cancel()
 for id in host.map_gesture.touches:owned_touches[id]=true
 host.map_gesture.cancel();host.knock_press.clear();popup_gesture.cancel();sheet_pointers.clear();sector_press=null;host.knock_armed=false;host.decoy_armed=false
 if not context.is_empty():subject=context
 elif subject.is_empty() or next=="fleet":subject={"kind":"craft","unit":host.sim.selected,"pos":host.sim.units[host.sim.selected].pos}
 var station=WarningChain.station_subject(host.sim,subject) if next=="object" else {}
 if not station.is_empty():next="plant";subject=station
 if subject.get("kind","")=="habitat" and next=="object":next="habitat"
 if next=="object":
  var wake=Wake.subject(host.sim,subject)
  if not wake.is_empty():subject=wake
 if next in ["object","inspect"] and subject.get("subkind","")=="wake_repeater":sheet_scroll.scroll_vertical=0
 page=next;instruments_open=page in ["inspect","signals"]
 if page=="object" and WorkTask.pinnable(subject):task=WorkTask.pin(host.sim,subject)
 if page=="inspect" and subject.get("subkind","")=="concealed":sheet_scroll.scroll_vertical=0
 host.advanced_orders=true;host._layout()
func dismiss():
 tool_help.cancel()
 draining_popup=not owned_touches.is_empty()
 host.map_gesture.cancel();host.knock_press.clear();popup_gesture.cancel();sheet_pointers.clear();sector_press=null;host.advanced_orders=false;instruments_open=false;host._layout()
func _back():
 if page=="field_tools":open("tools");return
 if page=="order_help":
  if help_return=="water":dismiss()
  else:open(help_return)
  return
 if host.knock_armed or host.decoy_armed:host._primary_action();dismiss();return
 if page=="signals":
  if details_return=="water":dismiss()
  else:open(details_return)
 elif page=="view":open("fleet")
 elif page in ["craft","object","fleet","salvage","plant","habitat","recovery","choose"]:dismiss()
 else:open("habitat" if subject.get("kind","")=="habitat" else "plant" if subject.get("kind","")=="plant" else "object" if subject.get("kind","")=="objective" else "salvage" if subject.get("kind","")=="salvage" else "craft")
func _extra(key:String):
 if key.begins_with("choose_unit_"):
  var id=int(key.trim_prefix("choose_unit_"))
  if id!=host.sim.selected:host._order("select",{"unit":id})
  open("craft",{"kind":"craft","unit":id,"pos":host.sim.units[id].pos});return
 if key=="choose_object":open(choose_next,subject);return
 if key=="audio_log":
  help_return="fleet";help_text=host.sound.accessibility.history_text();open("order_help");return
 if key=="choir_work":open("choir");return
 if key=="choir_route":
  var targets=preload("res://src/presentation/industrial_view.gd").targets(host.sim)
  if not targets.is_empty():host._order("route",{"point":subject.pos if subject.get("subkind","")=="choir" else targets[0].pos})
  return
 if key.begins_with("choir_"):host._order("choir_action",{"action":key.trim_prefix("choir_")});return
 if key=="glass_work":open("glass");return
 if key=="glass_route":
  var state=host.sim.glass_context();var a=state.artifact
  host._order("route",{"point":a.pos if not a.is_empty() and a.state in ["site","wreck"] else state.work_pos});return
 if key.begins_with("glass_"):
  var args={"action":key.trim_prefix("glass_")}
  if args.action=="transfer":args["carrier"]=host.sim.glass_context().artifact.get("carrier",-1)
  host._order("glass_action",args);return
 if key=="depth_menu":open("acoustics");return
 if key in ["depth_up","depth_down"]:
  host._order("depth",{"band":host.sim.units[host.sim.selected].band+(-1 if key=="depth_up" else 1)});open("acoustics");return
 if key in ["sonar_sector","sonar_power"]:
  var state=host.sim.sonar
  host._order("sonar_mode",{"sector":("forward" if state.sector=="all" else "all") if key=="sonar_sector" else state.sector,"power":("high" if state.power=="low" else "low") if key=="sonar_power" else state.power});open("acoustics");return
 if key=="sonar_emit":host._order("ping");open("acoustics");return
 if key=="sonar_history":details_return="acoustics";open("inspect",{"subkind":"sonar"});return
 if key=="concealed_work":
  var sites=Concealed.subjects(host.sim)
  if not sites.is_empty():open("inspect",sites[0])
  return
 if key.begins_with("concealed_"):
  host._order("concealed_tow",{"action":subject.get("seat","") if key=="concealed_seat" else key.trim_prefix("concealed_")});return
 if key=="warning_gate":host._order("warning_gate");return
 if key in ["warning_exposed","warning_sheltered"]:host._order("warning_depart",{"course":key.trim_prefix("warning_")});return
 if key.begins_with("chain_"):
  var action=key.trim_prefix("chain_");var retained=subject.duplicate(true)
  if action in ["connect","disconnect","backup"]:host._order("chain_power",{"mode":action})
  elif action in ["service","mast"]:host._order("chain_route",{"output":action});open("plant",retained)
  elif action=="send":host._order("chain_send")
  return
 if key=="arrivals":
  details_return="fleet" if host.advanced_orders else "water"
  open("signals",{"kind":"signals","receiver":-1 if host.advanced_orders else host.sim.selected});return
 if key=="route_here":host._order("route",{"point":subject.pos});return
 if key=="salvage":host._order("salvage",{"item":subject.item});return
 if key=="rendezvous_release":host._order("rendezvous_release");return
 if key=="blackwater_data":open("delivery");return
 if key in ["blackwater_handoff","blackwater_a","blackwater_b"]:
  host._order("blackwater_handoff",{"carrier":host.sim.selected if key=="blackwater_handoff" else 1 if key=="blackwater_a" else 2});return
 open({"tools_menu":"tools","route_menu":"route","guard_menu":"guard","inspect":"inspect","view_menu":"view"}[key])
func owns_pointer(event) -> bool:
 var draining=draining_popup
 if (host.advanced_orders or draining) and event is InputEventScreenTouch:
  if event.pressed:owned_touches[event.index]=true
  else:owned_touches.erase(event.index)
  if owned_touches.is_empty():draining_popup=false
 if draining and (event is InputEventScreenTouch or event is InputEventScreenDrag or (event is InputEventMouse and event.device==InputEvent.DEVICE_ID_EMULATION)):return true
 return false
func sector_at(point:Vector2) -> Button:
 if not host.advanced_orders or page in ["inspect","signals","recovery","order_help"] or ring_buttons.is_empty():return null
 var local=StatusView.radial_local(self,point-global_position-center);var distance=local.length()
 if distance<ring_radius-touch_height*.65 or distance>ring_radius+touch_height*.6:return null
 var turn=fposmod(local.angle()+PI/2,TAU)
 var index=posmod(roundi(turn/TAU*ring_buttons.size()),ring_buttons.size())
 return ring_buttons[index]
func plant_button_at(point:Vector2) -> Button:
 for button in ring_buttons:
  if button.get_global_rect().has_point(point):return button
 return sector_at(point)
func recovery_button_at(point:Vector2) -> Button:
 for button in recovery_buttons:
  if button.is_visible_in_tree() and button.get_global_rect().has_point(point):return button
 return null
func witness_button_at(point:Vector2) -> Button:
 # Every projected command has the same tap owner. New actions need no list.
 for button in command_controls():
  if button.is_visible_in_tree() and button.get_global_rect().has_point(point):return button
 return null
func label_at(point:Vector2) -> bool:
 return action_controls().values().any(func(b):return b.get_global_rect().has_point(point))
func popup_input(event) -> bool:
 if (event is InputEventScreenTouch or event is InputEventScreenDrag or event is InputEventMouse) and hints.blocks(event.position):
  tool_help.cancel();popup_gesture.cancel();sector_press=null;return false
 if help_consumed:
  if event is InputEventScreenTouch and not event.pressed:help_consumed=false
  elif event is InputEventMouseButton and not event.pressed:help_consumed=false
  return true
 if event is InputEventMouse and event.device==InputEvent.DEVICE_ID_EMULATION:return false
 var action={};var point=Vector2.ZERO;var pressed=false;var pointer=-1
 if event is InputEventScreenTouch and event.canceled:
  tool_help.cancel();popup_gesture.cancel();sector_press=null;sheet_pointers.erase(event.index);return true
 if event is InputEventScreenTouch:
  point=event.position;pressed=event.pressed;pointer=event.index
  if pressed and popup_gesture.active() and not popup_gesture.touches.has(event.index):dismiss();return true
  action=popup_gesture.feed("press" if pressed else "release",event.index,point)
 elif event is InputEventScreenDrag:
  point=event.position;pointer=event.index;action=popup_gesture.feed("move",event.index,point)
 elif event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT:
  point=event.position;pressed=event.pressed;action=popup_gesture.feed("press" if pressed else "release",-1,point)
 elif event is InputEventMouseMotion and popup_gesture.active():
  point=event.position;action=popup_gesture.feed("move",-1,point)
 if pressed:
  sector_press=witness_button_at(point)
  if sector_press==null:sector_press=recovery_button_at(point) if page=="recovery" else plant_button_at(point) if page=="plant" else null if label_at(point) else sector_at(point)
  if sheet.visible and sheet.get_global_rect().has_point(point) and not label_at(point):sheet_pointers[pointer]=true
  tool_help.arm(self,sector_press)
 if not pressed and (event is InputEventScreenTouch or event is InputEventMouseButton):tool_help.cancel()
 if sheet_pointers.has(pointer):
  if event is InputEventScreenTouch and not event.pressed:sheet_pointers.erase(pointer)
  elif event is InputEventMouseButton and not event.pressed:sheet_pointers.erase(pointer)
  return false
 if action.has("pan") or action.has("zoom"):dismiss();return true
 if action.has("tap") and sector_press!=null:
  var chosen=sector_press;sector_press=null
  var released=witness_button_at(point)
  if released==null:released=recovery_button_at(point) if page=="recovery" else plant_button_at(point) if page=="plant" else sector_at(point)
  if chosen==released and not chosen.disabled:chosen.pressed.emit()
  return true
 return false
func _outside(event):
 if event is InputEventScreenTouch or event is InputEventMouseButton:
  var point=event.position+blocker.global_position
  if label_at(point) or sector_at(point)!=null:return
 if event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_WHEEL_UP,MOUSE_BUTTON_WHEEL_DOWN]:dismiss();accept_event();return
 if (event is InputEventScreenTouch and event.pressed) or (event is InputEventMouseButton and event.pressed):dismiss();accept_event()
func command_controls() -> Array:
 match page:
  "cache":return Cache.controls(self)
  "choose":return choose_units.map(func(id):return extra["choose_unit_%d"%id])+[extra.choose_object]
  "choir":
   var controls=[]
   for action in host.sim.Choir.actions(host.sim):controls.append(extra["choir_"+action])
   return controls+[extra.choir_route,extra.inspect]
  "glass":
   var a=host.sim.glass_context().artifact;var controls=[]
   if not a.is_empty():controls.append(extra.glass_recover if a.state in ["site","wreck"] else extra.glass_transfer)
   if host.sim.mission.id==15:controls.append(extra.glass_vane)
   if host.sim.mission.id==18:controls.append_array([extra.glass_service,extra.glass_sever])
   if host.sim.mission.id in [18,19]:controls.append(extra.glass_gate)
   return controls+[extra.glass_route,extra.glass_withdraw,extra.inspect]
  "acoustics":return [extra.depth_up,extra.depth_down,extra.sonar_emit,extra.sonar_sector,extra.sonar_power,extra.sonar_history]
  "tools","field_tools":return preload("res://src/presentation/field_tool_view.gd").controls(self)
  "route":return [host.order_buttons.queue,host.order_buttons.hold,host.order_buttons.waypoint_mode,host.order_buttons.home,host.order_buttons.program]+([extra.all_stop] if AllStop.available(host.sim) else [])+([extra.guard_menu] if host.sim.selected==0 else [])
  "guard":return [host.order_buttons.contact_hold,host.order_buttons.wait_drone,host.order_buttons.hold]
  "view":return [focus_button,host.zoom_buttons[2],host.zoom_buttons[1],host.zoom_buttons[0]]
  "fleet":return host.unit_buttons+([extra.arrivals] if Expedition.active(host.sim) else [])+[extra.view_menu,host.order_buttons.menu]+([extra.audio_log] if preload("res://src/presentation/frontend/frontend_settings.gd").current.get("audio_captions",false) and not host.sound.accessibility.history.is_empty() else [])
  "object":
   if subject.get("subkind","")=="choir":return [extra.choir_work,extra.route_here,extra.inspect]
   if subject.get("subkind","")=="glass_work":return [extra.glass_work,extra.route_here,extra.inspect]
   if subject.get("subkind","")=="wake_repeater":return [extra.wake_playback,extra.route_here,extra.inspect]
   if subject.get("subkind","")=="concealed":return ([extra.concealed_seat] if not subject.get("seat","").is_empty() else [extra.concealed_attach,extra.concealed_release])+[extra.route_here,extra.inspect]
   if subject.get("subkind","")=="warning_recipient":return [extra.warning_exposed,extra.warning_sheltered,host.order_buttons.camera,extra.route_here,extra.inspect]
   if subject.get("subkind","")=="warning_gate":return [extra.warning_gate,host.order_buttons.camera,extra.route_here,extra.inspect]
   return ([extra.cache_menu] if subject.get("subkind","")=="corridor" and Cache.applies(host.sim) else [])+([extra.witness_land] if Witness.harbour_subject(host.sim,subject) else [])+([extra.rendezvous_release,extra.route_here,extra.inspect] if subject.get("subkind","")=="berth_control" else ([] if subject.get("subkind","")=="transmission" else [extra.route_here])+([] if subject.get("subkind","") in ["corridor","withdrawal"] else [host.order_buttons.camera])+[extra.inspect,host.order_buttons.program,host.order_buttons.queue])
  "habitat":return ([extra.shelf_alarm] if subject.get("site","")=="alarm" else [extra.shelf_warn])+[extra.route_here,extra.inspect]
  "plant":return ([extra.chain_connect,extra.chain_disconnect,extra.chain_backup] if subject.get("station","")=="inlet" else [extra.chain_service,extra.chain_mast,extra.chain_send])+[extra.route_here,extra.inspect]
  "salvage":return [extra.salvage,extra.route_here,extra.inspect]
  "delivery":return [extra.blackwater_a,extra.blackwater_b,extra.inspect]
  "inspect","signals","recovery","order_help":return []
 var controls=[host.order_buttons.camera,extra.depth_menu,host.order_buttons.silent,host.order_buttons.program,extra.route_menu,extra.tools_menu,extra.guard_menu,extra.inspect]
 if Cache.applies(host.sim):controls.append(extra.cache_menu)
 if host.sim.selected==0 and AllStop.available(host.sim):controls[6]=extra.all_stop
 if not host.sim.choir_context().is_empty():controls.append(extra.choir_work)
 if not host.sim.glass_context().is_empty():controls.append(extra.glass_work)
 if Witness.carries(host.sim,host.sim.selected):controls[0]=extra.witness_land
 if Concealed.status(host.sim).get("known",false):controls.append(extra.concealed_work)
 if not Delivery.status(host.sim).is_empty():
  if host.sim.selected==0:controls.append(extra.blackwater_data)
  elif not host.sim.blackwater_handoff_context(host.sim.selected).packets.is_empty():controls.append(extra.blackwater_handoff)
 return controls
func layout(bounds:Vector2,h:float):
 bounds=StatusView.content_bounds(self,bounds)
 position=Vector2.ZERO;size=bounds;touch_height=h
 text_scale=preload("res://src/presentation/frontend/frontend_settings.gd").text_scale()
 var font=maxi(14,roundi(h*.26*text_scale));var bw=h*1.55*text_scale;var bh=h*maxf(1.,text_scale*.9)
 for b in host.order_buttons.values()+host.unit_buttons+extra.values()+[close_button,focus_button,host.pause_button,host.advanced_button]+host.zoom_buttons:
  b.mouse_filter=Control.MOUSE_FILTER_IGNORE if b in command_controls() else Control.MOUSE_FILTER_STOP
  b.hide();b.custom_minimum_size=Vector2(bw,bh);b.size=Vector2(bw,bh);b.add_theme_font_size_override("font_size",font)
  b.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
  var normal=StyleBoxFlat.new();normal.bg_color=Color(0,0,0,0);normal.set_content_margin_all(2)
  var hover=normal.duplicate();hover.bg_color=Color(.2,.62,.65,.14)
  b.add_theme_stylebox_override("normal",normal);b.add_theme_stylebox_override("hover",hover);b.add_theme_stylebox_override("pressed",hover);b.add_theme_stylebox_override("disabled",normal)
  b.add_theme_color_override("font_outline_color",Color("041019"));b.add_theme_constant_override("outline_size",3)
 host.status_label.hide();host.log_label.hide()
 host.pause_button.show();host.pause_button.position=Vector2(12,12);host.pause_button.size=Vector2(bw,bh)
 host.advanced_button.visible=not host.advanced_orders;host.advanced_button.position=Vector2(bounds.x-bw-12,12);host.advanced_button.size=Vector2(bw,bh)
 if preload("res://src/presentation/frontend/frontend_settings.gd").current.get("mirrored_hud",false):
  host.pause_button.position.x=bounds.x-bw-12
  host.advanced_button.position.x=12
 var line_height=ceili(intent.get_theme_font("font").get_height(font))
 intent.position=Vector2(16,bounds.y-line_height*2-14);intent.size=Vector2(bounds.x-32,line_height*2+8);intent.add_theme_font_size_override("font_size",font);intent.custom_minimum_size=Vector2(bounds.x-32,line_height*2+8)
 intent.visible=not host.advanced_orders
 blocker.position=Vector2.ZERO;blocker.size=bounds;blocker.visible=host.advanced_orders
 ring_buttons=command_controls()
 # Reverse side clusters while keeping the top action and readable text upright.
 # The same ordered list drives layout, wedges, fitting and hit testing.
 if preload("res://src/presentation/frontend/frontend_settings.gd").current.get("mirrored_hud",false) and ring_buttons.size()>1:
  var sides=ring_buttons.slice(1);sides.reverse();ring_buttons=[ring_buttons[0]]+sides
 anchor=host.ocean.screen_position(subject.get("pos",host.sim.units[host.sim.selected].pos))
 ring_radius=h*2.25*text_scale
 var edge=Vector2(h*3.1,h*2.9)*text_scale
 var minimum=Vector2(edge.x,minf(h*3.85*text_scale+20,bounds.y-edge.y))
 center=anchor.clamp(minimum,bounds-edge)
 if page in ["inspect","signals","recovery","order_help"]:center=Vector2(bounds.x*.5,bounds.y*.5)
 if host.advanced_orders:
  for i in ring_buttons.size():
   var b=ring_buttons[i];var a=-PI/2+TAU*i/ring_buttons.size()
   b.position=center+Vector2.from_angle(a)*ring_radius-b.size/2;b.show();b.move_to_front()
  close_button.position=CenterLayout.back_rect(center,close_button.size,h,text_scale,ring_buttons).position;close_button.show();close_button.move_to_front()
 recovery_box.visible=host.advanced_orders and page=="recovery"
 for b in recovery_buttons:
  b.custom_minimum_size.y=h;b.add_theme_font_size_override("font_size",font)
 sheet.visible=host.advanced_orders and page in ["inspect","signals","recovery","order_help"]
 if sheet.visible:
  sheet.position=Vector2(maxf(12,center.x-minf(400,bounds.x*.4)),h+24)
  sheet.size=Vector2(minf(800,bounds.x-24),h*2)
  _schedule_sheet_fit()
  close_button.position=Vector2(center.x-h*.775,minf(bounds.y-h-16,sheet.position.y+sheet.size.y+8));sheet.move_to_front();close_button.move_to_front()
 for label in [host.title_label,host.detail_label,instrument_info]:label.add_theme_font_size_override("font_size",font)
 alarm.position=Vector2(bw+32,12);alarm.size=Vector2(maxf(1,bounds.x-h*6.*text_scale-64),h);alarm.add_theme_font_size_override("font_size",font)
 host.pause_button.move_to_front();alarm.move_to_front();refresh();queue_redraw()
# Status text wraps to as many lines as it needs (capped) and grows upward from the bottom edge.
func _fit_intent():
 if intent==null or not intent.visible or size.x<=0:return
 var font=intent.get_theme_font_size("font_size");var line=ceili(intent.get_theme_font("font").get_height(font))
 var wide=maxf(1.,size.x-32)
 var needed=intent.get_theme_font("font").get_multiline_string_size(intent.text,HORIZONTAL_ALIGNMENT_LEFT,wide,font).y
 var height=clampf(ceil(needed)+8,line*2+8,line*5+8)
 intent.custom_minimum_size=Vector2(wide,height);intent.size=Vector2(wide,height);intent.position=Vector2(16,size.y-height-14)
func _schedule_sheet_fit():
 if sheet_fit_pending:return
 sheet_fit_pending=true;call_deferred("_fit_sheet")
func _fit_sheet():
 sheet_fit_pending=false
 if sheet==null or not sheet.visible:return
 var margin=sheet.get_theme_stylebox("panel").get_minimum_size().y
 var maximum=maxf(touch_height*1.5,minf(size.y-touch_height*2-56,touch_height*4.7))
 var height=clampf(sheet_body.get_combined_minimum_size().y+margin,touch_height*1.5,maximum)
 var at=Vector2(sheet.position.x,clampf(center.y-height/2,touch_height+24,size.y-height-touch_height-24))
 if absf(sheet.size.y-height)<.1 and sheet.position.distance_to(at)<.1:return
 sheet.size.y=height;sheet.position=at
 close_button.position=Vector2(center.x-touch_height*.775,sheet.position.y+height+8)
 StatusView.fit_sheet(self)
 host.call_deferred("_report_targets")
func refresh():
 var sim=host.sim
 preload("res://src/presentation/field_tool_view.gd").refresh(self)
 sonar_waterfall.visible=page=="inspect" and subject.get("subkind","")=="sonar"
 sonar_waterfall.sim=sim;sonar_waterfall.queue_redraw()
 var u=sim.units[sim.selected];var transition=u.transition
 extra.all_stop.text=AllStop.label(sim);extra.all_stop.disabled=sim.selected!=0 or not u.alive
 extra.depth_up.text="↑ "+sim.Depth.NAMES[maxi(0,u.band-1)];extra.depth_up.disabled=u.band==0 or not transition.is_empty() or (sim.Depth.SurvivorAscent.count(sim.mission,sim.selected)>0 and u.get("ascent_settle",0.)>0)
 extra.depth_down.text="↓ "+sim.Depth.NAMES[mini(2,u.band+1)];extra.depth_down.disabled=u.band==2 or not transition.is_empty()
 extra.sonar_sector.text="SECTOR\n"+("ALL360°" if sim.sonar.sector=="all" else "FORWARD90°")
 extra.sonar_power.text="POWER\n"+sim.sonar.power.to_upper()
 extra.sonar_emit.text="EMIT\n"+("%s RESERVE"%String.num(snappedf(sim.Sonar.pulse_cost(sim,sim.selected),0.01)));extra.sonar_emit.disabled=sim.ping_time>0 or not transition.is_empty()
 subject=Concealed.refresh_subject(sim,Recipient.refresh_subject(sim,Rendezvous.refresh_subject(sim,subject)))
 host.pause_button.text="PAUSED\n▶ RESUME" if sim.paused else "Ⅱ\nPAUSE"
 host.advanced_button.text="FLEET"
 focus_button.text="FOLLOW" if host.ocean.chart_camera.mode=="follow" else "FOCUS"
 intent.text="%s · %s · %s"%[sim.units[sim.selected].name+" · "+sim.Depth.NAMES[sim.units[sim.selected].band],"QUEUE" if sim.queue_mode else "REPLACE",(host.targeting_feedback if not host.targeting_feedback.is_empty() else "DECOY · TAP CLEAR WATER ≤160m · TAP CANCEL" if host.decoy_armed else "TORPEDO · TAP FRESH CONTACT · TAP CANCEL" if host.knock_armed else sim.message)]
 host.title_label.visible=page not in ["signals","recovery","order_help"];host.detail_label.visible=page not in ["signals","recovery","order_help"]
 host.order_buttons.home.text="WITHDRAW" if Expedition.entry(sim) else "EXTRACT"
 extra.route_here.text="PLOT ROUTE" if subject.has("subkind") else "ROUTE HERE"
 extra.arrivals.text="ARRIVALS\n%d"%Expedition.measurements(sim).size()
 extra.arrivals.disabled=Expedition.measurements(sim).is_empty()
 var sites=host.ocean.observable_sites();var records=sites.filter(func(o):return o.captured).size()
 var summary="KNOWN SITES %d · RECORDED %d"%[sites.size(),records] if Expedition.active(sim) else "RECORDS %d/%d"%[records,sites.size()]
 instrument_info.text=summary+" · DEPTH %dm\n"%sim.mission.depth+"\n".join(host.ocean.acoustic_rows())+"\n"+sim.message
 if subject.get("kind","")=="objective" and subject.get("index",-1)>=0 and subject.index<host.ocean.observable_sites().size():
  var site=host.ocean.observable_sites()[subject.index]
  instrument_info.text=site.name+" · "+("RECORDED" if site.captured else "NOT RECORDED")+"\n"+site.get("requirement","")+"\n"+site.get("unit_requirement","")+"\n"+instrument_info.text
 if subject.get("subkind","") in ["corridor","withdrawal"]:instrument_info.text=Expedition.context_detail(sim,subject)+"\n\n"+instrument_info.text
 FeatureViews.build_context(self)
 if page=="signals":instrument_info.text=Expedition.detail(sim,subject.get("receiver",-1))
 var sampling=Equipment.sample_detail(sim)
 if not sampling.is_empty():
  host.order_buttons.camera.text="FIELD\nSAMPLE"
  intent.text=sim.units[sim.selected].name+" · "+sampling
  instrument_info.text+="\n\n"+sampling
 var operation=Operations.action(sim,subject.get("index",-1) if subject.get("kind","")=="objective" else -1)
 host.order_buttons.camera.disabled=false
 if not operation.is_empty():
  host.order_buttons.camera.text=operation.label;host.order_buttons.camera.disabled=not operation.enabled
  instrument_info.text=Operations.detail(sim,operation.target)+"\n\n"+summary+"\n"+"\n".join(host.ocean.acoustic_rows())
  host.detail_label.text=sim.units[sim.selected].name+" · "+("OWN TRANSMITTER" if operation.label=="TRANSMIT" else "LOCAL MACHINERY CONTROL")
  if sim.capture_feedback().unit>=0:intent.text=sim.units[sim.selected].name+" · "+operation.detail.get_slice("\n",0)
 FeatureViews.build_panel(self)
 if (host.knock_armed or host.decoy_armed) and not host.targeting_feedback.is_empty():
  intent.text=sim.units[sim.selected].name+" · "+host.targeting_feedback
 var photographic=sim.camera_context()
 if preload("res://src/simulation/photo_context.gd").is_photo(sim,photographic):
  host.order_buttons.camera.text="PHOTO";host.order_buttons.camera.disabled=false
 # 119: an object's CAMERA works that object only; the main CAMERA never
 # swaps the owner's unfinished chosen task for a different optional job.
 host.order_buttons.camera.tooltip_text=""
 if page=="object" and WorkTask.pinnable(subject):
  host.order_buttons.camera.tooltip_text=WorkTask.object_reason(sim,int(subject.index))
  if int(photographic.get("target",-1))!=int(subject.index):host.order_buttons.camera.disabled=true
 elif page!="object":
  var held=WorkTask.held_reason(sim,task)
  if not held.is_empty():host.order_buttons.camera.disabled=true;host.order_buttons.camera.tooltip_text=held
 for i in 3:extra["choose_unit_%d"%i].disabled=not sim.units[i].alive
 extra.choose_object.text=str(subject.get("name","OBJECT")).substr(0,14)+"\nBY "+WorkTask.LETTERS[sim.selected]
 var fitted=Equipment.status(sim)
 if not fitted.is_empty():instrument_info.text+="\n\n"+fitted
 if page=="inspect" and subject.get("kind","") in ["craft","fleet"]:
  instrument_info.text=sim.units[sim.selected].name+"\n"+fleet.status(sim.selected)+"\n\n"+instrument_info.text
 if page=="inspect" and sim.selected==0:
  var correlation=Equipment.correlation_detail(sim)
  if not correlation.is_empty():instrument_info.text+="\n\n"+correlation
 FeatureViews.build_activity(self)
 var reach=sim.glass_context()
 if not reach.is_empty():
  for action in reach.actions:
   var button=extra["glass_"+action];button.disabled=not reach.actions[action].ready;button.tooltip_text=reach.actions[action].reason
  extra.glass_transfer.disabled=reach.artifact.get("state","")!="cargo" or reach.artifact.get("carrier",-1)<1
  extra.glass_withdraw.disabled=sim.selected!=0 or sim.units[0].band!=1 or sim.units[0].pos.distance_to(sim.mission.extraction)>65
  if page=="glass":instrument_info.text=reach.detail+"\n"+sim.message
  elif not reach.artifact.is_empty() and reach.artifact.get("carrier",-1)==sim.selected:instrument_info.text+="\nMATERIAL ABOARD · "+reach.artifact.id+" · recover this carrier"
 if page=="recovery":instrument_info.text="%s · CHOOSE RECOVERY\n%s APPROACH"%[sim.units[sim.selected].name+" · "+sim.Depth.NAMES[sim.units[sim.selected].band],"QUEUE" if sim.queue_mode else "REPLACE"]
 FeatureViews.build_badges(self)
 # Water contact readouts own warnings; a popup transfers them above its
 # projection. The quiet top instrument owns only our operation estimate.
 var pressure=sim.recon_feedback()
 var warnings=[]
 for entry in host.ocean.contact_entries():
  if entry.urgent or (entry.fresh and ("REPORT" in entry.text or "STUNNED" in entry.text)):warnings.append(entry.text)
 host.ocean.warnings_in_hud=host.advanced_orders
 alarm.text="\n".join(warnings) if host.advanced_orders else "OP PRESSURE · %s"%pressure.stage
 alarm.visible=not warnings.is_empty() if host.advanced_orders else pressure.hunt>0
 var received=sim.Sonar.feedback(sim,sim.selected).rows.duplicate();received.reverse()
 for row in received:
  if sim.elapsed-row.time>1.2 or row.classification!=preload("res://src/simulation/sweeper_senses.gd").WARNING:continue
  var bearing=fposmod(rad_to_deg(atan2(row.direction.x,-row.direction.y)),360.)
  var heard="HEARD %s · %03d° · %.1fs"%[preload("res://src/simulation/contact_identity.gd").classification(sim,row),roundi(bearing)%360,sim.elapsed-row.time]
  if host.advanced_orders:alarm.text=(alarm.text+"\n" if alarm.visible else "")+heard
  elif warnings.is_empty():alarm.text=heard
  alarm.visible=true;break
 alarm.add_theme_stylebox_override("normal",warning_style if host.advanced_orders else pressure_style)
 alarm.add_theme_color_override("font_color",Color("ffb99b") if host.advanced_orders else Color("bbaa82"))
 var alert_font=alarm.get_theme_font_size("font_size")
 alarm.size=Vector2(maxf(1,size.x-touch_height*6.*text_scale-64),touch_height) if host.advanced_orders else Vector2(minf(size.x-touch_height*3.1*text_scale-56,ThemeDB.fallback_font.get_string_size(alarm.text,HORIZONTAL_ALIGNMENT_LEFT,-1,alert_font).x+22),ThemeDB.fallback_font.get_height(alert_font)+8)
 var blocked=[]
 for button in action_controls().values():
  if button not in fleet.buttons:blocked.append(Rect2(button.global_position-global_position,button.size))
 for label in [intent,alarm]:
  if label.visible:blocked.append(label.get_rect())
 for aid in [guard.panel,guard.undo_button,hints.panel,chart_choice.panel]:
  if aid.visible:blocked.append(Rect2(aid.global_position-global_position,aid.size))
 for rect in host.ocean.contact_readout_rects():blocked.append(rect)
 if host.ocean.optical_feed.is_visible_in_tree():blocked.append(host.ocean.optical_feed.get_rect())
 fleet.visible=not host.advanced_orders and not host.decoy_armed and not host.knock_armed
 if not host.decoy_armed and not host.knock_armed:
  for task_text in [WorkTask.line(sim,task),WorkTask.result_line(task_result),WorkTask.load_status(sim)]:
   if not task_text.is_empty():intent.text+="\n"+task_text
  intent.text+="\n"+sim.Depth.context(sim)
 StatusView.apply(self)
 _fit_intent()
 var aid_font=maxi(14,roundi(touch_height*.26*text_scale))
 guard.refresh(size,touch_height,aid_font,intent.position.y if intent.visible else size.y)
 chart_choice.refresh(size,touch_height,aid_font,intent.position.y if intent.visible else size.y,not guard.panel.visible and not guard.undo_button.visible)
 hints.refresh(size,touch_height,aid_font,host.ocean.instrument_top+touch_height+34)
 preload("res://src/presentation/field_tool_view.gd").place_notice(self)
 fleet.refresh(blocked)
 host.ocean.ui_blocked_rects=occupied_rects().map(func(r):return Rect2(r.position-host.ocean.global_position,r.size))
 if host.decoy_armed or host.knock_armed:
  close_button.text="CANCEL";close_button.position=Vector2(size.x/2-touch_height*.775,size.y-touch_height-12);close_button.show()
 else:close_button.text="CANCEL" if page=="recovery" else "LOCAL ORDERS" if page=="inspect" and subject.get("subkind","")=="concealed" else "BACK";close_button.visible=host.advanced_orders
 if page=="order_help":instrument_info.text=help_text;host.title_label.hide();host.detail_label.hide()
 queue_redraw()
 if page=="acoustics" or sonar_waterfall.visible:
  if sonar_waterfall.visible:host.title_label.hide();host.detail_label.hide()
  instrument_info.text=preload("res://src/presentation/sonar_history.gd").detail(sim)
  if not transition.is_empty():instrument_info.text="%s → %s · %.1fs remaining\n"%[sim.Depth.NAMES[u.band],sim.Depth.NAMES[transition.to],transition.remaining]+instrument_info.text

 HuntMeter.sync(self)

func _draw():
 caption_rects.clear()
 if host==null or not host.advanced_orders:return
 var h=touch_height;var font=ThemeDB.fallback_font;var text_size=maxi(14,roundi(h*.26*text_scale))
 var tether=anchor.clamp(Vector2.ONE*12,size-Vector2.ONE*12)
 draw_line(tether,center,Color(.3,.8,.8,.32),1.5)
 draw_circle(tether,5,Color("80cbc8"),false,1.5)
 if page in ["inspect","signals","recovery","order_help"]:return
 StatusView.draw_disc(self,ring_radius-h*.7,Color(.012,.038,.055,.78))
 for i in ring_buttons.size():
  var points=PackedVector2Array();var from=-PI/2+TAU*(i-.5)/ring_buttons.size()+.012;var until=-PI/2+TAU*(i+.5)/ring_buttons.size()-.012
  for j in 13:points.append(center+StatusView.radial_point(self,lerpf(from,until,j/12.),ring_radius-h*.65))
  for j in 13:points.append(center+StatusView.radial_point(self,lerpf(until,from,j/12.),ring_radius+h*.6))
  draw_colored_polygon(points,Color(.025,.095,.12,.9) if not ring_buttons[i].disabled else Color(.025,.04,.05,.9))
 StatusView.draw_outline(self,ring_radius-h*.65,Color(.3,.72,.74,.45),1.5)
 StatusView.draw_outline(self,ring_radius+h*.6,Color(.3,.72,.74,.6),1.5)
 for i in ring_buttons.size():
  var a=-PI/2+TAU*(i-.5)/ring_buttons.size();var inner=StatusView.radial_point(self,a,ring_radius-h*.65);var outer=StatusView.radial_point(self,a,ring_radius+h*.6)
  draw_line(center+inner,center+outer,Color(.3,.72,.74,.4),1)
 var title=subject.get("name","SITE") if subject.get("kind","") in ["objective","salvage","plant","habitat"] else host.sim.units[host.sim.selected].name
 var caption=page.to_upper() if page!="craft" else ("COMMAND · SITES %d"%host.ocean.observable_sites().size() if Expedition.active(host.sim) else "COMMAND · %d/%d"%[host.ocean.observable_sites().filter(func(o):return o.captured).size(),host.ocean.observable_sites().size()])
 if page=="acoustics":
  var body=host.sim.units[host.sim.selected];caption=host.sim.Depth.NAMES[body.band]
  if not body.transition.is_empty():caption+=" → "+host.sim.Depth.NAMES[body.transition.to]+" %.1fs"%body.transition.remaining
 if page=="plant":caption=WarningChain.power_label(host.sim,WarningChain.context(host.sim))+" · LOCAL 60m"
 if page=="delivery":caption="LOCAL LINK · 60m · SETTLED"
 if page=="salvage":
  var context=host.sim.salvage_context(subject.item)
  caption=host.sim.units[host.sim.selected].name+" · %dm / 60m"%roundi(context.distance)
 if subject.get("subkind","")=="berth_control":caption="AUDIBLE 950m / 6s"
 elif subject.get("subkind","")=="wake_repeater":caption="ONE PLAYBACK · LOCAL65m" if not Wake.context(host.sim).used else "LAST PLAYBACK SPENT"
 elif subject.get("subkind","")=="rendezvous_hull":
  var hull=Rendezvous.projection(host.sim).hull
  if not hull.is_empty():caption=str(hull.phase).to_upper()+" · LOCAL FIX" if hull.live else "STALE · %ds AGO"%floori(hull.age)
 var lines=[title,caption]
 if page=="acoustics":
  var carry=acoustics_carry_caption()
  if not carry.is_empty():lines.append(carry)
 if page=="cache":lines.append_array(Cache.captions(host.sim))
 if page=="plant":lines.append(WarningChain.radial_state(WarningChain.context(host.sim)))
 elif page=="craft" and host.order_buttons.camera in ring_buttons:lines.append_array(camera_caption())
 if page in ["object","salvage","plant","habitat"]:lines.append_array(WorkTask.captions(host.sim,subject))
 if page=="choose":lines.append("CRAFT OR OBJECT?")
 lines=StatusView.captions(self,lines)
 var first_y=CenterLayout.first_baseline(center.y,close_button.get_rect(),h,text_scale,lines.size(),font,text_size)
 for n in lines.size():
  var text=lines[n];var width=font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,text_size).x
  var baseline=Vector2(center.x-width/2,first_y+n*(text_size+CenterLayout.STYLE.line_gap))
  caption_rects.append(Rect2(baseline-Vector2(0,font.get_ascent(text_size)),Vector2(width,font.get_height(text_size))))
  draw_string(font,baseline,text,HORIZONTAL_ALIGNMENT_LEFT,-1,text_size,Color("a8d9d5"))
func acoustics_carry_caption()->String:
 var sim=host.sim
 return sim.Depth.SurvivorAscent.line(sim.mission,sim.selected,sim.units[sim.selected],true)
# What the contextual action is and what it will aim at, shown before the tap (two short lines).
func camera_caption() -> Array:
 var sim=host.sim;var button=host.order_buttons.camera
 var verb=button.text.replace("\n"," ")
 var held=WorkTask.held_reason(sim,task)
 if not held.is_empty():return [verb,"▸ TASK "+WorkTask.label(sim,WorkTask.site(sim,task)).substr(0,16),"HELD · OPEN THE OTHER JOB"]
 var context=sim.camera_context();var target=int(context.get("target",-1))
 if target==-2:return [verb,"▸ SIREN S%d"%(int(context.get("siren",0))+1)]
 if target>=0 and target<sim.mission.objectives.size():
  var site=sim.mission.objectives[target]
  return [verb,"▸ %s"%sim.Photo.label(site).to_upper().substr(0,18),("READY · " if context.get("ready",false) else "NOT READY · ")+"%dm"%roundi(sim.units[sim.selected].pos.distance_to(site.pos))]
 return [verb,"▸ NO SITE IN RANGE"]
func action_controls() -> Dictionary:
 var result={}
 for c in find_children("*","Button",true,false)+host.zoom_buttons:
  if c.is_visible_in_tree() and c.has_meta("action"):result[c.get_meta("action")]=c
 if host.zoom_buttons[2].is_visible_in_tree():result["fit"]=host.zoom_buttons[2]
 return result
func blocks(point:Vector2) -> bool:
 if host.advanced_orders:return true
 if guard!=null and (guard.blocks(point) or hints.blocks(point) or chart_choice.blocks(point)):return true
 for b in action_controls().values():
  if b.get_global_rect().has_point(point):return true
 return host.ocean.optical_feed!=null and host.ocean.optical_feed.is_visible_in_tree() and host.ocean.optical_feed.get_global_rect().has_point(point)
func occupied_rects() -> Array:
 var result=[]
 for c in action_controls().values():result.append(c.get_global_rect())
 # Visual placement avoids the whole plate; blocks() owns only real controls.
 if fleet!=null and fleet.is_visible_in_tree():
  for reading in fleet.readouts:result.append(Rect2(fleet.global_position+reading.rect.position,reading.rect.size))
 if intent.visible:result.append(intent.get_global_rect())
 if alarm.visible:result.append(alarm.get_global_rect())
 if host.advanced_orders:result.append(Rect2(center-Vector2.ONE*(ring_radius+touch_height*.65),Vector2.ONE*(ring_radius+touch_height*.65)*2))
 return result
