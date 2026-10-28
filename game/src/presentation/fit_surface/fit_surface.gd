extends RefCounted
# Pure projection of the recovered-fitting rows for one craft, grouped by mount type, with a per-row
# budget delta. It grants nothing and validates nothing: Catalog.choose stays the only authority.
# Seam: fit_surface_view.gd (screen widget), equipment_context.rows (row source). Revert: fit_surface_table.enabled=false.
const Table=preload("res://src/presentation/fit_surface/fit_surface_table.gd")
const Catalog=preload("res://src/equipment/equipment_catalog.gd")
const Tools=preload("res://src/equipment/field_tools.gd")
const Equipment=preload("res://src/presentation/equipment_context.gd")
const Economy=preload("res://src/campaign/economy.gd")
# Row state: fitted here, spare (owned and free to fit), elsewhere (on another craft), refused, left behind.
static func state(row:Dictionary)->String:
 if row.current==row.id:return "fitted"
 if row.unavailable:return "left"
 if not row.blocked_by.is_empty():return "elsewhere"
 if not row.refused.is_empty():return "refused"
 return "spare"
static func section_of(row:Dictionary)->String:
 return row.mount if row.mount in Table.MOUNT_ORDER else Table.OTHER
# Sections for one craft slot: [{"mount","label","rows"}]. A mount type with no row is omitted.
static func sections(context:Dictionary,slot:String)->Array:
 var by_mount={}
 for row in Equipment.rows(context):
  if row.slot!=slot:continue
  var type=section_of(row)
  if not by_mount.has(type):by_mount[type]=[]
  by_mount[type].append(row)
 var result=[]
 for type in Table.MOUNT_ORDER+[Table.OTHER]:
  if not by_mount.has(type):continue
  var rows:Array=by_mount[type]
  rows.sort_custom(func(a,b):return Table.STATE_ORDER[state(a)]<Table.STATE_ORDER[state(b)])
  result.append({"mount":type,"label":mount_label(context.get("slots",{}),slot,type),"rows":rows})
 return result
# "SENSOR MOUNT · Long hydrophone", "SENSOR MOUNTS · 1 of 2 used", or "no SENSOR mount on this frame".
static func mount_label(fit:Dictionary,slot:String,type:String)->String:
 if type==Table.OTHER:return "OTHER FITTINGS · no typed mount"
 var held=[];var count=0
 for mount in Catalog.budget(Catalog.canonical(fit),Catalog.SLOTS.find(slot)).mounts:
  if mount.type!=type:continue
  count+=1
  if not mount.item.is_empty():held.append(Catalog.ITEMS[mount.item].name)
 if count==0:return "%s · no mount on this frame"%type
 var shown="empty" if count==1 else "%d empty"%count
 if not held.is_empty():shown=" + ".join(held)+(" · %d free"%(count-held.size()) if count>held.size() else "")
 return "%s MOUNT%s · %s"%[type,"S" if count>1 else "",shown]
static func title(row:Dictionary)->String:
 var fitted=row.current==row.id
 var text="%s · %s → BARE"%[row.station,row.name]
 if not fitted:
  text="%s · BARE → FIT %s"%[row.station,row.name]
  if not row.replaces.is_empty():text="%s · FIT %s · REPLACES %s"%[row.station,row.name,row.replaces]
 if not fitted and not row.refused.is_empty():text="%s · %s REFUSED · %s"%[row.station,row.name,row.refused.to_upper()]
 if not fitted and not row.blocked_by.is_empty():text="%s · %s ON %s"%[row.station,row.name,row.blocked_by]
 if row.unavailable:text="%s · %s UNAVAILABLE · LEFT BEHIND"%[row.station,row.name]
 return text
static func state_tag(row:Dictionary)->String:
 match state(row):
  "fitted":return "FITTED"
  "spare":return "SPARE"
  "elsewhere":return "ON "+row.blocked_by
  "refused":return "REFUSED"
 return "LEFT BEHIND"
