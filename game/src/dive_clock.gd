extends RefCounted
# [AI-DESIGNED] A8 step 1 (code audit, Pat approved 2026-11-12): the one place
# that moves a dive forward in time for a rendered frame. It used to live inside
# the accessibility pause aids (tactical_aids.gd), so an accessibility module
# owned the simulation's clock.
#
# What it does, unchanged: when an automatic pause aid is on, the frame is cut
# into single fixed steps and the aids look at the dive after each one, so a
# long frame cannot run past the moment the aid would have paused. Otherwise the
# whole frame is handed to the simulation, which steps it with its own
# accumulator, and the aids look once.
#
# The developer console, when installed (debug builds), stands between this
# clock and the simulation so it can scale or freeze time.
#
# aids: an object with begin_frame(), slices_steps() and observe()
# (presentation/accessibility/tactical_aids.gd).
const FRAME_CAP=0.25
static func advance(host,aids,dt:float)->void:
	aids.begin_frame()
	if not aids.slices_steps():
		_step(host,dt);aids.observe();return
	var remaining=minf(dt,FRAME_CAP)
	while remaining>0.0000001 and not host.sim.paused and host.sim.outcome.is_empty():
		var amount=minf(remaining,host.sim.STEP)
		_step(host,amount);aids.observe();remaining-=amount
static func _step(host,dt:float)->void:
	if host.get("debug_console")!=null:host.debug_console.advance(dt)
	else:host.sim.advance(dt)
