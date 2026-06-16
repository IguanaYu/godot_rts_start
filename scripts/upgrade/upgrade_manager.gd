extends Node
## 升级管理器：管理 token 计数、已购升级、效果执行

const UD := preload("res://scripts/upgrade/upgrade_data.gd")
const StatSetClass := preload("res://scripts/stats/stat_set.gd")
const UnitScript := preload("res://scripts/units/unit.gd")

signal token_count_changed(tokens: Dictionary)
signal upgrade_applied(upgrade_id: int)

var tokens: Dictionary = {UD.Tier.SILVER: 0, UD.Tier.GOLD: 0, UD.Tier.DIAMOND: 0}
var purchased_upgrades: Array[int] = []

var _main_node: Node2D
var _spawner: Node  # game_spawner, duck typing


func initialize(main_node: Node2D) -> void:
	_main_node = main_node


func set_spawner(spawner: Node) -> void:
	_spawner = spawner


func add_token(tier: int) -> void:
	tokens[tier] = tokens.get(tier, 0) + 1
	token_count_changed.emit(tokens)


func get_total_tokens() -> int:
	var total := 0
	for tier in tokens:
		total += tokens[tier]
	return total


func get_highest_tier_token() -> int:
	if tokens.get(UD.Tier.DIAMOND, 0) > 0:
		return UD.Tier.DIAMOND
	if tokens.get(UD.Tier.GOLD, 0) > 0:
		return UD.Tier.GOLD
	if tokens.get(UD.Tier.SILVER, 0) > 0:
		return UD.Tier.SILVER
	return -1


func can_open_selection() -> bool:
	return get_total_tokens() > 0


func get_random_choices(tier: int, count: int = 3) -> Array:
	var pool: Array = UD.BY_TIER.get(tier, [])
	var available: Array = []
	for uid in pool:
		if uid not in purchased_upgrades:
			available.append(uid)
	available.shuffle()
	return available.slice(0, mini(count, available.size()))


func purchase_upgrade(upgrade_id: int) -> void:
	if upgrade_id in purchased_upgrades:
		return
	var config: Dictionary = UD.CONFIGS[upgrade_id]
	var tier: int = config.tier
	if tokens.get(tier, 0) <= 0:
		return
	tokens[tier] -= 1
	purchased_upgrades.append(upgrade_id)
	_execute_effect(upgrade_id)
	upgrade_applied.emit(upgrade_id)
	token_count_changed.emit(tokens)


func _execute_effect(upgrade_id: int) -> void:
	var config: Dictionary = UD.CONFIGS[upgrade_id]
	var etype: int = config.effect_type
	match etype:
		UD.EffectType.STAT_MOD:
			_apply_stat_upgrade_to_all(upgrade_id)
		UD.EffectType.SPAWN_UNITS:
			_spawn_units(config)
		UD.EffectType.GIVE_GOLD:
			_give_gold(config)


func _apply_stat_upgrade_to_all(upgrade_id: int) -> void:
	var config: Dictionary = UD.CONFIGS[upgrade_id]
	var stat_name: String = config.stat_name
	var flat: float = config.get("flat", 0.0)
	var mult: float = config.get("multiplier", 1.0)
	var ufilter: String = config.get("unit_filter", "all")
	var source_id: String = "global_upgrade:%d" % upgrade_id

	for unit in _main_node.get_tree().get_nodes_in_group("player_units"):
		if _is_unit_dead(unit):
			continue
		if not _unit_matches_filter(unit, ufilter):
			continue
		unit.stat_set.add_modifier(source_id, stat_name, flat, mult)
		_sync_hp_if_needed(unit, stat_name)


func apply_all_stat_upgrades_to_unit(unit) -> void:
	for upgrade_id in purchased_upgrades:
		var config: Dictionary = UD.CONFIGS[upgrade_id]
		if config.effect_type != UD.EffectType.STAT_MOD:
			continue
		var ufilter: String = config.get("unit_filter", "all")
		if not _unit_matches_filter(unit, ufilter):
			continue
		var source_id: String = "global_upgrade:%d" % upgrade_id
		unit.stat_set.add_modifier(
			source_id,
			config.stat_name,
			config.get("flat", 0.0),
			config.get("multiplier", 1.0),
		)
	# 新单位 HP 同步（直接设满）
	var new_max: int = unit.stat_set.get_int(StatSetClass.MAX_HP)
	if unit.health and new_max != unit.health.max_hp:
		unit.health.max_hp = new_max
		if unit.health.hp_bar:
			unit.health.hp_bar.max_value = new_max
		unit.health.hp = new_max


func _sync_hp_if_needed(unit, stat_name: String) -> void:
	if stat_name != StatSetClass.MAX_HP:
		return
	var new_max: int = unit.stat_set.get_int(StatSetClass.MAX_HP)
	if unit.health:
		var old_max: int = unit.health.max_hp
		unit.health.max_hp = new_max
		if unit.health.hp_bar:
			unit.health.hp_bar.max_value = new_max
		# 按增量回血
		var delta: int = new_max - old_max
		if delta > 0:
			unit.health.hp = mini(unit.health.hp + delta, new_max)


func _spawn_units(config: Dictionary) -> void:
	if not _spawner:
		return
	var base_pos := _get_base_position()
	var spawn_list: Array = config.get("spawn_units", [])
	var main_scene := get_tree().current_scene
	var has_rally: bool = main_scene != null and main_scene.get("has_global_rally")
	for entry in spawn_list:
		var type: int = entry.get("type", 0)
		var count: int = entry.get("count", 1)
		for _i in count:
			var u = _spawner.spawn_unit_near(type, base_pos, UnitScript.Team.PLAYER)
			if has_rally and u:
				u.attack_move_to(main_scene.global_rally_point)


func _give_gold(config: Dictionary) -> void:
	var amount: int = config.get("gold_amount", 0)
	if amount <= 0:
		return
	_main_node.gold += amount
	if _main_node.ui_module:
		_main_node.ui_module.update_gold_display(_main_node.gold)


func _get_base_position() -> Vector2:
	var buildings := _main_node.get_tree().get_nodes_in_group("player_buildings")
	if buildings.is_empty():
		return _main_node.map_bounds.position + _main_node.map_bounds.size / 2.0
	for preferred_type in [2, 1, 3]:  # CASTLE=2, BARRACKS=1, TOWER=3
		for building in buildings:
			if building.get("building_type") == preferred_type and not building.is_dead():
				return building.global_position
	return buildings[0].global_position


func _unit_matches_filter(unit, filter: String) -> bool:
	match filter:
		"all":
			return true
		"combat":
			return unit.unit_type != UnitScript.UnitType.MONK
		"monk":
			return unit.unit_type == UnitScript.UnitType.MONK
	return true


func _is_unit_dead(unit) -> bool:
	if unit.health and unit.health.is_dead():
		return true
	return unit.state == UnitScript.UnitState.DEAD
