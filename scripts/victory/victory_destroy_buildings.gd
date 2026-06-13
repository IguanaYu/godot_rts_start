class_name VictoryDestroyBuildings
extends VictoryCondition

## 摧毁指定建筑条件
## 胜利：所有指定建筑被摧毁
## 失败：玩家城堡被毁（仅当有城堡时检测）

const BuildingScript := preload("res://scripts/buildings/building.gd")

@export var target_buildings: Array[NodePath] = []
@export var target_building_type: int = -1  # -1表示使用target_buildings，否则扫描enemy_buildings匹配类型
@export var target_team: int = 1  # 默认敌方(1)
@export var skip_defeat_check: bool = false  # 无玩家城堡时跳过失败检测
## 标记等级：0=普通, 1=重要, 2=关键
@export var marker_level: int = 0

const ObjectiveMarker := preload("res://scripts/effects/objective_marker.gd")

var _targets: Array = []
var _markers: Array = []
var _destroyed_count: int = 0
var _total_targets: int = 0
var _initialized := false

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	# 延迟初始化到第一次 check()，确保所有建筑的分组注册已完成
	if target_building_type < 0:
		_init_targets()

func _init_targets() -> void:
	if _initialized:
		return
	_initialized = true

	if target_building_type < 0:
		# 使用指定的目标建筑
		for np in target_buildings:
			var node := get_node_or_null(np)
			if node != null:
				_targets.append(node)
				if node.has_signal("died"):
					node.died.connect(_on_building_died)
				_total_targets += 1
				if node.has_method("is_dead") and node.is_dead():
					_destroyed_count += 1
				else:
					_add_marker(node, ObjectiveMarker.MarkerType.CROSSHAIR, marker_level)
	else:
		# 扫描指定分组的建筑，匹配类型
		var group := "enemy_buildings" if target_team == 1 else "player_buildings"
		for building in get_tree().get_nodes_in_group(group):
			if building.has_method("get"):
				var btype = building.get("building_type")
				if btype != null and btype == target_building_type:
					_targets.append(building)
					if building.has_signal("died"):
						building.died.connect(_on_building_died)
					_total_targets += 1
					if building.has_method("is_dead") and building.is_dead():
						_destroyed_count += 1
					else:
						_add_marker(building, ObjectiveMarker.MarkerType.CROSSHAIR, marker_level)

	if _total_targets == 0:
		push_warning("VictoryDestroyBuildings: No targets found!")

func _on_building_died(building: Node) -> void:
	_destroyed_count += 1
	# 移除对应标记
	for i in range(_markers.size() - 1, -1, -1):
		var m = _markers[i]
		if is_instance_valid(m) and m.belongs_to(building):
			m.dismiss()
			_markers.remove_at(i)
	if _destroyed_count >= _total_targets:
		objective_updated.emit()

func check() -> int:
	# 延迟初始化（第一次 check 时分组已就绪）
	if not _initialized:
		_init_targets()

	# 胜利条件
	if _destroyed_count >= _total_targets and _total_targets > 0:
		return 1  # 胜利

	# 失败条件：玩家城堡被毁（仅当有城堡时检测）
	if not skip_defeat_check:
		var player_castle_alive := false
		for b in get_tree().get_nodes_in_group("player_buildings"):
			if b.has_method("is_dead") and not b.is_dead():
				if b.get("building_type") == BuildingScript.BuildingType.CASTLE:
					player_castle_alive = true
					break

		if not player_castle_alive:
			return 2  # 失败

	return 0  # 进行中

func get_objectives() -> Array[Dictionary]:
	if not _initialized:
		_init_targets()

	var state := 0
	if _destroyed_count >= _total_targets and _total_targets > 0:
		state = 1  # 完成

	var type_name := ""
	if target_building_type >= 0:
		type_name = "Tower"

	return [{
		"text": tr(description_key) if target_building_type < 0 else ("Destroy: " + type_name),
		"progress": "%d/%d" % [_destroyed_count, _total_targets],
		"state": state
	}]

func get_progress_fraction() -> float:
	if _total_targets == 0:
		return -1.0
	return float(_destroyed_count) / float(_total_targets)

func reset() -> void:
	_destroyed_count = 0
	for m in _markers:
		if is_instance_valid(m):
			m.queue_free()
	_markers.clear()


# ============================================================
# 标记管理
# ============================================================
func _add_marker(target: Node, type: int, level: int) -> void:
	var marker := Node2D.new()
	marker.set_script(ObjectiveMarker)
	marker.marker_type = type
	marker.marker_level = level
	marker.setup(target)
	add_child(marker)
	_markers.append(marker)
