class_name PoisonEffect
extends ProjectileEffect

## 中毒效果：命中后对目标施加持续伤害（DoT）
@export var dps: float = 8.0
@export var duration: float = 4.0


func apply(_projectile: Node2D, target: Node2D) -> void:
	if target.has_method("apply_poison"):
		target.apply_poison(dps, duration)
