extends "res://tests/wide_menus_ui_tests.gd"
# WP-109 (critic round 8): the result's action buttons are always on screen (a pinned footer under the scrolling detail,
# the cover screen and the inner screen at 100%, 130% and 150% text); the Career card says what it kept, lost and
# refills; the Career briefing shows the total reward and the replay reduction; RETRY OPERATION says the carried hull;
# photo pay gives its figures; the Career board's right panel stays while the contract list scrolls.
const Flow=preload("res://src/presentation/flow/campaign_flow.gd")
const Settings=preload("res://src/presentation/frontend/frontend_settings.gd")
const CareerBoard=preload("res://src/presentation/career/career_board.gd")
const DamageLog=preload("res://src/presentation/damage_log/damage_log.gd")
const PayTable=preload("res://src/presentation/photo_pay/pay_table.gd")
const ResultText=preload("res://src/presentation/mode_result_text.gd")
const Words=preload("res://src/presentation/runs/run_words.gd")
const Economy=preload("res://src/campaign/economy.gd")
const Names=preload("res://src/names.gd")
var seen:Array=[]
# A button is reachable without scrolling: it sits in the pinned footer, wholly inside the screen, clear of the scrolling page.
func pinned(game,id:String,tag:String)->void:
 var b=button(game,id)
 check(b!=null,"%s is on the result screen%s"%[id,tag])
 if b==null:return
 var r:Rect2=b.get_global_rect()
 check(b.get_parent()==game.menu_footer,"%s sits in the pinned footer, not the scrolling page%s"%[id,tag])
 check(root.get_visible_rect().grow(1.).encloses(r),"%s is wholly on screen without scrolling%s: %s"%[id,tag,str(r)])
 check(not r.intersects(game.scroll.get_global_rect().grow(-1.)),"%s is clear of the scrolling detail%s"%[id,tag])
 check(r.size.y>=game.ui_touch_height-.5,"%s keeps its touch height%s"%[id,tag])
 seen.append("%s %s %s"%[tag,id,str(r)])
func labels_text(node)->String:
 var out:PackedStringArray=[]
 for label in node.find_children("*","Label",true,false):out.append(label.text)
 return "\n".join(out)
func campaign_case(shape:Vector2i,scale:float)->void:
 root.size=shape;await settle()
 Settings.current["text_scale"]=scale
 var tag=" at %dx%d %d%%"%[shape.x,shape.y,roundi(scale*100)]
 var path="user://result-actions-%d-%d.save"%[shape.x,roundi(scale*100)]
 var game=await make_game(path)
 game.size=Vector2(game.get_viewport_rect().size);game._layout();await settle()
 game.sim.hull=0.;game.sim.outcome="lost";game.sim.message="Hull lost."
 game._debrief();await settle();await settle()
 for id in ["retry","back"]:pinned(game,id,tag+" (lost)")
 game._show_campaign();await settle()
 game.sim.hull=80.;game.sim.outcome="won";game.mission_index=0;game.completed=[];game.sim.message="Recovered."
 game._debrief();await settle();await settle()
 for id in ["next_dive","retry","back"]:pinned(game,id,tag+" (won)")
 check(labels_text(game.panel_box).contains("ARCHIVE RECOVERED"),"the page above the footer still holds the result"+tag)
 # WP-132: a first win opens the hull and drone frames on the hub: one line says so, the hub button says NEW, NEXT DIVE stays.
 check(labels_text(game.panel_box).contains("NEW: hull and drone frames unlocked"),"a first recovery says the frames are unlocked"+tag)
 check(button(game,"back").text==Flow.OPERATIONS_NEW and button(game,"next_dive")!=null,"the hub button says NEW and NEXT DIVE stays"+tag)
 game._show_campaign();await settle()
 game.sim.hull=80.;game.sim.outcome="won";game.mission_index=0;game.completed=[0];game.sim.message="Recovered."
 game._debrief();await settle();await settle()
 check(not labels_text(game.panel_box).contains("NEW: ") and button(game,"back").text=="OPERATIONS ARCHIVE","a replay with nothing new carries no unlock line"+tag)
 await finish(game,path)
