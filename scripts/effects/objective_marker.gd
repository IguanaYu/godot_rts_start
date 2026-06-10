extends Node2D
## 任务目标标记：头顶浮动图标，标记保护/击杀/收集等目标
## 全部程序化绘制，支持等级变体和状态切换

enum MarkerType { CROWN, SHIELD, SKULL, CROSSHAIR, STAR, FLAG, DIAMOND }
enum MarkerLevel { NORMAL, IMPORTANT, CRITICAL }

@export var marker_type: MarkerType = MarkerType.CROWN
@export var marker_level: MarkerLevel = MarkerLevel.NORMAL

## 要追踪的目标节点（标记会跟随此节点的位置）
var _target: Node2D

## 浮动高度（相对于目标位置的偏移，负数=向上）
@export var height_offset: float = -48.0
## 图标基础大小
@export var icon_size: float = 24.0
## 浮动幅度
@export var float_amplitude: float = 5.0
## 浮动速度
@export var float_speed: float = 2.0
## 脉冲速度（呼吸灯）
@export var pulse_speed: float = 4.0

var _time: float = 0.0
var _dying: bool = false
var _danger: bool = false
var _fade_alpha: float = 1.0

# 颜色
var _color_crown := Color(1.0, 0.84, 0.0)       # 金色
var _color_shield := Color(0.3, 0.75, 0.3)       # 绿色
var _color_shield_danger := Color(0.9, 0.15, 0.15)  # 濒危红色
var _color_skull := Color(0.9, 0.2, 0.2)         # 红色
var _color_crosshair := Color(1.0, 0.43, 0.0)    # 橙红
var _color_star := Color(1.0, 0.84, 0.25)        # 金黄
var _color_flag := Color(0.26, 0.65, 0.96)       # 蓝色
var _color_diamond := Color(1.0, 0.76, 0.03)     # 黄色


func _ready() -> void:
	add_to_group("objective_markers")
	z_index = 100


func _process(delta: float) -> void:
	_time += delta

	if _dying:
		_fade_alpha -= delta * 2.0  # 0.5s 淡出
		if _fade_alpha <= 0.0:
			queue_free()
			return
		modulate.a = _fade_alpha
		scale = Vector2.ONE * maxf(0.3, _fade_alpha)
	else:
		# 呼吸脉冲
		modulate.a = 0.6 + 0.4 * sin(_time * pulse_speed)

	# 跟随目标位置
	if _target != null and is_instance_valid(_target):
		global_position = _target.global_position + Vector2(0, height_offset + sin(_time * float_speed) * float_amplitude)
	else:
		# 目标已失效，淡出
		dismiss()

	queue_redraw()


func _draw() -> void:
	var s := icon_size
	var color := _get_color()

	# 深色背景圆，提高对比度
	var bg_r := s * 0.7
	draw_circle(Vector2.ZERO, bg_r, Color(0.0, 0.0, 0.0, 0.6))
	draw_arc(Vector2.ZERO, bg_r, 0.0, TAU, 24, Color(0.3, 0.3, 0.3, 0.9), 1.5)

	match marker_type:
		MarkerType.CROWN:
			_draw_crown(s, color)
		MarkerType.SHIELD:
			_draw_shield(s, color)
		MarkerType.SKULL:
			_draw_skull(s, color)
		MarkerType.CROSSHAIR:
			_draw_crosshair(s, color)
		MarkerType.STAR:
			_draw_star(s, color)
		MarkerType.FLAG:
			_draw_flag_marker(s, color)
		MarkerType.DIAMOND:
			_draw_diamond_marker(s, color)


# ============================================================
# 图标绘制
# ============================================================

