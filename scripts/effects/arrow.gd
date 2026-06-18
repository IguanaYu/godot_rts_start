extends Node2D

const ProjectileDataScript := preload("res://scripts/resources/projectile_data.gd")

var target_pos: Vector2 = Vector2.ZERO
var start_pos: Vector2 = Vector2.ZERO
var speed: float = 400.0
var arc_height: float = 40.0
var progress: float = 0.0
var hit_target = null
var hit_damage: int = 0
var shooter = null
var data: Resource = null
var hit_callback: Callable = Callable()

@onready var sprite: ColorRect = $ArrowSprite


func setup(from: Vector2, to: Vector2) -> void:
	start_pos = from
	target_pos = to
	global_position = from
	rotation = from.direction_to(to).angle()
	if data:
		speed = data.speed
		arc_height = data.arc_height


func _process(delta: float) -> void:
	var total_dist := start_pos.distance_to(target_pos)
	if total_dist < 1.0:
		queue_free()
		return

	progress += speed * delta / total_dist
	if progress >= 1.0:
		_on_hit()
		queue_free()
		return

	var pos := start_pos.lerp(target_pos, progress)
	var arc := -4.0 * arc_height * progress * (progress - 1.0)
	pos.y -= arc
	global_position = pos
	rotation = start_pos.direction_to(target_pos).angle() - arc * 0.01


func _on_hit() -> void:
	# 如果有自定义回调，优先执行回调并跳过默认伤害逻辑
	if hit_callback.is_valid():
		hit_callback.call()
		queue_free()
		return

	if hit_target != null and is_instance_valid(hit_target) and not hit_target.is_dead():
		hit_target.take_damage(hit_damage, shooter)
	# 驱散：射击者命中时清除目标增益（Inquisitor）
	if shooter != null and is_instance_valid(shooter) and shooter.has_method("dispel_target"):
		shooter.dispel_target(hit_target)
	if data:
		for effect: Resource in data.effects:
			effect.apply(self, hit_target)
