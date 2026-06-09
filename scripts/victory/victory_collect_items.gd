class_name VictoryCollectItems
extends VictoryCondition

## 收集物品条件
## 胜利：收集达到目标数量
## 失败：玩家城堡被毁

const BuildingScript := preload("res://scripts/buildings/building.gd")

@export var required_count: int = 0  # 0表示收集所有物品
@export var item_filter: String = ""  # 如果非空，只收集匹配item_id的物品

var _collected_count: int = 0
var _total_count: int = 0
var _collected_items: Array = []

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	# 扫描所有CollectibleItem
	for item in get_tree().get_nodes_in_group("collectible_items"):
		var item_id := ""
		if item.has_method("get"):
			item_id = item.get("item_id")

		# 应用过滤
		if item_filter.is_empty() or item_id == item_filter:
			_total_count += 1
			if item.has_signal("collected"):
				item.collected.connect(_on_item_collected)

			# 检查是否初始已收集
			if item.get("_collected"):
				_collected_count += 1
				_collected_items.append(item)

	if _total_count == 0:
		push_warning("VictoryCollectItems: No items found!")

func _on_item_collected(item: CollectibleItem) -> void:
	if item in _collected_items:
		return

	# 应用过滤
	var item_id := ""
	if item.has_method("get"):
		item_id = item.get("item_id")

	if item_filter.is_empty() or item_id == item_filter:
		_collected_items.append(item)
		_collected_count += 1
		objective_updated.emit()

func check() -> int:
	var target_count := required_count if required_count > 0 else _total_count

	# 胜利条件
	if _collected_count >= target_count and target_count > 0:
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

	return 0  # 进行中

func get_objectives() -> Array[Dictionary]:
	var target_count := required_count if required_count > 0 else _total_count
	var state := 0
	if _collected_count >= target_count and target_count > 0:
		state = 1  # 完成

	return [{
		"text": tr(description_key),
		"progress": "%d/%d" % [_collected_count, target_count],
		"state": state
	}]

func get_progress_fraction() -> float:
	var target_count := required_count if required_count > 0 else _total_count
	if target_count <= 0:
		return -1.0
	return float(_collected_count) / float(target_count)

func reset() -> void:
	_collected_count = 0
	_collected_items.clear()
