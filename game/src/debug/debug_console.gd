extends Control
# Debug-only adapter. Rules remain in Simulation. State restoration after each fixed tick
# implements invulnerability while retaining all sensing, lock and damage execution.
# Revert by removing Main.install; retain DevState persistence/eligibility consumers.
const State=preload("res://src/debug/dev_state.gd")
const View=preload("res://src/debug/debug_view.gd")
const Overlay=preload("res://src/debug/debug_overlay.gd")
const Hunt=preload("res://src/simulation/hunt_pressure/hunt_pressure.gd")
const Tools=preload("res://src/equipment/field_tools.gd")
const Racks=preload("res://src/equipment/tool_racks.gd")
const Catalog=preload("res://src/campaign/operation_catalog.gd")
var host
var panel
var overlay
var badge
var time_scale=1.0
var invulnerable=false
var layers={}
var fingers={}
var hold_since=-1
var history:Array=[]
var history_index=0
var metrics={}
var badge_layout_key=0
var last_locks={}
var last_tools={}
var used_drones={}
var transfer=preload("res://src/persistence/profiles/profile_transfer.gd").new()
static func available(debug_build:bool=OS.is_debug_build())->bool:return debug_build
static func install(owner,debug_build:bool=OS.is_debug_build()):
 if not available(debug_build):return null
 var node=load("res://src/debug/debug_console.gd").new();node.host=owner;owner.add_child(node);return node
func _ready()->void:
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);mouse_filter=Control.MOUSE_FILTER_IGNORE;z_index=90
 overlay=Overlay.new();overlay.console=self;overlay.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(overlay)
 badge=Button.new();badge.text="DEV";badge.custom_minimum_size=Vector2(48,48);badge.pressed.connect(open);add_child(badge)
 panel=View.new();panel.console=self;add_child(panel);panel.hide()
 reset_metrics()
func _process(_dt:float)->void:
 size=host.size;overlay.size=size
 badge.visible=State.marked(host)
 var layout_key=hash([size,host.ui_touch_height,host.screen,host.advanced_orders,host.sim.selected,host.mission_hud.page if host.mission_hud!=null else "",panel.visible])
 if layout_key!=badge_layout_key:badge_layout_key=layout_key;layout_badge()
 overlay.queue_redraw()
 if fingers.size()==3 and hold_since>=0 and Time.get_ticks_msec()-hold_since>=850:
  fingers.clear();hold_since=-1;open()
func layout_badge()->void:
 var touch=maxf(48,host.ui_touch_height)
 badge.custom_minimum_size=Vector2.ONE*touch;badge.size=badge.custom_minimum_size
 var occupied=host.mission_hud.occupied_rects() if host.screen=="mission" and host.mission_hud!=null else []
 for control in host.find_children("*","Button",true,false):
  if control!=badge and control.is_visible_in_tree() and not is_ancestor_of(control):occupied.append(control.get_global_rect())
 # Search from the upper right through unoccupied HUD space. Keep every existing
 # actionable control's rectangle intact at either display shape and text scale.
 for y in range(12,maxi(13,int(host.size.y-touch)),int(touch+8)):
  for x in range(maxi(12,int(host.size.x-touch-12)),11,-int(touch+8)):
   var candidate=Rect2(host.global_position+Vector2(x,y),Vector2.ONE*touch)
   if occupied.any(func(rect):return rect.grow(4).intersects(candidate)):continue
   badge.position=Vector2(x,y);return
func input(event:InputEvent)->bool:
 if event is InputEventScreenTouch:
  if event.pressed:fingers[event.index]=event.position
  else:fingers.erase(event.index)
  hold_since=Time.get_ticks_msec() if fingers.size()==3 else -1
 if event is InputEventScreenDrag and fingers.has(event.index):
  if event.position.distance_to(fingers[event.index])>24:fingers.clear();hold_since=-1
 if panel.visible and event is InputEventKey and event.pressed and event.keycode==KEY_ESCAPE:panel.hide();return true
 return false
func open()->void:
 host.sim.paused=true;host.map_gesture.cancel();panel.rebuild();panel.show()
func mark()->void:
 State.mark(host);host._save_archive()
func reset_metrics()->void:
 metrics={"dev":State.marked(host),"operation":host.mission_index,"time":0.,"hull":host.sim.hull,"hunt_peak":0.,"received_lock_episodes":0,"oxygen_margin":host.sim.oxygen,"oxygen_seconds":0.,"tools_spent":{},"drones_used":0}
 last_locks={};last_tools=tool_counts();used_drones={}
func tool_counts()->Dictionary:
 var sim=host.sim;var result={}
 for id in Tools.ids():
  result[id]=Racks.total(sim.mission.tool_racks,id) if sim.mission.has("tool_racks") else sim.tools.get(id,sim.mission.get("field_tools",{}).get("counts",{}).get(id,0))
 return result
