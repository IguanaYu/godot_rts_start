extends Node2D
## 区域效果（G 类预览版）
## 地面持续区域光环，多层 draw_arc + draw_circle

var effect_id: StringName = &"heal_aura"
var target_pos: Vector2 = Vector2.ZERO
var duration_sec: float = 5.0
var _elapsed: float = 0.0

const EFFECT_INFO := {
	&"heal_aura":  {color = Color(0.10, 0.90, 0.30), radius = 60.0, pulse = 1.5},
	&"damage_aura":{color = Color(1.00, 0.20, 0.20), radius = 55.0, pulse = 2.0},
	&"slow_aura":  {color = Color(0.50, 0.80, 1.00), radius = 50.0, pulse = 1.2},
	&"fear_aura":  {color = Color(0.60, 0.10, 0.70), radius = 55.0, pulse = 1.8},
}

var _color: Color = Color.WHITE
var _radius: float = 60.0
var _pulse: float = 1.5

func _ready() -> void:
	z_index = 15
	var info = EFFECT_INFO.get(effect_id, EFFECT_INFO[&"heal_aura"])
	_color = info.color
	_radius = info.radius
	_pulse = info.pulse

func _process(delta: float) -> void:
	_elapsed += delta
	if duration_sec > 0.0 and _elapsed >= duration_sec:
		queue_free()
		return
	queue_redraw()

func _draw() -> void:
	var alpha := 1.0
	if duration_sec > 0.0:
		var tail := duration_sec * 0.3
		if _elapsed > duration_sec - tail:
			alpha = maxf(0.0, (duration_sec - _elapsed) / tail)

	var breathe := 1.0 + 0.08 * sin(_elapsed * _pulse)
	var r := _radius * breathe
	var inner_r := r * 0.6

	match effect_id:
		&"heal_aura":
			# 绿色脉动光环
			draw_circle(Vector2.ZERO, r,
				Color(_color.r, _color.g, _color.b, alpha * 0.06))
			draw_arc(Vector2.ZERO, r, 0, TAU, 48,
				Color(_color.r, _color.g, _color.b, alpha * 0.5), 2.5)
			draw_arc(Vector2.ZERO, inner_r, 0, TAU, 48,
				Color(_color.r, _color.g, _color.b, alpha * 0.7), 2.0)
			# 十字治疗标记
			var cs := 10.0
			draw_line(Vector2(-cs, 0), Vector2(cs, 0),
				Color(_color.r, _color.g, _color.b, alpha * 0.5), 2.0)
			draw_line(Vector2(0, -cs), Vector2(0, cs),
				Color(_color.r, _color.g, _color.b, alpha * 0.5), 2.0)

		&"damage_aura":
			# 红色衰减区域（Psi Storm 风格简化）
			var pulse := 0.5 + 0.5 * sin(_elapsed * _pulse)
			draw_circle(Vector2.ZERO, r,
				Color(_color.r, _color.g, _color.b, alpha * 0.08 * (0.5 + pulse)))
			# 锯齿外圈
			for i in range(12):
				var angle := float(i) * TAU / 12.0
				var next_angle := float(i + 1) * TAU / 12.0
				var jitter := 0.85 + 0.15 * sin(_elapsed * 5.0 + float(i) * 2.0)
				var p1 := Vector2(cos(angle), sin(angle)) * r * jitter
				var p2 := Vector2(cos(next_angle), sin(next_angle)) * r * jitter
				draw_line(p1, p2, Color(_color.r, _color.g, _color.b, alpha * 0.4), 2.0)
			draw_circle(Vector2.ZERO, r * 0.3,
				Color(_color.r, _color.g, _color.b, alpha * 0.15))

		&"slow_aura":
			# 蓝色冰雾
			for i in range(3):
				var layer_r := r * (0.5 + float(i) * 0.25)
				var layer_alpha := alpha * (0.15 - float(i) * 0.04)
				draw_circle(Vector2.ZERO, layer_r,
					Color(_color.r, _color.g, _color.b, layer_alpha))
			draw_arc(Vector2.ZERO, r, 0, TAU, 48,
				Color(_color.r, _color.g, _color.b, alpha * 0.35), 2.5)
			# 冰晶点缀
			for i in range(6):
				var angle := float(i) * TAU / 6.0 + _elapsed * 0.3
				var cr := r * 0.7
				var cp := Vector2(cos(angle), sin(angle)) * cr
				var sz := 2.0 + sin(_elapsed * 2.0 + float(i)) * 1.0
				draw_circle(cp, sz,
					Color(_color.r, _color.g, _color.b, alpha * 0.5))

		&"fear_aura":
			# 紫色扭曲区域
			draw_circle(Vector2.ZERO, r,
				Color(_color.r, _color.g, _color.b, alpha * 0.08))
			# 旋转扭曲纹路
			for i in range(8):
				var angle := float(i) * TAU / 8.0 + _elapsed * 0.5
				var inner := Vector2(cos(angle), sin(angle)) * inner_r
				var outer := Vector2(cos(angle + 0.3), sin(angle + 0.3)) * r
				draw_line(inner, outer,
					Color(_color.r, _color.g, _color.b, alpha * 0.3), 2.0)
			# 外圈
			draw_arc(Vector2.ZERO, r, 0, TAU, 48,
				Color(_color.r, _color.g, _color.b, alpha * 0.5), 2.5)
			# 中心眼睛状
			draw_circle(Vector2.ZERO, 6.0,
				Color(_color.r, _color.g, _color.b, alpha * 0.4))
			draw_circle(Vector2.ZERO, 3.0,
				Color(1.0, 1.0, 1.0, alpha * 0.3))
