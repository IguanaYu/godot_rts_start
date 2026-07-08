extends Node2D
## 战斗测试场景初始化脚本

const UnitScene = preload("res://scenes/units/soldier.tscn")
const BuildingScene = preload("res://scenes/buildings/barracks.tscn")
const FactionClass = preload("res://scripts/faction.gd")
const EnemyAIScript = preload("res://scripts/units/enemy_ai.gd")

var soldiers = []
var enemy_building = null

func _ready() -> void:
	# 场景初始化后调用
	pass

func spawn_soldiers(count: int, base_pos: Vector2) -> Array:
	var parent = get_node("PlayerUnits")
	var units = []
	for i in range(count):
		var soldier = UnitScene.instantiate()
		soldier.alliance_id = 0
		soldier.faction_color = FactionClass.ColorId.BLUE
		soldier.position = base_pos + Vector2(i * 35, 0)
		parent.add_child(soldier)
		soldier.add_to_group("player_units")
		if has_method("_on_unit_died"):
			soldier.connect("died", Callable(self, "_on_unit_died"))
		units.append(soldier)
	return units

func spawn_enemy_barracks(pos: Vector2):
	var parent = get_node("Buildings")
	var building = BuildingScene.instantiate()
	building.alliance_id = 1
	building.faction_color = FactionClass.ColorId.RED
	building.position = pos
	parent.add_child(building)
	building.add_to_group("buildings")
	building.add_to_group("enemy_buildings")
	if has_method("_on_unit_died"):
		building.connect("died", Callable(self, "_on_unit_died"))
	return building

func _on_unit_died(entity) -> void:
	# 清理死亡单位
	if entity and is_instance_valid(entity):
		entity.queue_free()
