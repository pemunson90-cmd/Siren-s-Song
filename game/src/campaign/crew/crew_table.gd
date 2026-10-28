extends RefCounted
# BRANNOCK CREW data (handoff 082). AI-DESIGNED placeholders, Pat to rewrite and tune; no new plot.
# Seam: crew.gd reads every row and number here. Revert: enabled=false removes every effect and line.
# Each row is one rescued group read from a fact the campaign already saves (expedition facts).
# when: {"fact": key, "is": [values]}. Missing facts never match, so a campaign that rescued nobody is unchanged.
# kind: mark (a chart mark on op, grant only), credit (one-time supply credit when the fact is first
# recorded), line (a short briefing line on op). Every effect is a grant and is never required.
# speaker: key in voices_table SPEAKERS. Groups without a recurring character are relayed by okafor.
# Not covered yet: tessaly_divers, hollins_last_shift, varne_staff are named in the ledger but no
# operation saves them, so they have no row until a fact exists to read.
static var enabled=true
const HEAD="BRANNOCK CREW"
const FOOTER="AI-DESIGNED placeholder crew, Pat to rewrite. Grants only; none is required."
const MAX_CREDIT=4
const ROWS=[
 {"id":"kestrel_sailors","name":"Kestrel sailors","when":{"fact":"witness_arrival","is":["quietus","drone_a","drone_b"]},
  "kind":"mark","op":15,"speaker":"okafor",
  "mark":{"kind":"person","text":"KESTREL CREW LANE · the Kestrel sailors ran this strait; their line is charted","pos":[1000.0,2100.0]},
  "line":"The Kestrel sailors you landed have charted a lane through the strait.",
  "roster":"charted a lane on the Needle Strait chart."},
 {"id":"kestrel_launch","name":"Kestrel launch crew","when":{"fact":"warning_arrival","is":["exposed","sheltered"]},
  "kind":"credit","credit":{"cells":2},"speaker":"okafor",
  "line":"The launch crew left spare cells aboard Brannock.",
  "roster":"left spare cells aboard."},
 {"id":"port_ardent_watch","name":"Port Ardent watch","when":{"fact":"concealed_consequence","is":["shelf_service","shelf_baffle"]},
  "kind":"line","op":19,"speaker":"okafor",
  "line":"Port Ardent watch is logging the shelf for us. Listen before you move.",
  "roster":"log the shelf for Brannock."},
 {"id":"hollins_workers","name":"Hollins workers","when":{"fact":"choir_people","is":["landed"]},
  "kind":"credit","credit":{"scrap":3},"speaker":"rill",
  "line":"Rill's people sent salvage up from the service berth.",
  "roster":"sent salvage up from the service berth."}
]
