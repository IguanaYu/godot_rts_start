extends Node2D
## 生产圆圈：在建筑上方显示圆形进度条

var _progress: float = 0.0
var _fill_color: Color = Color.WHITE
var _bg_color := Color(0.2, 0.2, 0.2, 0.5)
var _radius := 8.0
var _line_width := 2.0


func setup(fill_color: Color, y_offset: float) -> void:
	_fill_color = fill_color
	position = Vector2(0, y_offset)


func update_progress(ratio: float) -> void:
	_progress = clampf(ratio, 0.0, 1.0)
	queue_redraw()


func _draw() -> void:
	# 底圈（灰色完整圆）
	draw_arc(Vector2.ZERO, _radius, 0, TAU, 32, _bg_color, _line_width)
	# 进度弧
	if _progress > 0.001:
		var end_angle := -PI / 2.0 + _progress * TAU
		draw_arc(Vector2.ZERO, _radius, -PI / 2.0, end_angle, 32, _fill_color, _line_width)
