extends SceneTree
const Ending=preload("res://src/campaign/endings.gd")
const Photo=preload("res://src/campaign/endings_photo.gd")
const Save2=preload("res://src/persistence/save_states/save2_controller.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func fixture(thread,channel)->Dictionary:
 return {"version":2,"route":thread,"routes":[thread],"selected_thread":thread,"completed":[6,7 if thread=="deep" else 8,9 if thread=="deep" else 10,11,12 if channel=="concealed" else 13],"facts":{thread:"Recovered branch account","confluence_route":channel},"history":[],"notes":{},"references":{},"entitlements":[]}
func _initialize():call_deferred("run")
func run():
 for thread in ["deep","shelf"]:
  for seed in ["concealed","overt"]:
   var p=fixture(thread,seed);var legacy=Ending.resolve(p)
   check(Ending.campaign_resolve(p).is_empty() and Ending.course_line(p).contains(legacy.title),"fork is provisional "+thread+seed)
   p.completed.append_array([14,15,16,17,18,19,22,23,24,25,30,31,32,33])
   check(Photo.resolve(p,{}).is_empty(),"op33 cannot offer a final wall")
   check(Photo.resolve(p,{},true,false).id==legacy.id,"expedition photo path keeps legacy resolution")
   p.completed.append(34)
   check(Ending.campaign_resolve(p)==legacy and Ending.course_line(p).is_empty(),"empty late record exactly preserves seed "+thread+seed)
   # Independent table: absent / concealed / overt for each of the three facts.
   for glass in ["","sever","service"]:
    for choir in ["","isolate","bypass"]:
     for plant in ["","dismantle","reconnect"]:
      var row=p.duplicate(true);row.facts.merge({"glass_choice":glass,"choir_choice":choir,"choir_plant":plant})
      var quiet=int(glass=="sever")+int(choir=="isolate")+int(plant=="dismantle")
      var open=int(glass=="service")+int(choir=="bypass")+int(plant=="reconnect")
      var channel="concealed" if quiet>=2 else "overt" if open>=2 else seed
      var expected={"deepconcealed":"silent_exodus","deepovert":"beacon_pact","shelfconcealed":"hidden_harbour","shelfovert":"surface_reckoning"}[thread+channel]
      var before=row.duplicate(true);var result=Ending.campaign_resolve(row)
      check(result.id==expected and row==before,"pure channel table "+str([thread,seed,glass,choir,plant]))
      var flip_line="What Quietus did at the Glass and the Choir was heard. The Sirens learned its voice." if channel=="overt" else "Quietus went quiet at the Glass and the Choir. The Sirens lost its voice."
      check(result.story.ends_with(flip_line) if channel!=seed else result.story==legacy.story,"plain directional cause line only on flip")
      for key in ["glass_choice","choir_choice","choir_plant","glass choice","choir choice","choir plant"]:
       check(not result.story.contains(key),"ending story keeps coded fact keys off screen: "+key)
      check(Ending.resolve(row).id==legacy.id,"expedition and historical fork remain unchanged")
   check(Ending.late_channel({"glass_choice":"unknown","choir_choice":"bypass"},seed)==seed,"unknown fact and single vote abstain")
 var game=load("res://scenes/main.tscn").instantiate();game.capture_scenario="runtime-test"
 root.add_child(game);game.set_process(false)
 game.store.path="user://088-old-ending.save"
 game.completed=[0,1,2,3,4,5];game.unlocked=5;game.active_started=false
 game.expedition=fixture("deep","concealed")
 game._show_campaign()
 check(not button(game,"ending") and labels(game).contains(Ending.course_line(game.expedition)),"Operations offers only provisional line")
 game.CampaignFlow.show_ending(game,false)
 check(labels(game).contains("PROVISIONAL FORK / UNHEARD") and button(game,"save2_forks")!=null,"explicit fork outcome and replay button are truthful")
 game._show_ending()
 check(game.screen=="menu" and button(game,"ending")==null,"normal ending request cannot show provisional outcome as final")
 var provisional_archive=game._archive();provisional_archive.erase("active")
 check(game.store.save(provisional_archive),"old provisional save writes without new fields")
 game.expedition={};game._load_archive();game._show_campaign()
 check(button(game,"ending")==null and labels(game).contains("Course so far: UNHEARD (provisional)."),"old provisional save reloads without final access")
 game.expedition.completed.append_array([14,15,16,17,18,19,22,23,24,25,30,31,32,33,34])
 game.expedition.facts.merge({"glass_choice":"service","choir_choice":"bypass","witness_arrival":"quietus"})
 game.expedition.ending="silent_exodus" # Existing save field may contain the old seed.
 var archive=game._archive();archive.erase("active")
 check(game.store.valid(archive) and game.store.save(archive),"old completed save needs no new fields")
 game.expedition={};game._load_archive();game._show_campaign()
 check(Ending.campaign_resolve(game.expedition).id=="beacon_pact" and button(game,"ending")!=null,"old op34 save recomputes final family on load")
 game.CampaignFlow.show_ending(game,false)
 check(labels(game).contains("CAMPAIGN OUTCOME") and labels(game).contains("What Quietus did at the Glass and the Choir was heard. The Sirens learned its voice."),"final outcome story visibly explains the flip")
 var flipped=game.expedition.duplicate(true);flipped.facts.warning_arrival="sheltered"
 check(Ending.campaign_resolve(flipped).story.contains("sheltered service passage"),"resulting overt family keeps arrival variant")
 flipped.facts.confluence_route="overt";flipped.completed.erase(12);flipped.completed.append(13)
 flipped.facts.glass_choice="sever";flipped.facts.choir_choice="isolate";flipped.facts.concealed_consequence="deep_trace_severed"
 check(Ending.campaign_resolve(flipped).story.contains("tracking float"),"resulting concealed family keeps consequence variant")
 game._start_mission(12);game.sim.outcome="won";game._debrief()
 check(game.screen=="photo_ending","post34 fork replay retains the final campaign photo path")
 game.queue_free();await process_frame
 for suffix in ["",".bak",".tmp"]:DirAccess.remove_absolute("user://088-old-ending.save"+suffix)
 print("LATE ENDING CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
func button(game,id):
 for node in game.find_children("*","Button",true,false):
  if node.get_meta("action","")==id:return node
 return null
func labels(game)->String:
 return "\n".join(game.panel_box.find_children("*","Label",true,false).map(func(node):return node.text))
