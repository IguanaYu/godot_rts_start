extends "res://scripts/skills/skill_component.gd"
## 嘲讽：周期性强制周围敌人攻击自己

const AggroComp := preload("res://scripts/core/aggro_component.gd")

func _apply_effect(caster, target) -> void:
	if target == null or not is_instance_valid(target):
		return
	# 优先用威胁值系统：让目标的 AggroComponent 把嘲讽者设为最高威胁
	var aggro = target.get_node_or_null("EnemyAI/AggroComponent")
	if aggro:
		aggro.add_threat(caster, AggroComp.TAUNT_THREAT, AggroComp.ThreatSource.TAUNT)
	# 兼容保留：直接强制 attack_target + 设 _taunt_expire_timer（无 AggroComponent 的目标也生效）
	if target.has_method("force_attack_target"):
		var dur: float = skill_resource.cooldown
		if dur <= 0.0:
			dur = 2.0
		target.force_attack_target(caster, dur)
