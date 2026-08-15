extends "res://scripts/skills/skill_component.gd"
## 闪现：追击时瞬移到目标附近
## delivery_type=INSTANT_RANGE，activate() 调用 _apply_effect(caster, target)
## PR-6 视觉：起点 dissolve 消散 + 紫波纹 → 紫色 beam 光迹 → 终点紫波纹 + dissolve 出现

const BeamScript := preload("res://scripts/effects/beam_effect.gd")

func _apply_effect(caster, target) -> void:
	if target == null or not is_instance_valid(target):
		return
	var dir: Vector2 = caster.global_position.direction_to(target.global_position)
	if dir.length_squared() < 0.001:
		return
	var blink_dist: float = skill_resource.cast_range if skill_resource.cast_range > 0.0 else 100.0
	var origin: Vector2 = caster.global_position
	var dest: Vector2 = origin + dir * blink_dist
	# 起点视觉：消散 + 紫波纹
	if caster.has_method("play_dissolve_out"):
		caster.play_dissolve_out(0.25)
	SkillVisualController.play_release_ripple(origin, SkillVisualController.COLOR_BLINK, 46.0)
	# 瞬移
	caster.global_position = dest
	# 终点视觉：紫波纹 + dissolve 出现
	SkillVisualController.play_release_ripple(dest, SkillVisualController.COLOR_BLINK, 46.0)
	if caster.has_method("play_dissolve_in"):
		caster.play_dissolve_in(0.3)
	# 紫色光迹（life_leech 风格流动光点改紫，0.35s）
	var beam := Node2D.new()
	beam.set_script(BeamScript)
	beam.effect_id = &"life_leech"
	beam.source_pos = origin
	beam.target_pos = dest
	beam.duration_sec = 0.35
	beam.color_override = SkillVisualController.COLOR_BLINK
	caster.get_tree().current_scene.add_child(beam)
	SkillVisualController.play_screen_impact(dest, 4.0)
