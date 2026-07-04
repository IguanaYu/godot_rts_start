extends Node2D
## 敌方 AI：巡逻/追击/攻击/波次攻击
## 通过类型化引用直接调用 Unit 方法（无字符串调用）
##
## BehaviorMode 是单位的"个性/指令"（持续状态），AIState 是单位的"当前行为"（瞬时状态）。
## 两者正交：GUARD 模式下也会经历 PATROL→CHASE→ATTACK→RETURN_HOME 的 AIState 流转。
##
## 状态入场锁：进入任何 AIState 后前 STATE_ENTRY_LOCK_MSEC(2s) 不判断退出条件
## （目标死亡/嘲讽 除外），防止状态间反复横跳。

enum AIState { PATROL, CHASE, ATTACK, WAVE_ATTACK, RETURN_HOME }

enum BehaviorMode {
	GUARD,          # 默认：防守当前点，有 leash
	AGGRESSIVE,     # 进攻：无 leash，主动追杀
	PURSUE,         # 死锁追杀：强制追 pursue_target，无视一切
	ESCORT,         # 护送：跟随指定友军（第二阶段实现，先 fallback 到 GUARD）
	RUSH,           # 强制赶路：跑向指定点，反击有限（第二阶段实现，先 fallback 到 GUARD）
	HOLD_POSITION,  # 坚守：完全不移动（第二阶段实现，先 fallback 到 GUARD）
}

const SCAN_THROTTLE_FRAMES: int = 6
const AggroComp := preload("res://scripts/core/aggro_component.gd")
const FloatingTextScript := preload("res://scripts/effects/floating_text.gd")

const ATTACKER_MEMORY_MSEC: int = 3000       # 超过 3s 没攻击就忘掉攻击者
const STATE_ENTRY_LOCK_MSEC: int = 2000      # 状态入场锁 2s
const RETALIATION_DAMAGE_PCT: float = 0.2    # 撤退中掉血超 20% 就反攻

@export var patrol_radius: float = 150.0
@export var vision_range: float = 250.0
@export var leash_range: float = 400.0      # 最大追击距离（距 patrol_center）
@export var behavior_mode: BehaviorMode = BehaviorMode.GUARD

var ai_state: AIState = AIState.PATROL
var patrol_center: Vector2
var patrol_target: Vector2
var patrol_wait_timer: float = 0.0
var chase_target = null
var wave_target: Vector2 = Vector2.ZERO
var previous_state: AIState = AIState.PATROL

# BehaviorMode 相关目标
var pursue_target = null            # PURSUE 模式目标
var escort_target = null            # ESCORT 模式目标（第二阶段）
var rush_target_pos: Vector2 = Vector2.ZERO  # RUSH 模式目标点（第二阶段）
var rush_counter_timer: float = 0.0  # RUSH 反击剩余时间（第二阶段）

# 内部状态
var unit: Unit
var _scan_phase: int = 0
var _aggro: AggroComp  # 威胁值表组件（仅用于嘲讽 + skill_component 选目标）
var _recent_attackers: Dictionary = {}  # key=攻击者, value=最后攻击时间 msec
var _state_enter_time: int = 0          # 进入当前 AIState 的时间戳 msec
var _hp_at_retreat_start: float = 0.0   # 进入 RETURN_HOME 时的血量


func _ready() -> void:
	unit = get_parent() as Unit
	patrol_center = unit.global_position
	_pick_new_patrol_point()
	_scan_phase = get_instance_id() % SCAN_THROTTLE_FRAMES
	# 挂载威胁值表组件（命名固定，避免 get_children() 误匹配）
	_aggro = AggroComp.new()
	_aggro.name = "AggroComponent"
	add_child(_aggro)
	_state_enter_time = Time.get_ticks_msec()


func _should_scan_this_frame() -> bool:
	return Engine.get_physics_frames() % SCAN_THROTTLE_FRAMES == _scan_phase


func _physics_process(_delta: float) -> void:
	if unit.state == Unit.UnitState.DEAD:
		return

	# === 威胁值表维护：每帧衰减（保留以清理过期条目，防内存泄漏） ===
	# 移除 tick_proximity（PROXIMITY 威胁是"无脑追远程"的根源之一）
	_aggro.decay(_delta)

	if _should_scan_this_frame():
		_scan_for_targets()

	# 如果单位正在攻击且目标已死，恢复之前状态
	if unit.state == Unit.UnitState.ATTACK:
		var target = unit.attack_target
		if target == null or target.is_dead():
			unit.state = Unit.UnitState.GUARD
			if previous_state == AIState.WAVE_ATTACK:
				_set_ai_state(AIState.WAVE_ATTACK)
				unit.attack_move_to(wave_target)
			else:
				_set_ai_state(AIState.PATROL)
				_pick_new_patrol_point()
		elif ai_state == AIState.ATTACK:
			# 目标活着且在 ATTACK AI 态：检查 _scan_for_targets 是否选了新目标
			# 切目标防抖由 _scan_for_targets 重置入场锁处理，这里直接执行
			var current_target = unit.attack_target
			if current_target != chase_target and chase_target != null:
				unit.command_attack(chase_target)
		return

	# 如果单位正在攻击移动中（WAVE_ATTACK 或玩家指令），AI 不干预
	if unit.state == Unit.UnitState.ATTACK_MOVE:
		# WAVE_ATTACK: check if arrived at target
		if ai_state == AIState.WAVE_ATTACK:
			var dist_to_target := unit.global_position.distance_to(wave_target)
			if dist_to_target < 50.0:
				_wave_attack_arrived()
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


