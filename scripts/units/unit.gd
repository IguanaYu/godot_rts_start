@tool
extends CharacterBody2D
class_name Unit

enum UnitState { GUARD, HOLD_POSITION, MOVE, ATTACK_MOVE, ATTACK, HEAL, DEAD, PATROL }
enum UnitType { SOLDIER, ARCHER, LANCER, MONK }
enum Team { PLAYER, ENEMY }
enum CommandSource { NONE, PLAYER, AUTO }

const HealEffectScene := preload("res://scenes/effects/heal_effect.tscn")
const UnitEffectsShader := preload("res://shaders/unit_effects.gdshader")

var _effects_material: ShaderMaterial = null

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

const StatSetClass = preload("res://scripts/stats/stat_set.gd")
const UpgradeMgrClass = preload("res://scripts/stats/upgrade_manager.gd")
@export var stats_data: UnitStats
@export_group("Variant Modifiers")
@export var variant_hp_bonus: int = 0
@export var variant_atk_bonus: int = 0
@export var variant_speed_mult: float = 1.0
@export var variant_scale: float = 1.0
var stat_set
var upgrade_mgr
var steer_lock_time: float = 0.5

var state: UnitState = UnitState.GUARD
var attack_target = null
var attack_command_source: CommandSource = CommandSource.NONE
var attack_timer: float = 0.0
var selected: bool = false
var _was_selected: bool = false
var attack_move_target: Vector2 = Vector2.ZERO
var attack_move_scan_range: float = 300.0
var hold_position_mode: bool = false

# Monk 治疗系统
var heal_target = null
var _is_healing: bool = false

# Buff 系统
var buffs: Dictionary = {}  # {buff_type: {"value": float, "expire": float}}
var _slow_factor: float = 1.0
var _slow_timer: float = 0.0

# 命令队列 (Shift)
const CommandQueue = preload("res://scripts/systems/command_queue.gd")
var command_queue = CommandQueue.new()

# 巡逻系统
var patrol_points: Array = []
var patrol_index: int = 0

# 跟随系统
var follow_target = null

# Alt血条
static var show_all_health_bars: bool = false

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var selection_ring: Node2D = $SelectionRing
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
var _blocked_timer: float = 0.0
var _is_blocked: bool = false
var _escaping_building: bool = false
var _escape_target: Vector2 = Vector2.ZERO
var _escape_timer: float = 0.0
const ShadowComp := preload("res://scripts/core/shadow_component.gd")
@onready var _shadow_component: ShadowComp = $ShadowComponent
const HealthComp := preload("res://scripts/core/health_component.gd")
@onready var health: HealthComp = $HealthComponent
var _state_indicator: ColorRect = null

signal died(unit: Unit)

func _ready() -> void:
	_setup_stats()
	_init_outline_materials()
	if Engine.is_editor_hint():
		_setup_editor_visuals()
	else:
		_setup_visuals()
		_update_selection_ring()
		_update_hp_bar()

func _init_outline_materials() -> void:
	if UnitEffectsShader == null:
		return
	_effects_material = ShaderMaterial.new()
	_effects_material.shader = UnitEffectsShader
	_effects_material.set_shader_parameter("glow_color", Color(1.0, 0.9, 0.3, 1.0))
	_effects_material.set_shader_parameter("glow_width", 3.0)
	_effects_material.set_shader_parameter("outline_enabled", false)
	_effects_material.set_shader_parameter("slow_enabled", false)
	_effects_material.set_shader_parameter("slow_tint", Color(0.5, 0.8, 1.0, 1.0))
	if body_sprite:
		body_sprite.material = _effects_material

func _setup_stats() -> void:
	if stats_data == null:
		return
	stat_set = StatSetClass.new(stats_data)
	upgrade_mgr = UpgradeMgrClass.new(stat_set)
	upgrade_mgr.setup_from_data(stats_data)
	var max_hp = stat_set.get_int(StatSetClass.MAX_HP)
	if health and not Engine.is_editor_hint():
		health.setup(max_hp, hp_bar)
	if stats_data.sprite_scale != 1.0:
		sprite_scale_x *= stats_data.sprite_scale
		sprite_scale_y *= stats_data.sprite_scale
	# 应用变体修饰器（通过 add_modifier 改实际属性）
	if variant_hp_bonus != 0:
		stat_set.add_modifier("variant", StatSetClass.MAX_HP, float(variant_hp_bonus))
	if variant_atk_bonus != 0:
		stat_set.add_modifier("variant", StatSetClass.ATTACK_DAMAGE, float(variant_atk_bonus))
	if variant_speed_mult != 1.0:
		stat_set.add_modifier("variant", StatSetClass.MOVE_SPEED, 0.0, variant_speed_mult)
	if variant_scale != 1.0:
		sprite_scale_x *= variant_scale
		sprite_scale_y *= variant_scale
	# 同步 HP（修饰器可能改了 max_hp）
	if (variant_hp_bonus != 0) and health and not Engine.is_editor_hint():
		health.setup(stat_set.get_int(StatSetClass.MAX_HP), hp_bar)

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


