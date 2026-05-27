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

const SETTINGS_PATH := "user://settings.cfg"
const DifficultyClass := preload("res://scripts/difficulty.gd")

var cursor_manager: Node = null
var _difficulty: int = 1  # 默认 NORMAL
var _difficulty_buttons: Array[Button] = []

# === 关卡数据（翻译键） ===
var levels := [
	{
		"name_key": "LEVEL_1_NAME",
		"desc_key": "LEVEL_1_DESC",
		"scene": "res://scenes/maps/map_1.tscn",
		"icon": PATH_ICON_01,
		"ribbon_row": 0,
	},
	{
		"name_key": "LEVEL_2_NAME",
		"desc_key": "LEVEL_2_DESC",
		"scene": "res://scenes/maps/map_2.tscn",
		"icon": PATH_ICON_02,
		"ribbon_row": 2,
	},
	{
		"name_key": "LEVEL_3_NAME",
		"desc_key": "LEVEL_3_DESC",
		"scene": "res://scenes/maps/map_3.tscn",
		"icon": PATH_ICON_03,
		"ribbon_row": 4,
	},
	{
		"name_key": "LEVEL_4_NAME",
		"desc_key": "LEVEL_4_DESC",
		"scene": "res://scenes/maps/map_4.tscn",
		"icon": PATH_ICON_04,
		"ribbon_row": 6,
	},
]

# === 支持的语言 ===
var _supported_locales := ["en", "zh", "ja"]

# === UI 引用 ===
var selected_index: int = -1
var button_backgrounds: Array[NinePatchRect] = []
var button_labels: Array[Label] = []
var right_title: Label
var right_desc: Label
var right_icon: TextureRect
var right_ribbon: NinePatchRect
var start_button_bg: NinePatchRect
var start_button_label: Label
var _banner_title: Label
var _hint_label: Label
var _lang_buttons: Array[Button] = []

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
	_ensure_translations_loaded()
	_load_language_preference()
	_difficulty = DifficultyClass.load_from_config()

	# 自定义光标
	var CursorManagerScene := preload("res://scenes/cursor_manager.tscn")
	cursor_manager = CursorManagerScene.instantiate()
	add_child(cursor_manager)

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

	# 构建 UI
	_create_banner()
	_create_main_layout()
	_create_hint_label()
	_select_level(0)


# ============================================================
# 语言偏好持久化
# ============================================================
func _load_language_preference() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		var saved_locale: String = config.get_value("game", "locale", "en")
		TranslationServer.set_locale(saved_locale)


func _save_language_preference(locale_code: String) -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value("game", "locale", locale_code)
	config.save(SETTINGS_PATH)


# ============================================================
# 语言切换
# ============================================================
func _on_language_selected(locale_code: String) -> void:
	TranslationServer.set_locale(locale_code)
	_save_language_preference(locale_code)
	_refresh_ui()


func _refresh_ui() -> void:
	_banner_title.text = tr("LEVEL_SELECT_TITLE")
	start_button_label.text = tr("LEVEL_START_MISSION")
	_hint_label.text = tr("LEVEL_PRESS_ESC_QUIT")
	for i in range(levels.size()):
		button_labels[i].text = tr(levels[i].name_key)
	_update_right_panel(selected_index)
	# 更新语言按钮高亮
	var current_locale := TranslationServer.get_locale()
	for btn in _lang_buttons:
		var btn_locale: String = btn.get_meta("locale")
		btn.add_theme_color_override("font_color", Color(1, 0.85, 0.0) if btn_locale == current_locale else Color(0.8, 0.8, 0.8))

	# 更新难度按钮
	var diff_keys := ["DIFFICULTY_EASY", "DIFFICULTY_NORMAL", "DIFFICULTY_HARD"]
	for i in range(_difficulty_buttons.size()):
		_difficulty_buttons[i].text = tr(diff_keys[i])
	_update_difficulty_highlight()


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
# 顶部横幅 + 语言按钮
# ============================================================
func _create_banner() -> void:
	# 标题
	_banner_title = Label.new()
	_banner_title.text = tr("LEVEL_SELECT_TITLE")
	_banner_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner_title.add_theme_font_size_override("font_size", 36)
	_banner_title.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
	_banner_title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	_banner_title.add_theme_constant_override("shadow_offset_x", 2)
	_banner_title.add_theme_constant_override("shadow_offset_y", 2)
	_banner_title.anchor_left = 0.0
	_banner_title.anchor_right = 1.0
	_banner_title.anchor_top = 0.01
	_banner_title.anchor_bottom = 0.06
	_banner_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_banner_title)

	# 语言按钮行
	var lang_hbox := HBoxContainer.new()
	lang_hbox.anchor_left = 0.0
	lang_hbox.anchor_right = 1.0
	lang_hbox.anchor_top = 0.065
	lang_hbox.anchor_bottom = 0.10
	lang_hbox.add_theme_constant_override("separation", 8)
	lang_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(lang_hbox)

	var current_locale := TranslationServer.get_locale()
	for locale_code in _supported_locales:
		var btn := Button.new()
		btn.text = tr("LANG_" + locale_code.to_upper())
		btn.custom_minimum_size = Vector2(90, 28)
		btn.add_theme_font_size_override("font_size", 14)
		btn.set_meta("locale", locale_code)
		if locale_code == current_locale:
			btn.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
		else:
			btn.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		btn.pressed.connect(_on_language_selected.bind(locale_code))
		lang_hbox.add_child(btn)
		_lang_buttons.append(btn)


