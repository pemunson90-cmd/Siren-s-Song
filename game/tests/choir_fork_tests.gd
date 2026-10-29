extends SceneTree
const Catalog=preload("res://src/campaign/operation_catalog.gd")
const Sim=preload("res://src/simulation/simulation.gd")
const Bare=preload("res://tests/iron_choir_pressure_sim.gd")
const Economy=preload("res://src/campaign/economy.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func route_history(value)->Dictionary:return {"facts":{"confluence_route":value}}
func _initialize():
 var overt=Catalog.make(23,route_history("overt"));var overt24=Catalog.make(24,route_history("overt"))
 check(overt.corridors.size()==1 and overt.corridors[0].pos==Vector2(2750,300),"overt op23 uses the north recovery mouth")
 check(overt24.corridors.size()==1 and overt24.corridors[0].pos==Vector2(2750,500),"overt op24 uses the north/east recovery mouth")
 check(overt.corridors[0].name=="CHOIR NORTH RECOVERY" and overt.brief.contains("open warning passage recorded at Confluence"),"overt briefing carries the earlier cause")
 for value in ["concealed","", "invalid"]:
  for id in [23,24]:
   var m=Catalog.make(id,route_history(value))
   check(m.corridors.size()==1 and m.corridors[0].pos==m.start and m.corridors[0].name=="CHOIR SOUTH RECOVERY","fallback preserves south recovery %s/%s"%[id,value])
 var missing=Catalog.make(23,{})
 check(missing.corridors[0].pos==missing.start,"missing history preserves south recovery")
 var s=Sim.new();var context=route_history("overt");s.start(23,"endurance",{"context":context});context.facts.confluence_route="concealed"
 var frozen=s.snapshot();check(Sim.valid_snapshot(frozen),"active fork dive snapshot validates")
 check(frozen.mission.corridors[0].pos==Vector2(2750,300) and frozen.mission.launch_context.facts.confluence_route=="overt","launch route is frozen into active dive")
 var restored=Sim.new();check(restored.restore(frozen),"active fork dive snapshot restores")
 check(restored.mission.corridors[0].pos==Vector2(2750,300),"roundtrip preserves selected recovery variant")
 for id in [22,30]:
  var base=Catalog.make(id);var changed=Catalog.make(id,route_history("overt"))
  check(base.corridors==changed.corridors and base.extraction==changed.extraction,"control op geometry unchanged %d"%id)
 for id in [23,24]:
  var op=Catalog.make(id,route_history("overt"));var live=Sim.new();live.start(id,"endurance",{"context":route_history("overt")})
  check(not op.iron_choir.sites.is_empty() and not live.all_records() and not live.extraction_corridors()[0].available,"industrial work remains mandatory before recovery %d"%id)
 for preset in ["standard","accessible"]:
  for id in [23,24]:bare_voyage(id,preset)
 print("CHOIR FORK CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)

# Permanent source-known SILENT floor. Public orders, physical work and live Sirens.
func tick(s,seconds:float)->void:
 s.paused=false
 for n in roundi(seconds*60):s.advance(Sim.STEP)
 s.paused=true
func course(s,points:Array)->bool:
 for point in points:
  if not s.command("route",{"point":point}):return false
  s.paused=false
  for n in 24000:
   s.advance(Sim.STEP)
   if not s.outcome.is_empty() or (s.units[0].route.is_empty() and s.units[0].vel.length()<2):break
  s.paused=true
  if s.units[0].pos.distance_to(point)>(65 if s.outcome=="won" else 25):return false
 return true
func work(s,action:String)->bool:
 if not s.command("choir_action",{"action":action}):return false
 tick(s,8.2);return true
func depth(s,band:int)->bool:
 if not s.command("depth",{"band":band}):return false
 tick(s,4.2);return true
func bare_voyage(id:int,preset:String)->void:
 var s=Bare.new()
 s.start(id,"endurance",{"context":route_history("overt"),"tool_racks":preload("res://src/equipment/tool_racks.gd").empty(),"fitted":{"quietus":"","drone_a":"","drone_b":""}})
 Economy.apply_launch(Economy.new_state(preset),s);s.ordinary_bare=true
 if id==23:
  check(course(s,[Vector2(650,1845)]) and work(s,"lock_a"),"bare opens lower stair "+preset)
  check(course(s,[Vector2(500,1850),Vector2(650,1785),Vector2(1250,1385)]) and depth(s,0) and work(s,"lock_b"),"bare works shallow equalizer "+preset)
  check(course(s,[Vector2(1250,1000),Vector2(1550,950),Vector2(2400,800)]) and depth(s,1) and depth(s,2),"bare reaches upper deep approach "+preset)
  check(course(s,[Vector2(2400,690)]) and work(s,"lock_c") and depth(s,1),"bare opens upper shutter "+preset)
  check(course(s,[Vector2(2400,400),Vector2(2750,300)]),"bare crosses open upper shutter to north recovery "+preset)
 else:
  check(course(s,[Vector2(750,2140)]) and s.command("choir_action",{"action":"attach"}),"bare attaches real ballast "+preset)
  check(course(s,[Vector2(750,2450),Vector2(2750,2450),Vector2(2750,500),Vector2(2450,500)]) and work(s,"bypass"),"bare tows wide route and seats real ballast "+preset)
  check(course(s,[Vector2(2750,500)]),"bare reaches east recovery after work "+preset)
 check(s.outcome=="won" and s.hull>0 and s.continuous_silent and s.ordinary_commands,"overt bare full operation stays SILENT %d/%s"%[id,preset])
 check(s.received_lock_episodes>0 or s.hunt_peak>=20.,"overt route retains received Siren pressure %d/%s"%[id,preset])
 check(s.mission.launch_equipment.values().all(func(item):return item=="") and s.tools.values().all(func(stock):return stock==0),"overt floor uses no fittings or tools %d/%s"%[id,preset])
 check(Sim.valid_snapshot(s.snapshot()),"recovered overt full voyage saves %d/%s"%[id,preset])
