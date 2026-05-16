extends Control

# === 素材路径常量 ===
const PATH_BANNER := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Banners/Banner.png"
const PATH_WOOD_TABLE := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Wood Table/WoodTable.png"
const PATH_SPECIAL_PAPER := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Papers/SpecialPaper.png"
const PATH_BTN_BLUE_REG := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigBlueButton_Regular.png"
const PATH_BTN_BLUE_PRS := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigBlueButton_Pressed.png"
const PATH_BTN_RED_REG := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigRedButton_Regular.png"
const PATH_BTN_RED_PRS := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigRedButton_Pressed.png"
const PATH_SMALL_RIBBONS := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Ribbons/SmallRibbons.png"
const PATH_ICON_01 := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_01.png"
const PATH_ICON_02 := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_02.png"
const PATH_ICON_03 := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_03.png"
const PATH_ICON_04 := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Icons/Icon_04.png"

# === 关卡数据 ===
var levels := [
	{
		"name": "Map 1: Blitz",
		"desc": "No base, no gold. Capture strongpoints to reinforce and push forward!",
		"scene": "res://scenes/maps/map_1.tscn",
		"icon": PATH_ICON_01,
		"ribbon_row": 0,
	},
	{
		"name": "Map 2: Basic Attack",
		"desc": "Build your base, train your army, and destroy the enemy castle!",
		"scene": "res://scenes/maps/map_2.tscn",
		"icon": PATH_ICON_02,
		"ribbon_row": 2,
	},
	{
		"name": "Map 3: Tower Defense",
		"desc": "Survive 3 waves of enemy attacks! Build defenses and hold your ground.",
		"scene": "res://scenes/maps/map_3.tscn",
		"icon": PATH_ICON_03,
		"ribbon_row": 4,
	},
	{
		"name": "Map 4: Expand & Defend",
		"desc": "Capture 4 neutral camps while defending against waves of enemies!",
		"scene": "res://scenes/maps/map_4.tscn",
		"icon": PATH_ICON_04,
		"ribbon_row": 6,
	},
]

# === UI 引用 ===
var selected_index: int = -1
var button_backgrounds: Array[NinePatchRect] = []
var button_labels: Array[Label] = []
var right_title: Label
var right_desc: Label
var right_icon: TextureRect
var right_ribbon: NinePatchRect
var start_button_bg: NinePatchRect

# === 预处理的九宫格纹理（去除透明间隙后的连续纹理）===
var np_banner: Dictionary
var np_wood_table: Dictionary
var np_paper: Dictionary
var np_btn_blue: Dictionary
var np_btn_blue_prs: Dictionary
var np_btn_red: Dictionary
var np_btn_red_prs: Dictionary

# ============================================================
# 九宫格纹理预处理：从精灵图裁剪9个tile并拼合成连续纹理
# ============================================================
# content_rows/cols: [[start, end], [start, end], [start, end]]
# start/end 是像素坐标（包含端点）
func _process_ninepatch(source_path: String, content_rows: Array, content_cols: Array) -> Dictionary:
	var source_tex: Texture2D = load(source_path)
	var img: Image = source_tex.get_image()

	var tw := [
		content_cols[0][1] - content_cols[0][0] + 1,
		content_cols[1][1] - content_cols[1][0] + 1,
		content_cols[2][1] - content_cols[2][0] + 1,
	]
	var th := [
		content_rows[0][1] - content_rows[0][0] + 1,
		content_rows[1][1] - content_rows[1][0] + 1,
		content_rows[2][1] - content_rows[2][0] + 1,
	]

	var new_w: int = tw[0] + tw[1] + tw[2]
	var new_h: int = th[0] + th[1] + th[2]
	var new_img := Image.create(new_w, new_h, false, Image.FORMAT_RGBA8)

	var dst_y: int = 0
	for r in range(3):
		var dst_x: int = 0
		for c in range(3):
			var region := Rect2i(content_cols[c][0], content_rows[r][0], tw[c], th[r])
			var tile := img.get_region(region)
			new_img.blit_rect(tile, Rect2i(Vector2i.ZERO, tile.get_size()), Vector2i(dst_x, dst_y))
			dst_x += tw[c]
		dst_y += th[r]

	return {
		"texture": ImageTexture.create_from_image(new_img),
		"margin_left": tw[0],
		"margin_right": tw[2],
		"margin_top": th[0],
		"margin_bottom": th[2],
	}