func sample()->void:
 var sim=host.sim
 metrics.dev=State.marked(host);metrics.time=sim.elapsed;metrics.hull=sim.hull
 metrics.hunt_peak=maxf(metrics.hunt_peak,Hunt.view(sim).hunt);metrics.oxygen_margin=sim.oxygen
 metrics.oxygen_seconds=sim.oxygen/maxf(.0001,preload("res://src/simulation/operation_endurance.gd").oxygen_drain(sim.mission,1.))
 for i in sim.sirens.size():
  var s=sim.sirens[i];var locked=float(s.get("lock",0))>0 and int(s.get("target",-1))>=0
  if locked and not last_locks.get(i,false):metrics.received_lock_episodes+=1
  last_locks[i]=locked
 var counts=tool_counts()
 for key in counts:
  var spent=maxi(0,int(last_tools.get(key,counts[key]))-int(counts[key]))
  metrics.tools_spent[key]=metrics.tools_spent.get(key,0)+spent
 last_tools=counts
 for i in range(1,sim.units.size()):
  var u=sim.units[i]
  if not u.route.is_empty() or u.pos.distance_to(sim.mission.get("start",sim.units[0].pos))>100 or not u.get("hold","").is_empty():used_drones[i]=true
 metrics.drones_used=used_drones.size()
func advance(dt:float)->void:
 var sim=host.sim
 if sim.paused:return
 # Chunk scaled time at the ordinary fixed step so the simulation's frame cap
 # cannot discard 4x time, and survival restoration happens before the next tick.
 if time_scale==1.0 and not invulnerable:
  sim.advance(dt);sample();return
 var remaining=minf(dt,0.25)*time_scale
 while remaining>0.000001 and sim.outcome.is_empty():
  var amount=minf(remaining,sim.STEP)
  var alive=sim.units.map(func(u):return u.alive)
  var batteries=sim.units.map(func(u):return u.get("battery",100.))
  var hull_before=sim.hull;var oxygen_before=sim.oxygen
  var carried={}
  var bodies=[]
  var paused_before=sim.paused
  if invulnerable:
   for domain in [["iron_choir","load"],["warning_recipient","body"]]:
    var body=sim.mission.get(domain[0],{}).get(domain[1],{})
    if not body.is_empty():bodies.append({"body":body,"before":body.duplicate(true)})
   for key in ["module_recovery","blackwater_delivery","witness_evacuation","glass_reach","iron_choir"]:
    if sim.mission.has(key):carried[key]=sim.mission[key].duplicate(true)
  sim.advance(amount);sample()
  if invulnerable:
   var died=false
   for i in sim.units.size():
    if alive[i] and not sim.units[i].alive:died=true
   if died:
    for key in carried:sim.mission[key]=carried[key]
   for record in bodies:
    var body=record.body;var before=record.before
    if not body.get("alive",true) and before.get("alive",true):body.merge(before,true)
    elif before.has("hull"):body.hull=before.hull
   sim.paused=paused_before
   sim.hull=hull_before;sim.oxygen=oxygen_before
   for i in sim.units.size():sim.units[i].alive=alive[i];sim.units[i].battery=batteries[i]
   if sim.outcome=="lost":sim.outcome="";sim.message="DEV survival restored after damage"
  remaining-=amount