func _draw_crown(s: float, color: Color) -> void:
	# 根据 level 决定尖数和装饰
	var tips: int = 3
	match marker_level:
		MarkerLevel.IMPORTANT:
			tips = 5
		MarkerLevel.CRITICAL:
			tips = 5

	var half_w := s * 0.6
	var h := s * 0.5
	var base_y := h * 0.3  # 底边
	var tip_y := -h * 0.7  # 尖端

	# 底座
	var base_left := Vector2(-half_w, base_y)
	var base_right := Vector2(half_w, base_y)
	draw_line(base_left, base_right, color, 2.0)

	# 侧边
	draw_line(base_left, Vector2(-half_w, base_y + h * 0.3), color, 1.5)
	draw_line(base_right, Vector2(half_w, base_y + h * 0.3), color, 1.5)

	# 尖角
	var pts := PackedVector2Array()
	for i in range(tips):
		var t := float(i) / maxf(tips - 1, 1.0)
		var x := -half_w + t * half_w * 2.0
		var tip_h := tip_y if i % 2 == 0 else base_y - h * 0.15
		# 底部点
		if i > 0:
			var prev_x := -half_w + (float(i) - 0.5) / maxf(tips - 1, 1.0) * half_w * 2.0
			draw_line(Vector2(prev_x, base_y), Vector2(x, tip_h), color, 2.0)
		else:
			draw_line(base_left, Vector2(x, tip_h), color, 2.0)
		# 连接到下一个底边中点
		if i < tips - 1:
			var next_x := -half_w + (float(i) + 0.5) / maxf(tips - 1, 1.0) * half_w * 2.0
			draw_line(Vector2(x, tip_h), Vector2(next_x, base_y), color, 2.0)
		else:
			draw_line(Vector2(x, tip_h), base_right, color, 2.0)

	# 顶部圆球装饰
	for i in range(tips):
		if i % 2 == 0:
			var t := float(i) / maxf(tips - 1, 1.0)
			var x := -half_w + t * half_w * 2.0
			draw_circle(Vector2(x, tip_y - 1.5), 1.8, color)

	# CRITICAL: 十字顶饰
	if marker_level == MarkerLevel.CRITICAL:
		var cross_y := tip_y - 4.0
		draw_line(Vector2(-2.0, cross_y), Vector2(2.0, cross_y), color, 1.5)
		draw_line(Vector2(0.0, cross_y - 2.0), Vector2(0.0, cross_y + 2.0), color, 1.5)


func _draw_shield(s: float, color: Color) -> void:
	var half := s * 0.5

	# 盾牌轮廓：上半圆 + 下尖
	var pts := PackedVector2Array()
	var segments := 12
	# 上半圆弧
	for i in range(segments + 1):
		var angle := PI + float(i) / segments * PI  # 从左到右
		pts.append(Vector2(cos(angle) * half, sin(angle) * half * 0.6 - half * 0.1))
	# 下部收尖
	var bottom := Vector2(0.0, half * 1.2)

	# 用多段线绘制轮廓
	for i in range(pts.size() - 1):
		draw_line(pts[i], pts[i + 1], color, 2.0)
	draw_line(pts[pts.size() - 1], bottom, color, 2.0)
	draw_line(bottom, pts[0], color, 2.0)

	# 填充半透明
	var fill_pts := PackedVector2Array()
	for p in pts:
		fill_pts.append(p)
	fill_pts.append(bottom)
	if fill_pts.size() >= 3:
		draw_colored_polygon(fill_pts, Color(color.r, color.g, color.b, 0.25))

	# IMPORTANT: 十字纹
	if marker_level == MarkerLevel.IMPORTANT:
		draw_line(Vector2(0.0, -half * 0.5), Vector2(0.0, half * 0.6), color, 1.5)
		draw_line(Vector2(-half * 0.4, 0.0), Vector2(half * 0.4, 0.0), color, 1.5)

	# CRITICAL: 大盾+闪电纹
	if marker_level == MarkerLevel.CRITICAL:
		# 额外盾边
		var outer_half := half + 2.0
		var outer_pts := PackedVector2Array()
		for i in range(segments + 1):
			var angle := PI + float(i) / segments * PI
			outer_pts.append(Vector2(cos(angle) * outer_half, sin(angle) * outer_half * 0.6 - outer_half * 0.1))
		var outer_bottom := Vector2(0.0, outer_half * 1.2)
		for i in range(outer_pts.size() - 1):
			draw_line(outer_pts[i], outer_pts[i + 1], color, 1.0)
		draw_line(outer_pts[outer_pts.size() - 1], outer_bottom, color, 1.0)
		draw_line(outer_bottom, outer_pts[0], color, 1.0)
		# 闪电
		var lx := -half * 0.15
		var ly := -half * 0.4
		var bolt := PackedVector2Array([
			Vector2(lx - 2, ly),
			Vector2(lx + 1, ly + half * 0.25),
			Vector2(lx - 1, ly + half * 0.25),
			Vector2(lx + 2, ly + half * 0.55),
		])
		for i in range(bolt.size() - 1):
			draw_line(bolt[i], bolt[i + 1], color, 1.5)


