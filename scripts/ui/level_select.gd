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
var _star_labels: Array[Label] = []
var _back_button_bg: NinePatchRect
var _back_button_label: Label

# 通关信息标签
var _completion_status_label: Label
var _completion_time_label: Label
var _completion_play_count_label: Label

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
		{
			"name_key": "LEVEL_5_NAME",
			"desc_key": "LEVEL_5_DESC",
			"scene": "res://scenes/maps/map_5.tscn",
			"icon": PATH_ICON_01,
			"ribbon_row": 1,
		},
		{
			"name_key": "LEVEL_6_NAME",
			"desc_key": "LEVEL_6_DESC",
			"scene": "res://scenes/maps/map_6.tscn",
			"icon": PATH_ICON_02,
			"ribbon_row": 3,
		},
		{
			"name_key": "LEVEL_7_NAME",
			"desc_key": "LEVEL_7_DESC",
			"scene": "res://scenes/maps/map_7.tscn",
			"icon": PATH_ICON_03,
			"ribbon_row": 5,
		},
		{
			"name_key": "LEVEL_8_NAME",
			"desc_key": "LEVEL_8_DESC",
			"scene": "res://scenes/maps/map_8.tscn",
			"icon": PATH_ICON_04,
			"ribbon_row": 7,
		},
		{
			"name_key": "LEVEL_9_NAME",
			"desc_key": "LEVEL_9_DESC",
			"scene": "res://scenes/maps/map_9.tscn",
			"icon": PATH_ICON_01,
			"ribbon_row": 8,
		},
		{
			"name_key": "LEVEL_10_NAME",
			"desc_key": "LEVEL_10_DESC",
			"scene": "res://scenes/maps/map_10.tscn",
			"icon": PATH_ICON_02,
			"ribbon_row": 9,
		},
		{
			"name_key": "LEVEL_11_NAME",
			"desc_key": "LEVEL_11_DESC",
			"scene": "res://scenes/maps/map_11.tscn",
			"icon": PATH_ICON_03,
			"ribbon_row": 0,
		},
		{
			"name_key": "LEVEL_12_NAME",
			"desc_key": "LEVEL_12_DESC",
			"scene": "res://scenes/maps/map_12.tscn",
			"icon": PATH_ICON_04,
			"ribbon_row": 2,
		},
		{
			"name_key": "LEVEL_13_NAME",
			"desc_key": "LEVEL_13_DESC",
			"scene": "res://scenes/maps/map_13.tscn",
			"icon": PATH_ICON_01,
			"ribbon_row": 4,
		},
		{
			"name_key": "LEVEL_14_NAME",
			"desc_key": "LEVEL_14_DESC",
			"scene": "res://scenes/maps/map_14.tscn",
			"icon": PATH_ICON_02,
			"ribbon_row": 6,
		},
		{
			"name_key": "LEVEL_15_NAME",
			"desc_key": "LEVEL_15_DESC",
			"scene": "res://scenes/maps/map_15.tscn",
			"icon": PATH_ICON_03,
			"ribbon_row": 8,
		},
		{
			"name_key": "LEVEL_16_NAME",
			"desc_key": "LEVEL_16_DESC",
			"scene": "res://scenes/maps/map_16.tscn",
			"icon": PATH_ICON_04,
			"ribbon_row": 9,
		},
		{
			"name_key": "LEVEL_17_NAME",
			"desc_key": "LEVEL_17_DESC",
			"scene": "res://scenes/maps/map_17.tscn",
			"icon": PATH_ICON_01,
			"ribbon_row": 1,
		},
		{
			"name_key": "LEVEL_18_NAME",
			"desc_key": "LEVEL_18_DESC",
			"scene": "res://scenes/maps/map_18.tscn",
			"icon": PATH_ICON_02,
			"ribbon_row": 3,
		},
		{
			"name_key": "LEVEL_19_NAME",
			"desc_key": "LEVEL_19_DESC",
			"scene": "res://scenes/maps/map_19.tscn",
			"icon": PATH_ICON_03,
			"ribbon_row": 5,
		},
		{
			"name_key": "LEVEL_20_NAME",
			"desc_key": "LEVEL_20_DESC",
			"scene": "res://scenes/maps/map_20.tscn",
			"icon": PATH_ICON_04,
			"ribbon_row": 7,
		},
	]

