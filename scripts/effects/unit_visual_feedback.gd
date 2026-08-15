class_name UnitVisualFeedback
extends Node2D
## UnitVisualFeedback（PR-3）：单位视觉反馈组件
## 短事件冲量（攻击前探/后坐、受击位移、治疗上提）+ 持续状态地面环（护盾/中毒/减速）
## 硬约束：只写 BodySprite.position/scale，禁止触碰 CharacterBody2D 本体
## 状态同步：组件每帧轮询父 Unit 字段（_slow_timer/_poison_timer/_shield_hp），
## 不要求 unit.gd 主动推送；set_* API 保留手动通道（PR-6 / 沙盒调试）
# z_index 5：高于 BodySprite(0)，低于 HPBar(100)，同 elite_aura 约定

@export var attack_lunge_px: float = -1.0   # 近战前探距离；-1 = 按 unit_type 默认
@export var ranged_recoil_px: float = -1.0  # 远程后坐距离；-1 = 按 unit_type 默认
@export var hit_push_px: float = 5.0        # 受击位移
@export var body_pulse_strength: float = 0.06  # 攻击/治疗缩放脉冲
@export var status_ring_enabled: bool = true
@export var idle_breath_strength: float = 0.0   # 默认 0 = 关闭（战场安静）

const Z_LAYER := 5
const SETTLE_DUR := 0.15
const RING_SHIELD_R := 22.0
const RING_INNER_R := 16.0
const SHIELD_BREATH_PERIOD := 1.2
const SHIELD_PULSE_DUR := 0.3
const HEAL_PULSE_DUR := 0.25
const C_SHIELD := Color(0.55, 0.80, 1.00)
const C_POISON := Color(0.35, 0.90, 0.35)
const C_SLOW := Color(0.40, 0.70, 1.00)
const C_HEAL := Color(0.40, 1.00, 0.50)

# int 键 = Unit.UnitType（0=SOLDIER 1=ARCHER 2=LANCER 3=MONK），避免引用 Unit 类
const TYPE_CFG := {
	0: {"lunge": 8.0, "recoil": 0.0, "dur": 0.18, "hold": 0.0},
	1: {"lunge": 0.0, "recoil": 6.0, "dur": 0.16, "hold": 0.0},
	2: {"lunge": 10.0, "recoil": 0.0, "dur": 0.24, "hold": 0.3},
	3: {"lunge": 0.0, "recoil": 0.0, "dur": 0.18, "hold": 0.0},
}

# --- 缓存 ---
var _body: Sprite2D = null
var _mat: ShaderMaterial = null
var _unit: Node2D = null
var _base_pos := Vector2.ZERO
var _base_scale := Vector2.ONE
var _cfg: Dictionary = {}
var _seed := 0.0

# --- 短事件冲量（同类覆盖不累加）：{dir, px, t, dur, hold} ---
var _atk := {}
var _hit := {}
var _heal_lift := {}

# --- 持续状态 ---
var _settle_t := -1.0   # <=0 表示待武装；>0 表示停步回正播放中
var _was_running := false
var _t := 0.0
var _ring_shield := false
var _ring_poison := false
var _ring_slow := false
var _manual_slow: bool = false  # set_slow 手动通道（true 时忽略轮询）
var _manual_poison: bool = false
var _manual_shield: bool = false
var _pulse_shield_hit := 0.0
var _pulse_heal := 0.0
var _draw_dirty := false


func _ready() -> void:
	z_index = Z_LAYER


func configure(body: Sprite2D, material: ShaderMaterial, unit_type: int, unit_seed: int) -> void:
	_body = body
	_mat = material
	_unit = get_parent()
	_cfg = TYPE_CFG.get(unit_type, TYPE_CFG[0])
	_seed = float(unit_seed % 1000) / 1000.0 * TAU
	if _body != null:
		_base_pos = _body.position
		_base_scale = _body.scale


# === 短事件 ===

func play_attack(aim_direction: Vector2, is_ranged: bool) -> void:
	if _body == null:
		return
	var px := 0.0
	var dir := aim_direction
	if is_ranged:
		px = ranged_recoil_px if ranged_recoil_px >= 0.0 else _cfg.recoil
		dir = -aim_direction  # 反作用力后坐
	else:
		px = attack_lunge_px if attack_lunge_px >= 0.0 else _cfg.lunge
	_atk = {"dir": dir, "px": px, "t": 0.0, "dur": _cfg.dur, "hold": _cfg.hold,
		"squash": Vector2.ONE + Vector2(body_pulse_strength, body_pulse_strength)}


