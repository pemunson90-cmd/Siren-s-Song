extends RefCounted
# Photographic intelligence. Film that comes home becomes intel: the best
# quality at which each feature was resolved. Intel is knowledge about the
# world, never a mission completion flag. It feeds two things:
#   research - camera hardware cut from what the archive shows (PROJECTS)
#   effects  - what a later operation reveals or changes (apply_effects)
# Stored in the save as {key:{"q":quality,"op":operation}}.
const Ops=preload("res://src/campaign/photo_ops.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
const Equipment=preload("res://src/equipment/equipment_catalog.gd")
# item <- intel key and the quality it must be resolved at.
# M1 chart knowledge only. Revert this table and its apply loop to remove the
# new payoffs; no terrain, enemy, tool, story or progression state is changed.
const RETURNED_FILM=[
 {"key":"tender_door","from":7,"ops":[9,12],"mark":{"kind":"route","text":"LOADING LANE · recorded door-side approach","pos":[820.0,760.0]}},
 {"key":"relay_blink","from":8,"ops":[10],"mark":{"kind":"post","text":"RELAY LAMP · recorded 6s gap in a 24s cycle; compare before work","pos":[520.0,1480.0],"period":24.0,"open":6.0,"phase":0.0}},
 {"key":"structure_edge","from":11,"ops":[12,13],"mark":{"kind":"hazard","text":"STRUCTURE EDGE · film records wear, not a live patrol","pos":[1080.0,1840.0],"r":120.0}},
 {"key":"buoy_blind","from":14,"ops":[15],"mark":{"kind":"post","text":"LAMP BACK PLATE · compare this listener with the returned film","pos":[1000.0,2200.0]}},
 {"key":"vane_crack","from":15,"ops":[21],"mark":{"kind":"weak","text":"RELEASE SEAM · compare the latch with the strain-vane crack","pos":[1320.0,1080.0]}},
 {"key":"keel_mark","from":18,"ops":[19],"mark":{"kind":"route","text":"SHELTERED SIDE · prior keel mark names the outer approach","pos":[725.0,1400.0]}},
 {"key":"boat_keel","from":19,"ops":[22],"mark":{"kind":"route","text":"SERVICE LANE · compare the berth with the recovered keel mark","pos":[1800.0,1100.0]}},
 {"key":"locker_latch","from":21,"ops":[23],"mark":{"kind":"weak","text":"SHALLOW LATCH · returned film records the seam pattern","pos":[1250.0,1350.0]}},
 {"key":"shutter_order","from":23,"ops":[24],"mark":{"kind":"post","text":"LOCK SEQUENCE · A B C recorded in the returned lamp film","pos":[2180.0,1120.0]}},
 {"key":"bus_cable","from":24,"ops":[25],"mark":{"kind":"post","text":"REPORTING BRANCH · the ballast cable is recorded","pos":[1800.0,1100.0]}},
 {"key":"spindle_wear","from":26,"ops":[25],"mark":{"kind":"weak","text":"SPINDLE COLLAR · tight scoring frame retained","pos":[850.0,1500.0]}},
 {"key":"slide_mark","from":27,"ops":[25],"mark":{"kind":"hazard","text":"COUNTERWEIGHT SCORE · recorded slide direction retained","pos":[1100.0,1400.0],"r":80.0}},
 {"key":"bell_name","from":28,"ops":[25],"mark":{"kind":"person","text":"HUMAN SURVIVOR MARKS · bell-berth nameplate retained","pos":[800.0,700.0]}},
 {"key":"feed_room","from":29,"ops":[25],"mark":{"kind":"post","text":"SECURITY FEED · terminal marks retained on film","pos":[2450.0,500.0]}}
]
const PROJECTS={
	"photo_flash":{"intel":"foundry_lining","q":0.35,"text":"Foundry lining, resolved: a flash tuned to its glare."},
	"low_light_back":{"intel":"base_cycle","q":0.4,"text":"Base cycle, observed whole: film that gathers a slow exposure."},
	"thermal_imager":{"intel":"exhaust_stack","q":0.35,"text":"Exhaust plume, resolved: a heat-sensing imager."},
	"quietus_tele_lens":{"intel":"prism_facets","q":0.45,"text":"Prism facets, measured: a long lens ground to their angle."}}
static func keys()->Array:
	var result=Ops.intel_keys()
	for type in Photo.SIREN_TYPES:result.append("siren_"+type)
	return result
static func label(key:String)->String:
	if key.begins_with("siren_"):return "SIREN / "+key.substr(6).to_upper()
	return Ops.intel_label(key)
static func ok(context:Dictionary,key:String,minimum:float=0.3)->bool:
	return float(context.get("intel",{}).get(key,{}).get("q",0.0))>=minimum
# Merges film from a recovered dive into the profile, keeping the best of each.
static func recover(previous:Dictionary,mission:Dictionary)->Dictionary:
	var result=previous.duplicate(true)
	var allowed=keys()
	for shot in mission.get("photo",{}).get("shots",[]):
		if not shot.get("usable",false):continue
		for key in shot.get("intel",{}):
			var q=float(shot.intel[key])
			if key in allowed and q>float(result.get(key,{}).get("q",0.0)):result[key]={"q":snappedf(q,0.01),"op":int(shot.op)}
	return result
static func projects(intel:Dictionary)->Array:
	var result=[]
	for item in PROJECTS:
		var p=PROJECTS[item]
		if float(intel.get(p.intel,{}).get("q",0.0))>=p.q:result.append(item)
	return result
static func valid(value)->bool:
	if not value is Dictionary or value.size()>keys().size():return false
	var allowed=keys()
	for key in value:
		var entry=value[key]
		if not key is String or key not in allowed or not entry is Dictionary or entry.size()!=2 or not (entry.get("q") is float or entry.get("q") is int) or entry.q<0 or entry.q>1 or not entry.get("op") is int:return false
	return true
static func detail(intel:Dictionary)->String:
	if intel.is_empty():return "No photographic intelligence has come home yet."
	var lines=[]
	for key in intel:lines.append("%s  %d%%  (dive %d)"%[label(key),roundi(float(intel[key].q)*100),int(intel[key].op)+1])
	var hardware=projects(intel)
	if not hardware.is_empty():lines.append("CAMERA HARDWARE CUT FROM THE ARCHIVE: "+", ".join(hardware.map(func(i):return Equipment.ITEMS[i].name)))
	return "\n".join(lines)
# Operation builders call this once. It changes the world or the brief only
# when the archive actually holds the matching film.
static func apply_effects(m:Dictionary,id:int,context:Dictionary)->void:
	for row in RETURNED_FILM:
		if id not in row.ops or not ok(context,row.key):continue
		var mark=row.mark.duplicate(true)
		mark.merge({"id":"film_"+row.key,"label":mark.text,"q":context.intel[row.key].q,"op":row.from})
		_mark(m,mark)
	if id==19 and ok(context,"silt_scour"):
		# The scour cut under the glass line: the middle water gains a gap.
		var plug=preload("res://src/campaign/encounters/terrain.gd").ridge([Vector2(1100,1410),Vector2(1300,1400)],160,3)
		m.rocks=m.rocks.filter(func(r):return r!=plug)
		m.brief+=" Your Silt Archive photographs showed a scour cut under a glass line. The same cut opens the middle water here, between the west piers and the service gate, away from both buoys."
		_mark(m,{"id":"scour_gap","kind":"gap","text":"SCOUR GAP · from your Silt Archive film","label":"SCOUR GAP · from your Silt Archive film","pos":[1200.0,1405.0],"r":110.0,"q":context.intel.silt_scour.q,"op":17})
	if id==25 and ok(context,"exhaust_stack"):
		m.thermal_revision=1;m.thermal_fronts=[{"area":Rect2(400,700,450,1250),"transmission":0.42,"close_range":90.0}]
		m["photo_lane"]="WARM EXHAUST LANE"
		_mark(m,{"id":"warm_lane","kind":"lane","text":"WARM EXHAUST LANE · from your Furnace Drift film","label":"WARM EXHAUST LANE · from your Furnace Drift film","rect":[400.0,700.0,450.0,1250.0],"q":context.intel.exhaust_stack.q,"op":16})
		m.brief+=" Your Furnace Drift photographs placed warm exhaust along the west channel. The plant breathes the same way here: sound and passive contacts weaken inside that lane, which runs the length of the service channel."

# Marks cut from earlier film: on the chart from the start, never before the film came home.
static func _mark(m:Dictionary,mark:Dictionary)->void:
	if not m.has("photo_marks"):m["photo_marks"]=[]
	m.photo_marks.append(mark)