# ============================================================
# 初始化
# ============================================================
func _ready() -> void:
	# 预处理所有九宫格纹理（通过 Python 像素分析得到的精确 tile 边界）
	# Banner (448x448): row [60-127, 192-255, 320-430], col [28-127, 192-255, 320-403]
	np_banner = _process_ninepatch(PATH_BANNER,
		[[60, 127], [192, 255], [320, 430]],
		[[28, 127], [192, 255], [320, 403]])

	# WoodTable (448x448): row [43-127, 192-255, 320-422], col [44-127, 192-255, 320-403]
	np_wood_table = _process_ninepatch(PATH_WOOD_TABLE,
		[[43, 127], [192, 255], [320, 422]],
		[[44, 127], [192, 255], [320, 403]])

	# SpecialPaper (320x320): row [20-63, 128-191, 256-298], col [9-63, 128-191, 256-310]
	np_paper = _process_ninepatch(PATH_SPECIAL_PAPER,
		[[20, 63], [128, 191], [256, 298]],
		[[9, 63], [128, 191], [256, 310]])

	# BigBlueButton Regular (320x320): row [17-63, 128-191, 256-302], col [19-63, 128-191, 256-300]
	np_btn_blue = _process_ninepatch(PATH_BTN_BLUE_REG,
		[[17, 63], [128, 191], [256, 302]],
		[[19, 63], [128, 191], [256, 300]])

	# BigBlueButton Pressed (320x320): row [28-63, 128-191, 256-304], col [14-63, 128-191, 256-305]
	np_btn_blue_prs = _process_ninepatch(PATH_BTN_BLUE_PRS,
		[[28, 63], [128, 191], [256, 304]],
		[[14, 63], [128, 191], [256, 305]])

	# BigRedButton Regular (320x320): row [17-63, 128-191, 256-302], col [19-63, 128-191, 256-300]
	np_btn_red = _process_ninepatch(PATH_BTN_RED_REG,
		[[17, 63], [128, 191], [256, 302]],
		[[19, 63], [128, 191], [256, 300]])

	# BigRedButton Pressed (320x320): row [28-63, 128-191, 256-304], col [14-63, 128-191, 256-305]
	np_btn_red_prs = _process_ninepatch(PATH_BTN_RED_PRS,
		[[28, 63], [128, 191], [256, 304]],
		[[14, 63], [128, 191], [256, 305]])

	# 构建 UI（banner 在最底层，不遮挡内容）
	_create_banner()
	_create_main_layout()
	_create_hint_label()
	_select_level(0)


# ============================================================
# 辅助：创建 NinePatchRect 并设置好 margin
# ============================================================
func _make_ninepatch(np: Dictionary) -> NinePatchRect:
	var npr := NinePatchRect.new()
	npr.texture = np.texture
	npr.patch_margin_left = np.margin_left
	npr.patch_margin_right = np.margin_right
	npr.patch_margin_top = np.margin_top
	npr.patch_margin_bottom = np.margin_bottom
	npr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return npr


# ============================================================
# 顶部横幅
# ============================================================
func _create_banner() -> void:
	# 简单文字标题
	var title := Label.new()
	title.text = "SELECT LEVEL"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	title.add_theme_constant_override("shadow_offset_x", 2)
	title.add_theme_constant_override("shadow_offset_y", 2)
	title.anchor_left = 0.0
	title.anchor_right = 1.0
	title.anchor_top = 0.01
	title.anchor_bottom = 0.06
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(title)


# ============================================================
# 主布局容器
# ============================================================
func _create_main_layout() -> void:
	var hbox := HBoxContainer.new()
	hbox.anchor_left = 0.05
	hbox.anchor_right = 0.95
	hbox.anchor_top = 0.10
	hbox.anchor_bottom = 0.93
	hbox.add_theme_constant_override("separation", 20)
	add_child(hbox)

	_create_left_panel(hbox)
	_create_right_panel(hbox)


# ============================================================
# 左侧面板 — 关卡列表
# ============================================================
func _create_left_panel(parent: HBoxContainer) -> void:
	var wrapper := Control.new()
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrapper.size_flags_stretch_ratio = 0.35
	parent.add_child(wrapper)

	# WoodTable 九宫格底板
	var bg := _make_ninepatch(np_wood_table)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wrapper.add_child(bg)

	# 内容容器
	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 20
	vbox.offset_right = -20
	vbox.offset_top = 20
	vbox.offset_bottom = -20
	vbox.add_theme_constant_override("separation", 12)
	wrapper.add_child(vbox)

	for i in range(levels.size()):
		vbox.add_child(_create_level_button(i))

	# 弹性间距，把按钮推到顶部
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)


