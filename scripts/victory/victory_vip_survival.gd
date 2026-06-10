class_name VictoryVipSurvival
extends VictoryCondition

## VIP存活条件
## 胜利：配合其他条件完成时VIP仍存活
## 失败：任一VIP死亡

@export var vip_units: Array[NodePath] = []
## 标记等级：0=普通(3尖皇冠), 1=重要(5尖+宝石), 2=关键(5尖+十字)
@export var marker_level: int = 0

const ObjectiveMarker := preload("res://scripts/effects/objective_marker.gd")

var _vips: Array = []
var _markers: Array = []
var _cached_result: int = 0

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	# 解析NodePath并连接died信号
	for np in vip_units:
		var node := get_node_or_null(np)
		if node != null:
			_vips.append(node)
			if node.has_signal("died"):
				node.died.connect(_on_vip_died)
			_add_marker(node, ObjectiveMarker.MarkerType.CROWN, marker_level)

	if _vips.is_empty():
		push_error("VictoryVipSurvival: No VIP units assigned!")

func _on_vip_died(_vip: Node = null) -> void:
	_cached_result = 2  # 失败

func check() -> int:
	return _cached_result

func get_objectives() -> Array[Dictionary]:
	var alive_count := 0
	for vip in _vips:
		if is_instance_valid(vip):
			if vip.has_method("is_dead") and not vip.is_dead():
				alive_count += 1

	var state := 0  # 进行中
	if _cached_result == 2:
		state = 2  # 失败
	elif alive_count == _vips.size():
		state = 1  # 全部存活（但不直接胜利，需配合其他条件）

	return [{
		"text": tr(description_key),
		"progress": "%d/%d" % [alive_count, _vips.size()],
		"state": state
	}]

func get_progress_fraction() -> float:
	if _vips.is_empty():
		return -1.0
	var alive_count := 0
	for vip in _vips:
		if is_instance_valid(vip):
			if vip.has_method("is_dead") and not vip.is_dead():
				alive_count += 1
	return float(alive_count) / float(_vips.size())

func reset() -> void:
	_cached_result = 0
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
	if target.has_signal("died"):
		target.died.connect(func(_t): marker.dismiss())
