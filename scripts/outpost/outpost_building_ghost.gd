extends Node2D
## 建筑建造 telegraph（defend/expand 策略用）
##
## 在建筑实际生成前先显示 2s 的 ghost：
## - 半透明建筑轮廓（虚线边框）
## - 中心进度条
## - 不可选中、不可攻击
## duration 到期后由外部 callback 实际放置建筑，ghost 自 queue_free

var world_pos: Vector2 = Vector2.ZERO
var grid_size_px: Vector2 = Vector2(64.0, 64.0)  # 建筑占地像素
var duration: float = 2.0
var color: Color = Color(0.30, 0.55, 1.00)  # 默认 defend 蓝
var _elapsed: float = 0.0


func _ready() -> void:
	global_position = world_pos
	z_index = 35
	modulate.a = 1.0


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= duration:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var progress: float = _elapsed / duration
	var alpha: float = 1.0 if progress < 0.85 else (1.0 - (progress - 0.85) / 0.15 * 0.4)
	var w: float = grid_size_px.x
	var h: float = grid_size_px.y
	var rect := Rect2(-w / 2.0, -h / 2.0, w, h)
	# 半透明填充
	draw_rect(rect, Color(color.r, color.g, color.b, 0.18 * alpha))
	# 虚线边框（4 段，随时间偏移制造"行进"动画）
	var dash_len: float = 10.0
	var gap_len: float = 6.0
	_draw_dashed_rect(rect, color, alpha, dash_len, gap_len, _elapsed * 30.0)
	# 中心进度条（横向）
	var bar_w: float = w * 0.7
	var bar_h: float = 4.0
	var bar_rect := Rect2(-bar_w / 2.0, h / 2.0 + 4.0, bar_w, bar_h)
	draw_rect(bar_rect, Color(0.10, 0.10, 0.15, 0.95 * alpha))
	draw_rect(Rect2(bar_rect.position, Vector2(bar_w * progress, bar_h)),
		Color(color.r, color.g, color.b, alpha))
	# 中心十字（建造标识）
	draw_line(Vector2(-6, 0), Vector2(6, 0), Color(color.r, color.g, color.b, alpha), 2.0)
	draw_line(Vector2(0, -6), Vector2(0, 6), Color(color.r, color.g, color.b, alpha), 2.0)


func _draw_dashed_rect(rect: Rect2, col: Color, alpha: float, dash_len: float, gap_len: float, offset: float) -> void:
	var col_a := Color(col.r, col.g, col.b, alpha)
	var perimeter: float = (rect.size.x + rect.size.y) * 2.0
	var total: float = 0.0
	# 简化：分别画 4 条边的虚线段
	_draw_dashed_line(rect.position, rect.position + Vector2(rect.size.x, 0), col_a, dash_len, gap_len, offset)
	_draw_dashed_line(rect.position + Vector2(rect.size.x, 0), rect.position + rect.size, col_a, dash_len, gap_len, offset)
	_draw_dashed_line(rect.position + rect.size, rect.position + Vector2(0, rect.size.y), col_a, dash_len, gap_len, offset)
	_draw_dashed_line(rect.position + Vector2(0, rect.size.y), rect.position, col_a, dash_len, gap_len, offset)


func _draw_dashed_line(a: Vector2, b: Vector2, col: Color, dash_len: float, gap_len: float, offset: float) -> void:
	var diff: Vector2 = b - a
	var total_len: float = diff.length()
	if total_len <= 0.001:
		return
	var dir: Vector2 = diff.normalized()
	var pos: float = -fmod(offset, dash_len + gap_len)
	while pos < total_len:
		var start: Vector2 = a + dir * maxf(pos, 0.0)
		var end_pos: float = minf(pos + dash_len, total_len)
		var end: Vector2 = a + dir * end_pos
		draw_line(start, end, col, 2.0)
		pos += dash_len + gap_len


func progress_ratio() -> float:
	return _elapsed / duration if duration > 0.0 else 0.0
