class_name VictoryEndless
extends VictoryCondition

## 无尽模式
## 无硬性胜利条件，只追踪波数和分数
## 失败：玩家被击败

const BuildingScript := preload("res://scripts/buildings/building.gd")

@export var wave_manager_path: NodePath = ^""
@export var score_per_kill: int = 10
@export var score_per_wave: int = 100

var _wave_manager: Node = null
var _waves_survived: int = 0
var _total_kills: int = 0
var _total_score: int = 0
var _highest_wave: int = 0
var _wave_started_count: int = 0

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	_wave_manager = get_node_or_null(wave_manager_path)
	if _wave_manager != null:
		if _wave_manager.has_signal("wave_started"):
			_wave_manager.wave_started.connect(_on_wave_started)
		if _wave_manager.has_signal("all_waves_completed"):
			_wave_manager.all_waves_completed.connect(_on_all_waves_completed)

	# 连接所有现有单位的died信号
	_connect_existing_enemies()

func _connect_existing_enemies() -> void:
	for unit in get_tree().get_nodes_in_group("enemy_units"):
		if unit.has_signal("died"):
			if not unit.died.is_connected(_on_enemy_killed):
				unit.died.connect(_on_enemy_killed)

func _on_wave_started(wave_number: int) -> void:
	_wave_started_count = wave_number
	# 连接新敌人的died信号
	_connect_existing_enemies()

func _on_all_waves_completed() -> void:
	_waves_survived += 1
	_total_score += score_per_wave

	# 重新开始波次（无尽循环）
	if _wave_manager != null and _wave_manager.has_method("start_waves"):
		_wave_manager.start_waves()

func _on_enemy_killed(enemy: Node) -> void:
	_total_kills += 1
	_total_score += score_per_kill
	objective_updated.emit()

func check() -> int:
	# 无尽模式永远不返回胜利（1）
	# 只检查失败条件

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
	var any_alive := false
	for u in get_tree().get_nodes_in_group("player_units"):
		if u is CharacterBody2D and u.has_method("is_dead") and not u.is_dead():
			any_alive = true
			break

	if not any_alive:
		return 2  # 失败

	return 0  # 进行中（无尽）

func get_objectives() -> Array[Dictionary]:
	return [
		{"text": "Waves: %d" % _wave_started_count, "progress": "", "state": 0},
		{"text": "Kills: %d" % _total_kills, "progress": "", "state": 0},
		{"text": "Score: %d" % _total_score, "progress": "", "state": 0},
	]

func get_progress_fraction() -> float:
	return -1.0  # 无尽模式无进度条
