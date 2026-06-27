extends Node
## 技能运行时组件基类（无 class_name，通过 preload + duck typing 使用）
##
## 子类 override _apply_effect() 实现具体技能效果。
## 需要每帧逻辑的子类 override _skill_process(delta)。

var skill_resource: Resource
var cooldown_timer: float = 0.0
var trigger_timer: float = 0.0
var uses_custom_process: bool = false  # 子类覆盖了 _skill_process 时设为 true
var _target = null

## 技能激活时发出，供 unit 监听做跨切面逻辑（扣钱/扣血/日志等）
signal skill_activated(target)


func _ready() -> void:
	if skill_resource == null:
		push_error("SkillComponent has no skill_resource")
		return


## 能否激活（检查冷却+蓝量）
func can_activate() -> bool:
	if cooldown_timer > 0.0:
		return false
	if skill_resource.mana_cost > 0.0:
		var u = get_parent()
		if u and "mana" in u and u.mana < skill_resource.mana_cost:
			return false
	return true


## 寻找目标（按 target_type 选择）
func find_target():
	match skill_resource.target_type:
		0:  # ENEMY_NEAREST
			return _find_nearest_enemy()
		1:  # ALLY_NEAREST_WOUNDED
			return _find_nearest_wounded_ally()
		2:  # SELF
			return get_parent()
		3:  # CURRENT_ATTACK_TARGET
			var u = get_parent()
			return u.attack_target if u and "attack_target" in u else null
		4:  # ENEMY_ATTACKING_ALLY
			return _find_enemy_attacking_ally()
		5:  # ALLY_LOWEST_HP
			return _find_nearest_wounded_ally()
	return null


## 释放技能
func activate(target) -> void:
	if not can_activate():
		return
	if target == null or not is_instance_valid(target):
		return

	# 扣蓝
	var u = get_parent()
	if u and "mana" in u and skill_resource.mana_cost > 0.0:
		u.mana = max(0.0, u.mana - skill_resource.mana_cost)

	# 设冷却
	cooldown_timer = skill_resource.cooldown

	# 跨切面信号：供 unit 监听做扣钱/扣血/日志等
	skill_activated.emit(target)

	# 按交付方式执行
	match skill_resource.delivery_type:
		0:  # PROJECTILE
			_deliver_projectile(target)
		1:  # INSTANT_SELF
			_apply_effect(u, u)
		2:  # INSTANT_RANGE
			_apply_effect(u, target)

	# 浮动文字
	_show_skill_text(skill_resource.skill_name)


## 每帧处理（由 unit.gd 的 _physics_process 调用）
## 只做冷却递减，PERIODIC_SCAN 触发由 unit.gd _skill_ai_tick() 统一处理
func _skill_process(delta: float) -> void:
	if cooldown_timer > 0.0:
		cooldown_timer = max(0.0, cooldown_timer - delta)


## 弹道交付
func _deliver_projectile(target) -> void:
	var u = get_parent()
	if u == null:
		return
	var tree = u.get_tree()
	if tree == null:
		return
	var spawner = tree.current_scene.get("spawner_module")
	if spawner == null:
		return

	var target_pos = target.global_position if target.has_method("get_global_position") else u.global_position
	var captured_target = target
	var callback = func():
		if not is_instance_valid(u):
			return
		var final_target = captured_target
		if is_instance_valid(captured_target) and (not "is_dead" in captured_target or not captured_target.is_dead()):
			final_target = captured_target
		_apply_effect(u, final_target)

	spawner.spawn_projectile(
		skill_resource.projectile_data,
		u.global_position,
		target_pos,
		null, u, 0,
		skill_resource.effect_scene,
		callback
	)


## 实际效果（由子类重写）
func _apply_effect(caster, target) -> void:
	pass


## 显示技能名浮动文字
func _show_skill_text(name: String) -> void:
	var u = get_parent()
	if not is_instance_valid(u):
		return
	var ft = Node2D.new()
	ft.set_script(preload("res://scripts/effects/floating_text.gd"))
	u.get_tree().current_scene.add_child(ft)
	ft.setup(name, Color(0.3, 1.0, 0.3), u.global_position + Vector2(0, -40))


# ============== 通用目标搜索工具 ==============

## 用 UnitGrid 查询附近单位（替代全量遍历）
func _query_nearby_units(search_range: float) -> Array:
	var u = get_parent()
	if u == null:
		return []
	return UnitGrid.query_neighbors(u.global_position, search_range)


func _find_nearest_enemy():
	var u = get_parent()
	if u == null:
		return null
	var search_range = skill_resource.cast_range if skill_resource.cast_range > 0.0 else 300.0
	var best = null
	var best_dist = search_range
	for unit in _query_nearby_units(search_range):
		if not is_instance_valid(unit) or unit == u:
			continue
		if "is_dead" in unit and unit.is_dead():
			continue
		if "team" in unit and unit.team == u.team:
			continue
		if "is_stealthed" in unit and unit.has_method("is_stealthed") and unit.is_stealthed():
			continue
		var d = u.global_position.distance_to(unit.global_position)
		if d <= best_dist:
			best_dist = d
			best = unit
	return best


## 找受伤友军：优先血量百分比最低的，同百分比选最近的
func _find_nearest_wounded_ally():
	var u = get_parent()
	if u == null:
		return null
	var search_range = skill_resource.cast_range if skill_resource.cast_range > 0.0 else 300.0
	var best = null
	var best_hp_ratio = 1.0
	var best_dist = search_range
	for unit in _query_nearby_units(search_range):
		if not is_instance_valid(unit) or unit == u:
			continue
		if "is_dead" in unit and unit.is_dead():
			continue
		if "team" in unit and unit.team != u.team:
			continue
		if "health" not in unit or unit.health == null:
			continue
		if unit.health.hp >= unit.health.max_hp:
			continue
		var hp_ratio = float(unit.health.hp) / float(unit.health.max_hp)
		var d = u.global_position.distance_to(unit.global_position)
		# 血量百分比更低，或同百分比但更近
		if hp_ratio < best_hp_ratio or (hp_ratio == best_hp_ratio and d < best_dist):
			best_hp_ratio = hp_ratio
			best_dist = d
			best = unit
	return best


## 找正在攻击友军的敌人（嘲讽优先目标）
func _find_enemy_attacking_ally():
	var u = get_parent()
	if u == null:
		return null
	var search_range = skill_resource.cast_range if skill_resource.cast_range > 0.0 else 300.0
	var best = null
	var best_dist = search_range
	for unit in _query_nearby_units(search_range):
		if not is_instance_valid(unit) or unit == u:
			continue
		if "is_dead" in unit and unit.is_dead():
			continue
		if "team" in unit and unit.team == u.team:
			continue
		if "is_stealthed" in unit and unit.has_method("is_stealthed") and unit.is_stealthed():
			continue
		# 检查这个敌人是否正在攻击友军
		if "attack_target" not in unit or unit.attack_target == null:
			continue
		if not is_instance_valid(unit.attack_target):
			continue
		if "team" in unit.attack_target and unit.attack_target.team != u.team:
			continue  # 它在攻击敌人，不是友军
		var d = u.global_position.distance_to(unit.global_position)
		if d <= best_dist:
			best_dist = d
			best = unit
	# 没找到正在攻击友军的敌人，fallback 到最近敌人
	if best == null:
		return _find_nearest_enemy()
	return best
