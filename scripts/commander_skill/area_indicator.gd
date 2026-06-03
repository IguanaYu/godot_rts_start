extends Node2D
## 技能范围指示器：显示一个渐隐的圆圈

var radius: float = 80.0
var indicator_color: Color = Color(1, 0.3, 0.1, 0.4)
var _elapsed: float = 0.0
var _duration: float = 1.5


func _ready() -> void:
	# 创建圆圈
	var circle := Node2D.new()
	circle.set_script(load("res://scripts/commander_skill/circle_renderer.gd"))
	circle.set("circle_radius", radius)
	circle.set("circle_color", indicator_color)
	add_child(circle)


func _process(delta: float) -> void:
	_elapsed += delta
	# 渐隐
	var alpha := 1.0 - (_elapsed / _duration)
	modulate.a = maxf(0.0, alpha)
	if _elapsed >= _duration:
		queue_free()
