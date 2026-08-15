extends "res://scripts/skills/skill_component.gd"
## 驱散：命中时清除目标所有增益 buff
## PR-6 视觉：白色波纹（施法者）+ 目标白闪（hit_flash 白）+ 停目标 buff 视觉

func _apply_effect(caster, target) -> void:
	if target == null or not is_instance_valid(target):
		return
	if target.has_method("clear_buffs"):
		target.clear_buffs()
	# PR-6 视觉三件套：白波纹 + 目标白闪 + 停 buff 视觉
	SkillVisualController.play_release_ripple(
		target.global_position, SkillVisualController.COLOR_DISPEL, 60.0)
	if target.has_method("_play_hit_flash"):
		target._play_hit_flash()
	var fb = target.get_node_or_null("UnitVisualFeedback")
	if fb:
		fb.set_slow(false)
		fb.set_poison(false)
		fb.set_enraged(false)
		fb.set_blessed(false)
	# 净化感粒子
	ParticlePool.spawn("energy_fog", target.global_position)
