extends "res://scripts/skills/skill_component.gd"
## 闪现：追击时瞬移到目标附近
## delivery_type=INSTANT_RANGE，activate() 调用 _apply_effect(caster, target)

func _apply_effect(caster, target) -> void:
	if target == null or not is_instance_valid(target):
		return
	var dir: Vector2 = caster.global_position.direction_to(target.global_position)
	if dir.length_squared() < 0.001:
		return
	var blink_dist: float = skill_resource.cast_range if skill_resource.cast_range > 0.0 else 100.0
	caster.global_position += dir * blink_dist
