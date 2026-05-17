@tool
extends CharacterBody2D
class_name Unit

enum UnitState { GUARD, HOLD_POSITION, MOVE, ATTACK_MOVE, ATTACK, HEAL, DEAD }
enum UnitType { SOLDIER, ARCHER, LANCER, MONK }
enum Team { PLAYER, ENEMY }

const HealEffectScene := preload("res://scenes/heal_effect.tscn")

@export var unit_type: UnitType = UnitType.SOLDIER:
	set(v): unit_type = v; _refresh_editor()
@export var team: Team = Team.PLAYER
@export var sprite_lift: float = 20.0:
	set(v): sprite_lift = v; _refresh_editor()
@export var shadow_width: int = 28:
	set(v): shadow_width = v; _refresh_editor()
@export var shadow_height: int = 12:
	set(v): shadow_height = v; _refresh_editor()
@export var shadow_alpha: float = 0.4:
	set(v): shadow_alpha = v; _refresh_editor()
@export var shadow_offset_x: float = 0.0:
	set(v): shadow_offset_x = v; _refresh_editor()
@export var shadow_offset_y: float = 0.0:
	set(v): shadow_offset_y = v; _refresh_editor()
@export var sprite_scale_x: float = 0.3:
	set(v): sprite_scale_x = v; _refresh_editor()
@export var sprite_scale_y: float = 0.3:
	set(v): sprite_scale_y = v; _refresh_editor()
@export var sprite_offset_x: float = 0.0:
	set(v): sprite_offset_x = v; _refresh_editor()
@export var sprite_offset_y: float = 0.0:
	set(v): sprite_offset_y = v; _refresh_editor()

var max_hp: int
var hp: int
var attack_damage: int
var attack_range: float
var attack_cooldown: float
var steer_lock_time: float = 0.5
var move_speed: float

var state: UnitState = UnitState.GUARD
var attack_target = null
var attack_timer: float = 0.0
var selected: bool = false
var attack_move_target: Vector2 = Vector2.ZERO
var attack_move_scan_range: float = 300.0
var hold_position_mode: bool = false

# Monk 治疗系统
var heal_target = null
var heal_range: float = 120.0
var heal_amount: int = 8
var heal_cooldown: float = 1.0
var heal_scan_range: float = 250.0
var _is_healing: bool = false

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var selection_ring: CanvasItem = $SelectionRing
@onready var hp_bar: ProgressBar = $HPBar
@onready var body_sprite: Sprite2D = $BodySprite
@onready var aggro_line: Line2D = $AggroLine

# 动画
var _anim_state: String = ""
var _anim_frame: int = 0
var _anim_timer: float = 0.0
var _anim_fps: float = 8.0
var _tex_idle: Texture2D = null
var _tex_run: Texture2D = null
var _tex_attack: Texture2D = null
var _anim_total_frames: int = 6
var _frames_idle: int = 6
var _frames_run: int = 6
var _frames_attack: int = 6
var _is_attacking: bool = false
var _lateral_dir: Vector2 = Vector2.ZERO
var _lateral_timer: float = 0.0
const ShadowComp := preload("res://scripts/shadow_component.gd")
@onready var _shadow_component: ShadowComp = $ShadowComponent
const HealthComp := preload("res://scripts/health_component.gd")
@onready var health: HealthComp = $HealthComponent
var _state_indicator: ColorRect = null

signal died(unit: Unit)

func _ready() -> void:
	_setup_stats()
	if Engine.is_editor_hint():
		_setup_editor_visuals()
	else:
		_setup_visuals()
		_update_selection_ring()
		_update_hp_bar()

func _setup_stats() -> void:
	match unit_type:
		UnitType.SOLDIER:
			max_hp = 100
			attack_damage = 10
			attack_range = 40.0
			attack_cooldown = 0.8
			move_speed = 120.0
		UnitType.ARCHER:
			max_hp = 60
			attack_damage = 15
			attack_range = 200.0
			attack_cooldown = 1.2
			move_speed = 80.0
		UnitType.LANCER:
			max_hp = 180
			attack_damage = 12
			attack_range = 45.0
			attack_cooldown = 1.0
			move_speed = 70.0
		UnitType.MONK:
			max_hp = 50
			attack_damage = 0
			attack_range = 0.0
			attack_cooldown = 999.0
			move_speed = 90.0
			heal_range = 120.0
			heal_amount = 8
			heal_cooldown = 1.0
			heal_scan_range = 250.0
	if health and not Engine.is_editor_hint():
		health.setup(max_hp, hp_bar)

