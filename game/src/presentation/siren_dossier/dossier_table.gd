extends RefCounted
# Player-facing Siren facts, limited to role rules already observable in play.
# This is a read-only presentation table; revert by removing this folder and its Archive entry.
const ROLES=[
	{"id":"patroller","name":"PATROLLER","does":"Walks an authored patrol and investigates detected sound or sight.","tell":"A patrol contact changes to INVESTIGATE after it detects a source.","counter":"Break clear sight with terrain; quiet movement or a decoy can redirect a sound search."},
	{"id":"sentinel","name":"SENTINEL · GUARD","does":"Hears a narrower area, remembers longer, and holds and turns at a reached search station.","tell":"A guard can approach a heard source, then turn in place while searching.","counter":"Use terrain to block sight; a fresh decoy can draw it away, but allow its longer attention to fade."},
	{"id":"hunter","name":"HUNTER","does":"Hears farther, sweeps around the last known source, and loses attention sooner.","tell":"Its fast response spreads into a local sweep after reaching the heard point.","counter":"Break clear sight, quiet the engines and leave the last noise behind while its shorter search fades."},
	{"id":"sweeper","name":"SWEEPER","does":"Listens for noise, investigates longer, and has no active sonar.","tell":"Its investigation can send a received directional bearing.","counter":"Quiet movement and cover reduce exposure; a decoy can draw its search away."},
	{"id":"buoy","name":"BUOY · LISTENER","does":"Listens for local acoustic activity and sends a report into the Siren network.","tell":"A received listener report marks network activity, not a live visual contact.","counter":"Disruption can interrupt it; changing depth can break an acoustic route."},
	{"id":"relay","name":"RELAY","does":"Forwards reports through connected Siren relays.","tell":"A received relay return signals network forwarding.","counter":"Disruption can interrupt it; changing depth can break an acoustic route."},
	{"id":"interceptor","name":"INTERCEPTOR","does":"Uses received evidence to commit to a fast burst along an announced line.","tell":"An audible burst windup warns before the committed pass.","counter":"Change depth or move behind cover during the warning; quiet travel limits fresh evidence."},
	{"id":"warden","name":"WARDEN","does":"Uses received evidence to charge a pressure attack at an announced point.","tell":"An audible charge cue precedes the pressure field.","counter":"Leave the announced area; cover or a depth change can break a clear attack path."}
]
const INTEL_PREFIX="siren_"
static func discovered(host)->Array:
	var seen=[]
	var cue=host.hud.get_node_or_null("FirstSirenCue") if host.get("hud")!=null else null
	if cue!=null and cue.tracker!=null:seen.append_array(cue.tracker.saved_types())
	for role in ROLES:
		var key=INTEL_PREFIX+role.id
		if host.photo_intel.has(key) and role.id not in seen:seen.append(role.id)
	var result=[]
	for role in ROLES:
		if role.id not in seen:continue
		var row=role.duplicate(true)
		var intel=host.photo_intel.get(INTEL_PREFIX+role.id,{})
		row["studied"]=intel is Dictionary and not intel.is_empty()
		row["quality"]=clampf(float(intel.get("q",0.0)),0.0,1.0) if row.studied else 0.0
		result.append(row)
	return result
