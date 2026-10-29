extends RefCounted
# Three discrete water volumes. Transitions occupy BOTH volumes until settled.
const NAMES=["SHALLOW","MIDDLE","DEEP"]
const DURATION=4.0
const SurvivorAscent=preload("res://src/simulation/survivor_ascent.gd")
const FieldTools=preload("res://src/simulation/field_tool_effects.gd")
const BandPhoto=preload("res://src/photo_depth/band_photo.gd")
const BandHint=preload("res://src/photo_depth/band_hint.gd")
static func initialize(sim):
 sim.mission["depth_cargo"]={};sim.mission["depth_openings"]=[]
 for body in sim.units+sim.sirens:
  body["band"]=body.get("band",1);body["transition"]={}
 for id in sim.sirens.size():sim.sirens[id]["acoustic_tone"]=sim.sirens[id].get("acoustic_tone",180.+id*17.)
static func occupied(body:Dictionary)->Array:
 var result=[body.get("band",1)]
 if not body.get("transition",{}).is_empty():result.append(body.transition.to)
 return result
static func overlap(a:Dictionary,b:Dictionary)->bool:
 for band in occupied(a):
  if band in occupied(b):return true
 return false
static func rock_shapes(sim,band:int)->Array:
 var override=sim.mission.get("depth_geometry",{}).get(band,{})
 var result=[]
 for rock in override.get("rocks",sim.mission.rocks):result.append(sim.rock_polygon(rock))
 return result
static func shapes(sim,band:int)->Array:
 var result=rock_shapes(sim,band)
 # Machinery remains solid in every band unless explicitly authored otherwise.
 for rect in structures(sim,band):
  result.append(PackedVector2Array([rect.position,Vector2(rect.end.x,rect.position.y),rect.end,Vector2(rect.position.x,rect.end.y)]))
 return result
static func structures(sim,band:int)->Array:
 return sim.mission.get("structures",[])+sim.mission.get("depth_geometry",{}).get(band,{}).get("structures",[])
static func clear(sim,a:Vector2,b:Vector2,band:int,radius:float=0.)->bool:
 var dimensions=sim.world_size()
 if not Rect2(Vector2.ONE*radius,dimensions-Vector2.ONE*radius*2).has_point(b):return false
 for rect in structures(sim,band):
  if sim._leg_enters_rect(a,b,rect.grow(radius)):return false
 var polygons=sim.band_shapes[band] if sim.band_shapes.has(band) else rock_shapes(sim,band)
 var boxes=sim.band_bounds.get(band,[])
 var corridor=Rect2(a,Vector2.ZERO).expand(b).grow(radius+.001)
 for index in polygons.size():
  var polygon=polygons[index]
  if index<boxes.size() and not boxes[index].grow(radius).intersects(corridor,true):continue
  if Geometry2D.is_point_in_polygon(a,polygon) or Geometry2D.is_point_in_polygon(b,polygon):return false
  for n in polygon.size():
   var first=polygon[n];var last=polygon[(n+1)%polygon.size()]
   if Geometry2D.segment_intersects_segment(a,b,first,last)!=null:return false
   if radius>0 and (Geometry2D.get_closest_point_to_segment(b,first,last).distance_to(b)<radius or Geometry2D.get_closest_point_to_segment(first,a,b).distance_to(first)<radius):return false
 return true
# Optical rays also cross temporary silt; physical navigation/work clearance stays unchanged.
static func optical_clear(sim,a:Vector2,b:Vector2,band:int)->bool:
 return clear(sim,a,b,band) and not FieldTools.silt_blocks(sim,a,b,band)
static func command(sim,band)->bool:
 if not band is int or band<0 or band>2:return false
 var u=sim.units[sim.selected]
 if not u.transition.is_empty() or absi(band-u.band)!=1 or not clear(sim,u.pos,u.pos,band,24):
  sim.message="Depth unavailable · adjacent band and local clearance required";return false
 if sim.Choir.towing(sim,sim.selected) or sim.mission.get("concealed_harbour",{}).get("carrier",-1)==sim.selected:
  sim.message="Release the physical tow before changing depth";return false
 var people=SurvivorAscent.count(sim.mission,sim.selected)
 var carried_ascent=people>0 and band<u.band
 if carried_ascent and u.get("ascent_settle",0.)>0:
  sim.message="Survivors must settle %.1fs before another ascent"%u.ascent_settle;return false
 # Soundings only reveal this local vertical clearance; never a remote detour.
 var held=u.hold
 var working=not sim.captures[sim.selected].is_empty() or not sim.module_recovery_status().jobs[sim.selected].is_empty() or sim.Delivery.busy(sim,sim.selected) or sim.Witness.busy(sim,sim.selected) or sim.Chain.connected(sim,sim.selected) or sim.Glass.busy(sim,sim.selected) or sim.Choir.busy(sim,sim.selected)
 var sleeve=sim.Equipment.has(sim.mission.launch_equipment,sim.selected,"quietus_pressure_sleeve")
 var duration=SurvivorAscent.duration_for_count(people) if carried_ascent else (2.5 if sleeve else DURATION)
 if sleeve:
  if sim.oxygen<.75:sim.message="Insufficient pressure-sleeve reserve";return false
  sim.oxygen-=.75;sim._noise(u.pos,250.,"PRESSURE SLEEVE",duration,u.band)
 u.transition={"to":band,"remaining":duration}
 if carried_ascent:u.transition["carried_ascent"]=true
 u.vel=Vector2.ZERO;u.hold=""
 sim.JobRelease.cancel(sim,sim.selected,"depth")
 if not working:u.hold=held
 sim.captures[sim.selected]={};sim.message="%s · %s → %s · %.1fs exposed transition"%[u.name,NAMES[u.band],NAMES[band],duration]
 return true
