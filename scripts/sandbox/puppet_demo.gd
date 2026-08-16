extends Node2D
## 拆件纸偶 demo：帧表单位 vs 拆件 puppet 并排，同一状态时间轴驱动。
## 左：Tiny Swords 帧表 Warrior（原图）　中：拆件 puppet 蓝队　右：拆件 puppet 红队（同 rig 阵营重映射）
## 状态循环：idle 2.6s → run 2.6s → attack ×2 → idle。
## --shot 模式：在 idle / run / attack 三个时刻截图到 tmp/ 后退出。

const MeadowTex := preload("res://assets/terrain_textures/ground_meadow.png")
const PuppetScript := preload("res://scripts/sandbox/puppet_unit.gd")
const SheetScript := preload("res://scripts/sandbox/sheet_unit_demo.gd")
const REPORT_PATH := "res://assets/sandbox/puppet_unit/parts_report.json"

const EVENTS := [[0.0, "idle"], [2.6, "run"], [5.2, "attack"], [6.4, "attack"], [7.6, "idle"]]
const CYCLE := 9.0
const SHOTS := [[1.4, "idle"], [4.0, "run"], [5.35, "atk_windup"], [5.58, "atk_slash"]]

var _units: Array[Node] = []
var _state_label: Label
var _t := 0.0
var _cur_state := ""
var _event_idx := 0
var _shot_idx := 0
var _capturing := false


func _ready() -> void:
	var vs := get_viewport_rect().size

	# 地面
	var g := Sprite2D.new()
	g.texture = MeadowTex
	g.centered = false
	g.region_enabled = true
	g.region_rect = Rect2(0, 0, vs.x, vs.y)
	g.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	g.z_index = -10
	add_child(g)

	# 三站
	var sheet := _build_sheet_unit()
	sheet.position = Vector2(320, 430)
	add_child(sheet)
	_units.append(sheet)

	var report := _load_report()
	for color in ["blue", "red"]:
		var puppet := Node2D.new()
		puppet.set_script(PuppetScript)
		add_child(puppet)
		puppet.setup(_puppet_cfg(report, color))
		puppet.position = Vector2(640 if color == "blue" else 960, 430)
		_units.append(puppet)

	# 站位标签（世界空间）
	_tag(Vector2(320, 330), "帧表 Warrior（Tiny Swords 原图）")
	_tag(Vector2(640, 330), "拆件 Puppet · 蓝队")
	_tag(Vector2(960, 330), "拆件 Puppet · 红队（同 rig 换阵营色）")

	# 顶栏（UI 层）
	var layer := CanvasLayer.new()
	add_child(layer)
	var title := Label.new()
	title.text = "拆件纸偶 vs 帧表精灵表 —— 同一状态时间轴：idle → run → attack ×2"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color("161c2e"))
	title.position = Vector2(120, 24)
	layer.add_child(title)
	_state_label = Label.new()
	_state_label.text = "IDLE"
	_state_label.add_theme_font_size_override("font_size", 34)
	_state_label.add_theme_color_override("font_color", Color("5a4638"))
	_state_label.position = Vector2(vs.x / 2 - 60, 66)
	layer.add_child(_state_label)


func _process(delta: float) -> void:
	_t += delta
	var ct := fmod(_t, CYCLE)
	if _event_idx < EVENTS.size() and ct >= EVENTS[_event_idx][0]:
		_apply_state(EVENTS[_event_idx][1])
		_event_idx += 1
	if ct < 0.02 and _event_idx >= EVENTS.size():
		_event_idx = 0  # 回环
	if not _capturing and _shot_idx < SHOTS.size() and _t >= SHOTS[_shot_idx][0]:
		_capture()


func _apply_state(s: String) -> void:
	_cur_state = s
	if _state_label:
		_state_label.text = s.to_upper()
	for u in _units:
		u.set_state(s)


func _build_sheet_unit() -> Node2D:
	var n := Node2D.new()
	n.set_script(SheetScript)
	var states := {}
	for key in ["idle", "run", "attack"]:
		var path := "res://assets/units/blue_warrior/Warrior_%s.png" % [
			{"idle": "Idle", "run": "Run", "attack": "Attack1"}[key]]
		states[key] = {"tex": load(path), "fps": {"idle": 8, "run": 10, "attack": 12}[key]}
	n.setup(states, 0.6)
	return n


func _load_report() -> Dictionary:
	var f := FileAccess.open(REPORT_PATH, FileAccess.READ)
	var data: Dictionary = JSON.parse_string(f.get_as_text())
	f.close()
	return data


func _puppet_cfg(report: Dictionary, color: String) -> Dictionary:
	var base := "res://assets/sandbox/puppet_unit/%s/" % color
	var parts: Dictionary = report["parts"]
	var anchors: Dictionary = report["anchors"]
	var v2 := func(arr: Array) -> Vector2: return Vector2(arr[0], arr[1])
	var cfg := {
		"tex_torso": load(base + "torso.png"),
		"tex_head": load(base + "head.png"),
		"tex_arm_f": load(base + "arm_f.png"),
		"tex_arm_b": load(base + "arm_b.png"),
		"tex_weapon": load(base + "weapon.png"),
		"origin_torso": v2.call(parts["torso"]["origin"]),
		"origin_head": v2.call(parts["head"]["origin"]),
		"origin_arm_f": v2.call(parts["arm_f"]["origin"]),
		"origin_arm_b": v2.call(parts["arm_b"]["origin"]),
		"origin_weapon": v2.call(parts["weapon"]["origin"]),
		"anchor_hip": v2.call(anchors["anchor_hip"]),
		"anchor_neck": v2.call(anchors["anchor_neck"]),
		"anchor_shoulder_f": v2.call(anchors["anchor_shoulder_f"]),
		"anchor_shoulder_b": v2.call(anchors["anchor_shoulder_b"]),
		"anchor_hand": v2.call(anchors["anchor_hand"]),
		"feet": v2.call(anchors["feet"]),
		"scale": 0.6,
		"shadow_r": Vector2(24, 9),
	}
	return cfg


func _tag(pos: Vector2, text: String) -> void:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 17)
	l.add_theme_color_override("font_color", Color("161c2e"))
	l.position = pos - Vector2(160, 0)
	add_child(l)


func _capture() -> void:
	_capturing = true
	_do_capture(_shot_idx)


func _do_capture(i: int) -> void:
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	var name: String = SHOTS[i][1]
	img.save_png("res://tmp/puppet_demo_shot_%d_%s.png" % [i, name])
	print("[PuppetDemo] shot -> tmp/puppet_demo_shot_%d_%s.png" % [i, name])
	_shot_idx += 1
	_capturing = false
	if _shot_idx >= SHOTS.size() and "--shot" in OS.get_cmdline_args():
		get_tree().quit()
