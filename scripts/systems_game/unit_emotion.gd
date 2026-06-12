extends Node
## 单位情绪系统：敌方单位低血量时触发特殊状态
## 挂载为敌方单位子节点，命名为 "Emotion"

enum Emotion { NONE, RAGE, ROAR, CALL_HELP, SEEK_GARRISON, FEAR }

const StatSetClass := preload("res://scripts/stats/stat_set.gd")

@export var trigger_hp_threshold: float = 0.5
@export var area_cooldown: float = 10.0
@export var area_radius: float = 150.0
@export var personal_cooldown: float = 30.0
@export var emotion_duration: float = 8.0

# ── 内部状态 ──
var _emotion_disabled: bool = false
var current_emotion: Emotion = Emotion.NONE
var emotion_timer: float = 0.0
var personal_cooldowns: Dictionary = {}  # {Emotion: remaining_time}
var _unit: CharacterBody2D
var _has_triggered: bool = false
var _last_attacker = null
# 求救专用
var _call_help_secondary: bool = false
var _call_help_wait: float = 0.0
# 求助专用
var _seek_target_building = null
# 恐惧专用
var _flee_target: Vector2 = Vector2.ZERO

# ── 区域CD 全局记录 ──
# 静态数组记录所有触发点 {position: Vector2, timestamp: float}
static var _area_triggers: Array[Dictionary] = []


func _ready() -> void:
	_unit = get_parent() as CharacterBody2D
	if _unit == null:
		push_warning("[Emotion] _ready: parent is null")
		return
	if _unit.get("team") != 1:  # Team.ENEMY = 1
		_emotion_disabled = true
		push_warning("[Emotion] disabled for team=%d" % _unit.get("team"))
		return
	push_warning("[Emotion] ACTIVE on enemy unit type=%d" % _unit.get("unit_type"))


func _process(delta: float) -> void:
	if _emotion_disabled:
		return
	if _unit == null or not is_instance_valid(_unit) or _unit.is_dead():
		return

	# 更新个人CD
	var expired_keys := []
	for key in personal_cooldowns:
		personal_cooldowns[key] -= delta
		if personal_cooldowns[key] <= 0.0:
			expired_keys.append(key)
	for k in expired_keys:
		personal_cooldowns.erase(k)

	# 情绪行为执行
	if current_emotion != Emotion.NONE:
		emotion_timer -= delta
		_process_emotion(delta)
		if emotion_timer <= 0.0:
			_end_emotion()
		return

	# 触发检查
	if not _has_triggered:
		var hp_ratio: float = _unit.health.hp / float(_unit.health.max_hp)
		if hp_ratio <= trigger_hp_threshold:
			_try_trigger_emotion()


# ============================================================
# 触发逻辑
# ============================================================
func _try_trigger_emotion() -> void:
	_has_triggered = true
	push_warning("[Emotion] _try_trigger called, hp=%.1f%%" % (_unit.health.hp / float(_unit.health.max_hp) * 100))

	# 1. 检查区域CD
	if _area_on_cooldown():
		push_warning("[Emotion] blocked by area CD")
		return

	# 2. 计算上下文
	var nearby_allies := _count_nearby_allies(300.0)
	var far_allies := _count_nearby_allies(800.0)
	var has_nearby_building := _has_nearby_garrison(500.0)
	var has_far_elite := _has_nearby_elite(500.0)
	var is_elite := _is_unit_elite()

	# 3. 计算各情绪权重
	var weights: Dictionary = {}

	# 愤怒：周围无友军 → 高；有精英+普通单位 → 0；精英更容易触发
	if has_far_elite and not is_elite:
		weights[Emotion.RAGE] = 0.0
	else:
		weights[Emotion.RAGE] = max(0.5, 3.0 - nearby_allies * 0.5) * (2.0 if is_elite else 1.0)

	# 咆哮：周围友军多 → 高
	weights[Emotion.ROAR] = 0.5 + nearby_allies * 0.8

	# 求救：近处友军少 + 远处友军多 → 高
	var call_help_factor: float = max(0.0, float(far_allies) - float(nearby_allies))
	weights[Emotion.CALL_HELP] = call_help_factor * 0.6

	# 求助：有建筑 + 近处友军少 → 高
	if has_nearby_building:
		weights[Emotion.SEEK_GARRISON] = max(0.3, 2.0 - nearby_allies * 0.5)
	else:
		weights[Emotion.SEEK_GARRISON] = 0.0

	# 恐惧：近处友军多 → 低
	weights[Emotion.FEAR] = max(0.1, 1.5 - nearby_allies * 0.3)

	# 4. 过滤掉个人CD中的情绪
	var filtered_weights: Dictionary = {}
	var total_weight: float = 0.0
	for key in weights:
		if personal_cooldowns.get(key, 0.0) <= 0.0 and weights[key] > 0.0:
			filtered_weights[key] = weights[key]
			total_weight += weights[key]

	if total_weight <= 0.0:
		return

	# 5. 加权随机选择
	var chosen := _weighted_random(filtered_weights, total_weight)
	if chosen == Emotion.NONE:
		return

	# 6. 激活
	_activate_emotion(chosen)


