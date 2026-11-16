extends SceneTree
# Source-known technical projections, not blind play. The no-receipt case
# temporarily obstructs the acoustic path for one actual send, then restores
# authored geometry; the public unsatisfied result remains available to UI.
var View=load("res://src/presentation/warning_chain_view.gd")
var checks=0
var failures=0
var folder=""
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():call_deferred("run")
func settle():
 for n in 6:await process_frame
func capture(name:String):
 if folder.is_empty() or DisplayServer.get_name()=="headless":return
 await RenderingServer.frame_post_draw;root.get_texture().get_image().save_png(folder.path_join(name+".png"))
func run():
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--capture-dir="):folder=arg.trim_prefix("--capture-dir=");DirAccess.make_dir_recursive_absolute(folder)
 var public_info={"result":{},"output":"service","sends_used":["service"]}
 check("NO RECEIPT" in View.proof(public_info) and not "NOT SENT" in View.proof(public_info),"a finite service send without receipt never appears unsent")
 public_info.output="mast";public_info.sends_used=["mast"]
 check("NO RECEIPT" in View.proof(public_info) and not "NOT SENT" in View.proof(public_info),"used output without proved result stays distinct from unsent selection")
 var has_labels=View.has_method("world_labels")
 check(has_labels,"plant hardware and active pulse share one public label projection")
 if not has_labels:finish();return
 for dimensions in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  root.size=dimensions;await settle()
  var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="warning-chain-world-public-fixture"
  if dimensions.x==2520:game.fixture_safe_area=Rect2(136,0,2384,1080)
  root.add_child(game);await settle();game.set_process(false);game.completed=[0,1,2,3,4,5];game.unlocked=5;game._start_mission(10);await settle()
  var sim=game.sim;var h=game.mission_hud;var label="cover" if dimensions.x==2520 else "inner"
  sim.sirens=[];sim.units[0].pos=Vector2(480,1055);sim.units[0].vel=Vector2.ZERO;sim.command("chain_power",{"mode":"backup"})
  sim.units[0].pos=Vector2(1520,1055);sim.command("chain_route",{"output":"service"})
  sim.mission.structures=[sim.warning_chain_context().crosslink.rect];sim._build_navigation();sim.command("chain_send");sim.mission.structures=[];sim._build_navigation()
  game.ocean.focus_craft();game._refresh();h.open("plant",View.nearest_station(sim));await settle()
  check(sim.warning_chain_context().result.is_empty() and sim.warning_chain_context().sends_used==["service"] and "NO RECEIPT" in View.summary(sim),"actual unreceived finite service output renders sent with no receipt")
  check(h.extra.chain_send.disabled and not h.extra.chain_mast.disabled and "NORTH MAST" in View.detail(sim,"panel"),"failed service keeps its explicit available mast fallback and cannot repeat the used output")
  await capture(label+"-service-sent-no-receipt-panel-fixture")
  var labels=View.world_labels(sim);var origins=labels.map(func(row):return row.origin)
  check(labels.size()==4 and origins.count(Vector2(1000,400))==1 and labels.filter(func(row):return row.id=="panel")[0].text.contains("1400m"),"live generator/shutter/service pulses coalesce with four distinct authored hardware labels")
  h.dismiss();game.ocean.fit_chart();game._refresh();await settle();await capture(label+"-service-sent-no-receipt-overview-fixture")
  sim.command("chain_route",{"output":"mast"});game._refresh();h.open("plant",View.nearest_station(sim));await settle();await capture(label+"-mast-selected-panel")
  check("NOT SENT" in View.proof(sim.warning_chain_context()),"switching to the unused mast restores only that branch's unsent state")
  sim.command("chain_send");h.dismiss();game.ocean.fit_chart();game._refresh();await settle()
  labels=View.world_labels(sim);var mast=labels.filter(func(row):return row.id=="mast")
  check(mast.size()==1 and "1100m" in mast[0].text and "UNKNOWN" in mast[0].text,"active mast emission and identity form one readable truthful hardware label")
  await capture(label+"-mast-warning-coalesced-overview")
  game.queue_free();await settle()
 finish()
func finish():
 print("WARNING CHAIN WORLD UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
