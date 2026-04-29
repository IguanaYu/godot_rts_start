extends Node2D

enum BuildingType { WALL, TOWER }
enum Team { PLAYER, ENEMY }

@export var building_type: BuildingType = BuildingType.WALL
@export var team: Team = Team.PLAYER

var hp: int
var max_hp: int
var grid_size: Vector2i = Vector2i(1, 1)
var grid_pos: Vector2i = Vector2i.ZERO
var _is_dead: bool = false

# 箭塔攻击
var attack_target = null
var attack_damage: float = 12.0
var attack_range: float = 150.0
var attack_cooldown: float = 1.5
var attack_timer: float = 0.0

signal died(building)

@onready var static_body: StaticBody2D = $StaticBody2D
@onready var collision_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var body_visual: ColorRect = $BodyVisual
@onready var type_label: Label = $BodyVisual/TypeLabel
@onready var hp_bar: ProgressBar = $HPBar
@onready var aggro_line: Line2D = $AggroLine

func _ready() -> void:
	_setup_stats()
	_setup_visuals()
	_update_hp_bar()

func _setup_stats() -> void:
	match building_type:
		BuildingType.WALL:
			max_hp = 300
			grid_size = Vector2i(2, 1)
		BuildingType.TOWER:
			max_hp = 150
			grid_size = Vector2i(1, 1)
	hp = max_hp

func _setup_visuals() -> void:
	var pixel_size := Vector2(grid_size.x * 64, grid_size.y * 64)

	# 视觉
	body_visual.size = pixel_size
	body_visual.position = -pixel_size / 2.0

	if building_type == BuildingType.WALL:
		body_visual.color = Color(0.5, 0.5, 0.55) if team == Team.PLAYER else Color(0.6, 0.35, 0.35)
		type_label.text = "W"
	else:
		body_visual.color = Color(0.6, 0.4, 0.2) if team == Team.PLAYER else Color(0.7, 0.3, 0.2)
		type_label.text = "T"

	# 碰撞
	var shape := RectangleShape2D.new()
	shape.size = pixel_size
	collision_shape.shape = shape

	# 血条位置
	hp_bar.offset_left = -pixel_size.x / 2.0
	hp_bar.offset_right = pixel_size.x / 2.0
	hp_bar.offset_top = -pixel_size.y / 2.0 - 12.0
	hp_bar.offset_bottom = -pixel_size.y / 2.0 - 4.0

func is_dead() -> bool:
	return _is_dead

func get_rect() -> Rect2:
	var pixel_size := Vector2(grid_size.x * 64, grid_size.y * 64)
	return Rect2(global_position - pixel_size / 2.0, pixel_size)

func _process(delta: float) -> void:
	if _is_dead:
		return
	if building_type == BuildingType.TOWER:
		_tower_process(delta)

func _tower_process(delta: float) -> void:
	attack_timer = max(0.0, attack_timer - delta)

	# 验证当前目标
	if attack_target != null:
		if not is_instance_valid(attack_target) or attack_target.is_dead():
			attack_target = null
		elif global_position.distance_to(attack_target.global_position) > attack_range:
			attack_target = null

	# 寻找目标
	if attack_target == null:
		var enemy_group := "player_units" if team == Team.ENEMY else "enemy_units"
		var closest = null
		var closest_dist: float = INF
		for u in get_tree().get_nodes_in_group(enemy_group):
			if u.is_dead():
				continue
			var d: float = global_position.distance_to(u.global_position)
			if d < attack_range and d < closest_dist:
				closest = u
				closest_dist = d
		attack_target = closest

	# 仇恨线
	if attack_target != null:
		aggro_line.visible = true
		aggro_line.clear_points()
		aggro_line.add_point(Vector2.ZERO)
		aggro_line.add_point(attack_target.global_position - global_position)
	else:
		aggro_line.visible = false

	# 射箭
	if attack_target != null and attack_timer <= 0.0:
		_spawn_arrow(attack_target)
		attack_timer = attack_cooldown

func _spawn_arrow(target) -> void:
	var arrow_scene := load("res://scenes/arrow.tscn")
	var arrow: Node2D = arrow_scene.instantiate()
	get_tree().current_scene.add_child(arrow)
	arrow.setup(global_position, target.global_position)
	arrow.hit_target = target
	arrow.hit_damage = int(attack_damage)

func take_damage(amount: int) -> void:
	if _is_dead:
		return
	hp = max(0, hp - amount)
	_update_hp_bar()
	if hp <= 0:
		die()

func die() -> void:
	_is_dead = true
	died.emit(self)
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
	tween.tween_callback(queue_free)

func _update_hp_bar() -> void:
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = hp
