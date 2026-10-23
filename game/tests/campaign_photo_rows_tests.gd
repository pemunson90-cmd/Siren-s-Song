extends SceneTree
# Data contracts for optional campaign reconnaissance and recovered-film charts.
const Sim=preload("res://src/simulation/simulation.gd")
const Ops=preload("res://src/campaign/photo_ops.gd")
const Intel=preload("res://src/campaign/photo_intel.gd")
const Pricing=preload("res://src/simulation/photo_pricing/photo_pricing.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
const Catalog=preload("res://src/campaign/operation_catalog.gd")
const View=preload("res://src/presentation/ocean_view.gd")
const EXPECTED={7:"tender_door",8:"relay_blink",11:"structure_edge",14:"buoy_blind",15:"vane_crack",18:"keel_mark",19:"boat_keel",21:"locker_latch",23:"shutter_order",24:"bus_cable",26:"spindle_wear",27:"slide_mark",28:"bell_name",29:"feed_room"}
const RETURNS={"tender_door":[9,12],"relay_blink":[10],"structure_edge":[12,13],"buoy_blind":[15],"vane_crack":[21],"keel_mark":[19],"boat_keel":[22],"locker_latch":[23],"shutter_order":[24],"bus_cable":[25],"spindle_wear":[25],"slide_mark":[25],"bell_name":[25],"feed_room":[25]}
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
# Camera-content fixture: stage the craft only on physically clear water, without
# changing geometry, enemies or light. Campaign travel remains covered separately.
func water_view(s,h:Dictionary,key:String)->Dictionary:
 var features=h.subject.features.filter(func(f):return f.get("intel","")==key)
 if features.is_empty():return {}
 var feature=features[0]
 var band:int=int(h.subject.get("band",1))
 var u=s.units[0]
 u.band=band;u.vel=Vector2.ZERO
 Photo.set_frame(s,0,{"mode":"tight","focus":feature.id})
 if feature.has("window"):s.elapsed=feature.window[0]-feature.window[2]+1.0
 for distance in [45.0,65.0,90.0,110.0,150.0]:
  for delta in [0.0,-0.35,0.35,-0.7,0.7]:
   var point:Vector2=h.pos+Vector2.from_angle(h.subject.facing+feature.get("bearing",0.0)+delta)*distance
   if not s.Depth.clear(s,point,point,band,24.0) or not s.Depth.clear(s,point,h.pos,band):continue
   u.pos=point;u.angle=point.angle_to_point(h.pos)
   var frame=Photo.frame(s,0,h,8.0)
   if frame.rows.any(func(r):return r.id==feature.id and r.ready and r.q>=0.3):return {"point":point,"band":band}
 return {}
func _initialize():
 for id in EXPECTED:
  var s=Sim.new();s.start(id)
  var key:String=EXPECTED[id]
  var matches=s.mission.objectives.filter(func(o):return o.get("optical","")==key) if id in [8,23] else s.mission.get("photo_hidden",[]).filter(func(h):return h.key==key)
  check(matches.size()==1,"operation%d has its optional %s subject"%[id,key])
  if matches.size()!=1:continue
  var h=matches[0]
  if id in [8,23]:
   check(h.get("unknown",false) and h.get("optional",false) and h.duration>=h.subject.features[1].window[0],"the optional lamp study starts unresolved and spans its full cycle")
  else:
   check(not h.found and not s.mission.objectives.any(func(o):return o.get("optical","")==key),"the new subject starts unresolved")
  check(View.FINDING_COLORS.has(h.subject.features[1].finding.kind),"local %s finding uses a visible chart marker"%key)
  check(key in Ops.intel_keys() and key in Ops.evidence_keys(),"subject evidence and intel are registered")
  check(h.subject.features.any(func(f):return f.get("intel","")==key and f.has("finding")),"a resolved feature files an actionable finding")
  check(key in h.subject.required,"a usable optional record requires its informative feature")
  check(Sim.valid_snapshot(s.snapshot()),"unseen optional subject preserves current saves")
  var view=water_view(s,h,key)
  check(not view.is_empty(),"%s detail resolves from navigable water in its declared band"%key)
  if not view.is_empty():
   Photo.discover(s)
   var found=s.mission.objectives.filter(func(o):return o.get("optical","")==key)
   check(found.size()==1 and found[0].get("optional",false),"real optical discovery creates only an optional photo")
   check(Sim.valid_snapshot(s.snapshot()),"discovered %s photo preserves current save validation"%key)
   if found.size()==1:
    var objective=found[0];var at:int=s.mission.objectives.find(objective)
    s.command("frame",{"mode":"tight","focus":key})
    var context=s.camera_context()
    check(context.get("ready",false) and context.get("target",-1)==at,"the ordinary PHOTO control offers the discovered %s subject"%key)
    for other in 3:
     s.units[0].band=other
     check(s.BandPhoto.can_shoot(s,s.units[0],objective)==(other==h.subject.band),"%s respects its declared photo band%d"%[key,other])
    s.units[0].band=h.subject.band
    var film=Pricing.film_left(s,0)
    Photo.begin(s,0,at)
    # Isolated exposure clock, not a travel or threat-avoidance claim.
    for tick in ceili(objective.get("duration",4.0)*60.0):
     Photo.tick(s,0,objective,1.0/60.0);s.elapsed+=1.0/60.0
    var shot=Photo.finish(s,0,objective).shot
    check(shot.usable and shot.intel.has(key),"a held resolved %s frame earns usable intel"%key)
    check(Pricing.film_left(s,0)==film-1,"the optional exposure spends exactly one film")
    check(Intel.recover({},s.mission).has(key),"actual returned %s film reaches campaign intel"%key)
    check(Sim.valid_snapshot(s.snapshot()),"the completed optional exposure preserves current saves")
  for later in RETURNS[key]:
   var blank=Catalog.make(later,{})
   var context={"intel":{key:{"q":0.8,"op":id}}}
   var informed=Catalog.make(later,context)
   check(informed.get("photo_marks",[]).size()>blank.get("photo_marks",[]).size(),"returned%s film adds a chart mark on%d"%[key,later])
   var returned=informed.get("photo_marks",[]).filter(func(mark):return mark.id=="film_"+key)
   check(returned.size()==1 and View.FINDING_COLORS.has(returned[0].kind),"returned%s film has a visible chart marker"%key)
   check(informed.rocks==blank.rocks and informed.get("structures",[])==blank.get("structures",[]) and informed.sirens==blank.sirens,"new film informs without changing terrain or enemy rules")
   check(informed.get("required_site_ids",[])==blank.get("required_site_ids",[]) and informed.get("corridors",[])==blank.get("corridors",[]),"core work and recovery remain independent of film")
  var unusable={"photo":{"shots":[{"usable":false,"intel":{key:0.9},"op":id}]}}
  check(not Intel.recover({},unusable).has(key),"unusable film earns no intel")
  var usable={"photo":{"shots":[{"usable":true,"intel":{key:0.8},"op":id}]}}
  check(Intel.recover({},usable).has(key),"recovered usable film retains the new intel")
 # The existing lens opens a standoff shot; close bare optics remain viable.
 var lens=Sim.new();lens.start(15)
 var crack=lens.mission.photo_hidden.filter(func(row):return row.key=="vane_crack")[0]
 var point=Vector2(980,2270)
 check(lens.Depth.clear(lens,point,point,1,24.0) and lens.Depth.clear(lens,point,crack.pos,1),"the lens comparison uses physically clear water")
 lens.units[0].pos=point;lens.units[0].angle=point.angle_to_point(crack.pos)
 Photo.set_frame(lens,0,{"mode":"tight","focus":"vane_crack"})
 var bare=Photo.frame(lens,0,crack).rows[1]
 lens.mission.launch_equipment=lens.Equipment.canonical({"quietus":"quietus_tele_lens","drone_a":"","drone_b":""})
 var tele=Photo.frame(lens,0,crack).rows[1]
 check(not bare.ready and tele.ready,"the optional vane crack rewards the tele lens at standoff")
 # The existing plant's three objective slots remain intact.
 var plant=Sim.new();plant.start(10)
 check(plant.mission.objectives.size()==3 and Sim.valid_snapshot(plant.snapshot()),"relay-film payoff preserves the three plant objectives")
 print("CAMPAIGN PHOTO ROWS CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
