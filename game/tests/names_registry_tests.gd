extends SceneTree
# A6 (WP-22): res://src/names.gd is the one home for Siren role names, craft
# ids and noise labels (and the loadout ids, unit display names, depth band
# names and hunt stages). This suite fails when one of them is typed as text
# again, because a typo in a copy breaks behaviour silently.
#
# What is checked where:
# - Role names, craft ids and every NOISE_* value: any quoted occurrence in any
#   .gd file under res://src outside names.gd, unless ALLOWED lists the file.
#   Comments are ignored. Files ending in _tests.gd under src keep their
#   literals on purpose: they are the independent check that the values did
#   not change.
# - Loadout ids, unit display names, the Q/A/B letters and depth band names are
#   common words, so they are checked only as exact list literals, for example
#   ["SHALLOW","MIDDLE","DEEP"].
# - Hunt stages are checked as the exact five-item list literal.
# To add a name: put it in names.gd, use the constant everywhere, and extend
# the lists below. To allow a leftover, add the file with a reason and count.
const Names=preload("res://src/names.gd")
const EnemyTypes=preload("res://src/simulation/enemy_types.gd")
const FieldTools=preload("res://src/equipment/field_tools.gd")
const RunTable=preload("res://src/campaign/runs/run_table.gd")
const HuntTable=preload("res://src/simulation/hunt_pressure/hunt_table.gd")
const DepthBands=preload("res://src/simulation/depth_bands.gd")
# path (or folder ending in "/") -> [allowed quoted occurrences of watched names, or -1 for any, reason]
const ALLOWED={
	"presentation/landmarks/landmark_data.gd":[8,"\"relay\" is a landmark kind, not a Siren role"],
	"simulation/simulation.gd":[1,"\"source\":\"relay\" tags a relayed shot, not a Siren role"],
	"presentation/truthful_commands.gd":[1,"substring search of a challenge title, not a craft id"],
	"main.gd":[3,"CAMERA and DECOY here are order button captions, not noise labels"],
	"presentation/acoustic_feedback.gd":[2,"CAMERA and KNOCKDOWN as the player-read words of a display map (keys use Names)"],
	"presentation/death_cause/cause_table.gd":[1,"ACTIVE SONAR as the player-read phrase (the key uses Names)"],
}
var checks=0
var failures=0
func check(ok:bool,label:String):
	checks+=1
	if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func unique(list:Array,label:String,size:int)->void:
	var seen={}
	for v in list:seen[v]=true
	check(seen.size()==list.size(),label+" has unique entries")
	check(list.size()==size,label+" has "+str(size)+" entries")
func watched()->Dictionary:
	var w={}
	for v in Names.ROLES:w[v]="role"
	for v in Names.CRAFT_IDS:w[v]="craft id"
	for v in Names.CRAFT_NOISES+Names.SIREN_NOISES:w[v]="noise label"
	for v in [Names.NOISE_TORPEDO_RUN,Names.NOISE_DECOY,Names.NOISE_RECOVERY_WINCH]:w[v]="noise label"
	return w
# The string literals of a source text outside comments.
func literals(text:String)->Array:
	var found=[]
	var i=0
	var n=text.length()
	while i<n:
		var c=text[i]
		if c=="#":
			while i<n and text[i]!="\n":i+=1
		elif c=="\"" or c=="'":
			var j=i+1
			var out=""
			while j<n and text[j]!=c:
				if text[j]=="\\" and j+1<n:j+=1
				out+=text[j];j+=1
			found.append(out)
			i=j+1
		else:i+=1
	return found
func source_files(dir:String,out:Array)->void:
	for f in DirAccess.get_files_at(dir):
		if f.ends_with(".gd"):out.append(dir.path_join(f))
	for d in DirAccess.get_directories_at(dir):source_files(dir.path_join(d),out)
func allowance(rel:String)->Array:
	if ALLOWED.has(rel):return ALLOWED[rel]
	for key in ALLOWED:
		if key.ends_with("/") and rel.begins_with(key):return ALLOWED[key]
	return []
# Exact list literals that must not be typed again, with the constant to use.
func list_patterns()->Array:
	return [
		["Siren role list in registry order",["patroller","sentinel","hunter","sweeper","buoy","relay","interceptor","warden"],"Names.ROLES"],
		["craft id list",["quietus","drone_a","drone_b"],"Names.CRAFT_IDS"],
		["unit name list",["QUIETUS","DRONE A","DRONE B"],"Names.UNIT_NAMES"],
		["unit letter list",["Q","A","B"],"Names.UNIT_LETTERS"],
		["loadout list",["endurance","disruption","survey"],"Names.LOADOUTS"],
		["loadout list (run table order)",["endurance","survey","disruption"],"Names.LOADOUT_*"],
		["depth band list",["SHALLOW","MIDDLE","DEEP"],"Names.BANDS"],
		["hunt stage list",["DORMANT","STIRRING","SEARCHING","HUNTING","LOCKDOWN"],"Names.HUNT_STAGES"],
	]
