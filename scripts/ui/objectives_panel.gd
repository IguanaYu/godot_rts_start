extends Node

## 目标面板UI
## 显示当前胜负条件和副目标

var _canvas: CanvasLayer
var _panel: PanelContainer
var _vbox: VBoxContainer
var _objective_labels: Array[Control] = []
var _main_node: Node2D = null
var _victory_condition: VictoryCondition = null
var _update_timer: float = 0.0
var _is_visible: bool = true

const PATH_WOOD_TABLE := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Wood Table/WoodTable.png"

func initialize(main_node: Node2D) -> void:
	_main_node = main_node
	_victory_condition = null
	_create_panel()
	_update_objectives()

func _connect_victory_condition() -> void:
	if _victory_condition == null and _main_node != null and is_instance_valid(_main_node):
		_victory_condition = _main_node.get("victory_condition")
		if _victory_condition != null:
			if _victory_condition.has_signal("objective_updated"):
				_victory_condition.objective_updated.connect(_on_objective_updated)
			if _victory_condition.has_signal("stage_advanced"):
				_victory_condition.stage_advanced.connect(_on_stage_advanced)
			_update_objectives()

func _create_panel() -> void:
	# 创建CanvasLayer（layer 8，低于主UI的10）
	_canvas = CanvasLayer.new()
	_canvas.layer = 8
	_canvas.name = "ObjectivesCanvas"
	get_node("/root").add_child(_canvas)


	# 创建面板容器
	_panel = PanelContainer.new()
	_panel.name = "ObjectivesPanel"
	_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_panel.offset_left = -270
	_panel.offset_right = -20
	_panel.offset_top = 20
	_panel.offset_bottom = 200
	_canvas.add_child(_panel)


	# 创建VBox容器
	_vbox = VBoxContainer.new()
	_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_vbox.add_theme_constant_override("separation", 4)
	_panel.add_child(_vbox)

	# 标题
	var title := Label.new()
	title.text = "OBJECTIVES"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(1, 0.85, 0))
	_vbox.add_child(title)

	# 折叠按钮
	var toggle_btn := Button.new()
	toggle_btn.text = "▼"
	toggle_btn.custom_minimum_size = Vector2(40, 20)
	toggle_btn.pressed.connect(_on_toggle_pressed)
	_vbox.add_child(toggle_btn)
	var BF := preload("res://scripts/ui/button_factory.gd")
	BF.add_hover_anim_button(toggle_btn)

func _on_toggle_pressed() -> void:
	_is_visible = not _is_visible
	for i in range(2, _objective_labels.size()):  # 跳过标题和按钮
		if _objective_labels[i] != null:
			_objective_labels[i].visible = _is_visible

func _on_objective_updated() -> void:
	_update_objectives()

func _on_stage_advanced(stage: int, total: int) -> void:
	_update_objectives()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		# 面板销毁时清理 CanvasLayer（挂在 /root 上不会随场景自动销毁）
		if _canvas != null and is_instance_valid(_canvas):
			# 先清理子节点避免泄漏
			for child in _canvas.get_children():
				child.queue_free()
			_canvas.queue_free()
			_canvas = null

func _process(delta: float) -> void:
	# 如果主节点不在场景树中（切回了选关界面），隐藏面板
	if _main_node == null or not is_instance_valid(_main_node) or not _main_node.is_inside_tree():
		if _canvas and _canvas.visible:
			_canvas.visible = false
		return
	elif _canvas and not _canvas.visible:
		_canvas.visible = true

	# 延迟连接 victory_condition
	if _victory_condition == null:
		_connect_victory_condition()

	# 每秒更新一次时间类目标
	_update_timer += delta
	if _update_timer >= 1.0:
		_update_timer = 0.0
		_update_objectives()

func _update_objectives() -> void:
	if _victory_condition == null:
		return

	# 清除现有标签
	for label in _objective_labels:
		if label != null and is_instance_valid(label):
			label.queue_free()
	_objective_labels.clear()

	# 获取目标列表
	var objectives := _victory_condition.get_objectives()

	# 重建标签
	for obj in objectives:
		var label := Label.new()
		label.text = obj.get("text", "")
		label.add_theme_font_size_override("font_size", 12)

		# 根据状态设置颜色
		var state : int = obj.get("state", 0)
		match state:
			1:  # 完成
				label.modulate = Color(0.3, 1.0, 0.3)
			2:  # 失败
				label.modulate = Color(1.0, 0.3, 0.3)
			_:  # 进行中
				label.modulate = Color(0.9, 0.9, 0.9)

		_vbox.add_child(label)
		_objective_labels.append(label)

		# 添加进度信息
		var progress : String = obj.get("progress", "")
		if not progress.is_empty():
			var progress_label := Label.new()
			progress_label.text = "  " + progress
			progress_label.add_theme_font_size_override("font_size", 10)
			progress_label.modulate = Color(0.7, 0.7, 0.7)
			_vbox.add_child(progress_label)
			_objective_labels.append(progress_label)
