class_name EscortNPC
extends CharacterBody2D

## 护送NPC系统
## 沿指定路径移动，可被攻击

signal died(npc: EscortNPC)
signal reached_waypoint(index: int)
signal reached_destination(npc: EscortNPC)

@export var path_points: Array[Vector2] = []
@export var move_speed: float = 60.0
@export var stop_at_each_point: bool = false
@export var stop_duration: float = 2.0
@export var hp: int = 200
@export var npc_name_key: String = "ESCORT_NPC"

var _current_waypoint: int = 0
var _is_dead: bool = false
var _is_moving: bool = false
var _stop_timer: float = 0.0
var _health: int
var nav_agent: NavigationAgent2D
var _paused: bool = false

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	add_to_group("neutral_units")

	_health = hp
	_is_moving = false

	# 创建NavigationAgent2D
	nav_agent = NavigationAgent2D.new()
	nav_agent.path_desired_distance = 10.0
	nav_agent.target_desired_distance = 10.0
	nav_agent.path_max_distance = 100.0
	add_child(nav_agent)

	# 等待导航区域可用
	await get_tree().physics_frame
	if nav_agent:
		nav_agent.navigation_finished.connect(_on_navigation_finished)

	# 开始移动到第一个路点
	if path_points.size() > 0:
		_start_move_to_waypoint(0)

func _start_move_to_waypoint(index: int) -> void:
	if index >= path_points.size():
		# 到达终点
		reached_destination.emit(self)
		return

	_current_waypoint = index
	_is_moving = true

	if nav_agent:
		nav_agent.set_target_location(path_points[index])

func _on_navigation_finished() -> void:
	if _is_dead:
		return

	_is_moving = false

	if stop_at_each_point:
		# 停留一段时间
		_stop_timer = stop_duration
	else:
		# 直接前往下一个路点
		_advance_to_next_waypoint()

	reached_waypoint.emit(_current_waypoint)

func _advance_to_next_waypoint() -> void:
	_current_waypoint += 1
	if _current_waypoint >= path_points.size():
		# 到达终点
		reached_destination.emit(self)
	else:
		_start_move_to_waypoint(_current_waypoint)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() or _is_dead or _paused:
		return

	# 处理停留计时器
	if _stop_timer > 0:
		_stop_timer -= delta
		if _stop_timer <= 0:
			_advance_to_next_waypoint()
		return

	# 移动逻辑
	if nav_agent and _is_moving and not nav_agent.is_navigation_finished():
		var next_pos := nav_agent.get_next_path_position()
		var direction := (next_pos - global_position).normalized()
		velocity = direction * move_speed
		move_and_slide()

func take_damage(amount: int, attacker = null) -> void:
	if _is_dead:
		return

	_health -= amount
	# 这里可以添加飘字效果

	if _health <= 0:
		die()

func die() -> void:
	if _is_dead:
		return

	_is_dead = true
	died.emit(self)
	# 播放死亡动画
	queue_free()

func is_dead() -> bool:
	return _is_dead

func pause_movement() -> void:
	_paused = true

func resume_movement() -> void:
	_paused = false