static func advance(sim,dt):
 for u in sim.units+sim.sirens:
  if u.get("alive",true)==false:continue
  var transition=u.get("transition",{})
  if u.get("ascent_settle",0.)>0:
   # Settle means holding the attained band, not time spent descending.
   if transition.is_empty():u.ascent_settle=maxf(0.,u.ascent_settle-dt)
   else:u.ascent_settle=SurvivorAscent.SETTLE_SECONDS
  if not transition.is_empty():
   transition.remaining=maxf(0,transition.remaining-dt)
   if transition.remaining<=0:
    if clear(sim,u.pos,u.pos,transition.to,12):
     u.band=transition.to
     if transition.get("carried_ascent",false):u["ascent_settle"]=SurvivorAscent.SETTLE_SECONDS
    u.transition={}
    if u in sim.units:
     sim._use_band(u.band)
     var goals=sim.RouteProgram.goals(u);var undo=u.get("route_undo",[]).duplicate(true)
     if not goals.is_empty():sim._install_program(u,goals,false)
     if not undo.is_empty():u.route_undo=undo
     sim._use_band(sim.units[sim.selected].band)
 # Pressure pumps impose recoverable operating cost, never permanent attrition.
 if sim.units[0].alive and sim.units[0].band==2:sim.oxygen=maxf(0,sim.oxygen-dt*.025)
 for i in [1,2]:
  if sim.units[i].alive and sim.units[i].band==2:sim.units[i].battery=maxf(0,sim.units[i].battery-dt*.035)
 BandPhoto.deep_cost(sim,dt)
static func transmission(a:Dictionary,b:Dictionary)->float:
 if overlap(a,b):return 1.0
 return .42 if absi(a.get("band",1)-b.get("band",1))==1 else .18
static func sight(sim,a:Dictionary,b:Dictionary)->bool:
 for band in occupied(a):
  if band in occupied(b) and clear(sim,a.pos,b.pos,band) and not FieldTools.silt_blocks(sim,a.pos,b.pos,band):return true
 return false
static func pursue(sim,enemy:Dictionary):
 var wanted=enemy.get("known_band",enemy.band)
 if enemy.get("attention_time",0)<=0 or not enemy.transition.is_empty() or wanted==enemy.band:return
 var step=enemy.band+signi(wanted-enemy.band)
 if clear(sim,enemy.pos,enemy.pos,step,24):enemy.transition={"to":step,"remaining":DURATION}
static func cargo_bands(sim):
 var bands=sim.mission.depth_cargo
 for item in sim.mission.get("module_recovery",{}).get("modules",{}):
  var module=sim.mission.module_recovery.modules[item]
  if module.unit>=0:bands[item]=sim.units[module.unit].band
  elif not bands.has(item):bands[item]=1
 var witness=sim.mission.get("witness_evacuation",{})
 if not witness.is_empty():
  if witness.state=="carried":bands["witness_capsule"]=sim.units[witness.carrier].band
  elif not bands.has("witness_capsule"):bands["witness_capsule"]=0 if sim.mission.id==41 else 1
 var delivery=sim.mission.get("blackwater_delivery",{})
 if not delivery.is_empty():
  for id in [1,2]:
   if not delivery.carriers[id].is_empty():bands["blackwater_buffer_%d"%id]=sim.units[id].band
static func cargo_band(sim,item:String)->int:
 return sim.mission.get("depth_cargo",{}).get(item,1)
