extends Node2D
## 程序化光球环绕效果（D 类预览版）
## 围绕单位旋转的 N 个光球，全 _draw 实现

var effect_id: StringName = &"holy_orbs"
var target: Node2D = null
var _elapsed: float = 0.0

const EFFECT_INFO := {
	&"holy_orbs":   {color = Color(1.0, 0.84, 0.25), count = 3, radius = 28.0, speed = 1.5},
	&"arcane_orbs": {color = Color(0.60, 0.20, 0.90), count = 5, radius = 32.0, speed = 2.0},
	&"shield_orbit":{color = Color(0.40, 0.70, 1.00), count = 4, radius = 26.0, speed = 1.2},
	&"burning_orbs":{color = Color(1.0, 0.35, 0.05), count = 6, radius = 30.0, speed = 2.5},
	&"poison_orbs": {color = Color(0.50, 0.0, 0.80), count = 4, radius = 28.0, speed = 1.8},
}

var _color: Color = Color.WHITE
var _count: int = 3
var _radius: float = 28.0
var _speed: float = 1.5

func _ready() -> void:
	z_index = 35
	var info = EFFECT_INFO.get(effect_id, EFFECT_INFO[&"holy_orbs"])
	_color = info.color
	_count = info.count
	_radius = info.radius
	_speed = info.speed

func _process(delta: float) -> void:
	_elapsed += delta
	if target != null:
		if not is_instance_valid(target):
			queue_free()
			return
		global_position = target.global_position
	queue_redraw()

func _draw() -> void:
	for i in range(_count):
		var phase := _elapsed * _speed + float(i) / float(_count) * TAU
		var pos := Vector2(cos(phase), sin(phase)) * _radius
		var breath := 1.0 + 0.15 * sin(_elapsed * 3.0 + float(i))
		var r := 4.0 * breath
		# 外光晕
		draw_circle(pos, r * 2.5, Color(_color.r, _color.g, _color.b, 0.15))
		# 主体
		draw_circle(pos, r, Color(_color.r, _color.g, _color.b, 0.85))
		# 核心亮点
		draw_circle(pos, r * 0.4, Color(1.0, 1.0, 1.0, 0.6))
		# 尾迹（最近位置淡出）
		for j in range(3):
			var trail_phase := phase - float(j + 1) * 0.15
			var trail_pos := Vector2(cos(trail_phase), sin(trail_phase)) * _radius
			var trail_alpha := 0.25 - float(j) * 0.08
			if trail_alpha > 0.0:
				draw_circle(trail_pos, r * (1.0 - float(j) * 0.25), Color(_color.r, _color.g, _color.b, trail_alpha))
