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
  # These pre098 counts are the player-facing stock, independently of allocation.
  var original={"endurance":[2,3,2,2,2,1,1,1],"disruption":[3,3,2,2,1,2,1,0],"survey":[2,3,3,2,3,1,1,2]}
  var ids=["emp","decoy","recon","knock","sonobuoy","silt_screen","hull_patch","relay_buoy"]
  var seeded=Racks.template(choice,Catalog.default_loadout())
  for i in ids.size():check(Racks.total(seeded,ids[i])==original[choice][i],"original pre098 template bundle "+choice+" "+ids[i])
  for id in Tools.field_ids():check(Tools.initial_counts(choice)[id]==Tools.loadout_count(id,choice),"legacy controller bundle "+choice+" "+id)
  for hull in Catalog.Hulls.HULLS:
   for chassis_a in Catalog.Chassis.CHASSIS:
    for chassis_b in Catalog.Chassis.CHASSIS:
     var fitted=Catalog.canonical({"hull":hull,"chassis_a":chassis_a,"chassis_b":chassis_b})
     template_case(choice,fitted)
     # Cargo-bearing fitted modules consume capacity before template allocation.
     fitted.quietus="quietus_reserve_cell"
     if chassis_a in ["standard","heavy"]:fitted.drone_a="drone_ballast_pack"
     if chassis_b in ["standard","heavy"]:fitted.drone_b="drone_sampler"
     check(Catalog.valid_fitting(fitted),"template matrix fixture is a legal fit")
     template_case(choice,fitted)
 var racks=Racks.empty();racks.quietus={"emp":1,"recon":1,"hull_patch":1}
 check(Racks.weight_ticks(racks,0)==35 and Racks.cargo_ticks(racks,0)==0 and Racks.cargo_ticks(racks,1)==0,"tools fill their own locker before general cargo")
 var fit=Catalog.canonical({"quietus":"quietus_reserve_cell"})
 check(Racks.room_ticks(fit,racks,0)==100 and Racks.winch_capacity({"launch_equipment":fit,"tool_racks":racks},0)==1,"module plus locker tools keep the pre098 winch place")
 racks.quietus={"recon":9,"knock":2,"hull_patch":1}
 check(Racks.cargo_ticks(racks,0)==30 and Racks.room_ticks(fit,racks,0)==70 and Racks.winch_capacity({"launch_equipment":fit,"tool_racks":racks},0)==0,"spill beyond locker consumes a whole winch place")
 check(Racks.winch_capacity({"launch_equipment":fit,"tool_racks":Racks.empty()},0)==1,"unloading spill frees a real winch place")
 var exact=Racks.empty();exact.quietus={"recon":9,"knock":2,"hull_patch":1,"emp":9,"decoy":5}
 check(Racks.weight_ticks(exact,0)==200 and Racks.room_ticks(fit,exact,0)==0 and Racks.reason(fit,exact).is_empty(),"round after summing charges, exact locker plus cargo boundary")
 exact.quietus.decoy=6
 check(not Racks.reason(fit,exact).is_empty(),"one light charge past locker plus cargo boundary refused")
 migration_checks(fit)
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
 var e=Economy.new_state();var extra=Racks.template("endurance",Catalog.default_loadout());extra.drone_a.emp=4
 check(Racks.cost(Racks.template("endurance",Catalog.default_loadout()),"endurance",e).is_empty() and not Racks.cost(extra,"endurance",e).is_empty(),"template free, extra manufactured through economy")
 var iron=Economy.new_state("standard",true)
 check(Racks.cost(extra,"endurance",iron)==Racks.cost(extra,"endurance",e),"Ironman extras retain manufacturing price each launch")
 check(Racks.cost(Racks.template("endurance",Catalog.default_loadout()),"endurance",Economy.new_state("accessible")).is_empty(),"Accessible template stays free")
 var s=Sim.new();s.start(0,"endurance",{"tool_racks":Racks.empty()})
 check(s.tools.values().all(func(n):return n==0) and Effects.state(s).counts.values().all(func(n):return n==0),"empty rack really launches with no finite stock")
 var survey=Racks.empty();survey.drone_a.sonobuoy=3
 s.start(0,"survey",{"tool_racks":survey});s.sirens=[]
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
func template_case(choice:String,fit:Dictionary)->void:
 var label="%s %s/%s/%s"%[choice,fit.hull,fit.chassis_a,fit.chassis_b]
 var racks=Racks.template(choice,fit)
 check(Racks.valid(racks) and Racks.reason(fit,racks).is_empty(),"aware template launchable "+label)
 var migrated=Racks.migrated({"upgrade":choice,"equipment":fit},fit)
 check(migrated==racks and Racks.reason(fit,migrated).is_empty(),"legacy migration launchable "+label)
 for unit in 3:
  var b=Catalog.budget(fit,unit)
  check(Racks.winch_capacity({"launch_equipment":fit,"tool_racks":racks},unit)==b.cargo_cap-b.cargo,"template keeps pre098 whole winch places "+label+" "+str(unit))
  check(Racks.room_ticks(fit,racks,unit)>=0 and Racks.cargo_ticks(racks,unit)==0,"template never spills "+label+" "+str(unit))
  check(Racks.weight_ticks(racks,unit)>0 and Racks.locker_ticks(unit)>0,"every frame carries tools in a nonzero locker "+label+" "+str(unit))
  var spill=Racks.empty()
  spill[Racks.UNITS[unit]]={"recon":9,"emp":3} if unit==0 else {"recon":5,"emp":1}
  check(Racks.cargo_ticks(spill,unit)==5,"locker overflow uses cargo on every frame "+label+" "+str(unit))
  if b.cargo_cap>b.cargo:
   check(Racks.winch_capacity({"launch_equipment":fit,"tool_racks":spill},unit)==b.cargo_cap-b.cargo-1,"overflow reduces winch places "+label+" "+str(unit))
  else:check(not Racks.reason(fit,spill).is_empty(),"zero general cargo refuses overflow "+label+" "+str(unit))
 for id in Tools.ids():check(Racks.total(racks,id)==Tools.loadout_count(id,choice),"all frame combinations keep original bundle "+label+" "+id)
 check(Racks.migrated({"tool_racks":racks},fit)==racks,"saved rack preserved "+label)
