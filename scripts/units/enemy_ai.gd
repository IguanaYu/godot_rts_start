extends Node2D
## 敌方 AI：巡逻/追击/攻击/波次攻击
## 通过类型化引用直接调用 Unit 方法（无字符串调用）

enum AIState { PATROL, CHASE, ATTACK, WAVE_ATTACK, RETURN_HOME }

const SCAN_THROTTLE_FRAMES: int = 6
const AggroComp := preload("res://scripts/core/aggro_component.gd")
const FloatingTextScript := preload("res://scripts/effects/floating_text.gd")

@export var patrol_radius: float = 150.0
@export var vision_range: float = 250.0
@export var leash_range: float = 400.0      # 最大追击距离（距 patrol_center）

var ai_state: AIState = AIState.PATROL
var patrol_center: Vector2
var patrol_target: Vector2
var patrol_wait_timer: float = 0.0
var chase_target = null
var wave_target: Vector2 = Vector2.ZERO
var previous_state: AIState = AIState.PATROL

var unit: Unit
var _scan_phase: int = 0
var _aggro: AggroComp  # 威胁值表组件（仅敌方 AI 持有）


func _ready() -> void:
	unit = get_parent() as Unit
	patrol_center = unit.global_position
	_pick_new_patrol_point()
	_scan_phase = get_instance_id() % SCAN_THROTTLE_FRAMES
	# 挂载威胁值表组件（命名固定，避免 get_children() 误匹配）
	_aggro = AggroComp.new()
	_aggro.name = "AggroComponent"
	add_child(_aggro)


func _should_scan_this_frame() -> bool:
	return Engine.get_physics_frames() % SCAN_THROTTLE_FRAMES == _scan_phase


func _physics_process(_delta: float) -> void:
	if unit.state == Unit.UnitState.DEAD:
		return

	# 如果单位正在攻击且目标已死，恢复之前状态
	if unit.state == Unit.UnitState.ATTACK:
		var target = unit.attack_target
		if target == null or target.is_dead():
			unit.state = Unit.UnitState.GUARD
			if previous_state == AIState.WAVE_ATTACK:
				ai_state = AIState.WAVE_ATTACK
				unit.attack_move_to(wave_target)
			else:
				ai_state = AIState.PATROL
				_pick_new_patrol_point()
		return

	# 如果单位正在攻击移动中（WAVE_ATTACK 或玩家指令），AI 不干预
	if unit.state == Unit.UnitState.ATTACK_MOVE:
		# WAVE_ATTACK: check if arrived at target
		if ai_state == AIState.WAVE_ATTACK:
			var dist_to_target := unit.global_position.distance_to(wave_target)
			if dist_to_target < 50.0:
				ai_state = AIState.PATROL
				patrol_center = wave_target
				_pick_new_patrol_point()
		return

	# 如果单位正在被外部指令移动中，AI 不干预
	# 例外：AI 追击时 unit.move_to() 会设 MOVE 状态，此时必须继续跑 AI 逻辑
	# 否则 leash 检查永远不执行，敌人会追到天涯海角
	if unit.state == Unit.UnitState.MOVE and ai_state == AIState.PATROL:
		return

	match ai_state:
		AIState.PATROL:
			_patrol_process(_delta)
		AIState.CHASE:
			_chase_process()
		AIState.ATTACK:
			_attack_process()
		AIState.WAVE_ATTACK:
			_wave_attack_process()
		AIState.RETURN_HOME:
			_return_home_process()

	# 威胁值表维护：每帧衰减 + 位置威胁累积
	# RETURN_HOME 态不累积位置威胁（否则玩家追上来立刻切 CHASE，
	# 单位在 leash 边缘反复横跳，原地抽搐+疯狂跳"回家"文字）
	_aggro.decay(_delta)
	if ai_state != AIState.RETURN_HOME:
		_aggro.tick_proximity(_delta, unit.global_position)

	if _should_scan_this_frame():
		_scan_for_targets()


func _is_beyond_leash() -> bool:
	return unit.global_position.distance_squared_to(patrol_center) > leash_range * leash_range


func _break_leash() -> void:
	# 脱战：清空威胁值表，走回出生点（patrol_center 即 spawn 位置）
	_aggro.clear()
	chase_target = null
	ai_state = AIState.RETURN_HOME
	unit.move_to(patrol_center)
	_show_text("回家", Color(0.5, 0.7, 1.0))


func _return_home_process() -> void:
	# 回到出生点附近 → 切回 PATROL（不回血，由用户决策）
	if unit.global_position.distance_squared_to(patrol_center) < 20.0 * 20.0:
		ai_state = AIState.PATROL
		_pick_new_patrol_point()


func _patrol_process(delta: float) -> void:
	if patrol_wait_timer > 0:
		patrol_wait_timer -= delta
		return

	var dist: float = unit.global_position.distance_to(patrol_target)
	if dist < 10.0:
		patrol_wait_timer = randf_range(1.0, 3.0)
		_pick_new_patrol_point()
	else:
		unit.move_to(patrol_target)


func _chase_process() -> void:
	# 切目标由 _scan_for_targets（每 6 帧）统一处理，避免每帧切目标导致滑步
	if _is_target_invalid():
		chase_target = null
		if previous_state == AIState.WAVE_ATTACK:
			ai_state = AIState.WAVE_ATTACK
			unit.attack_move_to(wave_target)
		else:
			ai_state = AIState.PATROL
			_pick_new_patrol_point()
		return

	# Phase 3：超出追击距离则放弃
	if _is_beyond_leash():
		_break_leash()
		return

	var dist: float = unit.global_position.distance_to(chase_target.global_position)
	var atk_range: float = unit.get_effective_attack_range()
	if dist <= atk_range:
		ai_state = AIState.ATTACK
		unit.command_attack(chase_target)
	else:
		unit.move_to(chase_target.global_position)


