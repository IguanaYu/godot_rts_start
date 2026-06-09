class_name BonusObjective
extends Node

## 副目标基类
## 不影响胜负，完成后给予奖励

signal completed(objective: BonusObjective)

@export var objective_id: String = ""
@export var description_key: String = ""
@export var reward_gold: int = 0
@export var reward_units: Dictionary = {}  # {UnitType: count}

var is_completed: bool = false

func check() -> bool:
	return false  # 子类重写

func get_objective_text() -> Dictionary:
	return {"text": tr(description_key), "completed": is_completed}

func _grant_reward() -> void:
	is_completed = true
	completed.emit(self)

	# 通过game_controller发奖励
	var gc: Node = get_parent()
	if gc != null and gc.has_method("get"):
		var main_node: Node = gc.get("game_controller")
		if main_node != null:
			# 金币奖励
			if reward_gold > 0 and main_node.has_method("add_gold"):
				main_node.call("add_gold", reward_gold)

			# 单位奖励
			if not reward_units.is_empty():
				for unit_type in reward_units:
					var count: int = reward_units[unit_type]
					for i in range(count):
						pass