func migration_checks(fit:Dictionary)->void:
 var old={"upgrade":"survey","tool_racks":Racks.empty()}
 check(Racks.migrated(old,fit)==Racks.template("survey",fit),"098 automatic empty template refilled")
 old.tool_racks.drone_a.emp=0
 check(Racks.migrated(old,fit)==old.tool_racks,"098 edited zero-count key kept")
 old.tool_racks.drone_a.emp=2
 var kept=Racks.migrated(old,fit)
 check(kept==old.tool_racks,"098 edited nonempty rack kept")
 kept.drone_a.emp=3
 check(old.tool_racks.drone_a.emp==2,"migration copies edited racks independently")
 Racks.write_archive(old,Racks.empty())
 check(Racks.valid_archive(old) and Racks.migrated(old,fit)==Racks.empty(),"new intentional empty rack survives repeat migration")
 for bad in [true,"100",99,101]:
  old.tool_racks_version=bad
  check(not Racks.valid_archive(old),"invalid locker archive marker refused "+str(bad))
 old={"tool_racks_version":Racks.ARCHIVE_VERSION}
 check(not Racks.valid_archive(old),"locker marker requires saved racks")
func refusal_checks():
 var s=Sim.new();var fit=Catalog.canonical({"hull":"quiet"})
 var racks=Racks.empty();racks.quietus={"recon":9,"emp":3}
 s.start(0,"endurance",{"fitted":fit,"tool_racks":racks})
 # Use a real module recovery refusal; no geometry or tool-effect shortcut.
 s.mission.module_recovery.modules["drone_deep_cells"]={"state":"salvage","unit":-1,"pos":s.units[0].pos}
 var c=s.ModuleRecovery.context(s,"drone_deep_cells",0)
 check(not c.ready and c.reason=="Hold full of tools: unload at the fittings screen","winch explains tool cargo refusal")
 s.mission.tool_racks=Racks.empty()
 check(s.ModuleRecovery.full_reason(s,0,"ordinary cargo refusal")=="ordinary cargo refusal","empty racks do not blame tools")
 s.mission.launch_equipment=Catalog.canonical({"chassis_a":"scout"})
 check(s.ModuleRecovery.full_reason(s,1,"ordinary cargo refusal")=="ordinary cargo refusal","zero capacity scout does not blame tools")
