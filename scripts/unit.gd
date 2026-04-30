extends CharacterBody2D
class_name Unit

enum UnitState { IDLE, MOVE, ATTACK_MOVE, ATTACK, DEAD }
enum UnitType { SOLDIER, ARCHER }
enum Team { PLAYER, ENEMY }

@export var unit_type: UnitType = UnitType.SOLDIER
@export var team: Team = Team.PLAYER

var max_hp: int
var hp: int
var attack_damage: int
var attack_range: float
var attack_cooldown: float
var move_speed: float

var state: UnitState = UnitState.IDLE
var attack_target = null
var attack_timer: float = 0.0
var selected: bool = false
var attack_move_target: Vector2 = Vector2.ZERO
var attack_move_scan_range: float = 300.0

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
var _shadow: Sprite2D = null

signal died(unit: Unit)

func _ready() -> void:
	_setup_stats()
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
	hp = max_hp

func _setup_visuals() -> void:
	var color_dir := "blue" if team == Team.PLAYER else "red"
	var unit_name := "warrior" if unit_type == UnitType.SOLDIER else "archer"
	var base := "res://assets/units/%s_%s" % [color_dir, unit_name]

	_tex_idle = load(base + "/Warrior_Idle.png" if unit_type == UnitType.SOLDIER else base + "/Archer_Idle.png")
	_tex_run = load(base + "/Warrior_Run.png" if unit_type == UnitType.SOLDIER else base + "/Archer_Run.png")
	_tex_attack = load(base + "/Warrior_Attack1.png" if unit_type == UnitType.SOLDIER else base + "/Archer_Shoot.png")
	_frames_idle = _tex_idle.get_width() / 192 if _tex_idle else 6
	_frames_run = _tex_run.get_width() / 192 if _tex_run else 6
	_frames_attack = _tex_attack.get_width() / 192 if _tex_attack else 6
	_set_anim("idle")

	# 创建脚底影子
	_shadow = Sprite2D.new()
	var shadow_size := Vector2i(32, 16)
	var img := Image.create(shadow_size.x, shadow_size.y, false, Image.FORMAT_RGBA8)
	for x in range(shadow_size.x):
		for y in range(shadow_size.y):
			var dx := (float(x) - shadow_size.x / 2.0) / (shadow_size.x / 2.0)
			var dy := (float(y) - shadow_size.y / 2.0) / (shadow_size.y / 2.0)
			if dx * dx + dy * dy <= 1.0:
				img.set_pixel(x, y, Color(0, 0, 0, 0.4))
	_shadow.texture = ImageTexture.create_from_image(img)
	_shadow.z_index = 0
	add_child(_shadow)
	move_child(_shadow, 0)

	# 贴图上移，形成站立效果
	body_sprite.position.y = -20
	# HPBar 跟随上移
	hp_bar.offset_top += 20
	hp_bar.offset_bottom += 20

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
	_set_anim(target_anim)

func _physics_process(delta: float) -> void:
	if state == UnitState.DEAD:
		return

	velocity = Vector2.ZERO

	match state:
		UnitState.MOVE:
			_move_process()
		UnitState.ATTACK_MOVE:
			_attack_move_process(delta)
		UnitState.ATTACK:
			_attack_process(delta)

	if velocity.length_squared() > 1.0:
		move_and_slide()

	attack_timer = max(0.0, attack_timer - delta)
	_update_aggro_line()
	_update_animation()

func _move_process() -> void:
	if nav_agent.is_navigation_finished():
		state = UnitState.IDLE
		return
	var next_pos := nav_agent.get_next_path_position()
	var direction := global_position.direction_to(next_pos)
	velocity = direction * move_speed

