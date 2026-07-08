@tool
extends Node2D
## Phase 0 特效预览场景驱动
## 启动即显示全部 35 个效果，7 行（A-G）并排展示
## 操作：WASD/方向键滚动，Q/E 缩放，R 重置，F 自动巡游

const SLOT_W := 220
const SLOT_H := 160

const ObjectiveMarker := preload("res://scripts/effects/objective_marker.gd")
const StatusMarker := preload("res://scripts/outpost/outpost_status_marker.gd")
const OrbitingOrbs := preload("res://scripts/effects/orbiting_orbs_effect.gd")
const BeamEffect := preload("res://scripts/effects/beam_effect.gd")
const SkyEvent := preload("res://scripts/effects/sky_event_effect.gd")
const AoeZone := preload("res://scripts/effects/aoe_zone_effect.gd")
const ExplosionScene := preload("res://scenes/effects/explosion.tscn")
const UnitShader := preload("res://shaders/unit_effects.gdshader")

var _cam: Camera2D
var _cam_pos := Vector2(900, 580)  # 初始看向场景中部
var _cam_zoom := 0.6  # 默认缩小，看全更多
var _auto_tour := false
var _auto_tour_t := 0.0
var _help_label: Label

func _ready() -> void:
	print("PreviewAllVFX: spawning all 35 effects... (WASD 滚动 / Q E 缩放 / R 重置 / F 自动巡游 / 1-7 跳行)")
	_build_all()
	_setup_camera()
	_setup_hud()

func _setup_camera() -> void:
	_cam = Camera2D.new()
	_cam.position = _cam_pos
	_cam.zoom = Vector2(_cam_zoom, _cam_zoom)
	add_child(_cam)
	_cam.make_current()

func _setup_hud() -> void:
	# HUD 用 CanvasLayer 固定在屏幕上，不随摄像头移动
	var layer := CanvasLayer.new()
	add_child(layer)
	_help_label = Label.new()
	_help_label.text = "WASD 滚动 · Q/E 缩放 · R 重置 · F 自动巡游 · 1-7 跳行\n当前: 全景 (zoom=%.2f)" % _cam_zoom
	_help_label.add_theme_font_size_override("font_size", 16)
	_help_label.add_theme_color_override("font_color", Color(1.0, 1.0, 0.8))
	_help_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.95))
	_help_label.add_theme_constant_override("shadow_offset_x", 2)
	_help_label.add_theme_constant_override("shadow_offset_y", 2)
	_help_label.position = Vector2(20, 20)
	layer.add_child(_help_label)

func _process(delta: float) -> void:
	if not _cam:
		return
	var speed := 600.0 * delta / maxf(_cam_zoom, 0.3)
	var moved := false
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		_cam_pos.y -= speed; moved = true
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		_cam_pos.y += speed; moved = true
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		_cam_pos.x -= speed; moved = true
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		_cam_pos.x += speed; moved = true
	# 缩放
	if Input.is_key_pressed(KEY_Q):
		_cam_zoom = maxf(0.3, _cam_zoom - 1.0 * delta)
		moved = true
	if Input.is_key_pressed(KEY_E):
		_cam_zoom = minf(2.5, _cam_zoom + 1.0 * delta)
		moved = true
	# 自动巡游模式
	if _auto_tour:
		_auto_tour_t += delta
		# 8 字形巡游路径
		var t := _auto_tour_t * 0.2
		_cam_pos.x = 900 + sin(t) * 700
		_cam_pos.y = 580 + sin(t * 2.0) * 400
		moved = true
	if moved:
		_cam.position = _cam_pos
		_cam.zoom = Vector2(_cam_zoom, _cam_zoom)
		if _help_label:
			var mode := "自动巡游" if _auto_tour else "手动"
			_help_label.text = "WASD 滚动 · Q/E 缩放 · R 重置 · F 自动巡游 · 1-7 跳行\n[%s] pos=(%d,%d) zoom=%.2f" % [mode, int(_cam_pos.x), int(_cam_pos.y), _cam_zoom]

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_R:
				_cam_pos = Vector2(900, 580)
				_cam_zoom = 1.0
				_auto_tour = false
			KEY_F:
				_auto_tour = not _auto_tour
				_auto_tour_t = 0.0
				print("auto tour: ", _auto_tour)
			KEY_1:  # 数字键 1-7 跳到对应行
				_jump_to_row(0)
			KEY_2: _jump_to_row(1)
			KEY_3: _jump_to_row(2)
			KEY_4: _jump_to_row(3)
			KEY_5: _jump_to_row(4)
			KEY_6: _jump_to_row(5)
			KEY_7: _jump_to_row(6)

