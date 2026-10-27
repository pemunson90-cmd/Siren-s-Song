extends SceneTree
const Sim=preload("res://src/simulation/simulation.gd")
const Tools=preload("res://src/equipment/field_tools.gd")
const Kit=preload("res://src/equipment/equipment_catalog.gd")
const Upgrades=preload("res://src/equipment/craft_upgrades.gd")
const Effects=preload("res://src/simulation/field_tool_effects.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
const NEW_ITEMS=["quietus_ducted_shroud","quietus_scrubber_bed","quietus_long_hydrophone","quietus_reserve_cell","quietus_camera_cowl",
 "drone_ballast_pack","drone_mast_array","drone_whisper_props"]
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;print("FAIL ",label)
func _initialize():call_deferred("run")
func run():
 table();modules();recoveries();tools_in_play();collision_patch();finish()
func table():
 check(Tools.ids().size()==8 and Tools.field_ids().size()==4 and Tools.TOUCH_DP==48,"eight finite tools, four new, 48 dp targets")
 for id in Tools.ids():
  check(Tools.TOOLS[id].counts.keys()==Tools.LOADOUTS and Tools.is_enabled(id),"every loadout has a count for "+id)
 check(Tools.initial_counts("survey").keys().size()==4 and Tools.loadout_count("relay_buoy","survey")==2,"new tool stock follows the loadout")
func modules():
 var mounts={}
 for id in NEW_ITEMS+["quietus_wellhead_seal","drone_choir_tuner"]:
  var item=Kit.ITEMS.get(id,{});check(not item.is_empty(),"catalog row "+id)
  var slot=item.compatible_slots[0];var single={slot:id}
  check(Kit.valid_fitting(single) and Upgrades.pulse_cost(single,Kit.SLOTS.find(slot))==1.0,"legal alone with no pulse cost: "+id)
  if id in NEW_ITEMS:mounts[item.mount]=true
 check(mounts.size()==6,"conventional modules cover all six mount types")
 check(Kit.ITEMS.quietus_wellhead_seal.gate=="research" and Kit.ITEMS.quietus_wellhead_seal.artifact=="trench_seal_core","wellhead seal is research gated")
 check(Kit.ITEMS.drone_choir_tuner.mount=="SENSOR" and Kit.ITEMS.drone_choir_tuner.artifact=="choir_reed","choir tuner is a research gated sensor")
 var bare=Kit.default_loadout()
 check(Upgrades.passive_range(bare,0)==240.0 and Upgrades.cruise_speed(bare)==78.0 and Upgrades.passive_range(bare,1)==330.0,"bare craft unchanged")
 var hydro={"quietus":"quietus_long_hydrophone"};var shroud={"quietus":"quietus_ducted_shroud"}
 check(absf(Upgrades.passive_range(hydro,0)-288.0)<.01 and Upgrades.noise_factor(hydro,0)>1.0,"hydrophone reaches farther and is louder")
 check(Upgrades.noise_factor(shroud,0)<1.0 and Upgrades.cruise_speed(shroud)<78.0,"shroud trades speed for quiet")
 check(Upgrades.life_support({"quietus":"quietus_wellhead_seal"})<1.0 and Upgrades.battery_drain({"drone_a":"drone_ballast_pack"},1,1.0)<Upgrades.battery_drain(bare,1,1.0),"endurance rows apply")
func recoveries():
 check(Upgrades.recovered([0,1,2,3,4],{})==[],"first five operations keep their original hardware rewards")
 var foundation=Upgrades.recovered([5],{})
 check(foundation.slice(0,2)==["quietus_vector_drive","drone_deep_cells"] and foundation.size()==4,"operation five preserves original drive and cell grants before new hardware")
 var milestones={5:["quietus_ducted_shroud","drone_ballast_pack"],11:["quietus_scrubber_bed","drone_mast_array"],16:["quietus_long_hydrophone","drone_whisper_props"],22:["quietus_reserve_cell","quietus_camera_cowl"]}
 var completed=[]
 for milestone in milestones:
  var before=Upgrades.recovered([],{"completed":completed})
  completed.append(milestone)
  var after=Upgrades.recovered([],{"completed":completed})
  for id in milestones[milestone]:
   check(id not in before and id in after,"conventional hardware becomes earned at operation %d: %s"%[milestone,id])
 var all_earned=Upgrades.recovered([5],{"completed":[5,7,8,11,16,22]})
 check("quietus_baffles" in all_earned and "drone_survey_array" in all_earned,"original expedition hardware rewards remain")
 check("quietus_wellhead_seal" not in all_earned and "drone_choir_tuner" not in all_earned,"alien research hardware is never automatically earned by operation completion")
func open():
 var s=Sim.new();s.start(0,"endurance");s.mission.structures=[];s.rock_shapes=[];s.rock_bounds=[];s.sirens=[];s._build_navigation()
 return s
func tools_in_play():
 var s=open();var u=s.units[0]
 check(Effects.count(s,"sonobuoy")==2 and Effects.count(s,"hull_patch")==1 and Sim.valid_snapshot(s.snapshot()),"fresh stock is seeded and saves")
 var held=s.tools.duplicate()
 check(s.command("sonobuoy") and s.command("sonobuoy") and not s.command("sonobuoy") and Effects.count(s,"sonobuoy")==0,"sonobuoy is finite")
 check(s.tools==held,"existing finite tools untouched")
 s.sirens=[{"pos":u.pos+Vector2(300,0),"type":"patroller","band":1,"transition":{},"stun":0}]
 var marks=Effects.bearings(s)
 check(marks.size()==2 and not marks[0].has("distance") and absf(marks[0].angle)<.05,"buoys hear a Siren as a bearing only")
 s.sirens=[]
 var body={"pos":u.pos+Vector2(100,0),"band":1,"transition":{}}
 u.angle=0.0
 check(s.Depth.sight(s,u,body) and Photo.can_sight(s,0,body.pos),"clear water shows the contact to sight and camera")
 check(s.command("silt_screen",{"point":u.pos+Vector2(50,0)}) and not s.Depth.sight(s,u,body) and not Photo.can_sight(s,0,body.pos) and s.Depth.clear(s,u.pos,body.pos,u.band),"silt blocks actual camera sight and contact sight while physical clearance stays open")
 check(not s.command("silt_screen") and Effects.count(s,"silt_screen")==0,"silt is finite")
 s.elapsed+=30.0
 check(s.Depth.sight(s,u,body) and Photo.can_sight(s,0,body.pos),"silt expiry restores contact and camera sight")
 s=open();check(not s.command("hull_patch") and Effects.count(s,"hull_patch")==1,"intact hull spends nothing")
 var far=s.passive_range(1);s.units[1].pos=s.units[0].pos
 check(s.command("relay_buoy"),"relay buoy places")
 check(absf(s.passive_range(1)-far*1.35)<.01 and s.passive_range(0)==240.0,"relay lengthens drone reach only")
 s.units[2].pos=s.units[0].pos
 check(absf(s.passive_range(2)-far*1.35)<.01,"relay benefits the second drone independently inside its radius")
 s.units[2].pos=s.units[0].pos+Vector2(421,0)
 check(is_equal_approx(s.passive_range(2),far),"second drone loses the bonus outside the radius while the first retains it")
 s.units[1].pos=Vector2(40,40)
 check(s.passive_range(1)==far or s.units[1].pos.distance_to(s.units[0].pos)<=420.0,"reach is local to the relay")
 var saved=s.snapshot();var back=Sim.new()
 check(Sim.valid_snapshot(saved) and back.restore(saved) and Effects.live(back,"relay_buoy").size()==1,"placed items round trip through a save")
 for mutate in [func(m):m.field_tools.counts.sonobuoy=-1,func(m):m.field_tools.counts.emp=1,func(m):m.field_tools.placed=[{"id":"sonobuoy"}],
   func(m):m.field_tools.placed=[{"id":"hull_patch","pos":Vector2.ZERO,"band":1,"until":1.0,"unit":0}],func(m):m.field_tools="x"]:
  var bad=s.snapshot();mutate.call(bad.mission);check(not Sim.valid_snapshot(bad),"corrupt field tool state is rejected")
 var old=s.snapshot();old.mission.erase("field_tools")
 var legacy=Sim.new();check(Sim.valid_snapshot(old) and legacy.restore(old) and not legacy.command("sonobuoy"),"older saves restore with no field tools")
func collision_patch():
 var s=open()
 s.hull=60.0
 check(not s.command("hull_patch") and s.hull==60.0 and Effects.count(s,"hull_patch")==1,"prior condition or unrelated hull loss is not repairable")
 s._hull_strike(s.units[0],32.0)
 check(is_equal_approx(s.hull,51.0) and is_equal_approx(s.mission.field_tools.repairable_collision_loss,9.0),"only actual collision delta credits repair")
 var saved=s.snapshot();var back=Sim.new()
 check(Sim.valid_snapshot(saved) and back.restore(saved) and is_equal_approx(back.mission.field_tools.repairable_collision_loss,9.0),"collision budget round trips")
 check(back.command("hull_patch") and is_equal_approx(back.hull,60.0) and back.mission.field_tools.repairable_collision_loss==0.0,"partial patch leaves all prior condition loss intact and consumes budget")
 check(not back.command("hull_patch") and back.hull==60.0 and Effects.count(back,"hull_patch")==0,"patch stock is one use")
 s=open();s._hull_strike(s.units[0],1000.0)
 check(s.command("hull_patch") and s.hull==95.0 and s.mission.field_tools.repairable_collision_loss==5.0,"large collision repair caps at thirty")
 s=open();s._hull_strike(s.units[0],1000.0);s.hull=95.0
 check(s.command("hull_patch") and s.hull==100.0 and s.mission.field_tools.repairable_collision_loss==30.0,"repair also caps at missing hull")
 s=open();s.hull=4.0;s._hull_strike(s.units[0],1000.0)
 check(s.mission.field_tools.repairable_collision_loss==4.0 and not Effects.use(s,"hull_patch",{}),"lethal collision credits actual loss only and cannot revive Quietus")
 s=open();s._hull_strike(s.units[0],32.0);s.units[0].alive=false
 check(not Effects.use(s,"hull_patch",{}) and Effects.count(s,"hull_patch")==1,"direct patch refuses dead craft")
 var beam=Sim.new();beam.start(0,"endurance")
 var enemy=beam.sirens[0]
 beam.mission.structures=[];beam.rock_shapes=[];beam.rock_bounds=[];beam._build_navigation()
 enemy.pos=beam.units[0].pos+Vector2(50,0);enemy.band=beam.units[0].band;enemy.transition={};enemy.stun=0.0;enemy.target=0;enemy.lock=3.99;enemy.type="patroller"
 beam.sirens=[enemy];beam._hull_strike(beam.units[0],32.0)
 check(beam._threats(0.02) and beam.hull==0.0 and beam.outcome=="lost","actual Siren beam remains lethal after collision damage")
 check(not beam.command("hull_patch") and not Effects.use(beam,"hull_patch",{}) and beam.hull==0.0 and Effects.count(beam,"hull_patch")==1 and is_equal_approx(beam.mission.field_tools.repairable_collision_loss,9.0),"beam loss never credits or accepts repair even with collision credit")
 for value in [-1.0,101.0,INF,NAN,"9",false]:
  var bad=saved.duplicate(true);bad.mission.field_tools.repairable_collision_loss=value
  check(not Sim.valid_snapshot(bad),"corrupt collision repair budget is rejected")
 var bad=saved.duplicate(true);bad.mission.field_tools.counts.hull_patch=2
 check(not Sim.valid_snapshot(bad),"multiple patch stock is rejected")
 var old=saved.duplicate(true);old.mission.field_tools.erase("repairable_collision_loss")
 var legacy=Sim.new()
 check(Sim.valid_snapshot(old) and legacy.restore(old) and not legacy.command("hull_patch") and legacy.hull==saved.hull,"legacy field tools have zero repairable collision budget")
func finish():print("FIELD TOOLS CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
