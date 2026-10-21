extends RefCounted
# Retained across dives/replays; key presence supplies evidence, never progression.
static func summary(evidence:Dictionary) -> String:
	var facts:PackedStringArray=[]
	if evidence.has("blackwater_reply"):facts.append("Blackwater · the driller's last log.")
	elif evidence.has("blackwater_request"):facts.append("Blackwater · a relay asks for its lost log.")
	if evidence.has("furnace") and evidence.has("cradle"):facts.append("Foundry · hollow castings; finished hulls in the cradles.")
	elif evidence.has("cradle"):facts.append("Foundry · finished hulls; one cradle empty.")
	elif evidence.has("furnace"):facts.append("Foundry · hollow forms on a construction line.")
	if evidence.has("well_signature"):facts.append("Well · cadence matches Quietus; speaker and intent unresolved.")
	elif evidence.has("well_pattern"):facts.append("Well · repeating cadence; Quietus comparison unverified.")
	if evidence.has("warning"):facts.append("Finale · bearings to every loud site; two still answer.")
	elif evidence.has("departure"):facts.append("Finale · hulls head deeper; their wakes split.")
	elif evidence.has("transmitter"):facts.append("Finale · a low pulse sent into the trench.")
	return "\n".join(facts) if not facts.is_empty() else "No chapter records are retained."
