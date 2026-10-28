extends RefCounted
# SAVE2 presentation/archive adapters. No Simulation commands or ending rules.
# Seams: prelaunch, terminal/recovery, archive restore/write and menu presenters.
# Revert Table.enabled=false; retain sidecars and the leaf transaction guard.
const Table=preload("res://src/persistence/save_states/save2_table.gd")
const Storage=preload("res://src/persistence/save_states/save2_store.gd")
const Transaction=preload("res://src/persistence/save_states/save2_transaction.gd")
const Economy=preload("res://src/campaign/economy.gd")
const Ending=preload("res://src/campaign/endings.gd")
const PhotoEnding=preload("res://src/campaign/endings_photo.gd")
static func _persistent(host)->bool:
 if not Table.enabled:return false
 if host.get_property_list().any(func(p):return p.name=="capture_scenario"):
  return str(host.get("capture_scenario")).is_empty()
 return true
static func initial_state(archive:Dictionary)->Dictionary:
 var known=[]
 for id in archive.get("completed",[])+archive.get("expedition",{}).get("completed",[]):
  if id is int and id>=0 and id<=31 and id not in known:known.append(id)
 return {"revision":1,"run_id":Table.identity(),"launch_id":Table.identity(),"credited_launch":"","recoveries":known.size(),"last_recovered":-1,"legacy_minimum":not known.is_empty(),"between":not archive.get("active") is Dictionary}
static func ensure_state(host)->Dictionary:
 if not host.has_meta(Table.STATE):
  host.set_meta(Table.STATE,initial_state({"completed":host.completed,"expedition":host.expedition}))
 return host.get_meta(Table.STATE)
static func manager(host):return Storage.new(host.store.path)
static func manual_allowed(host)->bool:
 return Table.enabled and not locked(host) and not host.store.suspended and (not host.active_started or not host.sim.outcome.is_empty())
# Ironman keeps one timeline: no exact restore, fork replay or new hard save for an Ironman campaign.
# Automatic fork checkpoints, the pending checkpoint and crash recovery are untouched.
static func locked(host)->bool:
 return Table.enabled and Table.ironman_lock and Economy.is_ironman(host.get("economy"))
static func notice(host,text:String,sticky:bool=true)->void:
 # Long SAVE2 details belong in the scrolling saved-state page. A growing
 # fixed archive banner can otherwise cover the body's touch targets.
 var previous=str(host.get_meta("save2_banner",""))
 var lines=Array(host.archive_warning.split("\n",false))
 if not previous.is_empty():lines=lines.filter(func(line):return line!=previous)
 if host.has_meta("save2_banner"):host.remove_meta("save2_banner")
 if text.is_empty():
  if host.has_meta("save2_notice"):host.remove_meta("save2_notice")
 else:host.set_meta("save2_notice",text)
 if sticky and not text.is_empty():
  var banner="Saved-state action needs attention. Open HARD SAVES."
  if text.begins_with("Launch paused:"):banner="Launch paused. Open HARD SAVES for details."
  elif text.begins_with("Saved state loaded"):banner="Saved state loaded."
  lines.append(banner);host.set_meta("save2_banner",banner)
 host.archive_warning="\n".join(lines)
 if host.has_method("_update_archive_status"):host._update_archive_status()
static func write(host,data:Dictionary)->void:
 if not _persistent(host) and not host.has_meta(Table.STATE):return
 var state=ensure_state(host)
 if _persistent(host):state.between=not host.active_started or not host.sim.outcome.is_empty()
 elif not Table.enabled:
  # Maintain existing optional metadata across a disabled build. Tracking may
  # have gaps, and a previous pending candidate cannot identify this dive.
  state.between=not host.active_started or not host.sim.outcome.is_empty()
  state.legacy_minimum=true;state.last_recovered=-1
  state.launch_id=Table.identity();state.credited_launch=""
 data[Table.STATE]=state.duplicate(true)
static func restore(host,data:Dictionary)->void:
 if host.has_meta(Table.STATE):host.remove_meta(Table.STATE)
 if data.has(Table.STATE):
  host.set_meta(Table.STATE,data[Table.STATE].duplicate(true))
  if Table.enabled and data[Table.STATE].between:host.active_started=false
 elif Table.enabled:host.set_meta(Table.STATE,initial_state(data))
 if _persistent(host) and host.has_meta(Table.STATE) and ensure_state(host).between:_publish_pending(host,[])
static func reset(host)->void:
 notice(host,"",false)
 host.set_meta(Table.STATE,initial_state({}))
 for key in ["save2_ui_page","save2_notice","save2_session_error"]:
  if host.has_meta(key):host.remove_meta(key)
static func events(before:Dictionary,after:Dictionary)->Array:
 var result=[]
 if before.get("route","").is_empty() and not after.get("route","").is_empty():result.append("route")
 if before.get("selected_thread","").is_empty() and not after.get("selected_thread","").is_empty():result.append("thread")
 var fields={"confluence_route":"confluence","glass_choice":"glass","choir_choice":"choir_choice","choir_people":"choir_people","choir_plant":"choir_plant"}
 for key in fields:
  if before.get("facts",{}).get(key,"").is_empty() and not after.get("facts",{}).get(key,"").is_empty():result.append(fields[key])
 if Ending.resolve(before).is_empty() and not Ending.resolve(after).is_empty():result.append("first_ending")
 return result
