@tool
extends Node2D
## 选中单位脚底圆圈，带脉动呼吸、选中闪烁、团队颜色

@export var team_color: Color = Color(0.3, 0.6, 1.0, 0.6)

var ring_radius: float = 20.0
var _base_radius: float = 20.0
var _pulse_time: float = 0.0
var _flash_alpha: float = 0.0
var _scale_pulse: float = 0.0


func _process(delta: float) -> void:
	if not visible:
		return
	_pulse_time += delta
	if _flash_alpha > 0.0:
		_flash_alpha = max(0.0, _flash_alpha - delta * 3.3)  # 0.3s 衰减
	if _scale_pulse > 0.0:
		_scale_pulse = max(0.0, _scale_pulse - delta * 4.0)  # 0.25s 衰减
		ring_radius = _base_radius * (1.0 + 0.5 * _scale_pulse)
	queue_redraw()


func flash() -> void:
	_flash_alpha = 1.0


func pulse_scale() -> void:
	_scale_pulse = 1.0


func _draw() -> void:
	# 脉动呼吸：alpha 在 0.4~0.8 之间
	var pulse_alpha := 0.4 + 0.2 * sin(_pulse_time * 3.0)
	var final_alpha := maxf(pulse_alpha, _flash_alpha)
	var r := team_color.r
	var g := team_color.g
	var b := team_color.b

	# 淡填充
	draw_circle(Vector2.ZERO, ring_radius, Color(r, g, b, 0.06))
	# 外层光晕环（更粗更淡）
	draw_arc(Vector2.ZERO, ring_radius + 2.0, 0.0, TAU, 64, Color(r, g, b, final_alpha * 0.3), 4.0)
	# 主圆环
	draw_arc(Vector2.ZERO, ring_radius, 0.0, TAU, 64, Color(r, g, b, final_alpha), 2.5)
