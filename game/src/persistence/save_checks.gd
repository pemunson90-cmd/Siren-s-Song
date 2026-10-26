extends RefCounted
# Feature save validators, in original short-circuit order and shape-guard phases.
# Seam: valid_snapshot calls valid(data, phase); add feature registrations here.
# Save shapes and rule values are unchanged. Revert by restoring the inline calls.
const HuntPressure=preload("res://src/simulation/hunt_pressure/hunt_pressure.gd")
const Shelf=preload("res://src/simulation/shelf_habitat.gd")
const Wake=preload("res://src/simulation/wake_crossing.gd")
const Operations=preload("res://src/simulation/resolution_operations.gd")
const Concealed=preload("res://src/simulation/concealed_harbour.gd")
const Witness=preload("res://src/simulation/witness_evacuation.gd")
const Recipient=preload("res://src/simulation/warning_recipient.gd")
const Correlator=preload("res://src/equipment/cadence_correlator.gd")
const Courier=preload("res://src/simulation/blackwater_courier.gd")
const Delivery=preload("res://src/simulation/blackwater_delivery.gd")
const Chain=preload("res://src/simulation/warning_chain.gd")
const Rendezvous=preload("res://src/simulation/rendezvous_transport.gd")
const Departure=preload("res://src/simulation/foundry_departure.gd")
const DroneOperations=preload("res://src/simulation/drone_operations.gd")
const ContactReports=preload("res://src/simulation/contact_reports.gd")
const Thermal=preload("res://src/simulation/thermal_front.gd")
const ModuleRecovery=preload("res://src/simulation/module_recovery.gd")
const Depth=preload("res://src/simulation/depth_bands.gd")
const Industry=preload("res://src/simulation/industrial_threats.gd")
const Choir=preload("res://src/simulation/industrial_jobs.gd")
const Glass=preload("res://src/simulation/glass_reach_work.gd")
const Network=preload("res://src/simulation/acoustic_network.gd")
const Sonar=preload("res://src/simulation/advanced_sonar.gd")
const Photo=preload("res://src/simulation/photo_capture.gd")
const ObservedStun=preload("res://src/simulation/observed_stun.gd")
const WorldRegion=preload("res://src/simulation/world_region.gd")

# phase, feature module, method, input shape
const save_checks = [
	["initial", HuntPressure, "valid", "mission_time"],
	["initial", Depth, "valid", "snapshot"],
	["initial", Sonar, "valid", "snapshot"],
	["initial", ModuleRecovery, "valid", "snapshot"],
	["initial", Operations, "valid", "mission_time"],
	["initial", Correlator, "valid_state", "correlation_time"],
	["features", ObservedStun, "valid", "snapshot"],
	["features", DroneOperations, "valid", "snapshot"],
	["features", Glass, "valid", "snapshot"],
	["features", Choir, "valid", "snapshot"],
	["features", Network, "valid", "snapshot"],
	["features", Industry, "valid", "snapshot"],
	["features", ContactReports, "valid", "snapshot"],
	["photo", Photo, "valid", "mission"],
	["world", WorldRegion, "valid", "snapshot"],
	["world", Witness, "valid", "snapshot"],
	["world", Concealed, "valid", "snapshot"],
	["world", Recipient, "valid", "snapshot"],
	["world", Delivery, "valid", "snapshot"],
	["world", Shelf, "valid", "snapshot"],
	["world", Wake, "valid", "snapshot"],
	["world", Chain, "valid", "snapshot"],
	["world", Rendezvous, "valid", "mission_time"],
	["transport", Departure, "valid", "mission_time"],
	["transport", Courier, "valid", "mission_time"],
	["transport", Thermal, "valid_mission", "mission"],
]

static func valid(data: Dictionary, phase: String) -> bool:
	for entry in save_checks:
		if entry[0] != phase:continue
		var subject = data
		if entry[3] in ["mission", "mission_time"]:subject = data.mission
		elif entry[3] == "correlation_time":subject = data.get("correlation", {})
		var accepted: bool
		if entry[3].ends_with("_time"):
			var time = data.get("elapsed", 0.0)
			accepted = entry[1].call(entry[2], subject, time if phase == "transport" else float(time))
		else:
			accepted = entry[1].call(entry[2], subject)
		if not accepted:return false
	return true
