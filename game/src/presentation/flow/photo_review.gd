extends RefCounted
# Photograph and archive review extracted from main. Main keeps its existing
# entry points as forwarders; host owns state, callbacks and deferred layout.
# Revert this PR to restore the bodies in main. No rules, text or save changes.
static func show_photo_grade(host, records:Array)->void:
	var grade=host.Recon.grade(records)
	if grade.photos>0:host._menu_text("INTEL PHOTO GRADE %s · %d %s · average %d%% of each record's best frame%s"%[grade.grade,grade.photos,"record" if grade.photos==1 else "records",roundi(grade.quality*100),"" if grade.photos==1 else " · sharpest record %d%%"%roundi(grade.best*100)],20)

static func merge_shots(host, key:String) -> void:
	var entry:Dictionary=host.recovered_evidence[key]
	var shots:Array=entry.get("shots",[]).duplicate(true)
	for shot in host.PhotoCapture.shots_for(host.sim.mission,key):
		if not shots.any(func(old):return old.id==shot.id and old.op==shot.op and old.time==shot.time):shots.append(shot.duplicate(true))
	while shots.size()>6:
		var worst:=0
		for i in shots.size():
			if float(shots[i].q)+float(i)*0.002<float(shots[worst].q)+float(worst)*0.002:worst=i
		shots.remove_at(worst)
	if not shots.is_empty():entry["shots"]=shots

static func evidence_is_text(host, entry:Dictionary) -> bool:
	return entry.optical in preload("res://src/campaign/operation_catalog.gd").record_keys(true) or entry.optical in ["well_pattern","well_signature"]

static func retain_evidence(host) -> void:
	for objective in host.sim.mission.objectives+host.PhotoCapture.peek(host.sim).get("studies",[]):
		if objective.captured and objective.has("photo_quality"):
			var key="%d:%d"%[host.sim.mission.id,host.PhotoCapture.index_of(host.sim,objective)]
			if objective.photo_quality>=host.photo_records.get(key,{}).get("photo_quality",0):host.photo_records[key]={"photo_quality":objective.photo_quality,"photo_craft":objective.photo_craft,"photo_distance":objective.photo_distance}
		if objective.captured and objective.has("optical"):
			var earlier:Array=host.recovered_evidence.get(objective.optical,{}).get("shots",[])
			host.recovered_evidence[objective.optical]={"name":objective.name,"caption":objective.evidence,"optical":objective.optical}
			if not earlier.is_empty():host.recovered_evidence[objective.optical]["shots"]=earlier
			for field in ["photo_quality","photo_craft","photo_distance"]:
				if objective.has(field):host.recovered_evidence[objective.optical][field]=objective[field]
			host._merge_shots(objective.optical)
	var signature=host.sim.well_signature_evidence()
	if not signature.is_empty():host.recovered_evidence[signature.optical]=signature

static func evidence_gallery(host, index: int,shot_index:int=-1,compare:bool=false) -> void:
	host._retain_evidence()
	if host.recovered_evidence.is_empty(): host._show_campaign(); return
	host.sim.paused=true; host.screen="evidence"; host._clear_menu()
	var keys=host.recovered_evidence.keys(); var entry=host.recovered_evidence[keys[index%keys.size()]]
	var shots:Array=entry.get("shots",[])
	var kind="PHOTOGRAPH" if not shots.is_empty() else ("ACOUSTIC" if host._evidence_is_text(entry) else ("HYDROPHONE" if entry.optical in ["blackwater_request","blackwater_reply"] else "OPTICAL"))
	host._menu_text("FIELD %s RECORDS / %d OF %d"%[kind,index+1,keys.size()],18)
	host._menu_text(entry.name,28)
	if not shots.is_empty():
		var best:=0
		for i in shots.size():
			if float(shots[i].q)>float(shots[best].q):best=i
		var at:int=best if shot_index<0 else clampi(shot_index,0,shots.size()-1)
		var plate_height:float=minf(300.0,host.size.y*(0.42 if not compare else 0.34))
		var row=HBoxContainer.new();row.add_theme_constant_override("separation",8);host.panel_box.add_child(row)
		var other:int=(at+1)%shots.size()
		for n in (2 if compare and shots.size()>1 else 1):
			var plate=host.PhotoView.Plate.new();plate.vm=host.PhotoView.from_shot(shots[at if n==0 else other]);plate.title="FRAME %d"%((at if n==0 else other)+1)
			plate.size_flags_horizontal=Control.SIZE_EXPAND_FILL;plate.custom_minimum_size=Vector2(0,plate_height);row.add_child(plate)
		host._menu_text(host._shot_report(shots[at],at,shots.size()),16)
		var learned:String=host._shot_findings(shots[at])
		if not learned.is_empty():host._menu_text(learned,17)
		if compare and shots.size()>1:host._menu_text(host._shot_difference(shots[at],shots[other],at,other),16)
		if shots.size()>1:
			host._button(host.panel_box,"NEXT FRAME",func(): host._evidence_gallery(index,(at+1)%shots.size(),compare),"next_shot")
			host._button(host.panel_box,"SINGLE FRAME" if compare else "COMPARE FRAMES",func(): host._evidence_gallery(index,at,not compare),"compare_shots")
	elif not host._evidence_is_text(entry) and preload("res://src/presentation/evidence_catalog.gd").IMAGES.has(entry.optical):
		var image=TextureRect.new(); image.texture=preload("res://src/presentation/evidence_catalog.gd").IMAGES[entry.optical]
		image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; image.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED; image.custom_minimum_size=Vector2(0,minf(320,host.size.y*0.4)); host.panel_box.add_child(image)
	host._menu_text(entry.caption,19)
	host._show_photo_grade([entry])
	if keys.size()>1: host._button(host.panel_box,"NEXT RECORD",func(): host._evidence_gallery((index+1)%keys.size()),"next_record")
	host._button(host.panel_box,"INTEL AND RESEARCH",host._intel_screen,"intel")
	host._button(host.menu_footer,"BACK TO OPERATIONS",host._show_campaign,"back"); host.menu_footer.show()
	host.call_deferred("_layout")

