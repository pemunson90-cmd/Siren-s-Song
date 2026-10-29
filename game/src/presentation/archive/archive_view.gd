extends RefCounted
# ARCHIVE view: best photographs, recovered evidence and recovered artifacts grouped by region,
# then the FIELD LOG (messages received and evidence recovered, by operation).
# Seam: archive_nav.gd entry and tabs. Read-only over host.photo_records, recovered_evidence,
# expedition and the voices log; evidence rows open the existing field-record gallery.
const Table=preload("res://src/presentation/archive/archive_table.gd")
const Nav=preload("res://src/presentation/archive/archive_nav.gd")
const Catalog=preload("res://src/campaign/operation_catalog.gd")
const Research=preload("res://src/campaign/glass_research.gd")
const Voices=preload("res://src/campaign/voices/voices.gd")
const Feed=preload("res://src/presentation/archive/voice_feed.gd")
const Dossier=preload("res://src/presentation/siren_dossier/siren_dossier.gd")
const LedgerView=preload("res://src/presentation/ledger/ledger_view.gd")
static func region_of(op:int)->String:
	for region in Table.REGIONS:
		if op>=region[1] and op<=region[2]:return region[0]
	return Table.OTHER_REGION
static func title_of(op:int,cache:Dictionary)->String:
	if not cache.has(op):cache[op]=str(Catalog.make(op).get("title","UNKNOWN")).to_upper()
	return "%02d %s"%[op+1,cache[op]]
# Operation an evidence record belongs to: the catalog's declared records, else its first shot's operation.
static func record_map()->Dictionary:
	var result={}
	for id in Catalog.registered_ids():
		for key in Catalog.definition(id).get("records",[]):
			if not result.has(key):result[key]=id
	return result
static func evidence_op(key:String,entry:Dictionary,records:Dictionary)->int:
	if records.has(key):return records[key]
	var shots:Array=entry.get("shots",[])
	if not shots.is_empty() and shots[0] is Dictionary and shots[0].get("op") is int:return shots[0].op
	return -1
static func photos(host)->Array:
	var result=[]
	for key in host.photo_records:
		var op=int(str(key).split(":")[0])
		var record=host.photo_records[key]
		result.append({"op":op,"quality":float(record.get("photo_quality",0.0)),"distance":float(record.get("photo_distance",0.0))})
	result.sort_custom(func(a,b):return a.quality>b.quality)
	return result
static func artifacts(host)->Array:
	var result=[]
	var state=host.expedition.get("research",{})
	for material in state.get("materials",[]):
		if not Research.RECIPES.has(material):continue
		result.append({"op":Research.RECIPES[material].operation,"name":material.replace("_"," ").to_upper(),
			"spent":material in state.get("spent",[])})
	return result
static func show(host)->void:
	var reading_position=host.scroll.scroll_vertical if host.screen=="archive" else 0
	host.screen="archive";host.sim.paused=true;host._clear_menu()
	Nav.header(host,"archive")
	host._menu_text("ARCHIVE",30)
	host._menu_text("Best photographs, evidence and recovered material by region. Only what you recovered is listed.",15)
	host._button(host.panel_box,"SIREN DOSSIER · OBSERVED ROLES",func():Dossier.show(host),"siren_dossier")
	host._menu_text("CAMPAIGN LEDGER",24)
	var ledger_progress=host.expedition.duplicate(false)
	ledger_progress["completed"]=host._campaign_completed()
	LedgerView.render(host,ledger_progress,host.photo_intel)
	var cache={}
	var done=host._campaign_completed()
	var groups={}
	for region in Table.REGIONS:groups[region[0]]={"photos":[],"evidence":[],"artifacts":[],"done":0,"total":0}
	groups[Table.OTHER_REGION]={"photos":[],"evidence":[],"artifacts":[],"done":0,"total":0}
	for id in Catalog.registered_ids():
		if not preload("res://src/campaign/sorley_rescue.gd").visible(id,host.expedition):continue
		var group=groups[region_of(id)]
		group.total+=1
		if id in done:group.done+=1
	for photo in photos(host):
		var group=groups[region_of(photo.op)]
		if group.photos.size()<Table.PHOTO_ROWS:group.photos.append(photo)
	var keys=host.recovered_evidence.keys()
	var evidence_by_op={}
	var records=record_map()
	for index in keys.size():
		if not preload("res://src/campaign/sorley_rescue.gd").enabled and (str(keys[index]).begins_with("sorley_log_") or keys[index]=="sorley_boy"):continue
		var entry=host.recovered_evidence[keys[index]]
		var op=evidence_op(str(keys[index]),entry,records)
		groups[region_of(op)].evidence.append({"index":index,"op":op,"entry":entry})
		if not evidence_by_op.has(op):evidence_by_op[op]=[]
		evidence_by_op[op].append(entry)
	for artifact in artifacts(host):groups[region_of(artifact.op)].artifacts.append(artifact)
	var any=false
	for name in groups:
		var group=groups[name]
		if group.done==0 and group.photos.is_empty() and group.evidence.is_empty() and group.artifacts.is_empty():continue
		any=true
		host._menu_text("%s · %d OF %d RECOVERED"%[name,group.done,group.total] if group.total>0 else name,20)
		for photo in group.photos:
			host._menu_text("PHOTO · %s · QUALITY %d%%%s"%[title_of(photo.op,cache),roundi(photo.quality*100.0),
				" · %dm"%roundi(photo.distance) if photo.distance>0.0 else ""],15)
		for item in group.evidence:
			var label="EVIDENCE · %s"%str(item.entry.get("name","RECORD")).to_upper()
			host._button(host.panel_box,label,func():host._evidence_gallery(item.index),"archive_evidence_%d"%item.index)
		for artifact in group.artifacts:
			host._menu_text("ARTIFACT · %s · %s"%[artifact.name,"CONSUMED IN RESEARCH" if artifact.spent else "AWAITING RESEARCH"],15)
	if not any:host._menu_text("Nothing recovered yet.",16)
	_field_log(host,evidence_by_op,cache)
	host.call_deferred("_layout")
	(func():
		await host.get_tree().process_frame
		if host.screen=="archive":host.scroll.scroll_vertical=reading_position
	).call_deferred()
# Messages received and evidence recovered, by operation.
static func _field_log(host,evidence_by_op:Dictionary,cache:Dictionary)->void:
	host._menu_text(Table.TEXT.log,24)
	var received=Feed.received(host)
	var ids=Voices.operations(received)
	for op in evidence_by_op:
		if op>=0 and op not in ids:ids.append(op)
	ids.sort()
	if ids.is_empty():
		host._menu_text("No messages received yet. Lines arrive by radio during briefings, dives and debriefs.",15)
		return
	for op in ids:
		if op==41 and not preload("res://src/campaign/sorley_rescue.gd").enabled:continue
		var lines=[title_of(op,cache)]
		for slot in Voices.Table.SLOTS:
			if Voices.heard(received,op,slot):lines.append(Voices.line(op,slot))
		for entry in evidence_by_op.get(op,[]):lines.append("Evidence recovered: %s"%str(entry.get("name","RECORD")))
		host._menu_text("\n".join(lines),15)
