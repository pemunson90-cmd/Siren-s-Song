extends RefCounted
# NEXT STEP: the one plain line the camera panel leads with when the frame is not yet as good as it can be.
# Presentation only. It reads facts the simulation already computed (one Photo.frame() result, the
# photo_pricing readout and the craft's optics) and names the single thing to do next; the numbers stay in the
# readouts below it. No rule, price or grade is changed. The words live in photo_pricing_table.gd (NEXT).
const Table=preload("res://src/simulation/photo_pricing/photo_pricing_table.gd")
# {"label": the detail that is held back, "text": what to do}, or {} when no detail on screen is held back.
# optics: Photo.optics for the craft ("flash" fitted, "integrate" seconds of low-light back); flash_left: charges.
static func read(frame:Dictionary,readout:Dictionary,optics:Dictionary,flash_left:int)->Dictionary:
	for r in frame.get("rows",[]):
		if not r.apparent or r.ready or str(r.why).is_empty():continue
		return {"label":str(r.label),"text":_text(str(r.why),frame,readout,optics,flash_left)}
	return {}
static func _text(why:String,frame:Dictionary,readout:Dictionary,optics:Dictionary,flash_left:int)->String:
	if why.begins_with("HIDDEN"):return Table.NEXT.hidden
	if why.begins_with("CROPPED"):return Table.NEXT.cropped
	if why.begins_with("OUT OF FOCUS"):return Table.NEXT.focus
	if why.begins_with("FINE DETAIL"):return Table.NEXT.tight
	if why.begins_with("WAITING"):return Table.NEXT.cycle
	var reach:int=floori(float(readout.get("plain",0.0)))
	var near:bool=reach>0 and float(frame.get("dist",0.0))>float(reach)
	if why.begins_with("HEAT"):return Table.NEXT.close%reach if near else Table.NEXT.heat
	# Too dark or too soft: the nearest answer first (closer, then light, then stillness), only those this craft has.
	var dark:bool=why.begins_with("TOO DARK")
	if near:return Table.NEXT.close%reach
	if bool(optics.get("flash",false)) and flash_left>0 and not bool(frame.get("flash",false)):return Table.NEXT.light
	if float(optics.get("integrate",0.0))>0.0:return Table.NEXT.hold%roundi(Table.STILL_HOLD)
	return Table.NEXT.dark if dark and not bool(optics.get("flash",false)) else Table.NEXT.soft
