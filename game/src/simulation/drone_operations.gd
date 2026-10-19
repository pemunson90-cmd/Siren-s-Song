extends RefCounted
# Scout decisions consume only fresh, receiver-attributed observations.
const ARMED='SCOUT'
const STOPPED='SCOUT_STOP'
static func local_contact(contacts:Dictionary,unit_id:int,elapsed:float)->int:
 for key in contacts:
  var c=contacts[key]
  if key is int and c is Dictionary and elapsed-c.get('time',-INF)<.3 and elapsed>=c.get('time',INF) and unit_id in c.get('seen_by',[]):return key
 return -1
static func valid(data:Dictionary)->bool:
 for id in data.units.size():
  var u=data.units[id]
  if u is Dictionary and u.get('hold','') is String and u.get('hold','').begins_with('SCOUT'):
   if id==0 or u.hold not in [ARMED,STOPPED]:return false
 var contacts=data.get('contacts',{})
 if not contacts is Dictionary:return false
 for c in contacts.values():
  if not c is Dictionary or not c.has('seen_by'):continue
  if not c.seen_by is Array:return false
  var found=[]
  for id in c.seen_by:
   if not id is int or id<0 or id>2 or id in found:return false
   found.append(id)
 return true
