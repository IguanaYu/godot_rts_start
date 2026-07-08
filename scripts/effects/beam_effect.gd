extends Node2D
## 连接光束效果（E 类预览版）
## 两点之间的光束，全 _draw 实现

var effect_id: StringName = &"heal_beam"
var source_pos: Vector2 = Vector2.ZERO
var target_pos: Vector2 = Vector2.ZERO
var duration_sec: float = 3.0
var _elapsed: float = 0.0

const EFFECT_INFO := {
	&"heal_beam":       {color = Color(0.10, 0.90, 0.30), width = 4.0},
	&"chain_lightning": {color = Color(0.30, 0.70, 1.00), width = 3.0},
	&"siphon":          {color = Color(1.00, 0.10, 0.10), width = 5.0},
	&"life_leech":      {color = Color(0.85, 0.10, 0.10), width = 3.5},
}

var _color: Color = Color.WHITE
var _width: float = 4.0

func _ready() -> void:
	z_index = 30
	var info = EFFECT_INFO.get(effect_id, EFFECT_INFO[&"heal_beam"])
	_color = info.color
	_width = info.width

func _process(delta: float) -> void:
	_elapsed += delta
	if duration_sec > 0.0 and _elapsed >= duration_sec:
		queue_free()
		return
	queue_redraw()

func _draw() -> void:
	var from := source_pos - global_position
	var to := target_pos - global_position
	var dir := (to - from).normalized()
	var perp := Vector2(-dir.y, dir.x)
	var dist := from.distance_to(to)
	var alpha := 1.0
	if duration_sec > 0.0:
		var tail := duration_sec * 0.25
		if _elapsed > duration_sec - tail:
			alpha = (duration_sec - _elapsed) / tail

	match effect_id:
		&"heal_beam":
			# 绿色持续光束 + 中点闪光
			var mid := (from + to) / 2.0
			# 主体光束
			var beam_color := Color(_color.r, _color.g, _color.b, alpha * 0.6)
			draw_line(from, to, beam_color, _width)
			draw_line(from, to, Color(_color.r, _color.g, _color.b, alpha * 0.2), _width * 2.5)
			# 中点脉冲闪光
			var pulse := 0.5 + 0.5 * sin(_elapsed * 5.0)
			draw_circle(mid, 3.0 + pulse * 4.0, Color(_color.r, _color.g, _color.b, alpha * 0.5 * pulse))

		&"chain_lightning":
			# 蓝白锯齿 — 多段折线 + 噪声
			var segments := 8
			var pts := PackedVector2Array()
			for i in range(segments + 1):
				var t := float(i) / float(segments)
				var base := from.lerp(to, t)
				var noise = Vector2(
					sin(_elapsed * 20.0 + t * 15.0) * 8.0,
					cos(_elapsed * 18.0 + t * 13.0) * 8.0
				) * (1.0 - abs(t - 0.5) * 1.5)
				pts.append(base + noise)
			for i in range(segments):
				draw_line(pts[i], pts[i + 1], Color(1.0, 1.0, 1.0, alpha * 0.9), _width + 1.0)
				draw_line(pts[i], pts[i + 1], Color(_color.r, _color.g, _color.b, alpha * 0.6), _width)

		&"siphon":
			# 红黑螺旋 — 沿光束旋转的小球流
			var count := 8
			for i in range(count):
				var t := float(i) / float(count)
				var pos := from.lerp(to, t)
				var offset := Vector2(
					cos(_elapsed * 8.0 + t * 20.0) * 6.0,
					sin(_elapsed * 8.0 + t * 20.0) * 6.0
				)
				draw_circle(pos + offset, 3.0, Color(_color.r, _color.g, _color.b, alpha * 0.7))
			# 中心红线
			draw_line(from, to, Color(_color.r, _color.g, _color.b, alpha * 0.3), _width * 0.5)

		&"life_leech":
			# 红色直线 + 流动光点
			draw_line(from, to, Color(_color.r, _color.g, _color.b, alpha * 0.4), _width)
			# 流动光点
			var flow_t := fmod(_elapsed * 1.5, 1.0)
			var flow_pos := from.lerp(to, flow_t)
			draw_circle(flow_pos, 3.5, Color(_color.r, _color.g, _color.b, alpha * 0.8))
			draw_circle(flow_pos, 1.5, Color(1.0, 1.0, 1.0, alpha * 0.6))
