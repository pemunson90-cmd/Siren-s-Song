extends RefCounted
# Shared terminal summary for the session and mode history. Existing scroll UI.
# Revert: remove the two view calls; keep saved records and validators.
const Records=preload("res://src/campaign/runs/run_records.gd")
const Catalog=preload("res://src/campaign/operation_catalog.gd")
const Tools=preload("res://src/equipment/field_tools.gd")
const Words=preload("res://src/presentation/runs/run_words.gd")
const ResultText=preload("res://src/presentation/mode_result_text.gd")
static func lines(row:Dictionary)->Array:
	return summary_lines(row)+operation_lines(row)
# The left column of the run record: the run's modifiers and what it spent and gained.
static func summary_lines(row:Dictionary)->Array:
	var out=["Seed %d: %d of %d operations cleared."%[row.seed,row.depth,row.total],"%s %s%s."%[Words.kit_line(row.loadout),Records.hunt_ceiling(row.hunt_stage),Records.HUNT_CEILING_NOTE],Records.scarcity_line(row.loadout,row.scarcity)]
	# Only tools that were spent or gained are listed; an unused run has no block.
	var used:Array=[]
	for key in Records.Table.TOOLS:
		var change=ResultText.tool_change(Tools.spec(key).name,row.spent[key],row.gained[key])
		if not change.is_empty():used.append(change)
	if not used.is_empty():out.append("Tools used and gained:");out.append_array(used)
	return out
# The right column of the run record: how each operation went.
static func operation_lines(row:Dictionary)->Array:
	var out=["Best photo in each operation:"]
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
	# Wide: the summary on the left, the operations and the replay on the right.
	var boxes=front._split(func():detail(front,row,back,replay))
	front._into(boxes[0],func():
		for line in summary_lines(row):front._text(line,17))
	front._into(boxes[1],func():
		for line in operation_lines(row):front._text(line,17)
		front._text("Replay keeps the seed's starting modifiers. Your offer and rider choices may change the route and supplies.",16)
		front._button("REPLAY THIS SEED",replay,"run_replay"))
