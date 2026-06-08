extends Node2D
## 地形障碍基类：提供导航遮挡区域和物理碰撞
## 在 Inspector 设置 obstacle_size 和 obstacle_type
## 运行时根据类型自动铺满对应贴图

enum ObstacleType { ROCK, FOREST, RIVER }

@export var obstacle_size: Vector2 = Vector2(64, 64)
@export var obstacle_type: ObstacleType = ObstacleType.ROCK
@export var fill_spacing: float = 50.0
@export var fill_z_index: int = 1

var _fill_margin: float = 20.0

const POS_JITTER := 12.0
const SCALE_JITTER := 0.15

const ROCK_TEXTURES := [
	preload("res://assets/environment/rocks/Rock1.png"),
	preload("res://assets/environment/rocks/Rock2.png"),
	preload("res://assets/environment/rocks/Rock3.png"),
	preload("res://assets/environment/rocks/Rock4.png"),
]
const TREE_TEXTURES := [
	preload("res://assets/environment/trees/Tree1.png"),
	preload("res://assets/environment/trees/Tree2.png"),
	preload("res://assets/environment/trees/Tree3.png"),
	preload("res://assets/environment/trees/Tree4.png"),
]
const WATER_TEXTURES := [
	preload("res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/Terrain/Tileset/Water Background color.png"),
]


func _ready() -> void:
	# 同步碰撞体大小到 obstacle_size
	var body := get_node_or_null("StaticBody2D/CollisionShape2D")
	if body and body.shape is RectangleShape2D:
		body.shape.size = obstacle_size

	# 删掉编辑器里的占位 Sprite
	var placeholder := get_node_or_null("Sprite")
	if placeholder:
		placeholder.queue_free()

	# 根据类型设置默认间距和边距
	match obstacle_type:
		ObstacleType.FOREST:
			fill_spacing = 70.0
			_fill_margin = 50.0
		ObstacleType.ROCK:
			fill_spacing = 45.0
			_fill_margin = 15.0
		ObstacleType.RIVER:
			fill_spacing = 52.0
			_fill_margin = 15.0

	# 障碍区域底色（比草地深，一眼区分）
	var bg := ColorRect.new()
	bg.size = obstacle_size
	bg.position = -obstacle_size / 2.0
	bg.color = _get_bg_color()
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.z_index = -8
	add_child(bg)

	# 根据类型选择贴图并铺满区域
	var textures: Array
	match obstacle_type:
		ObstacleType.ROCK: textures = ROCK_TEXTURES
		ObstacleType.FOREST: textures = TREE_TEXTURES
		ObstacleType.RIVER: textures = WATER_TEXTURES
		_: return
	_fill_area(textures)


func _get_bg_color() -> Color:
	match obstacle_type:
		ObstacleType.ROCK: return Color(0.25, 0.22, 0.18, 0.6)
		ObstacleType.FOREST: return Color(0.1, 0.28, 0.08, 0.6)
		ObstacleType.RIVER: return Color(0.1, 0.25, 0.5, 0.7)
		_: return Color(0.3, 0.3, 0.3, 0.5)


func _fill_area(textures: Array) -> void:
	if textures.is_empty():
		return

	var half := obstacle_size / 2.0
	var idx := 0
	var x := -half.x + _fill_margin
	while x < half.x - _fill_margin:
		var y := -half.y + _fill_margin
		while y < half.y - _fill_margin:
			var tex: Texture2D = textures[idx % textures.size()]
			var sprite := Sprite2D.new()
			sprite.texture = tex
			# 精灵图（树）需要 hframes 拆帧
			if tex.get_width() > tex.get_height() * 2:
				sprite.hframes = 8
				sprite.frame = idx % 8
			sprite.position = Vector2(
				x + randf_range(-POS_JITTER, POS_JITTER),
				y + randf_range(-POS_JITTER, POS_JITTER)
			)
			# 根据类型设置缩放：树和石头缩小，让贴图不超出碰撞区域
			var s := _get_fill_scale() * randf_range(1.0 - SCALE_JITTER, 1.0 + SCALE_JITTER)
			sprite.scale = Vector2(s, s)
			sprite.z_index = fill_z_index
			add_child(sprite)
			idx += 1
			y += fill_spacing
		x += fill_spacing


func _get_fill_scale() -> float:
	match obstacle_type:
		ObstacleType.FOREST: return 0.5
		ObstacleType.ROCK: return 0.8
		ObstacleType.RIVER: return 0.8
		_: return 0.5


func get_obstacle_rect() -> Rect2:
	return Rect2(global_position - obstacle_size / 2.0, obstacle_size)