func _setup_editor_visuals() -> void:
	_setup_texture()
	_rebuild_shadow()
	_apply_sprite_position()

func _setup_visuals() -> void:
	_setup_texture()

	# 创建脚底影子
	_rebuild_shadow()

	# 贴图上移
	_apply_sprite_position()

	# HPBar 跟随上移
	hp_bar.offset_top += sprite_lift + sprite_offset_y
	hp_bar.offset_bottom += sprite_lift + sprite_offset_y

	# 创建头顶状态指示小圆点
	_state_indicator = ColorRect.new()
	_state_indicator.size = Vector2(8, 8)
	_state_indicator.position = Vector2(-4, hp_bar.offset_top - 12)
	_state_indicator.visible = false
	add_child(_state_indicator)

func _setup_texture() -> void:
	var color_dir := "blue" if team == Team.PLAYER else "red"
	match unit_type:
		UnitType.SOLDIER:
			var base := "res://assets/units/%s_warrior" % color_dir
			_tex_idle = load(base + "/Warrior_Idle.png")
			_tex_run = load(base + "/Warrior_Run.png")
			_tex_attack = load(base + "/Warrior_Attack1.png")
		UnitType.ARCHER:
			var base := "res://assets/units/%s_archer" % color_dir
			_tex_idle = load(base + "/Archer_Idle.png")
			_tex_run = load(base + "/Archer_Run.png")
			_tex_attack = load(base + "/Archer_Shoot.png")
		UnitType.LANCER:
			var base := "res://assets/units/%s_lancer" % color_dir
			_tex_idle = load(base + "/Lancer_Idle.png")
			_tex_run = load(base + "/Lancer_Run.png")
			_tex_attack = load(base + "/Lancer_DownRight_Attack.png")
		UnitType.MONK:
			var base := "res://assets/units/%s_monk" % color_dir
			_tex_idle = load(base + "/Idle.png")
			_tex_run = load(base + "/Run.png")
			_tex_attack = null

	var frame_w := 192
	if unit_type == UnitType.LANCER:
		frame_w = 320
	_frames_idle = _tex_idle.get_width() / frame_w if _tex_idle else 6
	_frames_run = _tex_run.get_width() / frame_w if _tex_run else 6
	_frames_attack = _tex_attack.get_width() / frame_w if _tex_attack else 6

	if not Engine.is_editor_hint():
		_set_anim("idle")
	else:
		if _tex_idle:
			body_sprite.texture = _tex_idle
			body_sprite.hframes = _frames_idle
			body_sprite.frame = 0

func _rebuild_shadow() -> void:
	if _shadow_component:
		_shadow_component.rebuild(shadow_width, shadow_height, shadow_alpha, shadow_offset_x, shadow_offset_y)

func _apply_sprite_position() -> void:
	if _shadow_component:
		_shadow_component.apply_sprite_position(body_sprite, sprite_scale_x, sprite_scale_y, sprite_lift, sprite_offset_x, sprite_offset_y)

func _refresh_editor() -> void:
	if not Engine.is_editor_hint():
		return
	if not is_node_ready():
		return

	_setup_stats()
	_setup_texture()
	_rebuild_shadow()
	_apply_sprite_position()
	queue_redraw()

func _draw() -> void:
	if not Engine.is_editor_hint():
		return

	var cell := 64

	# 64x64 参考格子线
	var origin := Vector2(-cell / 2.0, -cell / 2.0)
	draw_rect(Rect2(origin, Vector2(cell, cell)), Color(1, 1, 1, 0.3), false, 1.0)

	# 碰撞圆（红色）
	draw_arc(Vector2.ZERO, 16.0, 0.0, TAU, 32, Color(1, 0, 0, 0.6), 1.0)

	# 阴影范围椭圆（黄色）
	var sw := float(shadow_width) / 2.0
	var sh := float(shadow_height) / 2.0
	var points := 32
	for i in range(points):
		var a1 := i * TAU / points
		var a2 := (i + 1) * TAU / points
		var p1 := Vector2(cos(a1) * sw + shadow_offset_x, sin(a1) * sh + shadow_offset_y)
		var p2 := Vector2(cos(a2) * sw + shadow_offset_x, sin(a2) * sh + shadow_offset_y)
		draw_line(p1, p2, Color(1, 1, 0, 0.6), 1.0)

