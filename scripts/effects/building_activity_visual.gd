class_name BuildingActivityVisual
extends Node2D
## BuildingActivityVisual（PR-4）：建筑活动视觉组件
## 持续状态（生产脉冲/施工尘土/升级转动环）+ 短事件（入队回弹/完成脉冲/产金环/受击震动红闪）
## 硬约束：只写 BodySprite.position/scale/modulate，禁止触碰建筑本体 position（碰撞会跟着抖）
## modulate 只 lerp RGB 不动 alpha（避免与施工半透明 0.5 / 指挥官 tint 冲突）

const Z_LAYER := 5  # 与 PR-3 UnitVisualFeedback 同层：高于 BodySprite(0)，低于 HPBar(100)。低于此会被 Ground(z=0) 盖住

enum State { IDLE, PRODUCING, CONSTRUCTING, AGE_UPGRADING }

const HIT_SHAKE_PX := 2.5
const HIT_FLASH_DUR := 0.18
const C_HIT_RED := Color(1.0, 0.25, 0.2)
const C_GOLD := Color(1.0, 0.84, 0.0)
const C_WALL_LINK := Color(1.0, 0.84, 0.0, 0.35)
const DUST_INTERVAL := 0.8          # 施工尘土固定周期
const UPGRADE_RING_SPIN := [1.2, 3.0]  # [慢, 快]，按 progress lerp

const DEFAULT_CONFIG := {
	"pulse_strength": 0.008,
	"pulse_interval": 1.2,
	"dust_interval": 0.0,  # 0 = 该建筑不出施工尘土
	"dust_anchor": Vector2(0, 24),
	"gold_ring": false,        # 是否有产金闪烁环
	"complete_bounce": 0.03,   # 完成/入队回弹幅度（0 = 无回弹）
	"fire_recoil": 0.0,        # 箭塔开火回弹幅度
}

# int 键 = Building.BuildingType 枚举值（不引用 Building 类，避免循环依赖）
const BUILDING_CONFIGS := {
	0: {"pulse_strength": 0.0, "complete_bounce": 0.0},            # WALL：不脉冲不回弹，受击走震动
	1: {"pulse_strength": 0.005, "pulse_interval": 0.0,
		"complete_bounce": 0.0, "fire_recoil": 0.05},              # TOWER：仅开火回弹
	2: {"pulse_strength": 0.005, "pulse_interval": 1.5,
		"gold_ring": true, "complete_bounce": 0.04},               # CASTLE：金环 + 大完成脉冲
	3: {"pulse_strength": 0.015, "pulse_interval": 0.8,
		"dust_interval": 1.1, "dust_anchor": Vector2(0, 24),
		"complete_bounce": 0.03},                                  # BARRACKS：强脉冲 + 门口尘土
	4: {"pulse_strength": 0.007, "pulse_interval": 1.2,
		"gold_ring": true, "complete_bounce": 0.02},               # MONASTERY：白蓝环（环色单独存）
	5: {"pulse_strength": 0.010, "pulse_interval": 1.0,
		"dust_interval": 1.5, "dust_anchor": Vector2(0, 24),
		"complete_bounce": 0.02},                                  # ARCHERY：弱脉冲 + 弱尘土
	6: {"pulse_strength": 0.008, "pulse_interval": 1.5,
		"gold_ring": true, "complete_bounce": 0.02},               # FARM：金闪
	7: {},                                                          # ALTAR_ARCHER：默认
	8: {},                                                          # ACADEMY：默认
}

const RING_COLOR_OVERRIDES := {
	4: Color(0.7, 0.85, 1.0, 0.8),  # MONASTERY 白蓝
}

# --- 缓存 ---
var _body: Sprite2D = null
var _building: Node2D = null
var _cfg: Dictionary = {}
var _phase := 0.0

# --- 快照（configure 时记录）---
var _base_pos := Vector2.ZERO
var _base_scale := Vector2.ONE
var _base_modulate := Color.WHITE

# --- 持续状态 ---
var _state: State = State.IDLE
var _progress := 0.0
var _state_time := 0.0
var _dust_timer := 0.0
# 三通道请求（优先级仲裁用，见 _apply_priority）
var _req_state: State = State.IDLE
var _req_construction := false
var _req_age_upgrade := false
var _req_progress := 0.0

# --- 短事件（同类覆盖不累加，PR-3 同模式）---
var _bounce := {}        # {amp, t, dur} scale 回弹
var _hit := {}           # {dir, t, dur} 震动 + 红闪
var _order_dip := {}     # {t, dur} 入队下沉

# --- 绘制 ---
var _rings: Array[Dictionary] = []   # 瞬态扩散环 {r0, grow, t, dur, color, width}
var _wall_link := false
var _flash := 0.0
var _idle_settled := false  # IDLE 静默优化：恢复快照后停写
var _ring_dirty := false


func _ready() -> void:
	z_index = Z_LAYER
	if Engine.is_editor_hint():
		set_process(false)


