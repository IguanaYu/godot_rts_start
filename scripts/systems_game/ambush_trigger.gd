class_name AmbushTrigger
extends Area2D

## 伏击触发器
## 玩家单位进入区域时生成敌人，一次性触发

@export var trigger_radius: float = 200.0
@export var ambush_units: Array[Dictionary] = []  # [{"type": 0, "count": 3}]
@export var one_shot: bool = true

var game_controller: Node2D = null
var _triggered: bool = false

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = trigger_radius
	collision.shape = shape
	collision.name = "TriggerShape"
	add_child(collision)

	body_entered.connect(_on_body_entered)

func set_game_controller(gc: Node2D) -> void:
	game_controller = gc

func _on_body_entered(body: Node2D) -> void:
	if _triggered:
		return
	if not body.is_in_group("player_units"):
		return

	_triggered = true
	_spawn_ambush()

	if one_shot:
		set_deferred("monitoring", false)

func _spawn_ambush() -> void:
	if game_controller == null or not game_controller.has_method("spawn_unit_near"):
		return

	for g in ambush_units:
		var type: int = g.get("type", 0)
		var count: int = g.get("count", 1)
		for _i in count:
			game_controller.call("spawn_unit_near", type, global_position, 1)
