extends Control
## PR-T2-4: 升级按钮组件（图标 + 名称 + 等级 + 费用，金币购买）
## 4 种状态：可买（白）/ 金币不够（淡红，可点触发 NO_GOLD 飘字）/ 满级（灰 MAX）/ 单次已购（灰 ✓）

const UUD := preload("res://scripts/upgrade/unit_upgrade_data.gd")

signal purchase_clicked(node_id: String)

var _node_id: String = ""
var _manager: Node
var _main_node: Node2D
var _btn: Button
var _name_label: Label
var _lv_label: Label
var _cost_label: Label


func setup(node_id: String, manager: Node, main_node: Node2D) -> void:
	_node_id = node_id
	_manager = manager
	_main_node = main_node
	_build_ui()
	_refresh()


func _build_ui() -> void:
	custom_minimum_size = Vector2(0, 36)

	_btn = Button.new()
	_btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.2, 0.25, 0.35, 0.6)
	bg.set_corner_radius_all(3)
	var bg_hover := bg.duplicate()
	bg_hover.bg_color = Color(0.3, 0.38, 0.5, 0.8)
	var bg_pressed := bg.duplicate()
	bg_pressed.bg_color = Color(0.15, 0.2, 0.3, 0.8)
	var bg_disabled := bg.duplicate()
	bg_disabled.bg_color = Color(0.15, 0.15, 0.15, 0.5)
	_btn.add_theme_stylebox_override("normal", bg)
	_btn.add_theme_stylebox_override("hover", bg_hover)
	_btn.add_theme_stylebox_override("pressed", bg_pressed)
	_btn.add_theme_stylebox_override("focus", bg)
	_btn.add_theme_stylebox_override("disabled", bg_disabled)
	_btn.pressed.connect(_on_pressed)
	add_child(_btn)

	var hbox := HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.offset_left = 8
	hbox.offset_right = -8
	hbox.add_theme_constant_override("separation", 6)
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hbox)

	var cfg: Dictionary = UUD.CONFIGS[_node_id]
	var icon_path: String = cfg.get("icon", "")
	if icon_path != "":
		var icon := TextureRect.new()
		icon.texture = load(icon_path)
		icon.custom_minimum_size = Vector2(20, 20)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		hbox.add_child(icon)

	_name_label = Label.new()
	_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_name_label.add_theme_font_size_override("font_size", 13)
	_name_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	_name_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	_name_label.add_theme_constant_override("shadow_offset_x", 1)
	_name_label.add_theme_constant_override("shadow_offset_y", 1)
	hbox.add_child(_name_label)

	_lv_label = Label.new()
	_lv_label.add_theme_font_size_override("font_size", 12)
	_lv_label.add_theme_color_override("font_color", Color(0.6, 0.75, 1.0))
	hbox.add_child(_lv_label)

	_cost_label = Label.new()
	_cost_label.add_theme_font_size_override("font_size", 13)
	_cost_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	hbox.add_child(_cost_label)


func refresh() -> void:
	_refresh()


func _refresh() -> void:
	var cfg: Dictionary = UUD.CONFIGS[_node_id]
	var lv: int = _manager.get_level(_node_id)
	var max_lv: int = _manager.get_max_level(_node_id)

	_name_label.text = tr(cfg.get("name", _node_id))
	_name_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))

	if lv >= max_lv:
		_btn.disabled = true
		modulate = Color(0.6, 0.6, 0.6, 1.0)
		_lv_label.text = "MAX" if max_lv > 1 else "✓"
		_cost_label.text = ""
		return

	_btn.disabled = false
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	if max_lv > 1:
		_lv_label.text = "Lv %d/%d" % [lv, max_lv]
	else:
		_lv_label.text = "Lv %d" % lv
	var cost: int = _manager.get_next_cost(_node_id)
	_cost_label.text = "%d 金" % cost
	if _main_node.gold < cost:
		modulate = Color(1.0, 0.75, 0.75, 1.0)


func _on_pressed() -> void:
	if _manager.is_maxed(_node_id):
		return
	# T3 PR: 反馈飘字在鼠标位置（按钮在屏幕底部，世界坐标正好落在按钮上方）
	var pos := _main_node.get_global_mouse_position()
	if not _manager.can_purchase(_node_id):
		_main_node.show_floating_text(tr("NO_GOLD"), Color(1.0, 0.4, 0.4), pos)
		return
	if _manager.purchase(_node_id):
		_main_node.show_floating_text(tr("UU_FEEDBACK_SUCCESS"), Color(0.4, 1.0, 0.4), pos)
		_refresh()
		purchase_clicked.emit(_node_id)
	else:
		_main_node.show_floating_text(tr("UU_FEEDBACK_FAIL"), Color(1.0, 0.4, 0.4), pos)
