class_name VictoryTimeExtender
extends VictoryCondition

## 摧毁建筑批次时延长限时
## 纯副作用条件，check() 始终返回 0

@export var time_limit_path: NodePath = ^""
@export var bonus_per_batch: float = 90.0
## 每个据点的建筑 NodePath 列表，空 NodePath 作为据点分隔符
## 例: [NodePath("A"), NodePath("B"), NodePath(""), NodePath("C"), NodePath("D")]
@export var target_buildings: Array[NodePath] = []

var _time_limit: VictoryTimeLimit = null
var _batches: Array[Array] = []  # Array of Array[Node]
var _batch_granted: Array[bool] = []

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_time_limit = get_node_or_null(time_limit_path)
	_parse_batches()

func _parse_batches() -> void:
	var current_batch: Array = []
	for np in target_buildings:
		if np == NodePath(""):
			if not current_batch.is_empty():
				_batches.append(current_batch)
				_batch_granted.append(false)
			current_batch = []
			continue
		var node := get_node_or_null(np)
		if node != null:
			current_batch.append(node)
			if node.has_signal("died"):
				node.died.connect(_on_building_died)
	if not current_batch.is_empty():
		_batches.append(current_batch)
		_batch_granted.append(false)

func _on_building_died(_building: Node) -> void:
	for i in range(_batches.size()):
		if _batch_granted[i]:
			continue
		var all_dead := true
		for b in _batches[i]:
			if is_instance_valid(b) and b.has_method("is_dead") and not b.is_dead():
				all_dead = false
				break
		if all_dead:
			_batch_granted[i] = true
			if _time_limit:
				_time_limit.add_time(bonus_per_batch)
			objective_updated.emit()

func check() -> int:
	return 0

func get_objectives() -> Array[Dictionary]:
	var granted := 0
	for g in _batch_granted:
		if g:
			granted += 1
	return [{
		"text": tr(description_key),
		"progress": "+%ds × %d/%d" % [int(bonus_per_batch), granted, _batches.size()],
		"state": 1 if granted >= _batches.size() else 0
	}]

func get_progress_fraction() -> float:
	if _batches.is_empty():
		return -1.0
	var granted := 0
	for g in _batch_granted:
		if g:
			granted += 1
	return float(granted) / float(_batches.size())

func reset() -> void:
	for i in range(_batch_granted.size()):
		_batch_granted[i] = false