func _set_anim(anim_name: String) -> void:
	if anim_name == _anim_state:
		return
	_anim_state = anim_name
	_anim_frame = 0
	_anim_timer = 0.0
	var tex: Texture2D = null
	match anim_name:
		"idle":
			tex = _tex_idle
			_anim_fps = 8.0
			_anim_total_frames = _frames_idle
		"run":
			tex = _tex_run
			_anim_fps = 10.0
			_anim_total_frames = _frames_run
		"attack":
			tex = _tex_attack
			_anim_fps = 12.0
			_anim_total_frames = _frames_attack
	if tex:
		body_sprite.texture = tex
		body_sprite.hframes = _anim_total_frames
		body_sprite.frame = 0
		body_sprite.visible = true

func _update_animation() -> void:
	if body_sprite.texture == null:
		return
	_anim_timer += get_physics_process_delta_time()
	var frame_duration := 1.0 / _anim_fps
	if _anim_timer >= frame_duration:
		_anim_timer -= frame_duration
		_anim_frame += 1
		if _anim_frame >= _anim_total_frames:
			if _anim_state == "attack":
				_anim_frame = _anim_total_frames - 1
			else:
				_anim_frame = 0
		body_sprite.frame = _anim_frame

	var target_anim := "idle"
	if state == UnitState.MOVE or state == UnitState.ATTACK_MOVE:
		target_anim = "run" if velocity.length_squared() > 1.0 else "idle"
	elif state == UnitState.ATTACK:
		if velocity.length_squared() > 1.0:
			target_anim = "run"
		elif _is_attacking:
			if _anim_frame >= _anim_total_frames - 1:
				_is_attacking = false
				target_anim = "idle"
			else:
				target_anim = "attack"
		else:
			target_anim = "idle"
	elif state == UnitState.HEAL:
		if velocity.length_squared() > 1.0:
			target_anim = "run"
		else:
			target_anim = "idle"
	_set_anim(target_anim)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if state == UnitState.DEAD:
		return

	velocity = Vector2.ZERO

	match state:
		UnitState.GUARD:
			_guard_process(delta)
		UnitState.HOLD_POSITION:
			_hold_position_process(delta)
		UnitState.MOVE:
			_move_process()
		UnitState.ATTACK_MOVE:
			_attack_move_process(delta)
		UnitState.ATTACK:
			_attack_process(delta)
		UnitState.HEAL:
			_heal_process(delta)

	if velocity.length_squared() > 1.0:
		var prev_pos := global_position
		move_and_slide()
		if global_position.distance_squared_to(prev_pos) < 0.5:
			velocity = Vector2.ZERO

	attack_timer = max(0.0, attack_timer - delta)
	_update_aggro_line()
	_update_animation()
	_update_state_indicator()

func _move_process() -> void:
	if nav_agent.is_navigation_finished():
		state = UnitState.GUARD
		hold_position_mode = false
		return
	var next_pos := nav_agent.get_next_path_position()
	var direction := global_position.direction_to(next_pos)
	velocity = direction * move_speed

func _attack_process(delta: float) -> void:
	# Monk不攻击，站着不动
	if unit_type == UnitType.MONK:
		return

	if attack_target == null or attack_target.is_dead():
		attack_target = null
		_is_attacking = false
		if hold_position_mode:
			state = UnitState.HOLD_POSITION
		elif attack_move_target != Vector2.ZERO:
			nav_agent.target_position = attack_move_target
			state = UnitState.ATTACK_MOVE
		else:
			state = UnitState.GUARD
			hold_position_mode = false
		return

	var dist := _get_dist_to_target(attack_target)
	if dist > attack_range:
		if hold_position_mode:
			attack_target = null
			_is_attacking = false
			state = UnitState.HOLD_POSITION
			return

		var base_dir: Vector2

		if attack_target.has_method("get_rect"):
			# 建筑：用 NavAgent 导航（需避开建筑障碍区）
			var nav_target := _get_building_nav_target(attack_target)
			nav_agent.target_position = nav_target
			if not nav_agent.is_navigation_finished():
				base_dir = global_position.direction_to(nav_agent.get_next_path_position())
			else:
				base_dir = global_position.direction_to(attack_target.global_position)
		else:
			# 单位：直接追，不用 NavAgent
			base_dir = global_position.direction_to(attack_target.global_position)

		# 切线避让：根据前方友军位置调整方向
		var steered_dir := _get_steered_direction(base_dir, delta)
		velocity = steered_dir * move_speed
	else:
		if attack_timer <= 0.0:
			_perform_attack()
			attack_timer = attack_cooldown