func _attack_process(delta: float) -> void:
	if attack_target == null or attack_target.is_dead():
		attack_target = null
		# 如果之前是攻击移动，继续移动
		if attack_move_target != Vector2.ZERO:
			nav_agent.target_position = attack_move_target
			state = UnitState.ATTACK_MOVE
		else:
			state = UnitState.IDLE
		return

	var dist := global_position.distance_to(attack_target.global_position)
	# 建筑有碰撞体，需要加上碰撞半径才能实际到达攻击范围
	var effective_attack_range := attack_range
	if attack_target.has_method("get_rect"):
		var brect: Rect2 = attack_target.get_rect()
		var building_radius: float = max(brect.size.x, brect.size.y) / 2.0
		effective_attack_range = attack_range + building_radius
	if dist > effective_attack_range:
		nav_agent.target_position = attack_target.global_position
		if not nav_agent.is_navigation_finished():
			var next_pos := nav_agent.get_next_path_position()
			velocity = global_position.direction_to(next_pos) * move_speed
	else:
		if attack_timer <= 0.0:
			_perform_attack()
			attack_timer = attack_cooldown

func _attack_move_process(delta: float) -> void:
	# 扫描附近敌方单位
	var enemy_group := "enemy_units" if team == Team.PLAYER else "player_units"
	var enemy_building_group := "enemy_buildings" if team == Team.PLAYER else "player_buildings"
	var closest = null
	var closest_dist: float = INF
	for u in get_tree().get_nodes_in_group(enemy_group):
		if u.is_dead():
			continue
		var d := global_position.distance_to(u.global_position)
		if d < attack_move_scan_range and d < closest_dist:
			closest = u
			closest_dist = d

	# 也扫描敌方建筑
	for b in get_tree().get_nodes_in_group(enemy_building_group):
		if not b.has_method("is_dead") or b.is_dead():
			continue
		var d := global_position.distance_to(b.global_position)
		if d < attack_move_scan_range and d < closest_dist:
			closest = b
			closest_dist = d

	if closest != null:
		attack_target = closest
		nav_agent.target_position = closest.global_position
		state = UnitState.ATTACK
		return

	# 没有敌人，继续移动
	if nav_agent.is_navigation_finished():
		state = UnitState.IDLE
		return
	var next_pos := nav_agent.get_next_path_position()
	velocity = global_position.direction_to(next_pos) * move_speed

func _perform_attack() -> void:
	if attack_target and not attack_target.is_dead():
		_is_attacking = true
		_set_anim("")
		_set_anim("attack")
		if unit_type == UnitType.ARCHER:
			_spawn_arrow(attack_target)
		else:
			attack_target.take_damage(attack_damage)

func _spawn_arrow(target) -> void:
	var arrow_scene := load("res://scenes/arrow.tscn")
	var arrow: Node2D = arrow_scene.instantiate()
	get_tree().current_scene.add_child(arrow)
	arrow.setup(global_position, target.global_position)
	arrow.hit_target = target
	arrow.hit_damage = attack_damage

func take_damage(amount: int) -> void:
	if state == UnitState.DEAD:
		return
	hp = max(0, hp - amount)
	_update_hp_bar()
	if hp <= 0:
		die()

func die() -> void:
	state = UnitState.DEAD
	died.emit(self)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
	tween.tween_callback(queue_free)

func move_to(target_pos: Vector2) -> void:
	attack_target = null
	attack_move_target = Vector2.ZERO
	nav_agent.target_position = target_pos
	state = UnitState.MOVE

func attack_move_to(target_pos: Vector2) -> void:
	attack_target = null
	attack_move_target = target_pos
	nav_agent.target_position = target_pos
	state = UnitState.ATTACK_MOVE

func stop() -> void:
	attack_target = null
	attack_move_target = Vector2.ZERO
	_is_attacking = false
	velocity = Vector2.ZERO
	nav_agent.target_position = global_position
	state = UnitState.IDLE

func command_attack(target) -> void:
	attack_target = target
	nav_agent.target_position = target.global_position
	state = UnitState.ATTACK

func set_selected(value: bool) -> void:
	selected = value
	_update_selection_ring()

func _update_selection_ring() -> void:
	if selection_ring:
		selection_ring.visible = selected

func _update_hp_bar() -> void:
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = hp

func _update_aggro_line() -> void:
	if state == UnitState.DEAD or aggro_line == null:
		return
	if attack_target != null and not attack_target.is_dead():
		aggro_line.visible = true
		aggro_line.clear_points()
		aggro_line.add_point(Vector2.ZERO)
		aggro_line.add_point(attack_target.global_position - global_position)
	else:
		aggro_line.visible = false

func is_dead() -> bool:
	return state == UnitState.DEAD
