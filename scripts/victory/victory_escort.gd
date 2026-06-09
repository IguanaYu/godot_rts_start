class_name VictoryEscort
extends VictoryCondition

## 护送条件
## 胜利：护送NPC到达目的地
## 失败：护送NPC死亡

@export var escort_npc_path: NodePath = ^""
@export var fail_on_npc_death: bool = true

var _escort_npc: EscortNPC = null
var _npc_reached: bool = false
var _npc_dead: bool = false
const BuildingScript := preload("res://scripts/buildings/building.gd")

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	_escort_npc = get_node_or_null(escort_npc_path)
	if _escort_npc == null:
		push_error("VictoryEscort: EscortNPC not found!")
		return

	if _escort_npc.has_signal("died"):
		_escort_npc.died.connect(_on_npc_died)
	if _escort_npc.has_signal("reached_destination"):
		_escort_npc.reached_destination.connect(_on_npc_reached)

func _on_npc_died(npc: EscortNPC) -> void:
	_npc_dead = true

func _on_npc_reached(npc: EscortNPC) -> void:
	_npc_reached = true

func check() -> int:
	if _npc_reached:
		return 1  # 胜利

	if _npc_dead and fail_on_npc_death:
		return 2  # 失败

	# 额外失败条件：玩家全灭（可选）
	var any_alive := false
	for u in get_tree().get_nodes_in_group("player_units"):
		if u is CharacterBody2D and u.has_method("is_dead") and not u.is_dead():
			any_alive = true
			break

	if not any_alive:
		return 2  # 失败

	return 0  # 进行中

func get_objectives() -> Array[Dictionary]:
	var state := 0
	if _npc_reached:
		state = 1
	elif _npc_dead:
		state = 2

	var hp_percent := 0
	if is_instance_valid(_escort_npc) and _escort_npc.has_method("get"):
		hp_percent = int(_escort_npc.get("_health")) if _escort_npc.get("_health") else 0

	return [{
		"text": tr(description_key),
		"progress": "HP: %d" % hp_percent,
		"state": state
	}]
