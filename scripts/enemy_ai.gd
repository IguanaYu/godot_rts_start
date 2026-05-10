extends Node2D

const UnitScript := preload("res://scripts/unit.gd")

enum AIState { PATROL, CHASE, ATTACK, WAVE_ATTACK }

@export var patrol_radius: float = 150.0
@export var vision_range: float = 250.0

var ai_state: AIState = AIState.PATROL
var patrol_center: Vector2
var patrol_target: Vector2
var patrol_wait_timer: float = 0.0
var chase_target = null
var wave_target: Vector2 = Vector2.ZERO
var previous_state: AIState = AIState.PATROL

var unit: CharacterBody2D

func _ready() -> void:
	unit = get_parent() as CharacterBody2D
	patrol_center = unit.global_position
	_pick_new_patrol_point()

func _physics_process(delta: float) -> void:
	if unit.get("state") == UnitScript.UnitState.DEAD:
		return

	# 如果单位正在攻击且目标已死，恢复之前状态
	if unit.get("state") == UnitScript.UnitState.ATTACK:
		var target = unit.get("attack_target")
		if target == null or target.is_dead():
			unit.set("state", UnitScript.UnitState.IDLE)
			if previous_state == AIState.WAVE_ATTACK:
				ai_state = AIState.WAVE_ATTACK
				unit.call("attack_move_to", wave_target)
			else:
				ai_state = AIState.PATROL
				_pick_new_patrol_point()
		return

	# 如果单位正在攻击移动中（WAVE_ATTACK 或玩家指令），AI 不干预
	if unit.get("state") == UnitScript.UnitState.ATTACK_MOVE:
		# WAVE_ATTACK: check if arrived at target
		if ai_state == AIState.WAVE_ATTACK:
			var dist_to_target := unit.global_position.distance_to(wave_target)
			if dist_to_target < 50.0:
				ai_state = AIState.PATROL
				patrol_center = wave_target
				_pick_new_patrol_point()
		return

	# 如果单位正在被外部指令移动中，AI 不干预
	if unit.get("state") == UnitScript.UnitState.MOVE:
		return

	match ai_state:
		AIState.PATROL:
			_patrol_process(delta)
		AIState.CHASE:
			_chase_process()
		AIState.ATTACK:
			_attack_process()
		AIState.WAVE_ATTACK:
			_wave_attack_process()

	_scan_for_targets()

func _patrol_process(delta: float) -> void:
	if patrol_wait_timer > 0:
		patrol_wait_timer -= delta
		return

	var dist: float = unit.global_position.distance_to(patrol_target)
	if dist < 10.0:
		patrol_wait_timer = randf_range(1.0, 3.0)
		_pick_new_patrol_point()
	else:
		unit.call("move_to", patrol_target)

func _chase_process() -> void:
	if _is_target_invalid():
		chase_target = null
		if previous_state == AIState.WAVE_ATTACK:
			ai_state = AIState.WAVE_ATTACK
			unit.call("attack_move_to", wave_target)
		else:
			ai_state = AIState.PATROL
			_pick_new_patrol_point()
		return

	var dist: float = unit.global_position.distance_to(chase_target.global_position)
	var atk_range: float = unit.get("attack_range")
	if dist <= atk_range:
		ai_state = AIState.ATTACK
		unit.call("command_attack", chase_target)
	else:
		unit.call("move_to", chase_target.global_position)

func _attack_process() -> void:
	if _is_target_invalid():
		chase_target = null
		if previous_state == AIState.WAVE_ATTACK:
			ai_state = AIState.WAVE_ATTACK
			unit.call("attack_move_to", wave_target)
		else:
			ai_state = AIState.PATROL
			_pick_new_patrol_point()
		return
	var current_target = unit.get("attack_target")
	if current_target != chase_target:
		unit.call("command_attack", chase_target)

func _wave_attack_process() -> void:
	# If idle, resume moving toward wave target
	if unit.get("state") == UnitScript.UnitState.IDLE:
		var dist_to_target := unit.global_position.distance_to(wave_target)
		if dist_to_target < 50.0:
			ai_state = AIState.PATROL
			patrol_center = wave_target
			_pick_new_patrol_point()
		else:
			unit.call("attack_move_to", wave_target)

func start_wave_attack(target: Vector2) -> void:
	wave_target = target
	previous_state = AIState.WAVE_ATTACK
	ai_state = AIState.WAVE_ATTACK
	unit.call("attack_move_to", target)

func _is_target_invalid() -> bool:
	return chase_target == null or not is_instance_valid(chase_target) or chase_target.is_dead()

func _scan_for_targets() -> void:
	if ai_state == AIState.ATTACK or ai_state == AIState.WAVE_ATTACK:
		return

	var closest = null
	var closest_dist: float = INF

	# 扫描玩家单位
	for u in get_tree().get_nodes_in_group("player_units"):
		if not (u is CharacterBody2D):
			continue
		if u.is_dead():
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

	if closest != null:
		chase_target = closest
		previous_state = ai_state
		ai_state = AIState.CHASE

func _pick_new_patrol_point() -> void:
	var angle := randf() * TAU
	var radius := randf() * patrol_radius
	patrol_target = patrol_center + Vector2(cos(angle), sin(angle)) * radius

func on_attacked(attacker) -> void:
	if ai_state == AIState.ATTACK:
		return
	previous_state = ai_state
	chase_target = attacker
	ai_state = AIState.CHASE
	# 打断当前巡逻移动，让AI立即接管
	if unit.get("state") == UnitScript.UnitState.MOVE:
		unit.set("state", UnitScript.UnitState.IDLE)
