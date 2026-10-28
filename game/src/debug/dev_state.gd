extends RefCounted
# Handoff 101. Optional validated taint is permanent for this profile until a new campaign.
# Revert: stop installing console; retain this validator and taint guards for existing saves.
const Catalog=preload("res://src/campaign/operation_catalog.gd")
const Equipment=preload("res://src/equipment/equipment_catalog.gd")
static func marked(host)->bool:
 if host.get_meta("dev_profile",false):return true
 if host.get_property_list().any(func(p):return p.name=="sim") and host.sim!=null and host.sim.mission!=null and host.sim.mission.get("dev",false):return true
 if host.get_property_list().any(func(p):return p.name=="campaign_host") and is_instance_valid(host.campaign_host):return marked(host.campaign_host)
 return false
static func eligible(host)->bool:return not marked(host)
static func mark(host)->void:
 host.set_meta("dev_profile",true);host.sim.mission["dev"]=true
 if host.get_property_list().any(func(p):return p.name=="campaign_host") and is_instance_valid(host.campaign_host):
  mark(host.campaign_host);host.campaign_host._save_archive()
static func valid(data:Dictionary)->bool:
 if data.has("dev") and not data.dev is bool:return false
 if data.has("dev_setup"):
  var s=data.dev_setup
  if not data.get("dev",false) or not s is Dictionary or not s.has_all(["history","items","completed","cleared"]):return false
  if s.size()!=4 or not s.history is Dictionary or not s.items is Array or not s.completed is Array or not s.cleared is Array:return false
  if s.history.size()>Catalog.fact_keys().size()+2:return false
  for key in s.history:
   if key not in Catalog.fact_keys()+["selected_thread","route"] or not s.history[key] is String or s.history[key].length()>160:return false
  for key in s.cleared:
   if key not in Catalog.fact_keys() or s.cleared.count(key)!=1:return false
  if s.cleared.size()>Catalog.fact_keys().size():return false
  if s.items.size()>Equipment.ITEMS.size():return false
  for item in s.items:
   if item not in Equipment.ITEMS or s.items.count(item)!=1:return false
  if s.completed.size()>Catalog.registered_ids().size():return false
  for id in s.completed:
   if not id is int or id not in Catalog.registered_ids() or s.completed.count(id)!=1:return false
 return true
static func setup(host)->Dictionary:
 if not host.has_meta("dev_setup"):host.set_meta("dev_setup",{"history":{},"items":[],"completed":[],"cleared":[]})
 return host.get_meta("dev_setup")
static func write(host,data:Dictionary)->void:
 if marked(host):
  data["dev"]=true;data["dev_setup"]=setup(host).duplicate(true)
static func restore(host,data:Dictionary,reset:bool=false)->void:
 host.set_meta("dev_profile",data.get("dev",false) or (not reset and marked(host)))
 host.set_meta("dev_setup",data.get("dev_setup",{"history":{},"items":[],"completed":[],"cleared":[]}).duplicate(true))
static func items(host,ordinary:Array)->Array:
 var result=ordinary.duplicate()
 if marked(host):
  for item in setup(host).items:
   if item not in result:result.append(item)
 return result
static func context(host,ordinary:Dictionary)->Dictionary:
 if not marked(host):return ordinary
 var c=ordinary.duplicate(true);var h=setup(host).history
 c["facts"]=c.get("facts",{}).duplicate(true);c.facts.merge(h,true)
 for key in setup(host).cleared:c.facts.erase(key)
 for key in ["route","selected_thread"]:
  if h.has(key):c[key]=h[key]
 if h.has("selected_thread"):c["thread"]=h.selected_thread
 c["completed"]=c.get("completed",[]).duplicate()
 for id in setup(host).completed:
  if id not in c.completed:c.completed.append(id)
 return c
static func preset(thread:String,channel:String,votes:String,sorley:bool)->Dictionary:
 var h={"route":thread,"selected_thread":thread,thread:"DEV recovered branch", "confluence_route":channel}
 if votes=="overt":h.merge({"glass_choice":"service","choir_choice":"bypass","choir_plant":"reconnect"})
 if votes=="concealed":h.merge({"glass_choice":"sever","choir_choice":"isolate","choir_plant":"dismantle"})
 # Handoff 092 uses a recovered rescue fact; absence means no rescued landing.
 if sorley and "sorley_boy" in Catalog.fact_keys():h["sorley_boy"]="rescued"
 return h

static func block_debrief(host)->bool:
 if not marked(host):return false
 if host.get("debug_console")!=null:host.debug_console.debrief()
 else:
  host.sim.paused=true;host.screen="dev_debrief";host._clear_menu()
  host._menu_text("DEV / RESULT EXCLUDED",28)
  host._menu_text("This profile used developer tools. Results cannot earn Ironman credit, challenge bests, expedition records or career standing.",18)
  host._button(host.panel_box,"RETURN",func():leave(host),"dev_return")
 return true

static func leave(host)->void:
 if host.get_property_list().any(func(p):return p.name=="campaign_host") and is_instance_valid(host.campaign_host):
  host.active_started=false
  if host.get_property_list().any(func(p):return p.name=="result_pending"):host.result_pending=false
  if host.get_property_list().any(func(p):return p.name=="recorded"):host.recorded=true
  host._return()
 else:host.active_started=false;host._show_campaign()
