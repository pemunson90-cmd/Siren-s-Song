extends RefCounted
# Retained across dives/replays; key presence supplies evidence, never progression.
static func summary(evidence:Dictionary) -> String:
	var facts:PackedStringArray=[]
	if evidence.has("blackwater_reply"):facts.append("Blackwater · the driller's last log.")
	elif evidence.has("blackwater_request"):facts.append("Blackwater · a relay asks for its lost log.")
	if evidence.has("furnace") and evidence.has("cradle"):facts.append("Foundry · a vent feeding open frames; all still warm.")
	elif evidence.has("cradle"):facts.append("Foundry · open frames on rails to the trench edge.")
	elif evidence.has("furnace"):facts.append("Foundry · a vent on a feed line.")
	if evidence.has("well_signature"):facts.append("Well · cadence matches Quietus; speaker and intent unresolved.")
	elif evidence.has("well_pattern"):facts.append("Well · repeating cadence; Quietus comparison unverified.")
	if evidence.has("warning"):facts.append("Finale · bearings to every loud site; two still answer.")
	elif evidence.has("departure"):facts.append("Finale · disturbed water splits south and west.")
	elif evidence.has("transmitter"):facts.append("Finale · a low pulse sent into the trench.")
	return "\n".join(facts) if not facts.is_empty() else "No chapter records are retained."