static func shot_report(host, shot:Dictionary,at:int,total:int) -> String:
	var seen:PackedStringArray=[]
	for mark in shot.frame.marks:
		if float(mark.q)>0:seen.append("%s %d%%"%[mark.label,roundi(float(mark.q)*100)])
	var how:="%s · %dm · aspect %d° · %s%s"%[shot.craft,roundi(float(shot.dist)),roundi(rad_to_deg(float(shot.aspect))),str(shot.mode).to_upper()," · flash" if shot.flash else ""]
	var water:="light %d%% · clarity %d%% · sharp %d%%"%[roundi(float(shot.light)*100),roundi(float(shot.clarity)*100),roundi(float(shot.sharp)*100)]
	return "FRAME %d OF %d · QUALITY %d%%%s\n%s\n%s\nRESOLVED: %s"%[at+1,total,roundi(float(shot.q)*100),"" if shot.get("usable",true) else " · UNUSABLE",how,water,", ".join(seen) if not seen.is_empty() else "nothing identifiable"]

static func shot_findings(host, shot:Dictionary) -> String:
	var lines:PackedStringArray=[]
	for f in shot.get("findings",[]):
		lines.append("%s · %s"%[str(f.kind).to_upper(),f.text])
	if lines.is_empty():return ""
	return "OBSERVED IN THIS FRAME · MARKED ON THE CHART\n"+"\n".join(lines)

static func shot_difference(host, a:Dictionary,b:Dictionary,ia:int,ib:int) -> String:
	var only_a:PackedStringArray=[];var only_b:PackedStringArray=[]
	for id in a.features:
		if id not in b.features:only_a.append(str(id))
	for id in b.features:
		if id not in a.features:only_b.append(str(id))
	var lines:PackedStringArray=["FRAME %d vs %d"%[ia+1,ib+1]]
	lines.append("QUALITY frame %d %d%% / frame %d %d%% · distance %dm / %dm · light %d%% / %d%% · clarity %d%% / %d%%"%[ia+1,roundi(float(a.q)*100),ib+1,roundi(float(b.q)*100),roundi(float(a.dist)),roundi(float(b.dist)),roundi(float(a.light)*100),roundi(float(b.light)*100),roundi(float(a.clarity)*100),roundi(float(b.clarity)*100)])
	lines.append("Better frame: %s"%("frame %d"%(ia+1) if float(a.q)>=float(b.q) else "frame %d"%(ib+1)))
	lines.append("Only in frame %d: %s"%[ia+1,", ".join(only_a) if not only_a.is_empty() else "none"])
	lines.append("Only in frame %d: %s"%[ib+1,", ".join(only_b) if not only_b.is_empty() else "none"])
	return "\n".join(lines)

static func intel_screen(host) -> void:
	host.sim.paused=true;host.screen="intel";host._clear_menu()
	host._menu_text("PHOTOGRAPHIC INTELLIGENCE",28)
	host._menu_text("Only film that comes home counts. Each entry is the best frame of that feature.",16)
	host._menu_text(host.PhotoIntel.detail(host.photo_intel),18)
	var pending:PackedStringArray=[]
	for item in host.PhotoIntel.PROJECTS:
		var p=host.PhotoIntel.PROJECTS[item]
		var have:=float(host.photo_intel.get(p.intel,{}).get("q",0.0))
		pending.append("%s %s · needs %s at %d%% (best %d%%)"%["CUT" if have>=p.q else "OPEN",preload("res://src/equipment/equipment_catalog.gd").ITEMS[item].name.to_upper(),host.PhotoIntel.label(p.intel),roundi(float(p.q)*100),roundi(have*100)])
	host._menu_text("CAMERA RESEARCH\n"+"\n".join(pending),17)
	host._button(host.menu_footer,"BACK TO FIELD RECORDS",func(): host._evidence_gallery(0),"back");host.menu_footer.show()
	host.call_deferred("_layout")