func _attack_process() -> void:
	# 切目标由 _scan_for_targets（每 6 帧）统一处理
	if _is_target_invalid():
		chase_target = null
		if previous_state == AIState.WAVE_ATTACK:
			ai_state = AIState.WAVE_ATTACK
			unit.attack_move_to(wave_target)
		else:
			ai_state = AIState.PATROL
			_pick_new_patrol_point()
		return

	# Phase 3：超出追击距离则放弃攻击
	if _is_beyond_leash():
		_break_leash()
		return

	var current_target = unit.attack_target
	if current_target != chase_target:
		unit.command_attack(chase_target)


func _wave_attack_process() -> void:
	# If idle, resume moving toward wave target
	if unit.state == Unit.UnitState.GUARD:
		var dist_to_target := unit.global_position.distance_to(wave_target)
		if dist_to_target < 50.0:
			ai_state = AIState.PATROL
			patrol_center = wave_target
			_pick_new_patrol_point()
		else:
			unit.attack_move_to(wave_target)


func start_wave_attack(target: Vector2) -> void:
	wave_target = target
	previous_state = AIState.WAVE_ATTACK
	ai_state = AIState.WAVE_ATTACK
	unit.attack_move_to(target)


func _is_target_invalid() -> bool:
	return chase_target == null or not is_instance_valid(chase_target) or chase_target.is_dead()


func _scan_for_targets() -> void:
	# WAVE_ATTACK 是玩家/AI 玩家级指令，不干预
	if ai_state == AIState.WAVE_ATTACK:
		return

	# RETURN_HOME 态：彻底不被扫描切目标
	# 必须真正走回家（距 patrol_center < 20）→ PATROL 态才重新评估
	# 防止单位在 leash 边缘反复横跳、原地抽搐
	# 注意：玩家在此期间造成伤害仍会累积 DAMAGE 威胁，单位到家后立刻切 CHASE 反击
	if ai_state == AIState.RETURN_HOME:
		return

	# 优先：威胁值表中的最高威胁目标
	var target = _aggro.get_target()

	# Fallback：最近敌人
	if target == null:
		target = _find_closest_in_vision()

	if target == null:
		return

	# 切目标提示：仅当旧目标非空（不是首次锁定）且确实换了目标时显示
	var old_target = chase_target
	var is_switch = old_target != null and target != old_target

	# ATTACK 态切目标：仅更新 chase_target，不切 ai_state
	# 下一帧 _attack_process 会发现 current_target != chase_target 自然切攻击目标
	# HOLD_TIME 锁定机制保证不会抖动（1.5s 内 _aggro.get_target() 返回同一目标）
	if ai_state == AIState.ATTACK:
		if target != chase_target:
			chase_target = target
			if is_switch:
				_show_text("转火", Color(1.0, 0.6, 0.2))
		return

	# CHASE 态切目标：仅更新 chase_target（不重置 previous_state、不切 ai_state）
	if ai_state == AIState.CHASE:
		if target != chase_target:
			chase_target = target
			if is_switch:
				_show_text("转火", Color(1.0, 0.6, 0.2))
		return

	# 其他态（PATROL/RETURN_HOME）→ 切到 CHASE
	chase_target = target
	previous_state = ai_state
	ai_state = AIState.CHASE


func _show_text(text: String, color: Color) -> void:
	var ft = Node2D.new()
	ft.set_script(FloatingTextScript)
	unit.get_tree().current_scene.add_child(ft)
	ft.setup(text, color, unit.global_position + Vector2(0, -50))


func _find_closest_in_vision():
	var closest = null
	var closest_dist: float = INF

	# 扫描玩家单位（用空间分区，grid 同时含 player/enemy，过滤 team）
	for u in UnitGrid.query_neighbors(unit.global_position, vision_range):
		if not (u is CharacterBody2D):
			continue
		if u.is_dead():
			continue
		if u.team != Unit.Team.PLAYER:
			continue
		var d: float = unit.global_position.distance_to(u.global_position)
		if d < vision_range and d < closest_dist:
			closest = u
			closest_dist = d

	# 扫描玩家建筑
	for b in get_tree().get_nodes_in_group("player_buildings"):
		if not b.has_method("is_dead") or b.is_dead():
			continue
		var d: float = unit.global_position.distance_to(b.global_position)
		if d < vision_range and d < closest_dist:
			closest = b
			closest_dist = d

	# 扫描中立单位（护送NPC等）
	for n in get_tree().get_nodes_in_group("neutral_units"):
		if not (n is CharacterBody2D):
			continue
		if n.has_method("is_dead") and n.is_dead():
			continue
		var d: float = unit.global_position.distance_to(n.global_position)
		if d < vision_range and d < closest_dist:
			closest = n
			closest_dist = d

	return closest


func _pick_new_patrol_point() -> void:
	var angle := randf() * TAU
	var radius := randf() * patrol_radius
	patrol_target = patrol_center + Vector2(cos(angle), sin(angle)) * radius


func on_attacked(attacker) -> void:
	# 不再立即切目标，避免被诱饵兵反复横跳无限勾引。
	# 真实威胁值已在 unit.gd::take_damage 注入点累加，
	# 这里仅刷新 last_seen（用 0 增量保证攻击者留在表内不被衰减清除）。
	if attacker is Unit:
		_aggro.add_threat(attacker, 0.0, AggroComp.ThreatSource.DAMAGE)
	# PATROL 态被打断：切 GUARD 让 _physics_process 接管（威胁表自动选目标）
	if ai_state == AIState.PATROL and unit.state == Unit.UnitState.MOVE:
		unit.state = Unit.UnitState.GUARD
