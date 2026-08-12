class_name VictoryDestroyBase
extends VictoryCondition

const BuildingScript := preload("res://scripts/buildings/building.gd")

func _ready() -> void:
	pass

func check() -> int:
	var player_castle_alive := _is_player_castle_alive()
	var enemy_castle_alive := _is_enemy_castle_alive()
	if not enemy_castle_alive:
		return 1  # Victory
	elif not player_castle_alive:
		return 2  # Defeat
	return 0  # Ongoing


## T3 PR-3: 右上角 objectives_panel 显示的任务
func get_objectives() -> Array[Dictionary]:
	var player_castle_alive := _is_player_castle_alive()
	var enemy_castle_alive := _is_enemy_castle_alive()
	return [
		{"text": "摧毁敌方据点（敌方城堡）", "state": 1 if not enemy_castle_alive else 0, "progress": ""},
		{"text": "保护我方城堡", "state": 2 if not player_castle_alive else 0, "progress": ""},
	]


func _is_player_castle_alive() -> bool:
	for b in get_tree().get_nodes_in_group("player_buildings"):
		if is_instance_valid(b) and b.has_method("is_dead") and not b.is_dead():
			if b.building_type == BuildingScript.BuildingType.CASTLE:
				return true
	return false


func _is_enemy_castle_alive() -> bool:
	for b in get_tree().get_nodes_in_group("enemy_buildings"):
		if is_instance_valid(b) and b.has_method("is_dead") and not b.is_dead():
			if b.building_type == BuildingScript.BuildingType.CASTLE:
				return true
	return false
