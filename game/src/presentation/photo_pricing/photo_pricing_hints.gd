extends RefCounted
# Chooses which one-verb priced-shot prompt is due. The text, operations and
# ids live in the table; the once-only bookkeeping stays in onboarding_hints.gd.
const Pricing=preload("res://src/simulation/photo_pricing/photo_pricing.gd")
const Table=preload("res://src/simulation/photo_pricing/photo_pricing_table.gd")
static func applies(id:String,op:int)->bool:
	return Table.HINTS.has(id) and op in Table.HINTS[id].ops
static func _armed(sim)->Dictionary:
	if sim.capture_unit>=0 and sim.selected==sim.capture_unit:
		var o=sim.Photo.obj(sim,sim.capture_target)
		return {"o":o,"unit":sim.capture_unit} if sim.Photo.applies(o) else {}
	return sim.Photo.preview(sim,sim.selected)
# The id due now, or "". `seen` tells whether an id was already shown.
static func wanted(sim,op:int,seen:Callable)->String:
	if applies("priced_film",op) and not seen.call("priced_film") and Pricing.film_used(sim)>=2:return "priced_film"
	var due:=false
	for id in ["priced_light","priced_window","priced_reach"]:
		if applies(id,op) and not seen.call(id):due=true
	if not due:return ""
	var view:Dictionary=_armed(sim)
	if view.is_empty():return ""
	var r:Dictionary=Pricing.readout(sim,int(view.unit),view.o)
	if applies("priced_light",op) and not seen.call("priced_light") and r.get("light",false):return "priced_light"
	if applies("priced_window",op) and not seen.call("priced_window") and not Pricing.windows(sim,view.o,sim.Photo.frame(sim,int(view.unit),view.o)).is_empty():return "priced_window"
	if applies("priced_reach",op) and not seen.call("priced_reach"):return "priced_reach"
	return ""
# A camera prompt retires when the camera is put away.
static func stale(sim,id:String)->bool:
	if not Table.HINTS.has(id) or id=="priced_film":return false
	return _armed(sim).is_empty()
