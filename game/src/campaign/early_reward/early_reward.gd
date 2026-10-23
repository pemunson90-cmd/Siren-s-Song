extends RefCounted
# D2 grants existing hardware, never changes its rules or an active launch.
# Revert: Table.enabled=false stops new grants; saved state/ownership stay valid.
const Table=preload("res://src/campaign/early_reward/reward_table.gd")
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
static func grant(previous:Dictionary,operation:int,outcome:String)->Dictionary:
 if not Table.enabled or previous.get("granted",false) or operation!=Table.GRANT.operation or outcome!="won":return previous.duplicate(true)
 return {"granted":true,"module":Table.GRANT.module}
static func earned(state:Dictionary,original:Array)->Array:
 var result=original.duplicate()
 if state.get("granted",false) and state.module not in result:result.append(state.module)
 return result
static func valid(data:Dictionary)->bool:
 if not data.has("early_reward"):return true
 var state=data.early_reward
 if not state is Dictionary:return false
 if state.is_empty():return true
 if state.size()!=2 or not state.get("granted") is bool or state.get("module")!=Table.GRANT.module:return false
 return not state.granted or (data.get("completed",[]) is Array and Table.GRANT.operation in data.completed)
static func debrief(main)->void:
 var previous=main.early_reward
 main.early_reward=grant(previous,main.mission_index,main.sim.outcome)
 if main.early_reward!=previous:main._menu_text("NEW FITTING · "+Catalog.ITEMS[main.early_reward.module].name,22)
static func fittings(main)->void:
 if main.early_reward.get("granted",false):main._menu_text(Table.GRANT.explanation,16)
