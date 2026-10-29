extends "res://src/presentation/quality/redraw_gate.gd"
# QUALITY, draw-only. Revert by dropping callers. Never applies a tier or FPS cap.
# QualityRuntime supplies active rendered wall intervals and explicit settings consent.
# Main and OceanView keep input live while gating periodic paused/idle refreshes.
var _samples:Array[float]=[]
var _sample_seconds:=0.0
var _over_budget_seconds:=0.0
var _pending:=false
var _dismissed:=false
func _init(headless:bool=DisplayServer.get_name()=="headless")->void:
	super(headless)
# Call once per rendered frame, using wall time (not simulation delta / time scale).
# eligible=false for loading, background, menus and intentional idle throttling.
# Returns true only on the transition to a visible suggestion.
func observe_frame(seconds:float,tier:Variant=Table.STANDARD,eligible:bool=true)->bool:
	if _headless or _dismissed:return false
	if Table.normalize(tier)!=Table.STANDARD:
		_reset_measurement();_pending=false;return false
	if not eligible:
		_reset_measurement();return false
	if not is_finite(seconds) or seconds<=0.0:return false
	_samples.append(seconds);_sample_seconds+=seconds
	while _samples.size()>1 and _sample_seconds-_samples[0]>=Table.ROLLING_SECONDS:
		_sample_seconds-=_samples.pop_front()
	if _sample_seconds<Table.ROLLING_SECONDS:return false
	if average_frame_seconds()>Table.FRAME_BUDGET_SECONDS:
		_over_budget_seconds+=seconds
	else:
		_over_budget_seconds=0.0
	if not _pending and _over_budget_seconds+0.000001>=Table.SUGGEST_AFTER_SECONDS:
		_pending=true;return true
	return false
func average_frame_seconds()->float:
	return _sample_seconds/_samples.size() if not _samples.is_empty() else 0.0
func suggestion()->Dictionary:
	if not _pending or _headless or _dismissed:return {}
	return {"tier":Table.LOW_EFFECTS,"text":"LOW EFFECTS may improve frame rate.","average_frame_seconds":average_frame_seconds()}
func dismiss()->void:
	_dismissed=true;_pending=false;_reset_measurement()
func _reset_measurement()->void:
	_samples.clear();_sample_seconds=0.0;_over_budget_seconds=0.0
