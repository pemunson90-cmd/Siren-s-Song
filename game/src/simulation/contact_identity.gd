extends RefCounted
# Presentation knowledge only. Raw contacts/history and every enemy rule retain
# their existing observations. Optional sonar.identified survives an interrupted
# dive; start() resets it and seeds only roles photographed in recovered intel.
const ROLES=["patroller","hunter","sentinel","sweeper","buoy","relay","interceptor","warden"]
static func coarse(role:String)->String:
 return "STATIC" if role in ["buoy","relay"] else "PATROLLER" if role in ROLES else "UNCLASSIFIED"
static func known(sim,id:int)->bool:
 return sim.sonar.get("identified",{}).has(id)
static func identify(sim,id:int)->void:
 if id<0 or id>=sim.sirens.size():return
 if not sim.sonar.has("identified"):sim.sonar["identified"]={}
 sim.sonar.identified[id]=str(sim.sirens[id].get("type","patroller"))
 decorate(sim,id)
static func seed(sim,intel:Dictionary)->void:
 for id in sim.sirens.size():
  if intel.has("siren_"+str(sim.sirens[id].get("type","patroller"))):identify(sim,id)
static func sighted(sim,id:int)->bool:
 if id<0 or id>=sim.sirens.size():return false
 var enemy=sim.sirens[id]
 # Surveyed chart water and an acoustic return are not sight from a craft.
 for uid in sim.units.size():
  var u=sim.units[uid]
  if not u.alive:continue
  var reach=sim.passive_range(uid)*sim.Depth.transmission(u,enemy)
  if sim.mission.get("thermal_revision",0)==1:reach*=sim.Thermal.reception(sim,u,enemy)
  if u.pos.distance_to(enemy.pos)<reach and sim.Depth.sight(sim,u,enemy):return true
 return false
static func decorate(sim,id:int)->void:
 if not sim.contacts.has(id):return
 var role=str(sim.sirens[id].get("type","patroller")) if id>=0 and id<sim.sirens.size() else str(sim.contacts[id].get("type","unknown"))
 sim.contacts[id]["display_type"]=sim.sonar.identified[id] if known(sim,id) else coarse(role)
static func observe(sim)->void:
 for id in sim.sirens.size():
  if sighted(sim,id):identify(sim,id)
 for shot in sim.mission.get("photo",{}).get("shots",[]):
  if shot.get("usable",false) and shot.has("siren"):identify(sim,int(shot.siren))
 for id in sim.contacts:decorate(sim,id)
static func contact_type(c:Dictionary)->String:
 # Old optical caches and synthetic first-hand contacts stay readable. An
 # explicit acoustic provenance never gets the legacy optical assumption.
 return str(c.get("display_type",coarse(str(c.get("type","unknown"))) if c.get("source","") in ["active","triangulation"] or (c.get("source","")=="optical" and c.get("seen_by",null)==[]) else c.get("type","patroller")))
static func contact_mode(c:Dictionary)->String:
 var text=str(c.get("mode",""))
 if contact_type(c) not in ["STATIC","PATROLLER","UNCLASSIFIED"]:return text
 # Role-prefixed survey/contact modes are observation detail, not identity.
 var words=text.split(" ",false);var safe=[]
 for word in words:
  if word.to_lower() not in ROLES+["intercept"]:safe.append(word)
 return " ".join(safe)
static func classification(sim,row:Dictionary)->String:
 var id=int(row.get("enemy",-1));var text=str(row.get("classification",""))
 if id<0 or id>=sim.sirens.size():return text
 if known(sim,id):
  var role=str(sim.sonar.identified[id]).to_upper()
  return role if text.to_lower() in ROLES else role+" - "+text
 var label=coarse(str(sim.sirens[id].get("type","patroller")))
 if text=="DIFFRACTED ECHO":return text
 if text==preload("res://src/simulation/sweeper_senses.gd").WARNING:return label+" - INVESTIGATING"
 if text in ["BURST WINDUP","COMMITTED BURST","PRESSURE CHARGE"]:return label+" - "+text
 return label
static func event(sim,raw:Dictionary)->Dictionary:
 var id=int(raw.get("enemy",-1))
 if id<0 or known(sim,id):return raw
 if id>=sim.sirens.size():return raw
 # Preserve event identity for reception dedup, mixer routing and haptics.
 # Only the recording and caption are generic until first-hand identification.
 var result=raw.duplicate();result["sound"]="carrier_received"
 result["caption"]="HEARD: "+coarse(str(sim.sirens[id].get("type","patroller")))+" signal"
 return result
static func valid(data:Dictionary)->bool:
 var state=data.sonar
 if not data.get("contacts",{}) is Dictionary:return false
 if state.has("identified"):
  if not state.identified is Dictionary or state.identified.size()>data.sirens.size():return false
  for id in state.identified:
   if not id is int or id<0 or id>=data.sirens.size() or not state.identified[id] is String or state.identified[id]!=data.sirens[id].get("type","patroller"):return false
 for id in data.get("contacts",{}):
  var c=data.contacts[id]
  if not c is Dictionary:return false
  if c.has("display_type") and (not c.display_type is String or c.display_type not in ROLES+["STATIC","PATROLLER","UNCLASSIFIED"]):return false
 return true