# Budget of the craft after tapping this row (fit, swap or clear). Empty when the tap does nothing.
static func after_budget(context:Dictionary,row:Dictionary)->Dictionary:
 var slots=Catalog.canonical(context.get("slots",{}))
 var attempt={}
 if row.current==row.id:attempt=Catalog.choose(slots,row.key,"",context.get("available",[]))
 elif row.unavailable or not row.blocked_by.is_empty() or not row.refused.is_empty():return {}
 else:attempt=Catalog.choose(slots,row.key,row.id,context.get("available",[]))
 if not attempt.ok:return {}
 return Catalog.budget(attempt.fitted,row.unit)
static func pct(value:float)->int:return roundi(value*100.0)
# "POWER 3→4 / 5 · NOISE 100%→110%" for the changes a tap would make. Empty when the tap is refused.
static func delta_text(context:Dictionary,row:Dictionary)->String:
 var after=after_budget(context,row)
 if after.is_empty():return ""
 var before=Catalog.budget(Catalog.canonical(context.get("slots",{})),row.unit)
 var parts=["POWER %d→%d / %d"%[before.power,after.power,after.power_cap]]
 if before.cargo!=after.cargo or (after.cargo_cap>0 and row.cargo>0):
  parts.append("CARGO %d→%d / %d"%[before.cargo,after.cargo,after.cargo_cap])
 if pct(before.noise)!=pct(after.noise):parts.append("NOISE %d%%→%d%%"%[pct(before.noise),pct(after.noise)])
 if pct(before.endurance)!=pct(after.endurance):parts.append("ENDURANCE %d%%→%d%%"%[pct(before.endurance),pct(after.endurance)])
 return " · ".join(parts)
# One line per module: what it draws before anything is fitted.
static func draw_text(row:Dictionary)->String:
 var item=Catalog.ITEMS.get(row.id,{})
 if item.is_empty():return ""
 var parts=["POWER %d"%item.power]
 if item.cargo>0:parts.append("CARGO %d"%item.cargo)
 if absf(item.noise)>0.001:parts.append("NOISE %+d%%"%pct(item.noise))
 if absf(item.endurance)>0.001:parts.append("ENDURANCE %+d%%"%pct(item.endurance))
 return " · ".join(parts)
static func frames_owned(economy:Dictionary,expedition:Dictionary,unit:int)->Array:
 var owned=0;var total=0
 for id in Catalog.frames(unit):
  total+=1
  if not Economy.frame_locked(economy,expedition,unit,id):owned+=1
 return [owned,total]
# Compact summary for the briefing: one line per craft, generated from the actual fit.
static func summary(context:Dictionary)->String:
 var slots=Catalog.canonical(context.get("slots",{}));var lines=[]
 for unit in 3:
  var b=Catalog.budget(slots,unit);var items=Catalog.items_for(slots,unit)
  var craft=Equipment.SLOTS[Catalog.SLOTS[unit]]
  lines.append("%s · %s · %d FITTED · POWER %d/%d · CARGO %d/%d"%[craft,b.name.to_upper(),items.size(),b.power,b.power_cap,b.cargo,b.cargo_cap])
 var spare=0
 for id in context.get("available",[]):
  if Catalog.ITEMS.has(id) and Catalog.key_of(slots,id).is_empty():spare+=1
 return "\n".join(lines)+("\n%d SPARE MODULE%s"%[spare,"" if spare==1 else "S"] if spare>0 else "")
# Supplies line from the tool table instead of fixed words. Drones are the two non-Quietus craft.
static func stock_text(choice:String,with_field:bool=true)->String:
 var parts=["%d DECOYS"%Tools.loadout_count("decoy",choice),"%d DRONES"%(Catalog.SLOTS.size()-1)]
 parts.append("%d TORPEDOES"%Tools.loadout_count("knock",choice))
 var field=[]
 for id in (Tools.field_ids() if with_field else []):
  if Tools.is_enabled(id):field.append("%s %d"%[Tools.spec(id).name.to_upper(),Tools.loadout_count(id,choice)])
 return " · ".join(parts)+("\n"+" · ".join(field) if not field.is_empty() else "")
