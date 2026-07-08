extends Node2D
## 天降事件效果（F 类预览版）
## 两阶段：telegraph 收缩环 → impact 光柱 + 爆裂

var effect_id: StringName = &"meteor"
var center_pos: Vector2 = Vector2.ZERO
var _elapsed: float = 0.0
var _phase: String = "telegraph"  # telegraph / impact
var _telegraph_duration: float = 1.2

const EFFECT_INFO := {
	&"meteor":         {color = Color(1.0, 0.40, 0.10), label = "陨石",   pillar_color = Color(1.0, 0.50, 0.10)},
	&"divine_strike":  {color = Color(1.0, 0.84, 0.25), label = "神圣审判", pillar_color = Color(1.0, 0.90, 0.50)},
	&"arcane_meteor":  {color = Color(0.60, 0.20, 0.90), label = "奥术陨石", pillar_color = Color(0.70, 0.30, 1.00)},
	&"resurrection":   {color = Color(1.0, 0.84, 0.25), label = "复活",   pillar_color = Color(1.0, 0.90, 0.50)},
}

var _color: Color = Color.WHITE
var _pillar_color: Color = Color.WHITE

func _ready() -> void:
	z_index = 30
	var info = EFFECT_INFO.get(effect_id, EFFECT_INFO[&"meteor"])
	_color = info.color
	_pillar_color = info.pillar_color

func _process(delta: float) -> void:
	_elapsed += delta
	match _phase:
		"telegraph":
			if _elapsed >= _telegraph_duration:
				_phase = "impact"
				_elapsed = 0.0
		"impact":
			var impact_duration := 1.5
			if effect_id == &"resurrection":
				impact_duration = 2.5
			if _elapsed >= impact_duration:
				queue_free()
				return
	queue_redraw()

func _draw() -> void:
	match _phase:
		"telegraph":
			_draw_telegraph()
		"impact":
			_draw_impact()

func _draw_telegraph() -> void:
	var progress := _elapsed / _telegraph_duration
	# 从大到小收缩环
	var outer_r := 60.0
	var r := outer_r * (1.0 - progress * 0.6)
	var alpha := 0.8 * (1.0 - progress * 0.5)
	# 外圈
	draw_arc(Vector2.ZERO, r + 4.0, 0, TAU, 32,
		Color(_color.r, _color.g, _color.b, alpha * 0.3), 2.0)
	# 内圈
	draw_arc(Vector2.ZERO, r, 0, TAU, 32,
		Color(_color.r, _color.g, _color.b, alpha), 3.0)
	# 中心十字
	var cross_s := 8.0
	draw_line(Vector2(-cross_s, 0), Vector2(cross_s, 0),
		Color(_color.r, _color.g, _color.b, alpha * 0.5), 1.5)
	draw_line(Vector2(0, -cross_s), Vector2(0, cross_s),
		Color(_color.r, _color.g, _color.b, alpha * 0.5), 1.5)
	# 淡色填充
	draw_circle(Vector2.ZERO, r,
		Color(_color.r, _color.g, _color.b, 0.06 * (1.0 - progress)))

func _draw_impact() -> void:
	var progress := _elapsed / 1.5
	var alpha := 1.0 - progress
	# 光柱：底端固定在单位中心 (y=0)，顶端随时间下降变短
	var pillar_w := 12.0
	var pillar_h := 200.0 * (1.0 - progress * 0.5)
	# 主体（从 y=-pillar_h 到 y=0，高度 = pillar_h）
	draw_rect(Rect2(-pillar_w / 2.0, -pillar_h, pillar_w, pillar_h),
		Color(_pillar_color.r, _pillar_color.g, _pillar_color.b, alpha * 0.35))
	# 两侧光晕
	draw_rect(Rect2(-pillar_w * 1.5, -pillar_h, pillar_w * 3.0, pillar_h),
		Color(_pillar_color.r, _pillar_color.g, _pillar_color.b, alpha * 0.08))
	# 底部强光（impact 点）
	var impact_r := 20.0 + progress * 15.0
	draw_circle(Vector2.ZERO, impact_r,
		Color(_pillar_color.r, _pillar_color.g, _pillar_color.b, alpha * 0.4))
	draw_circle(Vector2.ZERO, impact_r * 0.4,
		Color(1.0, 1.0, 1.0, alpha * 0.5))

	# resurrection 特殊：额外小光柱
	if effect_id == &"resurrection":
		for i in range(4):
			var angle := float(i) * TAU / 4.0 + _elapsed * 0.5
			var off := Vector2(cos(angle), sin(angle)) * 30.0
			var r := 8.0 * (1.0 - progress * 0.6)
			draw_circle(off, r,
				Color(_pillar_color.r, _pillar_color.g, _pillar_color.b, alpha * 0.3))
			# 小光柱
			var h := 60.0 * (1.0 - progress * 0.5)
			draw_rect(Rect2(off.x - 3.0, off.y - h, 6.0, h),
				Color(_pillar_color.r, _pillar_color.g, _pillar_color.b, alpha * 0.15))
