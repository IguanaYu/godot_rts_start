extends Node2D
## 风格实景 demo v2：用户拍板后的第二轮——绿地保留，泥地/干草地换新，UI 出两版对比。
## 默认交互运行；带 --shot 参数则截图到 tmp/style_demo_shot.png 后退出。
##
## 布局（1280x720）：
## - 地面：meadow 满铺 + 左上 grove 密林 + 右上 drygrass 干草 + 右下 dirt 泥地矿区
## - UI A（左上/底部）：奶油细框面板 + 三态按钮
## - UI B（右上）：深蓝纹理面板 + 三态按钮

const MeadowTex := preload("res://assets/terrain_textures/ground_meadow.png")
const GroveTex := preload("res://assets/terrain_textures/ground_grove.png")
const DrygrassTex := preload("res://assets/terrain_textures/ground_drygrass.png")
const DirtTex := preload("res://assets/terrain_textures/ground_dirt.png")
const PanelLight := preload("res://assets/ui_textures/ui_panel_light.png")
const PanelDark := preload("res://assets/ui_textures/ui_panel_dark.png")
const BtnLight := [
	preload("res://assets/ui_textures/ui_button_light_normal.png"),
	preload("res://assets/ui_textures/ui_button_light_hover.png"),
	preload("res://assets/ui_textures/ui_button_light_pressed.png"),
]
const BtnDark := [
	preload("res://assets/ui_textures/ui_button_dark_normal.png"),
	preload("res://assets/ui_textures/ui_button_dark_hover.png"),
	preload("res://assets/ui_textures/ui_button_dark_pressed.png"),
]

const SoldierScene := preload("res://scenes/units/soldier.tscn")
const ArcherScene := preload("res://scenes/units/archer.tscn")
const MonkScene := preload("res://scenes/units/monk.tscn")
const CastleScene := preload("res://scenes/buildings/castle.tscn")
const BarracksScene := preload("res://scenes/buildings/barracks.tscn")
const TreeScene := preload("res://scenes/environment/tree.tscn")
const BushScene := preload("res://scenes/environment/bush.tscn")
const RockScene := preload("res://scenes/environment/rock.tscn")
const SheepScene := preload("res://scenes/environment/sheep.tscn")


func _ready() -> void:
	var vs := get_viewport_rect().size

	# ---- 地面分层 ----
	_tile_ground(MeadowTex, Rect2(0, 0, vs.x, vs.y), -10)
	_tile_ground(GroveTex, Rect2(-40, -40, 470, 330), -9)
	_tile_ground(DrygrassTex, Rect2(vs.x - 430, -30, 470, 300), -9)
	_tile_ground(DirtTex, Rect2(vs.x - 480, vs.y - 350, 520, 390), -9)

	# ---- 环境 ----
	for pos in [Vector2(60, 60), Vector2(150, 30), Vector2(90, 150), Vector2(260, 80), Vector2(210, 200), Vector2(330, 160)]:
		_place(TreeScene, pos)
	for pos in [Vector2(560, 140), Vector2(700, 90), Vector2(480, 260)]:
		_place(BushScene, pos)
	for pos in [Vector2(640, 520), Vector2(760, 580)]:
		_place(BushScene, pos)
	# 泥地矿区：青灰岩石道具成群落（暖底冷物，跳出可读）
	for pos in [Vector2(vs.x - 440, vs.y - 300), Vector2(vs.x - 330, vs.y - 250), Vector2(vs.x - 420, vs.y - 160), Vector2(vs.x - 240, vs.y - 290), Vector2(vs.x - 300, vs.y - 110), Vector2(vs.x - 180, vs.y - 180), Vector2(vs.x - 460, vs.y - 70)]:
		_place(RockScene, pos)
	# 干草区点缀羊群
	_place(SheepScene, Vector2(vs.x - 340, 90))
	_place(SheepScene, Vector2(vs.x - 280, 140))
	_place(SheepScene, Vector2(vs.x - 370, 180))

	# ---- 建筑 + 编队 ----
	_place(CastleScene, Vector2(180, 560))
	_place(BarracksScene, Vector2(430, 610))
	for i in 3:
		_place(SoldierScene, Vector2(620 + i * 70, 470))
		_place(SoldierScene, Vector2(620 + i * 70, 535))
	for i in 2:
		_place(ArcherScene, Vector2(640 + i * 100, 400))
	_place(MonkScene, Vector2(600, 340))

	# ---- UI 两版同屏 ----
	_build_ui(vs)

	if "--shot" in OS.get_cmdline_args():
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		var img := get_viewport().get_texture().get_image()
		img.save_png("res://tmp/style_demo_shot.png")
		print("[StyleDemo] screenshot -> tmp/style_demo_shot.png ", img.get_size())
		get_tree().quit()