## 检查当前是否在某个建筑的碰撞区域内
func _is_inside_any_building() -> bool:
	for b in get_tree().get_nodes_in_group("buildings"):
		if b.is_dead():
			continue
		var rect: Rect2 = b.get_rect().grow(16.0)
		if rect.has_point(global_position):
			return true
	return false

## 计算从建筑内逃生的目标位置
func _find_escape_target() -> Vector2:
	var unit_radius := 16.0
	for b in get_tree().get_nodes_in_group("buildings"):
		if b.is_dead():
			continue
		var rect: Rect2 = b.get_rect().grow(unit_radius)
		if not rect.has_point(global_position):
			continue
		# 找到困住小兵的建筑，计算到四条边的距离
		var pos := global_position
		var dist_left := pos.x - rect.position.x
		var dist_right := rect.end.x - pos.x
		var dist_top := pos.y - rect.position.y
		var dist_bottom := rect.end.y - pos.y
		# 按距离排序四个逃生方向
		var tries := [
			[dist_left, Vector2(rect.position.x - 4.0, pos.y)],
			[dist_right, Vector2(rect.end.x + 4.0, pos.y)],
			[dist_top, Vector2(pos.x, rect.position.y - 4.0)],
			[dist_bottom, Vector2(pos.x, rect.end.y + 4.0)],
		]
		tries.sort_custom(func(a, b): return a[0] < b[0])
		for t in tries:
			var escape_pos: Vector2 = t[1]
			var valid := true
			for b2 in get_tree().get_nodes_in_group("buildings"):
				if b2.is_dead():
					continue
				if b2.get_rect().grow(unit_radius).has_point(escape_pos):
					valid = false
					break
			if valid:
				return escape_pos
	# 兜底：向下移动
	return global_position + Vector2(0, 64)

## 启动建筑内逃生
func _start_escape() -> void:
	_escaping_building = true
	_escape_target = _find_escape_target()
	_escape_timer = 3.0

## 结束逃生
func _stop_escape() -> void:
	_escaping_building = false
	_escape_target = Vector2.ZERO
	_escape_timer = 0.0

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if state == UnitState.DEAD:
		return
	if stat_set == null:
		return
	# 过期 buff 清理
	_expire_buffs()
	# 建筑内逃生逻辑（优先于正常状态机）
	if _escaping_building:
		_escape_timer -= delta
		if not _is_inside_any_building():
			_stop_escape()
		elif _escape_timer <= 0.0:
			global_position = _escape_target
			_stop_escape()
		else:
			var dir := global_position.direction_to(_escape_target)
			velocity = dir * stat_set.get_value(StatSetClass.MOVE_SPEED)
			move_and_slide()
			attack_timer = max(0.0, attack_timer - delta)
			_update_aggro_line()
			_update_animation()
			_update_state_indicator()
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

	# 减速效果
	if _slow_timer > 0.0:
		_slow_timer -= delta
		velocity *= _slow_factor
		if _effects_material:
			_effects_material.set_shader_parameter("slow_enabled", true)
	else:
		if _effects_material and _effects_material.get_shader_parameter("slow_enabled"):
			_effects_material.set_shader_parameter("slow_enabled", false)
	if velocity.length_squared() > 1.0:
		var prev_pos := global_position
		move_and_slide()
		var actual_move := global_position.distance_to(prev_pos)
		var expected_move = stat_set.get_value(StatSetClass.MOVE_SPEED) * delta
		if actual_move < expected_move * 0.3:
			velocity = Vector2.ZERO
			_blocked_timer = min(_blocked_timer + delta, 2.0)
			var was_blocked := _is_blocked
			_is_blocked = _blocked_timer > 0.1
			if _is_blocked and not was_blocked:
				_show_debug_text("Blocked!", Color(1.0, 0.5, 0.2))
				if _is_inside_any_building():
					_start_escape()
		else:
			if _is_blocked:
				_blocked_timer -= delta * 0.1
				if _blocked_timer <= 0.0:
					_is_blocked = false
					_blocked_timer = 0.0
			else:
				_blocked_timer = 0.0
	else:
		_blocked_timer = max(_blocked_timer - delta, 0.0)
		if _blocked_timer <= 0.0:
			_is_blocked = false

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
	velocity = direction * stat_set.get_value(StatSetClass.MOVE_SPEED)

