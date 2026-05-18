@tool
extends Node2D

enum BuildingType { WALL, TOWER, CASTLE, BARRACKS, MONASTERY, ARCHERY }
enum Team { PLAYER, ENEMY }

@export var building_type: BuildingType = BuildingType.WALL:
	set(v): building_type = v; _refresh_editor()
@export var team: Team = Team.PLAYER
@export var shadow_scale_x: float = 0.85:
	set(v): shadow_scale_x = v; _refresh_editor()
@export var shadow_scale_y: float = 0.45:
	set(v): shadow_scale_y = v; _refresh_editor()
@export var shadow_alpha: float = 0.35:
	set(v): shadow_alpha = v; _refresh_editor()
@export var shadow_offset_x: float = 0.0:
	set(v): shadow_offset_x = v; _refresh_editor()
@export var shadow_offset_y: float = 0.0:
	set(v): shadow_offset_y = v; _refresh_editor()
@export var sprite_scale_x: float = 0.4:
	set(v): sprite_scale_x = v; _refresh_editor()
@export var sprite_scale_y: float = 0.4:
	set(v): sprite_scale_y = v; _refresh_editor()
@export var sprite_lift_ratio: float = 0.15:
	set(v): sprite_lift_ratio = v; _refresh_editor()
@export var sprite_offset_x: float = 0.0:
	set(v): sprite_offset_x = v; _refresh_editor()
@export var sprite_offset_y: float = 0.0:
	set(v): sprite_offset_y = v; _refresh_editor()

var grid_size: Vector2i = Vector2i(1, 1)
var grid_pos: Vector2i = Vector2i.ZERO
var _is_dead: bool = false
const ShadowComp := preload("res://scripts/core/shadow_component.gd")
@onready var _shadow_component: ShadowComp = $ShadowComponent
const HealthComp := preload("res://scripts/core/health_component.gd")
@onready var health: HealthComp = $HealthComponent
const JellyEffect := preload("res://scripts/effects/jelly_effect.gd")

# 建造系统
var build_time: float = 5.0
var build_progress: float = 0.0
var is_constructed: bool = true
var build_bar: ProgressBar = null

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
	if Engine.is_editor_hint():
		_setup_editor_visuals()
	else:
		_setup_visuals()
		_update_hp_bar()

func _setup_stats() -> void:
	var max_hp: int
	match building_type:
		BuildingType.WALL:
			max_hp = 300
			grid_size = Vector2i(1, 1)
		BuildingType.TOWER:
			max_hp = 150
			grid_size = Vector2i(1, 1)
		BuildingType.CASTLE:
			max_hp = 500
			grid_size = Vector2i(3, 3)
		BuildingType.BARRACKS:
			max_hp = 250
			grid_size = Vector2i(2, 2)
		BuildingType.MONASTERY:
			max_hp = 400
			grid_size = Vector2i(2, 2)
		BuildingType.ARCHERY:
			max_hp = 200
			grid_size = Vector2i(2, 2)
	if health and not Engine.is_editor_hint():
		health.setup(max_hp, hp_bar)

func _setup_editor_visuals() -> void:
	_setup_texture()
	_rebuild_shadow()
	_apply_sprite_position()

func _setup_visuals() -> void:
	var pixel_size := Vector2(grid_size.x * 64, grid_size.y * 64)

	# 贴图
	_setup_texture()

	# 碰撞
	var shape := RectangleShape2D.new()
	shape.size = pixel_size
	collision_shape.shape = shape

	# 血条位置
	var sprite_height: float = pixel_size.y
	if body_sprite.texture:
		sprite_height = body_sprite.texture.get_height() * body_sprite.scale.y
	hp_bar.offset_left = -pixel_size.x / 2.0
	hp_bar.offset_right = pixel_size.x / 2.0
	hp_bar.offset_top = -sprite_height / 2.0 - 8.0
	hp_bar.offset_bottom = -sprite_height / 2.0

	# 影子
	_rebuild_shadow()

	# 贴图上移
	_apply_sprite_position()

	# HPBar 跟随上移
	var sprite_height_final: float = pixel_size.y
	if body_sprite.texture:
		sprite_height_final = body_sprite.texture.get_height() * body_sprite.scale.y
	var lift: float = sprite_height_final * sprite_lift_ratio
	hp_bar.offset_top += lift + sprite_offset_y
	hp_bar.offset_bottom += lift + sprite_offset_y

func _setup_texture() -> void:
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
		BuildingType.MONASTERY:
			tex_path = "res://assets/buildings/%s_monastery/Monastery.png" % color_dir
		BuildingType.ARCHERY:
			tex_path = "res://assets/buildings/%s_archery/Archery.png" % color_dir
	if tex_path != "":
		var tex := load(tex_path)
		if tex and body_sprite:
			body_sprite.texture = tex

