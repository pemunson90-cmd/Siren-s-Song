extends RefCounted
# Plain loss feedback from our own craft and already observed contacts only.
# Seams: classic and expedition debriefs. Revert: remove those two lines and this file.
static func line(sim)->String:
 if sim.outcome!="lost":return ""
 var oxygen=sim.get("oxygen")
 if (oxygen is float or oxygen is int) and oxygen<=0:return "Life support ran out before Quietus reached recovery."
 if "Siren beam" in sim.message:
  var contacts=sim.get("contacts");var units=sim.get("units");var elapsed=sim.get("elapsed")
  if contacts is Dictionary and units is Array and not units.is_empty() and (elapsed is float or elapsed is int):
   for id in contacts:
    var c=contacts[id];var age=elapsed-float(c.get("time",-100.))
    if age<0 or age>1. or c.get("target",-1)!=0 or c.get("mode","") not in ["LOCKING","BEAM"]:continue
    return "Last observed S%d at %d m before the beam hit Quietus."%[int(id)+1,roundi(units[0].pos.distance_to(c.pos))]
  return "A Siren beam hit Quietus before it could break contact."
 var hull=sim.get("hull")
 if (hull is float or hull is int) and hull<=0:return "Quietus lost its remaining hull before reaching recovery."
 return "Quietus did not reach recovery. Earlier campaign records remain safe."