# === 测试关卡数据 ===
var test_levels := [
	{"name_key": "TEST_T1_NAME", "desc_key": "TEST_T1_DESC", "scene": "res://scenes/maps/test_vip_survival.tscn"},
	{"name_key": "TEST_T2_NAME", "desc_key": "TEST_T2_DESC", "scene": "res://scenes/maps/test_assassinate.tscn"},
	{"name_key": "TEST_T3_NAME", "desc_key": "TEST_T3_DESC", "scene": "res://scenes/maps/test_destroy_buildings.tscn"},
	{"name_key": "TEST_T4_NAME", "desc_key": "TEST_T4_DESC", "scene": "res://scenes/maps/test_protect_building.tscn"},
	{"name_key": "TEST_T5_NAME", "desc_key": "TEST_T5_DESC", "scene": "res://scenes/maps/test_kill_count.tscn"},
	{"name_key": "TEST_T6_NAME", "desc_key": "TEST_T6_DESC", "scene": "res://scenes/maps/test_gold_target.tscn"},
	{"name_key": "TEST_T7_NAME", "desc_key": "TEST_T7_DESC", "scene": "res://scenes/maps/test_time_limit.tscn"},
	{"name_key": "TEST_T8_NAME", "desc_key": "TEST_T8_DESC", "scene": "res://scenes/maps/test_survive_timer.tscn"},
	{"name_key": "TEST_T9_NAME", "desc_key": "TEST_T9_DESC", "scene": "res://scenes/maps/test_reach_location.tscn"},
	{"name_key": "TEST_T10_NAME", "desc_key": "TEST_T10_DESC", "scene": "res://scenes/maps/test_composite_and.tscn"},
	{"name_key": "TEST_T11_NAME", "desc_key": "TEST_T11_DESC", "scene": "res://scenes/maps/test_multi_stage.tscn"},
	{"name_key": "TEST_T12_NAME", "desc_key": "TEST_T12_DESC", "scene": "res://scenes/maps/test_territory_score.tscn"},
	{"name_key": "TEST_T13_NAME", "desc_key": "TEST_T13_DESC", "scene": "res://scenes/maps/test_endless.tscn"},
	{"name_key": "TEST_OUTPOST_NAME", "desc_key": "TEST_OUTPOST_DESC", "scene": "res://scenes/maps/map_test_outpost.tscn"},
]

# === 模式切换 ===
var _is_test_mode: bool = false
var _current_levels: Array = []
var _campaign_tab_bg: NinePatchRect
var _campaign_tab_label: Label
var _campaign_tab_wrapper: Control
var _test_tab_bg: NinePatchRect
var _test_tab_label: Label
var _test_tab_wrapper: Control

# === 支持的语言 ===
var _supported_locales := ["en", "zh", "ja"]

# === UI 引用 ===
var selected_index: int = -1
var button_backgrounds: Array[NinePatchRect] = []
var button_wrappers: Array[Control] = []
var button_labels: Array[Label] = []
var button_icons: Array[TextureRect] = []
var right_title: Label
var right_desc: Label
var right_icon: TextureRect
var right_ribbon: NinePatchRect
var start_button_bg: NinePatchRect
var start_button_label: Label
var _banner_title: Label
var _hint_label: Label
var _esc_menu: Control = null

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
	_current_levels = levels
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


