extends "res://scripts/neutral.gd"

enum SheepState { IDLE, MOVING, EATING }

var state: SheepState = SheepState.IDLE
var state_timer: float = 0.0
var wander_target: Vector2 = Vector2.ZERO
var home_pos: Vector2 = Vector2.ZERO
var wander_radius: float = 100.0
var move_speed: float = 30.0

# 动画
var _anim_frame: int = 0
var _anim_timer: float = 0.0
var _anim_fps: float = 6.0
var _total_frames: int = 6
var _tex_idle: Texture2D = null
var _tex_move: Texture2D = null
var _tex_grass: Texture2D = null

func _ready() -> void:
	super._ready()
	_tex_idle = load("res://assets/environment/sheep/Sheep_Idle.png")
	_tex_move = load("res://assets/environment/sheep/Sheep_Move.png")
	_tex_grass = load("res://assets/environment/sheep/Sheep_Grass.png")
	home_pos = global_position
	_set_state(SheepState.IDLE)

func _process(delta: float) -> void:
	state_timer -= delta
	match state:
		SheepState.IDLE:
			_idle_process()
		SheepState.MOVING:
			_move_process(delta)
		SheepState.EATING:
			_eat_process()
	_update_animation(delta)

func _idle_process() -> void:
	if state_timer <= 0.0:
		_set_state(SheepState.MOVING)
		var angle := randf() * TAU
		var radius := randf() * wander_radius
		wander_target = home_pos + Vector2(cos(angle), sin(angle)) * radius

func _move_process(delta: float) -> void:
	var dist := global_position.distance_to(wander_target)
	if dist < 5.0 or state_timer <= 0.0:
		_set_state(SheepState.EATING if randf() < 0.4 else SheepState.IDLE)
		return
	var dir := global_position.direction_to(wander_target)
	global_position += dir * move_speed * delta

func _eat_process() -> void:
	if state_timer <= 0.0:
		_set_state(SheepState.IDLE)

func _set_state(new_state: SheepState) -> void:
	state = new_state
	_anim_frame = 0
	_anim_timer = 0.0
	match new_state:
		SheepState.IDLE:
			body_sprite.texture = _tex_idle
			body_sprite.hframes = 6
			_total_frames = 6
			state_timer = randf_range(2.0, 5.0)
			_anim_fps = 4.0
		SheepState.MOVING:
			body_sprite.texture = _tex_move
			body_sprite.hframes = 4
			_total_frames = 4
			state_timer = randf_range(3.0, 6.0)
			_anim_fps = 6.0
		SheepState.EATING:
			body_sprite.texture = _tex_grass
			body_sprite.hframes = 12
			_total_frames = 12
			state_timer = randf_range(2.0, 4.0)
			_anim_fps = 6.0

func _update_animation(delta: float) -> void:
	_anim_timer += delta
	var frame_duration := 1.0 / _anim_fps
	if _anim_timer >= frame_duration:
		_anim_timer -= frame_duration
		_anim_frame += 1
		if _anim_frame >= _total_frames:
			_anim_frame = 0
		body_sprite.frame = _anim_frame
