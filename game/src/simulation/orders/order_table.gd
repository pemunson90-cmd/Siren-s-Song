extends RefCounted
# One order lookup; flags preserve the original shared finish hooks.
# Revert by inlining a family and removing its table rows.
const Weapons=preload("res://src/simulation/orders/weapon_orders.gd")
const Sensors=preload("res://src/simulation/orders/sensor_orders.gd")
const Route=preload("res://src/simulation/orders/route_orders.gd")
const TABLE = {
	"emp": [Weapons, true],
	"knock": [Weapons, true],
	"decoy": [Weapons, true],
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
}
