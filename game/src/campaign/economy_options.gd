extends RefCounted
# 110 optional setup/switch block. Seam: Economy + EconomyPanel + Ledger.
# Revert these seams to ignore saved options; legacy saves use neutral defaults lazily.
const Table=preload("res://src/campaign/economy_table.gd")
static func fresh()->Dictionary:return {"started":false,"custom":{},"custom_run":false,"pending":"","history":[]}
static func state(e:Dictionary)->Dictionary:return e.get("economy_options",fresh())
static func ensure(e:Dictionary)->Dictionary:
 if not e.has("economy_options"):e.economy_options=fresh()
 return e.economy_options
static func multiplier(e:Dictionary,key:String)->float:return float(state(e).custom.get(key,1.0))
static func configure(e:Dictionary,values:Dictionary)->void:
 var s=ensure(e);s.custom=values.duplicate();s.custom_run=not values.is_empty()
 for key in Table.RES:e.stock[key]=mini(Table.CAP,roundi(Table.START[key]*multiplier(e,"start")))
static func choices(e:Dictionary)->Array:
 var s=state(e);var result=[]
 if e.ironman or not s.pending.is_empty():return result
 for id in Table.EASIER_ORDER:
  if Table.EASIER_ORDER.find(id)<=Table.EASIER_ORDER.find(e.preset):continue
  result.append(id)
 return result
static func request(e:Dictionary,id:String)->bool:
 if id not in choices(e):return false
 ensure(e).pending=id
 return true
static func dock(e:Dictionary)->void:
 var s=ensure(e)
 if s.pending.is_empty() or e.ironman:return
 s.history.append({"from":e.preset,"to":s.pending})
 e.preset=s.pending;s.pending=""
static func label(e:Dictionary)->String:
 return ("CUSTOM / " if state(e).custom_run else "")+str(Table.PRESETS[e.preset].name)
static func lines(e:Dictionary)->Array:
 if e.is_empty():return []
 var s=state(e);var result=["Campaign economy: "+label(e)+(" / IRONMAN" if e.ironman else "")+"."]
 for row in s.history:result.append("Economy preset: %s / %s at dock."%[Table.PRESETS[row.from].name,Table.PRESETS[row.to].name])
 if not s.pending.is_empty():result.append("Economy preset: %s queued for next dock."%Table.PRESETS[s.pending].name)
 return result
static func valid(value,preset:String,ironman:bool)->bool:
 if not value is Dictionary or value.size()!=5 or not value.has_all(["started","custom","custom_run","pending","history"]):return false
 if not value.started is bool:return false
 if not value.custom is Dictionary or not value.custom_run is bool or not value.pending is String or not value.history is Array:return false
 if not value.custom.is_empty():
  if not value.custom_run or value.custom.size()!=3:return false
  for key in Table.ADVANCED:
   var n=value.custom.get(key);var rule=Table.ADVANCED[key]
   if not (n is int or n is float) or not is_finite(float(n)) or n<rule.min or n>rule.max:return false
   if not is_equal_approx((float(n)-rule.min)/rule.step,round((float(n)-rule.min)/rule.step)):return false
 if value.history.size()>2:return false
 var last=""
 for row in value.history:
  if not row is Dictionary or row.size()!=2 or not row.has_all(["from","to"]):return false
  if not row.from is String or not row.to is String or row.from not in Table.EASIER_ORDER or row.to not in Table.EASIER_ORDER:return false
  if Table.EASIER_ORDER.find(row.to)<=Table.EASIER_ORDER.find(row.from) or (not last.is_empty() and row.from!=last):return false
  last=row.to
 if not last.is_empty() and last!=preset:return false
 if not value.pending.is_empty():
  var e={"preset":preset,"ironman":ironman,"economy_options":value.duplicate(true)};e.economy_options.pending=""
  if value.pending not in choices(e):return false
 return true