static func _missing(event:String,progress:Dictionary)->bool:
 if event=="first_ending":return Ending.resolve(progress).is_empty()
 if event=="route":return progress.get("route","").is_empty()
 if event=="thread":return progress.get("selected_thread","").is_empty()
 var field={"confluence":"confluence_route","glass":"glass_choice"}.get(event,event)
 return progress.get("facts",{}).get(field,"").is_empty()
static func before_launch(host,index:int)->bool:
 if not _persistent(host):return true
 var state=ensure_state(host)
 if not Transaction.recover(host.store.path):notice(host,"Launch paused: "+Transaction.warning);return false
 _publish_pending(host,[])
 if not Transaction.recover(host.store.path):notice(host,"Launch paused: "+Transaction.warning);return false
 var held=manager(host).inspect("pending",0)
 if held.status=="ready" and held.record.run_id==state.run_id and held.record.launch_id==state.launch_id:
  var target=int(held.record.event)
  if target in Table.TARGETS and events(held.data.get("expedition",{}),host.expedition).any(func(event):return event in Table.TARGETS[target]):
   notice(host,"Launch paused: the previous choice checkpoint still needs saving. Retry after storage recovers, or clear unreadable fork slots in REPLAY FROM FORK. The checkpoint was kept.")
   return false
 var launch=Table.identity()
 var capture_ok=true
 if index in Table.TARGETS and Table.TARGETS[index].any(func(event):return _missing(event,host.expedition)):
  var archive:Dictionary=host._archive().duplicate(true)
  archive[Table.STATE].between=true
  var storage=manager(host)
  if not storage.save_pending(archive,index,state.run_id,launch):
   capture_ok=false;notice(host,storage.warning+" A pre-choice checkpoint could not be recorded.")
 state.launch_id=launch;state.between=false
 if capture_ok:notice(host,"",false)
 return true
static func terminal(host)->void:
 if not _persistent(host) or host.sim.outcome.is_empty():return
 var state=ensure_state(host);state.between=true
 if host.sim.outcome=="won" and state.credited_launch!=state.launch_id:
  if state.recoveries<Table.COUNT_LIMIT:state.recoveries+=1
  else:state.legacy_minimum=true
  state.last_recovered=int(host.sim.mission.id);state.credited_launch=state.launch_id
static func recovered(host,previous:Dictionary)->void:
 if not _persistent(host) or host.sim.outcome!="won":return
 var changed=events(previous,host.expedition)
 if not changed.is_empty():_publish_pending(host,changed)
static func _publish_pending(host,actual:Array)->void:
 if not _persistent(host):return
 var storage=manager(host);var pending=storage.inspect("pending",0)
 if pending.status!="ready":return
 var state=ensure_state(host);var record:Dictionary=pending.record
 if record.run_id!=state.run_id or record.launch_id!=state.launch_id:return
 if pending.data.get(Table.STATE,{}).get("run_id","")!=state.run_id:return
 var target=int(record.event)
 if target not in Table.TARGETS:return
 var changed=events(pending.data.get("expedition",{}),host.expedition)
 var selected=changed.filter(func(event):return event in Table.TARGETS[target] and (actual.is_empty() or event in actual))
 if selected.is_empty():return
 for event in selected:
  if not storage.save_fork(event,pending.data,Table.EVENTS[event]):notice(host,storage.warning+" The pre-choice checkpoint remains pending.");return
 if not storage.delete_entry("pending",0,true,pending.token):notice(host,storage.warning)
static func open(host,kind:String="manual",return_to:String="operations")->void:
 if not Table.enabled:return
 host.sim.paused=true
 load("res://src/persistence/save_states/save2_ui.gd").show(host,kind,return_to,str(host.get_meta("save2_notice","")))
static func back(host)->bool:
 if host.screen!="save2" or not host.has_meta("save2_ui_page"):return false
 return load("res://src/persistence/save_states/save2_ui.gd").back(host)
static func entry(host)->void:
 host.set_meta("save2_delete_states",false)
 if Table.enabled:host._button(host.panel_box,"HARD SAVES",func():open(host),"save2_home")
static func replay_entry(host,return_to:String="ending")->void:
 if Table.enabled:host._button(host.panel_box,"REPLAY FROM FORK",func():open(host,"fork",return_to),"save2_forks")
static func legacy_title(host,normal:String)->String:
 if not Ending.resolve(host.expedition).is_empty() and Ending.campaign_resolve(host.expedition).is_empty():return "PROVISIONAL FORK / "+Ending.resolve(host.expedition).title
 if not Ending.campaign_resolve(host.expedition).is_empty():return "VIEW CAMPAIGN OUTCOME" if normal=="VIEW FORK OUTCOME" else "CAMPAIGN OUTCOME"
 return normal
static func erase_option(host)->void:
 host.set_meta("save2_delete_states",false)
 if not Table.enabled:return
 var check=CheckBox.new();check.text="Also delete this profile's hard saves and fork states";check.custom_minimum_size.y=host.ui_touch_height
 check.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;check.size_flags_horizontal=Control.SIZE_EXPAND_FILL
 check.set_meta("action","save2_erase_states");check.set_meta("ui_action","save2_erase_states")
 check.toggled.connect(func(value):host.set_meta("save2_delete_states",value));host.panel_box.add_child(check)
static func before_erase(host)->bool:
 var retained_notice=""
 if Table.enabled and host.get_meta("save2_delete_states",false):
  var storage=manager(host)
  if not storage.delete_all(true):notice(host,storage.warning+" Current campaign was kept.");return false
  retained_notice=storage.warning
 reset(host)
 if not retained_notice.is_empty():notice(host,retained_notice)
 return true
