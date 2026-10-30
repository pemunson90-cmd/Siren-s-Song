extends RefCounted
# RECURRING VOICES: short received lines per operation (briefing radio, one mid-dive message,
# one debrief line) from the recurring characters, and the log of lines the player received.
# Seam: presentation/archive/voice_feed.gd shows lines at briefing, HUD log row and debrief and
# persists the log as the optional archive field "voices" (registered in persistence/save_checks.gd).
# Pure rules, no simulation writes. Fair information: a mid-dive line fires only on the player's
# own progress (a captured objective, a retrieved carrier or a finished site job).
const Table=preload("res://src/campaign/voices/voices_table.gd")
const FIELD="voices"
const MAX_ENTRIES=240
static func key(op:int,slot:String)->String:
	return "%d:%s"%[op,slot]
# {"speaker","text"} for one slot, or {} when the operation has no line there.
static func row(op:int,slot:String)->Dictionary:
	if op==41 and not preload("res://src/campaign/sorley_rescue.gd").enabled:return {}
	var slot_index=Table.SLOTS.find(slot)
	if slot_index<0:return {}
	var set:Array=Table.LINES.get(op,Table.GENERIC if op in Table.GENERIC_IDS else [])
	if slot_index>=set.size():return {}
	return {"speaker":Table.SPEAKERS[set[slot_index][0]],"text":set[slot_index][1]}
static func line(op:int,slot:String)->String:
	var r=row(op,slot)
	return "" if r.is_empty() else "%s: %s"%[r.speaker,r.text]
static func heard(received:Array,op:int,slot:String)->bool:
	return key(op,slot) in received
# Marks a line received. Returns true when the log changed.
static func hear(received:Array,op:int,slot:String)->bool:
	if row(op,slot).is_empty() or heard(received,op,slot) or received.size()>=MAX_ENTRIES:return false
	received.append(key(op,slot))
	return true
# True once the player has made progress this dive that a command voice could legitimately hear.
static func progress(mission:Dictionary)->bool:
	for objective in mission.get("objectives",[]):
		if objective is Dictionary and objective.get("captured",false):return true
	if mission.get("recovered",false):return true
	var state=mission.get("iron_choir",{})
	if state is Dictionary:
		if state.get("receipt",false) or state.get("arrived",false):return true
		for site in state.get("sites",[]):
			if site is Dictionary and site.get("done",false):return true
	return mission.get("glass_reach",{}).get("retrieved",false) if mission.get("glass_reach",{}) is Dictionary else false
# Operations with at least one received line, in operation order.
static func operations(received:Array)->Array:
	var ids=[]
	for entry in received:
		var id=int(str(entry).split(":")[0])
		if id not in ids:ids.append(id)
	ids.sort()
	return ids
# ---- save validation ---------------------------------------------------------
# Registered in persistence/save_checks.gd (archive phase); an absent field is valid.
static func valid_archive(data:Dictionary)->bool:
	return not data.has(FIELD) or valid(data[FIELD])
static func valid(value)->bool:
	if not value is Array or value.size()>MAX_ENTRIES:return false
	var seen=[]
	for entry in value:
		if not entry is String or entry in seen:return false
		var parts=entry.split(":")
		if parts.size()!=2 or not parts[0].is_valid_int() or int(parts[0])<0 or int(parts[0])>99 or parts[0]!=str(int(parts[0])):return false
		if parts[1] not in Table.SLOTS:return false
		seen.append(entry)
	return true
