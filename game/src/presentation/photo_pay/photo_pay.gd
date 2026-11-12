extends RefCounted
# WP-10 [AI-DESIGNED] PHOTO PAY: shows what each secured photograph paid.
# Read-only. It never computes a reward: it reads the intel the profile already
# stored (host.photo_intel, written by PhotoIntel.recover() before either debrief
# draws) and the thresholds in PhotoIntel.PROJECTS and RETURNED_FILM.
# Seams (one line each):
#   flow/campaign_flow.gd     debrief(): after _show_photo_grade, PhotoPay.debrief(host)
#   expedition_operations.gd  debrief(): after the INTEL PHOTO GRADE line, PhotoPay.debrief(main)
#   archive/archive_view.gd   show(): under each PHOTO row, PhotoPay.archive_line(...)
# REVERT: PayTable.enabled=false. No saved field, no rule, no number changes.
const Table=preload("res://src/presentation/photo_pay/pay_table.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
const Intel=preload("res://src/campaign/photo_intel.gd")
const Grade=preload("res://src/photo_grade/grade_on_secure.gd")
const Equipment=preload("res://src/equipment/equipment_catalog.gd")

# Secured photographic records of a mission with their index: objectives, then studies.
static func records(mission:Dictionary)->Array:
	var result=[]
	var objectives:Array=mission.get("objectives",[])
	for i in objectives.size():result.append({"o":objectives[i],"index":i})
	var studies:Array=mission.get("photo",{}).get("studies",[])
	for n in studies.size():result.append({"o":studies[n],"index":Photo.STUDY+n})
	return result.filter(func(r):return r.o.get("captured",false) and r.o.has("photo_quality") and Photo.applies(r.o))

# Intel keys each usable frame of a record carried home, with the frame's own value.
static func carried(mission:Dictionary,index:int)->Dictionary:
	var keys={}
	for shot in mission.get("photo",{}).get("shots",[]):
		if int(shot.get("obj",-1))!=index or not shot.get("usable",false):continue
		for key in shot.get("intel",{}):keys[key]=maxf(float(keys.get(key,0.0)),float(shot.intel[key]))
	return keys

# True when the stored entry is this dive's film: same operation and the same value.
static func credited(entry:Dictionary,mission:Dictionary,value:float)->bool:
	return not entry.is_empty() and int(entry.get("op",-1))==int(mission.get("id",-2)) and absf(float(entry.q)-snappedf(value,0.01))<0.005

static func debrief_text(mission:Dictionary,intel:Dictionary)->String:
	if not Table.enabled:return ""
	var lines:PackedStringArray=[]
	var all_keys={}
	for r in records(mission):
		var o:Dictionary=r.o;var q:float=float(o.photo_quality)
		var keys:=carried(mission,int(r.index))
		var paid:PackedStringArray=[]
		for key in keys:
			all_keys[key]=true
			var entry:Dictionary=intel.get(key,{})
			if credited(entry,mission,float(keys[key])):paid.append(Table.TEXT.credited%[Intel.label(key),roundi(float(entry.q)*100)])
			elif not entry.is_empty():paid.append(Table.TEXT.kept%[Intel.label(key),roundi(float(keys[key])*100),roundi(float(entry.q)*100),int(entry.op)+1])
		var name:String=Photo.label(o).to_upper().substr(0,Table.RECORD_NAME_CHARS)
		lines.append(Table.TEXT.record%[name,Grade.letter(q),roundi(q*100),", ".join(paid) if not paid.is_empty() else Table.TEXT.none])
	if lines.is_empty():return ""
	for item in Intel.PROJECTS:
		var p:Dictionary=Intel.PROJECTS[item]
		if not all_keys.has(p.intel):continue
		var have:=float(intel.get(p.intel,{}).get("q",0.0))
		var item_name:String=str(Equipment.ITEMS[item].name).to_upper()
		if have>=float(p.q):lines.append(Table.TEXT.cut%[item_name,Intel.label(p.intel),roundi(have*100)])
		else:lines.append(Table.TEXT.short%[item_name,Intel.label(p.intel),roundi(float(p.q)*100),roundi(have*100)])
	for row in Intel.RETURNED_FILM:
		if all_keys.has(row.key) and Intel.ok({"intel":intel},row.key):
			lines.append(Table.TEXT.chart%[Intel.label(row.key),", ".join(PackedStringArray(row.ops.map(func(id):return str(int(id)+1))))])
	return Table.TEXT.head+"\n"+"\n".join(lines)

static func debrief(host)->void:
	var text:=debrief_text(host.sim.mission,host.photo_intel)
	if not text.is_empty():host._menu_text(text,17)

# One archive line for an operation's photographs: the intel the profile holds from it.
static func archive_line(intel:Dictionary,op:int)->String:
	if not Table.enabled:return ""
	var parts:PackedStringArray=[]
	var keys=intel.keys();keys.sort()
	for key in keys:
		if int(intel[key].get("op",-1))==op:parts.append(Table.TEXT.credited%[Intel.label(key),roundi(float(intel[key].q)*100)])
	return Table.TEXT.archive%", ".join(parts) if not parts.is_empty() else Table.TEXT.archive_none