# ============================================================
# 关卡按钮工厂
# ============================================================
func _create_level_button(index: int) -> Control:
	var wrapper := Control.new()
	wrapper.custom_minimum_size = Vector2(0, 100)

	# 九宫格按钮底板（初始蓝色）
	var bg := _make_ninepatch(np_btn_blue)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wrapper.add_child(bg)
	button_backgrounds.append(bg)

	# 透明 Button 接收鼠标事件
	var btn := Button.new()
	btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var empty_style := StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("normal", empty_style)
	btn.add_theme_stylebox_override("hover", empty_style)
	btn.add_theme_stylebox_override("pressed", empty_style)
	btn.add_theme_stylebox_override("focus", empty_style)
	btn.mouse_entered.connect(_on_button_hover.bind(index))
	btn.mouse_exited.connect(_on_button_unhover.bind(index))
	btn.pressed.connect(_on_button_clicked.bind(index))
	btn.button_down.connect(_on_button_down.bind(index))
	btn.button_up.connect(_on_button_up.bind(index))
	wrapper.add_child(btn)

	# 文字标签
	var label := Label.new()
	label.text = levels[index].name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(1, 1, 1))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrapper.add_child(label)
	button_labels.append(label)

	return wrapper


# ============================================================
# 右侧面板 — 关卡预览
# ============================================================
func _create_right_panel(parent: HBoxContainer) -> void:
	var wrapper := Control.new()
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrapper.size_flags_stretch_ratio = 0.65
	parent.add_child(wrapper)

	# SpecialPaper 九宫格底板
	var bg := _make_ninepatch(np_paper)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wrapper.add_child(bg)

	# 内容容器
	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 30
	vbox.offset_right = -30
	vbox.offset_top = 30
	vbox.offset_bottom = -30
	vbox.add_theme_constant_override("separation", 16)
	wrapper.add_child(vbox)

	# 1) 标题
	right_title = Label.new()
	right_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	right_title.add_theme_font_size_override("font_size", 28)
	right_title.add_theme_color_override("font_color", Color(0.3, 0.2, 0.1))
	vbox.add_child(right_title)

	# 2) 丝带装饰条
	right_ribbon = NinePatchRect.new()
	right_ribbon.custom_minimum_size = Vector2(0, 16)
	right_ribbon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_ribbon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(right_ribbon)

	# 3) 图标占位图
	right_icon = TextureRect.new()
	right_icon.custom_minimum_size = Vector2(128, 128)
	right_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	right_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	right_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	vbox.add_child(right_icon)

	# 4) 描述文字
	right_desc = Label.new()
	right_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	right_desc.add_theme_font_size_override("font_size", 18)
	right_desc.add_theme_color_override("font_color", Color(0.4, 0.35, 0.25))
	right_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right_desc.custom_minimum_size = Vector2(0, 60)
	vbox.add_child(right_desc)

	# 5) 弹性间距
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	# 6) START 按钮
	_create_start_button(vbox)


# ============================================================
# START 按钮
# ============================================================
func _create_start_button(parent: VBoxContainer) -> void:
	var wrapper := Control.new()
	wrapper.custom_minimum_size = Vector2(200, 100)
	wrapper.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	start_button_bg = _make_ninepatch(np_btn_red)
	start_button_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wrapper.add_child(start_button_bg)

	var btn := Button.new()
	btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var empty_style := StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("normal", empty_style)
	btn.add_theme_stylebox_override("hover", empty_style)
	btn.add_theme_stylebox_override("pressed", empty_style)
	btn.add_theme_stylebox_override("focus", empty_style)
	btn.pressed.connect(_on_start_pressed)
	btn.button_down.connect(func(): start_button_bg.texture = np_btn_red_prs.texture)
	btn.button_up.connect(func(): start_button_bg.texture = np_btn_red.texture)
	wrapper.add_child(btn)

	var label := Label.new()
	label.text = "START MISSION"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color(1, 1, 1))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrapper.add_child(label)

	parent.add_child(wrapper)


# ============================================================
# 底部提示
# ============================================================
func _create_hint_label() -> void:
	var hint := Label.new()
	hint.text = "Press Esc to quit"
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	hint.anchor_left = 0.0
	hint.anchor_right = 1.0
	hint.anchor_top = 0.94
	hint.anchor_bottom = 0.98
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(hint)


# ============================================================
# 交互逻辑
# ============================================================
func _select_level(index: int) -> void:
	selected_index = index
	_update_button_appearances()
	_update_right_panel(index)


