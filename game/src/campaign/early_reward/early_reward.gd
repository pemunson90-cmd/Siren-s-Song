extends RefCounted
# D2 grants existing hardware, never changes its rules or an active launch.
# Revert: Table.enabled=false stops new grants; saved state/ownership stay valid.
# Save field: {"granted":true,"modules":[ids]}. The older {"granted":true,"module":id} still loads.
const Table=preload("res://src/campaign/early_reward/reward_table.gd")
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
static func owned(state:Dictionary)->Array:
 if state.get("modules") is Array:return state.modules.duplicate()
 if state.get("granted",false) and state.get("module") is String:return [state.module]
 return []
static func grant(previous:Dictionary,operation:int,outcome:String)->Dictionary:
 if not Table.enabled or outcome!="won":return previous.duplicate(true)
 var have=owned(previous)
 for g in Table.GRANTS:
  if g.operation==operation and g.module not in have:
   have.append(g.module)
   return {"granted":true,"modules":have}
 return previous.duplicate(true)
static func earned(state:Dictionary,original:Array)->Array:
 var result=original.duplicate()
 for module in owned(state):
  if module not in result:result.append(module)
 return result
static func valid(data:Dictionary)->bool:
 if not data.has("early_reward"):return true
 var state=data.early_reward
 if not state is Dictionary:return false
 if state.is_empty():return true
 var done=data.get("completed",[])
 if state.has("modules"):
  if state.size()!=2 or state.get("granted")!=true or not state.modules is Array or state.modules.is_empty():return false
  var seen=[]
  for module in state.modules:
   var g=Table.entry(module) if module is String else {}
   if g.is_empty() or module in seen or not done is Array or g.operation not in done:return false
   seen.append(module)
  return true
 if state.size()!=2 or not state.get("granted") is bool or state.get("module")!=Table.GRANT.module:return false
 return not state.granted or (done is Array and Table.GRANT.operation in done)
static func debrief(main)->void:
 var previous=main.early_reward
 main.early_reward=grant(previous,main.mission_index,main.sim.outcome)
 if main.early_reward!=previous:
  for module in owned(main.early_reward):
   if module not in owned(previous):main._menu_text("NEW FITTING · "+Catalog.ITEMS[module].name,22)
static func fittings(main)->void:
 var have=owned(main.early_reward)
 for g in Table.GRANTS:
  if g.module in have:main._menu_text(g.explanation,16)