func _refresh_ui() -> void:
	_banner_title.text = tr("LEVEL_SELECT_TITLE")
	start_button_label.text = tr("LEVEL_START_MISSION")
	_hint_label.text = tr("LEVEL_HINT_NAV")
	for i in range(_current_levels.size()):
		button_labels[i].text = tr(_current_levels[i].name_key)
	_update_right_panel(selected_index)

	_update_difficulty_highlight()

	# 更新返回按钮文本
	if _back_button_label:
		_back_button_label.text = tr("ESC_BACK_MAIN_MENU")
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
		_banner_title.anchor_bottom = 0.055
		_banner_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(_banner_title)

		# Tab 按钮行
		var tab_row := HBoxContainer.new()
		tab_row.anchor_left = 0.0
		tab_row.anchor_right = 1.0
		tab_row.anchor_top = 0.06
		tab_row.anchor_bottom = 0.10
		tab_row.alignment = BoxContainer.ALIGNMENT_CENTER
		tab_row.add_theme_constant_override("separation", 8)
		tab_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(tab_row)

		var BF := preload("res://scripts/ui/button_factory.gd")

		# 战役 Tab
		_campaign_tab_wrapper = Control.new()
		_campaign_tab_wrapper.custom_minimum_size = Vector2(140, 36)
		_campaign_tab_bg = _make_ninepatch(np_btn_red)
		_campaign_tab_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_campaign_tab_wrapper.add_child(_campaign_tab_bg)
		var campaign_btn := Button.new()
		campaign_btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		campaign_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var es := StyleBoxEmpty.new()
		campaign_btn.add_theme_stylebox_override("normal", es)
		campaign_btn.add_theme_stylebox_override("hover", es)
		campaign_btn.add_theme_stylebox_override("pressed", es)
		campaign_btn.add_theme_stylebox_override("focus", es)
		campaign_btn.pressed.connect(_switch_to_campaign_mode)
		_campaign_tab_wrapper.add_child(campaign_btn)
		_campaign_tab_label = Label.new()
		_campaign_tab_label.text = tr("TAB_CAMPAIGN")
		_campaign_tab_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_campaign_tab_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_campaign_tab_label.add_theme_font_size_override("font_size", 16)
		_campaign_tab_label.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
		_campaign_tab_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
		_campaign_tab_label.add_theme_constant_override("shadow_offset_x", 1)
		_campaign_tab_label.add_theme_constant_override("shadow_offset_y", 1)
		_campaign_tab_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_campaign_tab_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_campaign_tab_wrapper.add_child(_campaign_tab_label)
		BF.add_hover_anim_button(campaign_btn)
		tab_row.add_child(_campaign_tab_wrapper)

		# 测试关卡 Tab
		_test_tab_wrapper = Control.new()
		_test_tab_wrapper.custom_minimum_size = Vector2(140, 36)
		_test_tab_bg = _make_ninepatch(np_btn_blue)
		_test_tab_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_test_tab_wrapper.add_child(_test_tab_bg)
		var test_btn := Button.new()
		test_btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		test_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		var es2 := StyleBoxEmpty.new()
		test_btn.add_theme_stylebox_override("normal", es2)
		test_btn.add_theme_stylebox_override("hover", es2)
		test_btn.add_theme_stylebox_override("pressed", es2)
		test_btn.add_theme_stylebox_override("focus", es2)
		test_btn.pressed.connect(_switch_to_test_mode)
		_test_tab_wrapper.add_child(test_btn)
		_test_tab_label = Label.new()
		_test_tab_label.text = tr("TAB_TEST_LEVELS")
		_test_tab_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_test_tab_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		_test_tab_label.add_theme_font_size_override("font_size", 16)
		_test_tab_label.add_theme_color_override("font_color", Color(1, 1, 1))
		_test_tab_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
		_test_tab_label.add_theme_constant_override("shadow_offset_x", 1)
		_test_tab_label.add_theme_constant_override("shadow_offset_y", 1)
		_test_tab_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_test_tab_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_test_tab_wrapper.add_child(_test_tab_label)
		BF.add_hover_anim_button(test_btn)
		tab_row.add_child(_test_tab_wrapper)


# ============================================================
# 主布局容器
# ============================================================
func _create_main_layout() -> void:
	var hbox := HBoxContainer.new()
	hbox.name = "MainLayout"
	hbox.anchor_left = 0.05
	hbox.anchor_right = 0.95
	hbox.anchor_top = 0.14
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
	wrapper.size_flags_stretch_ratio = 0.38
	parent.add_child(wrapper)

	# WoodTable 九宫格底板
	var bg := _make_ninepatch(np_wood_table)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wrapper.add_child(bg)

	# ScrollContainer 包裹按钮列表
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 20
	scroll.offset_right = -20
	scroll.offset_top = 20
	scroll.offset_bottom = -20
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	wrapper.add_child(scroll)

	# 内容容器
	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 12)
	scroll.add_child(vbox)

	for i in range(_current_levels.size()):
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
		wrapper.custom_minimum_size = Vector2(0, 72)

		# 九宫格按钮底板（初始蓝色）
		var bg := _make_ninepatch(np_btn_blue)
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		wrapper.add_child(bg)
		button_backgrounds.append(bg)
		button_wrappers.append(wrapper)
		wrapper.item_rect_changed.connect(func(): wrapper.pivot_offset = wrapper.size * 0.5)

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

		# 内容行：图标 + 文字
		var content_row := HBoxContainer.new()
		content_row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		content_row.offset_left = 12
		content_row.offset_right = -12
		content_row.offset_top = 8
		content_row.offset_bottom = -8
		content_row.add_theme_constant_override("separation", 8)
		content_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
		wrapper.add_child(content_row)

		# 图标
		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(64, 64)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var icon_path: String = _current_levels[index].get("icon", "")
		if icon_path != "":
			icon.texture = load(icon_path)
		else:
			icon.visible = false
		content_row.add_child(icon)
		button_icons.append(icon)

		# 文字标签
		var label := Label.new()
		label.text = tr(_current_levels[index].name_key)
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 20)
		label.add_theme_color_override("font_color", Color(1, 1, 1))
		label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
		label.add_theme_constant_override("shadow_offset_x", 1)
		label.add_theme_constant_override("shadow_offset_y", 1)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content_row.add_child(label)
		button_labels.append(label)

		return wrapper


