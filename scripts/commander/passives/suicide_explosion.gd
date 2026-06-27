extends RefCounted
## 被动技能：自爆流
## 单位死亡时在位置爆炸，对半径内敌方造成 attack_damage * 1.5 伤害
## 装备指挥官：test_all

const TriggersClass := preload("res://scripts/commander/passive_triggers.gd")

const EXPLOSION_RADIUS: float = 80.0
const DAMAGE_MULTIPLIER: float = 1.5


func register(manager: Node, _profile) -> void:
	manager.register(TriggersClass.UNIT_DIED, func(ctx: Dictionary): _on_unit_died(manager, ctx))


func _on_unit_died(manager: Node, ctx: Dictionary) -> void:
	var unit = ctx.get("unit", null)
	if unit == null or not is_instance_valid(unit):
		return
	# 仅玩家方单位（alliance_id = 0）触发
	var alliance_id: int = ctx.get("alliance_id", -1)
	if alliance_id != 0:
		return
	var pos: Vector2 = unit.global_position
	var base_damage: int = 20
	if "stat_set" in unit and unit.stat_set != null:
		var StatSetClass := preload("res://scripts/stats/stat_set.gd")
		base_damage = unit.stat_set.get_int(StatSetClass.ATTACK_DAMAGE)
	var damage: int = int(base_damage * DAMAGE_MULTIPLIER)
	# 创建爆炸特效（复用 commander_skill 的 explosion 场景）
	var main_node := manager.get_tree().current_scene
	if main_node == null:
		return
	var explosion_scene := load("res://scenes/effects/explosion.tscn")
	if explosion_scene != null:
		var fx: Node2D = explosion_scene.instantiate()
		fx.global_position = pos
		main_node.add_child(fx)
		if fx.has_node("Sprite"):
			var sprite: Sprite2D = fx.get_node("Sprite")
			var sf := EXPLOSION_RADIUS / 40.0
			sprite.scale = Vector2(sf, sf)
	# 对范围内敌方造成伤害
	for enemy in main_node.get_tree().get_nodes_in_group("enemy_units"):
		if is_instance_valid(enemy) and enemy is CharacterBody2D:
			if enemy.has_method("take_damage") and not enemy.health.is_dead():
				if enemy.global_position.distance_to(pos) <= EXPLOSION_RADIUS:
					enemy.take_damage(damage)
	for eb in main_node.get_tree().get_nodes_in_group("enemy_buildings"):
		if is_instance_valid(eb) and eb.has_method("take_damage"):
			if eb.has_method("is_dead") and eb.is_dead():
				continue
			if eb.global_position.distance_to(pos) <= EXPLOSION_RADIUS:
				eb.take_damage(damage)
