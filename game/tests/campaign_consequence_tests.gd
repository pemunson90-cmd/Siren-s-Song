extends SceneTree
const Campaign=preload("res://src/campaign/expedition_campaign.gd")
const Consequences=preload("res://src/campaign/campaign_consequences.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
 checks+=1
 if not ok:failures+=1;print("FAIL ",label)
func _initialize():
 var legacy={"version":1,"route":"deep","routes":["deep"],"facts":{"deep":"carrier"},"completed":[6,7]}
 check(Campaign.valid(legacy),"legacy expedition remains valid")
 var migrated=Consequences.upgrade(legacy)
 check(migrated.entitlements.is_empty() and migrated.references.is_empty(),"old completion never fabricates equipment or measured reference")
 var failed={"id":7,"consequence_revision":1,"expedition_revision":1,"recovered":false,"expedition_facts":{"rendezvous":"note"},"measured_reference":[0.8,1.6,0.8]}
 var notes=Consequences.retain(migrated,failed)
 check(notes.notes.has("rendezvous") and notes.entitlements.is_empty(),"failed field notes retain observation without reward")
 var recovered=failed.duplicate(true);recovered.recovered=true
 var earned=Campaign.recover(notes,recovered)
 check("quietus_correlator" in earned.entitlements and earned.references.return_cadence==[0.8,1.6,0.8],"successful confirmed recovery earns measured kit")
 check(9 in Campaign.available([0,1,2,3,4,5],earned),"Deep recovery opens actual onward task")
 var launched=Consequences.commit(earned,9,{"quietus":"quietus_correlator","drone_a":"","drone_b":""})
 check(launched.selected_thread=="deep" and launched.history.size()==1,"recovery commits one selected downstream history")
 var opposite={"id":6,"expedition_revision":1,"recovered":true,"chosen_route":"shelf","expedition_facts":{"shelf":"other"}}
 var replayed=Campaign.recover(launched,opposite)
 check(replayed.selected_thread=="deep" and replayed.history==launched.history and "shelf" in replayed.routes,"opposite replay adds access without rewriting selected history")
 var confluence={"id":11,"expedition_revision":2,"recovered":true,"chosen_route":"concealed","expedition_facts":{}}
 var selected=Campaign.recover(replayed,confluence)
 confluence.chosen_route="overt"
 check(Campaign.recover(selected,confluence).facts.confluence_route=="concealed","replayed later exit cannot rewrite committed consequence")
 var corrupt=launched.duplicate(true);corrupt.history[0].mission=99
 check(not Campaign.valid(corrupt),"bounded history rejects unknown mission")
 print("CAMPAIGN CONSEQUENCES ",checks," FAILURES ",failures)
 quit(1 if failures else 0)