func _rebuild_shadow() -> void:
	if _shadow_component:
		var pixel_size := Vector2(grid_size.x * 64, grid_size.y * 64)
		var shadow_w := int(pixel_size.x * shadow_scale_x)
		var shadow_h := int(pixel_size.y * shadow_scale_y)
		_shadow_component.rebuild(shadow_w, shadow_h, shadow_alpha, shadow_offset_x, shadow_offset_y)

func _apply_sprite_position() -> void:
	if _shadow_component and body_sprite and body_sprite.texture:
		var sprite_height: float = body_sprite.texture.get_height() * sprite_scale_y
		var lift: float = sprite_height * sprite_lift_ratio
		_shadow_component.apply_sprite_position(body_sprite, sprite_scale_x, sprite_scale_y, lift, sprite_offset_x, sprite_offset_y)

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
	var pixel_size := Vector2(grid_size.x * cell, grid_size.y * cell)
	var origin := -pixel_size / 2.0

	# 高亮填充建筑占用的格子
	draw_rect(Rect2(origin, pixel_size), Color(0.3, 0.6, 1.0, 0.15))

	# 画格子线
	for x in range(grid_size.x + 1):
		var x_pos := origin.x + x * cell
		draw_line(Vector2(x_pos, origin.y), Vector2(x_pos, origin.y + pixel_size.y), Color(1, 1, 1, 0.5), 1.0)
	for y in range(grid_size.y + 1):
		var y_pos := origin.y + y * cell
		draw_line(Vector2(origin.x, y_pos), Vector2(origin.x + y_pos, y_pos), Color(1, 1, 1, 0.5), 1.0)

	# 碰撞边界（红色）
	draw_rect(Rect2(origin, pixel_size), Color(1, 0, 0, 0.6), false, 2.0)

func is_dead() -> bool:
	return health.is_dead() if health else _is_dead

func get_rect() -> Rect2:
	var pixel_size := Vector2(grid_size.x * 64, grid_size.y * 64)
	return Rect2(global_position - pixel_size / 2.0, pixel_size)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if health.is_dead():
		return
	# 建造倒计时
	if not is_constructed:
		build_progress += delta
		if build_bar:
			build_bar.value = build_progress
		if build_progress >= build_time:
			_finish_construction()
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
	JellyEffect.play(body_sprite, Vector2(sprite_scale_x, sprite_scale_y))
	var arrow_scene := load("res://scenes/effects/arrow.tscn")
	var arrow: Node2D = arrow_scene.instantiate()
	get_tree().current_scene.add_child(arrow)
	arrow.setup(global_position, target.global_position)
	arrow.hit_target = target
	arrow.hit_damage = int(attack_damage)
	arrow.shooter = self

func take_damage(amount: int, attacker = null) -> void:
	if Engine.is_editor_hint():
		return
	if health.is_dead():
		return
	health.take_damage(amount)
	if attacker and team == Team.ENEMY:
		_alert_nearby_enemies(attacker)
	if health.hp <= 0:
		die()

func _alert_nearby_enemies(attacker) -> void:
	var alert_range := 500.0
	for u in get_tree().get_nodes_in_group("enemy_units"):
		if u.is_dead():
			continue
		if global_position.distance_to(u.global_position) <= alert_range:
			var ai = u.get_node_or_null("EnemyAI")
			if ai and ai.has_method("on_attacked"):
				ai.on_attacked(attacker)

func die() -> void:
	health._is_dead = true
	died.emit(self)
	# 生成爆炸特效
	var explosion_scene := load("res://scenes/effects/explosion.tscn")
	var explosion: Node2D = explosion_scene.instantiate()
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = global_position
	var max_dim := maxf(float(grid_size.x), float(grid_size.y))
	explosion.scale = Vector2(max_dim, max_dim)
	# 缩小+删除动画
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
	tween.tween_callback(queue_free)

func _update_hp_bar() -> void:
	if health:
		health._update_hp_bar()

func start_construction(duration: float = 5.0) -> void:
	build_time = duration
	build_progress = 0.0
	is_constructed = false
	body_sprite.modulate.a = 0.5
	_create_build_bar()

func _create_build_bar() -> void:
	build_bar = ProgressBar.new()
	build_bar.max_value = build_time
	build_bar.value = 0.0
	build_bar.show_percentage = false

	var pixel_size := Vector2(grid_size.x * 64, grid_size.y * 64)
	build_bar.offset_left = -pixel_size.x / 2.0
	build_bar.offset_right = pixel_size.x / 2.0
	build_bar.offset_top = hp_bar.offset_top - 10.0
	build_bar.offset_bottom = hp_bar.offset_top - 2.0

	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.2, 0.2, 0.2, 0.8)
	bg_style.set_corner_radius_all(2)
	build_bar.add_theme_stylebox_override("background", bg_style)

	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = Color(1.0, 0.85, 0.0)
	fill_style.set_corner_radius_all(2)
	build_bar.add_theme_stylebox_override("fill", fill_style)

	add_child(build_bar)

func _finish_construction() -> void:
	is_constructed = true
	body_sprite.modulate.a = 1.0
	if build_bar:
		build_bar.queue_free()
		build_bar = null
