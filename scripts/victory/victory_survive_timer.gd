class_name VictorySurviveTimer
extends VictoryCondition

## 限时生存条件
## 胜利：存活到计时结束
## 失败：城堡被毁 / 全灭

const BuildingScript := preload("res://scripts/buildings/building.gd")

@export var survival_time: float = 300.0  # 秒
@export var defeat_on_all_dead: bool = true  # 是否全军覆没时失败

var _start_time: float = 0.0

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_start_time = Time.get_ticks_msec() / 1000.0

func check() -> int:
	var elapsed := Time.get_ticks_msec() / 1000.0 - _start_time

	# 胜利条件：存活到计时结束
	if elapsed >= survival_time:
		return 1  # 胜利

	# 失败条件：玩家城堡被毁
	var player_castle_alive := false
	for b in get_tree().get_nodes_in_group("player_buildings"):
		if b.has_method("is_dead") and not b.is_dead():
			if b.get("building_type") == BuildingScript.BuildingType.CASTLE:
				player_castle_alive = true
				break

	if not player_castle_alive:
		return 2  # 失败

	# 失败条件：玩家全灭
	if defeat_on_all_dead:
		var any_alive := false
		for u in get_tree().get_nodes_in_group("player_units"):
			if u is CharacterBody2D and u.has_method("is_dead") and not u.is_dead():
				any_alive = true
				break

		if not any_alive:
			return 2  # 失败

	return 0  # 进行中

func get_objectives() -> Array[Dictionary]:
	var elapsed := Time.get_ticks_msec() / 1000.0 - _start_time
	var remaining := maxi(0, survival_time - elapsed)

	return [{
		"text": tr(description_key),
		"progress": "%ds" % remaining,
		"state": 0
	}]

func get_progress_fraction() -> float:
	var elapsed := Time.get_ticks_msec() / 1000.0 - _start_time
	return clampf(elapsed / survival_time, 0.0, 1.0)

func reset() -> void:
	_start_time = Time.get_ticks_msec() / 1000.0