func _attack_move_process(delta: float) -> void:
	# Monk 攻击移动时优先治疗
	if unit_type == UnitType.MONK:
		var wounded = _find_wounded_ally(heal_scan_range)
		if wounded != null:
			heal_target = wounded
			nav_agent.target_position = wounded.global_position
			state = UnitState.HEAL
			return
		if nav_agent.is_navigation_finished():
			state = UnitState.GUARD
			return
		var next_pos := nav_agent.get_next_path_position()
		var base_dir := global_position.direction_to(next_pos)
		velocity = _get_steered_direction(base_dir, delta) * move_speed
		return

	var closest = _find_closest_enemy_in_range(attack_move_scan_range)

	if closest != null:
		attack_target = closest
		nav_agent.target_position = _get_building_nav_target(closest)
		state = UnitState.ATTACK
		return

	# 没有敌人，继续移动
	if nav_agent.is_navigation_finished():
		state = UnitState.GUARD
		hold_position_mode = false
		return
	var next_pos2 := nav_agent.get_next_path_position()
	var base_dir2 := global_position.direction_to(next_pos2)
	velocity = _get_steered_direction(base_dir2, delta) * move_speed

func _find_closest_enemy_in_range(scan_range: float):
	var enemy_group := "enemy_units" if team == Team.PLAYER else "player_units"
	var enemy_building_group := "enemy_buildings" if team == Team.PLAYER else "player_buildings"
	var closest = null
	var closest_dist: float = INF
	for u in get_tree().get_nodes_in_group(enemy_group):
		if u.is_dead():
			continue
		var d := global_position.distance_to(u.global_position)
		if d < scan_range and d < closest_dist:
			closest = u
			closest_dist = d
	for b in get_tree().get_nodes_in_group(enemy_building_group):
		if not b.has_method("is_dead") or b.is_dead():
			continue
		var d := global_position.distance_to(b.global_position)
		if d < scan_range and d < closest_dist:
			closest = b
			closest_dist = d
	return closest

func _find_wounded_ally(scan_range: float):
	var ally_group := "player_units" if team == Team.PLAYER else "enemy_units"
	var closest = null
	var closest_dist: float = INF
	for u in get_tree().get_nodes_in_group(ally_group):
		if u == self:
			continue
		if u.is_dead():
			continue
		if u.hp >= u.max_hp:
			continue
		var d := global_position.distance_to(u.global_position)
		if d < scan_range and d < closest_dist:
			closest = u
			closest_dist = d
	return closest

func _heal_process(delta: float) -> void:
	if heal_target == null or heal_target.is_dead() or heal_target.hp >= heal_target.max_hp:
		heal_target = null
		_is_healing = false
		state = UnitState.GUARD
		return
	var dist := global_position.distance_to(heal_target.global_position)
	if dist > heal_range:
		nav_agent.target_position = heal_target.global_position
		if not nav_agent.is_navigation_finished():
			var next_pos := nav_agent.get_next_path_position()
			velocity = global_position.direction_to(next_pos) * move_speed
	else:
		if attack_timer <= 0.0:
			heal_target.heal(heal_amount)
			attack_timer = heal_cooldown
			_is_healing = true

func _guard_process(delta: float) -> void:
	# Monk 优先寻找受伤友军
	if unit_type == UnitType.MONK:
		var wounded = _find_wounded_ally(heal_scan_range)
		if wounded != null:
			heal_target = wounded
			nav_agent.target_position = wounded.global_position
			state = UnitState.HEAL
		return

	var closest = _find_closest_enemy_in_range(attack_move_scan_range)
	if closest != null:
		attack_target = closest
		nav_agent.target_position = _get_building_nav_target(closest)
		state = UnitState.ATTACK
		hold_position_mode = false

