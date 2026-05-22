extends Node2D

var target_pos: Vector2 = Vector2.ZERO
var start_pos: Vector2 = Vector2.ZERO
var speed: float = 400.0
var arc_height: float = 40.0
var progress: float = 0.0
var hit_target = null
var hit_damage: int = 0
var shooter = null

@onready var sprite: ColorRect = $ArrowSprite

func _ready() -> void:
	sprite.color = Color(0.8, 0.6, 0.2)

func setup(from: Vector2, to: Vector2) -> void:
	start_pos = from
	target_pos = to
	global_position = from
	rotation = from.direction_to(to).angle()

func _process(delta: float) -> void:
	var total_dist := start_pos.distance_to(target_pos)
	if total_dist < 1.0:
		queue_free()
		return

	progress += speed * delta / total_dist
	if progress >= 1.0:
		if hit_target != null and is_instance_valid(hit_target) and not hit_target.is_dead():
			hit_target.take_damage(hit_damage, shooter)
			# 箭塔射击减速
			if shooter and shooter.get("building_type") == 1:  # BuildingType.TOWER
				if hit_target.has_method("apply_slow"):
					hit_target.apply_slow(0.25, 2.0)
		queue_free()
		return

	var pos := start_pos.lerp(target_pos, progress)
	var arc := -4.0 * arc_height * progress * (progress - 1.0)
	pos.y -= arc
	global_position = pos
	rotation = start_pos.direction_to(target_pos).angle() - arc * 0.01