func _attack_process(delta: float) -> void:
	# Monk不攻击，站着不动
	if unit_type == UnitType.MONK:
		return

	if attack_target == null or attack_target.is_dead():
		attack_target = null
		attack_command_source = CommandSource.NONE
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
	if dist > get_effective_attack_range():
		if hold_position_mode:
			attack_target = null
			attack_command_source = CommandSource.NONE
			_is_attacking = false
			state = UnitState.HOLD_POSITION
			return

		# Attack-Move 清区域：目标跑出扫描范围就放弃，换最近的
		if attack_move_target != Vector2.ZERO and attack_command_source == CommandSource.AUTO:
			var dist_to_target := global_position.distance_to(attack_target.global_position)
			if dist_to_target > attack_move_scan_range:
				attack_target = null
				attack_command_source = CommandSource.NONE
				_is_attacking = false
				nav_agent.target_position = attack_move_target
				state = UnitState.ATTACK_MOVE
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

		# 只有被堵住时才横向挣脱，否则直走
		if _is_blocked:
			velocity = _get_steered_direction(base_dir, delta) * stat_set.get_value(StatSetClass.MOVE_SPEED)
		else:
			_lateral_dir = Vector2.ZERO
			_lateral_timer = 0.0
			velocity = base_dir * stat_set.get_value(StatSetClass.MOVE_SPEED)
	else:
		if attack_timer <= 0.0:
			_perform_attack()
			attack_timer = stat_set.get_value(StatSetClass.ATTACK_COOLDOWN)

func _attack_move_process(delta: float) -> void:
	# Monk 攻击移动时优先治疗
	if unit_type == UnitType.MONK:
		var wounded = _find_wounded_ally(stat_set.get_value(StatSetClass.HEAL_SCAN_RANGE))
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
		if _is_blocked:
			velocity = _get_steered_direction(base_dir, delta) * stat_set.get_value(StatSetClass.MOVE_SPEED)
		else:
			_lateral_dir = Vector2.ZERO
			_lateral_timer = 0.0
			velocity = base_dir * stat_set.get_value(StatSetClass.MOVE_SPEED)
		return

	var closest = _find_closest_enemy_in_range(attack_move_scan_range)

	if closest != null:
		attack_target = closest
		attack_command_source = CommandSource.AUTO
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
	if _is_blocked:
		velocity = _get_steered_direction(base_dir2, delta) * stat_set.get_value(StatSetClass.MOVE_SPEED)
	else:
		_lateral_dir = Vector2.ZERO
		_lateral_timer = 0.0
		velocity = base_dir2 * stat_set.get_value(StatSetClass.MOVE_SPEED)

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
		if u.health.hp >= u.health.max_hp:
			continue
		var d := global_position.distance_to(u.global_position)
		if d < scan_range and d < closest_dist:
			closest = u
			closest_dist = d
	return closest

func _heal_process(delta: float) -> void:
	if heal_target == null or heal_target.is_dead() or heal_target.health.hp >= heal_target.health.max_hp:
		heal_target = null
		_is_healing = false
		state = UnitState.GUARD
		return
	var dist := global_position.distance_to(heal_target.global_position)
	if dist > stat_set.get_value(StatSetClass.HEAL_RANGE):
		nav_agent.target_position = heal_target.global_position
		if not nav_agent.is_navigation_finished():
			var next_pos := nav_agent.get_next_path_position()
			velocity = global_position.direction_to(next_pos) * stat_set.get_value(StatSetClass.MOVE_SPEED)
	else:
		if attack_timer <= 0.0:
			heal_target.heal(stat_set.get_int(StatSetClass.HEAL_AMOUNT))
			attack_timer = stat_set.get_value(StatSetClass.HEAL_COOLDOWN)
			_is_healing = true

func _patrol_process(delta: float) -> void:
	if patrol_points.is_empty():
		state = UnitState.GUARD
		return
	# 巡逻中遇敌自动交战
	var closest = _find_closest_enemy_in_range(attack_move_scan_range)
	if closest != null:
		attack_target = closest
		attack_command_source = CommandSource.AUTO
		nav_agent.target_position = _get_building_nav_target(closest)
		state = UnitState.ATTACK
		return
	# 移动到当前巡逻点
	var target: Vector2 = patrol_points[patrol_index]
	if global_position.distance_to(target) < 20.0:
		patrol_index = (patrol_index + 1) % patrol_points.size()
		target = patrol_points[patrol_index]
	nav_agent.target_position = target
	if not nav_agent.is_navigation_finished():
		var next_pos := nav_agent.get_next_path_position()
		velocity = global_position.direction_to(next_pos) * stat_set.get_value(StatSetClass.MOVE_SPEED)