func _is_in_entry_lock() -> bool:
	return Time.get_ticks_msec() - _state_enter_time < STATE_ENTRY_LOCK_MSEC


func _set_ai_state(new_state: AIState) -> void:
	if ai_state == new_state:
		return
	# CHASE↔ATTACK 是正常流转（追到范围就攻击，跑出范围就追），不重置入场锁
	# 否则敌人在攻击范围边缘反复 CHASE↔ATTACK 会导致入场锁永远不过期
	var is_normal_flow: bool = (
		(ai_state == AIState.CHASE and new_state == AIState.ATTACK)
		or (ai_state == AIState.ATTACK and new_state == AIState.CHASE)
	)
	previous_state = ai_state
	ai_state = new_state
	if not is_normal_flow:
		_state_enter_time = Time.get_ticks_msec()


func _is_beyond_leash() -> bool:
	# AGGRESSIVE / PURSUE 模式无 leash 限制
	if behavior_mode == BehaviorMode.AGGRESSIVE or behavior_mode == BehaviorMode.PURSUE:
		return false
	return unit.global_position.distance_squared_to(patrol_center) > leash_range * leash_range


func _break_leash() -> void:
	# AGGRESSIVE / PURSUE 模式不会触发 leash
	if behavior_mode == BehaviorMode.AGGRESSIVE or behavior_mode == BehaviorMode.PURSUE:
		return
	# 脱战：清空威胁值表 + 攻击者记录，走回出生点（patrol_center 即 spawn 位置）
	_aggro.clear()
	_recent_attackers.clear()
	chase_target = null
	_hp_at_retreat_start = unit.health.hp
	_set_ai_state(AIState.RETURN_HOME)
	unit.move_to(patrol_center)
	_show_text("回家", Color(0.5, 0.7, 1.0))


func _return_home_process() -> void:
	# 入场锁 2s 后检查掉血反攻
	if not _is_in_entry_lock():
		if _hp_at_retreat_start > 0 and unit.health.hp / _hp_at_retreat_start < (1.0 - RETALIATION_DAMAGE_PCT):
			var attacker = _find_recent_attacker()
			if attacker == null:
				attacker = _find_closest_in_vision()
			if attacker != null:
				chase_target = attacker
				_set_ai_state(AIState.CHASE)
				_show_text("反攻", Color(1.0, 0.3, 0.3))
				return
	# 回到出生点附近 → 切回 PATROL（不回血，由用户决策）
	if unit.global_position.distance_squared_to(patrol_center) < 20.0 * 20.0:
		_hp_at_retreat_start = 0.0
		_set_ai_state(AIState.PATROL)
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
			_set_ai_state(AIState.WAVE_ATTACK)
			unit.attack_move_to(wave_target)
		else:
			_set_ai_state(AIState.PATROL)
			_pick_new_patrol_point()
		return

	# 超出追击距离则放弃（GUARD 模式才有 leash）
	if _is_beyond_leash():
		_break_leash()
		return

	var dist: float = unit.global_position.distance_to(chase_target.global_position)
	var atk_range: float = unit.get_effective_attack_range()
	if dist <= atk_range:
		_set_ai_state(AIState.ATTACK)
		unit.command_attack(chase_target)
	else:
		unit.move_to(chase_target.global_position)


func _attack_process() -> void:
	# 切目标由 _scan_for_targets（每 6 帧）统一处理
	if _is_target_invalid():
		chase_target = null
		if previous_state == AIState.WAVE_ATTACK:
			_set_ai_state(AIState.WAVE_ATTACK)
			unit.attack_move_to(wave_target)
		else:
			_set_ai_state(AIState.PATROL)
			_pick_new_patrol_point()
		return

	# 超出追击距离则放弃攻击（GUARD 模式才有 leash）
	if _is_beyond_leash():
		_break_leash()
		return

	# 切攻击目标：由 _scan_for_targets 重置入场锁防抖，这里直接执行
	var current_target = unit.attack_target
	if current_target != chase_target and chase_target != null:
		unit.command_attack(chase_target)


func _wave_attack_process() -> void:
	# If idle, resume moving toward wave target
	if unit.state == Unit.UnitState.GUARD:
		var dist_to_target := unit.global_position.distance_to(wave_target)
		if dist_to_target < 50.0:
			_wave_attack_arrived()
		else:
			unit.attack_move_to(wave_target)


