extends "res://scripts/skills/skill_component.gd"
## 召唤：攻击命中时召唤骷髅
## delivery_type=INSTANT_SELF，activate() 调用 _apply_effect(caster, caster)
## 实际召唤逻辑委托给 unit._try_summon_minion()

func _apply_effect(caster, target) -> void:
	if caster.has_method("_try_summon_minion"):
		caster._try_summon_minion()
