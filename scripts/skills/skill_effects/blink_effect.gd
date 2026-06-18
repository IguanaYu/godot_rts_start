extends "res://scripts/skills/skill_component.gd"
## 闪现：追击时瞬移到目标附近

func _skill_process(delta: float) -> void:
	# 冷却递减由基类处理
	if cooldown_timer > 0.0:
		cooldown_timer = max(0.0, cooldown_timer - delta)


## 由 unit.gd _attack_process 在距离过远时调用
func try_blink(target_node) -> bool:
	if cooldown_timer > 0.0:
		return false
	if target_node == null or not is_instance_valid(target_node):
		return false

	# 扣蓝
	var u = get_parent()
	if u == null:
		return false
	if skill_resource.mana_cost > 0.0 and "mana" in u:
		if u.mana < skill_resource.mana_cost:
			return false
		u.mana = max(0.0, u.mana - skill_resource.mana_cost)

	var dir: Vector2 = u.global_position.direction_to(target_node.global_position)
	if dir.length_squared() < 0.001:
		return false

	u.global_position += dir * (skill_resource.cast_range if skill_resource.cast_range > 0.0 else 100.0)
	cooldown_timer = skill_resource.cooldown
	_show_skill_text(skill_resource.skill_name)
	return true