func play_hit(from_direction: Vector2, shield_absorbed: bool) -> void:
	if _body == null:
		return
	if shield_absorbed:
		# 护盾吸收：位移减半 + 不压扁 + 蓝白扩散环
		_hit = {"dir": from_direction, "px": hit_push_px * 0.5, "t": 0.0,
			"dur": 0.16, "hold": 0.0, "squash": Vector2.ONE}
		_pulse_shield_hit = SHIELD_PULSE_DUR
	else:
		var dir := from_direction
		if dir == Vector2.ZERO:
			dir = Vector2(0, -1)  # 无 attacker 兜底：向上小跳
		_hit = {"dir": dir, "px": hit_push_px, "t": 0.0, "dur": 0.16, "hold": 0.0,
			"squash": Vector2(1.08, 0.90)}


func play_heal() -> void:
	if _body == null:
		return
	_heal_lift = {"dir": Vector2(0, -1), "px": 4.0, "t": 0.0, "dur": 0.35,
		"hold": 0.0, "squash": Vector2.ONE}
	_pulse_heal = HEAL_PULSE_DUR


# === 持续状态（手动通道）===

func set_slow(active: bool) -> void:
	_manual_slow = true
	_set_ring("slow", active)


func set_poison(active: bool) -> void:
	_manual_poison = true
	_set_ring("poison", active)


func set_shield(active: bool, _ratio: float = 1.0) -> void:
	_manual_shield = true
	_set_ring("shield", active)


func set_enraged(active: bool) -> void:
	if _mat != null:
		_mat.set_shader_parameter("enraged_enabled", active)


func set_blessed(active: bool, amount: float = 1.0) -> void:
	if _mat != null:
		_mat.set_shader_parameter("blessed_enabled", active)
		if active:
			_mat.set_shader_parameter("blessed_amount", clampf(amount, 0.0, 1.0))


func stop_all() -> void:
	_atk.clear()
	_hit.clear()
	_heal_lift.clear()
	_settle_t = -1.0
	_pulse_shield_hit = 0.0
	_pulse_heal = 0.0
	_set_ring("shield", false)
	_set_ring("poison", false)
	_set_ring("slow", false)
	if _body != null:
		_body.position = _base_pos
		_body.scale = _base_scale


# === 内部 ===

func _process(delta: float) -> void:
	if _body == null or Engine.is_editor_hint():
		return
	_t += delta
	var pos := _base_pos
	var scl := _base_scale

	# 1) move_settle：running→stop 瞬间一次性压扁回正
	var running: bool = _unit != null and _unit.velocity.length_squared() > 1.0
	if running:
		_settle_t = SETTLE_DUR
	elif _settle_t > 0.0:
		_settle_t -= delta
		var p := 1.0 - _settle_t / SETTLE_DUR
		var k := _impulse_curve(p)
		pos.y += 3.0 * (1.0 - k)
		scl *= Vector2(1.0 + 0.04 * k, 1.0 - 0.06 * k)
	_was_running = running

	# 2) 短事件冲量叠加
	var atk := _advance_impulse(_atk, delta)
	pos += atk[0]
	scl *= atk[1]
	var hit := _advance_impulse(_hit, delta)
	pos += hit[0]
	scl *= hit[1]
	var heal := _advance_impulse(_heal_lift, delta)
	pos += heal[0]
	scl *= heal[1]

	# 3) idle 呼吸（默认关）
	if idle_breath_strength > 0.0 and not running:
		var b := 1.0 + sin(_t * 2.0 + _seed) * idle_breath_strength
		scl *= Vector2(b, b)

	# 4) 脏检查写回
	if pos != _body.position:
		_body.position = pos
	if scl != _body.scale:
		_body.scale = scl

	# 5) 状态轮询 + 环 redraw
	_poll_states()
	_update_ring_redraw(delta)


func _advance_impulse(imp: Dictionary, delta: float) -> Array:
	if imp.is_empty():
		return [Vector2.ZERO, Vector2.ONE]
	imp.t += delta
	if imp.t >= imp.dur:
		imp.clear()
		return [Vector2.ZERO, Vector2.ONE]
	var hold := imp.get("hold", 0.0) as float
	var k := _impulse_curve(imp.t / imp.dur, hold)
	var offset: Vector2 = imp.dir * imp.px * k
	var squash: Vector2 = Vector2.ONE + (imp.squash - Vector2.ONE) * k
	return [offset, squash]


