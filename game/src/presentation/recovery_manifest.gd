extends RefCounted
# 133: EXTRACT / WITHDRAW asks first when any craft is outside recovery. Read-only
# projection of the existing recovery reach (same test as ModuleRecovery.departure);
# reach, loss rules and rewards are unchanged. HOLD resumes the dive, CONFIRM goes
# on exactly as EXTRACT did before. Revert: remove the hook line in main._recovery_route.
const REACH:=65.
const SPEED:=12.
static var confirmed:=false

static func nearest(sim,pos:Vector2)->Dictionary:
 var best:={};var distance:=INF
 for corridor in sim.extraction_corridors():
  var d=pos.distance_to(corridor.pos)
  if d<distance:distance=d;best=corridor
 return best

# One row per craft: name, in (inside recovery reach), lost, distance to the nearest mouth.
static func entries(sim)->Array:
 var rows:=[]
 for id in sim.units.size():
  var u=sim.units[id];var mouth=nearest(sim,u.pos)
  if mouth.is_empty():return []
  var distance=u.pos.distance_to(mouth.pos)
  var inside=u.alive and u.band==1 and u.transition.is_empty() and distance<REACH and u.vel.length()<SPEED and sim.Depth.clear(sim,u.pos,mouth.pos,u.band)
  if u.alive and id>0 and sim.HandPilot.recalled(sim,id):inside=true
  rows.append({"name":u.name,"in":inside,"lost":not u.alive,"distance":distance})
 return rows

static func lines(rows:Array)->Array:
 var result:=[]
 for row in rows:
  var name=str(row.name).to_upper()
  if row.lost:result.append(name+" · OUT · LOST")
  elif row.in:result.append(name+" · IN")
  else:result.append("%s · OUT · %dm TO RECOVERY"%[name,roundi(row.distance)])
 return result

# True when the manifest took over the press. False: carry on exactly as before.
static func intercept(host)->bool:
 if confirmed:confirmed=false;return false
 var sim=host.sim
 if not sim.outcome.is_empty() or host.screen!="mission":return false
 var rows=entries(sim)
 if rows.all(func(r):return r.in):return false
 show(host,rows);return true

static func show(host,rows:Array)->void:
 host.set_meta("manifest_was_paused",host.sim.paused)
 host.sim.paused=true;host.screen="recovery_manifest";host._clear_menu()
 host._menu_text("RECOVERY MANIFEST",24)
 for line in lines(rows):host._menu_text(line,17)
 host._menu_text("OUT means the craft is lost with its cargo when the dive ends. IN craft are recovered.",16)
 host._button(host.menu_footer,"HOLD\nKEEP DIVING",func():_hold(host),"manifest_hold")
 host._button(host.menu_footer,"CONFIRM\nEND DIVE",func():_confirm(host),"manifest_confirm")
 host.menu_footer.show()

static func _hold(host)->void:
 host.sim.paused=host.get_meta("manifest_was_paused",false)
 host._enter_water()

static func _confirm(host)->void:
 var context=host.sim.departure_context()
 if context.available:
  # Quietus is at a mouth: the same validated departure the module sheet sends.
  host._order("depart",{"confirm":true,"corridor":context.corridor})
  if not host.sim.outcome.is_empty():host._debrief()
  else:host._enter_water()
  return
 host.sim.paused=host.get_meta("manifest_was_paused",false)
 host._enter_water()
 confirmed=true
 host._recovery_route()
 confirmed=false
