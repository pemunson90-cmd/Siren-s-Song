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
# Hints with no " · " tail of their own in the viewfinder row reason.
const HINTS:={"HIDDEN":"go round to the lit side","CROPPED":"centre the subject","WAITING":"wait for its cycle","OUT OF FOCUS":"press FOCUS to choose it"}
# The sharpness hint the viewfinder prints ("TOO SOFT · closer, lit or still").
const SOFT_HINT:="closer, lit or still"

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
	return {"usable":usable,"q":q,"grade":Grade.letter(q)}

# What a better frame needs, from the same row reasons the viewfinder status uses.
static func hint(frame:Dictionary)->String:
	for r in frame.get("rows",[]):
		if r.apparent and not r.ready and not str(r.why).is_empty():
			var why:String=str(r.why)
			if " · " in why:return why.split(" · ",true,1)[1]
			for key in HINTS:
				if why.begins_with(key):return HINTS[key]
	return SOFT_HINT
