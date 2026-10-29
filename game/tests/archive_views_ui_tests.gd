extends "res://tests/fix2_menu_ui_tests.gd"
# RESEARCH and ARCHIVE views by real touch: entries from Operations and Fittings, pay a pending
# project through the existing economy action, evidence rows, voices at briefing and in the dive.
const ArchiveTable=preload("res://src/presentation/archive/archive_table.gd")
const Feed=preload("res://src/presentation/archive/voice_feed.gd")
func texts(game):
 var text=""
 for label in game.panel_box.find_children("*","Label",true,false):text+=label.text+"\n"
 return text
func shape_case(shape):
 root.size=shape;await settle()
 var game=load("res://scenes/main.tscn").instantiate();game.set_script(load("res://tests/density_main.gd"));game.capture_scenario="runtime-test"
 root.add_child(game);await settle();game.set_process(false)
 game.store.path="user://archive_views_test.save"
 game.completed=range(6);game.unlocked=5;game.active_started=false
 game.expedition={"version":1,"route":"deep","routes":["deep"],"facts":{"glass_record_16":"read"},"completed":[6,20],"entitlements":[],
  "research":{"materials":["prism_core"],"spent":[],"projects":[]}}
 game.economy.stock.alloy=5
 game.recovered_evidence={"furnace":{"name":"Foundry furnace","caption":"A vent on a feed line.","optical":"furnace"}}
 game.photo_records={"3:0":{"photo_quality":0.8,"photo_craft":0,"photo_distance":60.0}}
 game._show_campaign();await settle()
 var entry=button(game,"archive")
 check(entry!=null and entry.size.y>=game.ui_touch_height,"Operations offers a full-height RESEARCH / ARCHIVE entry")
 var dossier_home=button(game,"siren_dossier")
 check(dossier_home!=null and dossier_home.size.y>=game.ui_touch_height,"Operations offers a full-height Siren dossier entry")
 check(dossier_home!=null and game.scroll.get_global_rect().encloses(dossier_home.get_global_rect()),"Operations dossier entry remains visible in the scroll viewport")
 check(button(game,"next_operation")!=null and game.scroll.get_global_rect().encloses(button(game,"next_operation").get_global_rect()),"entry leaves the next operation on the first screen")
 await press(game,"siren_dossier");check(game.screen=="siren_dossier","Operations dossier entry opens the read-only dossier")
 await android_back();check(game.screen=="menu","Android Back from Operations dossier entry returns to Operations")
 check(button(game,"archive")!=null,"dossier navigation preserves the Operations archive entry")
 await press(game,"archive");check(game.screen=="archive","entry opens the archive view")
 var text=texts(game)
 check(text.contains("SHELF") and text.contains("PHOTO") and text.contains("QUALITY 80%") and text.contains("ARTIFACT · PRISM CORE · AWAITING RESEARCH"),"archive groups photo, artifact by region")
 var dossier_button=button(game,"siren_dossier")
 check(dossier_button!=null and dossier_button.size.y>=game.ui_touch_height,"archive offers a full-height Siren dossier entry")
 await press(game,"siren_dossier")
 check(game.screen=="siren_dossier" and not texts(game).contains("HUNTER") and not texts(game).contains("SWEEPER"),"unseen Siren roles reveal no dossier text")
 var cue=game.hud.get_node("FirstSirenCue")
 cue.tracker.restore_types(["hunter"]);game.photo_intel={"siren_hunter":{"q":0.72,"op":3},"siren_relay":{"q":0.46,"op":5}}
 await load("res://src/presentation/siren_dossier/siren_dossier.gd").show(game);await settle()
 text=texts(game)
 check(text.contains("HUNTER") and text.contains("BEST RECOVERED PHOTO QUALITY · 72%"),"seen and studied role lists its recovered quality")
 check(text.contains("RELAY") and text.contains("BEST RECOVERED PHOTO QUALITY · 46%"),"recovered role intel independently unlocks its row")
 check(not text.contains("SWEEPER") and not text.contains("WARDEN") and not text.contains("BUOY"),"unseen roles remain absent from the dossier")
 await android_back();check(game.screen=="menu","Android Back from dossier returns to Operations")
 await press(game,"archive");await press(game,"siren_dossier")
 await press(game,"siren_dossier_back");check(game.screen=="archive","dossier back button returns to Archive")
 text=texts(game)
 check(text.contains("FIELD LOG") and text.contains("Evidence recovered: Foundry furnace"),"field log lists recovered evidence by operation")
 check(button(game,"archive_evidence_0")!=null and button(game,"archive_evidence_0").size.y>=game.ui_touch_height,"evidence row is a touch button")
 await press(game,"archive_evidence_0");check(game.screen=="evidence","evidence row opens the existing gallery")
 await android_back();check(game.screen=="menu","Android Back returns from the gallery to Operations")
 await press(game,"archive");await press(game,"archive_tab_research")
 check(game.screen=="research","tab opens research")
 text=texts(game)
 for material in ["PRESSURE SPINDLE","TRACTION CORE","PRISM CORE","KEEPER WAFER","TRENCH SEAL CORE","CHOIR REED","DEEP KEEL PLATE","TRAWLER SCREW"]:
  check(text.contains(material),"research lists "+material)
 check(text.contains("PENDING") and text.contains("NOT RECOVERED") and text.contains("Cost: 2 ALLOY"),"research shows pending, not recovered and cost")
 var pay=button(game,"research_prism_core")
 check(pay!=null and not pay.disabled and pay.size.y>=game.ui_touch_height,"pending research offers a full-height pay button")
 var before=game.economy.stock.alloy
 await press(game,"research_prism_core")
 check(game.economy.stock.alloy==before-2 and "prism_core" in game.expedition.research.spent and "quietus_prism" in game.expedition.entitlements,"paying reuses the economy research action")
 check(button(game,"research_prism_core")==null and texts(game).contains("COMPLETE"),"paid research reads complete")
 await android_back();check(game.screen=="menu","Android Back returns from research")
 await press(game,"fittings");check(button(game,"archive")!=null,"Fittings offers the same entry")
 await press(game,"archive");check(game.screen=="archive","Fittings entry opens the archive view")
 await android_back();await android_back()
 # Voices: briefing radio, mid-dive message on the player's own progress, field log.
 game._briefing(0);await settle()
 if game.get_node_or_null("ArcCard")!=null:await press(game,"arc_continue")
 check(texts(game).contains("OKAFOR / BRANNOCK:") and Feed.received(game).has("0:brief"),"briefing shows the radio line and logs it")
 game._start_mission(0);game.screen="mission";game.sim.paused=true
 check(Feed.log_text(game,"msg")=="msg","no mid-dive message before any progress")
 game.sim.mission.objectives[0].captured=true
 check(Feed.log_text(game,"msg").contains("OKAFOR / BRANNOCK:") and Feed.received(game).has("0:mid"),"captured objective triggers the mid-dive message")
 game.sim.elapsed+=Feed.Table.HOLD+1.0
 check(Feed.log_text(game,"msg")=="msg","mid-dive message leaves the log row after its hold")
 var archived=game._archive()
 check(archived.get("voices",[]).has("0:mid") and load("res://src/persistence/save_checks.gd").valid(archived,"archive"),"received log is archived and passes the archive checks")
 Feed.clear(game);Feed.restore(game,archived)
 check(Feed.received(game).has("0:brief"),"received log restores")
 game._show_campaign();await settle();await press(game,"archive")
 check(texts(game).contains("OKAFOR / BRANNOCK:"),"field log lists received lines")
 await android_back()
 ArchiveTable.enabled=false;game._show_campaign();await settle()
 check(button(game,"archive")==null,"off switch removes the entry")
 ArchiveTable.enabled=true
 DirAccess.remove_absolute(game.store.path);DirAccess.remove_absolute(game.store.path+".bak")
 game.queue_free();await settle()
func run():
 for shape in [Vector2i(2520,1080),Vector2i(2184,1968)]:await shape_case(shape)
 print("ARCHIVE VIEWS UI CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
