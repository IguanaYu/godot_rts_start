class_name VictoryAssassinate
extends VictoryCondition

## 刺杀/击杀目标条件
## 胜利：所有指定敌方单位死亡
## 失败：玩家全灭

@export var target_units: Array[NodePath] = []
@export var target_category: String = ""  # 为空时使用target_units，非空时扫描enemy_units匹配category

var _targets: Array = []
var _killed_count: int = 0
var _total_targets: int = 0

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	if target_category.is_empty():
		# 使用指定的目标单位
		for np in target_units:
			var node := get_node_or_null(np)
			if node != null:
				_targets.append(node)
				if node.has_signal("died"):
					node.died.connect(_on_target_died)
				_total_targets += 1
				# 检查是否初始已死亡
				if node.has_method("is_dead") and node.is_dead():
					_killed_count += 1
	else:
		# 扫描enemy_units分组，匹配category
		for unit in get_tree().get_nodes_in_group("enemy_units"):
			if unit.has_method("get"):
				var stats = unit.get("stats_data")
				if stats != null and stats.get("category") == target_category:
					_targets.append(unit)
					if unit.has_signal("died"):
						unit.died.connect(_on_target_died)
					_total_targets += 1
					if unit.has_method("is_dead") and unit.is_dead():
						_killed_count += 1

	if _total_targets == 0:
		push_warning("VictoryAssassinate: No targets found!")

func _on_target_died(target: Node) -> void:
	_killed_count += 1
	if _killed_count >= _total_targets:
		# 所有目标已击杀，但暂不宣布胜利，需配合其他条件
		pass

func check() -> int:
	# 胜利条件
	if _killed_count >= _total_targets and _total_targets > 0:
		return 1  # 胜利

	# 失败条件：玩家全灭
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
	if _killed_count >= _total_targets and _total_targets > 0:
		state = 1  # 完成

	var progress_text := "%d/%d" % [_killed_count, _total_targets]
	if not target_category.is_empty():
		progress_text = tr(description_key) + " " + progress_text

	return [{
		"text": tr(description_key) if target_category.is_empty() else "Kill: " + target_category,
		"progress": progress_text,
		"state": state
	}]

func get_progress_fraction() -> float:
	if _total_targets == 0:
		return -1.0
	return float(_killed_count) / float(_total_targets)

func reset() -> void:
	_killed_count = 0
