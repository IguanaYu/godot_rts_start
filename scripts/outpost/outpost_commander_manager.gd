extends Node
## 据点指挥官调度器：注册/查询/周期 tick 分发 + 建筑/单位打 commander_ids
## 实例化位置：main.gd Step 5.5（spawner 之后），以便 spawner 创建单位/建筑时立即调 tag_entity

var _commanders: Array = []  # OutpostCommander 实例列表


func _ready() -> void:
	# 自动扫描场景中所有 OutpostCommander 节点（避免依赖节点 _ready defer 时序）
	call_deferred("_auto_scan")


func _auto_scan() -> void:
	var main_node := get_tree().current_scene
	if main_node == null:
		return
	for child in main_node.find_children("*", "OutpostCommander", true, false):
		if child not in _commanders:
			_commanders.append(child)
	# 给所有现存的 enemy_buildings/enemy_units 补打 tag（spawner 已先于 Manager 实例化的情况）
	for b in get_tree().get_nodes_in_group("enemy_buildings"):
		tag_entity(b)
	for u in get_tree().get_nodes_in_group("enemy_units"):
		tag_entity(u)


func register_commander(cmdr) -> void:
	if cmdr in _commanders:
		return
	_commanders.append(cmdr)
	# 该指挥官一上线，立即给现存匹配的单位/建筑补 tag
	for b in get_tree().get_nodes_in_group("enemy_buildings"):
		_tag_if_inside(cmdr, b)
	for u in get_tree().get_nodes_in_group("enemy_units"):
		_tag_if_inside(cmdr, u)


func unregister_commander(cmdr) -> void:
	_commanders.erase(cmdr)


func _process(delta: float) -> void:
	for cmdr in _commanders:
		if is_instance_valid(cmdr):
			cmdr.tick(delta)


# ============================================================
# 归属打标
# ============================================================
## 给建筑/单位打 commander_ids（由 game_spawner / building_placer 在创建后调用）
func tag_entity(entity) -> void:
	if not is_instance_valid(entity):
		return
	if not ("commander_ids" in entity):
		return
	for cmdr in _commanders:
		_tag_if_inside(cmdr, entity)


func _tag_if_inside(cmdr, entity) -> void:
	if not is_instance_valid(cmdr) or not is_instance_valid(entity):
		return
	if not cmdr.has_method("contains_entity") or not cmdr.has_method("get_uid"):
		return
	if not cmdr.contains_entity(entity):
		return
	var uid: StringName = cmdr.get_uid()
	if uid == &"":
		return
	if uid not in entity.commander_ids:
		entity.commander_ids.append(uid)


func get_commanders() -> Array:
	return _commanders.duplicate()


func get_commander_by_uid(uid: StringName) -> Node:
	for cmdr in _commanders:
		if is_instance_valid(cmdr) and cmdr.has_method("get_uid") and cmdr.get_uid() == uid:
			return cmdr
	return null
