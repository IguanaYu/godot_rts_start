class_name VictoryTerritoryScore
extends VictoryCondition

## 领土积分条件
## 胜利：玩家积分达到目标
## 失败：敌方积分达到目标

@export var territory_tracker_path: NodePath = ^""
@export var target_score: float = 500.0

var _tracker: TerritoryTracker = null
var _player_score: float = 0.0
var _enemy_score: float = 0.0

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	_tracker = get_node_or_null(territory_tracker_path)
	if _tracker == null:
		push_error("VictoryTerritoryScore: TerritoryTracker not found!")
		return

	if _tracker.has_signal("score_updated"):
		_tracker.score_updated.connect(_on_score_updated)
	if _tracker.has_signal("target_reached"):
		_tracker.target_reached.connect(_on_target_reached)

	# 初始分数
	_player_score = _tracker.get_score(0)
	_enemy_score = _tracker.get_score(1)

func _on_score_updated(team: int, score: float) -> void:
	if team == 0:
		_player_score = score
	else:
		_enemy_score = score
	objective_updated.emit()

func _on_target_reached(team: int) -> void:
	# check() 已根据分数判断胜负，这里只更新分数即可
	if team == 0:
		_player_score = target_score
	else:
		_enemy_score = target_score

func check() -> int:
	# 胜利条件
	if _player_score >= target_score:
		return 1  # 胜利

	# 失败条件
	if _enemy_score >= target_score:
		return 2  # 失败

	return 0  # 进行中

func get_objectives() -> Array[Dictionary]:
	var state := 0
	if _player_score >= target_score:
		state = 1
	elif _enemy_score >= target_score:
		state = 2

	return [{
		"text": tr(description_key),
		"progress": "%d/%d" % [int(_player_score), int(target_score)],
		"state": state
	}]

func get_progress_fraction() -> float:
	if target_score <= 0:
		return -1.0
	return _player_score / target_score
