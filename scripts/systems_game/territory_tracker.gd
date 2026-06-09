class_name TerritoryTracker
extends Node

## 领土积分追踪系统
## 根据据点归属方累加积分

signal score_updated(team: int, score: float)
signal target_reached(team: int)

@export var capture_points: Array[NodePath] = []
@export var score_rate: float = 2.0  # 每秒每据点积分
@export var target_score: float = 500.0

var _scores: Dictionary = {0: 0.0, 1: 0.0}  # team -> score，0=玩家，1=敌方
var _capture_points_nodes: Array = []

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	# 获取据点节点
	for np in capture_points:
		var cp := get_node_or_null(np)
		if cp != null:
			_capture_points_nodes.append(cp)

	if _capture_points_nodes.is_empty():
		push_warning("TerritoryTracker: No capture points assigned!")

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	# 计算各方控制的据点数量
	var player_controlled := 0
	var enemy_controlled := 0

	for cp in _capture_points_nodes:
		if not is_instance_valid(cp):
			continue

		var captured_by := -1
		if cp.has_method("get"):
			captured_by = cp.get("captured_by")

		if captured_by == 0:  # 玩家
			player_controlled += 1
		elif captured_by == 1:  # 敌方
			enemy_controlled += 1

	# 累加积分
	if player_controlled > 0:
		_scores[0] += score_rate * float(player_controlled) * delta
		score_updated.emit(0, _scores[0])
		if _scores[0] >= target_score:
			target_reached.emit(0)

	if enemy_controlled > 0:
		_scores[1] += score_rate * float(enemy_controlled) * delta
		score_updated.emit(1, _scores[1])
		if _scores[1] >= target_score:
			target_reached.emit(1)

func get_score(team: int) -> float:
	return _scores.get(team, 0.0)

func get_target_score() -> float:
	return target_score
