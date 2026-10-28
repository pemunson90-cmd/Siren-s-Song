extends RefCounted
# One order lookup; flags preserve the original shared finish hooks.
# Revert by inlining a family and removing its table rows.
const Weapons=preload("res://src/simulation/orders/weapon_orders.gd")
const Sensors=preload("res://src/simulation/orders/sensor_orders.gd")
const Route=preload("res://src/simulation/orders/route_orders.gd")
const Photo=preload("res://src/simulation/orders/photo_orders.gd")
const Features=preload("res://src/simulation/orders/feature_orders.gd")
const Tools=preload("res://src/simulation/orders/tool_orders.gd")
const TABLE = {
	"emp": [Weapons, true],
	"knock": [Weapons, true],
	"decoy": [Weapons, true],
	"sonobuoy": [Tools, true],
	"silt_screen": [Tools, true],
	"hull_patch": [Tools, false],
	"relay_buoy": [Tools, true],
	"ping": [Sensors, true],
	"recon": [Sensors, true],
	"select": [Route, true],
	"waypoint_mode": [Route, true],
	"queue": [Route, true],
	"route": [Route, true],
	"emergency": [Route, true],
	"route_edit": [Route, true],
	"route_insert": [Route, true],
	"route_delete": [Route, true],
	"route_undo": [Route, true],
	"order_undo": [Route, true],
	"hold": [Route, true],
	"contact_hold": [Route, true],
	"wait_drone": [Route, true],
	"silent": [Route, true],
	"drone_drive": [Route, true],
	"all_stop": [Route, false],
	"frame": [Photo, false],
	"camera": [Photo, true],
	"choir_action": [Features, false],
	"glass_action": [Features, false],
	"depth": [Features, false],
	"sonar_mode": [Features, false],
	"wake_playback": [Features, false],
	"shelf_warn": [Features, false],
	"shelf_alarm": [Features, false],
	"chain_power": [Features, false],
	"chain_route": [Features, false],
	"chain_send": [Features, false],
	"blackwater_handoff": [Features, false],
	"concealed_tow": [Features, false],
	"witness_land": [Features, false],
	"warning_gate": [Features, false],
	"warning_depart": [Features, false],
	"salvage": [Features, false],
	"rendezvous_release": [Features, false],
	"depart": [Features, false],
}
