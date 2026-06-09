class_name VictoryReachLocation
extends VictoryCondition

## 到达指定位置条件
## 胜利：指定单位到达目标区域
## 失败：指定单位死亡 / 玩家全灭

@export var destination: NodePath = ^""
@export var required_units: Array[NodePath] = []
@export var require_all: bool = false  # true=全部到达，false=任一到达
@export var reach_radius: float = 60.0  # 如果destination不是Area2D，用此半径

var _destination_node: Node = null
var _required: Array = []
var _arrived_units: Array = []
var _destination_area: Area2D = null
var _detect_pos: Vector2  # 如果destination不是Area2D，用此位置
var _cached_result: int = 0

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	# 获取目标节点
	_destination_node = get_node_or_null(destination)
	if _destination_node == null:
		push_error("VictoryReachLocation: Destination node not found!")
		return

	# 判断目标是Area2D还是位置点
	if _destination_node is Area2D:
		_destination_area = _destination_node
		_destination_area.body_entered.connect(_on_body_entered)
	else:
		_detect_pos = _destination_node.global_position
		_create_detection_area()

	# 获取需要到达的单位
	if required_units.is_empty():
		pass
	else:
		for np in required_units:
			var unit := get_node_or_null(np)
			if unit != null:
				_required.append(unit)
				if unit.has_signal("died"):
					unit.died.connect(_on_unit_died)

func _create_detection_area() -> void:
	var area := Area2D.new()
	area.name = "ReachDetectionArea"
	add_child(area)

	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = reach_radius
	collision.shape = shape
	area.add_child(collision)

	area.global_position = _detect_pos
	area.body_entered.connect(_on_body_entered)
	_destination_area = area

func _on_body_entered(body: Node) -> void:
	if required_units.is_empty():
		if body.is_in_group("player_units"):
			_on_unit_arrived(body)
	else:
		if body in _required and body not in _arrived_units:
			_on_unit_arrived(body)

func _on_unit_arrived(unit: Node) -> void:
	if unit in _arrived_units:
		return

	_arrived_units.append(unit)

	var arrived_count := _arrived_units.size()
	var target_count := 1 if required_units.is_empty() else _required.size()

	if require_all:
		if arrived_count >= target_count:
			_cached_result = 1
	else:
		if arrived_count >= 1:
			_cached_result = 1

func _on_unit_died(_unit: Node = null) -> void:
	if not require_all:
		return

	# 全部模式：检查是否还有足够单位
	var alive_count := 0
	for u in _required:
		if is_instance_valid(u) and u.has_method("is_dead") and not u.is_dead():
			alive_count += 1

	if alive_count < _required.size():
		_cached_result = 2  # 无法达成，失败

func check() -> int:
	if _cached_result != 0:
		return _cached_result

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
	var arrived_count := _arrived_units.size()
	var target_count := 1 if required_units.is_empty() else _required.size()

	var state: int = 0
	if _cached_result == 1:
		state = 1
	elif _cached_result == 2:
		state = 2

	var progress: String = "%d/%d" % [arrived_count, target_count]
	if required_units.is_empty():
		progress = "Reach destination"

	return [{
		"text": tr(description_key),
		"progress": progress,
		"state": state
	}]

func get_progress_fraction() -> float:
	if required_units.is_empty():
		return -1.0

	var arrived_count := _arrived_units.size()
	return float(arrived_count) / float(_required.size())

func reset() -> void:
	_arrived_units.clear()
	_cached_result = 0
