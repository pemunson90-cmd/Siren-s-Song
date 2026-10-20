extends RefCounted
const STORIES={
 "silent_exodus":{"title":"SILENT EXODUS","outcome":"The evacuees escape hidden.","story":"Quietus returns with the deep-water witness account and keeps the concealed passage out of the fleet's targeting network. Below the surface, the departing vessels pass without pursuit. The last carrier fades into the trench; the refugees have a future beyond our charts."},
 "beacon_pact":{"title":"BEACON PACT","outcome":"The evacuees coordinate a public safe channel.","story":"The deep-water account gives the warning its meaning. Quietus broadcasts the agreed passage and the fleet holds its fire. Human escorts and Siren carriers share a channel through the fracture zone. Their first pact is practical: everyone gets out."},
 "hidden_harbour":{"title":"HIDDEN HARBOUR","outcome":"The shelters evacuate covertly.","story":"The shelf record identifies inhabited shelters beneath the industrial lights. Quietus carries their witness account home without exposing the service passage. Shelter craft slip through the hidden harbour while the surface fleet watches empty water. The people below survive without becoming targets."},
 "surface_reckoning":{"title":"SURFACE RECKONING","outcome":"The surface warning averts disaster, exposing the corridor.","story":"The shelf warning reaches the surface in time. Ships clear the fracture zone and the approaching disaster claims no fleet. The public transmission also reveals the evacuation corridor. Quietus has saved thousands, but the route can never be secret again; both sides must now answer for what follows."}
}
static func resolve(progress:Dictionary)->Dictionary:
 var thread=progress.get("selected_thread",progress.get("route",""))
 var done=progress.get("completed",[])
 var route=progress.get("facts",{}).get("confluence_route","")
 var id=""
 if route=="concealed" and 12 in done:id="silent_exodus" if thread=="deep" else "hidden_harbour" if thread=="shelf" else ""
 if route=="overt" and 13 in done:id="beacon_pact" if thread=="deep" else "surface_reckoning" if thread=="shelf" else ""
 if id.is_empty():return {}
 var result=STORIES[id].duplicate(true);result["id"]=id;return result
