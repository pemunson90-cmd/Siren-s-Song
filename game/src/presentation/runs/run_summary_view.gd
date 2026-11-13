extends RefCounted
# Shared terminal summary for the session and mode history. Existing scroll UI.
# Revert: remove the two view calls; keep saved records and validators.
const Records=preload("res://src/campaign/runs/run_records.gd")
const Catalog=preload("res://src/campaign/operation_catalog.gd")
const Tools=preload("res://src/equipment/field_tools.gd")
const ResultText=preload("res://src/presentation/mode_result_text.gd")
static func lines(row:Dictionary)->Array:
	var out=["Seed %d: %d of %d operations cleared."%[row.seed,row.depth,row.total],"Loadout: %s. Supplies: %s. Hunt started at stage %d."%[Tools.loadout_label(row.loadout),Records.Table.SCARCITY[row.scarcity],row.hunt_stage]]
	# Only tools that were spent or gained are listed; an unused run has no block.
	var used:Array=[]
	for key in Records.Table.TOOLS:
		var change=ResultText.tool_change(Tools.spec(key).name,row.spent[key],row.gained[key])
		if not change.is_empty():used.append(change)
	if not used.is_empty():out.append("Tools used and gained:");out.append_array(used)
	out.append("Best photo in each operation:")
	for op in row.operations:
		out.append("%s: %s, %s."%[Catalog.make(op.op,{}).title,op.outcome,ResultText.photo_word(op.photo)])
	return out
static func session(host)->void:
	var row=Records.summary(host.run_state)
	if row.is_empty():return
	# The result header already states the seed and the recovered count; skip the repeat.
	for line in lines(row).slice(1):host._menu_text(line,17)
static func detail(front,row:Dictionary,back:Callable,replay:Callable)->void:
	front._reset("run_record")
	front._button("BACK",back,"frontend_back")
	front._text("EXPEDITION LOST" if row.status=="lost" else "EXPEDITION CLEARED",30)
	for line in lines(row):front._text(line,17)
	front._text("Replay keeps the seed's starting modifiers. Your offer and rider choices may change the route and supplies.",16)
	front._button("REPLAY THIS SEED",replay,"run_replay")
