extends Node2D

var _label: Label


func _ready() -> void:
	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override("font_size", 24)
	add_child(_label)


func setup(text: String, color: Color, world_pos: Vector2) -> void:
	global_position = world_pos
	z_index = 20

	_label.text = text
	_label.position = Vector2(-80, -30)
	_label.size = Vector2(160, 30)
	_label.add_theme_color_override("font_color", color)
	_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	_label.add_theme_constant_override("shadow_offset_x", 2)
	_label.add_theme_constant_override("shadow_offset_y", 2)

	scale = Vector2(0.3, 0.3)

	var tween := create_tween()
	tween.set_parallel(true)
	# 0-0.3s: 弹出放大
	tween.tween_property(self, "scale", Vector2(1.3, 1.3), 0.3)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	# 0-2.0s: 向上漂浮
	tween.tween_property(self, "position:y", position.y - 80, 2.0)\
		.set_ease(Tween.EASE_OUT)
	# 0.3s后: 缩回 + 淡出
	tween.chain().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.5)
	tween.tween_property(_label, "modulate:a", 0.0, 1.2)
	# 结束清理
	tween.chain().tween_callback(queue_free)
