extends Node2D
## AI 队友（盟军）：联合作战状态机
## 通过 owner_id=-2 标识；alliance_id=0 让 team=PLAYER 自动工作
## 状态：
##   FOLLOW_PLAYER  — 跟随玩家主力质心
##   ATTACK_TARGET  — 视野内/受击锁定敌人攻击
##   FORCE_ATTACK   — 玩家 ping 指挥，强制 attack_move 到指定位置

enum AllyState { FOLLOW_PLAYER, ATTACK_TARGET, FORCE_ATTACK, FORCE_DEFEND }

const SCAN_THROTTLE_FRAMES: int = 6
const FOLLOW_DISTANCE: float = 150.0
const FOLLOW_RECHECK_INTERVAL: float = 0.5
const VISION_RANGE: float = 280.0
const FORCE_ORDER_ARRIVE_DIST: float = 50.0  # 玩家 ping 距离目标 < 此值视为到达

var ally_state: AllyState = AllyState.FOLLOW_PLAYER
var chase_target = null
var _follow_target_pos: Vector2 = Vector2.ZERO
var _follow_recheck_timer: float = 0.0
var _scan_phase: int = 0
var _force_target_pos: Vector2 = Vector2.ZERO

var unit: Unit


func _ready() -> void:
	unit = get_parent() as Unit
	_scan_phase = get_instance_id() % SCAN_THROTTLE_FRAMES


func _should_scan_this_frame() -> bool:
	return Engine.get_physics_frames() % SCAN_THROTTLE_FRAMES == _scan_phase


func _physics_process(delta: float) -> void:
	if unit.state == Unit.UnitState.DEAD:
		return

	match ally_state:
		AllyState.ATTACK_TARGET:
			_physics_attack_target()
		AllyState.FORCE_ATTACK:
			_physics_force_attack()
		AllyState.FORCE_DEFEND:
			_physics_force_defend()
		_:
			_physics_follow_player(delta)


# ATTACK_TARGET：锁定敌人，丢失则回 FOLLOW_PLAYER
func _physics_attack_target() -> void:
	if _is_target_invalid():
		chase_target = null
		ally_state = AllyState.FOLLOW_PLAYER
		_follow_recheck_timer = 0.0
		return
	if unit.attack_target != chase_target:
		unit.command_attack(chase_target)


# FORCE_ATTACK：玩家 ping 攻击点，强制 attack_move 到位；扫敌自动切入战斗
func _physics_force_attack() -> void:
	# 正在战斗时不打断 — unit.attack_move_to 内部已有自动扫敌逻辑，会自然处理遇敌
	if unit.state == Unit.UnitState.ATTACK:
		return
	if unit.global_position.distance_to(_force_target_pos) < FORCE_ORDER_ARRIVE_DIST:
		# 已到位：扫敌视野内是否有敌，有则攻击；否则回 FOLLOW_PLAYER
		if _should_scan_this_frame():
			_scan_for_targets()
		if ally_state == AllyState.FORCE_ATTACK:
			ally_state = AllyState.FOLLOW_PLAYER
			_follow_recheck_timer = 0.0
		return
	# 没到位：仅当不在 ATTACK_MOVE 时才重发（避免每帧覆盖）
	if unit.state != Unit.UnitState.ATTACK_MOVE:
		unit.attack_move_to(_force_target_pos)


# FORCE_DEFEND：玩家 ping 防御点，到达后驻防（守在原地）
func _physics_force_defend() -> void:
	if unit.state == Unit.UnitState.ATTACK:
		return
	if unit.global_position.distance_to(_force_target_pos) < FORCE_ORDER_ARRIVE_DIST:
		if _should_scan_this_frame():
			_scan_for_targets()
		return
	if unit.state != Unit.UnitState.MOVE:
		unit.move_to(_force_target_pos)


func _physics_follow_player(delta: float) -> void:
	_follow_recheck_timer -= delta
	if _follow_recheck_timer <= 0.0:
		_follow_recheck_timer = FOLLOW_RECHECK_INTERVAL
		_follow_target_pos = _compute_player_centroid()

	if _follow_target_pos != Vector2.ZERO:
		var dist: float = unit.global_position.distance_to(_follow_target_pos)
		if dist > FOLLOW_DISTANCE and unit.state != Unit.UnitState.MOVE:
			unit.move_to(_follow_target_pos)

	if _should_scan_this_frame():
		_scan_for_targets()


func _compute_player_centroid() -> Vector2:
	var sum := Vector2.ZERO
	var count := 0
	for u in get_tree().get_nodes_in_group("player_units"):
		if not (u is CharacterBody2D):
			continue
		if u.is_dead():
			continue
		if u.owner_id == -2:
			continue
		sum += u.global_position
		count += 1
	if count == 0:
		return Vector2.ZERO
	return sum / float(count)


func _is_target_invalid() -> bool:
	return chase_target == null or not is_instance_valid(chase_target) or chase_target.is_dead()


func _scan_for_targets() -> void:
	var closest = null
	var closest_dist: float = INF
	for u in UnitGrid.query_neighbors(unit.global_position, VISION_RANGE):
		if not (u is CharacterBody2D):
			continue
		if u.is_dead():
			continue
		if u.team != Unit.Team.ENEMY:
			continue
		var d: float = unit.global_position.distance_to(u.global_position)
		if d < VISION_RANGE and d < closest_dist:
			closest = u
			closest_dist = d
	for b in get_tree().get_nodes_in_group("enemy_buildings"):
		if not b.has_method("is_dead") or b.is_dead():
			continue
		var d: float = unit.global_position.distance_to(b.global_position)
		if d < VISION_RANGE and d < closest_dist:
			closest = b
			closest_dist = d
	if closest != null:
		chase_target = closest
		ally_state = AllyState.ATTACK_TARGET
		unit.command_attack(closest)


func on_attacked(attacker) -> void:
	if ally_state == AllyState.ATTACK_TARGET:
		return
	if attacker == null or not is_instance_valid(attacker) or attacker.is_dead():
		return
	chase_target = attacker
	ally_state = AllyState.ATTACK_TARGET
	if unit.state == Unit.UnitState.MOVE:
		unit.state = Unit.UnitState.GUARD
	unit.command_attack(attacker)


# 增援波次冲锋：等价于一次 FORCE_ATTACK（攻击目标位置）
func start_wave_attack(target: Vector2) -> void:
	issue_attack_order(target)


# 玩家 ping 攻击点（Alt+左键）：强制 attack_move
func issue_attack_order(pos: Vector2) -> void:
	_force_target_pos = pos
	ally_state = AllyState.FORCE_ATTACK
	unit.attack_move_to(pos)


# 玩家 ping 防御点（Alt+右键）：move 到位后驻防
func issue_defend_order(pos: Vector2) -> void:
	_force_target_pos = pos
	ally_state = AllyState.FORCE_DEFEND
	unit.move_to(pos)

