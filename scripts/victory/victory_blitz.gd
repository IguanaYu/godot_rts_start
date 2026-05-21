class_name VictoryBlitz
extends VictoryCondition

const UnitScript := preload("res://scripts/units/unit.gd")

@export var capture_points: Array[NodePath] = []

var current_target: int = 0
var game_result: int = 0  # 0=ongoing, 1=victory, 2=defeat
var _captured_count: int = 0

func _ready() -> void:
	# 第一个点启用触发检测，其余禁用
	for i in range(capture_points.size()):
		var cp = get_node_or_null(capture_points[i])
		if cp == null:
			continue
		cp.captured.connect(_on_point_captured)
		if i == 0:
			cp.enable()
		else:
			cp.disable()

func _on_point_captured(team: int) -> void:
	if team != UnitScript.Team.PLAYER:
		return

	_captured_count += 1

	# 治疗所有玩家单位
	_heal_all_players()

	# 启用下一个点
	if current_target + 1 < capture_points.size():
		current_target += 1
		var cp = get_node_or_null(capture_points[current_target])
		if cp != null:
			cp.enable()

func _heal_all_players() -> void:
	for u in get_tree().get_nodes_in_group("player_units"):
		if u is CharacterBody2D and not u.is_dead():
			if u.has_method("heal"):
				u.heal(int(u.health.max_hp * 0.5))

func check() -> int:
	if game_result != 0:
		return game_result

	# 失败：所有玩家单位死亡
	var any_alive := false
	for u in get_tree().get_nodes_in_group("player_units"):
		if u is CharacterBody2D and not u.is_dead():
			any_alive = true
			break
	if not any_alive:
		game_result = 2
		return 2

	# 胜利：所有点占领
	if _captured_count >= capture_points.size():
		game_result = 1
		return 1

	return 0
