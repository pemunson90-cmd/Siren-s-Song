extends "res://tests/fix2_menu_ui_tests.gd"
const PlayerDive=preload("res://tests/fixtures/player_dive.gd")
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
  var seeded=Racks.template(choice)
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
 var stock={}
 for id in Tools.ids():stock[id]=1
 var stock_racks=Racks.from_stock(stock);var survey_template=Racks.template("survey")
 for id in Tools.ids():
  for slot in Racks.UNITS:
   check(stock_racks[slot].get(id,0)==(1 if survey_template[slot].get(id,0)>0 else 0),"stock allocation shares template craft mapping "+id+" "+slot)
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
 var e=Economy.new_state();var extra=Racks.template("endurance");extra.drone_a.emp=4
 check(Racks.cost(Racks.template("endurance"),"endurance",e).is_empty() and not Racks.cost(extra,"endurance",e).is_empty(),"template free, extra manufactured through economy")
 var iron=Economy.new_state("standard",true)
 check(Racks.cost(extra,"endurance",iron)==Racks.cost(extra,"endurance",e),"Ironman extras retain manufacturing price each launch")
 check(Racks.cost(Racks.template("endurance"),"endurance",Economy.new_state("accessible")).is_empty(),"Accessible template stays free")
 var s=Sim.new();s.start(0,"endurance",{"tool_racks":Racks.empty()})
 check(s.tools.values().all(func(n):return n==0) and Effects.state(s).counts.values().all(func(n):return n==0),"empty rack really launches with no finite stock")
 var survey=Racks.empty();survey.drone_a.sonobuoy=3
 s.start(0,"survey",{"tool_racks":survey});PlayerDive.launch_drones(s);s.sirens=[] # drones start aboard; the drone-carried tool is deployed from the water
 s.mission.structures=[];s.rock_shapes=[];s.rock_bounds=[];s._build_navigation()
 check(not s.command("sonobuoy") and Effects.count(s,"sonobuoy")==3,"Quietus cannot spend a drone's carried tool")
 s.selected=1;var origin=s.units[1].pos
 check(s.command("sonobuoy") and Effects.live(s,"sonobuoy")[0].pos==origin and Effects.live(s,"sonobuoy")[0].unit==1,"drone-carried sonobuoy deploys from owner")
 check(s.mission.tool_racks.drone_a.sonobuoy==2 and Sim.valid_snapshot(s.snapshot()),"spend synchronizes owner and aggregate save stock")
 var restored=Sim.new();check(restored.restore(s.snapshot()) and Racks.count(restored,"sonobuoy")==2,"restore preserves selected owner stock")
 var broken=s.snapshot();broken.mission.tool_racks.drone_a.sonobuoy=9
 check(not Sim.valid_snapshot(broken),"corrupt aggregate versus owner stock rejected")
 var owned=Racks.empty();owned.drone_b.emp=1;s.start(0,"endurance",{"tool_racks":owned});PlayerDive.launch_drones(s)
 # EMP needs a Siren inside its radius (Pat, 2026-11-12); one is placed beside drone B, which owns the charge.
 s.sirens=s.sirens.slice(0,1);s.sirens[0].pos=s.units[2].pos+Vector2(60,0)
 check(not s.command("emp") and s.tools.emp==1,"legacy tool refuses another craft's charge")
 s.selected=2
 check(s.command("emp") and s.tools.emp==0 and s.mission.tool_racks.drone_b.emp==0,"selected-craft legacy effect spends owner charge")
func template_case(choice:String,fit:Dictionary)->void:
 var label="%s %s/%s/%s"%[choice,fit.hull,fit.chassis_a,fit.chassis_b]
 var racks=Racks.template(choice)
 check(Racks.valid(racks) and Racks.reason(fit,racks).is_empty(),"aware template launchable "+label)
 var migrated=Racks.migrated({"upgrade":choice,"equipment":fit})
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
 check(Racks.migrated({"tool_racks":racks})==racks,"saved rack preserved "+label)
