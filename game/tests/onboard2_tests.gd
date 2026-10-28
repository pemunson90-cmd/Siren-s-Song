extends SceneTree
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 var path="res://src/campaign/onboarding2/briefing_rows.gd"
 check(ResourceLoader.exists(path),"later briefing data exists")
 var Rows=load(path)
 if ResourceLoader.exists(path):
  for id in range(3,41):
   var text=Rows.goal(id,"")
   check(text.begins_with("GOAL:") and "\nDANGER:" in text and "\nNEW THIS DIVE:" in text,"three concise factual rows "+str(id))
   check(text.length()<=300,"briefing facts stay bounded "+str(id))
  check(Rows.goal(2,"old")=="old" and Rows.goal(41,"later")=="later","outside rows retain existing briefings")
  Rows.enabled=false
  check(Rows.goal(6,"old")=="old","table switch restores existing text")
  Rows.enabled=true
 var Text=preload("res://src/campaign/onboarding_text.gd")
 var Store=preload("res://src/persistence/save_store.gd")
 var Help=preload("res://src/presentation/tool_help/tool_help.gd")
 for id in range(0,41):
  check(not Rows.goal(id,Text.goal(id)).is_empty(),"compact teaching covers operation "+str(id))
 var ids=Text.HINTS.keys()
 var archive={"version":2,"unlocked":0,"completed":[],"settings":{},"upgrade":"endurance","hints_seen":ids}
 check(Text.valid_seen(ids) and Store.new().valid(archive),"all opening and first-use ids load together")
 var store=Store.new();store.path="user://late-teaching-roundtrip.save"
 check(store.save(archive),"archive with all hint ids saves")
 var decoded=store.load_game()
 check(store.valid(decoded) and decoded.get("hints_seen")==ids,"hint ids survive real archive round trip")
 for id in ids:check(Text.valid_seen([id]),"known hint id validates "+id)
 check(not Text.valid_seen(["first_unknown"]) and not Text.valid_seen(["priced_unknown"]),"unknown ids including priced prefix rejected")
 check(not Text.valid_seen(["move","move"]) and not Text.valid_seen([4]),"duplicate and non-string hint ids rejected")
 var oversized=ids.duplicate();oversized.append("first_depth")
 check(not Text.valid_seen(oversized),"hint list size stays bounded")
 for id in ["sonobuoy","silt_screen","hull_patch","relay_buoy"]:
  check(Help.TEXT.has(id) and Help.TEXT[id].length()<180,"new tool has bounded hold help "+id)
 print("ONBOARD2 CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
