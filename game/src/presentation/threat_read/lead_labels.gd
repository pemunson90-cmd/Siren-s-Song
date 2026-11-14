extends RefCounted
# Chart labels for unresolved lead areas ("UNKNOWN STRUCTURE · AREA · BRG 091"). Several areas of one name seen at
# nearly the same bearing from the selected craft would pile their labels on one spot (critic 14 Nov), so they share
# one label with a count. Presentation only: the areas themselves are all still drawn.
const Table=preload("res://src/presentation/threat_read/threat_read_table.gd")
const Compass=preload("res://src/presentation/compass.gd")
# entries: [{"pos":Vector2 label anchor,"name":String,"color":Color,"bearing":float degrees}]. Returns the groups in
# first-seen order: {"pos","name","color","bearing" (whole degrees, mean of the members),"count"}.
static func group(entries:Array,within:float=Table.LEAD_GROUP_DEGREES)->Array:
	var groups:Array=[]
	for entry in entries:
		var joined:=false
		for existing in groups:
			if existing.name==entry.name and absf(degrees_apart(float(existing.first),float(entry.bearing)))<=within:
				existing.members.append(float(entry.bearing));existing.count+=1;joined=true;break
		if not joined:groups.append({"pos":entry.pos,"name":entry.name,"color":entry.color,"first":float(entry.bearing),"members":[float(entry.bearing)],"count":1})
	for existing in groups:
		var sum:=Vector2.ZERO
		for degrees in existing.members:sum+=Compass.direction(degrees)
		existing["bearing"]=Compass.bearing(sum) if existing.count>1 else roundi(existing.first)%360
	return groups
static func degrees_apart(a:float,b:float)->float:
	return fposmod(a-b+180.0,360.0)-180.0
static func text(entry:Dictionary)->String:
	if int(entry.count)>1:return Table.TEXT.lead_many%[entry.name,int(entry.count),int(entry.bearing)]
	return Table.TEXT.lead_one%[entry.name,int(entry.bearing)]
