extends "res://scripts/skills/skill_component.gd"
## 劝化：引导转化敌方单位
## 特殊：覆盖基类的 _skill_process 实现引导逻辑

var _channel_target = null
var _channel_time: float = 0.0
var _scan_timer: float = 0.0


func _ready() -> void:
	super._ready()
	uses_custom_process = true


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
		_channel_target = null
		_channel_time = 0.0
		return

	# 引导累加
	var channel_needed: float = 3.0
	if u.stats_data and u.stats_data.convert_channel_time > 0.0:
		channel_needed = u.stats_data.convert_channel_time
	_channel_time += delta
	if _channel_time >= channel_needed:
		_do_convert(u, _channel_target)
		_channel_target = null
		_channel_time = 0.0
		cooldown_timer = skill_resource.cooldown


func _find_convert_target():
	var u = get_parent()
	if u == null:
		return null
	var best = null
	var best_dist: float = 99999.0
	var max_range: float = skill_resource.cast_range if skill_resource.cast_range > 0.0 else 200.0
	for unit in _get_all_units():
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

	_show_skill_text(skill_resource.skill_name)
