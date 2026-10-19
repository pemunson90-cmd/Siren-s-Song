extends RefCounted
# Retained across dives/replays; key presence supplies evidence, never progression.
static func summary(evidence:Dictionary) -> String:
	var facts:PackedStringArray=[]
	if evidence.has("blackwater_reply"):facts.append("Blackwater · ocean archive older than humanity.")
	elif evidence.has("blackwater_request"):facts.append("Blackwater · a relay requests a missing ocean archive.")
	if evidence.has("furnace") and evidence.has("cradle"):facts.append("Foundry · hollow hulls; no visible armament.")
	elif evidence.has("cradle"):facts.append("Foundry · hulls with no visible armament at an open cradle.")
	elif evidence.has("furnace"):facts.append("Foundry · hollow forms on a construction line.")
	if evidence.has("well_signature"):facts.append("Well · cadence matches Quietus; speaker and intent unresolved.")
	elif evidence.has("well_pattern"):facts.append("Well · repeating cadence; Quietus comparison unverified.")
	if evidence.has("warning"):facts.append("Finale · fracture warning and evacuation packet.")
	elif evidence.has("departure"):facts.append("Finale · unarmed hulls head deeper.")
	elif evidence.has("transmitter"):facts.append("Finale · carrier directed into the trench.")
	return "\n".join(facts) if not facts.is_empty() else "No chapter records are retained."
