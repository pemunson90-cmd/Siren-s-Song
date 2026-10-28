extends "res://tests/fix2_menu_ui_tests.gd"
const Racks=preload("res://src/equipment/tool_racks.gd")
const Tools=preload("res://src/equipment/field_tools.gd")
const Effects=preload("res://src/simulation/field_tool_effects.gd")
const Sim=preload("res://src/simulation/simulation.gd")
const Economy=preload("res://src/campaign/economy.gd")
const Store098=preload("res://src/persistence/save_store.gd")
const RackView=preload("res://src/presentation/tool_racks_view.gd")
const EconomyPanel098=preload("res://src/presentation/economy_panel.gd")
func data_checks():
 for choice in Tools.LOADOUTS:
  var racks=Racks.template(choice)
  check(Racks.valid(racks) and Racks.reason(Catalog.default_loadout(),racks).is_empty(),"template fits standard frames "+choice)
  for id in Tools.ids():check(Racks.total(racks,id)==Tools.loadout_count(id,choice),"legacy template total "+choice+" "+id)
  for id in Tools.field_ids():check(Racks.total(racks,id)==Tools.initial_counts(choice)[id],"controller template API "+id)
  check(Racks.migrated({"upgrade":choice})==racks,"old profile migrates its own template "+choice)
 var racks=Racks.empty();racks.quietus={"emp":1,"recon":1,"hull_patch":1}
 check(Racks.cargo_ticks(racks,0)==35 and Racks.cargo_ticks(racks,1)==0,"light medium heavy arithmetic is per craft")
 var fit=Catalog.canonical({"quietus":"quietus_reserve_cell"})
 check(Racks.room_ticks(fit,racks,0)==65 and Racks.winch_capacity({"launch_equipment":fit,"tool_racks":racks},0)==0,"module plus fractional tools share whole winch places")
 check(Racks.winch_capacity({"launch_equipment":fit,"tool_racks":Racks.empty()},0)==1,"unloading frees a real winch place")
 var exact=Racks.empty();exact.quietus={"recon":9,"knock":1}
 check(Racks.room_ticks(fit,exact,0)==0 and Racks.reason(fit,exact).is_empty(),"round after summing ten charges, exact cargo boundary")
 exact.quietus.emp=1
 check(not Racks.reason(fit,exact).is_empty(),"one light charge past shared cargo boundary refused")
 var torpedoes=Racks.empty();torpedoes.quietus.knock=2
 check(Racks.valid(torpedoes),"existing two-torpedo rack is accepted")
 var torpedo_launch=Sim.new();torpedo_launch.start(0,"endurance",{"tool_racks":torpedoes})
 check(Sim.valid_snapshot(torpedo_launch.snapshot()),"accepted two-torpedo launch has a valid snapshot")
 torpedoes.quietus.knock=3
 check(not Racks.valid(torpedoes),"third torpedo candidate refused before loading or launch")
 var bad=Racks.empty();bad.drone_a.knock=1
 check(not Racks.valid(bad),"drone cannot carry Quietus-only torpedo")
 bad=Racks.empty();bad.drone_a.hull_patch=1
 check(not Racks.valid(bad),"drone cannot carry Quietus-only patch")
 var e=Economy.new_state();var extra=Racks.template("endurance");extra.drone_a.emp=1
 check(Racks.cost(Racks.template("endurance"),"endurance",e).is_empty() and not Racks.cost(extra,"endurance",e).is_empty(),"template free, extra manufactured through economy")
 var iron=Economy.new_state("standard",true)
 check(Racks.cost(extra,"endurance",iron)==Racks.cost(extra,"endurance",e),"Ironman extras retain manufacturing price each launch")
 check(Racks.cost(Racks.template("endurance"),"endurance",Economy.new_state("accessible")).is_empty(),"Accessible template stays free")
 var s=Sim.new();s.start(0,"endurance",{"tool_racks":Racks.empty()})
 check(s.tools.values().all(func(n):return n==0) and Effects.state(s).counts.values().all(func(n):return n==0),"empty rack really launches with no finite stock")
 s.start(0,"survey",{"tool_racks":Racks.template("survey")});s.sirens=[]
 s.mission.structures=[];s.rock_shapes=[];s.rock_bounds=[];s._build_navigation()
 check(not s.command("sonobuoy") and Effects.count(s,"sonobuoy")==3,"Quietus cannot spend a drone's carried tool")
 s.selected=1;var origin=s.units[1].pos
 check(s.command("sonobuoy") and Effects.live(s,"sonobuoy")[0].pos==origin and Effects.live(s,"sonobuoy")[0].unit==1,"drone-carried sonobuoy deploys from owner")
 check(s.mission.tool_racks.drone_a.sonobuoy==2 and Sim.valid_snapshot(s.snapshot()),"spend synchronizes owner and aggregate save stock")
 var restored=Sim.new();check(restored.restore(s.snapshot()) and Racks.count(restored,"sonobuoy")==2,"restore preserves selected owner stock")
 var broken=s.snapshot();broken.mission.tool_racks.drone_a.sonobuoy=9
 check(not Sim.valid_snapshot(broken),"corrupt aggregate versus owner stock rejected")
 var owned=Racks.empty();owned.drone_b.emp=1;s.start(0,"endurance",{"tool_racks":owned});s.sirens=[]
 check(not s.command("emp") and s.tools.emp==1,"legacy tool refuses another craft's charge")
 s.selected=2
 check(s.command("emp") and s.tools.emp==0 and s.mission.tool_racks.drone_b.emp==0,"selected-craft legacy effect spends owner charge")