func _draw_skull(s: float, color: Color) -> void:
	var r := s * 0.35

	# 头颅（圆）
	draw_circle(Vector2.ZERO, r, color)
	draw_circle(Vector2.ZERO, r, Color(color.r, color.g, color.b, 0.3))

	# 眼窝（黑色圆）
	var eye_r := r * 0.25
	draw_circle(Vector2(-r * 0.3, -r * 0.15), eye_r, Color(0.0, 0.0, 0.0))
	draw_circle(Vector2(r * 0.3, -r * 0.15), eye_r, Color(0.0, 0.0, 0.0))

	# 鼻子（小三角）
	var nose_pts := PackedVector2Array([
		Vector2(-r * 0.1, r * 0.05),
		Vector2(r * 0.1, r * 0.05),
		Vector2(0.0, r * 0.25),
	])
	draw_colored_polygon(nose_pts, Color(0.0, 0.0, 0.0))

	# 下颌
	var jaw_y := r * 0.7
	draw_line(Vector2(-r * 0.4, r * 0.35), Vector2(-r * 0.4, jaw_y), color, 1.5)
	draw_line(Vector2(r * 0.4, r * 0.35), Vector2(r * 0.4, jaw_y), color, 1.5)
	draw_line(Vector2(-r * 0.4, jaw_y), Vector2(r * 0.4, jaw_y), color, 1.5)
	# 牙齿线条
	for i in range(3):
		var tx := -r * 0.2 + float(i) * r * 0.2
		draw_line(Vector2(tx, r * 0.35), Vector2(tx, jaw_y), color, 1.0)

	# IMPORTANT: 交叉骨
	if marker_level >= MarkerLevel.IMPORTANT:
		var bone_y := jaw_y + r * 0.4
		var bone_w := r * 0.8
		var bone_h := r * 0.5
		draw_line(Vector2(-bone_w, bone_y), Vector2(bone_w, bone_y + bone_h), color, 2.0)
		draw_line(Vector2(bone_w, bone_y), Vector2(-bone_w, bone_y + bone_h), color, 2.0)
		# 骨头端点圆
		for end in [Vector2(-bone_w, bone_y), Vector2(bone_w, bone_y),
					Vector2(-bone_w, bone_y + bone_h), Vector2(bone_w, bone_y + bone_h)]:
			draw_circle(end, 1.5, color)

	# CRITICAL: 火焰光环
	if marker_level == MarkerLevel.CRITICAL:
		var flame_r := r * 1.6
		for i in range(8):
			var angle := float(i) / 8.0 * TAU + _time * 3.0
			var fx := cos(angle) * flame_r
			var fy := sin(angle) * flame_r * 0.8 - r * 0.3
			var fsize := 2.0 + sin(_time * 5.0 + float(i) * 1.5) * 1.0
			draw_circle(Vector2(fx, fy), fsize, Color(1.0, 0.4, 0.0, 0.6))


