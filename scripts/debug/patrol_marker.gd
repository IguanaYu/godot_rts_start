@tool
extends Node2D
class_name PatrolMarker

## 编辑器视觉标注：画 4 个同心圈标记敌方单位的
## patrol_radius(150) / PROXIMITY_RANGE(220) / vision_range(250) / leash_range(400)
## 运行时 _ready 隐藏，避免遮挡战斗。

@export var patrol_radius: float = 150.0
@export var proximity_radius: float = 220.0
@export var vision_radius: float = 250.0
@export var leash_radius: float = 400.0

const COLOR_PATROL := Color(1, 1, 1, 0.4)
const COLOR_PROXIMITY := Color(1, 0.9, 0.2, 0.5)
const COLOR_VISION := Color(1, 0.6, 0.2, 0.5)
const COLOR_LEASH := Color(1, 0.2, 0.2, 0.6)


func _ready() -> void:
	if not Engine.is_editor_hint():
		visible = false
	queue_redraw()


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	_draw_circle_outline(Vector2.ZERO, leash_radius, COLOR_LEASH, 2.0)
	_draw_circle_outline(Vector2.ZERO, vision_radius, COLOR_VISION, 2.0)
	_draw_circle_outline(Vector2.ZERO, proximity_radius, COLOR_PROXIMITY, 2.0)
	_draw_circle_outline(Vector2.ZERO, patrol_radius, COLOR_PATROL, 2.0)
	# 中心十字
	draw_line(Vector2(-8, 0), Vector2(8, 0), COLOR_PATROL, 1.5)
	draw_line(Vector2(0, -8), Vector2(0, 8), COLOR_PATROL, 1.5)


func _draw_circle_outline(center: Vector2, radius: float, color: Color, width: float) -> void:
	var point_count := 64
	var prev := center + Vector2(radius, 0)
	for i in range(1, point_count + 1):
		var angle := TAU * i / point_count
		var next := center + Vector2(cos(angle), sin(angle)) * radius
		draw_line(prev, next, color, width)
		prev = next


func _set(property: StringName, value) -> bool:
	if property in ["patrol_radius", "proximity_radius", "vision_radius", "leash_radius"]:
		queue_redraw()
	return false
