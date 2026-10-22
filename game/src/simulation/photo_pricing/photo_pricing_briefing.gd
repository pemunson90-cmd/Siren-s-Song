extends RefCounted
# Briefing line for the fitting choice: what this operation's photographs ask,
# and what the fitted optics offer. Placeholder text lives in the table.
const Table=preload("res://src/simulation/photo_pricing/photo_pricing_table.gd")
const Equipment=preload("res://src/equipment/equipment_catalog.gd")
static func optics_text(fit:Dictionary)->String:
	var parts:PackedStringArray=[]
	if Equipment.has(fit,0,"quietus_tele_lens"):parts.append("tele 360m, shutter still heard at 520m")
	if Equipment.has(fit,0,"photo_flash"):parts.append("flash, louder")
	if Equipment.has(fit,0,"thermal_imager"):parts.append("thermal imager")
	if Equipment.has(fit,0,"low_light_back"):parts.append("low-light back")
	return ", ".join(parts) if not parts.is_empty() else "standard lens 240m"
# Empty when the operation has no authored photo problems.
static func line(op:int,fit:Dictionary)->String:
	var problems:String=str(Table.PROBLEMS.get(op,""))
	if problems.is_empty():return ""
	return Table.TEXT.problems%problems+"\n"+Table.TEXT.optics%optics_text(fit)
