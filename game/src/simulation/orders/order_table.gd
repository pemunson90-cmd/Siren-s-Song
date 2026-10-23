extends RefCounted
# One order lookup; flags preserve the original shared finish hooks.
# Revert by inlining a family and removing its table rows.
const Weapons=preload("res://src/simulation/orders/weapon_orders.gd")
const Sensors=preload("res://src/simulation/orders/sensor_orders.gd")
const TABLE = {
	"emp": [Weapons, true],
	"knock": [Weapons, true],
	"decoy": [Weapons, true],
	"ping": [Sensors, true],
	"recon": [Sensors, true],
}
