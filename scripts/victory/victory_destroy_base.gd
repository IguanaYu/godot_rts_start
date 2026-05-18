class_name VictoryDestroyBase
extends VictoryCondition

const BuildingScript := preload("res://scripts/buildings/building.gd")

func _ready() -> void:
	pass

func check() -> int:
	# Check if player castle is alive
	var player_castle_alive := false
	for b in get_tree().get_nodes_in_group("player_buildings"):
		if b.has_method("is_dead") and not b.is_dead():
			if b.building_type == BuildingScript.BuildingType.CASTLE:
				player_castle_alive = true
				break

	# Check if enemy castle is alive
	var enemy_castle_alive := false
	for b in get_tree().get_nodes_in_group("enemy_buildings"):
		if b.has_method("is_dead") and not b.is_dead():
			if b.building_type == BuildingScript.BuildingType.CASTLE:
				enemy_castle_alive = true
				break

	if not enemy_castle_alive:
		return 1  # Victory
	elif not player_castle_alive:
		return 2  # Defeat

	return 0  # Ongoing
