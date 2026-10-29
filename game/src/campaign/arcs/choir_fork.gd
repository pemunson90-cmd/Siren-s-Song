extends RefCounted
# Arc 5 recovery approach follows the already recovered Confluence route.
# Revert by removing this application from Iron Choir construction.
const OVERT_POSITIONS={23:Vector2(2750,300),24:Vector2(2750,500)}

static func apply(m:Dictionary,history:Dictionary)->void:
	if m.get("id",-1) not in OVERT_POSITIONS:return
	var facts=history.get("facts",{})
	if not facts is Dictionary or facts.get("confluence_route","")!="overt":return
	var pos:Vector2=OVERT_POSITIONS[m.id]
	m.corridors=[{"pos":pos,"name":"CHOIR NORTH RECOVERY","route":"deep"}]
	m.brief=m.brief.replace("The south recovery mouth stays available after the job.","The north recovery mouth follows the open warning passage recorded at Confluence.")
