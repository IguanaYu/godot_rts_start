extends "res://scripts/skills/skill_component.gd"
## 嘲讽：周期性强制周围敌人攻击自己

func _apply_effect(caster, target) -> void:
	if target == null or not is_instance_valid(target):
		return
	if target.has_method("force_attack_target"):
		var dur: float = skill_resource.cooldown
		if dur <= 0.0:
			dur = 2.0
		target.force_attack_target(caster, dur)
