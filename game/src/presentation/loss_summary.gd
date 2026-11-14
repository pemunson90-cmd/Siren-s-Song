extends RefCounted
# Plain loss feedback from our own craft and already observed contacts only.
# Seams: classic, Career and expedition debriefs. Revert: remove those lines and this file.
# The cause is read from what happened (the lock that fired, as the contact record shows it), never from the
# last message: a rider's failure message or any later message can replace sim.message after the beam.
const Compass=preload("res://src/presentation/compass.gd")
const Names=preload("res://src/names.gd")
const LOCKISH=["LOCKING","BEAM"]
const FIRED="BEAM"
const SIREN_WORD="Siren"
const BEAM_LINE="%s %s's beam from the %s struck Quietus, about %d m away."
const BEAM_LINE_UNPLACED="A Siren beam hit Quietus before it could break contact."
# The Siren that locked Quietus most recently, as an index into the contacts, or -1.
static func beam_contact(sim)->int:
	var contacts=sim.get("contacts");var units=sim.get("units");var elapsed=sim.get("elapsed")
	if not (contacts is Dictionary and units is Array and not units.is_empty() and (elapsed is float or elapsed is int)):return -1
	var pick=-1
	for id in contacts:
		var c=contacts[id];var age=elapsed-float(c.get("time",-100.))
		if age<0 or age>1. or c.get("target",-1)!=0 or c.get("mode","") not in LOCKISH:continue
		if pick<0 or (c.get("mode","")==FIRED and contacts[pick].get("mode","")!=FIRED):pick=id
	return pick
static func life_support_out(sim)->bool:
	var oxygen=sim.get("oxygen")
	return (oxygen is float or oxygen is int) and oxygen<=0
# True when a fired Siren beam ended the dive: the simulation's own beam message, or a finished lock on Quietus.
static func beam_struck(sim)->bool:
	if sim.outcome!="lost" or life_support_out(sim):return false
	if "Siren beam" in sim.message:return true
	var id=beam_contact(sim)
	return id>=0 and sim.contacts[id].get("mode","")==FIRED
# The Siren's role in words: what the contact record saw first-hand, else what the dive identified, else "Siren".
static func siren_word(sim,id:int)->String:
	var c=sim.contacts[id]
	var role=str(c.get("type","")) if c.get("source","")=="optical" else ""
	if role not in Names.ROLES:
		var sonar=sim.get("sonar")
		role=str(sonar.get("identified",{}).get(id,"")) if sonar is Dictionary else ""
	return role.capitalize() if role in Names.ROLES else SIREN_WORD
static func article(word:String)->String:
	return "An" if word.substr(0,1) in ["A","E","I","O","U"] else "A"
static func line(sim)->String:
	if sim.outcome!="lost":return ""
	if life_support_out(sim):return "Life support ran out before Quietus reached recovery."
	if beam_struck(sim):
		var id=beam_contact(sim)
		if id>=0:
			var across:Vector2=sim.contacts[id].pos-sim.units[0].pos
			var word=siren_word(sim,id)
			return BEAM_LINE%[article(word),word,Compass.word(across).to_lower(),roundi(across.length()/10.)*10]
		return BEAM_LINE_UNPLACED
	var hull=sim.get("hull")
	if (hull is float or hull is int) and hull<=0:return "Quietus lost its remaining hull before reaching recovery."
	return "Quietus did not reach recovery. Earlier campaign records remain safe."
