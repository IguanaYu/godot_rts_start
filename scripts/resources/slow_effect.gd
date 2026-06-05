class_name SlowEffect
extends ProjectileEffect

@export var slow_rate: float = 0.25
@export var duration: float = 2.0


func apply(_projectile: Node2D, target: Node2D) -> void:
	if target.has_method("apply_slow"):
		target.apply_slow(slow_rate, duration)
