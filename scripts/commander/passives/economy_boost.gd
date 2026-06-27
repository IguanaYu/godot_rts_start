extends RefCounted
## 被动技能：经济加成
## 每秒为玩家方每座产出类建筑（CASTLE / building_stats.is_gold_producer=true）补发额外金币
## 装备指挥官：balanced

const TriggersClass := preload("res://scripts/commander/passive_triggers.gd")
const BuildingScript := preload("res://scripts/buildings/building.gd")

const GOLD_PER_PRODUCER: int = 2


func register(manager: Node, _profile) -> void:
	manager.register(TriggersClass.TICK_1S, func(_ctx: Dictionary): _on_tick(manager))


func _on_tick(manager: Node) -> void:
	var main_node := manager.get_tree().current_scene
	if main_node == null or not main_node.has_method("add_gold"):
		return
	var bonus: int = 0
	for b in main_node.get_tree().get_nodes_in_group("player_buildings"):
		if not is_instance_valid(b):
			continue
		if _is_gold_producer(b):
			bonus += GOLD_PER_PRODUCER
	if bonus > 0:
		main_node.add_gold(bonus)


func _is_gold_producer(b) -> bool:
	# 优先看 building_stats.is_gold_producer（数据驱动），fallback 到 building_type == CASTLE
	if b.get("building_stats") != null:
		var bs = b.building_stats
		if "is_gold_producer" in bs and bs.is_gold_producer:
			return true
	if "building_type" in b and b.building_type == BuildingScript.BuildingType.CASTLE:
		return true
	return false
