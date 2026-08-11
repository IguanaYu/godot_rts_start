extends CanvasLayer
## T3 升级 N 选 1 弹窗：屏幕居中显示候选项，玩家点击选择

signal choice_confirmed(unit_type: int, choice_id: StringName)

var _overlay: ColorRect
var _panel: PanelContainer
var _choices_vbox: VBoxContainer
var _current_unit_type: int = -1
var _current_data: Resource  # T3UpgradeData

func _ready() -> void:
	layer = 95  # 低于暂停菜单（100），高于其他 UI
	_create_ui()
	hide()

func _create_ui() -> void:
	# 半透明遮罩
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0.5)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_overlay)

	# 主面板（居中）
	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(500, 400)
	_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	add_child(_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	_panel.add_child(vbox)

	var title := Label.new()
	title.text = "T3 升级（N 选 1，不可更改）"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	_choices_vbox = VBoxContainer.new()
	_choices_vbox.add_theme_constant_override("separation", 8)
	vbox.add_child(_choices_vbox)

func show_for_unit(unit_type: int, data: Resource) -> void:
	_current_unit_type = unit_type
	_current_data = data
	for child in _choices_vbox.get_children():
		child.queue_free()
	for choice in data.choices:
		var btn := _create_choice_card(choice)
		_choices_vbox.add_child(btn)
	show()

func _create_choice_card(choice: Resource) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 80)
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	card.add_child(hbox)

	# 染色色块（与单位 tint 一致）
	var color_rect := ColorRect.new()
	color_rect.color = choice.tint
	color_rect.custom_minimum_size = Vector2(40, 40)
	hbox.add_child(color_rect)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info)

	var name_label := Label.new()
	name_label.text = "%s（%s）" % [choice.display_name, choice.positioning]
	info.add_child(name_label)

	var desc_label := Label.new()
	desc_label.text = choice.description
	desc_label.add_theme_font_size_override("font_size", 12)
	info.add_child(desc_label)

	var confirm_btn := Button.new()
	confirm_btn.text = "确认（%d 金）" % _current_data.cost
	confirm_btn.pressed.connect(func():
		choice_confirmed.emit(_current_unit_type, choice.choice_id)
		hide())
	hbox.add_child(confirm_btn)

	return card

func _unhandled_input(event: InputEvent) -> void:
	if visible and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		# 不允许 ESC 取消（玩家必须选一个，避免误操作）
		pass