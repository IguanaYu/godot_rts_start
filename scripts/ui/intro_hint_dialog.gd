extends CanvasLayer
## T3 PR-3: 开局一次性提示"摧毁敌方据点获胜"
## 每次进游戏都显示，玩家点"知道了"关闭。


func _ready() -> void:
	layer = 95  # 低于胜利/失败画面（100），高于普通 UI
	_create_ui()


func _create_ui() -> void:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.5)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(420, 220)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "本局任务"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
	vbox.add_child(title)

	var desc := Label.new()
	desc.text = "摧毁敌方据点（敌方城堡）即可获胜。\n保护我方城堡不被摧毁。"
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.add_theme_font_size_override("font_size", 14)
	desc.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	vbox.add_child(desc)

	var btn := Button.new()
	btn.text = "知道了"
	btn.custom_minimum_size = Vector2(120, 36)
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn.add_theme_font_size_override("font_size", 14)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.pressed.connect(func(): queue_free())
	vbox.add_child(btn)


# 拦截 ESC / 鼠标点击外部，强制玩家点"知道了"
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
