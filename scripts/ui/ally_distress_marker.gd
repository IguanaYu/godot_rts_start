class_name AllyDistressMarker
extends Node2D
## AI 队友求救感叹号：在求救位置闪烁，由 AllyDistressSignal.distress_cleared 时由 main 移除

var _label: Label


func _ready() -> void:
	_label = Label.new()
	_label.text = "!"
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override("font_size", 56)
	_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	_label.add_theme_constant_override("shadow_offset_x", 3)
	_label.add_theme_constant_override("shadow_offset_y", 3)
	_label.position = Vector2(-30, -90)
	_label.size = Vector2(60, 90)
	add_child(_label)
	z_index = 50

	var tween := create_tween().set_loops()
	tween.tween_property(_label, "modulate:a", 0.35, 0.4).set_trans(Tween.TRANS_SINE)
	tween.tween_property(_label, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE)


func setup(world_pos: Vector2) -> void:
	global_position = world_pos
