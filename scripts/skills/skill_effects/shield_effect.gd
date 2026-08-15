extends "res://scripts/skills/skill_component.gd"
## 护盾：周期性给受伤友军加盾
## PR-6 视觉：施法者脚下蓝白波纹扩散；受影响单位的护盾环由 PR-3
## UnitVisualFeedback 轮询 _shield_hp 自动画出（零改动复用）

func _apply_effect(caster, target) -> void:
	if target == null or not is_instance_valid(target):
		return
	var shielded := false
	if target.has_method("set_shield_hp"):
		var shield_amt := 30
		if caster.stats_data and caster.stats_data.shield_amount > 0:
			shield_amt = caster.stats_data.shield_amount
		target.set_shield_hp(shield_amt)
		shielded = true
	elif "_shield_hp" in target:
		var shield_amt := 30
		if caster.stats_data and caster.stats_data.shield_amount > 0:
			shield_amt = caster.stats_data.shield_amount
		target._shield_hp = shield_amt
		shielded = true
	if shielded:
		# PR-6：目标脚下蓝白波纹标记"被加盾"
		SkillVisualController.play_release_ripple(
			target.global_position, SkillVisualController.COLOR_SHIELD, 50.0)
