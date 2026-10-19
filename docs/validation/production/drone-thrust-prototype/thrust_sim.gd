extends "res://src/simulation/simulation.gd"
# Experimental requested propulsion only. No product fields/UI/save changes.
var drone_thrust: float=96.0
func _move(u:Dictionary,dt:float,speed:float,holding:bool,report_collision:bool=true,player_craft:bool=false)->void:
	if player_craft and u.name in ["DRONE A","DRONE B"]:
		speed=drone_thrust
	super._move(u,dt,speed,holding,report_collision,player_craft)
