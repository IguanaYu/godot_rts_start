class_name BonusObjectiveSpeedRun
extends BonusObjective

@export var time_limit: float = 180.0  # 秒

var _start_time: float = 0.0
var _is_failed := false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_start_time = Time.get_ticks_msec() / 1000.0

func check() -> bool:
	if is_completed or _is_failed:
		return is_completed

	var elapsed := Time.get_ticks_msec() / 1000.0 - _start_time
	if elapsed <= time_limit:
		_grant_reward()
		return true
	else:
		_is_failed = true
		return false

func get_objective_text() -> Dictionary:
	var elapsed := Time.get_ticks_msec() / 1000.0 - _start_time
	var remaining := maxi(0, time_limit - elapsed)
	return {
		"text": tr(description_key) + " (%ds)" % remaining,
		"completed": is_completed
	}
