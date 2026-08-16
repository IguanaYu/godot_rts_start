extends Node2D
## 拆件纸偶（paper doll）单位：AI 整图切片 → 部件按锚点拼装 → 代码驱动三态动画。
## 这是「角色拆件与模块化动画」调研（docs/research/technical/）的首个验证原型。
##
## 用法：由 puppet_demo.gd 调 setup(cfg) 注入部件贴图与锚点（均为整图像素坐标），
## 之后 set_state("idle"/"run"/"attack") 切换动画。部件锚点即节点原点，
## 旋转/位移全部打在 Node2D 上，Sprite 只做贴图偏移——像素不被破坏性变换。
##
## 节点结构（_build 里代码生成）：
##   PuppetUnit(本节点, 根缩放 0.6 对齐现有单位观感)
##   ├─ ArmBack (Node2D @肩后锚点) ─ Sprite(后臂)
##   ├─ Torso   (Node2D @髋锚点) ─ Sprite(躯干) ─ Head(Node2D @颈锚点) ─ Sprite(头)
##   └─ ArmFront(Node2D @肩前锚点) ─ Sprite(前臂) + Weapon(Sprite2D @手锚点)

signal attack_finished

const T_IDLE := 2.2          # 呼吸角速度
const T_RUN := 11.0          # 跑步步频
const ATK_WINDUP := 0.30     # 攻击·引（后摆蓄力）
const ATK_SLASH := 0.15      # 攻击·甩（快速前挥）
const ATK_SETTLE := 0.15     # 攻击·收（回位带余振）
const ATK_LEN := ATK_WINDUP + ATK_SLASH + ATK_SETTLE

var state := "idle"
var _t := 0.0                # 状态内时钟
var _atk_done := false
var _wpn_sway := 0.0         # 剑相对手臂的独立摆角（松握感的核心）

var _rig: Node2D             # 部件容器：原点=脚锚点（本节点原点即单位立足点）
var _torso: Node2D
var _head: Node2D
var _arm_b: Node2D
var _arm_f: Node2D
var _weapon: Sprite2D
var _hip := Vector2.ZERO
var _neck_base := Vector2.ZERO   # 颈锚点相对髋的基础偏移（头部摆动围绕它）
var _shadow_r := Vector2(26, 10)
var _root_scale := 0.6


## cfg: tex_* 部件图（arm 两张可选——v1 切片手臂留在躯干里，臂节点仅作武器枢轴）；
## origin_* 各部件在整图里的左上角坐标；
## anchor_hip/neck/shoulder_f/shoulder_b/hand 锚点（整图像素坐标）；feet 脚底中心。
func setup(cfg: Dictionary) -> void:
	_root_scale = cfg.get("scale", 0.6)
	_hip = cfg["anchor_hip"]
	_shadow_r = cfg.get("shadow_r", Vector2(26, 10))

	_rig = Node2D.new()
	_rig.position = -cfg["feet"]  # 装配坐标 → 脚锚点为本节点原点
	add_child(_rig)

	_arm_b = Node2D.new()
	_arm_b.position = cfg["anchor_shoulder_b"]
	_rig.add_child(_arm_b)
	if cfg.get("tex_arm_b"):
		_arm_b.add_child(_sprite(cfg["tex_arm_b"], cfg["origin_arm_b"] - cfg["anchor_shoulder_b"]))

	_torso = Node2D.new()
	_torso.position = _hip
	_rig.add_child(_torso)
	var torso_s := _sprite(cfg["tex_torso"], cfg["origin_torso"] - _hip)
	_torso.add_child(torso_s)

	_head = Node2D.new()
	_neck_base = cfg["anchor_neck"] - _hip
	_head.position = _neck_base
	_torso.add_child(_head)
	_head.add_child(_sprite(cfg["tex_head"], cfg["origin_head"] - cfg["anchor_neck"]))

	_arm_f = Node2D.new()
	_arm_f.position = cfg["anchor_shoulder_f"]
	_rig.add_child(_arm_f)
	if cfg.get("tex_arm_f"):
		_arm_f.add_child(_sprite(cfg["tex_arm_f"], cfg["origin_arm_f"] - cfg["anchor_shoulder_f"]))
	# 武器挂前臂节点下，但**旋转轴在握把**：node 原点=握点，贴图用 offset 摆位。
	# 这样剑自身 rotation（松握甩动）围绕掌心转，而不是绕图块左上角乱甩。
	_weapon = Sprite2D.new()
	_weapon.texture = cfg["tex_weapon"]
	_weapon.centered = false
	_weapon.position = cfg["anchor_hand"] - cfg["anchor_shoulder_f"]
	_weapon.offset = cfg["origin_weapon"] - cfg["anchor_hand"]
	_arm_f.add_child(_weapon)

	scale = Vector2(_root_scale, _root_scale)
	queue_redraw()