# ============================================================
# 主布局容器
# ============================================================
func _create_main_layout() -> void:
	var hbox := HBoxContainer.new()
	hbox.anchor_left = 0.05
	hbox.anchor_right = 0.95
	hbox.anchor_top = 0.12
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
	label.text = tr(levels[index].name_key)
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
	right_title.add_theme_color_override("font_color", Color(1, 0.95, 0.8))
	right_title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	right_title.add_theme_constant_override("shadow_offset_x", 1)
	right_title.add_theme_constant_override("shadow_offset_y", 1)
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
	right_desc.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
	right_desc.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	right_desc.add_theme_constant_override("shadow_offset_x", 1)
	right_desc.add_theme_constant_override("shadow_offset_y", 1)
	right_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	right_desc.custom_minimum_size = Vector2(0, 60)
	vbox.add_child(right_desc)

	# 5) 难度选择
	_create_difficulty_selector(vbox)

	# 6) 弹性间距
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

	start_button_label = Label.new()
	start_button_label.text = tr("LEVEL_START_MISSION")
	start_button_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	start_button_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	start_button_label.add_theme_font_size_override("font_size", 22)
	start_button_label.add_theme_color_override("font_color", Color(1, 1, 1))
	start_button_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	start_button_label.add_theme_constant_override("shadow_offset_x", 1)
	start_button_label.add_theme_constant_override("shadow_offset_y", 1)
	start_button_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	start_button_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrapper.add_child(start_button_label)

	parent.add_child(wrapper)


# ============================================================
# 难度选择器
# ============================================================
func _create_difficulty_selector(parent: VBoxContainer) -> void:
	# 标签
	var label := Label.new()
	label.text = tr("DIFFICULTY_LABEL")
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(1, 0.95, 0.8))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	parent.add_child(label)

	# 按钮行
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	parent.add_child(hbox)

	var difficulties := [
		{"key": "DIFFICULTY_EASY", "level": 0},
		{"key": "DIFFICULTY_NORMAL", "level": 1},
		{"key": "DIFFICULTY_HARD", "level": 2},
	]

	for diff in difficulties:
		var btn := Button.new()
		btn.text = tr(diff.key)
		btn.custom_minimum_size = Vector2(90, 28)
		btn.add_theme_font_size_override("font_size", 14)
		btn.set_meta("difficulty_level", diff.level)
		if diff.level == _difficulty:
			btn.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
		else:
			btn.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		btn.pressed.connect(_on_difficulty_selected.bind(diff.level))
		hbox.add_child(btn)
		_difficulty_buttons.append(btn)


func _on_difficulty_selected(level: int) -> void:
	_difficulty = level
	DifficultyClass.save_to_config(level)
	_update_difficulty_highlight()


func _update_difficulty_highlight() -> void:
	for btn in _difficulty_buttons:
		var btn_level: int = btn.get_meta("difficulty_level")
		if btn_level == _difficulty:
			btn.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
		else:
			btn.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))


# ============================================================
# 底部提示
# ============================================================
func _create_hint_label() -> void:
	_hint_label = Label.new()
	_hint_label.text = tr("LEVEL_PRESS_ESC_QUIT")
	_hint_label.add_theme_font_size_override("font_size", 14)
	_hint_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	_hint_label.anchor_left = 0.0
	_hint_label.anchor_right = 1.0
	_hint_label.anchor_top = 0.94
	_hint_label.anchor_bottom = 0.98
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_hint_label)


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
	right_title.text = tr(level.name_key)
	right_desc.text = tr(level.desc_key)
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


# ============================================================
# 手动加载 CSV 翻译文件（不依赖 Godot 自动导入）
# ============================================================
var _translations_loaded := false

func _ensure_translations_loaded() -> void:
	if _translations_loaded:
		return
	_translations_loaded = true
	var csv_path := "res://locales/translations.csv"
	var file := FileAccess.open(csv_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open translations file: " + csv_path)
		return
	var header_line := file.get_line()
	var headers := header_line.split(",")
	if headers.size() < 2:
		push_error("Invalid translations CSV header")
		return
	# headers[0] = "keys", headers[1..] = locale codes
	var locale_codes: PackedStringArray = []
	for i in range(1, headers.size()):
		locale_codes.append(headers[i].strip_edges())
	# 为每种语言创建 Translation 资源
	var translations: Array[Translation] = []
	for locale in locale_codes:
		var t := Translation.new()
		t.locale = locale
		translations.append(t)
	# 逐行读取翻译
	while not file.eof_reached():
		var line := file.get_line()
		if line.strip_edges() == "":
			continue
		var cols := _parse_csv_line(line)
		if cols.size() < 2:
			continue
		var key := cols[0].strip_edges()
		for i in range(locale_codes.size()):
			var col_index := i + 1
			if col_index < cols.size():
				translations[i].add_message(key, cols[col_index].strip_edges())
			else:
				translations[i].add_message(key, key)
	file.close()
	# 注册到 TranslationServer
	for t in translations:
		TranslationServer.add_translation(t)
	print("Translations loaded: ", locale_codes)

## 解析 CSV 行，正确处理双引号包裹的字段（含逗号）
func _parse_csv_line(line: String) -> PackedStringArray:
	var result: PackedStringArray = []
	var current := ""
	var in_quotes := false
	var i := 0
	while i < line.length():
		var ch := line[i]
		if in_quotes:
			if ch == '"':
				if i + 1 < line.length() and line[i + 1] == '"':
					current += '"'
					i += 2
					continue
				else:
					in_quotes = false
			else:
				current += ch
		else:
			if ch == '"':
				in_quotes = true
			elif ch == ',':
				result.append(current)
				current = ""
			else:
				current += ch
		i += 1
	result.append(current)
	return result
