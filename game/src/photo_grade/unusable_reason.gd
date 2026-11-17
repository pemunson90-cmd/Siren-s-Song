extends RefCounted
# WP-113: why a frame is (or would be) unusable, in one short plain phrase. Words live in ShutterTable.TEXT.why.
# Presentation only: it reads the rows Photo.frame() already computed and the same "required details" rule
# Photo.frame_usable() applies; it never decides usability. Photo.finish() stores the result on an unusable shot
# ("why") and the SHUTTER forecast calls it before the tap. No Photo preload here, so Photo may preload this.
const Table=preload("res://src/presentation/photo_shutter/shutter_table.gd")
# Row reason prefixes (photo_capture.gd frame()), checked in this order.
const CODES:=["HEAT SHIMMER","TOO DARK","CROPPED","HIDDEN","FINE DETAIL","OUT OF FOCUS","WAITING","TOO SOFT"]

# "SENSOR ARRAY: out of frame". rows: Photo.frame() rows; seen: ids a frame resolved (or the ready ids for a forecast).
static func reason(rows:Array,required:Array,seen:Array,mode:String,focus:String)->String:
	for r in rows:
		var id:String=str(r.get("id",""))
		if id in seen:continue
		if mode=="tight" and not focus.is_empty():
			if id!=focus:continue
		elif not required.is_empty() and id not in required:continue
		var code:String="SHORT"
		if not bool(r.get("ready",false)):
			for c in CODES:
				if str(r.get("why","")).begins_with(c):code=c;break
		return "%s: %s"%[str(r.get("label",id)),Table.TEXT.why[code]]
	return Table.TEXT.why.NONE