func _guard_process(delta: float) -> void:
	# Monk 优先寻找受伤友军
	if unit_type == UnitType.MONK:
		var wounded = _find_wounded_ally(stat_set.get_value(StatSetClass.HEAL_SCAN_RANGE))
		if wounded != null:
			heal_target = wounded
			nav_agent.target_position = wounded.global_position
			state = UnitState.HEAL
		return

	var closest = _find_closest_enemy_in_range(attack_move_scan_range)
	if closest != null:
		attack_target = closest
		attack_command_source = CommandSource.AUTO
		nav_agent.target_position = _get_building_nav_target(closest)
		state = UnitState.ATTACK
		hold_position_mode = false

func _hold_position_process(delta: float) -> void:
	var closest = _find_closest_enemy_in_range(get_effective_attack_range())
	if closest != null:
		attack_target = closest
		attack_command_source = CommandSource.AUTO
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

func _show_debug_text(text: String, color: Color) -> void:
	var ft := Node2D.new()
	ft.set_script(load("res://scripts/effects/floating_text.gd"))
	get_tree().current_scene.add_child(ft)
	ft.setup(text, color, global_position + Vector2(0, -20))

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
		var damage = stat_set.get_int(StatSetClass.ATTACK_DAMAGE)
		if unit_type == UnitType.ARCHER:
			_spawn_arrow(attack_target, damage)
		else:
			attack_target.take_damage(damage, self)

func _spawn_arrow(target, damage: int = -1) -> void:
	var spawner = get_tree().current_scene.get("spawner_module")
	if spawner:
		spawner.spawn_projectile(null, global_position, target.global_position, target, self, damage)

func take_damage(amount: int, attacker = null) -> void:
	if Engine.is_editor_hint():
		return
	if health.is_dead():
		return
	var final_amount := amount
	var reduction = stat_set.get_value(StatSetClass.DAMAGE_REDUCTION)
	if reduction > 0.0:
		final_amount = int(amount * (1.0 - reduction))
	health.take_damage(final_amount)
	# 伤害飘字
	if final_amount > 0:
		var main_node := get_tree().current_scene
		if main_node and main_node.has_method("show_damage_number"):
			main_node.show_damage_number(final_amount, global_position)
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
	# 玩家手动指定的攻击目标不被自动索敌打断
	if attack_command_source == CommandSource.PLAYER:
		return
	# 玩家移动指令不被自动反击打断
	if state == UnitState.MOVE:
		return
	# 验证攻击者仍存活
	if attacker == null or not is_instance_valid(attacker) or attacker.is_dead():
		return

	attack_target = attacker
	attack_command_source = CommandSource.AUTO
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

func _reset_movement_state() -> void:
	_is_blocked = false
	_blocked_timer = 0.0
	_lateral_dir = Vector2.ZERO
	_lateral_timer = 0.0
	follow_target = null

func command_patrol(points: Array) -> void:
	_reset_movement_state()
	patrol_points = points
	patrol_index = 0
	attack_target = null
	attack_command_source = CommandSource.NONE
	hold_position_mode = false
	heal_target = null
	_is_healing = false
	if not patrol_points.is_empty():
		nav_agent.target_position = patrol_points[0]
		state = UnitState.PATROL

func command_follow(target) -> void:
	_reset_movement_state()
	follow_target = target
	attack_target = null
	attack_command_source = CommandSource.NONE
	hold_position_mode = false
	heal_target = null
	_is_healing = false
	state = UnitState.MOVE

func queue_move(target_pos: Vector2) -> void:
	var cmd := CommandQueue.QueuedCommand.new()
	cmd.type = CommandQueue.CommandType.MOVE
	cmd.target_pos = target_pos
	command_queue.enqueue(cmd)

func queue_attack_move(target_pos: Vector2) -> void:
	var cmd := CommandQueue.QueuedCommand.new()
	cmd.type = CommandQueue.CommandType.ATTACK_MOVE
	cmd.target_pos = target_pos
	command_queue.enqueue(cmd)