func _weighted_random(weights: Dictionary, total: float) -> Emotion:
	var roll := randf() * total
	var accum: float = 0.0
	for key in weights:
		accum += weights[key]
		if roll <= accum:
			return key as Emotion
	return Emotion.NONE


func _activate_emotion(emotion: Emotion) -> void:
	current_emotion = emotion
	emotion_timer = _get_emotion_duration(emotion)
	personal_cooldowns[emotion] = personal_cooldown
	_register_area_trigger()
	var emotion_names := ["无", "愤怒", "咆哮", "求救", "求助", "恐惧"]
	var emotion_colors := [Color.WHITE, Color.RED, Color.ORANGE, Color.YELLOW, Color.CYAN, Color.GRAY]
	push_warning("[Emotion] %s triggered!" % emotion_names[emotion])
	_show_floating_emotion(emotion_names[emotion], emotion_colors[emotion])

	match emotion:
		Emotion.RAGE:
			_start_rage()
		Emotion.ROAR:
			_start_roar()
		Emotion.CALL_HELP:
			_start_call_help()
		Emotion.SEEK_GARRISON:
			_start_seek_garrison()
		Emotion.FEAR:
			_start_fear()


func _get_emotion_duration(emotion: Emotion) -> float:
	match emotion:
		Emotion.RAGE:
			return 8.0
		Emotion.ROAR:
			return 0.5  # 瞬发
		Emotion.CALL_HELP:
			return 5.0
		Emotion.SEEK_GARRISON:
			return 15.0  # 持续到到达建筑
		Emotion.FEAR:
			return 3.0
		_:
			return 0.0


func _end_emotion() -> void:
	current_emotion = Emotion.NONE
	emotion_timer = 0.0
	_call_help_secondary = false
	_call_help_wait = 0.0
	_seek_target_building = null


# ============================================================
# 情绪行为
# ============================================================
func _process_emotion(delta: float) -> void:
	match current_emotion:
		Emotion.CALL_HELP:
			_process_call_help(delta)
		Emotion.SEEK_GARRISON:
			_process_seek_garrison(delta)
		Emotion.FEAR:
			_process_fear(delta)


# ── 愤怒 ──
func _start_rage() -> void:
	# 回满血
	_unit.health.heal(_unit.health.max_hp - _unit.health.hp)
	# 攻速提升 buff
	_unit.apply_buff("attack_melee", 0.3)
	# 视觉：红色闪烁
	_show_emotion_effect(Color(1.0, 0.2, 0.2, 0.6))


# ── 咆哮 ──
func _start_roar() -> void:
	# 随机选一种效果
	var roll := randi() % 3
	match roll:
		0:  # 群体攻速+攻击力
			_buff_nearby_allies("attack_melee", 0.2)
			_buff_nearby_allies("range_bonus", 20.0)
		1:  # 群体回血
			_heal_nearby_allies(15)
		2:  # 远程单位加攻速
			_buff_ranged_allies("range_bonus", 25.0)
	_show_emotion_effect(Color(1.0, 0.85, 0.2, 0.6))


