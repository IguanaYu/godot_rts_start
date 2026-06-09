class_name VictoryKillCount
extends VictoryCondition

## 击杀计数条件
## 胜利：击杀达到目标数
## 失败：玩家城堡被毁 / 全灭

const BuildingScript := preload("res://scripts/buildings/building.gd")

@export var kill_target: int = 50
@export var include_buildings: bool = false

var _kill_count: int = 0
var _tracked_enemies: Array = []  # 已连接信号的敌人
var _rescan_timer: float = 0.0
const RESCAN_INTERVAL: float = 0.5  # 每0.5秒重新扫描新敌人

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	# 初始扫描并连接信号
	_scan_and_connect_enemies()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	_rescan_timer += delta
	if _rescan_timer >= RESCAN_INTERVAL:
		_rescan_timer = 0.0
		_scan_and_connect_enemies()

func _scan_and_connect_enemies() -> void:
	# 扫描enemy_units，连接新的敌人
	for unit in get_tree().get_nodes_in_group("enemy_units"):
		if unit in _tracked_enemies:
			continue  # 已连接
		if unit.has_method("is_dead") and unit.is_dead():
			continue  # 已死亡

		_tracked_enemies.append(unit)
		if unit.has_signal("died"):
			unit.died.connect(_on_enemy_died)

	# 如果包含建筑
	if include_buildings:
		for building in get_tree().get_nodes_in_group("enemy_buildings"):
			if building in _tracked_enemies:
				continue
			if building.has_method("is_dead") and building.is_dead():
				continue

			_tracked_enemies.append(building)
			if building.has_signal("died"):
				building.died.connect(_on_enemy_died)

func _on_enemy_died(enemy: Node) -> void:
	_kill_count += 1
	objective_updated.emit()

func check() -> int:
	# 胜利条件
	if _kill_count >= kill_target:
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
	var any_alive := false
	for u in get_tree().get_nodes_in_group("player_units"):
		if u is CharacterBody2D and u.has_method("is_dead") and not u.is_dead():
			any_alive = true
			break

	if not any_alive:
		return 2  # 失败

	return 0  # 进行中

func get_objectives() -> Array[Dictionary]:
	var state := 0
	if _kill_count >= kill_target:
		state = 1  # 完成

	return [{
		"text": tr(description_key),
		"progress": "%d/%d" % [_kill_count, kill_target],
		"state": state
	}]

func get_progress_fraction() -> float:
	return float(_kill_count) / float(kill_target)

func reset() -> void:
	_kill_count = 0
	_tracked_enemies.clear()
