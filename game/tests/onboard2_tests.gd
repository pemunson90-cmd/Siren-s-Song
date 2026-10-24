extends SceneTree
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 var path="res://src/campaign/onboarding2/briefing_rows.gd"
 check(ResourceLoader.exists(path),"later briefing data exists")
 if ResourceLoader.exists(path):
  var Rows=load(path)
  for id in range(3,30):
   var text=Rows.goal(id,"")
   check(text.begins_with("GOAL:") and "\nDANGER:" in text and "\nNEW THIS DIVE:" in text,"three concise factual rows "+str(id))
   check(text.length()<=300,"briefing facts stay bounded "+str(id))
  check(Rows.goal(2,"old")=="old" and Rows.goal(30,"pair")=="pair","outside rows retain existing briefings")
  Rows.enabled=false
  check(Rows.goal(6,"old")=="old","table switch restores existing text")
  Rows.enabled=true
 print("ONBOARD2 CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
