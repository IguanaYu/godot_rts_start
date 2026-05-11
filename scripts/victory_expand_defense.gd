class_name VictoryExpandDefense
extends VictoryCondition

const UnitScript := preload("res://scripts/unit.gd")
const BuildingScript := preload("res://scripts/building.gd")

@export var wave_manager_path: NodePath = ^"WaveManager"
@export var capture_points: Array[NodePath] = []
@export var activation_radius: float = 250.0

var wave_manager: Node = null
var all_waves_done: bool = false
var game_result: int = 0  # 0=ongoing, 1=victory, 2=defeat
var _captured_count: int = 0
var _point_states: Array[int] = []  # 0=waiting, 1=activated, 2=captured

func _ready() -> void:
	# Connect to WaveManager
	wave_manager = get_node_or_null(wave_manager_path)
	if wave_manager:
		wave_manager.all_waves_completed.connect(_on_all_waves_completed)

	# Initialize capture point states and connect signals
	_point_states.resize(capture_points.size())
	for i in range(capture_points.size()):
		_point_states[i] = 0
		var cp = get_node_or_null(capture_points[i])
		if cp == null:
			continue
		cp.deactivate()
		cp.captured.connect(_on_point_captured.bind(i))

func _on_all_waves_completed() -> void:
	all_waves_done = true

func _on_point_captured(team: int, index: int) -> void:
	if team != UnitScript.Team.PLAYER:
		return
	_point_states[index] = 2
	_captured_count += 1
	print("VictoryExpandDefense: Point ", index, " captured! (", _captured_count, "/", capture_points.size(), ")")

func check() -> int:
	if game_result != 0:
		return game_result

	# --- DEFEAT: player castle destroyed ---
	var player_castle_alive := false
	for b in get_tree().get_nodes_in_group("player_buildings"):
		if b.has_method("is_dead") and not b.is_dead():
			if b.building_type == BuildingScript.BuildingType.CASTLE:
				player_castle_alive = true
				break
	if not player_castle_alive:
		game_result = 2
		return 2

	# --- ACTIVATE capture points when nearby enemies cleared ---
	for i in range(capture_points.size()):
		if _point_states[i] != 0:
			continue
		var cp = get_node_or_null(capture_points[i])
		if cp == null:
			continue
		var cp_pos: Vector2 = cp.global_position
		var enemies_near := false
		# Check enemy units
		for u in get_tree().get_nodes_in_group("enemy_units"):
			if u is CharacterBody2D and not u.is_dead():
				if u.global_position.distance_to(cp_pos) < activation_radius:
					enemies_near = true
					break
		# Check enemy buildings
		if not enemies_near:
			for b in get_tree().get_nodes_in_group("enemy_buildings"):
				if b.has_method("is_dead") and not b.is_dead():
					if b.global_position.distance_to(cp_pos) < activation_radius:
						enemies_near = true
						break
		if not enemies_near:
			cp.activate()
			_point_states[i] = 1

	# --- VICTORY: all captured + all waves done + no enemies ---
	if _captured_count < capture_points.size():
		return 0

	if not all_waves_done:
		return 0

	var enemy_count := 0
	for u in get_tree().get_nodes_in_group("enemy_units"):
		if u is CharacterBody2D and not u.is_dead():
			enemy_count += 1
	if enemy_count > 0:
		return 0

	game_result = 1
	return 1
