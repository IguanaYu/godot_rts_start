extends Node
## PR-T2-4: 兵种全局升级管理器。玩家花金币购买升级节点，购买后现有 + 未来单位即时获得加成。
## 与 scripts/upgrade/upgrade_manager.gd（代币三选一）是两套独立系统：
## source_id 前缀不同（unit_upgrade:  vs global_upgrade:），stat_set modifier 互不干扰。

const UUD := preload("res://scripts/upgrade/unit_upgrade_data.gd")
const StatSetClass := preload("res://scripts/stats/stat_set.gd")
const UnitScript := preload("res://scripts/units/unit.gd")
const BuildingScript := preload("res://scripts/buildings/building.gd")

signal upgrade_purchased(node_id: String, new_level: int)

var _levels: Dictionary = {}  # node_id -> current_level
var _main_node: Node2D


func initialize(main_node: Node2D) -> void:
	_main_node = main_node


func get_level(node_id: String) -> int:
	return _levels.get(node_id, 0)


func get_max_level(node_id: String) -> int:
	if not UUD.CONFIGS.has(node_id):
		return 0
	return UUD.CONFIGS[node_id].get("max_level", 1)


func is_maxed(node_id: String) -> bool:
	return get_level(node_id) >= get_max_level(node_id)


func get_next_cost(node_id: String) -> int:
	if not UUD.CONFIGS.has(node_id):
		return -1
	var cfg: Dictionary = UUD.CONFIGS[node_id]
	return int(cfg.get("cost", 0) * pow(cfg.get("cost_growth", 1.5), get_level(node_id)))


func can_purchase(node_id: String) -> bool:
	if not UUD.CONFIGS.has(node_id):
		return false
	if is_maxed(node_id):
		return false
	return _main_node != null and _main_node.gold >= get_next_cost(node_id)


func purchase(node_id: String) -> bool:
	if not can_purchase(node_id):
		return false
	var cost := get_next_cost(node_id)
	_main_node.gold -= cost
	if _main_node.ui_module:
		_main_node.ui_module.update_gold_display(_main_node.gold)
	_levels[node_id] = get_level(node_id) + 1
	_apply_upgrade(node_id)
	upgrade_purchased.emit(node_id, _levels[node_id])
	return true


# ============================================================
# 加成应用（单位类）
# ============================================================

func _source_id(node_id: String) -> String:
	return "unit_upgrade:%s" % node_id


func _apply_upgrade(node_id: String) -> void:
	var cfg: Dictionary = UUD.CONFIGS[node_id]
	if cfg.get("category", UUD.Category.UNIT) == UUD.Category.BUILDING:
		_apply_to_existing_buildings(node_id, cfg)
	else:
		_apply_to_existing_units(node_id, cfg)


func _apply_to_existing_units(node_id: String, cfg: Dictionary) -> void:
	var lv := get_level(node_id)
	var mult: float = pow(cfg.get("multiplier", 1.0), lv)
	var flat: float = cfg.get("flat", 0.0) * lv
	var stat_name: String = cfg.get("stat_name", "")
	var filter: String = cfg.get("unit_filter", "all")
	for unit in _main_node.get_tree().get_nodes_in_group("player_units"):
		if not is_instance_valid(unit) or unit.is_dead():
			continue
		if not _unit_matches_filter(unit, filter):
			continue
		unit.stat_set.add_modifier(_source_id(node_id), stat_name, flat, mult)
		_sync_hp_if_needed(unit, stat_name)


## 新产出的单位应用当前所有已购升级（game_spawner 产兵路径调用）
func apply_to_new_unit(unit) -> void:
	if not is_instance_valid(unit) or unit.is_dead():
		return
	for node_id in _levels:
		var lv: int = _levels[node_id]
		if lv <= 0:
			continue
		var cfg: Dictionary = UUD.CONFIGS[node_id]
		if cfg.get("category", UUD.Category.UNIT) != UUD.Category.UNIT:
			continue
		if not _unit_matches_filter(unit, cfg.get("unit_filter", "all")):
			continue
		var mult: float = pow(cfg.get("multiplier", 1.0), lv)
		var flat: float = cfg.get("flat", 0.0) * lv
		unit.stat_set.add_modifier(_source_id(node_id), cfg.get("stat_name", ""), flat, mult)
	# 新单位 HP 同步（直接设满）
	var new_max: int = unit.stat_set.get_int(StatSetClass.MAX_HP)
	if unit.health and new_max != unit.health.max_hp:
		unit.health.max_hp = new_max
		if unit.health.hp_bar:
			unit.health.hp_bar.max_value = new_max
		unit.health.hp = new_max


# ============================================================
# 加成应用（建筑类，无 stat_set，走 building 裸字段 mult）
# ============================================================

func _apply_to_existing_buildings(node_id: String, cfg: Dictionary) -> void:
	var lv := get_level(node_id)
	var mult: float = pow(cfg.get("multiplier", 1.0), lv)
	var bfilter: String = cfg.get("building_filter", "all")
	var effect_type: int = cfg.get("effect_type", UUD.EffectType.STAT_MOD)
	for b in _main_node.get_tree().get_nodes_in_group("player_buildings"):
		if not is_instance_valid(b) or b.is_dead():
			continue
		if not _building_matches_filter(b, bfilter):
			continue
		match effect_type:
			UUD.EffectType.GOLD_PRODUCTION:
				b.apply_gold_mult(mult)
			UUD.EffectType.STAT_MOD:
				if cfg.get("stat_name", "") == "max_hp":
					b.apply_max_hp_mult(mult)


func _sync_hp_if_needed(unit, stat_name: String) -> void:
	if stat_name != StatSetClass.MAX_HP:
		return
	var new_max: int = unit.stat_set.get_int(StatSetClass.MAX_HP)
	if unit.health:
		var old_max: int = unit.health.max_hp
		unit.health.max_hp = new_max
		if unit.health.hp_bar:
			unit.health.hp_bar.max_value = new_max
		var delta: int = new_max - old_max
		if delta > 0:
			unit.health.hp = mini(unit.health.hp + delta, new_max)


func _unit_matches_filter(unit, filter: String) -> bool:
	match filter:
		"all":
			return true
		"combat":
			return unit.unit_type != UnitScript.UnitType.MONK
		"monk":
			return unit.unit_type == UnitScript.UnitType.MONK
		"soldier":
			return unit.unit_type == UnitScript.UnitType.SOLDIER
		"archer":
			return unit.unit_type == UnitScript.UnitType.ARCHER
		"lancer":
			return unit.unit_type == UnitScript.UnitType.LANCER
	return true


func _building_matches_filter(b, filter: String) -> bool:
	match filter:
		"all":
			return true
		"castle":
			return b.building_type == BuildingScript.BuildingType.CASTLE
		"farm":
			return b.building_type == BuildingScript.BuildingType.FARM
		"barracks":
			return b.building_type == BuildingScript.BuildingType.BARRACKS
		"tower":
			return b.building_type == BuildingScript.BuildingType.TOWER
		"archery":
			return b.building_type == BuildingScript.BuildingType.ARCHERY
	return true