func configure(building_type: int, body: Sprite2D, grid: Vector2i, rand_seed: int) -> void:
	_body = body
	_building = get_parent()
	_cfg = DEFAULT_CONFIG.duplicate()
	if BUILDING_CONFIGS.has(building_type):
		for k in BUILDING_CONFIGS[building_type]:
			_cfg[k] = BUILDING_CONFIGS[building_type][k]
	else:
		push_warning("BuildingActivityVisual: unknown building_type %d, using default" % building_type)
	_phase = float(rand_seed % 1000) / 1000.0 * TAU
	if _body != null:
		_base_pos = _body.position
		_base_scale = _body.scale
		_base_modulate = _body.modulate
	# 地面环几何：环心贴 footprint 底边中点，半径按 footprint 收敛
	_foot_y = grid.y * 64.0 * 0.5 - 4.0
	_ring_radius = clampf(minf(grid.x, grid.y) * 32.0 + 8.0, 40.0, 90.0)


var _foot_y := 0.0
var _ring_radius := 40.0


# === 持续状态 ===

func set_production(active: bool, ratio: float = 0.0) -> void:
	_req_state = State.PRODUCING if active else State.IDLE
	_req_progress = clampf(ratio, 0.0, 1.0)
	_apply_priority()


func set_construction(active: bool, ratio: float = 0.0) -> void:
	_req_construction = active
	if active:
		_dust_timer = 0.0
	_req_progress = clampf(ratio, 0.0, 1.0)
	_apply_priority()


func set_age_upgrade(active: bool, ratio: float = 0.0) -> void:
	_req_age_upgrade = active
	_req_progress = clampf(ratio, 0.0, 1.0)
	_apply_priority()


# 优先级：constructing > age_upgrading > producing > idle（设计文档第 6 节）
func _apply_priority() -> void:
	var s: State
	if _req_construction:
		s = State.CONSTRUCTING
	elif _req_age_upgrade:
		s = State.AGE_UPGRADING
	elif _req_state == State.PRODUCING:
		s = State.PRODUCING
	else:
		s = State.IDLE
	var changed := _state != s
	_state = s
	if _req_construction and _state == State.CONSTRUCTING:
		_progress = _req_progress
	elif _req_age_upgrade and _state == State.AGE_UPGRADING:
		_progress = _req_progress
	elif _state == State.PRODUCING:
		_progress = _req_progress
	if changed:
		_state_time = 0.0
		_idle_settled = false


# === 短事件 ===

func play_order_received() -> void:
	if _cfg.complete_bounce <= 0.0:
		return
	_order_dip = {"t": 0.0, "dur": 0.25}


func play_production_completed() -> void:
	if _cfg.complete_bounce <= 0.0:
		return
	_bounce = {"amp": _cfg.complete_bounce, "t": 0.0, "dur": 0.4}


func play_construction_completed() -> void:
	_bounce = {"amp": _cfg.complete_bounce, "t": 0.0, "dur": 0.45}
	_dust_timer = 99.0  # 强制立刻吐一口落成尘土
	_push_ring(_ring_radius, 22.0, 0.5, _gold_ring_color(), 3.0)


func play_resource_tick() -> void:
	if _cfg.gold_ring:
		_push_ring(_ring_radius * 0.7, 14.0, 0.5, _gold_ring_color(), 2.5)


func play_age_upgrade_completed() -> void:
	_bounce = {"amp": 0.05, "t": 0.0, "dur": 0.5}
	_push_ring(_ring_radius, 40.0, 0.6, _gold_ring_color(), 3.0)
	# 第二环延迟 0.12s（负 t 实现延迟）
	_push_ring(_ring_radius * 0.8, 38.0, 0.7, _gold_ring_color(), 2.5, -0.12)


func play_hit(from_direction: Vector2) -> void:
	var dir := from_direction
	if dir == Vector2.ZERO:
		dir = Vector2(0, -1)
	_hit = {"dir": dir.normalized(), "t": 0.0, "dur": HIT_FLASH_DUR}


func play_fire_recoil() -> void:
	if _cfg.fire_recoil <= 0.0:
		return
	_bounce = {"amp": _cfg.fire_recoil, "t": 0.0, "dur": 0.3}


func set_wall_link(active: bool) -> void:
	if _wall_link != active:
		_wall_link = active
		_ring_dirty = true


# === 控制 ===

func stop_all() -> void:
	_bounce.clear()
	_hit.clear()
	_order_dip.clear()
	_rings.clear()
	_flash = 0.0
	_req_state = State.IDLE
	_req_construction = false
	_req_age_upgrade = false
	_req_progress = 0.0
	_state = State.IDLE
	_progress = 0.0
	_state_time = 0.0
	_restore_snapshot()


func _restore_snapshot() -> void:
	if _body == null:
		return
	_body.position = _base_pos
	_body.scale = _base_scale
	_body.modulate = _base_modulate
	_idle_settled = true
	_ring_dirty = true


# === 内部 ===

