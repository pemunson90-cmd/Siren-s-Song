extends RefCounted
# [AI-DESIGNED] A7 (code audit, Pat approved 2026-11-12)
# Shared launch of a mode session (Career, Expedition, Challenge) on top of the campaign host.
# Fields are applied in the dictionary's order, after campaign_host, so each mode keeps its own order.
static func launch(front,script,node_name:String,fields:Dictionary)->void:
	var session=load("res://scenes/main.tscn").instantiate()
	session.set_script(script);session.name=node_name
	session.campaign_host=front.host
	for key in fields:session.set(key,fields[key])
	session.process_mode=Node.PROCESS_MODE_ALWAYS;session.freeze_campaign();front.host.add_child(session)
