extends Node2D
## 大战术释放者引导视觉反馈
## 跟随 target_unit，画三层：
## - 紫色脉动光环（外圈，半径随 sin 波动）
## - 进度环（中间圈，按 channel_progress 0→1 填充扇形）
## - 剩余秒数（头顶 Label）

var target_unit: Node = null
var progress: float = 0.0  # 0 → 1
var remaining_sec: float = 0.0
var channel_time: float = 30.0
var tactic_name: String = ""

const RING_RADIUS := 60.0
const AURA_AMPLITUDE := 8.0
const TACTIC_COLORS := {
	"持续召唤": Color(0.65, 0.35, 1.00),
	"召唤精英": Color(1.00, 0.40, 0.40),
	"鼓舞士气": Color(1.00, 0.82, 0.29),
	"结束时召唤": Color(0.20, 0.90, 1.00),
}

var _t: float = 0.0
var _color: Color = Color(0.65, 0.35, 1.00)
var _label: Label = null


func _ready() -> void:
	z_index = 50
	_color = TACTIC_COLORS.get(tactic_name, Color(0.65, 0.35, 1.00))
	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override("font_size", 16)
	_label.add_theme_color_override("font_color", Color(1, 1, 1))
	_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	_label.add_theme_constant_override("shadow_offset_x", 1)
	_label.add_theme_constant_override("shadow_offset_y", 1)
	add_child(_label)


func _process(delta: float) -> void:
	_t += delta
	if target_unit == null or not is_instance_valid(target_unit):
		queue_free()
		return
	if target_unit.has_method("is_dead") and target_unit.is_dead():
		queue_free()
		return
	# 作为 target_unit 的子节点，位置自动跟随，无需手动设
	if _label:
		_label.text = "%s\n%.1fs" % [tactic_name, remaining_sec]
		_label.position.x = -60
		_label.position.y = -90
	queue_redraw()


func _draw() -> void:
	# 外圈脉动光环
	var pulse: float = 1.0 + sin(_t * 4.0) * 0.15
	var aura_radius: float = (RING_RADIUS + AURA_AMPLITUDE) * pulse
	draw_arc(Vector2.ZERO, aura_radius, 0, TAU, 48,
		Color(_color.r, _color.g, _color.b, 0.35), 3.0)
	draw_circle(Vector2.ZERO, aura_radius,
		Color(_color.r, _color.g, _color.b, 0.08))
	# 中圈进度环（按 progress 填充扇形）
	var progress_angle: float = progress * TAU
	if progress_angle > 0.01:
		var pts := PackedVector2Array()
		var colors := PackedColorArray()
		pts.append(Vector2.ZERO)
		colors.append(Color(_color.r, _color.g, _color.b, 0.0))
		var segments: int = max(8, int(progress_angle / (TAU / 64.0)))
		for i in range(segments + 1):
			var a: float = -PI / 2.0 + progress_angle * float(i) / float(segments)
			pts.append(Vector2(cos(a), sin(a)) * RING_RADIUS)
			colors.append(Color(_color.r, _color.g, _color.b, 0.55))
		draw_polygon(pts, colors)
	# 进度环描边
	draw_arc(Vector2.ZERO, RING_RADIUS, 0, TAU, 64,
		Color(_color.r, _color.g, _color.b, 0.7), 2.0)
	# 内圈：填充随 progress 加深的颜色
	var inner_alpha: float = 0.10 + progress * 0.25
	draw_circle(Vector2.ZERO, RING_RADIUS * 0.85,
		Color(_color.r, _color.g, _color.b, inner_alpha))
