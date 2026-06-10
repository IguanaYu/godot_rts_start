extends Node

## 信息面板UI：波次倒计时 + 目标条件
## 右上角统一面板，包含 Waves 区和 Objectives 区

var _canvas: CanvasLayer
var _panel: PanelContainer
var _vbox: VBoxContainer
var _wave_container: VBoxContainer
var _obj_container: VBoxContainer
var _body_container: VBoxContainer
var _objective_labels: Array[Control] = []
var _wave_rows: Dictionary = {}  # wave_number -> HBoxContainer
var _main_node: Node2D = null
var _victory_condition: VictoryCondition = null
var _update_timer: float = 0.0
var _is_visible: bool = true
var _toggle_btn: Button

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
	_canvas = CanvasLayer.new()
	_canvas.layer = 8
	_canvas.name = "InfoCanvas"
	get_node("/root").add_child(_canvas)

	# 面板容器
	_panel = PanelContainer.new()
	_panel.name = "InfoPanel"
	_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_panel.offset_left = -240
	_panel.offset_right = -12
	_panel.offset_top = 12
	_panel.offset_bottom = 220
	_panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0, 0, 0, 0.5)
	panel_style.set_corner_radius_all(6)
	panel_style.set_content_margin_all(10)
	panel_style.set_border_width_all(1)
	panel_style.border_color = Color(1, 1, 1, 0.08)
	_panel.add_theme_stylebox_override("panel", panel_style)
	_canvas.add_child(_panel)

	_vbox = VBoxContainer.new()
	_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_vbox.add_theme_constant_override("separation", 4)
	_panel.add_child(_vbox)

	# Header: "Info" + 折叠按钮
	var header := HBoxContainer.new()
	header.alignment = BoxContainer.ALIGNMENT_CENTER
	_vbox.add_child(header)

	var title := Label.new()
	title.text = "Info"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 13)
	title.add_theme_color_override("font_color", Color(1, 0.85, 0))
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	_toggle_btn = Button.new()
	_toggle_btn.text = "▼"
	_toggle_btn.custom_minimum_size = Vector2(24, 20)
	_toggle_btn.add_theme_font_size_override("font_size", 12)
	_toggle_btn.add_theme_color_override("font_color", Color(0.53, 0.53, 0.53))
	_toggle_btn.pressed.connect(_on_toggle_pressed)
	var btn_empty := StyleBoxEmpty.new()
	_toggle_btn.add_theme_stylebox_override("normal", btn_empty)
	_toggle_btn.add_theme_stylebox_override("hover", btn_empty)
	_toggle_btn.add_theme_stylebox_override("pressed", btn_empty)
	header.add_child(_toggle_btn)

	# 可折叠的 body 区域
	_body_container = VBoxContainer.new()
	_body_container.add_theme_constant_override("separation", 4)
	_vbox.add_child(_body_container)

	# Waves 区
	var wave_section := Label.new()
	wave_section.text = "WAVES"
	wave_section.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wave_section.add_theme_font_size_override("font_size", 11)
	wave_section.add_theme_color_override("font_color", Color(0.33, 0.33, 0.33))
	_body_container.add_child(wave_section)

	_wave_container = VBoxContainer.new()
	_wave_container.add_theme_constant_override("separation", 3)
	_body_container.add_child(_wave_container)

	# 分隔线
	var sep := HSeparator.new()
	sep.add_theme_stylebox_override("separator", _make_line_style())
	_body_container.add_child(sep)

	# Objectives 区
	var obj_section := Label.new()
	obj_section.text = "OBJECTIVES"
	obj_section.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	obj_section.add_theme_font_size_override("font_size", 11)
	obj_section.add_theme_color_override("font_color", Color(0.33, 0.33, 0.33))
	_body_container.add_child(obj_section)

	_obj_container = VBoxContainer.new()
	_obj_container.add_theme_constant_override("separation", 2)
	_body_container.add_child(_obj_container)

func _make_line_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(1, 1, 1, 0.06)
	s.set_content_margin_all(2)
	return s

func _on_toggle_pressed() -> void:
	_is_visible = not _is_visible
	_toggle_btn.text = "▶" if not _is_visible else "▼"
	_body_container.visible = _is_visible
	# 收起时缩小面板
	if _is_visible:
		_panel.offset_bottom = 220
	else:
		_panel.offset_bottom = 55

func _on_objective_updated() -> void:
	_update_objectives()

