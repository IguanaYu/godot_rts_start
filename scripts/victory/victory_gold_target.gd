class_name VictoryGoldTarget
extends VictoryCondition

## 收集金币条件
## 胜利：持有金币 ≥ 目标值
## 失败：无（需配合其他失败条件）

@export var gold_target: int = 5000
@export var include_starting_gold: bool = true  # true=当前持有，false=累计收入

var _starting_gold: int = 0

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	if game_controller != null and game_controller.has_method("get"):
		_starting_gold = int(game_controller.get("gold"))

func check() -> int:
	if game_controller == null:
		return 0

	var current_gold: int = int(game_controller.get("gold"))
	var target_gold: int = gold_target

	if not include_starting_gold:
		target_gold += _starting_gold

	if current_gold >= target_gold:
		return 1  # 胜利

	return 0  # 进行中

func get_objectives() -> Array[Dictionary]:
	var current_gold: int = 0
	if game_controller != null:
		current_gold = int(game_controller.get("gold"))

	var target_gold: int = gold_target
	if not include_starting_gold:
		target_gold += _starting_gold

	var state: int = 0
	if current_gold >= target_gold:
		state = 1  # 完成

	return [{
		"text": tr(description_key),
		"progress": "%d/%d" % [current_gold, target_gold],
		"state": state
	}]

func get_progress_fraction() -> float:
	if game_controller == null:
		return 0.0

	var current_gold: int = int(game_controller.get("gold"))
	var target_gold: int = gold_target
	if not include_starting_gold:
		target_gold += _starting_gold

	if target_gold <= 0:
		return 1.0 if current_gold > 0 else 0.0

	return float(current_gold) / float(target_gold)
