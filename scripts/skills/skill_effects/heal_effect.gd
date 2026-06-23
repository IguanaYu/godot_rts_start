extends "res://scripts/skills/skill_component.gd"
## 治疗：周期性给最近受伤友军加血
## 替换原来的 HEAL 状态机

var _heal_target = null
var _target_timer: float = 0.0


func _ready() -> void:
	super._ready()
	uses_custom_process = true


func _skill_process(delta: float) -> void:
	# 冷却递减
	if cooldown_timer > 0.0:
		cooldown_timer = max(0.0, cooldown_timer - delta)
		return

	var u = get_parent()
	if u == null:
		return

	# 验证当前目标
	if _heal_target == null or not is_instance_valid(_heal_target) or _heal_target.is_dead():
		_heal_target = null
		# 扫描受伤友军
		_target_timer += delta
		if _target_timer >= 0.5:
			_target_timer = 0.0
			_heal_target = find_target()
		return

	# 目标满血了
	if _heal_target.health and _heal_target.health.hp >= _heal_target.health.max_hp:
		_heal_target = null
		return

	# 距离检查
	var heal_range := 120.0
	if u.stats_data and u.stats_data.heal_range > 0.0:
		heal_range = u.stats_data.heal_range

	var dist: float = u.global_position.distance_to(_heal_target.global_position)
	if dist <= heal_range:
		# 治疗
		var heal_amt := 8
		if u.stats_data and u.stats_data.heal_amount > 0:
			heal_amt = u.stats_data.heal_amount
		if _heal_target.has_method("heal"):
			_heal_target.heal(heal_amt)
		elif _heal_target.health:
			_heal_target.health.heal(heal_amt)

		# 审判官：治疗时清除友军 debuff
		if u.stats_data and u.stats_data.cleanse_on_heal and _heal_target.has_method("cleanse_debuffs"):
			_heal_target.cleanse_debuffs()

		var heal_cd := 1.0
		if u.stats_data and u.stats_data.heal_cooldown > 0.0:
			heal_cd = u.stats_data.heal_cooldown
		cooldown_timer = heal_cd
		_show_skill_text(skill_resource.skill_name)
	else:
		# 朝目标移动（设置导航目标，但不改变 unit 状态）
		if u.has_method("move_to") and u.nav_agent:
			u.nav_agent.target_position = _heal_target.global_position