# ============================================================
# 右侧面板 — 关卡预览
# ============================================================
func _create_right_panel(parent: HBoxContainer) -> void:
	var wrapper := Control.new()
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	wrapper.size_flags_stretch_ratio = 0.62
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

	# 4.5) 通关信息
	_completion_status_label = Label.new()
	_completion_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_completion_status_label.add_theme_font_size_override("font_size", 16)
	_completion_status_label.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
	_completion_status_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.4))
	_completion_status_label.add_theme_constant_override("shadow_offset_x", 1)
	_completion_status_label.add_theme_constant_override("shadow_offset_y", 1)
	vbox.add_child(_completion_status_label)

	_completion_time_label = Label.new()
	_completion_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_completion_time_label.add_theme_font_size_override("font_size", 15)
	_completion_time_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	_completion_time_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.4))
	_completion_time_label.add_theme_constant_override("shadow_offset_x", 1)
	_completion_time_label.add_theme_constant_override("shadow_offset_y", 1)
	vbox.add_child(_completion_time_label)

	_completion_play_count_label = Label.new()
	_completion_play_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_completion_play_count_label.add_theme_font_size_override("font_size", 14)
	_completion_play_count_label.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))
	_completion_play_count_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.3))
	_completion_play_count_label.add_theme_constant_override("shadow_offset_x", 1)
	_completion_play_count_label.add_theme_constant_override("shadow_offset_y", 1)
	vbox.add_child(_completion_play_count_label)

	# 5) 难度选择
	_create_difficulty_selector(vbox)

	# 6) 弹性间距
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)


	# 8) START 按钮
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

	var BF := preload("res://scripts/ui/button_factory.gd")
	BF.add_hover_anim(wrapper, start_button_bg, np_btn_red_prs.texture, np_btn_red.texture)
	# 按钮行：开始 + 返回（战前配置已移至 commander_select 界面）
	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 16)
	btn_row.add_child(wrapper)
	_create_back_button(btn_row)
	parent.add_child(btn_row)



# ============================================================
# 返回主菜单按钮
# ============================================================
func _create_back_button(parent: BoxContainer) -> void:
	var wrapper := Control.new()
	wrapper.custom_minimum_size = Vector2(160, 50)
	wrapper.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	_back_button_bg = _make_ninepatch(np_btn_blue)
	_back_button_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wrapper.add_child(_back_button_bg)

	var btn := Button.new()
	btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var empty_style := StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("normal", empty_style)
	btn.add_theme_stylebox_override("hover", empty_style)
	btn.add_theme_stylebox_override("pressed", empty_style)
	btn.add_theme_stylebox_override("focus", empty_style)
	btn.pressed.connect(_on_back_pressed)
	wrapper.add_child(btn)

	_back_button_label = Label.new()
	_back_button_label.text = tr("ESC_BACK_MAIN_MENU")
	_back_button_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_back_button_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_back_button_label.add_theme_font_size_override("font_size", 16)
	_back_button_label.add_theme_color_override("font_color", Color(1, 1, 1))
	_back_button_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	_back_button_label.add_theme_constant_override("shadow_offset_x", 1)
	_back_button_label.add_theme_constant_override("shadow_offset_y", 1)
	_back_button_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_back_button_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrapper.add_child(_back_button_label)

	var BF2 := preload("res://scripts/ui/button_factory.gd")
	BF2.add_hover_anim(wrapper, _back_button_bg, np_btn_blue_prs.texture, np_btn_blue.texture)
	parent.add_child(wrapper)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


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

		# 星星行
		var hbox := HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 4)
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		parent.add_child(hbox)

		for i in range(3):
			var star_wrapper := Control.new()
			star_wrapper.custom_minimum_size = Vector2(40, 40)
			hbox.add_child(star_wrapper)

			var star_btn := Button.new()
			star_btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			star_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			var es := StyleBoxEmpty.new()
			star_btn.add_theme_stylebox_override("normal", es)
			star_btn.add_theme_stylebox_override("hover", es)
			star_btn.add_theme_stylebox_override("pressed", es)
			star_btn.add_theme_stylebox_override("focus", es)
			star_btn.pressed.connect(_on_difficulty_selected.bind(i))
			star_wrapper.add_child(star_btn)

			var star_label := Label.new()
			star_label.text = "★"
			star_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			star_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			star_label.add_theme_font_size_override("font_size", 28)
			star_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			star_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			star_wrapper.add_child(star_label)
			_star_labels.append(star_label)

			var BF4 := preload("res://scripts/ui/button_factory.gd")
			BF4.add_hover_anim_button(star_btn)

		_update_difficulty_highlight()


