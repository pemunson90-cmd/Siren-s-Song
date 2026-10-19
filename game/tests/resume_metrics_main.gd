extends "res://src/main.gd"
var resume_snapshots: Array=[]
func _emit_ui_metrics(snapshot: Dictionary={}) -> void:
	resume_snapshots.append(snapshot.duplicate(true));super._emit_ui_metrics(snapshot)
