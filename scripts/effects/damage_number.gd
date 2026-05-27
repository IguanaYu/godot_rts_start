extends Node2D

## 伤害飘字：4层描边 + 砸下弹跳动画

var _shadows: Array[Label] = []
var _label: Label

const FONT_SIZE := 32
const OUTLINE_D := 3  # 描边偏移像素


func _ready() -> void:
	# 4个描边层：上、下、左、右
	var dirs := [Vector2(0, -OUTLINE_D), Vector2(0, OUTLINE_D),
				Vector2(-OUTLINE_D, 0), Vector2(OUTLINE_D, 0)]
	for dir in dirs:
		var s := Label.new()
		s.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		s.add_theme_font_size_override("font_size", FONT_SIZE)
		s.add_theme_color_override("font_color", Color(0, 0, 0))
		# 偏移相对于主文字位置
		s.position = dir
		add_child(s)
		_shadows.append(s)

	# 主文字层
	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override("font_size", FONT_SIZE)
	add_child(_label)


func setup(amount: int, world_pos: Vector2) -> void:
	var offset := Vector2(randf_range(-16, 16), randf_range(-8, 8))
	global_position = world_pos + offset
	z_index = 20

	var text := str(amount)
	var label_pos := Vector2(-80, -50)
	var label_size := Vector2(160, 50)

	_label.text = text
	_label.position = label_pos
	_label.size = label_size
	_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.15))

	for s in _shadows:
		s.text = text
		s.size = label_size
		# position = dir（已在_ready中设置）+ label_pos
		s.position += label_pos

	# 砸下弹跳动画
	scale = Vector2(0.1, 0.1)

	var tween := create_tween()
	# 阶段1：快速砸下放大
	tween.tween_property(self, "scale", Vector2(1.8, 1.8), 0.1)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	# 阶段2：弹性回弹
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	# 阶段3：上浮 + 淡出（并行）
	tween.parallel().tween_property(self, "position:y", position.y - 60, 0.9)\
		.set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(_label, "modulate:a", 0.0, 0.9)
	for s in _shadows:
		tween.parallel().tween_property(s, "modulate:a", 0.0, 0.9)
	# 结束清理
	tween.chain().tween_callback(queue_free)