func _on_difficulty_selected(level: int) -> void:
		_difficulty = level
		DifficultyClass.save_to_config(level)
		_update_difficulty_highlight()


func _update_difficulty_highlight() -> void:
	for i in range(_star_labels.size()):
		if i <= _difficulty:
			_star_labels[i].add_theme_color_override("font_color", Color(1, 0.85, 0.0))
		else:
			_star_labels[i].add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))

# ============================================================
# 底部提示
# ============================================================
func _create_hint_label() -> void:
	_hint_label = Label.new()
	_hint_label.text = tr("LEVEL_HINT_NAV")
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


func _is_level_locked(index: int) -> bool:
	if _is_test_mode:
		return false
	var sm := _get_save_manager()
	if not sm:
		return false
	return not sm.is_level_unlocked(sm.get_current_data(), index)


func _update_button_appearances() -> void:
	for i in range(button_backgrounds.size()):
		if not _is_test_mode and _is_level_locked(i):
			button_backgrounds[i].texture = np_btn_blue.texture
			button_backgrounds[i].patch_margin_left = np_btn_blue.margin_left
			button_backgrounds[i].patch_margin_right = np_btn_blue.margin_right
			button_backgrounds[i].patch_margin_top = np_btn_blue.margin_top
			button_backgrounds[i].patch_margin_bottom = np_btn_blue.margin_bottom
			button_backgrounds[i].modulate = Color(0.4, 0.4, 0.4, 1.0)
			button_labels[i].add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		elif i == selected_index:
			button_backgrounds[i].texture = np_btn_red.texture
			button_backgrounds[i].patch_margin_left = np_btn_red.margin_left
			button_backgrounds[i].patch_margin_right = np_btn_red.margin_right
			button_backgrounds[i].patch_margin_top = np_btn_red.margin_top
			button_backgrounds[i].patch_margin_bottom = np_btn_red.margin_bottom
			button_backgrounds[i].modulate = Color(1, 1, 1, 1)
			button_labels[i].add_theme_color_override("font_color", Color(1, 1, 0.8))
		else:
			button_backgrounds[i].texture = np_btn_blue.texture
			button_backgrounds[i].patch_margin_left = np_btn_blue.margin_left
			button_backgrounds[i].patch_margin_right = np_btn_blue.margin_right
			button_backgrounds[i].patch_margin_top = np_btn_blue.margin_top
			button_backgrounds[i].patch_margin_bottom = np_btn_blue.margin_bottom
			button_backgrounds[i].modulate = Color(1, 1, 1, 1)
			button_labels[i].add_theme_color_override("font_color", Color(1, 1, 1))


