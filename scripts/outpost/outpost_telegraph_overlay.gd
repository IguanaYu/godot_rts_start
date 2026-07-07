extends Node2D
## 据点指挥官事件反馈（Telegraph 类，瞬时 2-3s）
## 由 OutpostCommander._spawn_vfx_for_spell / _spawn_vfx_for_strategy 实例化
##
## 视觉分四层（从外到内）：
## 1. 领地圈高亮（2-3 同心圈，按 tier 决定）
## 2. 圈内淡色填充
## 3. 中心 icon（按 effect_id 派生：箭头/波纹/十字/六边形/三角等）
## 4. 中心 banner（深色背景框 + 大字 + 彩色边框，居中显示事件名）
## 可选：attack/coordinate 画虚线 + 箭头指向 target_pos

var center: Vector2 = Vector2.ZERO
var radius: float = 200.0
var effect_id: StringName = &""
var target_pos: Vector2 = Vector2.ZERO
var tier: String = "mid"  # "high" / "mid" / "low"

var _elapsed: float = 0.0
var _duration: float = 2.5
var _color: Color = Color.WHITE
var _label_text: String = ""
var _icon_kind: String = ""
var _banner: Label
var _banner_at_caster: bool = false  # shield 等：banner 显示在 target_pos（caster/building 位置，非指挥官上方）

const TIER_DURATION := {"high": 3.5, "mid": 3.0, "low": 2.5}
const TIER_RING_COUNT := {"high": 3, "mid": 2, "low": 2}

const EFFECT_INFO := {
	&"attack":           {color = Color(1.00, 0.20, 0.20), label = "出击！",   icon = "arrows"},
	&"coordinate":       {color = Color(1.00, 0.55, 0.16), label = "集结！",   icon = "rings"},
	&"defend":           {color = Color(0.30, 0.55, 1.00), label = "巩固防御", icon = "flash"},
	&"expand":           {color = Color(0.30, 1.00, 0.55), label = "扩张！",   icon = "ripple"},
	&"shield":           {color = Color(0.00, 0.85, 0.95), label = "护盾",    icon = "hexagon", banner_at_caster = true},
	&"heal":             {color = Color(0.15, 0.95, 0.35), label = "治疗",    icon = "cross"},
	&"inspire":          {color = Color(1.00, 0.82, 0.29), label = "鼓舞",    icon = "ripple"},
	&"call_to_arms":     {color = Color(1.00, 0.40, 0.30), label = "紧急动员！", icon = "flag"},
	&"release_garrison": {color = Color(0.85, 0.60, 0.40), label = "释放驻军", icon = "dust"},
}

const BANNER_W := 280.0
const BANNER_H := 60.0


func _ready() -> void:
	global_position = center
	z_index = 50
	_duration = TIER_DURATION.get(tier, 2.5)
	var info: Dictionary = EFFECT_INFO.get(effect_id, {})
	_color = info.get("color", Color.WHITE)
	_label_text = info.get("label", String(effect_id))
	_icon_kind = info.get("icon", "")
	_banner_at_caster = info.get("banner_at_caster", false)

	_banner = Label.new()
	_banner.text = _label_text
	_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_banner.add_theme_font_size_override("font_size", 30)
	_banner.add_theme_color_override("font_color", Color.WHITE)
	_banner.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	_banner.add_theme_color_override("font_outline_color", _color)
	_banner.add_theme_constant_override("shadow_offset_x", 2)
	_banner.add_theme_constant_override("shadow_offset_y", 2)
	_banner.add_theme_constant_override("outline_size", 10)
	_banner.size = Vector2(BANNER_W, BANNER_H)
	_banner.pivot_offset = Vector2(BANNER_W / 2.0, BANNER_H / 2.0)
	add_child(_banner)

	modulate.a = 1.0


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= _duration:
		queue_free()
		return
	# 整体淡出（前 50% 维持满 alpha，后 50% 线性降到 0）
	var progress: float = _elapsed / _duration
	modulate.a = 1.0 if progress < 0.5 else (1.0 - (progress - 0.5) / 0.5)
	queue_redraw()


