extends "res://scripts/skills/skill_component.gd"
## 嘲讽：周期性强制周围敌人攻击自己
## PR-6 视觉：施法者脚下红波纹扩散 + 屏幕小震动；被嘲讽目标的 aggro_line
## 由 unit.gd::_update_aggro_line 在 _taunt_expire_timer 期间自动变红

const AggroComp := preload("res://scripts/core/aggro_component.gd")

func _apply_effect(caster, target) -> void:
	if target == null or not is_instance_valid(target):
		return
	# 优先用威胁值系统：让目标的 AggroComponent 把嘲讽者设为最高威胁
	var aggro = target.get_node_or_null("EnemyAI/AggroComponent")
	if aggro:
		aggro.add_threat(caster, AggroComp.TAUNT_THREAT, AggroComp.ThreatSource.TAUNT)
	# 兼容保留：直接强制 attack_target + 设 _taunt_expire_timer（无 AggroComponent 的目标也生效）
	var dur: float = skill_resource.cooldown
	if dur <= 0.0:
		dur = 2.0
	if target.has_method("force_attack_target"):
		target.force_attack_target(caster, dur)
	# 通知 EnemyAI 嘲讽生效：刷新入场锁，强制切目标到嘲讽者
	var ai = target.get_node_or_null("EnemyAI")
	if ai and ai.has_method("on_taunted"):
		ai.on_taunted(caster, dur)
	# PR-6：施法者脚下红色波纹 + 小屏震（嘲讽为低强度技能，不加色差）
	SkillVisualController.play_release_ripple(
		caster.global_position, SkillVisualController.COLOR_TAUNT, 110.0)
	SkillVisualController.play_screen_impact(caster.global_position, 3.0)
