extends SceneTree
const Ledger=preload("res://src/campaign/ledger/ledger.gd")
const Endings=preload("res://src/campaign/endings.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func text(p)->String:
 var lines=[]
 for panel in Ledger.build(p,{}):lines.append_array(panel.rows)
 return "\n".join(lines)
func _initialize():
 for thread in ["deep","shelf"]:
  for channel in ["concealed","overt"]:
   var p={"selected_thread":thread,"completed":[11,12 if channel=="concealed" else 13,30,31,32,33,34],"facts":{"confluence_route":channel}}
   var before=p.duplicate(true);var ending=Endings.campaign_resolve(p)
   var lines=text(p)
   check(lines.contains("FINAL ACCOUNT / "+ending.title),"authored closure for "+ending.id)
   check(lines.contains("Sorley's boy was not brought home"),"real omission retained "+ending.id)
   check(not lines.contains("Calder evidence:"),"completion alone never invents recovered evidence")
   check(p==before and Endings.campaign_resolve(p)==ending,"closure preserves saved state and ending "+ending.id)
   p.completed.erase(34)
   check(not text(p).contains("FINAL ACCOUNT"),"no final closure before terminal recovery")
 var p={"completed":[32,33,34],"facts":{"glass_record_34":"recovered bore photograph"}}
 check(text(p).contains("Beneath evidence:") and not text(p).contains("Comparison:"),"single recovered record gets only its own interpretation")
 p.facts.glass_record_32="recovered breach photograph"
 check(text(p).contains("Comparison: Calder and Beneath"),"two recovered bore records support comparison")
 p.facts.glass_record_33="recovered gallery photograph"
 check(text(p).contains("Gallery evidence:") and text(p).contains("Comparison: Gallery and Beneath"),"occupied gallery changes reading of bore evidence")
 p.facts.glass_record_33=""
 check(not text(p).contains("Gallery evidence:") and not text(p).contains("Comparison: Gallery and Beneath"),"empty record is no evidence")
 for id in [32,33,34]:
  var m=preload("res://src/campaign/missions.gd").make(id)
  check(m.objectives[0].evidence.length()<=170,"short interpretation op "+str(id))
 var divergence=preload("res://src/campaign/missions.gd").make(6)
 check(divergence.record.contains("Each recovered carrier fix") and not divergence.record.contains("route to each"),"Divergence result is conditional on recovered carrier fixes")
 var shelf=preload("res://src/campaign/resolution_missions.gd").make(12,{"thread":"shelf"})
 check(shelf.brief.contains("no separate CUT order") and shelf.brief.contains("On Quietus use ATTACH TOW") and shelf.brief.contains("SEAT HERE"),"shelf pre-action prose names actual owner and tow/placement controls")
 var ending=Endings.resolve({"selected_thread":"shelf","completed":[11,12],"facts":{"confluence_route":"concealed","concealed_consequence":"shelf_baffle"}})
 check(ending.story.contains("towed and placed") and not ending.story.contains("cut the blast door"),"Standing Down result matches environmental actions")
 for malformed in [{"facts":"bad","completed":[34]},{"facts":{},"completed":3}]:
  check(not text(malformed).contains("FINAL ACCOUNT"),"malformed legacy containers never enter ending resolution")
 var switched={"selected_thread":"deep","completed":[11,12,30,31,34],"facts":{"confluence_route":"concealed","glass_choice":"service","choir_choice":"bypass"}}
 check(text(switched).contains("FINAL ACCOUNT / OPEN WATER") and not text(switched).contains("launch reached"),"late votes select closure without inventing an original overt launch")
 print("AUTHORED CLOSURE CHECKS %d FAILURES %d"%[checks,failures]);quit(1 if failures else 0)