## 快出慢回曲线：p∈[0,1]；hold>0 时前段先冲到峰值保持
static func _impulse_curve(p: float, hold: float = 0.0) -> float:
	if p <= 0.0:
		return 0.0
	if hold > 0.0 and p < hold:
		var q := p / hold
		return 1.0 - pow(1.0 - q, 2)
	var q := (p - hold) / (1.0 - hold)
	if q < 0.35:
		var r := q / 0.35
		return 1.0 - pow(1.0 - r, 2)
	return 1.0 - (q - 0.35) / 0.65 * (1.0 - (1.0 - (q - 0.35) / 0.65))


func _poll_states() -> void:
	if _unit == null:
		return
	if not _manual_slow:
		_set_ring("slow", "_slow_timer" in _unit and _unit._slow_timer > 0.0)
	if not _manual_poison:
		_set_ring("poison", "_poison_timer" in _unit and _unit._poison_timer > 0.0)
	if not _manual_shield:
		_set_ring("shield", "_shield_hp" in _unit and _unit._shield_hp > 0)


func _set_ring(kind: String, active: bool) -> void:
	var cur: bool
	match kind:
		"shield":
			cur = _ring_shield
			_ring_shield = active
		"poison":
			cur = _ring_poison
			_ring_poison = active
		"slow":
			cur = _ring_slow
			_ring_slow = active
		_:
			return
	if cur != active:
		_draw_dirty = true


func _update_ring_redraw(delta: float) -> void:
	_pulse_shield_hit = maxf(0.0, _pulse_shield_hit - delta)
	_pulse_heal = maxf(0.0, _pulse_heal - delta)
	var any := _ring_shield or _ring_poison or _ring_slow \
		or _pulse_shield_hit > 0.0 or _pulse_heal > 0.0
	if any:
		queue_redraw()
	elif _draw_dirty:
		queue_redraw()  # 全熄灭后补画一次空帧清屏
		_draw_dirty = false


func _draw() -> void:
	if not status_ring_enabled or _unit == null:
		return
	if "is_stealthed" in _unit and _unit.is_stealthed():
		return

	# 护盾外环 r22：蓝白呼吸 1.2s 周期
	if _ring_shield:
		var br := sin(_t * TAU / SHIELD_BREATH_PERIOD + _seed)
		draw_arc(Vector2.ZERO, RING_SHIELD_R + br * 1.0, 0.0, TAU, 40,
			Color(C_SHIELD.r, C_SHIELD.g, C_SHIELD.b, 0.42 + br * 0.13), 2.0)

	# 中毒内环 r16：3 个绿点绕脚底慢转
	if _ring_poison:
		for i in 3:
			var a := _t * 1.2 + i * TAU / 3.0 + _seed
			draw_circle(Vector2(cos(a), sin(a)) * RING_INNER_R, 2.5,
				Color(C_POISON.r, C_POISON.g, C_POISON.b,
					0.55 + 0.25 * sin(_t * 3.0 + i)))

	# 减速内环 r16：3/4 蓝弧极慢旋转（与中毒形状区分）
	if _ring_slow:
		var r0 := _t * 0.3 + _seed
		draw_arc(Vector2.ZERO, RING_INNER_R, r0, r0 + TAU * 0.75, 28,
			Color(C_SLOW.r, C_SLOW.g, C_SLOW.b, 0.5), 2.0)

	# 护盾承伤脉冲：r16→26 扩散
	if _pulse_shield_hit > 0.0:
		var q := 1.0 - _pulse_shield_hit / SHIELD_PULSE_DUR
		draw_arc(Vector2.ZERO, RING_INNER_R + 10.0 * q, 0.0, TAU, 32,
			Color(C_SHIELD.r, C_SHIELD.g, C_SHIELD.b, 0.7 * (1.0 - q)), 2.5)

	# 治疗脉冲：r12→20 绿色扩散
	if _pulse_heal > 0.0:
		var q2 := 1.0 - _pulse_heal / HEAL_PULSE_DUR
		draw_arc(Vector2.ZERO, 12.0 + 8.0 * q2, 0.0, TAU, 32,
			Color(C_HEAL.r, C_HEAL.g, C_HEAL.b, 0.7 * (1.0 - q2)), 2.5)