func _draw() -> void:
	var progress: float = _elapsed / _duration
	var alpha: float = modulate.a

	# Layer 1: 领地圈（同心）
	var ring_count: int = TIER_RING_COUNT.get(tier, 2)
	for i in range(ring_count):
		var ring_alpha: float = alpha * (1.0 - float(i) / float(ring_count + 1))
		var ring_radius: float = radius * (1.0 + i * 0.04 * progress)
		var width: float = 4.5 if i == 0 else 2.5
		draw_arc(Vector2.ZERO, ring_radius, 0, TAU, 64,
			Color(_color.r, _color.g, _color.b, ring_alpha), width)

	# Layer 2: 圈内淡色填充（更明显）
	draw_circle(Vector2.ZERO, radius,
		Color(_color.r, _color.g, _color.b, 0.10 * alpha))

	# Layer 3: 中心 banner 背景框（深色 + 彩色描边）
	_draw_banner_background(alpha)

	# Layer 4: 中心 icon（按 _icon_kind 派生）
	_draw_center_icon(alpha)

	# Layer 5: 目标指示线（attack/coordinate）
	if effect_id == &"attack" or effect_id == &"coordinate":
		_draw_target_line(alpha)

	# Layer 6: 指挥官中心 marker（小圆点，标识"这是源头"）— 放在 banner 下方
	draw_circle(Vector2.ZERO, 14.0, Color(0, 0, 0, alpha * 0.7))
	draw_circle(Vector2.ZERO, 11.0, Color(_color.r, _color.g, _color.b, alpha))


# ============================================================
# Banner 背景框
# ============================================================
func _draw_banner_background(alpha: float) -> void:
	var w: float = BANNER_W
	var h: float = BANNER_H
	# 默认 banner 在指挥官上方（圆心上方 radius*0.5）
	# shield 等 banner_at_caster 事件：banner 显示在 target_pos（caster/building 局部坐标 = target_pos - global_position）
	var banner_center_local: Vector2 = Vector2(0, -radius * 0.5)
	if _banner_at_caster and target_pos != Vector2.ZERO:
		banner_center_local = target_pos - global_position
	var rect := Rect2(banner_center_local.x - w / 2.0, banner_center_local.y - h / 2.0, w, h)
	# 阴影
	var shadow_rect := rect.grow_individual(2, 4, 2, 4)
	draw_rect(shadow_rect, Color(0, 0, 0, alpha * 0.5))
	# 深色背景
	draw_rect(rect, Color(0.05, 0.05, 0.10, alpha * 0.92))
	# 彩色粗边框
	draw_rect(rect, Color(_color.r, _color.g, _color.b, alpha), false, 4.0)
	# 上下彩色横条（强调）
	var stripe_h := 6.0
	draw_rect(Rect2(rect.position.x, rect.position.y, rect.size.x, stripe_h),
		Color(_color.r, _color.g, _color.b, alpha))
	draw_rect(Rect2(rect.position.x, rect.position.y + rect.size.y - stripe_h, rect.size.x, stripe_h),
		Color(_color.r, _color.g, _color.b, alpha))
	# 同步移动 Label 子节点到 banner 位置（Label pivot 已设为中心，position 即为左上角）
	if _banner != null:
		_banner.position = rect.position


