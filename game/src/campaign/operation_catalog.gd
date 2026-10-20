extends RefCounted
# Authored content registry. Factories retain their existing physical implementations.
# A definition selects a factory/configuration, supported behaviors and progression.
const BEHAVIORS=["packet_delivery","tender","warning_plant","witness","recipient","resolution","signals_v1","signals_v2","history"]
static var _entries:Dictionary={}
const CONTENT=[
 {"id":0,"factory":"res://src/campaign/shelf_signal_operation.gd","config":{"source_id":0,"history":false},"behaviors":[],"prerequisites":[],"facts":[],"records":[],"campaign":false,"route":"","required_facts":{}},
 {"id":1,"factory":"res://src/campaign/tutorial_missions.gd","config":{"source_id":1,"history":false},"behaviors":[],"prerequisites":[],"facts":[],"records":[],"campaign":false,"route":"","required_facts":{}},
 {"id":2,"factory":"res://src/campaign/tutorial_missions.gd","config":{"source_id":2,"history":false},"behaviors":["packet_delivery"],"prerequisites":[],"facts":[],"records":["blackwater_request","blackwater_reply"],"campaign":false,"route":"","required_facts":{}},
 {"id":3,"factory":"res://src/campaign/tutorial_missions.gd","config":{"source_id":3,"history":false},"behaviors":[],"prerequisites":[],"facts":[],"records":["furnace","cradle"],"campaign":false,"route":"","required_facts":{}},
 {"id":4,"factory":"res://src/campaign/tutorial_missions.gd","config":{"source_id":4,"history":false},"behaviors":[],"prerequisites":[],"facts":[],"records":["well_pattern","well_signature"],"campaign":false,"route":"","required_facts":{}},
 {"id":5,"factory":"res://src/campaign/tutorial_missions.gd","config":{"source_id":5,"history":false},"behaviors":[],"prerequisites":[],"facts":[],"records":["transmitter","departure","warning"],"campaign":false,"route":"","required_facts":{}},
 {"id":6,"factory":"res://src/campaign/divergence_missions.gd","config":{"source_id":6,"history":false},"behaviors":["signals_v1"],"prerequisites":[],"facts":["deep","shelf"],"records":["divergence_deep","divergence_shelf"],"campaign":true,"route":"","required_facts":{}},
 {"id":7,"factory":"res://src/campaign/divergence_missions.gd","config":{"source_id":7,"history":false},"behaviors":["tender","signals_v1"],"prerequisites":[6],"facts":["rendezvous"],"records":["divergence_rendezvous"],"campaign":true,"route":"deep","required_facts":{}},
 {"id":8,"factory":"res://src/campaign/divergence_missions.gd","config":{"source_id":8,"history":false},"behaviors":["signals_v1"],"prerequisites":[6],"facts":["shelf_warning"],"records":["divergence_warning"],"campaign":true,"route":"shelf","required_facts":{}},
 {"id":9,"factory":"res://src/campaign/onward_missions.gd","config":{"source_id":9,"history":true},"behaviors":["signals_v2","history"],"prerequisites":[7],"facts":["wake_packet","wake_repeater","wake_crossing"],"records":["wake_packet","wake_repeater"],"campaign":true,"route":"deep","required_facts":{}},
 {"id":10,"factory":"res://src/campaign/onward_missions.gd","config":{"source_id":10,"history":true},"behaviors":["warning_plant","signals_v2","history"],"prerequisites":[8],"facts":["chain_west","chain_east","chain_relay","warning_chain"],"records":["chain_west","chain_east","chain_relay"],"campaign":true,"route":"shelf","required_facts":{}},
 {"id":11,"prerequisite_mode":"any","factory":"res://src/campaign/resolution_missions.gd","config":{"source_id":11,"history":true},"behaviors":["resolution","signals_v2","history"],"prerequisites":[9,10],"facts":["confluence_packet","confluence_repeater","confluence_route"],"records":["divergence_confluence_packet","divergence_confluence_repeater"],"campaign":true,"route":"","required_facts":{}},
 {"id":12,"factory":"res://src/campaign/resolution_missions.gd","config":{"source_id":12,"history":true},"behaviors":["witness","resolution","signals_v2","history"],"prerequisites":[11],"facts":["witness_packet","witness_repeater","witness_sluice","witness_arrival","witness_recovery","concealed_consequence","resolution"],"records":["divergence_witness_packet","divergence_witness_repeater","resolution_witness_sluice"],"campaign":true,"route":"","required_facts":{"confluence_route":"concealed"}},
 {"id":13,"factory":"res://src/campaign/resolution_missions.gd","config":{"source_id":13,"history":true},"behaviors":["recipient","resolution","signals_v2","history"],"prerequisites":[11],"facts":["warning_west","warning_east","warning_uplink","warning_transmission","warning_reply","warning_arrival","warning_arrival_hull","warning_service","resolution"],"records":["resolution_warning_transmission","divergence_warning_reply","resolution_warning_west","resolution_warning_east","resolution_warning_uplink"],"campaign":true,"route":"","required_facts":{"confluence_route":"overt"}}
]
static func _ensure():
 if not _entries.is_empty():return
 for entry in CONTENT:_entries[entry.id]=entry.duplicate(true)