func list_regex(words:Array)->RegEx:
	var parts=[]
	for w in words:parts.append("[\"']"+w+"[\"']")
	var re=RegEx.new()
	re.compile("\\[\\s*"+"\\s*,\\s*".join(parts)+"\\s*\\]")
	return re
func run():
	# (a) the registry itself
	unique(Names.ROLES,"ROLES",8)
	unique(Names.CRAFT_IDS,"CRAFT_IDS",3)
	unique(Names.UNIT_NAMES,"UNIT_NAMES",3)
	unique(Names.UNIT_LETTERS,"UNIT_LETTERS",3)
	unique(Names.LOADOUTS,"LOADOUTS",3)
	unique(Names.CRAFT_NOISES,"CRAFT_NOISES",5)
	unique(Names.SIREN_NOISES,"SIREN_NOISES",5)
	unique(Names.BANDS,"BANDS",3)
	unique(Names.HUNT_STAGES,"HUNT_STAGES",5)
	var every_noise=Names.CRAFT_NOISES+Names.SIREN_NOISES+[Names.NOISE_TORPEDO_RUN,Names.NOISE_DECOY,Names.NOISE_RECOVERY_WINCH]
	unique(every_noise,"all noise labels",13)
	check(Names.unit_name(1)=="DRONE A" and Names.unit_name(3)=="","unit_name by index")
	check(Names.craft_id(2)=="drone_b" and Names.craft_id(-1)=="","craft_id by index")
	check(Names.is_role("warden") and not Names.is_role("relay_buoy") and not Names.is_role(3),"is_role")
	# the owners agree with the registry
	var as_set=func(a:Array)->Array:
		var c=a.duplicate();c.sort();return c
	check(as_set.call(EnemyTypes.ALL)==as_set.call(Names.ROLES),"enemy_types.ALL holds the same eight roles")
	check(EnemyTypes.ALL==Names.ROLES,"enemy_types.ALL keeps the registry order")
	check(EnemyTypes.SWEEPER==Names.ROLE_SWEEPER,"enemy_types.SWEEPER is the registry sweeper")
	check(as_set.call(FieldTools.LOADOUTS)==as_set.call(Names.LOADOUTS),"field_tools.LOADOUTS holds the three loadout ids")
	check(as_set.call(RunTable.LOADOUTS)==as_set.call(Names.LOADOUTS),"run_table.LOADOUTS holds the three loadout ids")
	check(RunTable.LOADOUTS==[Names.LOADOUT_ENDURANCE,Names.LOADOUT_SURVEY,Names.LOADOUT_EMP],"run_table.LOADOUTS keeps its own order")
	check(HuntTable.STAGES==Names.HUNT_STAGES,"hunt_table.STAGES is the registry list")
	check(DepthBands.NAMES==Names.BANDS,"depth_bands.NAMES is the registry list")
	# (b) walk the source
	var files=[]
	source_files("res://src",files)
	files.sort()
	check(files.size()>300,"source walk found the game source ("+str(files.size())+" files)")
	var w=watched()
	var patterns=list_patterns()
	var regs=[]
	for p in patterns:regs.append(list_regex(p[1]))
	var allowed_used={}
	for path in files:
		var rel=path.trim_prefix("res://src/")
		if rel=="names.gd" or rel.ends_with("_tests.gd"):continue
		var text=FileAccess.get_file_as_string(path)
		var hits={}
		for lit in literals(text):
			if w.has(lit):hits[lit]=hits.get(lit,0)+1
		var total=0
		for k in hits:total+=hits[k]
		var allow=allowance(rel)
		if not allow.is_empty():
			allowed_used[rel]=true
			if allow[0]>=0:check(total<=allow[0],rel+" types "+str(total)+" watched names as text, allowed "+str(allow[0])+" ("+allow[1]+"): "+str(hits))
			continue
		check(total==0,rel+" types names as text, use Names: "+str(hits))
		for i in patterns.size():
			check(regs[i].search(text)==null,rel+" types a "+patterns[i][0]+" as text, use "+patterns[i][2])
	for key in ALLOWED:
		if key.ends_with("/"):continue
		check(allowed_used.has(key),"allow-list entry "+key+" still names a source file")
	print("NAMES REGISTRY CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