func queue_attack_target(target) -> void:
	var cmd := CommandQueue.QueuedCommand.new()
	cmd.type = CommandQueue.CommandType.ATTACK_TARGET
	cmd.target_pos = target.global_position if target else Vector2.ZERO
	cmd.target_unit = weakref(target) if target else null
	command_queue.enqueue(cmd)

func _try_dequeue_next_command() -> void:
	if command_queue.is_empty():
		return
	var cmd := command_queue.dequeue()
	match cmd.type:
		CommandQueue.CommandType.MOVE:
			move_to(cmd.target_pos)
		CommandQueue.CommandType.ATTACK_MOVE:
			attack_move_to(cmd.target_pos)
		CommandQueue.CommandType.ATTACK_TARGET:
			var target: Variant = cmd.target_unit.get_ref() if cmd.target_unit else null
			if is_instance_valid(target) and target.has_method("is_dead") and not target.is_dead():
				command_attack(target)
			else:
				_try_dequeue_next_command()

func move_to(target_pos: Vector2) -> void:
	_reset_movement_state()
	attack_target = null
	attack_command_source = CommandSource.NONE
	attack_move_target = Vector2.ZERO
	hold_position_mode = false
	heal_target = null
	_is_healing = false
	nav_agent.target_position = target_pos
	state = UnitState.MOVE

func attack_move_to(target_pos: Vector2) -> void:
	_reset_movement_state()
	attack_target = null
	attack_command_source = CommandSource.NONE
	attack_move_target = target_pos
	hold_position_mode = false
	heal_target = null
	_is_healing = false
	nav_agent.target_position = target_pos
	state = UnitState.ATTACK_MOVE

func stop() -> void:
	_reset_movement_state()
	attack_target = null
	attack_command_source = CommandSource.NONE
	attack_move_target = Vector2.ZERO
	_is_attacking = false
	hold_position_mode = false
	heal_target = null
	_is_healing = false
	velocity = Vector2.ZERO
	nav_agent.target_position = global_position
	state = UnitState.GUARD

func hold_position() -> void:
	_reset_movement_state()
	attack_target = null
	attack_command_source = CommandSource.NONE
	attack_move_target = Vector2.ZERO
	_is_attacking = false
	hold_position_mode = true
	heal_target = null
	_is_healing = false
	velocity = Vector2.ZERO
	nav_agent.target_position = global_position
	state = UnitState.HOLD_POSITION

func command_attack(target) -> void:
	_reset_movement_state()
	attack_target = target
	attack_command_source = CommandSource.PLAYER
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
		if selected:
			selection_ring.team_color = Color(0.3, 0.6, 1.0, 0.6) if team == Team.PLAYER else Color(1.0, 0.3, 0.3, 0.6)
			if not _was_selected:
				selection_ring.flash()
	# 发光 shader uniform 切换
	if _effects_material:
		_effects_material.set_shader_parameter("outline_enabled", selected)
	_was_selected = selected
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

# ============================================================
# Buff 系统
# ============================================================
func apply_buff(buff_type: String, value: float) -> void:
	var now_msec := Time.get_ticks_msec()
	buffs[buff_type] = {"value": value, "expire": now_msec + 1500}
	# 同步修饰器到 StatSet
	match buff_type:
		"defense":
			stat_set.add_modifier("buff:defense", StatSetClass.DAMAGE_REDUCTION, 0.0, 1.0 - value)
		"attack_melee":
			stat_set.add_modifier("buff:attack_melee", StatSetClass.ATTACK_DAMAGE, 0.0, 1.0 + value)
		"range_bonus":
			stat_set.add_modifier("buff:range_bonus", StatSetClass.ATTACK_RANGE, value, 1.0)

func _expire_buffs() -> void:
	var now_msec := Time.get_ticks_msec()
	var expired := []
	for buff_type in buffs:
		if now_msec > buffs[buff_type]["expire"]:
			expired.append(buff_type)
	for bt in expired:
		buffs.erase(bt)
		stat_set.remove_source("buff:" + bt)

func has_buff(buff_type: String) -> bool:
	if buff_type not in buffs:
		return false
	if Time.get_ticks_msec() > buffs[buff_type]["expire"]:
		buffs.erase(buff_type)
		stat_set.remove_source("buff:" + buff_type)
		return false
	return true

func get_buff_value(buff_type: String) -> float:
	if not has_buff(buff_type):
		return 0.0
	return buffs[buff_type]["value"]

func apply_slow(factor: float, duration: float) -> void:
	_slow_factor = 1.0 - factor
	_slow_timer = duration

func get_effective_attack_range() -> float:
	return stat_set.get_value(StatSetClass.ATTACK_RANGE)
