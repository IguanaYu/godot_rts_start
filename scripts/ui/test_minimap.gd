extends Node2D
## 小地图测试场景：独立于 main.gd 运行，直接测试 minimap 所有特效
##
## 键盘快捷键：
##   1-4: 单独显示某组，5: 全部显示

const MinimapPanel := preload("res://scripts/ui/minimap_panel.gd")
const MMD := preload("res://scripts/ui/minimap_marker_data.gd")
const PATH_WOOD_TABLE := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Wood Table/WoodTable.png"

# minimap 引用
var _minimap: Control
var _map_bounds := Rect2(-500, -500, 2000, 1700)

# 注册的标记 ID 分组
var _group_ids: Dictionary = {}  # group_name -> Array[int]


func _ready() -> void:
	_setup_dummy_nodes()
	_setup_minimap()
	_register_all_markers()
	_setup_ui_overlay()


func _process(_delta: float) -> void:
	# 每 3 秒触发一次 ping
	var t := Time.get_ticks_msec() / 1000.0
	if int(t) % 3 == 0 and int(t * 10) % 10 == 0:
		var ping_pos := Vector2(200, 550 + sin(t * 2.0) * 50.0)
		_minimap.send_ping(ping_pos, Color(1.0, 0.6, 0.0), MMD.Shape.CIRCLE, 1.5)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1: _show_only_group("shapes")
			KEY_2: _show_only_group("anims")
			KEY_3: _show_only_group("clusters")
			KEY_4: _show_only_group("scale")
			KEY_5: _show_all_groups()


# ============================================================
# 初始化
# ============================================================
func _setup_dummy_nodes() -> void:
	# minimap 会遍历 _main_node.player_units_node / enemy_units_node / buildings_node
	# 添加空容器避免报错
	for name in ["PlayerUnits", "EnemyUnits", "Buildings"]:
		if not has_node(name):
			var n := Node2D.new()
			n.name = name
			add_child(n)


func _setup_minimap() -> void:
	# 创建 CanvasLayer 作为 UI 层
	var ui_layer := CanvasLayer.new()
	ui_layer.layer = 10
	add_child(ui_layer)

	# minimap 包装器（右下角）
	var wrapper := Control.new()
	wrapper.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	wrapper.offset_left = -186
	wrapper.offset_top = -186
	wrapper.offset_right = -6
	wrapper.offset_bottom = -6
	ui_layer.add_child(wrapper)

	# 背景（木纹九宫格）
	var bg := NinePatchRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var tex := load(PATH_WOOD_TABLE)
	if tex:
		bg.texture = tex
		bg.patch_margin_left = 8
		bg.patch_margin_top = 8
		bg.patch_margin_right = 8
		bg.patch_margin_bottom = 8
	wrapper.add_child(bg)

	# minimap 面板
	_minimap = Control.new()
	_minimap.set_script(MinimapPanel)
	_minimap.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_minimap.offset_left = 7
	_minimap.offset_top = 7
	_minimap.offset_right = -7
	_minimap.offset_bottom = -7
	wrapper.add_child(_minimap)
	_minimap.initialize(self, null, _map_bounds)


func _setup_ui_overlay() -> void:
	var ui_layer := CanvasLayer.new()
	ui_layer.layer = 20
	add_child(ui_layer)

	var panel := Panel.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	panel.offset_left = 10
	panel.offset_top = 10
	panel.size = Vector2(320, 400)
	ui_layer.add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 8
	vbox.offset_top = 8
	vbox.offset_right = -8
	vbox.offset_bottom = -8
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "小地图测试场景"
	title.theme_override_font_sizes/font_size = 18
	vbox.add_child(title)

	var sep := HSeparator.new()
	vbox.add_child(sep)

	var lines := [
		"",
		"[1] 形状展示 (6种)",
		"[2] 动画特效 (11种)",
		"[3] 密度聚类",
		"[4] 比例测试",
		"[5] 全部显示（默认）",
		"",
		"Alt+左键: 攻击 ping",
		"Alt+右键: 防御 ping",
		"左键点击: 跳转相机",
	]
	for txt in lines:
		var label := Label.new()
		label.text = txt
		label.theme_override_font_sizes/font_size = 14
		vbox.add_child(label)


# ============================================================
# 注册所有标记
# ============================================================
func _register_all_markers() -> void:
	_register_shape_demo()
	_register_anim_demo()
	_register_cluster_demo()
	_register_scale_demo()


# ---------- 组 A：形状展示 ----------
func _register_shape_demo() -> void:
	var group := "shapes"
	_group_ids[group] = []

	var shapes := [
		{ shape = MMD.Shape.CIRCLE,   color = Color.RED,        label = "CIRCLE" },
		{ shape = MMD.Shape.DIAMOND,  color = Color(0.2, 0.5, 1.0), label = "DIAMOND" },
		{ shape = MMD.Shape.TRIANGLE, color = Color.GREEN,      label = "TRIANGLE" },
		{ shape = MMD.Shape.SQUARE,   color = Color.YELLOW,     label = "SQUARE" },
		{ shape = MMD.Shape.STAR,     color = Color(0.7, 0.3, 1.0), label = "STAR" },
		{ shape = MMD.Shape.CROSS,    color = Color.ORANGE,     label = "CROSS" },
	]

	var base := Vector2(-200, -200)
	for i in range(shapes.size()):
		var s := shapes[i]
		var pos := base + Vector2(i * 100, 0)
		var m := MMD.new(pos, s.color, s.shape, 4.0, MMD.Anim.NONE)
		m.group = group
		_group_ids[group].append(_minimap.register_marker(m))


