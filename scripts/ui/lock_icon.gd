extends Control
## PR-T2-5: 灰色锁图标（简笔绘制，避免依赖 emoji 字体渲染）

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var w := size.x
	var h := size.y
	if w <= 0 or h <= 0:
		return
	# 锁身（圆角矩形）
	var body_sb := StyleBoxFlat.new()
	body_sb.bg_color = Color(0.2, 0.2, 0.24, 0.95)
	body_sb.set_corner_radius_all(2)
	body_sb.set_border_width_all(1)
	body_sb.border_color = Color(0.5, 0.5, 0.55, 1.0)
	draw_style_box(body_sb, Rect2(3, 6, w - 6, h - 6))
	# 锁孔
	draw_circle(Vector2(w / 2.0, h - 4.5), 2.2, Color(0.85, 0.85, 0.9, 1.0))
	# 锁梁（上半圆弧）
	draw_arc(Vector2(w / 2.0, 7.0), 4.0, PI, TAU, 24, Color(0.5, 0.5, 0.55, 1.0), 2.0)
