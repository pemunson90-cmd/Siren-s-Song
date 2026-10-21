extends RefCounted
const STORIES={
 "silent_exodus":{"title":"UNHEARD","outcome":"Drill crews and divers out by craft. No surface ship came.","story":"Quietus brought them up the trench a few at a time, pumps throttled, under the layer. Okafor counted each one aboard Brannock out loud. On the trench floor the patrols kept their circuits. None of them turned toward Quietus."},
 "beacon_pact":{"title":"OPEN WATER","outcome":"The most people out, by surface ship on an open channel.","story":"Brannock came in on the broadcast channel and lifted everyone Quietus had found. The Sirens heard all of it: the call, the engines, the winches. They came close, listened, and left. On the next dive a patrol passed Quietus at two hundred meters and kept going."},
 "hidden_harbour":{"title":"STANDING DOWN","outcome":"The military survivors out quietly. Their weapons stay dark on the bottom.","story":"Quietus carried Port Ardent's watch crew and Kestrel's sailors out without one active ping. The station's test array is cold and Kestrel's tubes are shut. On the shelf the patrols kept their circuits. None of them turned toward Quietus."},
 "surface_reckoning":{"title":"MARKED","outcome":"Everyone out by surface ship. The call went out from a military post.","story":"Port Ardent's mast put the call out and Brannock came straight in. Every survivor Quietus had found went up the ladder. Then the Sirens came to the mast, and then to every place Quietus had held station. Okafor pulled it out with eleven minutes of air. Quietus cannot dive near them again."}
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
  result.story=carrier_name(arrival)+" landed Kestrel's sonar operator alive. On her word Quietus hauled the Siren pickup off the trench mouth and broke its surface trace. Kade came on the bell channel: \"It's gone quiet. We're starting the slow lift.\" Okafor counted four voices. "+progress.facts.get("witness_recovery","")
 elif id=="hidden_harbour" and concealed in ["shelf_service","shelf_baffle"]:
  result.outcome="Port Ardent's watch crew reached their seabed lock."
  var mouth="The short service approach stays open: a direct route for the crew, and for sound." if concealed=="shelf_service" else "The screen now baffles the north entrance. The crew take the longer lower turn through quieter water."
  result.story=carrier_name(arrival)+" landed Kestrel's sonar operator alive. She knew why Port Ardent's crew could not reach their lock: the collapsed screen across its mouth. Quietus cleared it and the lock watch started bringing people down. "+mouth+" By the next watch all six were in the lock and the station above them was dark. "+progress.facts.get("witness_recovery","")
 var warning=progress.get("facts",{}).get("warning_arrival","")
 if id in ["beacon_pact","surface_reckoning"] and warning in ["exposed","sheltered"]:
  var passage="the sheltered service passage" if warning=="sheltered" else "the exposed eastern channel"
  var first="Brannock's launch reached the northeast pickup through "+passage+". Quietus came home after it heard the launch arrive. "
  if id=="beacon_pact":
   result.outcome="A launch on an open channel, and nothing fired on it."
   result.story=first+"Kestrel's sailors went up Brannock's ladder in the open, engines running, the call on loop. A Siren patrol came within sight of the launch, held there a long minute, and turned away. The next morning Okafor sent Quietus down again. Nothing followed it."
  else:
   result.outcome="Everyone out. The water is closed to Quietus."
   result.story=first+"The call had gone out on Port Ardent's military band. Brannock took every survivor aboard and ran. Behind it the Sirens came to the mast, then to every place Quietus had held station that week. Okafor pulled Quietus up with the hatch still wet and did not send it back."
 return result

static func carrier_name(arrival:String)->String:return {"quietus":"QUIETUS","drone_a":"DRONE A","drone_b":"DRONE B"}.get(arrival,"The rescue craft")
