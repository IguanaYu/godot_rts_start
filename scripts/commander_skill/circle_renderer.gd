extends Node2D
## 圆圈渲染器：使用 Line2D 绘制圆

var circle_radius: float = 80.0
var circle_color: Color = Color(1, 0.3, 0.1, 0.4)


func _ready() -> void:
	var line := Line2D.new()
	line.width = 2.0
	line.default_color = circle_color
	var segments := 64
	for i in segments + 1:
		var angle := (i / float(segments)) * TAU
		line.add_point(Vector2(cos(angle), sin(angle)) * circle_radius)
	line.z_index = 100
	add_child(line)
