extends RefCounted
const STORIES={
 "silent_exodus":{"title":"UNHEARD","outcome":"Drill crews and divers out by craft. No surface ship came.","story":"Quietus carried the drill crews and divers out by craft, a few at a time. No surface ship came. The Sirens never registered Quietus, and it can keep diving."},
 "beacon_pact":{"title":"OPEN WATER","outcome":"The most people out, by surface ship on an open channel.","story":"A surface ship took the most people out on a broadcast channel. The Sirens heard it often enough to learn it: a known, unarmed voice. They leave Quietus alone."},
 "hidden_harbour":{"title":"STANDING DOWN","outcome":"The military survivors out quietly. Their weapons stay dark on the bottom.","story":"Quietus carried the military survivors out quietly. Their weapons stay dark on the bottom and the installations go silent for good. The Sirens never registered Quietus."},
 "surface_reckoning":{"title":"MARKED","outcome":"Everyone out by surface ship. The call went out from a military post.","story":"A surface ship took the most people out, but the channel came from a military post. The Sirens registered Quietus as a threat. Everyone is out, and Quietus can never dive near them again."}
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
  result.outcome="Kestrel's capsule reached the quiet lift point with the sailors alive."
  result.story=carrier+" set Kestrel's escape capsule down at the southeast lift point with the sailors still breathing inside. Quietus came home with their account and nothing broadcast behind it. Anyone else still down there, this dive did not see. "+progress.facts.get("witness_recovery","")
 var concealed=progress.get("facts",{}).get("concealed_consequence","")
 if id=="silent_exodus" and concealed=="deep_trace_severed":
  result.outcome="The trench mouth went quiet and Tessaly's bell started up."
  result.story=carrier_name(arrival)+" landed Kestrel's sonar operator alive. On her word Quietus hauled the old tracking float off the trench mouth and broke its surface trace. The bell began its slow lift. "+progress.facts.get("witness_recovery","")
 elif id=="hidden_harbour" and concealed in ["shelf_service","shelf_baffle"]:
  result.outcome="Port Ardent's six came out of the shore-end bunker."
  var mouth="The short service approach stays open: a direct route for the crew, and for sound." if concealed=="shelf_service" else "The north entrance is baffled. The crew take the longer lower turn through quieter water."
  result.story=carrier_name(arrival)+" landed Kestrel's sonar operator alive. She told Quietus how the bunker could be opened from the water. Quietus cleared the approach and cut the blast door; the cutter ran loud. "+mouth+" All six came out. "+progress.facts.get("witness_recovery","")
 var warning=progress.get("facts",{}).get("warning_arrival","")
 if id in ["beacon_pact","surface_reckoning"] and warning in ["exposed","sheltered"]:
  var passage="the sheltered service passage" if warning=="sheltered" else "the exposed eastern channel"
  var first="Brannock's launch reached the northeast pickup through "+passage+". Quietus came home after it heard the launch arrive. "
  if id=="beacon_pact":
   result.outcome="A launch on an open channel, and nothing fired on it."
   result.story=first+"Kestrel's sailors went up in the open, engines running, the call on loop. The Sirens heard it all and a patrol turned away."
  else:
   result.outcome="Everyone out. The water is closed to Quietus."
   result.story=first+"The call had gone out on a military post's channel. Brannock took every survivor aboard. The Sirens registered Quietus as a threat, and Quietus cannot dive near them again."
 return result

static func carrier_name(arrival:String)->String:return {"quietus":"QUIETUS","drone_a":"DRONE A","drone_b":"DRONE B"}.get(arrival,"The rescue craft")
