class_name CapturePoint
extends Area2D

const UnitScript := preload("res://scripts/unit.gd")

const UNIT_TYPE_NAMES := {
	UnitScript.UnitType.SOLDIER: "Soldier",
	UnitScript.UnitType.ARCHER: "Archer",
	UnitScript.UnitType.LANCER: "Lancer",
	UnitScript.UnitType.MONK: "Monk",
}

enum RewardType { GOLD, UNITS, CUSTOM }

@export var capture_radius: float = 100.0
@export var capture_speed: float = 20.0  # Progress per second when dominant

@export var reward_type: RewardType = RewardType.GOLD
@export var reward_gold: int = 500
@export var reward_units: Array[Dictionary] = []
@export var reward_custom: String = ""

# Trigger conditions
@export var trigger_on_start: bool = true
@export var trigger_on_kill_all: bool = false
@export var trigger_on_destroy_building: NodePath = ""

var capture_progress: float = 0.0  # 0 to 100
var capturing_team: int = -1  # -1=neutral, 0=player, 1=enemy (matches Unit.Team)
var captured_by: int = -1
var is_active: bool = false

var game_controller: Node2D = null

signal captured(team: int)
signal capture_progress_changed(team: int, progress: float)

func _ready() -> void:
	# Setup collision for body detection
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = capture_radius
	collision.shape = shape
	add_child(collision)

	# Setup visual
	_setup_visual()

	if trigger_on_start:
		activate()
	else:
		visible = false

func _setup_visual() -> void:
	var sprite := ColorRect.new()
	sprite.name = "CaptureRing"
	sprite.size = Vector2(capture_radius * 2, capture_radius * 2)
	sprite.position = Vector2(-capture_radius, -capture_radius)
	sprite.color = Color(1, 1, 1, 0.15)
	sprite.z_index = 5
	add_child(sprite)

func set_game_controller(gc: Node2D) -> void:
	game_controller = gc

func activate() -> void:
	is_active = true
	visible = true

func deactivate() -> void:
	is_active = false
	visible = false

func _process(delta: float) -> void:
	if not is_active:
		return

	var player_count := 0
	var enemy_count := 0

	# Use distance-based detection instead of get_overlapping_bodies()
	# to avoid Area2D collision layer issues
	for u in get_tree().get_nodes_in_group("player_units"):
		if u is CharacterBody2D and not u.is_dead():
			if u.global_position.distance_to(global_position) <= capture_radius:
				player_count += 1

	for u in get_tree().get_nodes_in_group("enemy_units"):
		if u is CharacterBody2D and not u.is_dead():
			if u.global_position.distance_to(global_position) <= capture_radius:
				enemy_count += 1

	# Determine dominant team
	var dominant_team := -1
	if player_count > enemy_count:
		dominant_team = UnitScript.Team.PLAYER
	elif enemy_count > player_count:
		dominant_team = UnitScript.Team.ENEMY

	# Update capture progress
	if dominant_team != -1:
		if captured_by == -1 or captured_by == dominant_team:
			capture_progress += capture_speed * delta
		else:
			capture_progress -= capture_speed * delta * 1.5

		capture_progress = clamp(capture_progress, 0.0, 100.0)
		capturing_team = dominant_team

		capture_progress_changed.emit(capturing_team, capture_progress)

		# Check capture complete
		if capture_progress >= 100.0 and captured_by != capturing_team:
			captured_by = capturing_team
			captured.emit(captured_by)
			_grant_reward()
			deactivate()
	else:
		if captured_by == -1:
			capture_progress = max(0.0, capture_progress - capture_speed * delta * 0.5)

func _grant_reward() -> void:
	if game_controller == null:
		print("CapturePoint: grant_reward FAILED - game_controller is null!")
		return

	match reward_type:
		RewardType.GOLD:
			if game_controller.has_method("add_gold"):
				game_controller.call("add_gold", reward_gold)
				print("CapturePoint: granted ", reward_gold, " gold!")
			else:
				print("CapturePoint: game_controller has no add_gold method!")
			if game_controller.has_method("show_floating_text"):
				game_controller.call("show_floating_text",
					"+%d" % reward_gold,
					Color(1.0, 0.85, 0.0),
					global_position)
		RewardType.UNITS:
			if game_controller.has_method("spawn_unit_near"):
				for unit_data in reward_units:
					var type = unit_data.get("type", 0)
					var count = unit_data.get("count", 1)
					for i in count:
						game_controller.call("spawn_unit_near", type, global_position, captured_by)
			if game_controller.has_method("show_floating_text"):
				var parts: Array[String] = []
				for unit_data in reward_units:
					var type = unit_data.get("type", 0)
					var count = unit_data.get("count", 1)
					var unit_name: String = UNIT_TYPE_NAMES.get(type, "Unit")
					if count > 1:
						parts.append("+%d %ss" % [count, unit_name])
					else:
						parts.append("+%d %s" % [count, unit_name])
				game_controller.call("show_floating_text",
					" ".join(parts),
					Color(0.3, 1.0, 0.3),
					global_position)
		RewardType.CUSTOM:
			pass

func get_capture_progress() -> float:
	return capture_progress

func get_captured_by() -> int:
	return captured_by

func is_captured() -> bool:
	return captured_by != -1
