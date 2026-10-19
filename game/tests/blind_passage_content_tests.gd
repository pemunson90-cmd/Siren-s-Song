extends SceneTree
const MODULE="res://src/campaign/blind_passage_mission.gd"
var checks=0
var failures=0
func check(ok:bool,label:String)->void:
 checks+=1
 if not ok:failures+=1;printerr("FAIL: ",label)
func _initialize()->void:
 check(ResourceLoader.exists(MODULE),"connected Blind Passage content exists")
 if failures:finish();return
 var content=load(MODULE)
 check(not content.can_launch({}),"an unearned operation cannot launch carried-evidence delivery")
 check(not content.can_launch({"notes":{"resolution":"concealed_recovery"},"completed":[11]}),"retained notes cannot fabricate recovered evidence")
 var concealed={"thread":"deep","completed":[6,7,9,11,12],"facts":{"confluence_route":"concealed","resolution":"concealed_recovery"},"references":{}}
 var overt={"thread":"shelf","completed":[6,8,10,11,13],"facts":{"confluence_route":"overt","resolution":"overt_warning"},"references":{}}
 check(content.can_launch(concealed) and content.can_launch(overt),"either recovered resolution opens the same onward region without requiring both")
 check(content.carried_evidence(concealed)=="concealed_recovery" and content.carried_evidence(overt)=="overt_warning","actual prior evidence remains distinct across the rejoin")
 var mismatch=concealed.duplicate(true);mismatch.facts.resolution="overt_warning"
 check(not content.can_launch(mismatch),"mismatched recovery fact cannot become a different packet")
 mismatch=concealed.duplicate(true);mismatch.facts.confluence_route="overt"
 check(not content.can_launch(mismatch),"replayed route metadata cannot rewrite the recovered resolution")
 var before=concealed.duplicate(true);concealed["notes"]={"unrecovered":"unknown shoal"}
 var m=content.make(14,concealed)
 check(m.id==14 and content.make(99,concealed).is_empty(),"new content owns only assigned14")
 check(m.delivery_revision==1 and m.terrain_chart_revision==1 and m.chart_geometry_revision==1 and m.region_revision==1,"delivery and earned chart behavior are explicitly opt-in")
 check(not m.has("expedition_revision") and m.objectives.is_empty() and m.required_site_ids.is_empty(),"carried delivery adds no receiver or hold chain")
 check(not m.handoff_complete and not m.recovered and not content.delivery_ready(m),"empty objective list does not grant handoff readiness")
 check(m.launch_context==before and concealed.has("notes"),"launch copies committed history without notes or input mutation")
 check(m.extraction==m.withdrawal_pos and m.extraction==m.start and m.handoff_pos.distance_to(m.start)>2400,"far physical handoff is followed by a real return")
 check(m.launch_seed.encloses(Rect2(m.start-Vector2.ONE*24,Vector2.ONE*48)),"launch chart contains the submarine footprint")
 check(m.handoff_sector.has_point(m.handoff_pos) and not m.launch_seed.intersects(m.handoff_sector),"announced handoff coordinates are separate from the charted launch seed")
 check(not m.has("known") and not m.has("terrain_chart") and not m.has("revealed_rocks"),"content does not prefill hidden topology or a complete surveyed chart")
 check(m.sirens.all(func(s):return s.mode=="PATROL" and s.target==-1 and s.lock==0),"patrols begin without knowledge of the pilot")
 m.handoff_complete=true
 check(content.delivery_ready(m),"model-earned handoff flag allows returning the actual carried evidence")
 m.carried_evidence="overt_warning"
 check(not content.delivery_ready(m),"handoff cannot switch the carried packet after launch")
 m=content.make(14,{})
 m.handoff_complete=true
 check(not content.delivery_ready(m),"a fabricated handoff flag without recovered evidence grants nothing")
 var revisiting=before.duplicate(true);revisiting.terrain_notes={"14":{"geometry_revision":1,"clear_cells":[Vector2i(5,65)]}}
 check(content.make(14,revisiting).launch_context.terrain_notes==revisiting.terrain_notes,"optional retained chart note reaches the model without becoming new completion")
 finish()
func finish()->void:
 print("BLIND PASSAGE CONTENT CHECKS ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
