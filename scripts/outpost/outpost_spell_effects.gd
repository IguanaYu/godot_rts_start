extends RefCounted
## 据点指挥官法术实现（敌方阵营版本，对应 skill_effects.gd 的玩家版）
## 调用方式：OutpostSpellEffects.<spell_id>(main_node, spawner_module, target_pos, config)
## 复用 skill_effects.gd 的 _show_area_indicator 模式

const UnitScript := preload("res://scripts/units/unit.gd")
const BuildingScript := preload("res://scripts/buildings/building.gd")
const SkillEffectsRef := preload("res://scripts/commander_skill/skill_effects.gd")


# ============================================================
# heal — 治疗圈内友方单位（敌方阵营）
# ============================================================
static func heal(main_node: Node2D, _spawner_module: Node, target_pos: Vector2, config: Dictionary) -> void:
	var radius: float = config.get("radius", 100.0)
	var heal_amount: int = config.get("heal_amount", 50)

	var healed_count := 0
	for unit in main_node.get_tree().get_nodes_in_group("enemy_units"):
		if not is_instance_valid(unit):
			continue
		if not (unit is CharacterBody2D):
			continue
		if unit.health == null or unit.health.is_dead():
			continue
		if unit.global_position.distance_to(target_pos) <= radius:
			unit.heal(heal_amount)
			healed_count += 1

	_show_area_indicator(main_node, target_pos, radius, Color(0.1, 0.9, 0.3, 0.4))
	if _spawner_module != null and _spawner_module.has_method("show_floating_text") and healed_count > 0:
		_spawner_module.show_floating_text("+%d" % heal_amount, Color(0.1, 0.9, 0.3), target_pos)


# ============================================================
# inspire — 鼓舞：群体加攻击 buff（以单位为圆心）
# 注：当前 buff 系统只注册了 attack/defense/attack_melee/range_bonus，
#     暂用 "attack"（加攻击力）作为鼓舞效果。后续可扩展 attack_speed/move_speed。
# ============================================================
static func inspire(main_node: Node2D, _spawner_module: Node, target_pos: Vector2, config: Dictionary) -> void:
	var radius: float = config.get("radius", 120.0)
	var attack_bonus: float = config.get("attack_speed_bonus", 0.5)  # 复用字段名，实际作为 attack 加成
	var duration_sec: float = config.get("duration", 8.0)
	var duration_msec: int = int(duration_sec * 1000)

	var buffed_count := 0
	for unit in main_node.get_tree().get_nodes_in_group("enemy_units"):
		if not is_instance_valid(unit):
			continue
		if not (unit is CharacterBody2D):
			continue
		if unit.health == null or unit.health.is_dead():
			continue
		if unit.global_position.distance_to(target_pos) <= radius:
			if unit.has_method("apply_buff_duration"):
				unit.apply_buff_duration("attack", attack_bonus, duration_msec)
				buffed_count += 1

	_show_area_indicator(main_node, target_pos, radius, Color(1.0, 0.85, 0.2, 0.4))
	if _spawner_module != null and _spawner_module.has_method("show_floating_text") and buffed_count > 0:
		_spawner_module.show_floating_text("Inspire", Color(1.0, 0.85, 0.2), target_pos)


# ============================================================
# call_to_arms — 紧急从兵营类建筑瞬时生产一波单位
# ============================================================
static func call_to_arms(main_node: Node2D, _spawner_module: Node, _target_pos: Vector2, config: Dictionary) -> void:
	var search_radius: float = config.get("search_radius", 400.0)
	var center: Vector2 = config.get("center", _target_pos)
	var forced_count_per_building: int = config.get("count_per_building", 1)

	var triggered: int = 0
	for building in main_node.get_tree().get_nodes_in_group("enemy_buildings"):
		if not is_instance_valid(building):
			continue
		if building.is_dead():
			continue
		# 仅兵营类（BARRACKS=3, ARCHERY=5, MONASTERY=4, CASTLE=2）
		var btype: int = building.building_type
		if btype != 2 and btype != 3 and btype != 4 and btype != 5:
			continue
		if building.global_position.distance_to(center) > search_radius:
			continue
		# 强制生产 N 次（绕过冷却）
		for i in range(forced_count_per_building):
			if building.has_method("_spawn_produced_unit"):
				building._spawn_produced_unit()
				triggered += 1

	if _spawner_module != null and _spawner_module.has_method("show_floating_text") and triggered > 0:
		_spawner_module.show_floating_text("Call to Arms! (+%d)" % triggered, Color(1.0, 0.5, 0.3), center)


# ============================================================
# release_garrison — 强制释放兵营屯兵
# 依赖 building_garrison.force_release_all()（P4 同步新增）
# ============================================================
static func release_garrison(main_node: Node2D, _spawner_module: Node, _target_pos: Vector2, config: Dictionary) -> void:
	var search_radius: float = config.get("search_radius", 400.0)
	var center: Vector2 = config.get("center", _target_pos)

	var released: int = 0
	for building in main_node.get_tree().get_nodes_in_group("enemy_buildings"):
		if not is_instance_valid(building):
			continue
		if building.is_dead():
			continue
		if building.global_position.distance_to(center) > search_radius:
			continue
		var garrison = building.get_node_or_null("Garrison")
		if garrison == null or not garrison.has_method("force_release_all"):
			continue
		var before: int = garrison.get_garrison_count() if garrison.has_method("get_garrison_count") else 0
		garrison.force_release_all()
		released += before

	if _spawner_module != null and _spawner_module.has_method("show_floating_text") and released > 0:
		_spawner_module.show_floating_text("Release! (%d)" % released, Color(0.9, 0.6, 0.2), center)


# ============================================================
# shield — 给单个建筑加临时护盾（max_hp +N + 回满）
# ============================================================
static func shield(main_node: Node2D, _spawner_module: Node, _target_pos: Vector2, config: Dictionary) -> void:
	var target_building: Node = config.get("target_building", null)
	if target_building == null or not is_instance_valid(target_building):
		return
	var duration: float = config.get("duration", 12.0)
	var max_hp_bonus: float = config.get("max_hp_bonus", 0.5)
	if not target_building.has_node("HealthComponent"):
		return
	var health = target_building.get_node("HealthComponent")
	var old_max: int = health.max_hp
	var new_max: int = int(old_max * (1.0 + max_hp_bonus))
	health.max_hp = new_max
	health.hp = new_max
	if health.has_method("_update_hp_bar"):
		health._update_hp_bar()

	# 到期恢复
	var tree := main_node.get_tree()
	var timer: SceneTreeTimer = tree.create_timer(duration)
	timer.timeout.connect(func():
		if is_instance_valid(target_building) and target_building.has_node("HealthComponent"):
			var h = target_building.get_node("HealthComponent")
			h.max_hp = old_max
			h.hp = mini(h.hp, old_max)
			if h.has_method("_update_hp_bar"):
				h._update_hp_bar()
	)

	if _spawner_module != null and _spawner_module.has_method("show_floating_text"):
		_spawner_module.show_floating_text("Shield +%d%%" % int(max_hp_bonus * 100), Color(0.4, 0.7, 1.0), target_building.global_position)


# ============================================================
# 复用 skill_effects 的 _show_area_indicator
# ============================================================
static func _show_area_indicator(main_node: Node2D, pos: Vector2, radius: float, color: Color) -> void:
	SkillEffectsRef._show_area_indicator(main_node, pos, radius, color)
