class_name SkillVisualController
extends Node2D
## SkillVisualController（PR-6）：指挥官技能视觉统一入口
## 全 _draw 程序化实现：释放波纹环 / 光柱（含十字）/ 蓄力进度环
## 挂载：main.gd 与沙盒 sandbox_controller.gd 各挂一份，static instance 供技能脚本直接调用
## 所有静态入口在 instance 为空时静默跳过（场景未挂载/切换中安全）

const COLOR_TAUNT := Color(1.0, 0.25, 0.2)
const COLOR_BLINK := Color(0.6, 0.25, 0.9)
const COLOR_STEALTH := Color(0.6, 0.25, 0.9)
const COLOR_CONVERT := Color(1.0, 0.84, 0.25)
const COLOR_SHIELD := Color(0.5, 0.8, 1.0)
const COLOR_SUMMON := Color(0.6, 0.25, 0.9)
const COLOR_HEAL := Color(1.0, 0.84, 0.25)
const COLOR_DISPEL := Color(1.0, 1.0, 1.0)

const RIPPLE_DUR := 0.35
const RIPPLE_WIDTH := 3.0
const PILLAR_W := 12.0
const CHARGE_RING_R := 26.0

# 活动实例：{pos, color, max_r, t}
var _ripples: Array = []
# 活动光柱：{pos, color, dur, shape, t}
var _pillars: Array = []
# 活动蓄力环：{pos, color, progress}
var _charges: Dictionary = {}


static var instance: SkillVisualController = null


func _ready() -> void:
	z_index = 40  # beam_effect=30 之上，HPBar=100 之下
	instance = self


func _exit_tree() -> void:
	if instance == self:
		instance = null


func _process(delta: float) -> void:
	if _ripples.is_empty() and _pillars.is_empty() and _charges.is_empty():
		return
	var i := _ripples.size() - 1
	while i >= 0:
		_ripples[i].t += delta
		if _ripples[i].t >= RIPPLE_DUR:
			_ripples.remove_at(i)
		i -= 1
	i = _pillars.size() - 1
	while i >= 0:
		_pillars[i].t += delta
		if _pillars[i].t >= _pillars[i].dur:
			_pillars.remove_at(i)
		i -= 1
	queue_redraw()


# ============== 静态 API（技能脚本调用） ==============

## 释放波纹环：地面扩散 0.35s 消失
static func play_release_ripple(world_pos: Vector2, color: Color, max_radius: float = 80.0) -> void:
	if instance == null:
		return
	instance._ripples.append({"pos": world_pos, "color": color, "max_r": max_radius, "t": 0.0})


## 光柱：shape = "pillar"（竖直光柱）/ "cross"（头顶十字光环）
static func play_light_pillar(world_pos: Vector2, color: Color, duration: float = 0.6, shape: String = "pillar") -> void:
	if instance == null:
		return
	instance._pillars.append({"pos": world_pos, "color": color, "dur": duration, "shape": shape, "t": 0.0})


## 蓄力进度环：返回句柄字典，调用方每帧改 handle.progress（0-1），调 finish() 结束
static func play_charging_circle(world_pos: Vector2, color: Color) -> Dictionary:
	if instance == null:
		return {}
	var handle := {"pos": world_pos, "color": color, "progress": 0.0}
	instance._charges[handle] = true
	return handle


## 蓄力环句柄结束（无视觉收尾，直接移除）
static func finish_charging_circle(handle: Dictionary) -> void:
	if instance == null or handle.is_empty():
		return
	instance._charges.erase(handle)


## 屏幕冲击：转发 PR-5 PostProcessController
static func play_screen_impact(world_pos: Vector2, strength: float = 5.0) -> void:
	PostProcessController.shake_screen(strength, 0.25)


# ============== 绘制 ==============

func _draw() -> void:
	for r in _ripples:
		var q: float = r.t / RIPPLE_DUR
		var radius: float = 10.0 + (r.max_r - 10.0) * q
		var c: Color = r.color
		draw_arc(to_local(r.pos), radius, 0.0, TAU, 48,
			Color(c.r, c.g, c.b, 0.8 * (1.0 - q)), RIPPLE_WIDTH * (1.0 - q * 0.5))
		# 内侧跟随薄环增强扩散感
		draw_arc(to_local(r.pos), radius * 0.8, 0.0, TAU, 40,
			Color(c.r, c.g, c.b, 0.35 * (1.0 - q)), RIPPLE_WIDTH * 0.5)

	for p in _pillars:
		var c: Color = p.color
		var alpha: float = 1.0
		if p.t > p.dur * 0.6:
			alpha = (p.dur - p.t) / (p.dur * 0.4)
		var center: Vector2 = to_local(p.pos)
		if p.shape == "cross":
			# 十字光环：两根交叉光条 + 外圈
			var w := PILLAR_W * 0.6 * alpha
			draw_line(center + Vector2(-16, -16), center + Vector2(16, 16),
				Color(c.r, c.g, c.b, 0.7 * alpha), w)
			draw_line(center + Vector2(16, -16), center + Vector2(-16, 16),
				Color(c.r, c.g, c.b, 0.7 * alpha), w)
			draw_arc(center, 22.0, 0.0, TAU, 32, Color(c.r, c.g, c.b, 0.5 * alpha), 2.0)
		else:
			# 竖直光柱：底粗顶细两段 + 根部辉光
			var h := 60.0
			draw_line(center + Vector2(0, -2), center + Vector2(0, -h),
				Color(c.r, c.g, c.b, 0.55 * alpha), PILLAR_W)
			draw_line(center + Vector2(0, -2), center + Vector2(0, -h),
				Color(1, 1, 1, 0.35 * alpha), PILLAR_W * 0.4)
			draw_circle(center, PILLAR_W * 0.8, Color(c.r, c.g, c.b, 0.45 * alpha))

	for handle in _charges:
		var c: Color = handle.color
		var center: Vector2 = to_local(handle.pos)
		# 底环（暗）
		draw_arc(center, CHARGE_RING_R, 0.0, TAU, 40,
			Color(c.r, c.g, c.b, 0.2), 3.0)
		# 进度弧（亮），从 -90°（顶部）顺时针
		var progress: float = clampf(handle.progress, 0.0, 1.0)
		if progress > 0.0:
			draw_arc(center, CHARGE_RING_R, -PI / 2.0, -PI / 2.0 + TAU * progress, 40,
				Color(c.r, c.g, c.b, 0.85), 3.5)
