extends "res://scripts/skills/skill_component.gd"
## 护盾：周期性给受伤友军加盾

func _apply_effect(caster, target) -> void:
	if target == null or not is_instance_valid(target):
		return
	if target.has_method("set_shield_hp"):
		var shield_amt := 30
		if caster.stats_data and caster.stats_data.shield_amount > 0:
			shield_amt = caster.stats_data.shield_amount
		target.set_shield_hp(shield_amt)
	elif "_shield_hp" in target:
		var shield_amt := 30
		if caster.stats_data and caster.stats_data.shield_amount > 0:
			shield_amt = caster.stats_data.shield_amount
		target._shield_hp = shield_amt