func _jump_to_row(row_idx: int) -> void:
	_cam_pos = Vector2(900, 20 + row_idx * 160 + 60)
	_cam_zoom = 1.2
	_auto_tour = false
	if _cam:
		_cam.position = _cam_pos
		_cam.zoom = Vector2(_cam_zoom, _cam_zoom)

func _build_all() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.13, 0.13, 0.13)
	bg.size = Vector2(4000, 1800)
	bg.position = Vector2(-200, -100)
	add_child(bg)

	var y_start := 20
	_spawn_row_a(y_start)
	_spawn_row_b(y_start + 160)
	_spawn_row_c(y_start + 320)
	_spawn_row_d(y_start + 480)
	_spawn_row_e(y_start + 640)
	_spawn_row_f(y_start + 800)
	_spawn_row_g(y_start + 960)
	_spawn_row_labels(y_start)

func _spawn_row_labels(y_start: float) -> void:
	var names := ["A 标识型", "B 地面贴花", "C 身体材质", "D 光球", "E 连接光束", "F 天降事件", "G 区域效果"]
	for i in range(names.size()):
		var lbl := Label.new()
		lbl.text = names[i]
		lbl.add_theme_font_size_override("font_size", 18)
		lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
		lbl.position = Vector2(-30, y_start + i * 160 + 50)
		add_child(lbl)

# ============================================================
# 工具函数
# ============================================================

func _make_label(text: String, y_offset: float) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	lbl.position = Vector2(-60, y_offset)
	lbl.size = Vector2(120, 18)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return lbl

func _make_slot(x: float, y: float) -> Node2D:
	var slot := Node2D.new()
	slot.position = Vector2(x, y)
	return slot

func _make_dummy_unit() -> Sprite2D:
	var spr := Sprite2D.new()
	var tex := load("res://assets/units/blue_warrior/Warrior_Idle.png")
	if tex:
		spr.texture = tex
		spr.hframes = 8
		spr.frame = 0
		spr.scale = Vector2(0.6, 0.6)
		spr.position = Vector2(0, -11)  # 匹配 soldier.tscn 的 sprite lift
		# 闲置帧动画 (8 帧)
		var tw := spr.create_tween().set_loops()
		tw.tween_method(func(f): spr.frame = f, 0, 7, 0.8)
		tw.tween_method(func(f): spr.frame = f, 7, 0, 0.8)
	else:
		# fallback 灰圆
		var sz := 48
		var img := Image.create(sz, sz, false, Image.FORMAT_RGBA8)
		img.fill(Color.TRANSPARENT)
		var cx := sz / 2
		var cy := sz / 2
		var r := sz / 2 - 2
		for px in range(sz):
			for py in range(sz):
				var dx := px - cx
				var dy := py - cy
				if dx * dx + dy * dy <= r * r:
					img.set_pixel(px, py, Color(0.6, 0.6, 0.6, 1.0))
		spr.texture = ImageTexture.create_from_image(img)
	return spr

func _make_dummy_unit_with_shader() -> Sprite2D:
	var spr := _make_dummy_unit()
	var mat := ShaderMaterial.new()
	mat.shader = UnitShader
	spr.material = mat
	return spr

# ============================================================
# A 类：标识型 — 使用 objective_marker.gd
# ============================================================

func _spawn_row_a(y: float) -> void:
	var items := [
		["A1", "boss 王冠"],
		["A2", "elite 钻石"],
		["A3", "enraged Skull"],
		["A4", "blessed Star"],
	]
	var type_map := [
		ObjectiveMarker.MarkerType.CROWN,
		ObjectiveMarker.MarkerType.DIAMOND,
		ObjectiveMarker.MarkerType.SKULL,
		ObjectiveMarker.MarkerType.STAR,
	]
	var color_map := [
		Color(0.60, 0.20, 0.90),
		Color(0.40, 0.70, 1.00),
		Color(0.90, 0.15, 0.15),
		Color(1.00, 0.84, 0.25),
	]

	for i in range(items.size()):
		var slot := _make_slot(80.0 + i * SLOT_W, y + 60)
		var dummy := _make_dummy_unit()
		slot.add_child(dummy)

		var marker := ObjectiveMarker.new()
		marker.marker_type = type_map[i]
		marker.icon_size = 22.0
		marker.height_offset = -38.0
		slot.add_child(marker)
		marker.setup(dummy)
		marker.modulate = color_map[i]

		slot.add_child(_make_label(items[i][0] + " " + items[i][1], 30.0))
		add_child(slot)