func _on_stage_advanced(stage: int, total: int) -> void:
	_update_objectives()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if _canvas != null and is_instance_valid(_canvas):
			for child in _canvas.get_children():
				child.queue_free()
			_canvas.queue_free()
			_canvas = null

func _process(delta: float) -> void:
	if _main_node == null or not is_instance_valid(_main_node) or not _main_node.is_inside_tree():
		if _canvas and _canvas.visible:
			_canvas.visible = false
		return
	elif _canvas and not _canvas.visible:
		_canvas.visible = true

	if _victory_condition == null:
		_connect_victory_condition()

	_update_timer += delta
	if _update_timer >= 1.0:
		_update_timer = 0.0
		_update_objectives()

func _update_objectives() -> void:
	if _victory_condition == null:
		return

	for label in _objective_labels:
		if label != null and is_instance_valid(label):
			label.queue_free()
	_objective_labels.clear()

	var objectives := _victory_condition.get_objectives()

	for obj in objectives:
		var label := Label.new()
		label.text = obj.get("text", "")
		label.add_theme_font_size_override("font_size", 12)

		var state : int = obj.get("state", 0)
		match state:
			1:
				label.modulate = Color(0.3, 1.0, 0.3)
			2:
				label.modulate = Color(1.0, 0.3, 0.3)
			_:
				label.modulate = Color(0.8, 0.88, 1.0)

		_obj_container.add_child(label)
		_objective_labels.append(label)

		var progress : String = obj.get("progress", "")
		if not progress.is_empty():
			var progress_label := Label.new()
			progress_label.text = "  " + progress
			progress_label.add_theme_font_size_override("font_size", 10)
			progress_label.modulate = Color(0.53, 0.53, 0.53)
			_obj_container.add_child(progress_label)
			_objective_labels.append(progress_label)

	if not _is_visible:
		_body_container.visible = false
		_panel.offset_bottom = 55

# === 波次倒计时接口 ===

func update_wave_countdown(wave_number: int, remaining: float, total: int) -> void:
	if _wave_container == null:
		return
	if remaining <= 0:
		_remove_wave(wave_number)
		return

	var row: HBoxContainer = _wave_rows.get(wave_number, null)
	if row == null:
		row = _create_wave_row(wave_number)
		_wave_rows[wave_number] = row

	# 更新进度条
	var bar: ProgressBar = row.get_meta("wave_bar")
	if bar:
		bar.value = remaining

	# 更新倒计时文字
	var time_label: Label = row.get_meta("time_label")
	if time_label:
		var secs := ceili(remaining)
		if secs >= 60:
			time_label.text = "%d:%02d" % [secs / 60, secs % 60]
		else:
			time_label.text = "%ds" % secs

func hide_wave_countdown() -> void:
	for wave_num in _wave_rows:
		var row: HBoxContainer = _wave_rows[wave_num]
		if row != null and is_instance_valid(row):
			row.queue_free()
	_wave_rows.clear()

func _create_wave_row(wave_number: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)

	var display_num := wave_number + 1
	var name_label := Label.new()
	name_label.text = "Wave %d" % display_num
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	name_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	name_label.custom_minimum_size.x = 56
	row.add_child(name_label)

	var bar := ProgressBar.new()
	bar.max_value = 30.0
	bar.value = 30.0
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(60, 3)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var bar_bg := StyleBoxFlat.new()
	bar_bg.bg_color = Color(1, 1, 1, 0.1)
	bar_bg.set_corner_radius_all(2)
	bar.add_theme_stylebox_override("background", bar_bg)
	var bar_fill := StyleBoxFlat.new()
	bar_fill.bg_color = Color(1, 0.3, 0.3)
	bar_fill.set_corner_radius_all(2)
	bar.add_theme_stylebox_override("fill", bar_fill)
	row.add_child(bar)
	row.set_meta("wave_bar", bar)

	var time_label := Label.new()
	time_label.text = ""
	time_label.add_theme_font_size_override("font_size", 11)
	time_label.add_theme_color_override("font_color", Color(0.53, 0.53, 0.53))
	row.add_child(time_label)
	row.set_meta("time_label", time_label)

	_wave_container.add_child(row)
	return row

func _remove_wave(wave_number: int) -> void:
	var row: HBoxContainer = _wave_rows.get(wave_number, null)
	if row != null and is_instance_valid(row):
		row.queue_free()
	_wave_rows.erase(wave_number)