func career_case(shape:Vector2i,scale:float)->void:
 root.size=shape;await settle()
 Settings.current["text_scale"]=scale
 var tag=" at %dx%d %d%%"%[shape.x,shape.y,roundi(scale*100)]
 var path="user://result-actions-career-%d-%d.save"%[shape.x,roundi(scale*100)]
 var game=await make_game(path)
 var front=Front.new();front.settings_store.path=path+".settings";game.add_child(front);front.setup(game,true)
 check(CareerArchive.persist(game,CareerState.new_career()),"a career is saved"+tag)
 CareerFront.start(front);await settle()
 var career=game.get_node_or_null("CareerSession")
 check(career!=null and career.screen=="career_board","the contract board opens"+tag)
 if career==null:await finish(game,path);return
 var wide:bool=career.get_meta("prep_wide",false)
 # (6) The right panel stays while the contract list scrolls (wide screens).
 if wide:
  var pane=career.get_meta("prep_scroll",null)
  check(pane is ScrollContainer,"the contract list scrolls in its own pane"+tag)
  var before=rect(career,"career_supplies")
  if pane is ScrollContainer:
   pane.scroll_vertical=100000;await settle()
   var after=rect(career,"career_supplies")
   check(before.size.x>0 and after.position.is_equal_approx(before.position),"SUPPLIES and BACK stay in place while the list scrolls"+tag+": %s -> %s"%[str(before),str(after)])
   check(onscreen(rect(career,"career_return")),"BACK TO GAME MODES stays on screen"+tag)
   pane.scroll_vertical=0
 # (4) The briefing's reward: the total, and on a replay the reduced salvage.
 career._select_contract("brannock_watch");await settle()
 var text=labels_text(career.panel_box)
 var c=CareerBoard.Table.CONTRACTS["brannock_watch"]
 var total=Economy.fmt(CareerBoard.sum_pay(c.reward,CareerBoard.salvage(career,c))).to_lower()
 check(text.contains("%s in total"%total) and text.contains("contract pay %s"%Economy.fmt(c.reward).to_lower()),"the briefing names the total reward: "+total+tag)
 check(not text.contains("Salvage is reduced"),"a first recovery does not claim a reduction"+tag)
 check(text.contains("Lose it: standing") and text.contains("salvage of only"),"the briefing says what a loss still pays"+tag)
 career.career_state.progress.completed.append(c.op);career._select_contract("brannock_watch");await settle()
 text=labels_text(career.panel_box)
 var replay=Economy.fmt(CareerBoard.sum_pay(c.reward,CareerBoard.salvage(career,c))).to_lower()
 check(text.contains("Salvage is reduced") and text.contains("%s in total"%replay) and replay!=total,"a replay says its salvage is reduced and shows the new total: "+replay+tag)
 career.career_state.progress.completed.erase(c.op)
 # (1)(3) A lost contract: the result card says what refills, what is kept and what is lost, with its buttons on screen.
 career._select_contract("brannock_watch");await settle()
 career._begin();await settle()
 check(career.active_started,"the contract dive launches"+tag)
 if career.active_started:
  career.sim.hull=0.;career.sim.outcome="lost"
  var objective=career.sim.mission.objectives[0];objective["captured"]=true;objective["photo_quality"]=.8
  career._debrief();await settle();await settle()
  check(career.screen=="career_result","the contract result opens"+tag)
  pinned(career,"career_board",tag+" (career lost)")
  var card=labels_text(career.panel_box)
  check(card.contains("Field tools refill at the next launch") and not card.contains("Spent:"),"the card says tools refill, and does not call their use a cost"+tag)
  check(card.contains("the lowest hull this difficulty allows") and card.contains("The next dive starts at") and not card.contains("lowest this difficulty records after a loss"),"the card says why the hull is recorded as it is"+tag)
  check(card.contains(ResultText.CAREER_PHOTOS_LOST),"a lost contract says its photographs are lost and none are kept"+tag)
 await finish(game,path)
func words_case()->void:
 var cover=load("res://scenes/main.tscn").instantiate();cover.capture_scenario="runtime-test";root.add_child(cover);await settle();cover.set_process(false)
 # (5) RETRY OPERATION names the carried hull, from the number the briefing uses; the source button asks for that label.
 cover.economy.cond[Names.CRAFT_QUIETUS]=60
 check(Flow.retry_label(cover,true)==Flow.RETRY_HULL_OPERATION%60 and Flow.retry_label(cover,true).begins_with("RETRY OPERATION"),"RETRY OPERATION says the hull the next attempt starts with: "+Flow.retry_label(cover,true))
 cover.economy.cond[Names.CRAFT_QUIETUS]=100
 check(Flow.retry_label(cover,true)=="RETRY OPERATION","an undamaged operation retry keeps the plain label")
 check(FileAccess.get_file_as_string("res://src/presentation/expedition_operations.gd").contains("retry_label(main,true)"),"the Expedition result's retry button reads that label")
 cover.queue_free();await settle()
 # (2) Photo pay says what it is made of.
 check(PayTable.TEXT.head.contains("not scrap or cells") and PayTable.TEXT.head.contains("intel"),"photo pay says it pays intel, not scrap or cells: "+PayTable.TEXT.head)
 check(PayTable.TEXT.record.contains("frame quality"),"each photo pay row names its figure as frame quality")
 check(PayTable.TEXT.unused.contains("%s") and PayTable.TEXT.credited.contains("%d%%"),"intel with no use says so; credited intel gives its figure")
 # (3) The words the Career card uses.
 check(Words.career_ledger("2 EMP","nothing","x")[1]=="Used: 2 EMP. Field tools refill at the next launch.","the Career ledger's second line is the tool use and the refill")
 check(DamageLog.FLOOR_LINE_LOST.contains("the lowest hull this difficulty allows"),"the hull floor line states the floor as a rule of the difficulty")
func run():
 await words_case()
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:
  for scale in [1.,1.3,1.5]:
   await campaign_case(shape,scale)
   await career_case(shape,scale)
 Settings.current["text_scale"]=1.
 for line in seen:print("RA ",line)
 print("RESULT ACTIONS UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