func _draw_crosshair(s: float, color: Color) -> void:
	var r := s * 0.45

	# 外圆
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 16, color, 1.5)
	# 内圆
	draw_arc(Vector2.ZERO, r * 0.5, 0.0, TAU, 12, color, 1.0)

	# 十字线
	draw_line(Vector2(0.0, -r * 1.2), Vector2(0.0, -r * 0.3), color, 1.5)
	draw_line(Vector2(0.0, r * 0.3), Vector2(0.0, r * 1.2), color, 1.5)
	draw_line(Vector2(-r * 1.2, 0.0), Vector2(-r * 0.3, 0.0), color, 1.5)
	draw_line(Vector2(r * 0.3, 0.0), Vector2(r * 1.2, 0.0), color, 1.5)

	# 中心点
	draw_circle(Vector2.ZERO, 1.5, color)


func _draw_star(s: float, color: Color) -> void:
	var outer_r := s * 0.5
	var inner_r := outer_r * 0.4
	var pts := PackedVector2Array()

	for i in range(5):
		var outer_angle := -PI / 2.0 + float(i) / 5.0 * TAU
		var inner_angle := outer_angle + PI / 5.0
		pts.append(Vector2(cos(outer_angle) * outer_r, sin(outer_angle) * outer_r))
		pts.append(Vector2(cos(inner_angle) * inner_r, sin(inner_angle) * inner_r))

	draw_colored_polygon(pts, color)


func _draw_flag_marker(s: float, color: Color) -> void:
	var pole_h := s * 0.8
	var flag_w := s * 0.5
	var flag_h := s * 0.35

	# 旗杆
	var pole_top := Vector2(0.0, -pole_h)
	draw_line(Vector2.ZERO, pole_top, color, 2.0)

	# 三角旗帜
	var flag_pts := PackedVector2Array([
		pole_top,
		pole_top + Vector2(flag_w, flag_h * 0.5),
		pole_top + Vector2(0.0, flag_h),
	])
	draw_colored_polygon(flag_pts, color)

	# 旗帜飘动效果（第二条线）
	var wave_offset := sin(_time * 3.0) * 1.5
	draw_line(pole_top + Vector2(flag_w * 0.3, flag_h * 0.2),
		pole_top + Vector2(flag_w * 0.3 + wave_offset, flag_h * 0.4),
		color, 1.0)


func _draw_diamond_marker(s: float, color: Color) -> void:
	var half := s * 0.5
	var pts := PackedVector2Array([
		Vector2(0.0, -half),
		Vector2(half, 0.0),
		Vector2(0.0, half),
		Vector2(-half, 0.0),
	])
	draw_colored_polygon(pts, color)
	# 内部高光
	draw_colored_polygon(PackedVector2Array([
		Vector2(0.0, -half * 0.5),
		Vector2(half * 0.5, 0.0),
		Vector2(0.0, half * 0.5),
		Vector2(-half * 0.5, 0.0),
	]), Color(1.0, 1.0, 1.0, 0.3))


# ============================================================
# 颜色
# ============================================================

func _get_color() -> Color:
	if _danger:
		return _color_shield_danger

	match marker_type:
		MarkerType.CROWN:
			return _color_crown
		MarkerType.SHIELD:
			return _color_shield
		MarkerType.SKULL:
			return _color_skull
		MarkerType.CROSSHAIR:
			return _color_crosshair
		MarkerType.STAR:
			return _color_star
		MarkerType.FLAG:
			return _color_flag
		MarkerType.DIAMOND:
			return _color_diamond
		_:
			return _color_crown


# ============================================================
# 外部接口
# ============================================================

## 目标完成/标记失效 → 淡出移除
func dismiss() -> void:
	_dying = true


## 设置标记要追踪的目标节点（应在 add_child 之前调用）
func setup(target: Node) -> void:
	_target = target


## 保护目标濒危 → 切换红色闪烁
func set_danger(enabled: bool) -> void:
	_danger = enabled


## 判断此标记是否属于指定节点
func belongs_to(node: Node) -> bool:
	return _target == node


## 获取标记跟踪的目标节点
func get_target() -> Node:
	return _target