func _hold_position_process(delta: float) -> void:
	var closest = _find_closest_enemy_in_range(attack_move_scan_range)
	if closest != null:
		var dist := _get_dist_to_target(closest)
		if dist <= attack_range:
			attack_target = closest
			state = UnitState.ATTACK
			hold_position_mode = true

func _get_building_nav_target(target, angle_offset: float = 0.0) -> Vector2:
	if not target.has_method("get_rect"):
		return target.global_position
	var brect: Rect2 = target.get_rect()
	var center := brect.get_center()
	var to_unit := global_position - center
	if to_unit.length_squared() < 1.0:
		return center + Vector2.RIGHT * brect.size.x / 2.0
	var angle := to_unit.angle() + angle_offset
	var half := brect.size / 2.0
	var ca := cos(angle)
	var sa := sin(angle)
	var dx: float = half.x / abs(ca) if abs(ca) > 0.001 else 999999.0
	var dy: float = half.y / abs(sa) if abs(sa) > 0.001 else 999999.0
	var d: float = minf(dx, dy)
	return center + Vector2(ca, sa) * (d + 25.0)

func _get_dist_to_target(target) -> float:
	if not target.has_method("get_rect"):
		return global_position.distance_to(target.global_position)
	var brect: Rect2 = target.get_rect()
	var nearest := global_position.clamp(brect.position, brect.end)
	return global_position.distance_to(nearest)

func _get_steered_direction(base_dir: Vector2, delta: float) -> Vector2:
	# 通用1秒方向锁：设定了新方向就锁住不改，防止抖动
	if _lateral_dir != Vector2.ZERO and _lateral_timer < steer_lock_time:
		_lateral_timer += delta
		return _lateral_dir

	var scan_range := 50.0

	# Step 1: 收集前方±60°内的单位（友军+敌军），分左右
	var left_units: Array = []
	var right_units: Array = []

	var ally_group := "player_units" if team == Team.PLAYER else "enemy_units"
	var enemy_group := "enemy_units" if team == Team.PLAYER else "player_units"

	for group in [ally_group, enemy_group]:
		for u in get_tree().get_nodes_in_group(group):
			if u == self or u.is_dead():
				continue
			if u == attack_target:
				continue
			# 同方向移动的单位不算障碍（保持阵型）
			if u.velocity.length_squared() > 1.0:
				var vel_angle: float = abs(base_dir.angle_to(u.velocity))
				if vel_angle < PI / 4.0:
					continue
			var to_u: Vector2 = u.global_position - global_position
			var dist: float = to_u.length()
			if dist < scan_range and dist > 0.1:
				var angle: float = base_dir.angle_to(to_u)
				if abs(angle) < PI / 3.0:  # ±60°
					if angle < 0:
						left_units.append(to_u)
					else:
						right_units.append(to_u)

	var has_left: bool = not left_units.is_empty()
	var has_right: bool = not right_units.is_empty()

	# Step 2: 前方无单位 → 直走，清空锁
	if not has_left and not has_right:
		_lateral_dir = Vector2.ZERO
		_lateral_timer = 0.0
		return base_dir

	# Step 3: 单侧避让 → 锐角切线
	if has_left != has_right:
		var units: Array = left_units if has_left else right_units
		_lateral_dir = _calc_best_tangent(units, base_dir, true, true)
		_lateral_timer = 0.0
		return _lateral_dir

	# Step 4: 双侧都有单位
	var left_acute: Vector2 = _calc_best_tangent(left_units, base_dir, true, true)
	var right_acute: Vector2 = _calc_best_tangent(right_units, base_dir, true, true)

	var left_cross: float = left_acute.cross(base_dir)
	var right_cross: float = right_acute.cross(base_dir)
	var same_side: bool = (left_cross > 0) == (right_cross > 0)

	if same_side:
		# 4a: 同侧堵塞 → 选角度更大的切线
		var la: float = abs(left_acute.angle_to(base_dir))
		var ra: float = abs(right_acute.angle_to(base_dir))
		_lateral_dir = left_acute if la > ra else right_acute
		_lateral_timer = 0.0
		return _lateral_dir

	# 4b: 对侧拥堵 → 扩大扫描到±120°，钝角切线横向躲避
	for group in [ally_group, enemy_group]:
		for u in get_tree().get_nodes_in_group(group):
			if u == self or u.is_dead() or u == attack_target:
				continue
			var to_u: Vector2 = u.global_position - global_position
			var dist: float = to_u.length()
			if dist < scan_range and dist > 0.1:
				var angle: float = base_dir.angle_to(to_u)
				if abs(angle) >= PI / 3.0 and abs(angle) < 2.0 * PI / 3.0:
					if angle < 0:
						left_units.append(to_u)
					else:
						right_units.append(to_u)

	var left_escape: Vector2 = _calc_best_tangent(left_units, base_dir, false, false)
	var right_escape: Vector2 = _calc_best_tangent(right_units, base_dir, false, false)

	var la2: float = abs(left_escape.angle_to(base_dir))
	var ra2: float = abs(right_escape.angle_to(base_dir))
	_lateral_dir = left_escape if la2 < ra2 else right_escape
	_lateral_timer = 0.0
	return _lateral_dir