func migration_checks(fit:Dictionary)->void:
 var old={"upgrade":"survey","tool_racks":Racks.empty()}
 check(Racks.migrated(old)==Racks.template("survey"),"098 automatic empty template refilled")
 old.tool_racks.drone_a.emp=0
 check(Racks.migrated(old)==old.tool_racks,"098 edited zero-count key kept")
 old.tool_racks.drone_a.emp=2
 var kept=Racks.migrated(old)
 check(kept==old.tool_racks,"098 edited nonempty rack kept")
 kept.drone_a.emp=3
 check(old.tool_racks.drone_a.emp==2,"migration copies edited racks independently")
 Racks.write_archive(old,Racks.empty())
 check(Racks.valid_archive(old) and Racks.migrated(old)==Racks.empty(),"new intentional empty rack survives repeat migration")
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
 var carry=RackView.carry_text(game.tool_racks)
 # Wide screens print each craft's sentence over its bars; narrow screens print the three together.
 var carried=Racks.UNITS.all(func(slot):return RackView.carry_line(game.tool_racks,slot) in text) if game.get_meta("prep_wide",false) else carry in text
 check(carried and "carries" in carry and not " 0 " in carry and not "SPACE EACH" in text and not "LOCKER SPACE" in text,"carry sentences replace the spreadsheet rows "+label)
 var bars=game.panel_box.find_children("*","Control",true,false).filter(func(n):return n.has_meta("bar_label"))
 var locker_bars=bars.filter(func(n):return n.get_meta("bar_label")=="LOCKER")
 check(locker_bars.size()==3 and bars.size()==6,"one locker bar and one cargo bar per craft "+label)
 for unit in 3:
  if locker_bars.size()>unit:check(is_equal_approx(locker_bars[unit].fraction(),float(Racks.locker_used_ticks(game.tool_racks,unit))/float(Racks.locker_ticks(unit))),"locker bar drawn fraction equals held over locker "+str(unit)+" "+label)
 for id in Tools.ids():
  if id in Tools.field_ids() and not Tools.is_enabled(id):continue
  check(button(game,"rack_add_"+id)!=null and button(game,"rack_remove_"+id)!=null and (button(game,"rack_add_"+id).text==" +" or button(game,"rack_add_"+id).text=="+") and button(game,"rack_add_"+id).size.x>=game.ui_touch_height-.5,"tool row has one minus and one plus at touch size "+id+" "+label)
 check(not "LOAD +1" in text and "TOOLS FOR THE NEXT DIVE" in text and "QUICK FILL" in text,"plain headings "+label)
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
  check(game.tool_racks==Racks.template(choice) and EconomyPanel098.can_begin(game),"fittings template honors current fit "+choice+" "+label)
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
 check(game.tool_racks==Racks.template(old098.upgrade),"Main refills098 empty template after disk reload "+label)
 var edited098=old098.duplicate(true);edited098.tool_racks.drone_a.emp=0
 check(disk.save(edited098),"098 edited zero-key profile saves "+label)
 game._load_archive()
 check(game.tool_racks==edited098.tool_racks,"Main preserves098 zero-key edit after reload "+label)
 var legacy=archive.duplicate(true);legacy.erase("tool_racks");legacy.erase("tool_racks_version")
 check(disk.save(legacy),"old profile remains accepted "+label)
 game.store=disk;game._load_archive()
 check(game.tool_racks==Racks.template(legacy.upgrade),"Main migrates loaded old profile to its template "+label)
 for suffix in ["",".bak"]:DirAccess.remove_absolute(disk.path+suffix)
 archive.tool_racks.drone_a.emp=-1;check(not game.store.valid(archive),"malformed profile racks rejected "+label)
 await android_back();check(game.screen=="menu","Android Back returns from racks "+label)
 game.queue_free();await settle()
func labels_of(game)->String:
 var text=""
 for row in game.panel_box.find_children("*","Label",true,false):text+=row.text+"\n"
 return text
func bars_of(game,which:String)->Array:
 return game.panel_box.find_children("*","Control",true,false).filter(func(n):return n.get_meta("bar_label","")==which)
func locker_matches(game)->bool:
 for unit in 3:
  var bars=bars_of(game,"LOCKER")
  if bars.size()!=3 or not is_equal_approx(bars[unit].fraction(),float(Racks.locker_used_ticks(game.tool_racks,unit))/float(Racks.locker_ticks(unit))):return false
 return true
# WP-53: the preparation layout. Wide on both Fold shapes (summary left, controls scrolling on their own right),
# the old single column on a phone, and the same threshold for every screen.
func layout_checks():
 var Metrics=preload("res://src/presentation/layout_metrics.gd")
 check(Metrics.prep_wide(Vector2(1680,720),98.,1.) and Metrics.prep_wide(Vector2(1280,1153),87.,1.),"wide preparation layout on the cover and inner screens")
 check(not Metrics.prep_wide(Vector2(1280,2844),175.,1.) and Metrics.prep_wide(Vector2(1280,1153),87.,1.5) and Metrics.prep_wide(Vector2(1680,720),98.,1.5) and not Metrics.prep_wide(Vector2(1000,1153),87.,1.5),"single column on a portrait phone and when the largest text would not fit two columns (a column needs more than a tool row only when its longest word is wider)")
 check(Metrics.hub_wide(Vector2(1680,720),98.,1.5) and Metrics.hub_wide(Vector2(1280,1153),87.) and Metrics.hub_wide(Vector2(1280,1153),87.,1.5) and not Metrics.hub_wide(Vector2(1280,2844),175.),"the campaign hub is two columns on the cover and inner screens at every text size, one on a phone")
