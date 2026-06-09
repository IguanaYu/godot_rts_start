class_name VictoryMultiStage
extends VictoryCondition

## 多阶段任务
## 按顺序完成多个阶段的目标

@export var stage_names: Array[String] = []  # 每个阶段的翻译key

var _stages: Array[Node] = []
var _current_stage_index: int = 0

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	# 查找Stage0, Stage1, Stage2...节点
	var i := 0
	while true:
		var stage_name := "Stage%d" % i
		var stage_node := get_node_or_null(NodePath(stage_name))
		if stage_node == null:
			break

		_stages.append(stage_node)

		# 初始化阶段内的条件
		for child in stage_node.get_children():
			if child is VictoryCondition:
				child.set_game_controller(game_controller)
				if child.has_signal("objective_updated"):
					child.objective_updated.connect(_on_sub_objective_updated)
				if child.has_signal("stage_advanced"):
					child.stage_advanced.connect(_on_sub_stage_advanced)

		i += 1

	if _stages.is_empty():
		push_error("VictoryMultiStage: No stages found (Stage0, Stage1, ...)!")

	# 只激活第一阶段
	_activate_stage(0)

func _activate_stage(index: int) -> void:
	_current_stage_index = index

	# 设置所有阶段的process_mode
	for i in range(_stages.size()):
		var stage := _stages[i]
		if i == index:
			stage.process_mode = Node.PROCESS_MODE_INHERIT
			for child in stage.get_children():
				if child is VictoryCondition:
					child.process_mode = Node.PROCESS_MODE_INHERIT
		else:
			stage.process_mode = Node.PROCESS_MODE_DISABLED
			for child in stage.get_children():
				if child is VictoryCondition:
					child.process_mode = Node.PROCESS_MODE_DISABLED

	stage_advanced.emit(index, _stages.size())
	objective_updated.emit()

func _on_sub_objective_updated() -> void:
	objective_updated.emit()

func _on_sub_stage_advanced(stage: int, total: int) -> void:
	# 子阶段的stage_advanced信号不处理，只处理自身的
	pass

func check() -> int:
	if _stages.is_empty():
		return 0

	var current_stage := _stages[_current_stage_index]

	# 检查当前阶段的所有条件
	var stage_victory := false
	var stage_defeat := false

	for child in current_stage.get_children():
		if child is VictoryCondition:
			var result := child.check()
			if result == 1:
				stage_victory = true
			elif result == 2:
				stage_defeat = true

	# 失败立即返回
	if stage_defeat:
		return 2  # 失败

	# 胜利则进入下一阶段
	if stage_victory:
		if _current_stage_index < _stages.size() - 1:
			# 还有下一阶段，切换并继续
			_activate_stage(_current_stage_index + 1)
			return 0  # 进行中
		else:
			# 最后阶段胜利，整体胜利
			return 1  # 胜利

	return 0  # 进行中

func get_objectives() -> Array[Dictionary]:
	var all_objectives := []

	# 显示已完成阶段
	for i in range(_current_stage_index):
		var stage_name := tr(stage_names[i]) if i < stage_names.size() else ("Stage %d" % i)
		all_objectives.append({
			"text": stage_name,
			"progress": tr("OBJ_COMPLETED"),
			"state": 1  # 完成
		})

	# 显示当前阶段的目标
	if _current_stage_index < _stages.size():
		var current_stage := _stages[_current_stage_index]
		var stage_name := tr(stage_names[_current_stage_index]) if _current_stage_index < stage_names.size() else ("Stage %d" % _current_stage_index)

		# 添加阶段标题
		all_objectives.append({
			"text": stage_name,
			"progress": "",
			"state": 0  # 进行中
		})

		# 添加当前阶段的具体目标
		for child in current_stage.get_children():
			if child is VictoryCondition:
				var sub_objs := child.get_objectives()
				for obj in sub_objs:
					# 缩进显示
					obj["text"] = "  " + obj["text"]
					all_objectives.append(obj)

	# 显示未来阶段
	for i in range(_current_stage_index + 1, _stages.size()):
		var stage_name := tr(stage_names[i]) if i < stage_names.size() else ("Stage %d" % i)
		all_objectives.append({
			"text": stage_name,
			"progress": "",
			"state": 0  # 进行中
		})

	return all_objectives

func get_progress_fraction() -> float:
	if _stages.is_empty():
		return -1.0

	return float(_current_stage_index) / float(_stages.size())

func reset() -> void:
	_current_stage_index = 0
	_activate_stage(0)