# ============================================================
# B 类：地面贴花 — 使用 outpost_status_marker.gd
# ============================================================

func _spawn_row_b(y: float) -> void:
	var items := [
		["B1", "inspire", &"inspire"],
		["B2", "heal", &"heal"],
		["B3", "shield", &"shield"],
		["B4", "attack", &"attack"],
		["B5", "burn", &"burn"],
		["B6", "poison", &"poison"],
		["B7", "rage", &"rage"],
		["B8", "slow", &"slow"],
		["B9", "telegraph_aoe", &"telegraph_aoe"],
	]

	for i in range(items.size()):
		var item = items[i]
		var wx := 80.0 + i * SLOT_W
		var wy := y + 60
		# marker 直接加到根节点，用 center 定位（outpost_status_marker._process 会强制 global_position = center）
		var marker := StatusMarker.new()
		marker.effect_id = item[2]
		marker.center = Vector2(wx, wy)
		marker.duration_sec = 0.0
		add_child(marker)
		# label 用 slot 包装
		var slot := _make_slot(wx, wy)
		slot.add_child(_make_label(item[0] + " " + item[1], 30.0))
		add_child(slot)

# ============================================================
# C 类：身体材质（shader）
# ============================================================

func _spawn_row_c(y: float) -> void:
	var items := [
		["C1", "hit_flash"],
		["C2a", "boss_glow a"],
		["C2b", "boss_glow b"],
		["C3", "enraged"],
		["C4", "blessed"],
		["C5", "死亡爆裂"],
	]

	for i in range(items.size()):
		var slot := _make_slot(80.0 + i * SLOT_W, y + 60)
		var dummy := _make_dummy_unit_with_shader()
		var mat := dummy.material as ShaderMaterial

		match i:
			0:  # C1 hit_flash 脉冲白闪
				mat.set_shader_parameter("hit_flash_enabled", true)
				var tw := create_tween().set_loops()
				tw.tween_method(func(v): mat.set_shader_parameter("hit_flash_amount", v), 0.85, 0.0, 0.15)
				tw.tween_method(func(v): mat.set_shader_parameter("hit_flash_amount", v), 0.0, 0.85, 0.35)
				tw.tween_interval(1.5)
			1:  # C2a boss_glow a 版 shader fake
				mat.set_shader_parameter("boss_glow_enabled", true)
				mat.set_shader_parameter("boss_glow_color", Color(0.60, 0.20, 0.90))
				mat.set_shader_parameter("boss_pulse_speed", 3.0)
				mat.set_shader_parameter("glow_width", 4.0)
			2:  # C2b boss_glow b 版标记 — 同样用 shader fake 但白色呼吸提示"这是 b 版对比"
				mat.set_shader_parameter("boss_glow_enabled", true)
				mat.set_shader_parameter("boss_glow_color", Color(0.60, 0.20, 0.90))
				mat.set_shader_parameter("boss_pulse_speed", 3.0)
				mat.set_shader_parameter("glow_width", 4.0)
				var tw := create_tween().set_loops()
				tw.tween_method(func(v): dummy.modulate = Color(1,1,1,v), 0.0, 0.3, 0.5)
				tw.tween_method(func(v): dummy.modulate = Color(1,1,1,v), 0.3, 0.0, 0.5)
			3:  # C3 enraged
				mat.set_shader_parameter("enraged_enabled", true)
			4:  # C4 blessed
				mat.set_shader_parameter("blessed_enabled", true)
			5:  # C5 死亡爆裂
				pass

		slot.add_child(dummy)

		# C5: 循环爆炸
		if i == 5:
			var boom := ExplosionScene.instantiate()
			boom.modulate = Color(0.8, 0.2, 0.2)
			slot.add_child(boom)
			var timer := Timer.new()
			timer.wait_time = 3.0
			timer.autostart = true
			timer.timeout.connect(func():
				var b := ExplosionScene.instantiate()
				b.modulate = Color(0.8, 0.2, 0.2)
				slot.add_child(b)
			)
			slot.add_child(timer)

		slot.add_child(_make_label(items[i][0] + " " + items[i][1], 30.0))
		add_child(slot)

