extends SceneTree
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
const Consequences=preload("res://src/campaign/campaign_consequences.gd")
const Chart=preload("res://src/simulation/terrain_chart.gd")
var checks=0
var failures=0
func check(ok,label):
 checks+=1
 if not ok:failures+=1;printerr("FAIL ",label)
func _initialize():
 var old=Consequences.upgrade({"version":1,"route":"deep","routes":["deep"],"facts":{"deep":"carrier"},"completed":[6,7]})
 var chart=Chart.new();var m={"id":14,"terrain_chart_revision":1,"chart_geometry_revision":1,"world_size":Vector2(2400,3000),"launch_seed":Rect2(80,2400,520,520),"delivery_revision":1,"recovered":false}
 chart.configure(m,[]);m.terrain_chart_note=chart.snapshot()
 var notes=Campaign.recover(old,m)
 check(notes.has("terrain_notes") and notes.terrain_notes.get("14")==m.terrain_chart_note,"failed passage retains one geometry-qualified chart note")
 check(notes.completed==old.completed and notes.entitlements==old.entitlements and notes.history==old.history,"chart memory grants no completion capability or history")
 check(Campaign.valid(notes),"optional bounded terrain note saves through existing campaign schema")
 check(Consequences.context(notes).get("terrain_notes",{})==notes.get("terrain_notes"),"next launch carries retained bathymetry independently of recovered facts")
 check(not old.has("terrain_notes") and not Consequences.context(old).has("terrain_notes"),"old progress/context optional shape stays exact")
 var bad=notes.duplicate(true);bad.terrain_notes["13"]=bad.terrain_notes["14"]
 check(not Campaign.valid(bad),"one-region notes cannot expand into arbitrary global atlas")
 check(14 not in Campaign.available([0,1,2,3,4,5],notes),"new journey stays gated until coherent actual view and play review")
 print("TERRAIN CHART CAMPAIGN CHECKS ",checks," FAILURES ",failures);quit(1 if failures else 0)
