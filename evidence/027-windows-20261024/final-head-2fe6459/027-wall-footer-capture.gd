extends "res://tests/fix2_menu_ui_tests.gd"
# Source-known terminal and archive-layout fixtures, not blind mission play.
const Photo=preload("res://src/simulation/photo_capture.gd")
const Ending=preload("res://src/campaign/endings_photo.gd")
const ArchiveView=preload("res://src/presentation/photo_view.gd")
func archive_fixture()->Dictionary:
 var archive={}
 for id in [30,31]:
  for index in 2:
   var s=preload("res://src/simulation/simulation.gd").new();s.start(id)
   var o=s.mission.objectives[index]
   s.units[0].band=o.band;s.units[0].pos=o.pos+Vector2(-120,0);s.units[0].angle=0.
   s.command("frame",{"mode":"tight","focus":o.optical})
   Photo.begin(s,0,index)
   for tick in 300:Photo.tick(s,0,o,1./60.);s.elapsed+=1./60.
   var shot=Photo.finish(s,0,o).shot
   check(shot.usable,"fixture archive uses usable recorded frame "+o.optical)
   archive[o.optical]={"optical":o.optical,"name":o.name,"caption":o.evidence,"shots":[shot]}
 return archive
func shape_case(shape):
 root.size=shape;await settle()
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="runtime-test"
 root.add_child(game);await settle();game.set_process(false)
 game.completed=[0,1,2,3,4,5];game.unlocked=5
 game.expedition={"version":2,"route":"deep","routes":["deep"],"facts":{"deep":"Recovered branch account","confluence_route":"concealed"},"completed":[6,7,9,11,12,14,15,16,17,18,19,22,23,24,25,30,31],"notes":{},"references":{},"entitlements":[],"history":[],"selected_thread":"deep"}
 game.recovered_evidence=archive_fixture();game.active_started=false
 var before=game.recovered_evidence.duplicate(true)
 check(game.store.valid(game._archive()),"new completed campaign and archive remain valid without added save fields")
 var disk=preload("res://src/persistence/save_store.gd").new();disk.path="user://027-wall-%dx%d.save"%[shape.x,shape.y]
 var payload=game._archive()
 check(disk.save(payload) and disk.load_game()==payload,"completed wall archive checksummed disk roundtrip")
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute(disk.path+suffix)
 game._show_ending();await settle()
 check(game.screen=="photo_ending","both final recoveries select photo wall")
 var plates=game.panel_box.get_children().filter(func(c):return c is ArchiveView.Plate)
 check(plates.size()==4,"wall uses four real archive plate controls")
 check(not game.panel_box.find_children("*","Label",true,false).any(func(label):return label.text.begins_with("NO RECOVERED")),"recovered photographs are never described as absent when research is empty")
 for plate in plates:
  check(plate.size.x>0 and plate.size.y>=170 and plate.get_global_rect().end.x<=game.size.x,"plate bounded to viewport width")
 check(game.recovered_evidence==before,"presentation preserves archive")
 var footer_dir=OS.get_environment("SIRENS_027_CAPTURE_DIR")
 if DisplayServer.get_name()!="headless" and not footer_dir.is_empty():
  game.scroll.scroll_vertical=1000000;await settle()
  await create_timer(1.8).timeout;await RenderingServer.frame_post_draw
  var saved=root.get_texture().get_image().save_png(footer_dir+"/wall-footer-%dx%d.png"%[shape.x,shape.y])
  if saved!=OK:push_error("Footer capture failed");quit(1);return
  game.scroll.scroll_vertical=0;await settle()
 var capture_dir=OS.get_environment("SIRENS_027_CAPTURE_DIR")
 if DisplayServer.get_name()!="headless" and not capture_dir.is_empty():
  await create_timer(1.8).timeout
  await RenderingServer.frame_post_draw
  check(root.get_texture().get_image().save_png(capture_dir+"/wall-%dx%d.png"%[shape.x,shape.y])==OK,"native rendered wall captured")
 var back=button(game,"back")
 check(back!=null and back.size.y>=game.ui_touch_height and back.get_global_rect().end.y<=game.size.y,"Back remains visible with Android minimum target")
 if await press(game,"fork_ending"):check(game.screen=="ending","existing fork outcome still reachable by real touch")
 game._show_ending();await settle()
 if await press(game,"back"):check(game.screen=="menu","wall Back returns to campaign by real touch")
 game.expedition.completed.erase(31);game._show_ending();await settle()
 check(game.screen=="ending","incomplete pair keeps existing ending presentation")
 game.expedition.completed.append(31);game.recovered_evidence={};game._show_ending();await settle()
 check(game.screen=="photo_ending" and button(game,"fork_ending")!=null,"no recovered film still reaches ending and navigation")
 game.queue_free();await settle()
func run():
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:await shape_case(shape)
 print("PHOTO ENDINGS UI CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