func _update_button_appearances() -> void:
	for i in range(levels.size()):
		if i == selected_index:
			button_backgrounds[i].texture = np_btn_red.texture
			button_backgrounds[i].patch_margin_left = np_btn_red.margin_left
			button_backgrounds[i].patch_margin_right = np_btn_red.margin_right
			button_backgrounds[i].patch_margin_top = np_btn_red.margin_top
			button_backgrounds[i].patch_margin_bottom = np_btn_red.margin_bottom
			button_labels[i].add_theme_color_override("font_color", Color(1, 1, 0.8))
		else:
			button_backgrounds[i].texture = np_btn_blue.texture
			button_backgrounds[i].patch_margin_left = np_btn_blue.margin_left
			button_backgrounds[i].patch_margin_right = np_btn_blue.margin_right
			button_backgrounds[i].patch_margin_top = np_btn_blue.margin_top
			button_backgrounds[i].patch_margin_bottom = np_btn_blue.margin_bottom
			button_labels[i].add_theme_color_override("font_color", Color(1, 1, 1))


func _update_right_panel(index: int) -> void:
	if index < 0 or index >= levels.size():
		return
	var level: Dictionary = levels[index]
	right_title.text = level.name
	right_desc.text = level.desc
	right_icon.texture = load(level.icon)

	# 更新丝带（从 SmallRibbons 图集提取对应行）
	var ribbon_row: int = int(level.ribbon_row)
	# SmallRibbons 行的 content 区域：交替 60px 和 54px
	# row 0: 4-63(60), row 1: 68-121(54), row 2: 132-191(60), ...
	var ribbon_starts := [4, 68, 132, 196, 260, 324, 388, 452, 516, 580]
	var ribbon_ends := [63, 121, 191, 249, 319, 377, 447, 505, 575, 633]
	if ribbon_row < ribbon_starts.size():
		var rh: int = ribbon_ends[ribbon_row] - ribbon_starts[ribbon_row] + 1
		var ribbon_atlas := AtlasTexture.new()
		ribbon_atlas.atlas = load(PATH_SMALL_RIBBONS)
		# 提取中间列（128-191, 64px 宽）作为丝带纹理
		ribbon_atlas.region = Rect2(128, ribbon_starts[ribbon_row], 64, rh)
		right_ribbon.texture = ribbon_atlas
		right_ribbon.patch_margin_left = 0
		right_ribbon.patch_margin_right = 0
		right_ribbon.patch_margin_top = 0
		right_ribbon.patch_margin_bottom = 0


func _on_button_hover(index: int) -> void:
	_update_right_panel(index)


func _on_button_unhover(_index: int) -> void:
	_update_right_panel(selected_index)


func _on_button_clicked(index: int) -> void:
	_select_level(index)


func _on_button_down(index: int) -> void:
	if index == selected_index:
		button_backgrounds[index].texture = np_btn_red_prs.texture
		button_backgrounds[index].patch_margin_left = np_btn_red_prs.margin_left
		button_backgrounds[index].patch_margin_right = np_btn_red_prs.margin_right
		button_backgrounds[index].patch_margin_top = np_btn_red_prs.margin_top
		button_backgrounds[index].patch_margin_bottom = np_btn_red_prs.margin_bottom
	else:
		button_backgrounds[index].texture = np_btn_blue_prs.texture
		button_backgrounds[index].patch_margin_left = np_btn_blue_prs.margin_left
		button_backgrounds[index].patch_margin_right = np_btn_blue_prs.margin_right
		button_backgrounds[index].patch_margin_top = np_btn_blue_prs.margin_top
		button_backgrounds[index].patch_margin_bottom = np_btn_blue_prs.margin_bottom


func _on_button_up(index: int) -> void:
	if index == selected_index:
		button_backgrounds[index].texture = np_btn_red.texture
		button_backgrounds[index].patch_margin_left = np_btn_red.margin_left
		button_backgrounds[index].patch_margin_right = np_btn_red.margin_right
		button_backgrounds[index].patch_margin_top = np_btn_red.margin_top
		button_backgrounds[index].patch_margin_bottom = np_btn_red.margin_bottom
	else:
		button_backgrounds[index].texture = np_btn_blue.texture
		button_backgrounds[index].patch_margin_left = np_btn_blue.margin_left
		button_backgrounds[index].patch_margin_right = np_btn_blue.margin_right
		button_backgrounds[index].patch_margin_top = np_btn_blue.margin_top
		button_backgrounds[index].patch_margin_bottom = np_btn_blue.margin_bottom


func _on_start_pressed() -> void:
	if selected_index >= 0 and selected_index < levels.size():
		_load_level(levels[selected_index].scene)


func _load_level(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
