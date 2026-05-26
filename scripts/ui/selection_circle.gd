@tool
extends Node2D
## 选中单位脚底绿圈，表示实际碰撞体积

@export var ring_radius: float = 16.0
@export var ring_color: Color = Color(0, 1, 0.3, 0.5)

func _draw() -> void:
	# 淡填充
	draw_circle(Vector2.ZERO, ring_radius, Color(ring_color.r, ring_color.g, ring_color.b, 0.08))
	# 圆环边线
	draw_arc(Vector2.ZERO, ring_radius, 0.0, TAU, 64, ring_color, 1.5)