func _buff_nearby_allies(buff_type: String, value: float) -> void:
	var range := 200.0
	for u in get_tree().get_nodes_in_group("enemy_units"):
		if u == _unit or u.is_dead():
			continue
		if _unit.global_position.distance_to(u.global_position) <= range:
			u.apply_buff(buff_type, value)


func _heal_nearby_allies(amount: int) -> void:
	var range := 200.0
	for u in get_tree().get_nodes_in_group("enemy_units"):
		if u.is_dead():
			continue
		if _unit.global_position.distance_to(u.global_position) <= range:
			if u.health.hp < u.health.max_hp:
				u.health.heal(amount)


func _buff_ranged_allies(buff_type: String, value: float) -> void:
	var range := 200.0
	for u in get_tree().get_nodes_in_group("enemy_units"):
		if u == _unit or u.is_dead():
			continue
		var utype: int = u.get("unit_type")
		# ARCHER = 1, MONK = 3 为远程
		if utype not in [1, 3]:
			continue
		if _unit.global_position.distance_to(u.global_position) <= range:
			u.apply_buff(buff_type, value)


# ── 求救 ──
func _start_call_help() -> void:
	# 第一次大范围呼唤
	_call_nearby_allies_to_position(_unit.global_position, 800.0)
	# 自己往后退
	if _last_attacker and is_instance_valid(_last_attacker):
		var flee_dir: Vector2 = (_unit.global_position - _last_attacker.global_position).normalized()
		var flee_pos: Vector2 = _unit.global_position + flee_dir * 150.0
		_unit.move_to(flee_pos)
	_call_help_secondary = false
	_call_help_wait = 2.5  # 2.5秒后再呼唤一次
	_show_emotion_effect(Color(1.0, 1.0, 0.2, 0.6))


func _process_call_help(delta: float) -> void:
	if not _call_help_secondary:
		_call_help_wait -= delta
		if _call_help_wait <= 0.0:
			_call_help_secondary = true
			# 第二次呼唤
			_call_nearby_allies_to_position(_unit.global_position, 800.0)


func _call_nearby_allies_to_position(pos: Vector2, range: float) -> void:
	for u in get_tree().get_nodes_in_group("enemy_units"):
		if u == _unit or u.is_dead():
			continue
		if pos.distance_to(u.global_position) <= range:
			var ai = u.get_node_or_null("EnemyAI")
			if ai and ai.has_method("start_wave_attack"):
				ai.start_wave_attack(pos)


# ── 求助（找驻军建筑）──
func _start_seek_garrison() -> void:
	_seek_target_building = _find_nearest_garrison_building()
	if _seek_target_building == null:
		# 没有驻军建筑，切换为恐惧
		_end_emotion()
		_activate_emotion(Emotion.FEAR)
		return
	# 走向建筑
	_unit.move_to(_seek_target_building.global_position)
	_show_emotion_effect(Color(0.3, 0.7, 1.0, 0.6))


func _process_seek_garrison(delta: float) -> void:
	if _seek_target_building == null or not is_instance_valid(_seek_target_building):
		_end_emotion()
		return
	var dist := _unit.global_position.distance_to(_seek_target_building.global_position)
	if dist <= 50.0:
		# 到达建筑，触发释放
		var garrison = _seek_target_building.get_node_or_null("Garrison")
		if garrison and garrison.has_method("alert_from_ally"):
			garrison.alert_from_ally()
		_end_emotion()
	else:
		# 继续移动
		_unit.move_to(_seek_target_building.global_position)


func _find_nearest_garrison_building() -> Node2D:
	var closest = null
	var closest_dist: float = INF
	for b in get_tree().get_nodes_in_group("enemy_buildings"):
		if b.is_dead():
			continue
		var garrison_node = b.get_node_or_null("Garrison")
		if garrison_node == null:
			continue
		if garrison_node.get_garrison_count() <= 0:
			continue
		var dist := _unit.global_position.distance_to(b.global_position)
		if dist < closest_dist:
			closest = b
			closest_dist = dist
	return closest