# ============================================================
# 中心 icon（按 _icon_kind 派生）
# ============================================================
func _draw_center_icon(alpha: float) -> void:
	var icon_color := Color(_color.r, _color.g, _color.b, alpha)
	match _icon_kind:
		"arrows":
			# 4 个旋转箭头向外辐射
			for i in range(4):
				var angle := i * TAU / 4.0 + _elapsed * 1.5
				var dir := Vector2(cos(angle), sin(angle))
				var start := dir * 30.0
				var end := dir * 70.0
				draw_line(start, end, icon_color, 5.0)
				# 箭头头
				var perp := Vector2(-dir.y, dir.x)
				var head_pts := PackedVector2Array([
					end + dir * 8.0,
					end - dir * 6.0 + perp * 8.0,
					end - dir * 6.0 - perp * 8.0,
				])
				draw_colored_polygon(head_pts, icon_color)
		"rings":
			# 同心环向外扩散（脉冲）
			for i in range(4):
				var phase: float = fmod(_elapsed * 1.0 + i * 0.25, 1.0)
				var r: float = 25.0 + phase * 45.0
				var a: float = alpha * (1.0 - phase)
				draw_arc(Vector2.ZERO, r, 0, TAU, 32,
					Color(_color.r, _color.g, _color.b, a), 3.0)
		"flash":
			# 中心强闪（快速放大淡出）— 多次脉冲
			for i in range(2):
				var offset: float = i * 0.4
				var phase: float = fmod(_elapsed + offset, 1.2) / 1.2
				var r: float = 25.0 + phase * 50.0
				var a: float = alpha * (1.0 - phase) * 0.7
				draw_circle(Vector2.ZERO, r,
					Color(_color.r, _color.g, _color.b, a))
		"ripple":
			# 多层波纹向外扩散
			for i in range(4):
				var r: float = fmod(_elapsed * 80.0 + i * 25.0, 100.0)
				var a: float = alpha * (1.0 - r / 100.0)
				draw_arc(Vector2.ZERO, r, 0, TAU, 32,
					Color(_color.r, _color.g, _color.b, a), 3.0)
		"hexagon":
			# 围绕目标建筑的六边形（telegraph 短闪，持续交给 status_marker）
			if target_pos != Vector2.ZERO:
				_draw_hexagon(target_pos - global_position, 50.0, alpha, icon_color)
		"cross":
			# 加号（治疗）— 大且粗
			var s := 35.0
			var t := 12.0
			# 横条
			draw_rect(Rect2(-s, -t / 2.0, s * 2.0, t), icon_color)
			# 竖条
			draw_rect(Rect2(-t / 2.0, -s, t, s * 2.0), icon_color)
		"flag":
			# 三角警示 + 旗杆
			var s := 38.0
			var pts := PackedVector2Array([
				Vector2(0, -s),
				Vector2(-s * 0.866, s * 0.5),
				Vector2(s * 0.866, s * 0.5),
			])
			draw_colored_polygon(pts, icon_color)
			# 中间感叹号（黑色）
			draw_line(Vector2(0, -s * 0.4), Vector2(0, s * 0.15), Color(0, 0, 0, alpha), 4.0)
			draw_circle(Vector2(0, s * 0.35), 3.5, Color(0, 0, 0, alpha))
		"dust":
			# 尘云（多圆随机偏移 + 扩散）
			for i in range(6):
				var angle := i * TAU / 6.0 + _elapsed * 0.8
				var offset := Vector2(cos(angle), sin(angle)) * (20.0 + _elapsed * 15.0)
				var r := 16.0 + sin(_elapsed * 5.0 + i) * 5.0
				draw_circle(offset, r,
					Color(_color.r, _color.g, _color.b, alpha * 0.55))


func _draw_hexagon(local_pos: Vector2, size: float, alpha: float, color: Color) -> void:
	var pts := PackedVector2Array()
	for i in range(6):
		var angle := i * TAU / 6.0
		pts.append(local_pos + Vector2(cos(angle), sin(angle)) * size)
	draw_colored_polygon(pts, Color(color.r, color.g, color.b, alpha * 0.20))
	for i in range(6):
		var a := pts[i]
		var b := pts[(i + 1) % 6]
		draw_line(a, b, color, 3.5)


func _draw_target_line(alpha: float) -> void:
	var local_target := target_pos - global_position
	if local_target.length() < radius + 20.0:
		return
	var dir := local_target.normalized()
	var start := dir * (radius + 8.0)
	var end := local_target - dir * 36.0
	# 虚线
	var dash_len := 16.0
	var gap_len := 10.0
	var total_len := start.distance_to(end)
	var pos: float = 0.0
	while pos < total_len:
		var a := start + dir * pos
		var b := start + dir * minf(pos + dash_len, total_len)
		draw_line(a, b, Color(_color.r, _color.g, _color.b, alpha), 3.5)
		pos += dash_len + gap_len
	# 箭头
	var arrow_size := 18.0
	var perp := Vector2(-dir.y, dir.x)
	var arrow_tip := end + dir * 10.0
	var arrow_pts := PackedVector2Array([
		arrow_tip,
		end - dir * arrow_size + perp * arrow_size * 0.5,
		end - dir * arrow_size - perp * arrow_size * 0.5,
	])
	draw_colored_polygon(arrow_pts, Color(_color.r, _color.g, _color.b, alpha))


func progress() -> float:
	return _elapsed / _duration if _duration > 0.0 else 0.0
