extends "res://tests/challenges_ui_tests.gd"
# WP-62: the menu screens use two columns on a wide screen (the cover screen 2520x1080 and the inner screen
# 2184x1968) and keep one column on a narrow one. Real controls, found by their ui_action ids.
const Modes=preload("res://src/presentation/runs/modes_frontend.gd")
const RunState=preload("res://src/campaign/runs/run_state.gd")
const RunArchive=preload("res://src/campaign/runs/run_archive.gd")
const CareerState=preload("res://src/campaign/career/career_state.gd")
const CareerArchive=preload("res://src/campaign/career/career_archive.gd")
const CareerFront=preload("res://src/presentation/career/career_frontend.gd")
const Columns=preload("res://src/presentation/prep_columns.gd")
func rect(node,id):
 var b=button(node,id)
 return b.get_global_rect() if b!=null else Rect2()
# True when `a` lies wholly to the left of `b`.
func beside(a:Rect2,b:Rect2)->bool:
 return a.size.x>0 and b.size.x>0 and a.end.x<=b.position.x+1.
func label_rect(node,start:String)->Rect2:
 for label in node.find_children("*","Label",true,false):
  if label.is_visible_in_tree() and label.text.begins_with(start):return label.get_global_rect()
 return Rect2()
# The control exists on the page. A tall page is reached by scrolling, as it always was.
func inside(r:Rect2)->bool:
 return r.size.x>0
func onscreen(r:Rect2)->bool:
 return r.size.x>0 and root.get_visible_rect().grow(1.).encloses(r)
func make_game(path:String):
 for suffix in ["",".bak",".tmp",".runs",".career"]:DirAccess.remove_absolute(path+suffix)
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"))
 game.capture_scenario="runtime-test";game.store.path=path
 root.add_child(game);await settle();game.set_process(false)
 game.completed=[0];game.unlocked=1;game._show_campaign();game.capture_scenario="";game._save_archive()
 return game
func finish(game,path:String):
 game.queue_free();await settle()
 for suffix in ["",".bak",".tmp",".runs",".career",".settings"]:DirAccess.remove_absolute(path+suffix)
func front_case(shape:Vector2i,wide:bool):
 root.size=shape;await settle()
 var path="user://wide-menus-%d.save"%shape.x
 var game=await make_game(path)
 var front=Front.new();front.settings_store.path=path+".settings";game.add_child(front);front.setup(game);await settle()
 var tag=" "+str(shape)
 check(front.title_backdrop.visible and front.title_backdrop.get_global_rect().encloses(root.get_visible_rect()),"the title backdrop fills the screen"+tag)
 # GAME MODES: four cards, two columns on a wide screen.
 front._mode_select();await settle()
 var a=rect(front,"mode_campaign");var b=rect(front,"mode_challenges");var c=rect(front,"mode_expeditions");var d=rect(front,"mode_career")
 check(inside(a) and inside(b) and inside(c) and inside(d) and (onscreen(a) and onscreen(b) and onscreen(c) and onscreen(d) if wide else true),"all four mode buttons are on the page, and on screen when the page is wide"+tag)
 if wide:
  check(beside(a,b) and beside(c,d) and absf(a.position.y-b.position.y)<2. and a.end.y<=c.position.y+1. and absf(a.position.x-c.position.x)<2.,"the four modes are a grid of two columns"+tag)
  var card=button(front,"mode_campaign").get_parent().get_parent()
  check(card is PanelContainer and card.get_child(0).get_child(1) is Label and card.get_child(0).get_child(1).text.begins_with("A continuing"),"each mode's line sits inside its card"+tag)
  check(front.title_backdrop.plate_pixels>0.,"the plate behind a two-column page is as wide as the page"+tag)
 else:
  check(absf(a.position.x-b.position.x)<2. and absf(a.position.x-d.position.x)<2. and a.end.y<=b.position.y+1.,"the modes stay a stacked list on a narrow screen"+tag)
 var tapped=await press(front,"mode_challenges")
 check(tapped and front.screen=="challenges","a card's button still opens its mode"+tag)
 await android_back();front._mode_select();await settle()
 # SETTINGS: the page buttons stay a row; independent rows go in two columns.
 front._settings_screen();await settle()
 var tabs=[rect(front,"settings_page_audio"),rect(front,"settings_page_display"),rect(front,"settings_page_controls")]
 check(beside(tabs[0],tabs[1]) and beside(tabs[1],tabs[2]),"the settings pages stay a row"+tag)
 var slider=front.find_children("*","HSlider",true,false)[0].get_global_rect()
 var mute=rect(front,"mute")
 check(inside(mute) and (beside(slider,mute)==wide),"audio: volumes and the switches are "+("two columns" if wide else "one column")+tag)
 for page in ["display","controls"]:
  front.settings_page=page;front._settings_screen();await settle()
  var first=rect(front,"quality_standard") if page=="display" else rect(front,"setting_mirrored_hud")
  var second=rect(front,"setting_high_contrast") if page=="display" else rect(front,"setting_haptics")
  check(inside(first) and inside(second) and (beside(first,second)==wide),page+": the rows are "+("two columns" if wide else "one column")+tag)
  check(inside(rect(front,"settings_reset")),page+": the page buttons stay reachable"+tag)
 front.settings_page="audio";front._settings_screen();await settle()
 var back=await press(front,"frontend_back")
 check(back and front.screen=="title","settings Back still returns to the title"+tag)
 # EXPEDITIONS menu and NAVAL CAREER intro: the explanation beside the actions.
 Modes.expeditions(front);await settle()
 var intro=label_rect(front,"Separate fleet");var new_run=rect(front,"run_new")
 check(inside(new_run) and (beside(intro,new_run)==wide),"expeditions: the explanation and the actions are "+("two columns" if wide else "one column")+tag)
 CareerFront.show(front);await settle()
 intro=label_rect(front,"Regional reconnaissance");var start=rect(front,"career_new")
 check(inside(start) and (beside(intro,start)==wide),"career: the explanation and the start are "+("two columns" if wide else "one column")+tag)
 # A resize that changes the answer redraws the screen in the other shape.
 front._mode_select();await settle()
 var other=Vector2(960,432) if wide else Vector2(2184,1968)
 root.size=Vector2i(other);game.size=other;await settle();await settle()
 a=rect(front,"mode_campaign");b=rect(front,"mode_challenges")
 check((not beside(a,b)) if wide else beside(a,b),"a resize redraws the modes in the other shape"+tag)
 root.size=shape;game.size=Vector2(shape);await settle()
 await finish(game,path)
