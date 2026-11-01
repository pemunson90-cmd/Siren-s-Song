extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Program=preload("res://src/simulation/route_program.gd")
const Chart=preload("res://src/simulation/terrain_chart.gd")
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func fixture(wall:bool=true):
 # Source-known wall fixture replaces the authored encounter in every band.
 # 127: earned-course repair and chart brakes are the dev/test autopilot path (Pat 2026-10-30).
 var s=Sim.new();s.start(0);s.sirens=[];s.mission["dev"]=true
 s.mission.erase("depth_geometry");s.mission.rocks=[];s.mission.structures=[Rect2(800,380,80,240)] if wall else []
 s.mission.world_size=Vector2(1600,960);s.mission.region_revision=1;s.mission.start=Vector2(240,500);s.mission.earned_terrain=true;s.mission.launch_seed=Rect2(80,80,640,800)
 # Route commands switch through the band lookup, which must own this new chart.
 s._build_navigation();s._configure_terrain();s._configure_depth_charts()
 s.units[0].pos=Vector2(240,500);s.units[0].angle=0;s.units[1].alive=false;s.units[2].alive=false
 return s
func measure_wall(s)->void:
 s.terrain_chart.observe([{"pos":Vector2(600,500),"radius":330.0}],{})
 s.known=s.terrain_chart.clear_cells.duplicate();s.mission.terrain_chart=s.terrain_chart.snapshot()
func move_for(s,seconds:float)->void:
 for n in int(seconds*60):s._move(s.units[0],Sim.STEP,42.0,false,true,true)
func surveyed_program():
 var s=fixture();s.command("route",{"point":Vector2(1200,500)});s.command("route_edit",{"index":0,"mode":"cruise","stop":false});s.command("queue");s.command("route",{"point":Vector2(1300,500)});s.command("route_edit",{"index":1,"mode":"silent","stop":true})
 s.terrain_chart.observe([],{"pos":Vector2(800,500),"radius":560.0});s.known=s.terrain_chart.clear_cells.duplicate();s.mission.terrain_chart=s.terrain_chart.snapshot()
 return s
func observed_save(path:String)->void:
 var store=preload("res://src/persistence/save_store.gd").new();store.path=path
 var data=store.load_game();var s=Sim.new()
 check(not data.is_empty() and s.restore(data.active),"preserved actual player profile restores without rewriting its source")
 if data.is_empty() or s.units.is_empty():return
 var u=s.units[1];var start=u.pos;var goal=s.route_goals(1);var tools=s.tools.duplicate();var safe=true;s.paused=false
 for tick in 720:
  s._move(u,Sim.STEP,96,false,true,true);safe=safe and s.terrain_chart.is_clear(u.pos)
  if tick%9==0:s._terrain_observe()
 check(start.distance_to(u.pos)>250 and safe and s.route_goals(1)==goal and s.tools==tools,"actual stopped Drone A gains measured travel under identical retained intent and no tools")
 check(u.get("chart_stop","")=="New terrain" and u.pos.distance_to(goal[0].pos)>20,"actual unresolved goal still requires a new exploration decision")