# 计算一组单位的最佳切线方向
# acute: true=锐角切线(接近base_dir), false=钝角切线(远离base_dir)
# pick_smallest: true=选角度最小的单位, false=选角度最大的单位
func _calc_best_tangent(units: Array, base_dir: Vector2, acute: bool, pick_smallest: bool) -> Vector2:
	var best: Vector2 = base_dir
	var best_ang: float = INF if pick_smallest else -1.0
	for to_u_v in units:
		var to_u: Vector2 = to_u_v
		var t1: Vector2 = Vector2(-to_u.y, to_u.x).normalized()
		var t2: Vector2 = Vector2(to_u.y, -to_u.x).normalized()
		var tangent: Vector2
		if acute:
			tangent = t1 if t1.dot(base_dir) >= t2.dot(base_dir) else t2
		else:
			tangent = t1 if t1.dot(base_dir) < t2.dot(base_dir) else t2
		var ang: float = abs(tangent.angle_to(base_dir))
		if pick_smallest and ang < best_ang:
			best_ang = ang
			best = tangent
		elif not pick_smallest and ang > best_ang:
			best_ang = ang
			best = tangent
	return best

func _perform_attack() -> void:
	if attack_target and not attack_target.is_dead():
		if unit_type == UnitType.MONK:
			return
		_is_attacking = true
		_set_anim("")
		_set_anim("attack")
		if unit_type == UnitType.ARCHER:
			_spawn_arrow(attack_target)
		else:
			attack_target.take_damage(attack_damage, self)

func _spawn_arrow(target) -> void:
	var arrow_scene := load("res://scenes/arrow.tscn")
	var arrow: Node2D = arrow_scene.instantiate()
	get_tree().current_scene.add_child(arrow)
	arrow.setup(global_position, target.global_position)
	arrow.hit_target = target
	arrow.hit_damage = attack_damage
	arrow.shooter = self

func take_damage(amount: int, attacker = null) -> void:
	if Engine.is_editor_hint():
		return
	if health.is_dead():
		return
	health.take_damage(amount)
	if attacker:
		if team == Team.ENEMY:
			_alert_enemy_response(attacker)
		elif team == Team.PLAYER:
			_player_retaliate(attacker)
	if health.hp <= 0:
		die()

func _player_retaliate(attacker) -> void:
	# 已经在攻击有效目标时不切换
	if state == UnitState.ATTACK and attack_target != null and not attack_target.is_dead():
		return
	# 验证攻击者仍存活
	if attacker == null or not is_instance_valid(attacker) or attacker.is_dead():
		return

	attack_target = attacker
	nav_agent.target_position = _get_building_nav_target(attacker)

	if state == UnitState.HOLD_POSITION:
		state = UnitState.ATTACK
		hold_position_mode = true
	else:
		state = UnitState.ATTACK
		hold_position_mode = false

	# 通知附近友军
	_alert_nearby_allies(attacker)

func _alert_nearby_allies(attacker) -> void:
	var alert_range := 400.0
	var ally_group := "player_units" if team == Team.PLAYER else "enemy_units"
	for u in get_tree().get_nodes_in_group(ally_group):
		if u == self or u.is_dead():
			continue
		if global_position.distance_to(u.global_position) <= alert_range:
			u._player_retaliate(attacker)