# ---------- 组 B：动画特效 ----------
func _register_anim_demo() -> void:
	var group := "anims"
	_group_ids[group] = []

	var anims := [
		{ anim = MMD.Anim.NONE,          color = Color.RED,        label = "NONE", sz = 3.0 },
		{ anim = MMD.Anim.PULSE,         color = Color.GREEN,      label = "PULSE", sz = 3.0 },
		{ anim = MMD.Anim.BLINK,         color = Color(0.2, 0.5, 1.0), label = "BLINK", sz = 3.0 },
		{ anim = MMD.Anim.BOUNCE,        color = Color.YELLOW,     label = "BOUNCE", sz = 3.0 },
		{ anim = MMD.Anim.COLOR_BREATHE, color = Color.RED,        label = "COLOR_BR", sz = 3.0, extra = { color_b = Color.BLUE } },
		{ anim = MMD.Anim.ROTATE,        color = Color(0.7, 0.3, 1.0), label = "ROTATE", sz = 3.0, shape = MMD.Shape.DIAMOND },
		{ anim = MMD.Anim.RIPPLE,        color = Color(0.2, 0.8, 1.0), label = "RIPPLE", sz = 3.0 },
		{ anim = MMD.Anim.SHAKE,         color = Color.ORANGE,     label = "SHAKE", sz = 3.0 },
		{ anim = MMD.Anim.BURST,         color = Color(1.0, 0.4, 0.3), label = "BURST", sz = 3.0 },
	]

	var base := Vector2(0, 0)
	for i in range(anims.size()):
		var a := anims[i]
		var pos := base + Vector2(i % 4 * 90, floori(i / 4.0) * 80)
		var shape := a.get("shape", MMD.Shape.CIRCLE)
		var m := MMD.new(pos, a.color, shape, a.sz, a.anim)
		m.group = group
		if a.anim == MMD.Anim.COLOR_BREATHE:
			m.color_b = Color.BLUE
		if a.anim == MMD.Anim.RIPPLE:
			m.lifetime = 2.0
		if a.anim == MMD.Anim.BURST:
			m.anim_speed = 0.8
		_group_ids[group].append(_minimap.register_marker(m))


# ---------- 组 C：密度聚类 ----------
func _register_cluster_demo() -> void:
	var group := "clusters"
	# 密度聚类通过 _draw_units() 中的 enemy_units_node 子节点触发
	# 添加真实的 Node2D 子节点来测试聚类算法
	var enemy_root := $"EnemyUnits"

	# 密集组：15 个单位在 100x100 范围内 → 应显示为红色团块
	var dense_center := Vector2(1000, 500)
	for i in range(15):
		var offset := Vector2(randf() * 100.0 - 50.0, randf() * 100.0 - 50.0)
		var unit := Node2D.new()
		unit.position = dense_center + offset
		enemy_root.add_child(unit)

	# 稀疏组：3 个单位分散放置 → 应显示为独立红点
	var sparse_positions := [Vector2(1300, 500), Vector2(1400, 550), Vector2(1350, 450)]
	for pos in sparse_positions:
		var unit := Node2D.new()
		unit.position = pos
		enemy_root.add_child(unit)

	var label_s := MMD.new(Vector2(1350, 380), Color.WHITE, MMD.Shape.DIAMOND, 2.0)
	label_s.group = group
	_group_ids[group].append(_minimap.register_marker(label_s))


# ---------- 组 D：比例测试 ----------
func _register_scale_demo() -> void:
	var group := "scale"
	_group_ids[group] = []

	# 建筑方块（4~7px）
	var buildings := [Vector2(800, 50), Vector2(900, 50), Vector2(1000, 50)]
	for pos in buildings:
		var m := MMD.new(pos, Color(0.2, 0.5, 1.0), MMD.Shape.SQUARE, 5.0)
		m.group = group
		_group_ids[group].append(_minimap.register_marker(m))

	var label_b := MMD.new(Vector2(900, -20), Color.WHITE, MMD.Shape.DIAMOND, 2.0)
	label_b.group = group
	_group_ids[group].append(_minimap.register_marker(label_b))

	# 单位圆点（2~3.5px），紧挨建筑旁边
	var units := [Vector2(800, 120), Vector2(850, 120), Vector2(900, 120)]
	for pos in units:
		var m := MMD.new(pos, Color(0.2, 0.9, 0.2), MMD.Shape.CIRCLE, 3.0)
		m.group = group
		_group_ids[group].append(_minimap.register_marker(m))

	var label_u := MMD.new(Vector2(850, 160), Color.WHITE, MMD.Shape.DIAMOND, 2.0)
	label_u.group = group
	_group_ids[group].append(_minimap.register_marker(label_u))


# ============================================================
# 分组切换
# ============================================================
func _show_only_group(group: String) -> void:
	for g in _group_ids.keys():
		if g == group:
			_minimap.show_group(g)
		else:
			_minimap.hide_group(g)


func _show_all_groups() -> void:
	for g in _group_ids.keys():
		_minimap.show_group(g)