# ============================================================
# D 类：光球（程序化）
# ============================================================

func _spawn_row_d(y: float) -> void:
	var items := [
		["D1", "holy_orbs"],
		["D2", "arcane_orbs"],
		["D3", "shield_orbit"],
		["D4", "burning_orbs"],
		["D5", "poison_orbs"],
	]
	var ids := [&"holy_orbs", &"arcane_orbs", &"shield_orbit", &"burning_orbs", &"poison_orbs"]

	for i in range(items.size()):
		var slot := _make_slot(80.0 + i * SLOT_W, y + 60)
		var dummy := _make_dummy_unit()
		slot.add_child(dummy)
		var orbs := OrbitingOrbs.new()
		orbs.effect_id = ids[i]
		orbs.target = dummy
		slot.add_child(orbs)
		slot.add_child(_make_label(items[i][0] + " " + items[i][1], 30.0))
		add_child(slot)

# ============================================================
# E 类：连接光束
# ============================================================

func _spawn_row_e(y: float) -> void:
	var items := [
		["E1", "heal_beam"],
		["E2", "chain_lightning"],
		["E3", "siphon"],
		["E4", "life_leech"],
	]
	var ids := [&"heal_beam", &"chain_lightning", &"siphon", &"life_leech"]

	for i in range(items.size()):
		var slot := _make_slot(80.0 + i * SLOT_W, y + 60)
		var left := _make_dummy_unit()
		left.position = Vector2(-40, 0)
		var right := _make_dummy_unit()
		right.position = Vector2(40, 0)
		slot.add_child(left)
		slot.add_child(right)
		var beam := BeamEffect.new()
		beam.effect_id = ids[i]
		beam.source_pos = left.global_position
		beam.target_pos = right.global_position
		beam.duration_sec = 0.0
		slot.add_child(beam)
		slot.add_child(_make_label(items[i][0] + " " + items[i][1], 30.0))
		add_child(slot)

# ============================================================
# F 类：天降事件
# ============================================================

func _spawn_row_f(y: float) -> void:
	var items := [
		["F1", "meteor"],
		["F2", "divine_strike"],
		["F3", "arcane_meteor"],
		["F4", "resurrection"],
	]
	var ids := [&"meteor", &"divine_strike", &"arcane_meteor", &"resurrection"]

	for i in range(items.size()):
		var slot := _make_slot(80.0 + i * SLOT_W, y + 60)
		var ground := _make_dummy_unit()
		ground.modulate = Color(0.4, 0.4, 0.4, 0.5)
		slot.add_child(ground)
		# 首次天降
		var sky := SkyEvent.new()
		sky.effect_id = ids[i]
		sky.center_pos = Vector2.ZERO
		slot.add_child(sky)
		# 循环触发
		var timer := Timer.new()
		timer.wait_time = 3.5
		timer.autostart = true
		timer.timeout.connect(func():
			var ns := SkyEvent.new()
			ns.effect_id = ids[i]
			ns.center_pos = Vector2.ZERO
			slot.add_child(ns)
		)
		slot.add_child(timer)
		slot.add_child(_make_label(items[i][0] + " " + items[i][1], 30.0))
		add_child(slot)

# ============================================================
# G 类：区域效果
# ============================================================

func _spawn_row_g(y: float) -> void:
	var items := [
		["G1", "heal_aura"],
		["G2", "damage_aura"],
		["G3", "slow_aura"],
		["G4", "fear_aura"],
	]
	var ids := [&"heal_aura", &"damage_aura", &"slow_aura", &"fear_aura"]

	for i in range(items.size()):
		var slot := _make_slot(80.0 + i * SLOT_W, y + 60)
		var dummy := _make_dummy_unit()
		slot.add_child(dummy)
		var zone := AoeZone.new()
		zone.effect_id = ids[i]
		zone.target_pos = Vector2.ZERO
		zone.duration_sec = 0.0
		slot.add_child(zone)
		slot.add_child(_make_label(items[i][0] + " " + items[i][1], 30.0))
		add_child(slot)