func main_case(shape:Vector2i,wide:bool):
 root.size=shape;await settle()
 var path="user://wide-menus-main-%d.save"%shape.x
 var game=await make_game(path)
 var tag=" "+str(shape)
 # SUPPLIES: what you hold and what the next launch costs beside the repairs and purchases.
 game._show_economy();await settle()
 check(game.get_meta("prep_wide",false)==wide,"supplies use two columns only on a wide screen"+tag)
 var holding=label_rect(game,"You have:");var bare=rect(game,"eco_bare");var ironman=rect(game,"eco_ironman")
 check(inside(bare) and (beside(holding,bare)==wide and not beside(ironman,bare) and ironman.position.y>bare.position.y),"supplies: holdings and purchases are "+("two columns" if wide else "one column")+tag)
 check(inside(rect(game,"back")),"supplies: Back is reachable"+tag)
 var launch=label_rect(game,"NEXT LAUNCH REFIT")
 check(launch.size.x>0 and (beside(launch,bare)==wide),"supplies: the launch cost stays with what you hold"+tag)
 await press(game,"back")
 check(game.screen=="menu","supplies Back returns to Operations"+tag)
 # EXPEDITION operation menu: the briefing beside the rider and the tools.
 check(RunArchive.persist(game,RunState.new_run(12345)),"a seeded run is saved"+tag)
 var front=Front.new();front.settings_store.path=path+".settings";game.add_child(front);front.setup(game,true)
 Modes.start(front);await settle()
 var session=game.get_node_or_null("ExpeditionSession")
 check(session!=null and session.screen=="expedition_menu","the expedition menu opens"+tag)
 if session!=null:
  check(session.get_meta("prep_wide",false)==wide,"the expedition menu uses two columns only on a wide screen"+tag)
  var goal=label_rect(session,"GOAL:");var begin=rect(session,"run_begin")
  var tool_row=Rect2()
  for b in session.find_children("*","Button",true,false):
   if String(b.get_meta("ui_action","")).begins_with("mode_rack_add_") and b.is_visible_in_tree():tool_row=b.get_global_rect();break
  check(goal.size.x>0 and inside(begin) and tool_row.size.x>0,"the expedition briefing, the tool rows and BEGIN are on screen"+tag)
  check(beside(goal,tool_row)==wide,"expedition: the briefing and the tools are "+("two columns" if wide else "one column")+tag)
  session._return();await settle()
 # NAVAL CAREER contract board: the contracts beside the standing rules and the links.
 check(CareerArchive.persist(game,CareerState.new_career()),"a career is saved"+tag)
 CareerFront.start(front);await settle()
 var career=game.get_node_or_null("CareerSession")
 check(career!=null and career.screen=="career_board","the contract board opens"+tag)
 if career!=null:
  check(career.get_meta("prep_wide",false)==wide,"the contract board uses two columns only on a wide screen"+tag)
  var contract=null
  for b in career.find_children("*","Button",true,false):
   if String(b.get_meta("ui_action","")).begins_with("career_contract_"):contract=b;break
  var supplies=rect(career,"career_supplies");var leave=rect(career,"career_return")
  check(contract!=null and inside(supplies) and inside(leave),"contract board: contracts, links and Back are on screen"+tag)
  if contract!=null:
   var cr=contract.get_global_rect()
   check(beside(cr,supplies)==wide and beside(cr,leave)==wide,"contract board: contracts and links are "+("two columns" if wide else "one column")+tag)
   # The rider line stays inside its contract's block: under its own button, in the same column, before the next rule.
   var column=contract.get_parent()
   var index=contract.get_index()
   var rider=column.get_child(index+1)
   check(rider is Label and rider.text.begins_with("OPTIONAL RIDER FOR") and column.get_child(index+2) is HSeparator,"each rider line stays in its contract's block"+tag)
  var tapped=await press(career,"career_supplies")
  check(tapped and career.screen=="career_supplies","contract board links still open"+tag)
  career._show_campaign();await settle()
  check(inside(rect(career,"career_return")),"contract board Back is reachable again"+tag)
 await finish(game,path)
func run():
 for shape in [[Vector2i(2520,1080),true],[Vector2i(2184,1968),true],[Vector2i(960,432),false]]:
  await front_case(shape[0],shape[1])
  await main_case(shape[0],shape[1])
 print("WIDE MENUS UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
