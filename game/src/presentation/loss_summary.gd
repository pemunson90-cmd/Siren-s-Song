extends RefCounted
# Plain loss feedback from our own craft and already observed contacts only.
# Seams: classic and expedition debriefs. Revert: remove those two lines and this file.
static func line(sim)->String:
 if sim.outcome!="lost":return ""
 if sim.oxygen<=0:return "Life support ran out before Quietus reached recovery."
 if "Siren beam" in sim.message:
  for id in sim.contacts:
   var c=sim.contacts[id];var age=sim.elapsed-float(c.get("time",-100.))
   if age<0 or age>1. or c.get("target",-1)!=0 or c.get("mode","") not in ["LOCKING","BEAM"]:continue
   return "Last observed S%d at %d m before the beam hit Quietus."%[int(id)+1,roundi(sim.units[0].pos.distance_to(c.pos))]
  return "A Siren beam hit Quietus before it could break contact."
 if sim.hull<=0:return "Quietus lost its remaining hull before reaching recovery."
 return "Quietus did not reach recovery. Earlier campaign records remain safe."
