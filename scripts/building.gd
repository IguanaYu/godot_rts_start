extends Node2D

enum BuildingType { WALL, TOWER, CASTLE, BARRACKS }
enum Team { PLAYER, ENEMY }

@export var building_type: BuildingType = BuildingType.WALL
@export var team: Team = Team.PLAYER
@export var shadow_scale_x: float = 0.85
@export var shadow_scale_y: float = 0.45
@export var shadow_alpha: float = 0.35
@export var sprite_lift_ratio: float = 0.15

var hp: int
var max_hp: int
var grid_size: Vector2i = Vector2i(1, 1)
var grid_pos: Vector2i = Vector2i.ZERO
var _is_dead: bool = false
var _shadow: Sprite2D = null

# 箭塔攻击
var attack_target = null
var attack_damage: float = 12.0
var attack_range: float = 150.0
var attack_cooldown: float = 1.5
var attack_timer: float = 0.0

signal died(building)

@onready var static_body: StaticBody2D = $StaticBody2D
@onready var collision_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var body_sprite: Sprite2D = $BodySprite
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
			grid_size = Vector2i(1, 1)
			shadow_scale_x = 0.85
			shadow_scale_y = 0.45
			sprite_lift_ratio = 0.12
		BuildingType.TOWER:
			max_hp = 150
			grid_size = Vector2i(1, 1)
			shadow_scale_x = 0.85
			shadow_scale_y = 0.45
			sprite_lift_ratio = 0.18
		BuildingType.CASTLE:
			max_hp = 500
			grid_size = Vector2i(3, 3)
			shadow_scale_x = 0.7
			shadow_scale_y = 0.4
			sprite_lift_ratio = 0.18
		BuildingType.BARRACKS:
			max_hp = 250
			grid_size = Vector2i(2, 2)
			shadow_scale_x = 0.8
			shadow_scale_y = 0.4
			sprite_lift_ratio = 0.18
	hp = max_hp

func _setup_visuals() -> void:
	var pixel_size := Vector2(grid_size.x * 64, grid_size.y * 64)

	# 贴图
	var color_dir := "blue" if team == Team.PLAYER else "red"
	var tex_path := ""
	match building_type:
		BuildingType.WALL:
			tex_path = "res://assets/buildings/%s_house/House1.png" % color_dir
		BuildingType.TOWER:
			tex_path = "res://assets/buildings/%s_tower/Tower.png" % color_dir
		BuildingType.CASTLE:
			tex_path = "res://assets/buildings/%s_castle/Castle.png" % color_dir
		BuildingType.BARRACKS:
			tex_path = "res://assets/buildings/%s_barracks/Barracks.png" % color_dir
	if tex_path != "":
		var tex := load(tex_path)
		if tex and body_sprite:
			body_sprite.texture = tex

	# 碰撞
	var shape := RectangleShape2D.new()
	shape.size = pixel_size
	collision_shape.shape = shape

	# 血条位置（基于贴图实际高度）
	var sprite_height: float = pixel_size.y
	if body_sprite.texture:
		sprite_height = body_sprite.texture.get_height() * body_sprite.scale.y
	hp_bar.offset_left = -pixel_size.x / 2.0
	hp_bar.offset_right = pixel_size.x / 2.0
	hp_bar.offset_top = -sprite_height / 2.0 - 8.0
	hp_bar.offset_bottom = -sprite_height / 2.0

	# 创建脚底影子
	_shadow = Sprite2D.new()
	var shadow_w := int(pixel_size.x * shadow_scale_x)
	var shadow_h := int(pixel_size.y * shadow_scale_y)
	var img := Image.create(shadow_w, shadow_h, false, Image.FORMAT_RGBA8)
	for x in range(shadow_w):
		for y in range(shadow_h):
			var dx := (float(x) - shadow_w / 2.0) / (shadow_w / 2.0)
			var dy := (float(y) - shadow_h / 2.0) / (shadow_h / 2.0)
			if dx * dx + dy * dy <= 1.0:
				img.set_pixel(x, y, Color(0, 0, 0, shadow_alpha))
	_shadow.texture = ImageTexture.create_from_image(img)
	_shadow.z_index = 0
	add_child(_shadow)
	move_child(_shadow, 0)

	# 贴图上移，形成站立效果
	var lift: float = sprite_height * sprite_lift_ratio
	body_sprite.position.y = -lift
	# HPBar 跟随上移
	hp_bar.offset_top += lift
	hp_bar.offset_bottom += lift

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