static func registered_ids()->Array:
 _ensure();var result=_entries.keys();result.sort();return result
static func definition(id:int)->Dictionary:
 _ensure();return _entries.get(id,{}).duplicate(true)
static func supports(id:int,behavior:String)->bool:
 _ensure();return behavior in _entries.get(id,{}).get("behaviors",[])
static func ids_with(behavior:String)->Array:
 return registered_ids().filter(func(id):return supports(id,behavior))
static func campaign_ids()->Array:
 return registered_ids().filter(func(id):return definition(id).campaign)
static func fact_keys()->Array:
 var keys=[]
 for id in registered_ids():
  for key in _entries[id].facts:
   if key not in keys:keys.append(key)
 return keys
static func valid_definition(d)->bool:
 if not d is Dictionary or not d.has_all(["id","factory","config","behaviors","prerequisites","facts","records","campaign","route","required_facts"]):return false
 if not d.id is int or d.id<0 or not d.factory is String or not d.factory.begins_with("res://src/campaign/") or not ResourceLoader.exists(d.factory):return false
 if not d.config is Dictionary or not d.config.get("source_id") is int or d.config.source_id<0 or not d.config.get("history") is bool or not d.campaign is bool:return false
 if d.get("prerequisite_mode","all") not in ["all","any"]:return false
 if d.route not in ["","deep","shelf"] or not d.required_facts is Dictionary:return false
 for key in d.required_facts:
  if key not in fact_keys() or not d.required_facts[key] is String:return false
 var factory=load(d.factory)
 # Legacy factories declare which source layouts support a different identity.
 if d.id!=d.config.source_id and factory.has_method("supports_identity") and not factory.supports_identity(d.id,d.config):return false
 if not factory.has_method("supports_config") or not factory.supports_config(d.config):return false
 for key in ["behaviors","prerequisites","facts","records"]:
  if not d[key] is Array:return false
  var seen=[]
  for value in d[key]:
   if value in seen:return false
   seen.append(value)
   if key=="behaviors" and value not in BEHAVIORS:return false
   if key=="prerequisites" and (not value is int or value==d.id or value not in registered_ids()):return false
   if key in ["facts","records"] and (not value is String or value.is_empty()):return false
 if not factory.has_method("make") and not factory.has_method("build"):return false
 var sample=factory.build(d.config,{}) if factory.has_method("build") else factory.make(d.config.source_id,{}) if d.config.history else factory.make(d.config.source_id)
 if not sample is Dictionary or not sample.has_all(["id","objectives","sirens","extraction","rocks"]):return false
 if d.campaign!=sample.has("expedition_revision"):return false
 var payloads={"packet_delivery":"blackwater_delivery","tender":"rendezvous_transport","warning_plant":"warning_chain","witness":"witness_evacuation","recipient":"warning_recipient","resolution":"resolution_revision"}
 for behavior in payloads:
  if (behavior in d.behaviors)!=sample.has(payloads[behavior]):return false
 if ("signals_v1" in d.behaviors)!=(sample.get("expedition_revision",0)==1) or ("signals_v2" in d.behaviors)!=(sample.get("expedition_revision",0)==2):return false
 return true
static func register_definition(d:Dictionary)->bool:
 _ensure()
 if not valid_definition(d) or _entries.has(d.id):return false
 _entries[d.id]=d.duplicate(true);return true
static func make(id:int,history:Dictionary={})->Dictionary:
 var d=definition(id)
 if d.is_empty():return {}
 var factory=load(d.factory)
 var m=factory.build(d.config,history) if factory.has_method("build") else factory.make(d.config.source_id,history) if d.config.history else factory.make(d.config.source_id)
 if not m is Dictionary or not m.has_all(["id","objectives","sirens","extraction","rocks"]):return {}
 m.id=id
 return m
static func prerequisites_met(id:int,completed:Array)->bool:
 var d=definition(id)
 if d.is_empty():return false
 if d.get("prerequisite_mode","all")=="any":return d.prerequisites.is_empty() or d.prerequisites.any(func(required):return required in completed)
 return d.prerequisites.all(func(required):return required in completed)
static func accessible(id:int,progress:Dictionary)->bool:
 var d=definition(id)
 if d.is_empty() or not d.campaign or not prerequisites_met(id,progress.get("completed",[])):return false
 if not d.route.is_empty() and progress.get("route","")!=d.route:return false
 for key in d.required_facts:
  if progress.get("facts",{}).get(key)!=d.required_facts[key]:return false
 return true
static func valid_facts(id:int,facts)->bool:
 var d=definition(id)
 if d.is_empty() or not facts is Dictionary:return false
 for key in facts:
  if key not in d.facts or not facts[key] is String:return false
 return true
static func record_keys(campaign_only:bool=false)->Array:
 var keys=[]
 for id in registered_ids():
  var d=_entries[id]
  if campaign_only and not d.campaign:continue
  for key in d.records:
   if key not in keys:keys.append(key)
 return keys
