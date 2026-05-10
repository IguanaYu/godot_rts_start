class_name VictoryBlitz
extends VictoryCondition

const UnitScript := preload("res://scripts/unit.gd")

@export var capture_points: Array[NodePath] = []
@export var activation_radius: float = 200.0

var current_target: int = 0
var game_result: int = 0  # 0=ongoing, 1=victory, 2=defeat
var _captured_count: int = 0
var _waiting_for_clear: bool = false

func _ready() -> void:
	# All capture points start deactivated
	for i in range(capture_points.size()):
		var cp = get_node_or_null(capture_points[i])
		if cp == null:
			continue
		cp.deactivate()
		cp.captured.connect(_on_point_captured)

	# Start waiting for enemies near first point to be cleared
	_waiting_for_clear = true

func _on_point_captured(team: int) -> void:
	if team != UnitScript.Team.PLAYER:
		return

	_captured_count += 1

	# Heal all player units
	_heal_all_players()

	# Wait for next point area to be cleared
	if current_target + 1 < capture_points.size():
		current_target += 1
		_waiting_for_clear = true

func _heal_all_players() -> void:
	for u in get_tree().get_nodes_in_group("player_units"):
		if u is CharacterBody2D and not u.is_dead():
			if u.has_method("heal"):
				u.heal(int(u.get("max_hp") * 0.5))

var _debug_timer: float = 0.0

func check() -> int:
	if game_result != 0:
		return game_result

	# Check defeat: all player units dead
	var any_alive := false
	for u in get_tree().get_nodes_in_group("player_units"):
		if u is CharacterBody2D and not u.is_dead():
			any_alive = true
			break
	if not any_alive:
		game_result = 2
		return 2

	# Check if current target area is cleared of enemies
	if _waiting_for_clear:
		var cp = get_node_or_null(capture_points[current_target])
		if cp != null:
			var cp_pos: Vector2 = cp.global_position
			var enemies_near := false
			for u in get_tree().get_nodes_in_group("enemy_units"):
				if u is CharacterBody2D and not u.is_dead():
					if u.global_position.distance_to(cp_pos) < activation_radius:
						enemies_near = true
						break
			if not enemies_near:
				# Area cleared, activate the capture point
				cp.activate()
				_waiting_for_clear = false

	# Check victory: all capture points captured
	if _captured_count >= capture_points.size():
		game_result = 1
		return 1

	return 0
