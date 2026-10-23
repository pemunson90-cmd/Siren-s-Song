extends RefCounted
# Save the stun clock only on an already earned, currently visible optical contact.
# Seams: optical observation and successful Disrupt. This never adds a contact or
# changes enemy state, sight, hearing or beam rules. Optional old saves stay valid.
# Revert: remove record hooks, validator registration and the two display branches.
static func record(sim)->void:
 for id in sim.contacts:
  var c=sim.contacts[id]
  if id<0 or id>=sim.sirens.size() or c.get("source","")!="optical":continue
  if sim.elapsed-float(c.time)>=.3 or not sim.contact_visible(sim.sirens[id]):continue
  c["observed_stun"]=maxf(0,sim.sirens[id].stun)
static func remaining(contact:Dictionary,elapsed:float)->float:
 return maxf(0,float(contact.get("observed_stun",0))-(elapsed-float(contact.time)))
static func valid(data:Dictionary)->bool:
 var contacts=data.get("contacts",{})
 if not contacts is Dictionary:return false
 for contact in contacts.values():
  if not contact is Dictionary:return false
  if not contact.has("observed_stun"):continue
  var clock=contact.observed_stun
  if not (clock is float or clock is int) or not is_finite(clock) or clock<0:return false
 return true