func _update_right_panel(index: int) -> void:
	if index < 0 or index >= _current_levels.size():
		return
	var level: Dictionary = _current_levels[index]
	if not _is_test_mode and _is_level_locked(index):
		right_title.text = tr(level.name_key)
		right_desc.text = tr("LEVEL_LOCKED_DESC")
		if level.has("icon") and level.icon:
			right_icon.texture = load(level.icon)
		right_icon.modulate = Color(0.4, 0.4, 0.4)
		_completion_status_label.text = ""
		_completion_time_label.text = ""
		_completion_play_count_label.text = ""
		start_button_bg.modulate = Color(0.5, 0.5, 0.5)
		return
	right_icon.modulate = Color(1, 1, 1)
	start_button_bg.modulate = Color(1, 1, 1)
	right_title.text = tr(level.name_key)
	right_desc.text = tr(level.desc_key)

	# 图标：测试关卡无 icon，用默认图标
	if level.has("icon") and level.icon:
		right_icon.texture = load(level.icon)
	else:
		right_icon.texture = load(PATH_ICON_01)

	# 通关信息（测试关卡不显示）
	if _is_test_mode:
		_completion_status_label.text = ""
		_completion_time_label.text = ""
		_completion_play_count_label.text = ""
	else:
		var sm := _get_save_manager()
		var level_id := "map_%d" % (index + 1)
		var save_data: Dictionary = sm.get_current_data()
		var lvl_data: Dictionary = save_data.get("levels", {}).get(level_id, {})
		if lvl_data.get("completed", false):
			var score_val: int = sm.get_level_score_value(level_id)
			_completion_status_label.text = tr("SAVE_COMPLETED") + "  " + tr("SAVE_SCORE_EARNED") % score_val
			var best_time = lvl_data.get("best_time_seconds")
			if best_time != null:
				_completion_time_label.text = tr("SAVE_BEST_TIME") % sm.format_time(float(best_time))
			else:
				_completion_time_label.text = ""
			_completion_play_count_label.text = tr("SAVE_PLAY_COUNT") % int(lvl_data.get("play_count", 0))
		else:
			_completion_status_label.text = ""
			_completion_time_label.text = ""
			_completion_play_count_label.text = tr("SAVE_PLAY_COUNT") % int(lvl_data.get("play_count", 0))

	# 更新丝带（从 SmallRibbons 图集提取对应行，测试关卡用第一行）
	var ribbon_row: int = int(level.get("ribbon_row", 0))
	var ribbon_starts := [4, 68, 132, 196, 260, 324, 388, 452, 516, 580]
	var ribbon_ends := [63, 121, 191, 249, 319, 377, 447, 505, 575, 633]
	if ribbon_row < ribbon_starts.size():
		var rh: int = ribbon_ends[ribbon_row] - ribbon_starts[ribbon_row] + 1
		var ribbon_atlas := AtlasTexture.new()
		ribbon_atlas.atlas = load(PATH_SMALL_RIBBONS)
		ribbon_atlas.region = Rect2(128, ribbon_starts[ribbon_row], 64, rh)
		right_ribbon.texture = ribbon_atlas
		right_ribbon.patch_margin_left = 0
		right_ribbon.patch_margin_right = 0
		right_ribbon.patch_margin_top = 0
		right_ribbon.patch_margin_bottom = 0


func _on_button_hover(index: int) -> void:
	if index >= button_backgrounds.size():
		return
	if not _is_test_mode and _is_level_locked(index):
		return
	if index < button_wrappers.size(): button_wrappers[index].scale = Vector2(1.08, 1.08)
	_update_right_panel(index)



func _on_button_unhover(_index: int) -> void:
	if _index >= button_backgrounds.size():
		return
	if _index < button_wrappers.size(): button_wrappers[_index].scale = Vector2(1.0, 1.0)
	_update_right_panel(selected_index)


func _on_button_clicked(index: int) -> void:
	if index >= button_backgrounds.size():
		return
	if not _is_test_mode and _is_level_locked(index):
		return
	_select_level(index)



func _on_button_down(index: int) -> void:
	if index >= button_backgrounds.size():
		return
	if index < button_wrappers.size(): button_wrappers[index].scale = Vector2(0.95, 0.95)
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
	if index >= button_backgrounds.size():
		return
	if index < button_wrappers.size(): button_wrappers[index].scale = Vector2(1.08, 1.08)
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
	if selected_index >= 0 and selected_index < _current_levels.size():
		var level_scene: String = _current_levels[selected_index].scene
		var level_id: String = "map_%d" % (selected_index + 1) if not _is_test_mode else "test"
		# 正式关卡才存档
		if not _is_test_mode:
			var sm := _get_save_manager()
			if sm:
				sm.start_game_session(level_id)
		# 路由到指挥官选择界面（暂存关卡，确认后加载）
		CommanderChoice.set_pending_level(level_scene, level_id)
		get_tree().change_scene_to_file("res://scenes/ui/commander_select.tscn")