func set_state(s: String) -> void:
	if state == s and s != "attack":
		return
	state = s
	_t = 0.0
	_atk_done = false
	if s == "attack":
		_t = -0.0001


func face(dir: int) -> void:
	scale.x = abs(scale.x) * dir


func _process(delta: float) -> void:
	_t += delta
	match state:
		"idle":
			_anim_idle()
		"run":
			_anim_run()
		"attack":
			_anim_attack()
	if _weapon:
		_weapon.rotation = _wpn_sway


func _anim_idle() -> void:
	var b := sin(_t * T_IDLE)
	_torso.position = _hip + Vector2(0, b * 1.2)
	_torso.rotation = b * 0.015
	_head.rotation = sin(_t * T_IDLE + 0.4) * 0.04
	_head.position = _neck_base + Vector2(0, b * 0.5)  # 头部轻微独立起伏
	_arm_b.rotation = sin(_t * T_IDLE + 0.8) * 0.05
	_arm_f.rotation = sin(_t * T_IDLE + 1.2) * 0.05
	_wpn_sway = 0.05 * sin(_t * T_IDLE + 1.6)   # 剑尖极轻微荡


func _anim_run() -> void:
	# abs(sin) 双步弹跳 + 双臂反相摆 + 头部滞后（RimWorld 式代码行走）
	var s := sin(_t * T_RUN)
	_torso.position = _hip + Vector2(0, -abs(sin(_t * T_RUN)) * 2.6)
	_torso.rotation = s * 0.04
	_head.rotation = sin(_t * T_RUN + 0.6) * -0.06
	_arm_b.rotation = s * 0.5
	_arm_f.rotation = -s * 0.4
	# 剑独立滞后摆：相位落后手臂一截 + 二次小抖 —— 松握甩剑，不是焊死在手上
	_wpn_sway = 0.38 * sin(_t * T_RUN + 1.05) + 0.08 * sin(_t * T_RUN * 2.0 + 0.6)


func _anim_attack() -> void:
	# 三段式：引（后摆蓄力）→ 甩（快速前挥，剑滞后 whip）→ 收（余振回位）
	# 手臂与剑各走各的曲线——剑不跟随手臂刚体转动，有自己的节奏
	var arm := 0.0
	var lunge := 0.0
	var lean := 0.0
	if _t < ATK_WINDUP:
		var k := ease_out(_t / ATK_WINDUP)
		arm = lerp(0.0, -0.55, k)
		_wpn_sway = lerp(0.0, -0.75, k)          # 手腕后引，剑荡到肩后
		lean = lerp(0.0, -2.5, k)
		lunge = lerp(0.0, -2.0, k)               # 重心微微后坐
	elif _t < ATK_WINDUP + ATK_SLASH:
		var k := ease_in((_t - ATK_WINDUP) / ATK_SLASH)
		arm = lerp(-0.55, 1.25, k)
		_wpn_sway = lerp(-0.75, 0.55, k * k)     # 剑先滞后再甩出（鞭梢感）
		lean = lerp(-2.5, 2.5, k)
		lunge = lerp(-2.0, 7.5, k)               # 前探
	else:
		var k := clampf((_t - ATK_WINDUP - ATK_SLASH) / ATK_SETTLE, 0.0, 1.0)
		arm = lerp(1.25, 0.0, ease_out(k))
		_wpn_sway = 0.55 * (1.0 - k) * cos(12.0 * k)   # 衰减余振
		lean = lerp(2.5, 0.0, ease_out(k))
		lunge = lerp(7.5, 0.0, ease_out(k))
	_arm_f.rotation = arm
	_arm_b.rotation = -arm * 0.25
	_torso.position = _hip + Vector2(lean * 0.6 + lunge, -abs(lunge) * 0.15)
	_torso.rotation = lean * 0.004
	_head.rotation = arm * 0.1
	if _t >= ATK_LEN and not _atk_done:
		_atk_done = true
		attack_finished.emit()


func ease_out(k: float) -> float:
	return 1.0 - (1.0 - k) * (1.0 - k)


func ease_in(k: float) -> float:
	return k * k


func _sprite(tex: Texture2D, offset_px: Vector2) -> Sprite2D:
	var s := Sprite2D.new()
	s.texture = tex
	s.centered = false
	s.position = offset_px
	return s


func _part(tex: Texture2D, origin: Vector2, anchor: Vector2) -> Node2D:
	var n := Node2D.new()
	n.position = anchor
	n.add_child(_sprite(tex, origin - anchor))
	return n


func _draw() -> void:
	# 脚底椭圆影（本节点原点即立足点）
	var r := _shadow_r
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(-r.x, 0), Vector2(0, -r.y), Vector2(r.x, 0), Vector2(0, r.y),
		]),
		Color(0.1, 0.1, 0.2, 0.25)
	)
