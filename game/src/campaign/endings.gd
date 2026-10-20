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
 var result=STORIES[id].duplicate(true);result["id"]=id
 var arrival=progress.get("facts",{}).get("witness_arrival","")
 if id in ["silent_exodus","hidden_harbour"] and arrival in ["quietus","drone_a","drone_b"]:
  var carrier={"quietus":"QUIETUS","drone_a":"DRONE A","drone_b":"DRONE B"}[arrival]
  result.outcome="The living witness reaches the concealed harbour."
  result.story=carrier+" physically lands the occupied witness capsule in the southeast refuge. Quietus returns with the survivor's account, keeping the passage outside the fleet's targeting network. This witness has a safe harbour; the fate of other shelter craft remains beyond our observations. "+progress.facts.get("witness_recovery","")
 var concealed=progress.get("facts",{}).get("concealed_consequence","")
 if id=="silent_exodus" and concealed=="deep_trace_severed":
  result.outcome="The deep departure line gains a hidden crossing."
  result.story=carrier_name(arrival)+" lands the living navigator. Guided by the survivor’s account, Quietus removes the listening float from the departure mouth and physically severs its surface trace. The departure station reports its own line dark and opens its local shutter. The first deep crossing begins beyond that silent mouth; the berthing corrections Quietus recorded now lead unarmed hulls away from the fracture. Their destination belongs to the people aboard them. "+progress.facts.get("witness_recovery","")
 elif id=="hidden_harbour" and concealed in ["shelf_service","shelf_baffle"]:
  result.outcome="The pressure-shelter families gain a concealed harbour."
  var mouth="The short service approach stays open, a direct route for arrivals and for sound." if concealed=="shelf_service" else "The screen now shields the north entrance. Arriving families take the longer lower turn into quieter water."
  result.story=carrier_name(arrival)+" lands the living harbour keeper. The survivor reveals why the occupied pressure shelters cannot leave together. Quietus clears the collapsed screen from their receiving refuge; its watch acknowledges the open mouth and begins admitting families into the lit bays. "+mouth+" By the next watch, sleeping berths and warm-water nurseries share a crowded harbour beneath the industrial shelf. The hidden passage has become a place to live while the evacuation continues. "+progress.facts.get("witness_recovery","")
 var warning=progress.get("facts",{}).get("warning_arrival","")
 if id in ["beacon_pact","surface_reckoning"] and warning in ["exposed","sheltered"]:
  var passage="the sheltered service passage" if warning=="sheltered" else "the exposed eastern channel"
  var first="The warned recipient reaches the northern refuge through "+passage+". Quietus returns after receiving its arrival. "
  if id=="beacon_pact":
   result.outcome="A warned passage becomes the first public pact."
   result.story=first+"The deep-water witness account travels aboard the surviving launch. At the refuge, its crew and the human watch agree on a common channel: no firing on the departing unarmed hulls. The first escort sails beside the craft it was sent to hunt. A pact begins with that difficult crossing, and grows as each vessel answers."
  else:
   result.outcome="The shelf warning reaches the people who can act."
   result.story=first+"The launch carries the shelf shelters’ warning into the surface watch. Its crew marks the inhabited passages on the fleet’s charts; ships turn clear while shelter pilots bring their people through. By morning the industrial lights are dark and the refuge is crowded. The public crossing has exposed the corridor, and neither side can deny who lived beneath it."
 return result

static func carrier_name(arrival:String)->String:return {"quietus":"QUIETUS","drone_a":"DRONE A","drone_b":"DRONE B"}.get(arrival,"The rescue craft")
