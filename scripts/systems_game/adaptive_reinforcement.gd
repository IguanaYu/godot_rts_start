class_name AdaptiveReinforcement
extends Node2D

## 自适应增兵系统
## 玩家存活单位越少，援军来得越快越多

@export var spawn_point_path: NodePath = ^""
@export var reinforcement_table: Array[Dictionary] = []
  # [{"min_alive": 0, "max_alive": 4, "interval": 8.0, "groups": [{"type": 0, "count": 3}, {"type": 1, "count": 2}]},
  #  {"min_alive": 5, "max_alive": 10, "interval": 15.0, "groups": [{"type": 0, "count": 2}]}]

var game_controller: Node2D = null
var _timer: float = 0.0
var _spawn_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	var spawn_node := get_node_or_null(spawn_point_path)
	if spawn_node and spawn_node is Node2D:
		_spawn_pos = spawn_node.global_position
	else:
		_spawn_pos = global_position

func set_game_controller(gc: Node2D) -> void:
	game_controller = gc

func _process(delta: float) -> void:
	if game_controller == null:
		return

	var alive := _count_player_units()
	var tier := _find_tier(alive)
	if tier == null:
		return

	var interval: float = tier.get("interval", 20.0)
	_timer += delta
	if _timer >= interval:
		_timer = 0.0
		_spawn_reinforcement(tier)

func _count_player_units() -> int:
	var count := 0
	for u in get_tree().get_nodes_in_group("player_units"):
		if u is CharacterBody2D and u.has_method("is_dead") and not u.is_dead():
			count += 1
	return count

func _find_tier(alive: int) -> Dictionary:
	for tier in reinforcement_table:
		var min_a: int = tier.get("min_alive", 0)
		var max_a: int = tier.get("max_alive", 999)
		if alive >= min_a and alive <= max_a:
			return tier
	return {}

func _spawn_reinforcement(tier: Dictionary) -> void:
	if game_controller == null or not game_controller.has_method("spawn_unit_near"):
		return
	var groups: Array = tier.get("groups", [])
	for g: Dictionary in groups:
		var type: int = g.get("type", 0)
		var count: int = g.get("count", 1)
		for _i: int in count:
			game_controller.call("spawn_unit_near", type, _spawn_pos, 0)
