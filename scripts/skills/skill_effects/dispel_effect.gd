extends "res://scripts/skills/skill_component.gd"
## 驱散：命中时清除目标所有增益 buff

func _apply_effect(caster, target) -> void:
	if target == null or not is_instance_valid(target):
		return
	if target.has_method("clear_buffs"):
		target.clear_buffs()
