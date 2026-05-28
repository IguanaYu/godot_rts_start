extends Node2D
## 集结点指示器：旗帜 + 虚线连接

var _target_pos: Vector2 = Vector2.ZERO  # 相对于建筑的本地坐标
var _flag_height: float = 24.0
var _flag_width: float = 14.0
var _color: Color = Color(1.0, 0.85, 0.0, 0.8)  # 黄色
var _dash_length: float = 8.0
var _gap_length: float = 6.0


func setup(rally_world_pos: Vector2, building_world_pos: Vector2) -> void:
	_target_pos = rally_world_pos - building_world_pos
	queue_redraw()


func _draw() -> void:
	if _target_pos.length_squared() < 4.0:
		return

	# 虚线：从建筑中心到集结点
	var direction := _target_pos.normalized()
	var total_dist := _target_pos.length()
	var drawn := 0.0
	var drawing := true
	while drawn < total_dist:
		var seg_len := _dash_length if drawing else _gap_length
		if drawing:
			var start := direction * drawn
			var end := direction * minf(drawn + seg_len, total_dist)
			draw_line(start, end, Color(_color.r, _color.g, _color.b, 0.5), 1.5)
		drawn += seg_len
		drawing = not drawing

	# 旗杆
	draw_line(_target_pos, _target_pos + Vector2(0, -_flag_height), _color, 2.0)

	# 三角旗帜
	var pole_top := _target_pos + Vector2(0, -_flag_height)
	var flag_points := PackedVector2Array([
		pole_top,
		pole_top + Vector2(_flag_width, _flag_height * 0.35),
		pole_top + Vector2(0, _flag_height * 0.6),
	])
	draw_colored_polygon(flag_points, _color)