func prep_case(shape:Vector2i,expect_wide:bool):
 root.size=shape;await settle()
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="runtime-test"
 root.add_child(game);await settle();game.set_process(false)
 game._show_fittings();await settle()
 var label="%dx%d"%[shape.x,shape.y]
 var pane=game.get_meta("prep_scroll") if game.has_meta("prep_scroll") else null
 var text=labels_of(game)
 check(game.get_meta("prep_wide",false)==expect_wide and (pane!=null)==expect_wide,"Fittings column count "+label)
 check("You have: 8 scrap · 10 cells · 0 alloy." in text and "Scrap and cells come from" in text,"currency line and first-visit note "+label)
 for id in Tools.ids():check(not RackView.describe(id).is_empty() and RackView.describe(id) in text,"tool row says what "+id+" does "+label)
 # EMP at 2 is not a cap (nine per craft); torpedoes are capped at two across the fleet and say why.
 check(not button(game,"rack_add_emp").disabled and button(game,"rack_add_knock").disabled and RackView.REASONS["RACK FULL"] in text,"only a capped tool is greyed, and it says why "+label)
 var back=button(game,"back")
 if expect_wide:
  var left=pane.get_parent().get_child(0)
  var bars=bars_of(game,"LOCKER")+bars_of(game,"CARGO")
  check(bars.size()==6 and bars.all(func(b):return left.is_ancestor_of(b)) and back!=null and left.is_ancestor_of(back),"summary bars and BACK sit in the left column "+label)
  check(pane.is_ancestor_of(button(game,"rack_add_relay_buoy")) and pane.is_ancestor_of(button(game,"rack_empty")),"controls sit in the scrolling right column "+label)
  check(game.panel_box.size.y<=game.scroll.size.y+1.0,"the page itself does not scroll "+label)
  var last=button(game,"rack_add_relay_buoy")
  pane.ensure_control_visible(last);await settle()
  var screen=Rect2(Vector2.ZERO,game.size)
  check(bars.all(func(b):return screen.encloses(b.get_global_rect())) and screen.encloses(last.get_global_rect()),"bars on screen while the last tool row is on screen "+label)
  check(pane.scroll_vertical>0,"the right column scrolled on its own "+label)
  var before=bars_of(game,"LOCKER")[0].fraction();var now=before
  if await press(game,"rack_remove_hull_patch"):
   now=bars_of(game,"LOCKER")[0].fraction()
   check(now<before and locker_matches(game),"minus updates the summary LOCKER bar at once "+label)
   check(game.get_meta("prep_scroll").scroll_vertical>0,"the right column keeps its place after a change "+label)
   check(not "Scrap and cells come from" in labels_of(game),"first-visit note is shown once per visit "+label)
  if await press(game,"rack_add_decoy"):
   check(bars_of(game,"LOCKER")[0].fraction()>now and locker_matches(game),"plus updates the summary LOCKER bar at once "+label)
  var plain=labels_of(game)
  check(not plain.contains("Locker ") and not plain.contains("cargo 0 of"),"no feedback line under the row beside the summary "+label)
  # Turning the screen to a phone shape redraws the same screen as one column.
  root.size=Vector2i(1080,2400);await settle();await settle()
  check(game.screen=="fittings" and not game.get_meta("prep_wide",true) and not game.has_meta("prep_scroll") and game.panel_box.get_child(0)==button(game,"back"),"a resize to a phone shape redraws one column "+label)
 else:
  check(game.panel_box.get_child(0)==back and not game.has_meta("prep_scroll"),"single column keeps BACK first "+label)
  var order=[text.find("FITTINGS"),text.find("You have:"),text.find(RackView.carry_text(game.tool_racks)),text.find("TOOLS FOR THE NEXT DIVE"),text.find("QUICK FILL"),text.find("Extra charges for the next launch")]
  var sorted=order.duplicate();sorted.sort()
  check(order==sorted and not order.has(-1),"single column keeps today's order "+label)
  if await press(game,"rack_add_decoy"):
   var line=RackView.feedback_text(game,0)
   check(line.begins_with("Locker ") and line in labels_of(game),"the row just changed shows the craft's locker and cargo "+label)
   var rows=game.panel_box.get_children()
   var add=button(game,"rack_add_decoy");var holder=add.get_parent()
   check(holder.get_index()+1<rows.size() and rows[holder.get_index()+1] is Label and rows[holder.get_index()+1].text==line,"the feedback line sits directly under the changed row "+label)
 game.queue_free();await settle()
func run():
 data_checks()
 layout_checks()
 refusal_checks()
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:await prep_case(shape,true)
 await prep_case(Vector2i(1080,2400),false)
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:await shape_case(shape)
 print("TOOL RACKS CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