func shape_case(shape):
 root.size=shape;await settle()
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="runtime-test"
 root.add_child(game);await settle();game.set_process(false)
 game._show_fittings();await settle()
 var label=str(shape.x)
 var text=""
 for row in game.panel_box.find_children("*","Label",true,false):text+=row.text+"\n"
 check(RackView.summary(game) in text and text.count(" LOCKER ")==3 and "CARGO " in text and "SPACE EACH (LOCKER FIRST)" in text,"both viewports show separate locker and cargo used/left "+label)
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
 game.fitted_equipment=Catalog.canonical({"hull":"quiet","chassis_a":"scout","chassis_b":"endurance"})
 for choice in Tools.LOADOUTS:
  RackView.fill(game,choice)
  check(game.tool_racks==Racks.template(choice,game.fitted_equipment) and EconomyPanel098.can_begin(game),"fittings template honors current fit "+choice+" "+label)
 var archive=game._archive();check(game.store.valid(archive),"new rack profile validates "+label)
 var disk=Store098.new();disk.path="user://098-racks.save"
 check(archive.tool_racks_version==Racks.ARCHIVE_VERSION and disk.save(archive) and disk.load_game().tool_racks==game.tool_racks,"binary profile roundtrip preserves versioned racks "+label)
 var empty_archive=archive.duplicate(true);Racks.write_archive(empty_archive,Racks.empty())
 check(disk.save(empty_archive),"intentional empty locker profile saves "+label)
 game.store=disk;game._load_archive()
 check(game.tool_racks==Racks.empty(),"Main keeps intentional empty lockers after disk reload "+label)
 var old098=archive.duplicate(true);old098.erase("tool_racks_version");old098.tool_racks=Racks.empty()
 check(disk.save(old098),"098 empty template profile remains accepted "+label)
 game._load_archive()
 check(game.tool_racks==Racks.template(old098.upgrade,game.fitted_equipment),"Main refills098 empty template after disk reload "+label)
 var edited098=old098.duplicate(true);edited098.tool_racks.drone_a.emp=0
 check(disk.save(edited098),"098 edited zero-key profile saves "+label)
 game._load_archive()
 check(game.tool_racks==edited098.tool_racks,"Main preserves098 zero-key edit after reload "+label)
 var legacy=archive.duplicate(true);legacy.erase("tool_racks");legacy.erase("tool_racks_version")
 check(disk.save(legacy),"old profile remains accepted "+label)
 game.store=disk;game._load_archive()
 check(game.tool_racks==Racks.template(legacy.upgrade,game.fitted_equipment),"Main migrates loaded old profile to its template "+label)
 for suffix in ["",".bak"]:DirAccess.remove_absolute(disk.path+suffix)
 archive.tool_racks.drone_a.emp=-1;check(not game.store.valid(archive),"malformed profile racks rejected "+label)
 await android_back();check(game.screen=="menu","Android Back returns from racks "+label)
 game.queue_free();await settle()
func run():
 data_checks()
 refusal_checks()
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:await shape_case(shape)
 print("TOOL RACKS CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
