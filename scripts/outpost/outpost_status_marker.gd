extends Node2D
## 据点指挥官持续状态反馈（Status 类，跟随 buff/状态时长）
##
## 与 telegraph_overlay 区别：
## - telegraph：瞬时事件，1.2-2s 后 queue_free，告诉玩家"刚刚发生了 X"
## - status：跟随目标/状态，duration 跟 buff 同步，告诉玩家"这个目标正在被 X 影响"
##
## 支持的 effect_id：
## - shield:    跟随 target_building，六边形护盾，duration 跟 buff 同步（默认 12s），最后 3s 闪烁
## - inspire:   静态位置（target_pos），金色淡光圈，duration 默认 8s
## - heal:      静态位置（target_pos），绿色淡圆环，duration 3s
## - attack:    跟随 commander（target=null，center=指挥官位置），红色淡描边，duration 直到外部 free

var target: Node = null          # 可空。若非空则每帧跟随 target.global_position
var center: Vector2 = Vector2.ZERO  # target 为空时使用
var effect_id: StringName = &""
var duration_sec: float = 5.0

var _elapsed: float = 0.0
var _color: Color = Color.WHITE
var _radius: float = 35.0  # 视觉半径（不同 effect 不同含义）

const EFFECT_INFO := {
	&"shield":   {color = Color(0.40, 0.70, 1.00), radius = 38.0},
	&"inspire":  {color = Color(1.00, 0.82, 0.29), radius = 50.0},
	&"heal":     {color = Color(0.10, 0.90, 0.30), radius = 60.0},
	&"attack":   {color = Color(1.00, 0.25, 0.25), radius = 0.0},
	&"burn":     {color = Color(1.00, 0.55, 0.00), radius = 42.0},
	&"poison":   {color = Color(0.50, 0.00, 0.80), radius = 42.0},
	&"rage":     {color = Color(1.00, 0.15, 0.00), radius = 45.0},
	&"slow":     {color = Color(0.40, 0.70, 1.00), radius = 45.0},
	&"telegraph_aoe": {color = Color(1.00, 0.20, 0.20), radius = 50.0},
}

const WARN_TAIL_RATIO := 0.25  # 最后 25% 时间进入闪烁警示（buff 即将结束）


func _ready() -> void:
	z_index = 40
	var info: Dictionary = EFFECT_INFO.get(effect_id, {})
	_color = info.get("color", Color.WHITE)
	if effect_id != &"attack":
		_radius = info.get("radius", 35.0)


func _process(delta: float) -> void:
	_elapsed += delta
	# 跟随目标
	if target != null:
		if not is_instance_valid(target):
			queue_free()
			return
		if target.has_method("is_dead") and target.is_dead():
			queue_free()
			return
		global_position = target.global_position
	else:
		global_position = center
	# attack 状态：duration 0 表示"持续到外部 free"
	if duration_sec > 0.0 and _elapsed >= duration_sec:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var alpha: float = 0.85  # 默认基础 alpha
	# 最后阶段闪烁警示
	if duration_sec > 0.0:
		var warn_start: float = duration_sec * (1.0 - WARN_TAIL_RATIO)
		if _elapsed > warn_start:
			# 2Hz 闪烁，越接近结束越淡
			var tail_ratio: float = (_elapsed - warn_start) / (duration_sec - warn_start)
			var base_alpha: float = 0.85 * (1.0 - tail_ratio * 0.6)
			alpha = base_alpha * (0.4 + 0.6 * (1.0 if int(_elapsed * 6.0) % 2 == 0 else 0.2))

	var color := Color(_color.r, _color.g, _color.b, alpha)

	match effect_id:
		&"shield":
			_draw_hexagon(_radius, color)
		&"inspire":
			# 双层光圈：外淡内深
			draw_arc(Vector2.ZERO, _radius, 0, TAU, 48,
				Color(_color.r, _color.g, _color.b, alpha * 0.45), 2.5)
			draw_arc(Vector2.ZERO, _radius * 0.7, 0, TAU, 48,
				Color(_color.r, _color.g, _color.b, alpha * 0.8), 2.0)
			draw_circle(Vector2.ZERO, _radius,
				Color(_color.r, _color.g, _color.b, alpha * 0.08))
		&"heal":
			draw_arc(Vector2.ZERO, _radius, 0, TAU, 48, color, 2.5)
			draw_circle(Vector2.ZERO, _radius,
				Color(_color.r, _color.g, _color.b, alpha * 0.10))
		&"attack":
			# 红色淡描边（territory_radius 由外部 _radius 设置）
			if _radius > 0.0:
				draw_arc(Vector2.ZERO, _radius, 0, TAU, 64,
					Color(_color.r, _color.g, _color.b, alpha * 0.6), 2.0)
		_:
			# 默认：通用地面贴花（外圈描边 + 内圈 + 淡填充）
			draw_arc(Vector2.ZERO, _radius, 0, TAU, 48,
				Color(_color.r, _color.g, _color.b, alpha * 0.7), 3.0)
			draw_arc(Vector2.ZERO, _radius * 0.7, 0, TAU, 48,
				Color(_color.r, _color.g, _color.b, alpha * 0.4), 1.5)
			draw_circle(Vector2.ZERO, _radius,
				Color(_color.r, _color.g, _color.b, alpha * 0.10))


func _draw_hexagon(size: float, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in range(6):
		var angle := i * TAU / 6.0
		pts.append(Vector2(cos(angle), sin(angle)) * size)
	draw_colored_polygon(pts, Color(color.r, color.g, color.b, color.a * 0.15))
	for i in range(6):
		var a := pts[i]
		var b := pts[(i + 1) % 6]
		draw_line(a, b, color, 2.0)


## 由 OutpostCommander 在领地半径场景下注入（attack 状态用）
func set_visual_radius(r: float) -> void:
	_radius = r