# State-aware reminders use own orders/custody and received evidence only.
static func context(sim)->String:
 var u=sim.units[sim.selected]
 var ascent=SurvivorAscent.line(sim.mission,sim.selected,u)
 if not ascent.is_empty():return ascent
 if not u.transition.is_empty():return "Depth change · stationary %.1fs · exposed in BOTH bands until settled."%u.transition.remaining
 var delivery=sim.mission.get("blackwater_delivery",{})
 if not delivery.is_empty() and sim.selected>0 and not delivery.carriers[sim.selected].is_empty():return "RAW BUFFER aboard · meet Quietus at SAME settled depth within60m to TRANSFER."
 if sim.all_records() and sim.Delivery.complete(sim):return "Archive ready · recover Quietus settled in MIDDLE; retained kit still needs its carrier."
 var local=BandHint.local_record(sim,u)
 if not local.is_empty():return local
 if u.band!=1 and sim.mission.objectives.any(func(o):return not o.captured and u.pos.distance_to(o.pos)<240):return "Local record nearby · settle in MIDDLE to CAMERA / SAMPLE; shifting exposes both bands."
 var rows=sim.Sonar.feedback(sim,sim.selected).rows
 if rows.any(func(row):return sim.elapsed-row.time<3 and row.classification==preload("res://src/simulation/sweeper_senses.gd").WARNING):return "Sweeper heard locally · it is walking to the last noise it heard; go quiet or leave, or drop a decoy."
 if sim.Sonar.feedback(sim,sim.selected).listening>0:return "Listening for returns · moving160m or leaving the emitter band can lose your return."
 if sim.motion_radius(sim.selected)>180:return "Your engines drown out heard directions · slow down or listen from an independent craft."
 return sim.mission.get("depth_hint","Craft → DEPTH / SONAR · bearings need movement or a second receiver; depth costs time.")
static func valid(data)->bool:
 if data.mission.has("depth_hint") and not data.mission.depth_hint is String:return false
 if not data.get("noises") is Array:return false
 for noise in data.noises:
  if not noise is Dictionary or not noise.get("band") is int or noise.band not in [0,1,2]:return false
 if not data.mission.get("depth_cargo") is Dictionary:return false
 for value in data.mission.depth_cargo.values():
  if not value is int or value<0 or value>2:return false
 if not data.mission.get("depth_charts") is Dictionary or not data.mission.depth_charts.has_all([0,2]):return false
 if not data.mission.get("world_size",Vector2(1600,960)) is Vector2 or not data.mission.get("world_size",Vector2(1600,960)).is_finite():return false
 if not data.mission.get("depth_openings") is Array or data.mission.depth_openings.size()>32:return false
 for opening in data.mission.depth_openings:
  if not opening is Dictionary or not opening.get("rect") is Rect2 or not opening.rect.is_finite() or not (opening.get("time") is float or opening.get("time") is int) or not is_finite(opening.time) or opening.time<0 or opening.time>data.get("elapsed",0.):return false
 var config=data.mission.duplicate();config["world_size"]=data.mission.get("world_size",Vector2(1600,960))
 for chart in data.mission.depth_charts.values():
  if not preload("res://src/simulation/terrain_chart.gd").valid_state(chart,config):return false
 var geometry=data.mission.get("depth_geometry",{})
 if not geometry is Dictionary:return false
 for band in geometry:
  if not band is int or band not in [0,1,2] or not geometry[band] is Dictionary:return false
  for key in geometry[band]:
   if key not in ["rocks","structures"] or not geometry[band][key] is Array:return false
  for rock in geometry[band].get("rocks",[]):
   if not preload("res://src/simulation/polygon_containment.gd").valid_shape(rock):return false
  for rect in geometry[band].get("structures",[]):
   if not rect is Rect2 or not rect.is_finite() or rect.size.x<=0 or rect.size.y<=0:return false
 for enemy in data.sirens:
  if not enemy is Dictionary or not (enemy.get("acoustic_tone") is float or enemy.get("acoustic_tone") is int) or not is_finite(enemy.acoustic_tone) or enemy.acoustic_tone<40 or enemy.acoustic_tone>2000:return false
 for body in data.units+data.sirens:
  if not body is Dictionary:return false
  if not body.get("band") is int or body.band<0 or body.band>2 or not body.get("transition") is Dictionary:return false
  if body.has("known_band") and (not body.known_band is int or body.known_band not in [0,1,2]):return false
  var settle=body.get("ascent_settle",0.)
  if not (settle is float or settle is int) or not is_finite(settle) or settle<0 or settle>SurvivorAscent.SETTLE_SECONDS:return false
  if body in data.sirens and body.has("ascent_settle"):return false
  var t=body.transition
  if not t.is_empty():
   if t.size()!=(3 if t.has("carried_ascent") else 2) or not t.has_all(["to","remaining"]) or not t.to is int or t.to<0 or t.to>2 or absi(t.to-body.band)!=1:return false
   var carried=t.get("carried_ascent",false)
   if t.has("carried_ascent") and (not carried is bool or not carried or body in data.sirens or t.to>=body.band):return false
   if not (t.remaining is float or t.remaining is int) or not is_finite(t.remaining) or t.remaining<=0 or t.remaining>(SurvivorAscent.MANY_SECONDS if carried else DURATION):return false
 return true