func _wave_attack_arrived() -> void:
	# 到达 wave_target 后根据 behavior_mode 决策
	if behavior_mode == BehaviorMode.AGGRESSIVE:
		# AGGRESSIVE：不设 patrol_center，无 leash 限制，继续扫敌追杀
		_set_ai_state(AIState.PATROL)
	else:  # GUARD / 其他 fallback
		_set_ai_state(AIState.PATROL)
		patrol_center = wave_target
	_pick_new_patrol_point()


func start_wave_attack(target: Vector2) -> void:
	wave_target = target
	_set_ai_state(AIState.WAVE_ATTACK)
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
	if ai_state == AIState.RETURN_HOME:
		return

	# 1. 嘲讽优先：被嘲讽时强制打嘲讽者（由 unit.gd 的 _taunt_expire_timer 维护）
	if unit.is_taunted():
		var taunt_target = _aggro.get_target()
		if taunt_target != null and is_instance_valid(taunt_target) and not taunt_target.is_dead():
			if chase_target != taunt_target:
				chase_target = taunt_target
				_show_text("嘲讽", Color(1.0, 0.4, 0.4))
			return

	# 3. PURSUE 模式：强制追 pursue_target，不扫描切目标
	if behavior_mode == BehaviorMode.PURSUE:
		if pursue_target != null and is_instance_valid(pursue_target) and not pursue_target.is_dead():
			if chase_target != pursue_target:
				chase_target = pursue_target
			return
		# pursue_target 失效 → fallback 到 GUARD 逻辑

	# 注：入场锁不阻止"切目标"，只阻止"切状态"（CHASE→PATROL 等）
	# 切目标防抖靠 _find_recent_attacker 的距离优先 + 3s 记忆窗口：
	# B 贴脸打我时距离最近，稳定选中 B，不会反复横跳

	# 4. 清理 _recent_attackers 过期条目
	var now := Time.get_ticks_msec()
	var to_remove: Array = []
	for attacker in _recent_attackers.keys():
		if not is_instance_valid(attacker) or attacker.is_dead():
			to_remove.append(attacker)
		elif now - int(_recent_attackers[attacker]) > ATTACKER_MEMORY_MSEC:
			to_remove.append(attacker)
	for a in to_remove:
		_recent_attackers.erase(a)

	# 5. 优先：最近打我的攻击者（距离最近）
	var new_target = _find_recent_attacker()

	# 6. 没有攻击者 → fallback 到视野内最近敌人
	if new_target == null:
		new_target = _find_closest_in_vision()

	if new_target == null:
		return

	# 7. 目标没变 → 保留
	if new_target == chase_target:
		return

	# 8. 切目标
	var is_switch = chase_target != null and new_target != chase_target
	chase_target = new_target

	# PATROL → CHASE（状态切换由 _set_ai_state 处理入场锁）
	if ai_state == AIState.PATROL:
		_set_ai_state(AIState.CHASE)
	elif ai_state == AIState.ATTACK:
		# ATTACK 态切目标：让 _physics_process 顶部 ATTACK 分支执行 command_attack
		# 不直接调 command_attack，避免与 _physics_process 竞争
		pass

	if is_switch:
		_show_text("转火", Color(1.0, 0.6, 0.2))


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
	# 记录攻击者到 _recent_attackers（替代旧的 _aggro.add_threat(0, DAMAGE)）
	# take_damage 中已注入实际伤害值到 aggro 表（skill_component 仍依赖）
	if attacker != null and is_instance_valid(attacker):
		_recent_attackers[attacker] = Time.get_ticks_msec()
	# PATROL 态被打断：切 GUARD 让 _physics_process 接管（_scan_for_targets 会选目标）
	# 注意检查当前 state，避免覆盖 ATTACK 等更重要状态
	if ai_state == AIState.PATROL and unit.state == Unit.UnitState.MOVE:
		unit.state = Unit.UnitState.GUARD


func on_taunted(caster, duration_sec: float) -> void:
	# 嘲讽算"转移目标"：刷新 2s 入场锁，期间 _scan_for_targets 不切目标
	# 嘲讽持续时间由 unit.gd 的 _taunt_expire_timer 维护
	chase_target = caster
	_state_enter_time = Time.get_ticks_msec()
	if ai_state != AIState.ATTACK and ai_state != AIState.CHASE:
		_set_ai_state(AIState.CHASE)
		unit.command_attack(caster)


func _find_recent_attacker():
	# 在 _recent_attackers 中选距离最近的攻击者（而非时间戳最新）
	# 这样近战贴脸攻击者优先于远程持续射击者
	var best = null
	var best_dist: float = INF
	var my_pos: Vector2 = unit.global_position
	for attacker in _recent_attackers.keys():
		if not is_instance_valid(attacker) or attacker.is_dead():
			continue
		var d: float = my_pos.distance_to(attacker.global_position)
		if d < best_dist:
			best = attacker
			best_dist = d
	return best
