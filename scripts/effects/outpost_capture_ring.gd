extends Node2D
## PR-4：据点占领光圈（绿色 Line2D 圆环）
## 由 main.gd 在 _on_outpost_captured 时实例化，挂在据点中心位置
## 复用 building_placer 的 BUILD_RADIUS overlay 视觉风格

var radius: float = 200.0
var ring_color: Color = Color(0.0, 1.0, 0.0, 0.7)
var _t: float = 0.0

func _ready() -> void:
	z_index = 5
	set_process(true)

func setup(r: float) -> void:
	radius = r
	queue_redraw()

func _process(delta: float) -> void:
	_t += delta
	queue_redraw()

func _draw() -> void:
	# 呼吸脉冲（轻微 alpha 变化）
	var alpha: float = 0.5 + sin(_t * 1.5) * 0.2
	var c := Color(ring_color.r, ring_color.g, ring_color.b, alpha)
	# 实线圆环（64 段近似圆）
	var points := 64
	var prev := Vector2.ZERO
	for i in range(points + 1):
		var angle: float = i * TAU / points
		var next := Vector2(cos(angle), sin(angle)) * radius
		if i > 0:
			draw_line(prev, next, c, 2.5)
		prev = next
	# 中心半透明填充（极淡）
	draw_circle(Vector2.ZERO, radius * 0.95, Color(ring_color.r, ring_color.g, ring_color.b, 0.05))
