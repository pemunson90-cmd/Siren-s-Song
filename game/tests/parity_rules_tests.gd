extends SceneTree
# WP-16: the prototype rules Pat restored on 2026-11-12 (parity_rules/). On a
# player dive after the three tutorial operations the chart is discovered, a
# survey sweep's picture is temporary, objectives are search areas until found,
# Disrupt keeps its charge with no Siren in range, and a factory senses craft
# near it. A direct Simulation.start() without the flag keeps the older rules.
const Sim=preload("res://src/simulation/simulation.gd")
const Rules=preload("res://src/simulation/parity_rules/parity_rules.gd")
const Search=preload("res://src/simulation/parity_rules/site_search.gd")
const Factory=preload("res://src/simulation/parity_rules/factory_sensors.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 6:await process_frame
func dive(operation:int)->Object:
 var s=Sim.new();s.start(operation,"endurance",{Rules.KEY:true});preload("res://tests/fixtures/player_dive.gd").launch_drones(s);return s
func run_for(s,seconds:float)->void:
 s.paused=false
 for n in roundi(seconds/Sim.STEP):s.advance(Sim.STEP)
 s.paused=true
# A point near `site` from which a craft has a clear path to it.
func vantage(s,site:Vector2,reach:float)->Vector2:
 for ring in [reach,reach*.7,reach*.45]:
  for turn in 16:
   var p=site+Vector2(ring,0).rotated(TAU*turn/16.)
   if Rect2(Vector2.ONE*30,s.world_size()-Vector2.ONE*60).has_point(p) and not s.blocked(p,20.) and s.Depth.clear(s,p,site,1):return p
 return Vector2.INF
func searched(s)->Array:
 return s.mission.objectives.filter(func(o):return o.get("search",false))
func run():
 Rules.debug_known=false
 older_rules_case()
 tutorial_case()
 for operation in [5,16]:
  chart_case(operation)
  site_case(operation)
 survey_case(5)
 disrupt_case()
 sonar_case()
 drone_case()
 sight_case()
 factory_case()
 save_case()
 developer_case()
 await main_case()
 print("PARITY RULES CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
func older_rules_case():
 var s=Sim.new();s.start(5,"endurance",{Rules.KEY:false,"drones_aboard":false})
 check(not s.mission.get(Rules.KEY,false),"a start without the flag carries no parity rules")
 check(searched(s).is_empty() and s.observable_sites().all(func(o):return o.get("stage","")!="lead" or o.get("unknown",false)),"without the flag objectives are charted as before")
 var before=int(s.tools.emp);s.sirens=[]
 check(s.command("emp") and int(s.tools.emp)==before-1,"without the flag Disrupt spends its charge as before")
func tutorial_case():
 for operation in Rules.CHARTED_OPERATIONS:
  var s=dive(operation)
  check(s.mission.get(Rules.KEY,false) and searched(s).is_empty(),"op%d (tutorial water) keeps its objectives charted"%operation)
  check(not Rules.discovers(s.mission),"op%d keeps its authored chart"%operation)
func chart_case(operation:int):
 var s=dive(operation);var tag="op%d"%operation
 check(s.mission.get("earned_terrain",false) and s.terrain_chart!=null,tag+" discovers its chart on a player dive")
 if s.terrain_chart==null:return
 var grid=Vector2i(s.world_size()/s.terrain_chart.TILE)
 var known=s.terrain_chart.clear_cells.size()+s.terrain_chart.return_cells.size()
 check(known>0 and known<grid.x*grid.y*.5,"%s starts with a small known window (%d of %d cells)"%[tag,known,grid.x*grid.y])
func site_case(operation:int):
 var s=dive(operation);var tag="op%d"%operation;s.sirens=[]
 var sites=searched(s)
 check(not sites.is_empty(),tag+" has objectives to search for")
 if sites.is_empty():return
 var index=s.mission.objectives.find(sites[0]);var o:Dictionary=sites[0]
 var shown:Dictionary=s.observable_sites()[index]
 check(shown.get("stage","")=="lead" and shown.pos!=o.pos,tag+" an unfound objective is a search area, not its position")
 check(shown.pos.distance_to(o.pos)<float(shown.get("lead_r",0.)),"%s the search area contains the objective (%.0fm off centre, radius %.0fm)"%[tag,shown.pos.distance_to(o.pos),float(shown.get("lead_r",0.))])
 check(str(shown.name)==str(o.name),tag+" the search area keeps the objective's name")
 # A craft's own passive sensing finds it for good.
 var near=vantage(s,o.pos,minf(140.,s.passive_range(0)*.6))
 check(near!=Vector2.INF,tag+" setup: a clear vantage near the objective")
 if near==Vector2.INF:return
 s.units[0].pos=near;s.units[0].vel=Vector2.ZERO
 run_for(s,.4)
 check(o.get("found",false) and Photo.stage(o)=="resolved" and s.observable_sites()[index].pos==o.pos,tag+" a craft within passive reach finds the objective")
 check("located" in s.message or s.events.any(func(e):return e.get("type","")=="site_found"),tag+" the find is reported")
 # Sonar finds it too.
 var t=dive(operation);t.sirens=[]
 var target:Dictionary=searched(t)[0]
 var far=vantage(t,target.pos,minf(400.,t.Sonar.POWERS.low.radius*.9))
 if far!=Vector2.INF and far.distance_to(target.pos)>t.passive_range(0):
  t.units[0].pos=far;t.sonar.sector="all"
  check(t.command("ping") and target.get("found",false),tag+" a sonar pulse that reaches the objective finds it")
func survey_case(operation:int):
 var s=dive(operation);var tag="op%d survey"%operation;s.sirens=[]
 var sites=searched(s)
 if sites.is_empty() or s.terrain_chart==null:check(false,tag+" setup");return
 var o:Dictionary=sites[0]
 var chart=s.terrain_chart
 var before=chart.clear_cells.size()+chart.return_cells.size()
 # A sweep centred on the objective, far from the craft.
 s.mission["survey_origin"]=o.pos;s.recon_time=2.0
 run_for(s,.5)
 var during=chart.clear_cells.size()+chart.return_cells.size()
 check(during>before,"%s a sweep adds to the chart (%d to %d cells)"%[tag,before,during])
 check(o.get("glimpsed",false) and Photo.stage(o)=="resolved" and not o.get("found",false),tag+" a sweep shows the objective without finding it for good")
 var saved=chart.snapshot()
 check(saved.clear_cells.size()+saved.return_cells.size()<during,tag+" a saved chart leaves out the sweep's passing picture")
 check(Sim.valid_snapshot(s.snapshot()),tag+" a dive saved during a sweep is a valid snapshot")
 s.recon_time=0.0
 run_for(s,Rules.SURVEY_MEMORY+2.0)
 var after=chart.clear_cells.size()+chart.return_cells.size()
 check(after<during,"%s the sweep's picture lapses when no craft maps it (%d then %d cells)"%[tag,during,after])
 check(not o.get("glimpsed",false) and Photo.stage(o)=="lead",tag+" the objective is a search area again")
func disrupt_case():
 var s=dive(5);s.sirens=[]
 var before=int(s.tools.emp)
 check(not s.command("emp") and int(s.tools.emp)==before,"Disrupt with no Siren in range is refused and keeps its charge")
 check("charge kept" in s.message and "EMP" in s.message,"the refusal names the EMP and says the charge is kept: "+s.message)
 var t=dive(5)
 if not t.sirens.is_empty():
  t.sirens[0].pos=t.units[0].pos+Vector2(80,0);t.sirens[0]["band"]=t.units[0].band
  var had=int(t.tools.emp)
  check(t.command("emp") and int(t.tools.emp)==had-1 and float(t.sirens[0].get("stun",0.))>0.,"Disrupt with a Siren in range fires, spends and stuns")
func sonar_case():
 var s=dive(5);s.sirens=[];s.sonar.sector="all"
 check(s.Sonar.pulse_cost(s,0)==0.,"Quietus's sonar costs no life support on a player dive")
 check(s.Sonar.pulse_cost(s,1)>0.,"a drone's sonar still costs battery")
 var oxygen=s.oxygen
 check(s.command("ping") and s.oxygen==oxygen,"a Quietus pulse spends no oxygen (%.2f to %.2f)"%[oxygen,s.oxygen])
 var battery=float(s.units[1].battery);s.ping_time=0.;s.command("select",{"unit":1})
 check(s.command("ping") and float(s.units[1].battery)<battery,"a drone pulse spends battery")
 var plain=Sim.new();plain.start(5,"endurance",{Rules.KEY:false,"drones_aboard":false})
 check(plain.Sonar.pulse_cost(plain,0)>0.,"without the flag the older sonar cost stands")
# Drone A and one Siren 90 m apart in open water, both far from Quietus.
func beside_drone(s)->Dictionary:
 var e:Dictionary=s.sirens[0].duplicate(true)
 var size:Vector2=s.world_size();var drone_at=Vector2.INF;var spot=Vector2.INF
 for gy in range(2,int(size.y/80.)-1):
  for gx in range(2,int(size.x/80.)-1):
   var d=Vector2(gx,gy)*80.
   if s.blocked(d,24.) or d.distance_to(s.units[0].pos)<520.:continue
   for turn in 8:
    var p:Vector2=d+Vector2(90,0).rotated(TAU*turn/8.)
    if not s.blocked(p,24.) and p.distance_to(s.units[0].pos)>520. and s.Depth.clear(s,p,d,1):drone_at=d;spot=p;break
   if spot!=Vector2.INF:break
  if spot!=Vector2.INF:break
 if spot==Vector2.INF:return {"pos":Vector2.INF}
 s.units[1].pos=drone_at;s.units[1].vel=Vector2.ZERO;s.units[1].route=[]
 e.pos=spot;e.home=spot;e.goal=spot;e.route=[];e.patrol_points=[];e.stun=0.;e.lock=0.;e.target=-1;e.band=s.units[1].band;e.transition={};e.type="patroller";e.mode="PATROL"
 s.sirens=[e];return e
func drone_case():
 # Drones deployed (no drone bay flag) so the Siren rules are tested alone.
 var s=dive(5)
 if s.sirens.is_empty():check(false,"drone setup");return
 # Move Quietus well away so only the drone is near the Siren.
 var e=beside_drone(s)
 check(e.pos!=Vector2.INF,"setup: a Siren beside Drone A")
 s.units[0].silent=true;s.units[1].silent=true
 run_for(s,6.0)
 check(s.units[1].alive and float(s.sirens[0].get("lock",0.))==0.,"a calm Siren ignores a drone in its sight")
 s.mission.reconnaissance=s.Recon.state(s.mission).duplicate(true);s.mission.reconnaissance.hunt=60.;s.mission.reconnaissance.floor=60.
 run_for(s,6.0)
 check(not s.units[1].alive,"once Hunt reaches SEARCHING the same Siren destroys the drone")
 var plain=Sim.new();plain.start(5,"endurance",{Rules.KEY:false,"drones_aboard":false})
 if not plain.sirens.is_empty():
  beside_drone(plain);plain.units[1].silent=true
  run_for(plain,6.0)
  check(not plain.units[1].alive,"without the flag a calm Siren destroys a drone in its sight as before")
 # Quieter drones: same craft, same speed, 0.6 of the noise reach.
 var a=dive(5);var b=Sim.new();b.start(5,"endurance",{Rules.KEY:false,"drones_aboard":false})
 for sim in [a,b]:sim.units[1].vel=Vector2(90,0);sim.units[1].silent=false
 var with_rule=a.motion_radius(1);var without=b.motion_radius(1)
 check(without>0. and absf(with_rule/without-s.DroneStealth.NOISE)<.01,"a drone's movement noise reaches %.0f%% as far (%.0f against %.0f)"%[s.DroneStealth.NOISE*100,with_rule,without])
 check(a.motion_radius(0)==b.motion_radius(0),"Quietus's noise is unchanged")
func sight_case():
 var known={Rules.KEY:true,"context":{"intel":{"siren_patroller":{"q":1.0}}}}
 var s=Sim.new();s.start(5,"endurance",known)
 if s.sirens.is_empty():check(false,"sight setup");return
 s.sirens[0]["type"]="patroller"
 check("patroller" in s.SightRange.known_types(s),"photo intel of a Siren type is remembered for the dive")
 check(s.SightRange.rows(s).is_empty(),"no sight range is drawn without a contact")
 s.contacts[0]={"pos":s.sirens[0].pos,"time":s.elapsed,"mode":"","lock":0.0,"angle":0.0,"target":-1,"type":"patroller","band":1,"seen_by":[0]}
 s.sonar.get("identified",{}).erase(0)
 check(s.SightRange.rows(s).is_empty(),"no sight range for a contact whose type is not identified")
 s.ContactIdentity.identify(s,0)
 var rows=s.SightRange.rows(s)
 check(rows.size()==1 and rows[0].pos==s.contacts[0].pos,"an identified contact of a photographed type gets a sight range at its last known position")
 if rows.size()==1:
  s.units[s.selected].silent=true;var quiet=float(s.SightRange.rows(s)[0].radius)
  s.units[s.selected].silent=false;var moving=float(s.SightRange.rows(s)[0].radius)
  check(quiet<moving and "SIGHT" in str(rows[0].label),"the range follows the selected craft's silent state (%.0f quiet, %.0f moving)"%[quiet,moving])
 var t=dive(5)
 if not t.sirens.is_empty():
  t.sirens[0]["type"]="patroller";t.contacts[0]={"pos":t.sirens[0].pos,"time":t.elapsed,"mode":"","lock":0.0,"angle":0.0,"target":-1,"type":"patroller","band":1,"seen_by":[0]};t.ContactIdentity.identify(t,0)
  check(t.SightRange.rows(t).is_empty(),"a Siren type that was never photographed shows no sight range")
func factory_case():
 for operation in [3,11]:
  var s=dive(operation);var tag="op%d"%operation;s.sirens=[]
  var sites=Factory.sites(s.mission)
  check(sites.size()==1,tag+" names one factory sensor site")
  if sites.is_empty():continue
  check(Factory.reading(s)==0.0,tag+" the factory does not sense a craft at the launch point")
  var hunt_far=float(s.Recon.state(s.mission).hunt)
  run_for(s,2.0)
  var drift=float(s.Recon.state(s.mission).hunt)-hunt_far
  s.units[0].pos=sites[0].pos+Vector2(float(sites[0].r)*.25,0)
  check(Factory.reading(s)>.7,tag+" a craft close to the factory is sensed")
  var hunt_near=float(s.Recon.state(s.mission).hunt)
  run_for(s,2.0)
  var rise=float(s.Recon.state(s.mission).hunt)-hunt_near
  check(rise>drift+8.,"%s Hunt rises near the factory (%.1f in 2 s, against %.1f away from it)"%[tag,rise,drift])
  check(s.HuntPressure.view(s).cause=="factory sensors","%s the Hunt meter names the cause: %s"%[tag,s.HuntPressure.view(s).cause])
  check(s.mission.get("factory_state",{}).get("sensed",false),tag+" the player is told once")
  # Aboard drones are not in the water and are not sensed.
  check(s.units[1].get("alive",true),tag+" setup: this fixture has its drones deployed")
 var plain=Sim.new();plain.start(3,"endurance",{Rules.KEY:false,"drones_aboard":false})
 check(Factory.sites(plain.mission).is_empty(),"without the flag the factory senses nothing")
func save_case():
 var s=dive(16);s.sirens=[]
 check(Sim.valid_snapshot(s.snapshot()),"a player dive with search areas saves as a valid snapshot")
 var sites=searched(s)
 if not sites.is_empty():
  sites[0]["found"]=true
  var data=s.snapshot();var r=Sim.new()
  check(Sim.valid_snapshot(data) and r.restore(data),"a dive with a found objective saves and restores")
  check(r.mission.get(Rules.KEY,false) and searched(r).size()==sites.size() and searched(r)[0].get("found",false),"the restored dive keeps its rules and what was found")
func developer_case():
 Rules.debug_known=true
 var s=dive(5)
 check(searched(s).is_empty() and not Rules.discovers(s.mission),"the developer option starts a dive with objectives and water known")
 Rules.debug_known=false
 var t=dive(5)
 Search.reveal_all(t)
 check(searched(t).all(func(o):return o.get("found",false)),"the developer option marks every objective of the current dive")
func main_case():
 root.size=Vector2i(2520,1080);await settle()
 var game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="runtime-test"
 game.store.path="user://wp16-parity-%d.save"%Time.get_ticks_usec()
 root.add_child(game);await settle();game.set_process(false)
 game._start_mission(5);await settle();game._refresh();await settle()
 check(game.sim.mission.get(Rules.KEY,false),"a dive started by the game carries the parity rules")
 check(not searched(game.sim).is_empty() and game.sim.terrain_chart!=null,"the game's dive has search areas and a discovered chart")
 check(game.order_buttons.emp.text.begins_with("EMP"),"the tool button reads EMP: "+game.order_buttons.emp.text.replace("\n"," / "))
 game.queue_free();await settle()
