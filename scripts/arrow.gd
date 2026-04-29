extends Node2D

var target_pos: Vector2 = Vector2.ZERO
var start_pos: Vector2 = Vector2.ZERO
var speed: float = 400.0
var arc_height: float = 40.0
var progress: float = 0.0
var on_hit: Callable

@onready var sprite: ColorRect = $ArrowSprite

func _ready() -> void:
	sprite.color = Color(0.8, 0.6, 0.2)

func setup(from: Vector2, to: Vector2) -> void:
	start_pos = from
	target_pos = to
	global_position = from
	# 箭矢朝向目标
	rotation = from.direction_to(to).angle()

func _process(delta: float) -> void:
	var total_dist := start_pos.distance_to(target_pos)
	if total_dist < 1.0:
		queue_free()
		return

	progress += speed * delta / total_dist
	if progress >= 1.0:
		if on_hit.is_valid():
			on_hit.call()
		queue_free()
		return

	# 线性插值位置
	var pos := start_pos.lerp(target_pos, progress)
	# 抛物线弧度
	var arc := -4.0 * arc_height * progress * (progress - 1.0)
	pos.y -= arc
	global_position = pos

	# 随弧度微调角度
	rotation = start_pos.direction_to(target_pos).angle() - arc * 0.01
