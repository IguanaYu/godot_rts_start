extends Node2D
## 目标预览：跟随鼠标的范围圈

var preview_radius: float = 80.0


func _ready() -> void:
	var line := Line2D.new()
	line.width = 2.0
	line.default_color = Color(1, 1, 1, 0.5)
	var segments := 48
	for i in segments + 1:
		var angle := (i / float(segments)) * TAU
		line.add_point(Vector2(cos(angle), sin(angle)) * preview_radius)
	line.z_index = 100
	add_child(line)

	# 半透明填充
	var fill := ColorRect.new()
	fill.color = Color(1, 1, 1, 0.1)
	fill.size = Vector2(preview_radius * 2, preview_radius * 2)
	fill.position = Vector2(-preview_radius, -preview_radius)
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fill.z_index = 99
	add_child(fill)


func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
