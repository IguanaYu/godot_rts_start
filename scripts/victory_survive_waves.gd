class_name VictorySurviveWaves
extends VictoryCondition

const BuildingScript := preload("res://scripts/building.gd")

@export var wave_manager_path: NodePath = ^"WaveManager"

var wave_manager: Node = null
var all_waves_done: bool = false

func _ready() -> void:
	wave_manager = get_node_or_null(wave_manager_path)
	if wave_manager:
		wave_manager.all_waves_completed.connect(_on_all_waves_completed)

func _on_all_waves_completed() -> void:
	all_waves_done = true

func check() -> int:
	# Check defeat: player castle alive?
	var player_castle_alive := false
	for b in get_tree().get_nodes_in_group("player_buildings"):
		if b.has_method("is_dead") and not b.is_dead():
			if b.building_type == BuildingScript.BuildingType.CASTLE:
				player_castle_alive = true
				break
	if not player_castle_alive:
		return 2  # Defeat

	# Check victory: all waves done + all enemies dead
	if all_waves_done:
		var enemy_count := 0
		for u in get_tree().get_nodes_in_group("enemy_units"):
			if u is CharacterBody2D and not u.is_dead():
				enemy_count += 1
		if enemy_count == 0:
			return 1  # Victory

	return 0  # Ongoing
