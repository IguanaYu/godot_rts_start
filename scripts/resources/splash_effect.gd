class_name SplashEffect
extends ProjectileEffect

@export var radius: float = 50.0
@export var splash_ratio: float = 0.5


func apply(projectile: Node2D, _target: Node2D) -> void:
	var hit_pos := projectile.global_position
	var shooter = projectile.get("shooter")
	var damage: int = projectile.get("hit_damage")

	var enemy_group := "player_units"
	if shooter and shooter.has_method("get") and shooter.get("team") == 0:
		enemy_group = "enemy_units"
	elif shooter and shooter.has_method("get") and shooter.get("team") == 1:
		enemy_group = "player_units"

	for unit in projectile.get_tree().get_nodes_in_group(enemy_group):
		if not is_instance_valid(unit) or unit.is_dead():
			continue
		if hit_pos.distance_to(unit.global_position) <= radius:
			var splash_damage := maxi(1, int(damage * splash_ratio))
			unit.take_damage(splash_damage, shooter)
