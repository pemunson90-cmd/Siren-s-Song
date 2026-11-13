extends RefCounted
# [AI-DESIGNED] A7 (code audit, Pat approved 2026-11-12)
# Shared host-freeze and host-restore steps for the Career, Expedition and Challenge sessions.
# A session hides the campaign Main, stops its sound and processing, and gives all of it back on leave.
# The session keeps prior_mode, prior_visibility, prior_sound_suspended, campaign_host and return_to_list.
static func freeze(session)->void:
	var host=session.campaign_host
	session.prior_mode=host.process_mode;session.prior_sound_suspended=host.sound.system_suspended
	for child in host.get_children():
		if child is CanvasItem:session.prior_visibility.append({"node":child,"visible":child.visible});child.hide()
	host.sound.suspend();host.process_mode=Node.PROCESS_MODE_DISABLED
static func leave(session)->void:
	for item in session.prior_visibility:
		if is_instance_valid(item.node):item.node.visible=item.visible
	session.campaign_host.process_mode=session.prior_mode
	if not session.prior_sound_suspended:session.campaign_host.sound.resume()
	session.get_parent().remove_child(session)
	if session.return_to_list.is_valid():session.return_to_list.call()
	session.queue_free()
