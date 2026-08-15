extends "res://scripts/skills/skill_component.gd"
## 劝化：引导转化敌方单位
## 特殊：覆盖基类的 _skill_process 实现引导逻辑
## PR-6 视觉：引导期间金光柱连接 caster→target（beam 跟随移动）+
## 目标 blessed tint 随进度渐变；成功瞬间金色波纹 + 蓄力环收尾

const BeamScript := preload("res://scripts/effects/beam_effect.gd")

var _channel_target = null
var _channel_time: float = 0.0
var _scan_timer: float = 0.0
var _beam: Node2D = null
var _charge_handle: Dictionary = {}


func _ready() -> void:
	super._ready()
	uses_custom_process = true


func _exit_tree() -> void:
	_cleanup_channel_visual()


func _skill_process(delta: float) -> void:
	# 冷却递减
	if cooldown_timer > 0.0:
		cooldown_timer = max(0.0, cooldown_timer - delta)
		return

	var u = get_parent()
	if u == null:
		return

	# 无引导目标时扫描
	var target_dead = false
	if _channel_target != null and is_instance_valid(_channel_target):
		if _channel_target.has_method("is_dead") and _channel_target.is_dead():
			target_dead = true
	if _channel_target == null or not is_instance_valid(_channel_target) or target_dead:
		_stop_channel_visual()
		_channel_target = null
		_channel_time = 0.0
		_scan_timer += delta
		if _scan_timer >= 0.5:
			_scan_timer = 0.0
			_channel_target = _find_convert_target()
		return

	# 目标超出射程则放弃
	var dist: float = u.global_position.distance_to(_channel_target.global_position)
	var max_range: float = skill_resource.cast_range if skill_resource.cast_range > 0.0 else 200.0
	if dist > max_range:
		_stop_channel_visual()
		_channel_target = null
		_channel_time = 0.0
		return

	# 引导累加
	var channel_needed: float = 3.0
	if u.stats_data and u.stats_data.convert_channel_time > 0.0:
		channel_needed = u.stats_data.convert_channel_time
	_channel_time += delta
	# PR-6：引导视觉（beam + 蓄力环 + blessed 渐变）
	_update_channel_visual(u, _channel_target, _channel_time / channel_needed)
	if _channel_time >= channel_needed:
		var saved_target = _channel_target
		_do_convert(u, saved_target)
		# 统一入口：扣蓝(mana_cost=0 不扣) + 设冷却(cooldown=0) + 文字 + 信号
		activate(saved_target)
		_stop_channel_visual()
		# 成功瞬间：金色波纹 + 光柱
		SkillVisualController.play_release_ripple(
			saved_target.global_position, SkillVisualController.COLOR_CONVERT, 70.0)
		SkillVisualController.play_light_pillar(
			saved_target.global_position, SkillVisualController.COLOR_CONVERT, 0.5)
		SkillVisualController.play_screen_impact(saved_target.global_position, 4.0)
		_channel_target = null
		_channel_time = 0.0


## 引导视觉三件套：确保 beam 存在、进度环推进、blessed 渐变
func _update_channel_visual(caster, target, progress: float) -> void:
	if _beam == null or not is_instance_valid(_beam):
		_beam = Node2D.new()
		_beam.set_script(BeamScript)
		_beam.effect_id = &"heal_beam"
		_beam.color_override = SkillVisualController.COLOR_CONVERT
		_beam.duration_sec = 0.0  # 永续，由 _stop_channel_visual 回收
		_beam.follow_source = caster
		_beam.follow_target = target
		caster.get_tree().current_scene.add_child(_beam)
		_charge_handle = SkillVisualController.play_charging_circle(
			target.global_position, SkillVisualController.COLOR_CONVERT)
	if not _charge_handle.is_empty():
		_charge_handle.progress = progress
	# blessed tint 随进度渐变（转化完成后由 clear/转化流程接管）
	var fb = target.get_node_or_null("UnitVisualFeedback")
	if fb:
		fb.set_blessed(true, progress)


func _stop_channel_visual() -> void:
	_cleanup_channel_visual()
	_channel_time = 0.0


func _cleanup_channel_visual() -> void:
	if _beam != null and is_instance_valid(_beam):
		_beam.duration_sec = _beam._elapsed + 0.3  # 尾部渐隐 0.3s
	if not _charge_handle.is_empty():
		SkillVisualController.finish_charging_circle(_charge_handle)
		_charge_handle = {}
	_beam = null


func _find_convert_target():
	var u = get_parent()
	if u == null:
		return null
	var best = null
	var best_dist: float = 99999.0
	var max_range: float = skill_resource.cast_range if skill_resource.cast_range > 0.0 else 200.0
	for unit in _query_nearby_units(max_range):
		if not is_instance_valid(unit) or unit == u:
			continue
		if "is_dead" in unit and unit.is_dead():
			continue
		if "team" in unit and unit.team == u.team:
			continue
		if "is_stealthed" in unit and unit.has_method("is_stealthed") and unit.is_stealthed():
			continue
		var d: float = u.global_position.distance_to(unit.global_position)
		if d <= max_range and d < best_dist:
			best_dist = d
			best = unit
	return best


func _do_convert(caster, target) -> void:
	if target == null or not is_instance_valid(target) or target.is_dead():
		return

	# 调用 unit.gd 的 _convert_unit 方法（保留在 unit.gd 中）
	if caster.has_method("_convert_unit"):
		caster._convert_unit(target)
	else:
		# fallback：简单转化逻辑
		var old_group: String = "enemy_units" if target.team == 1 else "player_units"
		var new_group: String = "player_units" if target.team == 1 else "enemy_units"
		var new_alliance: int = 0 if target.team == 1 else 1
		if target.is_in_group(old_group):
			target.remove_from_group(old_group)
		target.alliance_id = new_alliance
		target.add_to_group(new_group)
		var new_parent_name: String = "PlayerUnits" if new_alliance == 0 else "EnemyUnits"
		var new_parent = caster.get_tree().current_scene.get_node_or_null(new_parent_name)
		if new_parent:
			var old_pos: Vector2 = target.global_position
			target.reparent(new_parent)
			target.global_position = old_pos
		var ai = target.get_node_or_null("EnemyAI")
		if ai:
			ai.queue_free()
		target.attack_target = null
		target.attack_command_source = 0
		if target.state == 4:  # ATTACK
			target.state = 0  # GUARD
	# 浮动文字由 activate() 统一处理
