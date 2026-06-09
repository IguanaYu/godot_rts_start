class_name BonusObjectiveKillCount
extends BonusObjective

@export var kill_target: int = 20
@export var target_unit_category: String = ""  # 为空表示任意敌人

var _kill_count: int = 0

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	# 初始计数敌人
	_count_initial_enemies()

func _count_initial_enemies() -> void:
	for unit in get_tree().get_nodes_in_group("enemy_units"):
		if unit.has_method("is_dead") and unit.is_dead():
			_kill_count += 1

func check() -> bool:
	if is_completed:
		return true

	# 重新计数（简单但有效）
	_kill_count = 0
	for unit in get_tree().get_nodes_in_group("enemy_units"):
		if unit.has_method("is_dead") and unit.is_dead():
			var stats: Resource = unit.get("stats_data")
			if target_unit_category.is_empty() or (stats != null and stats.get("category") == target_unit_category):
				_kill_count += 1

	if _kill_count >= kill_target:
		_grant_reward()
		return true

	return false

func get_objective_text() -> Dictionary:
	return {
		"text": tr(description_key) + " (%d/%d)" % [_kill_count, kill_target],
		"completed": is_completed
	}
