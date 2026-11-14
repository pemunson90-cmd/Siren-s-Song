extends RefCounted
# What happened on the dive, in the Expedition debrief's words: the cause of a loss, the dive
# time, hull and life support at the end, and the damage the boat carries on.
# Only shown for the dive just finished: a result restored after a reload has no dive to read.
# Presentation only. Revert: remove the call in CareerSession._result_menu and this file.
const LossSummary=preload("res://src/presentation/loss_summary.gd")
const CauseLog=preload("res://src/presentation/death_cause/cause_log.gd")
const DamageLog=preload("res://src/presentation/damage_log/damage_log.gd")
const Flow=preload("res://src/presentation/flow/campaign_flow.gd")
const ABANDONED="You gave up the contract before the dive ended."
static func show(host,abandoned:bool)->void:
	var sim=host.sim
	if abandoned:host._menu_text(ABANDONED,17)
	else:
		var cause=LossSummary.line(sim)
		# The cause comes from what happened, not from sim.message: a rider's failure replaces that message.
		if not cause.is_empty():host._menu_text(cause,17)
	host._menu_text(Flow.stats_line(sim),17)
	if not abandoned:CauseLog.debrief(host)
	DamageLog.debrief(host)