func _tile_ground(tex: Texture2D, rect: Rect2, z: int) -> void:
	var s := Sprite2D.new()
	s.texture = tex
	s.centered = false
	s.position = rect.position
	s.region_enabled = true
	s.region_rect = Rect2(0, 0, rect.size.x, rect.size.y)
	s.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	s.z_index = z
	add_child(s)


func _place(scene: PackedScene, pos: Vector2) -> Node2D:
	var n := scene.instantiate()
	n.position = pos
	add_child(n)
	return n


func _style(tex: Texture2D, margin: int) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = tex
	sb.texture_margin_left = margin
	sb.texture_margin_right = margin
	sb.texture_margin_top = margin
	sb.texture_margin_bottom = margin
	return sb


func _demo_button(text: String, tex: Texture2D, font_col: Color, pressed_col: Color) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(88, 36)
	var sb := _style(tex, 6)
	btn.add_theme_stylebox_override("normal", sb)
	btn.add_theme_stylebox_override("hover", sb)
	btn.add_theme_stylebox_override("pressed", sb)
	btn.add_theme_color_override("font_color", font_col)
	btn.add_theme_color_override("font_hover_color", font_col)
	btn.add_theme_color_override("font_pressed_color", pressed_col)
	return btn


func _build_ui(vs: Vector2) -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	# A 左上：奶油细框（指挥部）
	var pa := PanelContainer.new()
	pa.add_theme_stylebox_override("panel", _style(PanelLight, 7))
	pa.position = Vector2(24, 20)
	layer.add_child(pa)
	var va := VBoxContainer.new()
	va.add_theme_constant_override("separation", 10)
	pa.add_child(va)
	var ta := Label.new()
	ta.text = "A 奶油细框 · 指挥部"
	ta.add_theme_font_size_override("font_size", 20)
	ta.add_theme_color_override("font_color", Color("161c2e"))
	va.add_child(ta)
	var ra := HBoxContainer.new()
	ra.add_theme_constant_override("separation", 12)
	va.add_child(ra)
	for i in 3:
		ra.add_child(_demo_button(["出兵", "悬停", "按下"][i], BtnLight[i], Color("161c2e"), Color("5a4638")))

	# B 右上：深蓝纹理（金币）
	var pb := PanelContainer.new()
	pb.add_theme_stylebox_override("panel", _style(PanelDark, 6))
	pb.position = Vector2(vs.x - 250, 20)
	layer.add_child(pb)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 8)
	pb.add_child(vb)
	var tb := Label.new()
	tb.text = "B 深蓝纹理 · 金币 1250"
	tb.add_theme_font_size_override("font_size", 18)
	tb.add_theme_color_override("font_color", Color("f2edd3"))
	vb.add_child(tb)
	var rb := HBoxContainer.new()
	rb.add_theme_constant_override("separation", 10)
	vb.add_child(rb)
	for i in 3:
		rb.add_child(_demo_button(["购买", "悬停", "按下"][i], BtnDark[i], Color("f2edd3"), Color("a8b2cc")))

	# 底部：A 风格训练队列（贴近实战占位）
	var bottom := PanelContainer.new()
	bottom.add_theme_stylebox_override("panel", _style(PanelLight, 7))
	bottom.position = Vector2(vs.x / 2 - 170, vs.y - 84)
	layer.add_child(bottom)
	var q := Label.new()
	q.text = "军营 · 训练队列：战士 ×2   弓手 ×1"
	q.add_theme_font_size_override("font_size", 18)
	q.add_theme_color_override("font_color", Color("161c2e"))
	bottom.add_child(q)
