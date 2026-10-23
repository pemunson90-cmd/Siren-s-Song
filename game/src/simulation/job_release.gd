extends RefCounted
# One release-on-unhold seam for orders and depth transitions.
# Feature adapters own their job storage; this module owns the shared HOLD guard.
# Revert by restoring each adapter's hold test and the original caller lists.
const ModuleRecovery=preload("res://src/simulation/module_recovery.gd")
const Glass=preload("res://src/simulation/glass_reach_work.gd")
const Choir=preload("res://src/simulation/industrial_jobs.gd")
const Delivery=preload("res://src/simulation/blackwater_delivery.gd")
const Witness=preload("res://src/simulation/witness_evacuation.gd")
const Chain=preload("res://src/simulation/warning_chain.gd")
const JOBS = [ModuleRecovery, Glass, Choir, Delivery, Witness]
# Retain the pre-existing depth-transition cancellation order as well.
const DEPTH_JOBS = [ModuleRecovery, Delivery, Witness, Glass, Choir]

static func cancel(sim, unit: int, order: String) -> void:
	if sim.units[unit].hold != "HOLD":
		for feature in DEPTH_JOBS if order == "depth" else JOBS:
			feature.release_if_unheld(sim, unit)
	# The plant also releases on route edits while HOLD remains set.
	Chain.cancel_released(sim, order)
