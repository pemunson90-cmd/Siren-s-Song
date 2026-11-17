extends RefCounted
# FRAME FORECAST: what the frame the viewfinder shows right now would file as, and what
# would raise it. Presentation only. It reads one Photo.frame() result and applies the
# filing rule Photo.finish() uses (photo_capture.gd frame_usable / frame_quality), so a
# still craft that exposes now files the quality shown here. It ignores dwell time
# (the exposure normally outlasts it), low-light integration that builds during the
# exposure, and any earlier frame of the same record (a record keeps its best).
# REVERT: GradeOnSecure.enabled=false hides both uses; nothing is saved or ruled here.
const Grade=preload("res://src/photo_grade/grade_on_secure.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
const Reason=preload("res://src/photo_grade/unusable_reason.gd")
const Table=preload("res://src/presentation/photo_shutter/shutter_table.gd")
const PricingTable=preload("res://src/simulation/photo_pricing/photo_pricing_table.gd")
# Hints with no " · " tail of their own in the viewfinder row reason.
const HINTS:={"HIDDEN":"go round the subject","CROPPED":"centre the subject","WAITING":"wait for its cycle","OUT OF FOCUS":"press FOCUS to choose it"}
# The camera panel's own advice for the next detail (photo_pricing.readout): hidden, or too dark to resolve.
const LIGHT_HINT:="more light: use the flash, hold still or move closer"
# The sharpness hint the viewfinder prints (photo_pricing_table.gd SOFT_REASON).
const SOFT_HINT:=PricingTable.SOFT_HINT

# {"usable":bool,"q":0..1,"grade":"A"|"B"|"C"} for a frame dictionary and its subject.
static func forecast(frame:Dictionary,o:Dictionary)->Dictionary:
	var rows:Array=frame.get("rows",[])
	var seen:Array=[];var gained:=0.0
	for r in rows:
		if r.ready and float(r.q)>0.0:seen.append(r.id);gained+=float(r.q)
	var tight:bool=str(frame.get("mode","wide"))=="tight"
	var usable:bool=Photo.frame_usable(o.get("subject",{}).get("required",[]),seen,str(frame.get("mode","wide")),str(frame.get("focus","")))
	var coverage:float=gained/maxf(1.0,1.0 if tight else float(rows.size()))
	var q:float=Photo.frame_quality(usable,float(frame.get("sharp",0.0)),coverage)
	# WP-113: when the frame would be unusable, the plain reason (the first required detail that does not resolve now).
	return {"usable":usable,"q":q,"grade":Grade.letter(q),"why":"" if usable else Reason.reason(rows,o.get("subject",{}).get("required",[]),seen,str(frame.get("mode","wide")),str(frame.get("focus","")))}

# WP-113: "FILED 94% · a new frame only helps if …" when this subject's record is already filed this dive, else "".
# The rule it states is Photo.finish(): a record keeps its best, and a later usable frame raises it only through a sharper
# frame (55% of the grade) or a detail no earlier frame showed (45%).
static func filed_note(o:Dictionary)->String:
	if not bool(o.get("captured",false)) or float(o.get("photo_quality",0.0))<=0.0:return ""
	return Table.TEXT.filed_before%roundi(float(o.photo_quality)*100.0)

# What a better frame needs, from the same row reasons the viewfinder status uses.
# readout: photo_pricing.readout for the same craft and subject, when given: its advice for the next detail comes
# first, so the result line says what the panel said ("… hidden from here · go round the subject").
static func hint(frame:Dictionary,readout:Dictionary={})->String:
	if readout.get("hidden",false):return HINTS.HIDDEN
	if readout.get("light",false):return LIGHT_HINT
	for r in frame.get("rows",[]):
		if r.apparent and not r.ready and not str(r.why).is_empty():
			var why:String=str(r.why)
			if " · " in why:return why.split(" · ",true,1)[1]
			for key in HINTS:
				if why.begins_with(key):return HINTS[key]
	return SOFT_HINT
