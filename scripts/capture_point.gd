class_name CapturePoint
extends Area2D

const UnitScript := preload("res://scripts/unit.gd")

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
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# Setup collision
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = capture_radius
	collision.shape = shape
	add_child(collision)

	# Setup visual
	_setup_visual()

	if trigger_on_start:
		activate()

func _setup_visual() -> void:
	var sprite := ColorRect.new()
	sprite.name = "CaptureRing"
	sprite.size = Vector2(capture_radius * 2, capture_radius * 2)
	sprite.position = Vector2(-capture_radius, -capture_radius)
	sprite.color = Color(1, 1, 1, 0.1)
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

	for body in get_overlapping_bodies():
		if not body is CharacterBody2D:
			continue
		if body.has_method("is_dead") and body.is_dead():
			continue
		if body.has_method("get"):
			var team = body.get("team")
			if team == UnitScript.Team.PLAYER:
				player_count += 1
			elif team == UnitScript.Team.ENEMY:
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
	else:
		if captured_by == -1:
			capture_progress = max(0.0, capture_progress - capture_speed * delta * 0.5)

func _grant_reward() -> void:
	if game_controller == null:
		return

	match reward_type:
		RewardType.GOLD:
			if game_controller.has_method("add_gold"):
				game_controller.call("add_gold", reward_gold)
		RewardType.UNITS:
			if game_controller.has_method("spawn_unit_near"):
				for unit_data in reward_units:
					var type = unit_data.get("type", 0)
					var count = unit_data.get("count", 1)
					for i in count:
						game_controller.call("spawn_unit_near", type, global_position, captured_by)
		RewardType.CUSTOM:
			pass

func _on_body_entered(body: Node2D) -> void:
	pass

func _on_body_exited(body: Node2D) -> void:
	pass

func get_capture_progress() -> float:
	return capture_progress

func get_captured_by() -> int:
	return captured_by

func is_captured() -> bool:
	return captured_by != -1