func execute(line:String)->String:
 var a=line.strip_edges().split(" ",false)
 if a.is_empty():return "Enter a command below."
 history.append(line);history_index=history.size()
 var command=a[0].to_lower();var sim=host.sim
 if command=="help":return View.HELP
 if command=="export":export_log();return "Exporting run log."
 if command=="overlay" and a.size()==2 and a[1] in Overlay.LAYERS:
  mark();layers[a[1]]=not layers.get(a[1],false);return a[1]+": "+str(layers[a[1]])
 if command=="time" and a.size()==2 and a[1].is_valid_float() and float(a[1])>=.25 and float(a[1])<=4:
  mark();time_scale=float(a[1]);return "Time scale %.2fx"%time_scale
 if command=="step":
  mark();sim.paused=false;advance(sim.STEP/time_scale);sim.paused=true;return "Advanced one fixed tick."
 if command=="invulnerable":mark();invulnerable=not invulnerable;return "Invulnerable: "+str(invulnerable)
 if command=="oxygen":mark();sim.oxygen=120.;return "Oxygen refilled."
 if command=="end":
  mark();host.active_started=false;debrief();return "DEV dive ended. Setup commands are available."
 if host.active_started and sim.outcome.is_empty() and command in ["preset","fact","clear","complete","grant","unlock","jump"]:
  return "Between dives only. End this dive before changing setup."
 if command=="preset" and a.size()==5 and a[1] in ["deep","shelf"] and a[2] in ["concealed","overt"] and a[3] in ["none","concealed","overt"] and a[4] in ["found","absent"]:
  mark();State.setup(host).history=State.preset(a[1],a[2],a[3],a[4]=="found")
  State.setup(host).cleared=[]
  if a[4]=="absent" and "sorley_boy" in Catalog.fact_keys():State.setup(host).cleared.append("sorley_boy")
  host._save_archive();return "History preset ready."
 if command=="fact" and a.size()>=3 and a[1] in Catalog.fact_keys():
  var value=" ".join(a.slice(2))
  if value.length()>160:return "Fact value is limited to 160 characters."
  mark();State.setup(host).history[a[1]]=value;State.setup(host).cleared.erase(a[1]);host._save_archive();return "Fact set: "+a[1]
 if command=="clear" and a.size()==2 and a[1] in Catalog.fact_keys():
  mark();State.setup(host).history.erase(a[1])
  if a[1] not in State.setup(host).cleared:State.setup(host).cleared.append(a[1])
  host._save_archive();return "Fact cleared: "+a[1]
 if command=="complete" and a.size()==2 and a[1].is_valid_int() and int(a[1]) in Catalog.registered_ids():
  mark();var ids=State.setup(host).completed
  if int(a[1]) not in ids:ids.append(int(a[1]))
  host._save_archive();return "DEV operation complete: "+a[1]
 if command=="unlock":
  mark();State.setup(host).items=State.Equipment.ITEMS.keys()
  host.economy.unlocks=preload("res://src/campaign/economy_table.gd").UNLOCK_PRICE.keys()
  host._save_archive();return "All hardware unlocked."
 if command=="grant" and a.size()>=2:
  var item=a[1];var count=1
  if a.size()==3:
   if not a[2].is_valid_int() or int(a[2])<1:return "Grant count must be positive."
   count=mini(999,int(a[2]))
  if item in State.Equipment.ITEMS:
   mark();var items=State.setup(host).items
   if item not in items:items.append(item)
  elif item in host.economy.stock:
   mark();host.economy.stock[item]=mini(preload("res://src/campaign/economy_table.gd").CAP,host.economy.stock[item]+count)
  elif item in preload("res://src/campaign/economy_table.gd").UNLOCK_PRICE:
   mark()
   if item not in host.economy.unlocks:host.economy.unlocks.append(item)
  elif item in Tools.ids():
   var racks=host.tool_racks.duplicate(true);var slot=Racks.UNITS[sim.selected]
   racks[slot][item]=int(racks[slot].get(item,0))+count
   if not Racks.valid(racks):return "Tool stock limit reached for this craft or tool."
   var reason=Racks.reason(host.fitted_equipment,racks)
   if not reason.is_empty():return reason
   mark();host.tool_racks=racks
  else:return "Unknown resource, tool, module or frame id."
  host._save_archive();return "Granted "+item
 if command=="jump" and a.size()==2 and a[1].is_valid_int() and int(a[1]) in Catalog.registered_ids():
  mark();var id=int(a[1]);host.mission_index=id
  sim.start(id,host.upgrade,{"context":State.context(host,host.CampaignFlow.launch_context(host,id)),"fitted":host.fitted_equipment.duplicate(true),"tool_racks":host.tool_racks.duplicate(true)})
  sim.mission["dev"]=true;host.active_started=true;host.ocean.sim=sim;host.ocean.focus_craft();host.screen="mission";host.menu.hide();host.hud.show();host._layout();reset_metrics();panel.hide();host._save_archive();return "DEV operation launched."
 return "Unknown command or arguments. HELP lists supported commands."
func json_log()->String:
 sample();return JSON.stringify({"format":"sirens-song-dev-run-1","metrics":metrics,"commands":history},"  ")
func export_log()->void:
 var bytes=json_log().to_utf8_buffer();var name="siren-dev-run-%d.json"%Time.get_unix_time_from_system()
 var route=transfer.route()
 var done=func(message):panel.output.text=message
 if route=="none":done.call(transfer.MSG_NONE);return
 if route=="dialog":
  # Same provider routing/write path as profile export; JSON-specific filter.
  DisplayServer.file_dialog_show("Export DEV run log","",name,false,DisplayServer.FILE_DIALOG_MODE_SAVE_FILE,PackedStringArray(["*.json;DEV run log;application/json"]),func(ok,paths,_filter):
   done.call("Run log exported." if ok and not paths.is_empty() and transfer.write_external(paths[0],bytes) else "Export cancelled or failed."))
 else:
  var path=transfer.downloads().path_join(name) if route=="downloads" else "user://"+name
  done.call("Exported: "+ProjectSettings.globalize_path(path) if transfer.write_external(path,bytes) else "Export failed.")
func debrief()->void:
 sample();host.sim.paused=true;host.screen="dev_debrief";host._clear_menu()
 host._menu_text("DEV / DIVE MEASUREMENTS",28);host._menu_text(JSON.stringify(metrics,"  "),17)
 host._menu_text("DEV results excluded from Ironman, challenge bests, expedition records and career standing.",17)
 host._button(host.panel_box,"EXPORT RUN LOG",export_log,"dev_export")
 host._button(host.panel_box,"DEVELOPER CONSOLE",open,"developer")
 host._button(host.panel_box,"RETURN",func():State.leave(host),"dev_return")
 host.call_deferred("_layout");host._save_archive()
