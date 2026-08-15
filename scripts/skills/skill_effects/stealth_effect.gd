extends "res://scripts/skills/skill_component.gd"
## 隐身：闲置时自动隐身
## PR-6 视觉：进入/退出隐身瞬间脚下紫波纹（状态切换沿检测）

var _reveal_timer: float = 0.0
var _was_stealthed := false


func _skill_process(delta: float) -> void:
	var u = get_parent()
	if u == null:
		return
	# 从 stats_data 读取隐身配置
	var reveal_dur := 2.0
	if u.stats_data and u.stats_data.stealth_reveal_duration > 0.0:
		reveal_dur = u.stats_data.stealth_reveal_duration

	if _reveal_timer > 0.0:
		_reveal_timer = max(0.0, _reveal_timer - delta)

	var stealthed := is_stealthed()
	# PR-6：状态切换瞬间放紫波纹（进入=消散感，退出=现形感）
	if stealthed != _was_stealthed:
		SkillVisualController.play_release_ripple(
			u.global_position, SkillVisualController.COLOR_STEALTH, 40.0)
		_was_stealthed = stealthed
	if stealthed:
		u.modulate.a = 0.35
	else:
		u.modulate.a = 1.0


func is_stealthed() -> bool:
	return _reveal_timer <= 0.0


func reveal_temporarily() -> void:
	var dur := 2.0
	var u = get_parent()
	if u and u.stats_data and u.stats_data.stealth_reveal_duration > 0.0:
		dur = u.stats_data.stealth_reveal_duration
	_reveal_timer = dur
