class_name BonusObjectiveCollectAll
extends BonusObjective

@export var item_filter: String = ""

var _total_count: int = 0
var _collected_count: int = 0

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	# 扫描所有物品
	for item in get_tree().get_nodes_in_group("collectible_items"):
		var item_id := ""
		if item.has_method("get"):
			item_id = item.get("item_id")

		if item_filter.is_empty() or item_id == item_filter:
			_total_count += 1
			if item.get("_collected"):
				_collected_count += 1

func check() -> bool:
	if is_completed:
		return true

	# 重新计数
	_collected_count = 0
	for item in get_tree().get_nodes_in_group("collectible_items"):
		var item_id := ""
		if item.has_method("get"):
			item_id = item.get("item_id")

		if item_filter.is_empty() or item_id == item_filter:
			if item.get("_collected"):
				_collected_count += 1

	if _collected_count >= _total_count and _total_count > 0:
		_grant_reward()
		return true

	return false

func get_objective_text() -> Dictionary:
	return {
		"text": tr(description_key) + " (%d/%d)" % [_collected_count, _total_count],
		"completed": is_completed
	}
