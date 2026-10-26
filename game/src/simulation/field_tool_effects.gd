extends RefCounted
# C2 field tools: stock, placed items and effects of sonobuoy, silt_screen, hull_patch and relay_buoy.
# AI-DESIGNED. Table: equipment/field_tools.gd. Orders: orders/tool_orders.gd (rows in order_table.gd).
# State lives in mission["field_tools"]={"counts":{id:int},"placed":[{id,pos,band,until,unit}]}, so it saves with the mission.
# Seams (all one line): Simulation.start() seed, Simulation.passive_range() reach_scale, Depth.sight() silt_blocks,
# SaveChecks "world" valid. Queries are pure; expiry is by sim.elapsed, so there is no tick hook.
# Revert: Tools.enabled=false, or delete the four seam lines and the tool_orders table rows.
const Tools=preload("res://src/equipment/field_tools.gd")
const KEY="field_tools"
const MAX_PLACED=8
const MAX_COUNT=9

static func state(sim)->Dictionary:
 return sim.mission.get(KEY,{}) if sim!=null and Tools.enabled else {}
static func seed(sim,upgrade:String)->void:
 sim.mission.erase(KEY)
 if Tools.enabled:sim.mission[KEY]={"counts":Tools.initial_counts(upgrade),"placed":[]}
static func count(sim,id:String)->int:
 return int(state(sim).get("counts",{}).get(id,0))
static func live(sim,id:String)->Array:
 var result=[]
 for item in state(sim).get("placed",[]):
  if item.id==id and item.until>sim.elapsed:result.append(item)
 return result
static func use(sim,order:String,args:Dictionary)->bool:
 if state(sim).is_empty() or order not in Tools.field_ids() or not Tools.is_enabled(order):return false
 var spec=Tools.spec(order);var u=sim.units[sim.selected]
 if count(sim,order)<=0:sim.message="%s · none left"%spec.name;return false
 if order=="hull_patch":return _patch(sim,spec,u)
 return _deploy(sim,spec,u,args)
static func _spend(sim,spec:Dictionary)->void:
 sim.mission[KEY].counts[spec.id]=count(sim,spec.id)-1
static func _noise(sim,spec:Dictionary,pos:Vector2,band:int)->void:
 if spec.noise>0.0:sim._noise(pos,spec.noise,spec.noise_label,spec.noise_time,band)
static func _deploy(sim,spec:Dictionary,u:Dictionary,args:Dictionary)->bool:
 var point=args.get("point",u.pos)
 if not point is Vector2 or not point.is_finite():return false
 var bad=not Rect2(Vector2(6,6),sim.world_size()-Vector2(12,12)).has_point(point) or u.pos.distance_to(point)>spec.deploy+0.001
 if bad or sim.blocked(point,6) or (point!=u.pos and not sim.Depth.clear(sim,u.pos,point,u.band)):
  sim.message="%s needs clear water within %dm · none spent"%[spec.name,roundi(spec.deploy)];return false
 if live(sim,spec.id).size()>=spec.max_active:sim.message="%s already working · wait for it to lapse"%spec.name;return false
 var placed:Array=state(sim).placed.filter(func(item):return item.until>sim.elapsed)
 if placed.size()>=MAX_PLACED:return false
 placed.append({"id":spec.id,"pos":point,"band":u.band,"until":sim.elapsed+spec.life,"unit":sim.selected})
 sim.mission[KEY].placed=placed;_spend(sim,spec);_noise(sim,spec,point,u.band)
 sim.message="%s placed · %ds"%[spec.name,roundi(spec.life)]
 return true
static func _patch(sim,spec:Dictionary,u:Dictionary)->bool:
 if sim.selected!=0 or sim.hull>=100.0:
  sim.message="Hull patch needs Quietus selected and hull damage · none spent";return false
 var repaired:float=minf(spec.repair,100.0-sim.hull)
 sim.hull+=repaired;_spend(sim,spec);_noise(sim,spec,u.pos,u.band)
 sim.message="Hull patched · +%d%%"%roundi(repaired)
 return true
# Drone passive reach multiplier while a relay buoy covers the drone. Quietus is unchanged.
static func reach_scale(sim,unit_id:int)->float:
 if unit_id==0 or sim.mission.get(KEY)==null:return 1.0
 for item in live(sim,"relay_buoy"):
  var spec=Tools.spec("relay_buoy")
  if sim.units[unit_id].pos.distance_to(item.pos)<=spec.radius:return spec.scale
 return 1.0
# True when a live silt cloud in this band crosses the sight line a-b. Never touches Siren state.
static func silt_blocks(sim,a:Vector2,b:Vector2,band:int)->bool:
 if sim.mission.get(KEY)==null:return false
 var radius=float(Tools.spec("silt_screen").radius)
 for item in live(sim,"silt_screen"):
  if item.band==band and Geometry2D.get_closest_point_to_segment(item.pos,a,b).distance_to(item.pos)<radius:return true
 return false
# Bearings only: direction from each live sonobuoy to each Siren it hears, snapped to a coarse step.
static func bearings(sim)->Array:
 var result=[]
 var spec=Tools.spec("sonobuoy")
 for item in live(sim,"sonobuoy"):
  var ear={"band":item.band,"transition":{}}
  for s in sim.sirens:
   if s.get("type","") in sim.Network.ROLES or s.get("type","") in sim.Industry.ROLES:continue
   if item.pos.distance_to(s.pos)>=spec.range*sim.Depth.transmission(ear,s):continue
   var angle:float=item.pos.angle_to_point(s.pos)
   result.append({"from":item.pos,"angle":snappedf(angle,spec.bearing_step),"until":item.until})
 return result
static func status(sim)->String:
 var parts=[]
 for id in Tools.field_ids():
  if Tools.is_enabled(id) and count(sim,id)>0:parts.append("%s %d"%[Tools.spec(id).name.to_upper(),count(sim,id)])
 return " · ".join(parts)
# Save shape of mission["field_tools"]; absent is valid.
static func valid(mission:Dictionary)->bool:
 if not mission.has(KEY):return true
 var data=mission[KEY]
 if not data is Dictionary or not data.get("counts") is Dictionary or not data.get("placed") is Array:return false
 for id in data.counts:
  if not id is String or id not in Tools.field_ids() or not data.counts[id] is int:return false
  if data.counts[id]<0 or data.counts[id]>MAX_COUNT:return false
 if data.placed.size()>MAX_PLACED:return false
 for item in data.placed:
  if not item is Dictionary or not item.get("id") is String or item.id not in Tools.field_ids() or item.id=="hull_patch":return false
  if not item.get("pos") is Vector2 or not item.pos.is_finite() or not item.get("band") is int or item.band not in [0,1,2]:return false
  if not (item.get("until") is float or item.get("until") is int) or not is_finite(item.until) or not item.get("unit") is int:return false
  if item.unit<0 or item.unit>2:return false
 return true
