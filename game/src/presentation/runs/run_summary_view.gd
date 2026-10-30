extends RefCounted
# Shared terminal summary for the session and mode history. Existing scroll UI.
# Revert: remove the two view calls; keep saved records and validators.
const Records=preload("res://src/campaign/runs/run_records.gd")
const Catalog=preload("res://src/campaign/operation_catalog.gd")
const Tools=preload("res://src/equipment/field_tools.gd")
static func lines(row:Dictionary)->Array:
	var out=["SEED %d / %d OF %d OPERATIONS CLEARED"%[row.seed,row.depth,row.total],Records.modifiers(row).replace("STARTING HUNT","EXPEDITION HUNT")]
	out.append("RESOURCES / CHARGES SPENT + GAINED")
	for key in Records.Table.TOOLS:
		out.append("%s: %d spent / %d gained"%[Tools.spec(key).name,row.spent[key],row.gained[key]])
	out.append("BEST PHOTO PER OPERATION")
	for op in row.operations:
		out.append("%s / %s / %s"%[Catalog.make(op.op,{}).title,op.outcome.to_upper(),Records.photo_text(op.photo)])
	return out
static func session(host)->void:
	var row=Records.summary(host.run_state)
	if row.is_empty():return
	for line in lines(row):host._menu_text(line,17)
static func detail(front,row:Dictionary,back:Callable,replay:Callable)->void:
	front._reset("run_record")
	front._button("BACK",back,"frontend_back")
	front._text("EXPEDITION LOST" if row.status=="lost" else "EXPEDITION CLEARED",30)
	for line in lines(row):front._text(line,17)
	front._text("Replay keeps the seed's starting modifiers. Your offer and rider choices may change the route and supplies.",16)
	front._button("REPLAY THIS SEED",replay,"run_replay")
