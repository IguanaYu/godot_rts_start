class_name VictoryComposite
extends VictoryCondition

## 组合条件
## 将多个子条件用 AND/OR 逻辑组合

enum LogicMode { AND, OR }

@export var logic_mode: LogicMode = LogicMode.AND  # 0=AND(全部满足), 1=OR(任一满足)

var _sub_conditions: Array[VictoryCondition] = []

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	# 发现所有VictoryCondition子节点
	for child in get_children():
		if child is VictoryCondition:
			_sub_conditions.append(child)
			# 给子条件传game_controller
			child.set_game_controller(game_controller)
			# 监听子条件的状态变化
			if child.has_signal("objective_updated"):
				child.objective_updated.connect(_on_sub_objective_updated)
			if child.has_signal("stage_advanced"):
				child.stage_advanced.connect(_on_sub_stage_advanced)

	if _sub_conditions.is_empty():
		push_warning("VictoryComposite: No sub-conditions found!")

func _on_sub_objective_updated() -> void:
	objective_updated.emit()

func _on_sub_stage_advanced(stage: int, total: int) -> void:
	stage_advanced.emit(stage, total)

func check() -> int:
	if _sub_conditions.is_empty():
		return 0

	var victory_count := 0
	var defeat_count := 0
	var ongoing_count := 0

	# 检查所有子条件
	for condition in _sub_conditions:
		var result := condition.check()
		match result:
			1:
				victory_count += 1
			2:
				defeat_count += 1
			_:
				ongoing_count += 1

	match logic_mode:
		LogicMode.AND:
			# AND模式：全部胜利才胜利，任一失败则失败
			if defeat_count > 0:
				return 2  # 失败
			if victory_count == _sub_conditions.size():
				return 1  # 胜利
			return 0  # 进行中

		LogicMode.OR:
			# OR模式：任一胜利就胜利，全部失败才失败
			if victory_count > 0:
				return 1  # 胜利
			if defeat_count == _sub_conditions.size():
				return 2  # 失败
			return 0  # 进行中

	return 0

func get_objectives() -> Array[Dictionary]:
	var all_objectives := []

	# 收集所有子条件的目标
	for condition in _sub_conditions:
		var sub_objs := condition.get_objectives()
		for obj in sub_objs:
			all_objectives.append(obj)

	return all_objectives

func get_progress_fraction() -> float:
	if _sub_conditions.is_empty():
		return -1.0

	var total_progress := 0.0
	var valid_count := 0

	for condition in _sub_conditions:
		var fraction := condition.get_progress_fraction()
		if fraction >= 0:
			total_progress += fraction
			valid_count += 1

	if valid_count == 0:
		return -1.0

	return total_progress / float(valid_count)

func reset() -> void:
	for condition in _sub_conditions:
		condition.reset()
