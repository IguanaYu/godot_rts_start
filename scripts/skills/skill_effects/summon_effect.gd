extends "res://scripts/skills/skill_component.gd"
## 召唤：攻击时概率发射弹道，落地召唤骷髅
## 实际召唤逻辑委托给 unit._try_summon_minion()

func _skill_process(delta: float) -> void:
	# 冷却递减（召唤冷却为0，但保留通用逻辑）
	if cooldown_timer > 0.0:
		cooldown_timer = max(0.0, cooldown_timer - delta)


## 由 unit.gd _perform_attack 在攻击命中后调用
func try_summon() -> bool:
	var u = get_parent()
	if u == null:
		return false
	if not u.has_method("_try_summon_minion"):
		return false
	u._try_summon_minion()
	return true