func shape_case(shape):
 root.size=shape;await settle()
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="runtime-test"
 root.add_child(game);await settle();game.set_process(false)
 game._show_fittings();await settle()
 var label=str(shape.x)
 check(button(game,"rack_empty")!=null and button(game,"rack_add_emp").size.y>=game.ui_touch_height-.5,"rack controls keep touch size "+label)
 if await press(game,"rack_craft_drone_a"):
  check(button(game,"rack_add_knock")==null and button(game,"rack_add_hull_patch")==null,"unsupported tools absent from drone UI "+label)
  var before=game.tool_racks.drone_a.get("emp",0)
  if await press(game,"rack_add_emp"):check(game.tool_racks.drone_a.emp==before+1,"real touch loads drone charge "+label)
 var active=game.sim.snapshot();game.economy.ironman=true
 var candidate=game.tool_racks.duplicate(true);candidate.quietus.emp=0
 game.tool_racks=candidate
 check(game.sim.snapshot()==active and preload("res://src/persistence/save_states/save2_controller.gd").locked(game),"Ironman next-rack edit never rewrites live dive or unlocks rewind "+label)
 if await press(game,"rack_empty"):
  check(game.tool_racks==Racks.empty() and EconomyPanel098.can_begin(game),"touch empty racks keeps launch available "+label)
 var archive=game._archive();check(game.store.valid(archive),"new rack profile validates "+label)
 var disk=Store098.new();disk.path="user://098-racks.save"
 check(disk.save(archive) and disk.load_game().tool_racks==game.tool_racks,"binary profile roundtrip preserves racks "+label)
 var legacy=archive.duplicate(true);legacy.erase("tool_racks")
 check(disk.save(legacy),"old profile remains accepted "+label)
 game.store=disk;game._load_archive()
 check(game.tool_racks==Racks.template(legacy.upgrade),"Main migrates loaded old profile to its template "+label)
 for suffix in ["",".bak"]:DirAccess.remove_absolute(disk.path+suffix)
 archive.tool_racks.drone_a.emp=-1;check(not game.store.valid(archive),"malformed profile racks rejected "+label)
 await android_back();check(game.screen=="menu","Android Back returns from racks "+label)
 game.queue_free();await settle()
func run():
 data_checks()
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:await shape_case(shape)
 print("TOOL RACKS CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