func _load_level(scene_path: String) -> void:
	LoadRouter.request_load(scene_path, false)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			if _esc_menu:
				_close_esc_menu()
				return
			_show_esc_menu()
		elif event.keycode == KEY_UP or event.keycode == KEY_W:
			if _esc_menu:
				return
			var new_idx := selected_index
			while new_idx > 0:
				new_idx -= 1
				if _is_test_mode or not _is_level_locked(new_idx):
					_select_level(new_idx)
					break
		elif event.keycode == KEY_DOWN or event.keycode == KEY_S:
			if _esc_menu:
				return
			var new_idx := selected_index
			while new_idx < _current_levels.size() - 1:
				new_idx += 1
				if _is_test_mode or not _is_level_locked(new_idx):
					_select_level(new_idx)
					break
		elif event.keycode == KEY_TAB or event.keycode == KEY_RIGHT or event.keycode == KEY_LEFT:
			if _esc_menu:
				return
			if _is_test_mode:
				_switch_to_campaign_mode()
			else:
				_switch_to_test_mode()
		elif event.keycode == KEY_SPACE or event.keycode == KEY_ENTER:
			if _esc_menu:
				return
			if selected_index >= 0 and selected_index < _current_levels.size():
				if _is_test_mode or not _is_level_locked(selected_index):
					_on_start_pressed()


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


func _show_esc_menu() -> void:
	_esc_menu = Control.new()
	_esc_menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_esc_menu.mouse_filter = Control.MOUSE_FILTER_STOP

	var overlay := ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_esc_menu.add_child(overlay)

	var panel_wrapper := Control.new()
	panel_wrapper.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel_wrapper.offset_left = -160
	panel_wrapper.offset_right = 160
	panel_wrapper.offset_top = -80
	panel_wrapper.offset_bottom = 80
	_esc_menu.add_child(panel_wrapper)

	var panel_bg := _make_ninepatch(np_paper)
	panel_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel_wrapper.add_child(panel_bg)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 20
	vbox.offset_right = -20
	vbox.offset_top = 16
	vbox.offset_bottom = -16
	vbox.add_theme_constant_override("separation", 16)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel_wrapper.add_child(vbox)

	var resume_wrapper := Control.new()
	resume_wrapper.custom_minimum_size = Vector2(200, 44)
	var resume_bg := _make_ninepatch(np_btn_blue)
	resume_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resume_wrapper.add_child(resume_bg)
	var resume_btn := Button.new()
	resume_btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resume_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var es := StyleBoxEmpty.new()
	resume_btn.add_theme_stylebox_override("normal", es)
	resume_btn.add_theme_stylebox_override("hover", es)
	resume_btn.add_theme_stylebox_override("pressed", es)
	resume_btn.add_theme_stylebox_override("focus", es)
	resume_btn.pressed.connect(_close_esc_menu)
	resume_wrapper.add_child(resume_btn)
	var resume_label := Label.new()
	resume_label.text = tr("ESC_RESUME")
	resume_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	resume_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	resume_label.add_theme_font_size_override("font_size", 18)
	resume_label.add_theme_color_override("font_color", Color(1, 1, 1))
	resume_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	resume_label.add_theme_constant_override("shadow_offset_x", 1)
	resume_label.add_theme_constant_override("shadow_offset_y", 1)
	resume_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resume_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	resume_wrapper.add_child(resume_label)
	var BF := preload("res://scripts/ui/button_factory.gd")
	BF.add_hover_anim(resume_wrapper, resume_bg, np_btn_blue_prs.texture, np_btn_blue.texture)
	vbox.add_child(resume_wrapper)

	var back_wrapper := Control.new()
	back_wrapper.custom_minimum_size = Vector2(200, 44)
	var back_bg := _make_ninepatch(np_btn_red)
	back_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	back_wrapper.add_child(back_bg)
	var back_btn := Button.new()
	back_btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	back_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var es2 := StyleBoxEmpty.new()
	back_btn.add_theme_stylebox_override("normal", es2)
	back_btn.add_theme_stylebox_override("hover", es2)
	back_btn.add_theme_stylebox_override("pressed", es2)
	back_btn.add_theme_stylebox_override("focus", es2)
	back_btn.pressed.connect(_on_esc_back_to_main)
	back_wrapper.add_child(back_btn)
	var back_label := Label.new()
	back_label.text = tr("ESC_BACK_MAIN_MENU")
	back_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	back_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	back_label.add_theme_font_size_override("font_size", 16)
	back_label.add_theme_color_override("font_color", Color(1, 1, 1))
	back_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	back_label.add_theme_constant_override("shadow_offset_x", 1)
	back_label.add_theme_constant_override("shadow_offset_y", 1)
	back_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	back_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	back_wrapper.add_child(back_label)
	var BF2 := preload("res://scripts/ui/button_factory.gd")
	BF2.add_hover_anim(back_wrapper, back_bg, np_btn_red_prs.texture, np_btn_red.texture)
	vbox.add_child(back_wrapper)

	add_child(_esc_menu)