func _alert_enemy_response(attacker) -> void:
	# 通知自身AI
	var ai = get_node_or_null("EnemyAI")
	if ai and ai.has_method("on_attacked"):
		ai.on_attacked(attacker)
	# 广播给附近友军
	var alert_range := 400.0
	for u in get_tree().get_nodes_in_group("enemy_units"):
		if u == self or u.is_dead():
			continue
		if global_position.distance_to(u.global_position) <= alert_range:
			var ally_ai = u.get_node_or_null("EnemyAI")
			if ally_ai and ally_ai.has_method("on_attacked"):
				ally_ai.on_attacked(attacker)

func die() -> void:
	state = UnitState.DEAD
	died.emit(self)
	health._is_dead = true
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
	tween.tween_callback(queue_free)

func move_to(target_pos: Vector2) -> void:
	attack_target = null
	attack_move_target = Vector2.ZERO
	hold_position_mode = false
	heal_target = null
	_is_healing = false
	nav_agent.target_position = target_pos
	state = UnitState.MOVE

func attack_move_to(target_pos: Vector2) -> void:
	attack_target = null
	attack_move_target = target_pos
	hold_position_mode = false
	heal_target = null
	_is_healing = false
	nav_agent.target_position = target_pos
	state = UnitState.ATTACK_MOVE

func stop() -> void:
	attack_target = null
	attack_move_target = Vector2.ZERO
	_is_attacking = false
	hold_position_mode = false
	heal_target = null
	_is_healing = false
	velocity = Vector2.ZERO
	nav_agent.target_position = global_position
	state = UnitState.GUARD

func hold_position() -> void:
	attack_target = null
	attack_move_target = Vector2.ZERO
	_is_attacking = false
	hold_position_mode = true
	heal_target = null
	_is_healing = false
	velocity = Vector2.ZERO
	nav_agent.target_position = global_position
	state = UnitState.HOLD_POSITION

func command_attack(target) -> void:
	attack_target = target
	hold_position_mode = false
	heal_target = null
	_is_healing = false
	nav_agent.target_position = _get_building_nav_target(target)
	state = UnitState.ATTACK

func set_selected(value: bool) -> void:
	selected = value
	_update_selection_ring()

func _update_selection_ring() -> void:
	if selection_ring:
		selection_ring.visible = selected
	_update_state_indicator()

func _update_hp_bar() -> void:
	if health:
		health._update_hp_bar()

func _update_state_indicator() -> void:
	if _state_indicator == null:
		return
	_state_indicator.visible = selected and team == Team.PLAYER
	if not _state_indicator.visible:
		return
	match state:
		UnitState.GUARD:
			_state_indicator.color = Color("#4CAF50")
		UnitState.HOLD_POSITION:
			_state_indicator.color = Color("#FFC107")
		UnitState.ATTACK:
			_state_indicator.color = Color("#F44336")
		UnitState.MOVE, UnitState.ATTACK_MOVE:
			_state_indicator.color = Color("#2196F3")
		UnitState.HEAL:
			_state_indicator.color = Color("#4CAF50")

func _update_aggro_line() -> void:
	if state == UnitState.DEAD or aggro_line == null:
		return
	# 治疗目标也显示连线
	if heal_target != null and is_instance_valid(heal_target) and not heal_target.is_dead():
		aggro_line.visible = true
		aggro_line.clear_points()
		aggro_line.add_point(Vector2.ZERO)
		aggro_line.add_point(heal_target.global_position - global_position)
	elif attack_target != null and not attack_target.is_dead():
		aggro_line.visible = true
		aggro_line.clear_points()
		aggro_line.add_point(Vector2.ZERO)
		aggro_line.add_point(attack_target.global_position - global_position)
	else:
		aggro_line.visible = false

func is_dead() -> bool:
	return health.is_dead() if health else state == UnitState.DEAD

func heal(amount: int) -> void:
	if health.is_dead():
		return
	health.heal(amount)
	var effect: Node2D = HealEffectScene.instantiate()
	get_tree().current_scene.add_child(effect)
	effect.global_position = global_position
