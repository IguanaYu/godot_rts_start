class_name VictoryTimeLimit
extends VictoryCondition

## 限时完成条件
## 胜利：配合其他条件（通常由VictoryComposite使用）
## 失败：超时

@export var time_limit: float = 300.0  # 秒
@export var victory_on_expire: bool = false  # true=倒计时结束胜利（即限时生存），false=超时失败

var _start_time: float = 0.0
var _time_expired: bool = false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_start_time = Time.get_ticks_msec() / 1000.0

func check() -> int:
	var elapsed := Time.get_ticks_msec() / 1000.0 - _start_time

	if elapsed >= time_limit:
		_time_expired = true
		if victory_on_expire:
			return 1  # 胜利
		else:
			return 2  # 失败

	return 0  # 进行中

func get_objectives() -> Array[Dictionary]:
	var elapsed := Time.get_ticks_msec() / 1000.0 - _start_time
	var remaining := maxi(0, time_limit - elapsed)

	var state := 0
	if _time_expired:
		state = 1 if victory_on_expire else 2

	return [{
		"text": tr(description_key),
		"progress": "%ds" % remaining,
		"state": state
	}]

func get_progress_fraction() -> float:
	var elapsed := Time.get_ticks_msec() / 1000.0 - _start_time
	var remaining := maxi(0, time_limit - elapsed)
	if victory_on_expire:
		# 限时生存：进度条随时间增长
		return clampf(elapsed / time_limit, 0.0, 1.0)
	else:
		# 限时完成：进度条随时间减少
		return clampf(1.0 - (remaining / time_limit), 0.0, 1.0)

func reset() -> void:
	_start_time = Time.get_ticks_msec() / 1000.0
	_time_expired = false