# ── 恐惧 ──
func _start_fear() -> void:
	# 远离攻击者方向
	if _last_attacker and is_instance_valid(_last_attacker):
		var flee_dir: Vector2 = (_unit.global_position - _last_attacker.global_position).normalized()
		_flee_target = _unit.global_position + flee_dir * 200.0
	else:
		var angle := randf() * TAU
		_flee_target = _unit.global_position + Vector2(cos(angle), sin(angle)) * 200.0
	_unit.move_to(_flee_target)
	_show_emotion_effect(Color(0.5, 0.5, 0.5, 0.6))


func _process_fear(_delta: float) -> void:
	# 持续逃跑
	var dist := _unit.global_position.distance_to(_flee_target)
	if dist < 10.0:
		# 已到达逃跑点，再选一个方向
		var angle := randf() * TAU
		_flee_target = _unit.global_position + Vector2(cos(angle), sin(angle)) * 150.0
		_unit.move_to(_flee_target)


# ============================================================
# 视觉特效
# ============================================================
func _show_emotion_effect(color: Color) -> void:
	# 简单的颜色闪烁，用 unit 的 shader material
	if _unit.has_method("apply_buff"):
		# 利用已有的 shader 系统做闪烁
		pass  # TODO: 后续可以加表情图标或光环特效


func _show_floating_emotion(text: String, color: Color) -> void:
	var ft := Node2D.new()
	ft.set_script(load("res://scripts/effects/floating_text.gd"))
	get_tree().current_scene.add_child(ft)
	ft.setup(text, color, _unit.global_position + Vector2(0, -50))


# ============================================================
# 上下文检测
# ============================================================
func _count_nearby_allies(range: float) -> int:
	var count := 0
	for u in get_tree().get_nodes_in_group("enemy_units"):
		if u == _unit or u.is_dead():
			continue
		if _unit.global_position.distance_to(u.global_position) <= range:
			count += 1
	return count


func _has_nearby_garrison(range: float) -> bool:
	for b in get_tree().get_nodes_in_group("enemy_buildings"):
		if b.is_dead():
			continue
		var garrison_node = b.get_node_or_null("Garrison")
		if garrison_node == null:
			continue
		if _unit.global_position.distance_to(b.global_position) <= range:
			return true
	return false


func _has_nearby_elite(range: float) -> bool:
	for u in get_tree().get_nodes_in_group("enemy_units"):
		if u == _unit or u.is_dead():
			continue
		if not _is_unit_elite_check(u):
			continue
		if _unit.global_position.distance_to(u.global_position) <= range:
			return true
	return false


func _is_unit_elite() -> bool:
	return _is_unit_elite_check(_unit)


func _is_unit_elite_check(u) -> bool:
	# 通过 scale 判断是否精英（scale >= 1.5 为精英）
	var sx: float = u.get("sprite_scale_x")
	return sx >= 1.5


# ============================================================
# 区域CD
# ============================================================
func _register_area_trigger() -> void:
	_area_triggers.append({
		"position": _unit.global_position,
		"timestamp": Time.get_ticks_msec() / 1000.0,
	})


func _area_on_cooldown() -> bool:
	var now := Time.get_ticks_msec() / 1000.0
	var my_pos := _unit.global_position
	# 清理过期记录
	var valid: Array[Dictionary] = []
	for record in _area_triggers:
		if now - record.timestamp > area_cooldown:
			continue
		valid.append(record)
	_area_triggers = valid
	# 检查范围内是否有记录
	for record in _area_triggers:
		if my_pos.distance_to(record.position) <= area_radius:
			return true
	return false


# ============================================================
# 外部接口
# ============================================================
func is_emotion_active() -> bool:
	return current_emotion != Emotion.NONE


func get_current_emotion() -> Emotion:
	return current_emotion


## 记录攻击者（由 enemy_ai 在 on_attacked 时调用）
func set_last_attacker(attacker) -> void:
	_last_attacker = attacker


func _write_log(msg: String) -> void:
	var f := FileAccess.open("user://emotion_debug.log", FileAccess.WRITE_READ)
	if f:
		f.seek_end()
		f.store_line(msg)
		f.close()
