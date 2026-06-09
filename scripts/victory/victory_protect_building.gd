class_name VictoryProtectBuilding
extends VictoryCondition

## 保护建筑条件
## 胜利：存活到波次结束 / 倒计时结束 / 配合其他条件
## 失败：任一保护建筑被摧毁

const BuildingScript := preload("res://scripts/buildings/building.gd")

@export var protected_buildings: Array[NodePath] = []
@export var wave_manager_path: NodePath = ^""
@export var survival_time: float = 0.0  # 0表示不使用计时

var _protected: Array = []
var _wave_manager: Node = null
var _all_waves_done: bool = false
var _start_time: float = 0.0
var _cached_result: int = 0

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	# 连接保护建筑的died信号
	for np in protected_buildings:
		var node := get_node_or_null(np)
		if node != null:
			_protected.append(node)
			if node.has_signal("died"):
				node.died.connect(_on_building_died)

	if _protected.is_empty():
		push_error("VictoryProtectBuilding: No protected buildings assigned!")

	# 连接WaveManager（如果有）— 注意是 not is_empty()
	if not wave_manager_path.is_empty():
		_wave_manager = get_node_or_null(wave_manager_path)
		if _wave_manager != null and _wave_manager.has_signal("all_waves_completed"):
			_wave_manager.all_waves_completed.connect(_on_all_waves_completed)

	# 记录开始时间（如果有计时）
	if survival_time > 0:
		_start_time = Time.get_ticks_msec() / 1000.0

func _on_building_died(_building: Node = null) -> void:
	# 保护建筑被毁不直接判负，但无法再达成胜利条件
	pass

func _on_all_waves_completed() -> void:
	_all_waves_done = true

func check() -> int:
	if _cached_result != 0:
		return _cached_result

	# 失败条件：玩家城堡被毁
	var player_castle_alive := false
	for b in get_tree().get_nodes_in_group("player_buildings"):
		if b.has_method("is_dead") and not b.is_dead():
			if b.get("building_type") == BuildingScript.BuildingType.CASTLE:
				player_castle_alive = true
				break
	if not player_castle_alive:
		return 2  # 失败

	# 检查是否有胜利条件
	var victory_ready := false

	# 波次完成条件
	if _wave_manager != null and _all_waves_done:
		# 还需要清除所有敌人
		var enemy_count := 0
		for u in get_tree().get_nodes_in_group("enemy_units"):
			if u is CharacterBody2D and u.has_method("is_dead") and not u.is_dead():
				enemy_count += 1
		if enemy_count == 0:
			victory_ready = true

	# 计时完成条件
	if survival_time > 0:
		var elapsed := Time.get_ticks_msec() / 1000.0 - _start_time
		if elapsed >= survival_time:
			victory_ready = true

	# 如果没有配置胜利条件，返回0（由其他条件决定）
	if _wave_manager == null and survival_time <= 0:
		return 0

	if victory_ready:
		return 1  # 胜利

	return 0  # 进行中

func get_objectives() -> Array[Dictionary]:
	var state: int = 0
	if _cached_result == 2:
		state = 2  # 失败
	elif _wave_manager != null and _all_waves_done:
		state = 1  # 完成

	var progress: String = ""
	if survival_time > 0:
		var elapsed := Time.get_ticks_msec() / 1000.0 - _start_time
		var remaining := maxi(0, survival_time - elapsed)
		progress = tr("OBJ_TIME_REMAINING") % "%ds" % remaining

	return [{
		"text": tr(description_key),
		"progress": progress,
		"state": state
	}]

func get_progress_fraction() -> float:
	if survival_time <= 0:
		return -1.0
	var elapsed := Time.get_ticks_msec() / 1000.0 - _start_time
	var remaining := maxi(0, survival_time - elapsed)
	return 1.0 - (remaining / survival_time)

func reset() -> void:
	_cached_result = 0
	_all_waves_done = false
	_start_time = Time.get_ticks_msec() / 1000.0