func _process(delta: float) -> void:
	if _body == null or Engine.is_editor_hint():
		return
	_state_time += delta

	var scl := _base_scale
	var pos := _base_pos
	var flash := 0.0

	# 1) 持续脉冲（生产/施工中）
	if _state in [State.PRODUCING, State.CONSTRUCTING] and _cfg.pulse_interval > 0.0:
		var pulse: float = _cfg.pulse_strength * sin(TAU * _state_time / _cfg.pulse_interval + _phase)
		var p2 := 1.0 + pulse
		scl *= Vector2(p2, p2)

	# 2) 短事件
	var bounce_k := _advance_event(_bounce, delta)
	if bounce_k > 0.0:
		# 阻尼振荡：压→回弹→稳
		var env := exp(-4.0 * bounce_k) * sin(bounce_k * TAU * 2.5)
		var b: float = _bounce.amp * env
		scl *= Vector2(1.0 - b, 1.0 + b)
	var dip_k := _advance_event(_order_dip, delta)
	if dip_k > 0.0:
		var d: float = _cfg.complete_bounce * sin(dip_k * PI)  # 半周期正弦下沉
		scl *= Vector2(1.0 + d * 0.6, 1.0 - d)
	var hit_k := _advance_event(_hit, delta)
	if hit_k > 0.0:
		var env2 := exp(-4.0 * hit_k) * sin(hit_k * TAU * 2.5)
		pos += (_hit.dir as Vector2) * HIT_SHAKE_PX * env2
		flash = maxf(flash, absf(env2))
	_flash = maxf(_flash - delta / HIT_FLASH_DUR, flash)

	# 3) 写回（脏检查）
	if not _idle_settled or _has_active_effects():
		if pos != _body.position:
			_body.position = pos
		if scl != _body.scale:
			_body.scale = scl
		var mod := _base_modulate.lerp(C_HIT_RED, clampf(_flash * 0.6, 0.0, 0.6))
		if mod != _body.modulate:
			_body.modulate = mod
		if _state == State.IDLE and not _has_active_effects():
			_idle_settled = true

	# 4) 施工尘土周期
	if _state == State.CONSTRUCTING and _cfg.dust_interval > 0.0:
		_dust_timer += delta
		if _dust_timer >= _cfg.dust_interval:
			_dust_timer = 0.0
			_spawn_dust()
	elif _dust_timer >= 99.0:  # 落成尘土（play_construction_completed 置的哨兵）
		_dust_timer = 0.0
		_spawn_dust()

	# 5) 环 redraw
	_advance_rings(delta)
	var spinning := _state == State.AGE_UPGRADING
	if spinning or not _rings.is_empty() or _ring_dirty:
		queue_redraw()
		if not spinning and _rings.is_empty():
			_ring_dirty = false


func _has_active_effects() -> bool:
	return not _bounce.is_empty() or not _hit.is_empty() or not _order_dip.is_empty() or _flash > 0.0


## 推进事件字典，返回归一化进度（结束返回 -1 并清空）
func _advance_event(ev: Dictionary, delta: float) -> float:
	if ev.is_empty():
		return -1.0
	ev.t += delta
	if ev.t >= ev.dur:
		ev.clear()
		return -1.0
	return ev.t / ev.dur


func _spawn_dust() -> void:
	if _building == null:
		return
	var gs = _building.get("grid_size")
	var dim := 1.0
	if gs != null:
		dim = maxf(float(gs.x), float(gs.y))
	ParticlePool.spawn("dust", _building.global_position + (_cfg.dust_anchor as Vector2),
		{"scale": Vector2(dim * 0.8, dim * 0.8)})


func _push_ring(r0: float, grow: float, dur: float, color: Color, width: float, delay: float = 0.0) -> void:
	_rings.append({"r0": r0, "grow": grow, "t": delay, "dur": dur, "color": color, "width": width})


func _advance_rings(delta: float) -> void:
	for i in range(_rings.size() - 1, -1, -1):
		_rings[i].t += delta
		if _rings[i].t >= _rings[i].dur:
			_rings.remove_at(i)


func _gold_ring_color() -> Color:
	var bt: int = _building.get("building_type") if _building != null and "building_type" in _building else -1
	return RING_COLOR_OVERRIDES.get(bt, C_GOLD)


func _draw() -> void:
	if Engine.is_editor_hint():
		return
	var center := Vector2(0, _foot_y)

	# 升级转动金环：缺口弧，临近完成加速
	if _state == State.AGE_UPGRADING:
		var speed: float = lerpf(UPGRADE_RING_SPIN[0], UPGRADE_RING_SPIN[1], _progress)
		var ang: float = Time.get_ticks_msec() / 1000.0 * speed + _phase
		var col := _gold_ring_color()
		draw_arc(center, _ring_radius, ang, ang + TAU * 0.72, 48,
			Color(col.r, col.g, col.b, 0.55), 3.0)

	# 瞬态扩散环
	for r in _rings:
		if r.t < 0.0:
			continue
		var q: float = r.t / r.dur
		var c: Color = r.color
		draw_arc(center, r.r0 + r.grow * q, 0.0, TAU, 40,
			Color(c.r, c.g, c.b, c.a * (1.0 - q)), r.width)

	# 城墙连结细环（静态，仅变化时重绘）
	if _wall_link:
		draw_arc(center, _ring_radius, 0.0, TAU, 40, C_WALL_LINK, 1.5)