func _initialize():
 var s=fixture();var goal=Vector2(1200,500)
 check(s.command("route",{"point":goal}),"unmeasured goal is accepted before first returns")
 measure_wall(s)
 var u=s.units[0];var before=s.route_goals();var history=u.get("route_undo",[]).duplicate(true)
 check(not s.terrain_chart.segment_safe(u.pos,u.route[0].pos) and s.terrain_chart.clear_distance(u.pos,u.route[0].pos)>400,"reproduction has a distant measured blocker and substantial certified prefix")
 var start=u.pos;move_for(s,3)
 check(u.pos.x>start.x+80 and not u.has("chart_stop"),"new distant terrain retains travel through the measured safe prefix")
 check(s.route_goals()==before and u.get("route_undo",[])==history,"prefix travel preserves destination and undo")
 move_for(s,30)
 check(u.pos.x>650 and u.pos.x<800 and u.vel.length()<2 and u.get("chart_stop","")=="New terrain","unresolved measured obstacle stops after useful progress and requests a real decision")
 check(s.route_goals()==before and Program.valid_unit(u),"obstacle stop retains the complete valid goal program")
 var unknown=fixture(false);unknown.command("route",{"point":goal});move_for(unknown,30)
 check(unknown.units[0].pos.x>650 and unknown.units[0].pos.x<720 and not unknown.units[0].has("chart_stop"),"unmeasured frontier brakes without inventing an observed obstruction")
 var earning=fixture(false);earning.command("route",{"point":goal});earning.paused=false;var launch_cells=earning.terrain_chart.clear_cells.size();var original_tools=earning.tools.duplicate()
 for n in 1800:earning.advance(Sim.STEP)
 check(earning.units[0].route.is_empty() and earning.units[0].pos.distance_to(goal)<20 and earning.terrain_chart.clear_cells.size()>launch_cells and earning.tools==original_tools,"ordinary accepted course earns more chart and completes through live passive measurements without replots or tools")
 var blocked=fixture();blocked.command("route",{"point":Vector2(840,500)});measure_wall(blocked);var blocked_goal=blocked.route_goals();move_for(blocked,30)
 check(not blocked.blocked(blocked.units[0].pos,12) and blocked.units[0].pos.x<800 and blocked.units[0].get("chart_stop","")=="New terrain" and blocked.route_goals()==blocked_goal,"a genuinely obstructed accepted goal retains intent and halts before physical rock")
 var detour=surveyed_program()
 var accepted=detour.route_goals();var undo=detour.units[0].route_undo.duplicate(true)
 detour._move(detour.units[0],Sim.STEP,78,false,true,true)
 check(detour.units[0].route.size()>2 and detour.terrain_chart.segment_safe(detour.units[0].pos,detour.units[0].route[0].pos),"new measured obstruction repairs an ordinary wholly surveyed detour")
 check(detour.route_goals()==accepted and detour.units[0].route_undo==undo and Program.valid_unit(detour.units[0]),"surveyed repair preserves incoming propulsion PASS STOP queue and undo")
 var memory=detour.terrain_chart.snapshot();var alternate=Chart.new();alternate.configure(detour.mission,[],memory)
 var origin=Vector2(240,500);var planned=detour.terrain_chart.known_path(origin,goal)
 check(not planned.is_empty() and alternate.public_chart()==detour.terrain_chart.public_chart() and alternate.known_path(origin,goal)==planned,"identical measured chart yields identical autonomous route with different hidden geometry")
 var at=origin;var all_clear=true
 for node in planned:
  all_clear=all_clear and detour.terrain_chart.clear_distance(at,node.pos)+0.0001>=at.distance_to(node.pos);at=node.pos
 check(all_clear and detour.terrain_chart.snapshot()==memory,"automatic detour traverses only certified corridors and cannot acquire chart knowledge")
 var grid=detour.terrain_chart._known_grid;var cache_size=detour.terrain_chart._known_paths.size()
 for n in 60:detour.terrain_chart.known_path(origin+Vector2(n/100.0,0),goal)
 check(detour.terrain_chart._known_grid==grid and detour.terrain_chart._known_paths.size()==cache_size,"same chart generation and start cell reuse the grid and AStar path across physics frames")
 var paused=detour.snapshot();detour.advance(1)
 check(detour.snapshot()==paused,"pause freezes the surveyed repair and route program")
 var restored=Sim.new();check(restored.restore(bytes_to_var(var_to_bytes(paused))) and restored.snapshot()==paused,"current snapshot restores repaired corners and unchanged accepted program")
 for n in 180:
  detour._move(detour.units[0],Sim.STEP,42,false,true,true);restored._move(restored.units[0],Sim.STEP,42,false,true,true)
 check(restored.snapshot()==detour.snapshot(),"repaired route continues identically after binary save restore")
 move_for(detour,45)
 check(detour.units[0].route.is_empty() and detour.units[0].pos.distance_to(Vector2(1300,500))<20,"same accepted waypoint program completes its surveyed detour without another order")
 var held=surveyed_program();held.units[1]=held.units[0].duplicate(true);held.units[1].name="DRONE A";held.units[1].alive=true;held.units[1].hold="SCOUT_STOP";held.units[0].route=[];Program.clear(held.units[0]);held.selected=2
 var held_route=held.units[1].route.duplicate(true);held._move(held.units[1],Sim.STEP,96,true,true,true)
 check(held.units[1].route==held_route and held.units[1].vel==Vector2.ZERO and held.units[1].hold=="SCOUT_STOP","local SCOUT stop prevents repair or restart of an independently held drone")
 held.units[1].hold="";held._move(held.units[1],Sim.STEP,96,false,true,true)
 check(held.units[1].route.size()>held_route.size() and held.selected==2 and "DRONE A" in held.message,"released unselected drone repairs its own course without changing fleet selection")
 var flowing=surveyed_program();flowing.mission.currents=[{"center":Vector2(800,500),"radius":1400.0,"velocity":Vector2(18,7)}];flowing.units[0].water_velocity=Vector2.ZERO
 var flowing_copy=Sim.new();check(flowing_copy.restore(flowing.snapshot()),"current-assisted pending course repair restores without compatibility flags")
 var current_safe=true
 for n in 2700:
  flowing._move(flowing.units[0],Sim.STEP,42,false,true,true);flowing_copy._move(flowing_copy.units[0],Sim.STEP,42,false,true,true)
  current_safe=current_safe and not flowing.blocked(flowing.units[0].pos,12) and flowing.terrain_chart.is_clear(flowing.units[0].pos)
 check(current_safe and flowing.units[0].route.is_empty() and flowing.units[0].pos.distance_to(Vector2(1300,500))<20,"surveyed detour composes with physical crossflow acceleration and final stationkeeping")
 check(flowing_copy.snapshot()==flowing.snapshot(),"flowing repaired program remains deterministic after restore")
 var physical=surveyed_program();physical.units[0].chart_stop="Physical clearance stop";var physical_route=physical.units[0].route.duplicate(true);move_for(physical,1)
 check(physical.units[0].pos==Vector2(240,500) and physical.units[0].route==physical_route and physical.units[0].chart_stop=="Physical clearance stop","physical-clearance stop still requires an explicit replacement order")
 var args=OS.get_cmdline_user_args()
 if not args.is_empty():observed_save(args[0])
 print("EARNED COURSE CONTINUITY CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