func _close_esc_menu() -> void:
	if _esc_menu:
		_esc_menu.queue_free()
		_esc_menu = null


func _on_esc_back_to_main() -> void:
	_close_esc_menu()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")



func _switch_to_test_mode() -> void:
	_is_test_mode = true
	_current_levels = test_levels
	_update_tab_appearance()
	_rebuild_left_panel()
	_select_level(0)


func _switch_to_campaign_mode() -> void:
	_is_test_mode = false
	_current_levels = levels
	_update_tab_appearance()
	_rebuild_left_panel()
	_select_level(0)


func _update_tab_appearance() -> void:
	if _is_test_mode:
		_test_tab_bg.texture = np_btn_red.texture
		_test_tab_bg.patch_margin_left = np_btn_red.margin_left
		_test_tab_bg.patch_margin_right = np_btn_red.margin_right
		_test_tab_bg.patch_margin_top = np_btn_red.margin_top
		_test_tab_bg.patch_margin_bottom = np_btn_red.margin_bottom
		_test_tab_label.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
		_campaign_tab_bg.texture = np_btn_blue.texture
		_campaign_tab_bg.patch_margin_left = np_btn_blue.margin_left
		_campaign_tab_bg.patch_margin_right = np_btn_blue.margin_right
		_campaign_tab_bg.patch_margin_top = np_btn_blue.margin_top
		_campaign_tab_bg.patch_margin_bottom = np_btn_blue.margin_bottom
		_campaign_tab_label.add_theme_color_override("font_color", Color(1, 1, 1))
	else:
		_campaign_tab_bg.texture = np_btn_red.texture
		_campaign_tab_bg.patch_margin_left = np_btn_red.margin_left
		_campaign_tab_bg.patch_margin_right = np_btn_red.margin_right
		_campaign_tab_bg.patch_margin_top = np_btn_red.margin_top
		_campaign_tab_bg.patch_margin_bottom = np_btn_red.margin_bottom
		_campaign_tab_label.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
		_test_tab_bg.texture = np_btn_blue.texture
		_test_tab_bg.patch_margin_left = np_btn_blue.margin_left
		_test_tab_bg.patch_margin_right = np_btn_blue.margin_right
		_test_tab_bg.patch_margin_top = np_btn_blue.margin_top
		_test_tab_bg.patch_margin_bottom = np_btn_blue.margin_bottom
		_test_tab_label.add_theme_color_override("font_color", Color(1, 1, 1))


func _rebuild_left_panel() -> void:
	# 清空旧的左侧面板按钮
	button_backgrounds.clear()
	button_wrappers.clear()
	button_labels.clear()
	button_icons.clear()

	# 找到主 HBoxContainer（遍历子节点查找）
	var hbox: HBoxContainer = null
	for child in get_children():
		if child.name == "MainLayout":
			hbox = child
			break
	if hbox == null:
		return

	var left_wrapper: Control = hbox.get_child(0)
	if left_wrapper == null:
		return

	# left_wrapper 里有 WoodTable bg 和 ScrollContainer -> VBoxContainer
	var vbox: VBoxContainer = null
	for child in left_wrapper.get_children():
		if child is ScrollContainer:
			for sc_child in child.get_children():
				if sc_child is VBoxContainer:
					vbox = sc_child
					break
			break
	if vbox == null:
		return

	# 清空 VBoxContainer 内容
	for child in vbox.get_children():
		vbox.remove_child(child)
		child.queue_free()

	# 重建按钮
	for i in range(_current_levels.size()):
		vbox.add_child(_create_level_button(i))

	# 弹性间距
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)


func _get_save_manager() -> Node:
	return get_node_or_null("/root/SaveManager")