extends Node
## UI 模块：底部建造面板（标签页）+ 金币显示 + 放置模式提示 + 波次倒计时 + 暂停菜单

const D := preload("res://scripts/systems/game_data.gd")
const StatSetClass := preload("res://scripts/stats/stat_set.gd")
const UnitScript := preload("res://scripts/units/unit.gd")

# === 素材路径常量 ===
const PATH_WOOD_TABLE := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Wood Table/WoodTable.png"
const PATH_BTN_BLUE_REG := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigBlueButton_Regular.png"
const PATH_BTN_BLUE_PRS := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigBlueButton_Pressed.png"
const PATH_BTN_RED_REG := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigRedButton_Regular.png"
const PATH_BAR_BASE := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Bars/BigBar_Base.png"
const PATH_BAR_FILL := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Bars/BigBar_Fill.png"

signal place_mode_requested(mode: int)
signal restart_requested
signal level_select_requested
signal quit_requested
signal upgrade_button_pressed

# UI 引用
var ui_buttons: Dictionary = {}  # mode -> Control wrapper
var place_mode_label: Label
var gold_label: Label
var upgrade_token_label: Label
var upgrade_token_button: Button
var wave_countdown_label: Label
var panel_bg: NinePatchRect  # 底部面板背景，用于高亮

# 倍速控制
var _game_speed: float = 1.0
const SPEED_OPTIONS: Array[float] = [1.0, 2.0, 4.0]
var _speed_button: Button
var _speed_label: Label
var _speed_wrapper: Control

# 标签页
var active_tab: int = 0  # 0=单位, 1=建筑, 2=信息
var tab_buttons: Array[Button] = []
var unit_container: HBoxContainer
var building_container: HBoxContainer

# 信息面板 (Info tab)
var info_container: HBoxContainer
var _info_count_label: Label
var _info_hp_bar_bg: ColorRect
var _info_hp_bar_fill: ColorRect
var _info_hp_label: Label
var _info_atk_label: Label
var _info_spd_label: Label
var _info_type_container: HBoxContainer
var _tracked_units: Array = []
var _tracked_building = null
var _info_refresh_timer: float = 0.0

# Tooltip
var tooltip_panel: PanelContainer
var tooltip_label: Label
var tooltip_timer: Timer
var tooltip_target_mode: int = -1

# 暂停菜单
var pause_menu_open: bool = false
var pause_canvas: CanvasLayer

var objectives_panel: Node = null
# 选择信息
var selection_info_label: Label
var _pause_overlay: ColorRect  # 用于切换主菜单/设置页

# Key mapping
var key_to_mode: Dictionary = {}

# 分辨率预设
const RESOLUTION_PRESETS: Array[Vector2i] = [
	Vector2i(1280, 720), Vector2i(1366, 768),
	Vector2i(1600, 900), Vector2i(1920, 1080),
]
const RESOLUTION_KEYS: Array[String] = [
	"RES_1280x720", "RES_1366x768", "RES_1600x900", "RES_1920x1080",
]

# 外部引用
var _main_node: Node2D

# 面板矩形（用于相机豁免）
var panel_rect: Rect2

# CanvasLayer 引用（用于 tooltip）
var _ui_canvas: CanvasLayer

# 九宫格纹理
var np_wood_table: Dictionary
var np_btn_blue: Dictionary
var np_btn_blue_prs: Dictionary
var np_btn_red: Dictionary
var np_btn_menu: Dictionary
var np_btn_menu_prs: Dictionary
var np_bar_base: Dictionary
var np_bar_fill: Dictionary

# FPS 显示
var _fps_label: Label

# 设置页引用（用于动态更新）
var _settings_res_option: OptionButton
var _settings_display_mode_option: OptionButton

func initialize(main_node: Node2D, map_config: Resource, gold: int) -> void:
	Engine.time_scale = 1.0
	_game_speed = 1.0
	_main_node = main_node
	_preprocess_textures()
	_create_ui(map_config, gold)
	_create_tooltip()
	_create_pause_menu()
	_create_objectives_panel()


# ============================================================
# 九宫格纹理预处理
# ============================================================
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


func _make_ninepatch(np: Dictionary) -> NinePatchRect:
	var npr := NinePatchRect.new()
	npr.texture = np.texture
	npr.patch_margin_left = np.margin_left
	npr.patch_margin_right = np.margin_right
	npr.patch_margin_top = np.margin_top
	npr.patch_margin_bottom = np.margin_bottom
	npr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return npr


func _preprocess_textures() -> void:
	np_wood_table = _process_ninepatch(PATH_WOOD_TABLE,
		[[43, 127], [192, 255], [320, 422]],
		[[44, 127], [192, 255], [320, 403]])
	np_btn_blue = _process_ninepatch(PATH_BTN_BLUE_REG,
		[[17, 63], [128, 191], [256, 302]],
		[[19, 63], [128, 191], [256, 300]])
	np_btn_blue_prs = _process_ninepatch(PATH_BTN_BLUE_PRS,
		[[28, 63], [128, 191], [256, 304]],
		[[14, 63], [128, 191], [256, 305]])
	np_btn_menu = _process_ninepatch(PATH_BTN_BLUE_REG,
		[[17, 26], [128, 191], [287, 302]],
		[[19, 28], [128, 191], [291, 300]])
	np_btn_menu_prs = _process_ninepatch(PATH_BTN_BLUE_PRS,
		[[28, 37], [128, 191], [294, 304]],
		[[19, 28], [128, 191], [291, 300]])
	np_btn_red = _process_ninepatch(PATH_BTN_RED_REG,
		[[17, 63], [128, 191], [256, 302]],
		[[19, 63], [128, 191], [256, 300]])
	np_bar_base = _process_ninepatch(PATH_BAR_BASE,
		[[6, 31], [128, 159], [256, 281]],
		[[6, 31], [128, 159], [256, 281]])
	np_bar_fill = _process_ninepatch(PATH_BAR_FILL,
		[[6, 31], [128, 159], [256, 281]],
		[[6, 31], [128, 159], [256, 281]])


# ============================================================
# 主 UI 创建
# ============================================================
func _create_ui(map_config: Resource, current_gold: int) -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 10
	_main_node.add_child(canvas)
	_ui_canvas = canvas

	# --- 获取并按固定顺序排序可用物品 ---
	var available_items: Array = []
	if map_config != null and not map_config.available_items.is_empty():
		available_items = map_config.available_items
	else:
		available_items = D.ALL_ITEMS

	var sorted_items: Array = []
	for mode in D.DISPLAY_ORDER:
		if mode in available_items:
			sorted_items.append(mode)

	# 分离单位和建筑
	var unit_modes: Array = []
	var building_modes: Array = []
	for mode in sorted_items:
		if D.is_unit_mode(mode):
			unit_modes.append(mode)
		else:
			building_modes.append(mode)

	# --- 底部建造面板 ---
	var panel_wrapper := Control.new()
	panel_wrapper.anchor_left = 0.1
	panel_wrapper.anchor_right = 0.9
	panel_wrapper.anchor_top = 1.0
	panel_wrapper.anchor_bottom = 1.0
	panel_wrapper.offset_top = -140.0
	panel_wrapper.offset_bottom = -8.0
	panel_wrapper.grow_vertical = Control.GROW_DIRECTION_BEGIN
	canvas.add_child(panel_wrapper)

	# WoodTable 九宫格底板
	panel_bg = _make_ninepatch(np_wood_table)
	panel_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel_wrapper.add_child(panel_bg)

	# 内容区域
	var content := VBoxContainer.new()
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.offset_left = 10
	content.offset_right = -10
	content.offset_top = 6
	content.offset_bottom = -6
	content.add_theme_constant_override("separation", 4)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel_wrapper.add_child(content)

	# --- 标签页行 ---
	var tab_row := HBoxContainer.new()
	tab_row.add_theme_constant_override("separation", 8)
	tab_row.alignment = BoxContainer.ALIGNMENT_CENTER
	tab_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(tab_row)

	# 单位标签
	var BF4 := preload("res://scripts/ui/button_factory.gd")
	var unit_tab := Button.new()
	unit_tab.text = tr("TAB_UNITS")
	unit_tab.custom_minimum_size = Vector2(100, 28)
	unit_tab.toggle_mode = true
	unit_tab.pressed.connect(func(): _switch_tab(0))
	BF4.add_hover_anim_button(unit_tab)
	tab_row.add_child(unit_tab)
	tab_buttons.append(unit_tab)

	# 建筑标签
	var build_tab := Button.new()
	build_tab.text = tr("TAB_BUILDINGS")
	build_tab.custom_minimum_size = Vector2(100, 28)
	build_tab.toggle_mode = true
	build_tab.pressed.connect(func(): _switch_tab(1))
	BF4.add_hover_anim_button(build_tab)
	tab_row.add_child(build_tab)
	tab_buttons.append(build_tab)

	# 信息标签
	var info_tab := Button.new()
	info_tab.text = tr("TAB_INFO")
	info_tab.custom_minimum_size = Vector2(100, 28)
	info_tab.toggle_mode = true
	info_tab.pressed.connect(func(): _switch_tab(2))
	BF4.add_hover_anim_button(info_tab)
	tab_row.add_child(info_tab)
	tab_buttons.append(info_tab)

	# --- 信息面板容器 (Info tab) ---
	info_container = HBoxContainer.new()
	info_container.add_theme_constant_override("separation", 24)
	info_container.alignment = BoxContainer.ALIGNMENT_CENTER
	info_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_container.visible = false
	content.add_child(info_container)

	# 左块: 数量 + 总HP条
	var info_left := HBoxContainer.new()
	info_left.add_theme_constant_override("separation", 8)
	info_left.alignment = BoxContainer.ALIGNMENT_CENTER
	info_left.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_container.add_child(info_left)

	_info_count_label = Label.new()
	_info_count_label.add_theme_font_size_override("font_size", 18)
	_info_count_label.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
	_info_count_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	_info_count_label.add_theme_constant_override("shadow_offset_x", 1)
	_info_count_label.add_theme_constant_override("shadow_offset_y", 1)
	_info_count_label.text = ""
	info_left.add_child(_info_count_label)

	# HP条背景
	var hp_bar_wrapper := Control.new()
	hp_bar_wrapper.custom_minimum_size = Vector2(120, 14)
	hp_bar_wrapper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_left.add_child(hp_bar_wrapper)
	_info_hp_bar_bg = ColorRect.new()
	_info_hp_bar_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_info_hp_bar_bg.color = Color(0.2, 0.2, 0.2, 0.8)
	_info_hp_bar_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hp_bar_wrapper.add_child(_info_hp_bar_bg)
	_info_hp_bar_fill = ColorRect.new()
	_info_hp_bar_fill.anchor_left = 0.0
	_info_hp_bar_fill.anchor_right = 0.0
	_info_hp_bar_fill.anchor_top = 0.0
	_info_hp_bar_fill.anchor_bottom = 1.0
	_info_hp_bar_fill.offset_left = 0.0
	_info_hp_bar_fill.offset_right = 0.0
	_info_hp_bar_fill.color = Color(0.2, 0.8, 0.2)
	_info_hp_bar_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hp_bar_wrapper.add_child(_info_hp_bar_fill)

	_info_hp_label = Label.new()
	_info_hp_label.add_theme_font_size_override("font_size", 14)
	_info_hp_label.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
	_info_hp_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	_info_hp_label.add_theme_constant_override("shadow_offset_x", 1)
	_info_hp_label.add_theme_constant_override("shadow_offset_y", 1)
	_info_hp_label.text = ""
	info_left.add_child(_info_hp_label)

	# 中块: ATK + SPD
	var info_mid := HBoxContainer.new()
	info_mid.add_theme_constant_override("separation", 16)
	info_mid.alignment = BoxContainer.ALIGNMENT_CENTER
	info_mid.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_container.add_child(info_mid)

	_info_atk_label = Label.new()
	_info_atk_label.add_theme_font_size_override("font_size", 14)
	_info_atk_label.add_theme_color_override("font_color", Color(1, 0.6, 0.4))
	_info_atk_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	_info_atk_label.add_theme_constant_override("shadow_offset_x", 1)
	_info_atk_label.add_theme_constant_override("shadow_offset_y", 1)
	_info_atk_label.text = ""
	info_mid.add_child(_info_atk_label)

	_info_spd_label = Label.new()
	_info_spd_label.add_theme_font_size_override("font_size", 14)
	_info_spd_label.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
	_info_spd_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	_info_spd_label.add_theme_constant_override("shadow_offset_x", 1)
	_info_spd_label.add_theme_constant_override("shadow_offset_y", 1)
	_info_spd_label.text = ""
	info_mid.add_child(_info_spd_label)

	# 右块: 分类型明细
	_info_type_container = HBoxContainer.new()
	_info_type_container.add_theme_constant_override("separation", 16)
	_info_type_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_info_type_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_container.add_child(_info_type_container)


	# --- 单位图标容器 ---
	unit_container = HBoxContainer.new()
	unit_container.add_theme_constant_override("separation", 16)
	unit_container.alignment = BoxContainer.ALIGNMENT_CENTER
	unit_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(unit_container)

	# --- 建筑图标容器 ---
	building_container = HBoxContainer.new()
	building_container.add_theme_constant_override("separation", 16)
	building_container.alignment = BoxContainer.ALIGNMENT_CENTER
	building_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(building_container)

	# --- 生成按钮 ---
	for mode in unit_modes:
		_add_icon_button(mode, unit_container)
	for mode in building_modes:
		_add_icon_button(mode, building_container)

	# 默认显示单位页
	_switch_tab(0)

	# --- 金币显示（左上角）---
	gold_label = Label.new()
	gold_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	gold_label.offset_left = 10.0
	gold_label.offset_top = 10.0
	gold_label.add_theme_font_size_override("font_size", 22)
	gold_label.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
	gold_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	gold_label.add_theme_constant_override("shadow_offset_x", 1)
	gold_label.add_theme_constant_override("shadow_offset_y", 1)
	gold_label.text = tr("UI_GOLD") % current_gold
	canvas.add_child(gold_label)

	# --- 升级币按钮（金币下方）---
	var upgrade_wrapper := Control.new()
	upgrade_wrapper.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	upgrade_wrapper.offset_left = 10.0
	upgrade_wrapper.offset_top = 40.0
	upgrade_wrapper.custom_minimum_size = Vector2(120, 28)
	canvas.add_child(upgrade_wrapper)

	var up_bg := _make_ninepatch(np_btn_blue)
	up_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	up_bg.name = "UpgradeButtonBG"
	upgrade_wrapper.add_child(up_bg)

	upgrade_token_label = Label.new()
	upgrade_token_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	upgrade_token_label.offset_left = 4
	upgrade_token_label.offset_right = -4
	upgrade_token_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	upgrade_token_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	upgrade_token_label.add_theme_font_size_override("font_size", 14)
	upgrade_token_label.add_theme_color_override("font_color", Color(0.78, 0.78, 0.78, 1.0))
	upgrade_token_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	upgrade_token_label.text = tr("UPGRADE_TOKENS") % 0
	upgrade_token_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	upgrade_wrapper.add_child(upgrade_token_label)

	upgrade_token_button = Button.new()
	upgrade_token_button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	upgrade_token_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var up_empty := StyleBoxEmpty.new()
	upgrade_token_button.add_theme_stylebox_override("normal", up_empty)
	upgrade_token_button.add_theme_stylebox_override("hover", up_empty)
	upgrade_token_button.add_theme_stylebox_override("pressed", up_empty)
	upgrade_token_button.add_theme_stylebox_override("focus", up_empty)
	upgrade_token_button.disabled = true
	upgrade_token_button.modulate.a = 0.5
	upgrade_token_button.pressed.connect(func(): upgrade_button_pressed.emit())
	upgrade_wrapper.add_child(upgrade_token_button)
	var BF3 := preload("res://scripts/ui/button_factory.gd")
	BF3.add_hover_anim(upgrade_wrapper, up_bg, np_btn_blue_prs.texture, np_btn_blue.texture)

	# --- 放置模式提示（屏幕顶部）---
	place_mode_label = Label.new()
	place_mode_label.anchor_left = 0.5
	place_mode_label.anchor_right = 0.5
	place_mode_label.anchor_top = 0.0
	place_mode_label.anchor_bottom = 0.0
	place_mode_label.offset_top = 10.0
	place_mode_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	place_mode_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	place_mode_label.add_theme_font_size_override("font_size", 18)
	place_mode_label.add_theme_color_override("font_color", Color(1, 0.9, 0.3))
	place_mode_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	place_mode_label.add_theme_constant_override("shadow_offset_x", 1)
	place_mode_label.add_theme_constant_override("shadow_offset_y", 1)
	place_mode_label.visible = false
	canvas.add_child(place_mode_label)

	# --- 波次倒计时（底部面板上方）---
	wave_countdown_label = Label.new()
	wave_countdown_label.anchor_left = 0.5
	wave_countdown_label.anchor_right = 0.5
	wave_countdown_label.anchor_top = 1.0
	wave_countdown_label.anchor_bottom = 1.0
	wave_countdown_label.offset_top = -155.0
	wave_countdown_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	wave_countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wave_countdown_label.add_theme_font_size_override("font_size", 20)
	wave_countdown_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	wave_countdown_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	wave_countdown_label.add_theme_constant_override("shadow_offset_x", 1)
	wave_countdown_label.add_theme_constant_override("shadow_offset_y", 1)
	wave_countdown_label.visible = false
	canvas.add_child(wave_countdown_label)

	# --- 选择信息（底部面板上方）---
	selection_info_label = Label.new()
	selection_info_label.anchor_left = 0.5
	selection_info_label.anchor_right = 0.5
	selection_info_label.anchor_top = 1.0
	selection_info_label.anchor_bottom = 1.0
	selection_info_label.offset_top = -168.0
	selection_info_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	selection_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	selection_info_label.add_theme_font_size_override("font_size", 16)
	selection_info_label.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
	selection_info_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	selection_info_label.add_theme_constant_override("shadow_offset_x", 1)
	selection_info_label.add_theme_constant_override("shadow_offset_y", 1)
	selection_info_label.visible = false
	canvas.add_child(selection_info_label)

	# --- FPS 显示（左上角，金币下方）---
	_fps_label = Label.new()
	_fps_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_fps_label.offset_left = 10.0
	_fps_label.offset_top = 38.0
	_fps_label.add_theme_font_size_override("font_size", 14)
	_fps_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	_fps_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	_fps_label.add_theme_constant_override("shadow_offset_x", 1)
	_fps_label.add_theme_constant_override("shadow_offset_y", 1)
	_fps_label.visible = _main_node.show_fps
	canvas.add_child(_fps_label)

	# --- 小地图（右下角）---
	var minimap_wrapper := Control.new()
	minimap_wrapper.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	minimap_wrapper.offset_left = -186
	minimap_wrapper.offset_top = -186
	minimap_wrapper.offset_right = -6
	minimap_wrapper.offset_bottom = -6
	canvas.add_child(minimap_wrapper)

	var minimap_bg := _make_ninepatch(np_wood_table)
	minimap_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	minimap_wrapper.add_child(minimap_bg)

	var minimap := Control.new()
	minimap.set_script(preload("res://scripts/ui/minimap_panel.gd"))
	minimap.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	minimap.offset_left = 7
	minimap.offset_top = 7
	minimap.offset_right = -7
	minimap.offset_bottom = -7
	minimap_wrapper.add_child(minimap)
	minimap.initialize(_main_node, _main_node.camera_module, _main_node.map_bounds)


	# 将小地图区域注册为相机豁免区域
	var mm_vp := _main_node.get_viewport().get_visible_rect().size
	_main_node.camera_module.ui_exclusion_rects.append(
		Rect2(mm_vp.x - 186, mm_vp.y - 186, 180, 180)
	)
	# --- 倍速按钮（右上角，独立 canvas 确保不被遮挡）---
	var speed_canvas := CanvasLayer.new()
	speed_canvas.layer = 50
	_main_node.add_child(speed_canvas)

	_speed_wrapper = Control.new()
	_speed_wrapper.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	_speed_wrapper.position = Vector2(10, -40)
	_speed_wrapper.size = Vector2(48, 30)
	speed_canvas.add_child(_speed_wrapper)

	var speed_bg := _make_ninepatch(np_btn_blue)
	speed_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_speed_wrapper.add_child(speed_bg)

	_speed_label = Label.new()
	_speed_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_speed_label.offset_left = 4
	_speed_label.offset_right = -4
	_speed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_speed_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_speed_label.add_theme_font_size_override("font_size", 16)
	_speed_label.add_theme_color_override("font_color", Color(1, 0.9, 0.3))
	_speed_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	_speed_label.add_theme_constant_override("shadow_offset_x", 1)
	_speed_label.add_theme_constant_override("shadow_offset_y", 1)
	_speed_label.text = "1x"
	_speed_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_speed_wrapper.add_child(_speed_label)

	_speed_button = Button.new()
	_speed_button.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_speed_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var speed_empty := StyleBoxEmpty.new()
	_speed_button.add_theme_stylebox_override("normal", speed_empty)
	_speed_button.add_theme_stylebox_override("hover", speed_empty)
	_speed_button.add_theme_stylebox_override("pressed", speed_empty)
	_speed_button.add_theme_stylebox_override("focus", speed_empty)
	_speed_button.pressed.connect(_on_speed_button_pressed)
	_speed_wrapper.add_child(_speed_button)
	var BF5 := preload("res://scripts/ui/button_factory.gd")
	BF5.add_hover_anim(_speed_wrapper, speed_bg, np_btn_blue_prs.texture, np_btn_blue.texture)


func _process(delta: float) -> void:
	if _fps_label and _fps_label.visible:
		_fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
	# 信息面板定期刷新
	_info_refresh_timer += delta
	if _info_refresh_timer >= 0.33:
		_info_refresh_timer = 0.0
		_update_info_panel()


func _on_speed_button_pressed() -> void:
	var idx := SPEED_OPTIONS.find(_game_speed)
	var next_idx := (idx + 1) % SPEED_OPTIONS.size()
	set_game_speed(SPEED_OPTIONS[next_idx])

func set_game_speed(speed: float) -> void:
	_game_speed = speed
	Engine.time_scale = speed
	if _speed_label:
		_speed_label.text = "%dx" % int(speed)

func increase_game_speed() -> void:
	var idx := SPEED_OPTIONS.find(_game_speed)
	if idx < SPEED_OPTIONS.size() - 1:
		set_game_speed(SPEED_OPTIONS[idx + 1])

func decrease_game_speed() -> void:
	var idx := SPEED_OPTIONS.find(_game_speed)
	if idx > 0:
		set_game_speed(SPEED_OPTIONS[idx - 1])


# ============================================================
# 图标裁剪工具
# ============================================================
func _make_trimmed_icon(tex: Texture2D) -> AtlasTexture:
	var img: Image = tex.get_image()
	var tw := img.get_width()
	var th := img.get_height()

	var frame_w: int
	var frame_h: int
	if tw > th:
		var frame_count := tw / th
		if frame_count > 0:
			frame_w = tw / frame_count
		else:
			frame_w = tw
		frame_h = th
	else:
		frame_w = tw
		frame_h = th

	var frame_img := img.get_region(Rect2i(0, 0, frame_w, frame_h))
	var bbox: Rect2i = frame_img.get_used_rect()

	if bbox.size.x <= 0 or bbox.size.y <= 0:
		bbox = Rect2i(0, 0, frame_w, frame_h)

	var atlas := AtlasTexture.new()
	atlas.atlas = tex
	atlas.region = Rect2(bbox.position.x, bbox.position.y, bbox.size.x, bbox.size.y)
	return atlas


# ============================================================
# 图标按钮工厂
# ============================================================
func _add_icon_button(mode: int, container: HBoxContainer) -> void:
	var hotkey: Key = D.MODE_HOTKEYS.get(mode, KEY_0)
	var hotkey_index: int = (hotkey - KEY_1 + 1) if hotkey != KEY_0 else 0
	var cost: int = D.COSTS.get(mode, 0)
	var mode_name: String = tr(D.MODE_NAMES.get(mode, "ENTITY_UNIT"))
	var icon_tex: Texture2D = D.ICON_TEXTURES.get(mode, null) as Texture2D

	key_to_mode[hotkey] = mode

	var wrapper := Control.new()
	wrapper.custom_minimum_size = Vector2(80, 80)

	var bg := _make_ninepatch(np_btn_blue)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.name = "ButtonBG"
	wrapper.add_child(bg)

	if icon_tex != null:
		var display_tex: AtlasTexture = _make_trimmed_icon(icon_tex)
		var icon := TextureRect.new()
		icon.texture = display_tex
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		icon.offset_left = 6
		icon.offset_right = -6
		icon.offset_top = 6
		icon.offset_bottom = -6
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		wrapper.add_child(icon)

	var key_label := Label.new()
	key_label.text = str(hotkey_index)
	key_label.add_theme_font_size_override("font_size", 14)
	key_label.add_theme_color_override("font_color", Color(1, 1, 1))
	key_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	key_label.add_theme_constant_override("shadow_offset_x", 1)
	key_label.add_theme_constant_override("shadow_offset_y", 1)
	key_label.anchor_left = 0.0
	key_label.anchor_right = 0.0
	key_label.anchor_top = 0.0
	key_label.anchor_bottom = 0.0
	key_label.offset_left = 4
	key_label.offset_right = 18
	key_label.offset_top = 2
	key_label.offset_bottom = 14
	key_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrapper.add_child(key_label)

	var btn := Button.new()
	btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var empty_style := StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("normal", empty_style)
	btn.add_theme_stylebox_override("hover", empty_style)
	btn.add_theme_stylebox_override("pressed", empty_style)
	btn.add_theme_stylebox_override("focus", empty_style)
	btn.pressed.connect(func(): place_mode_requested.emit(mode))
	var BF2 := preload("res://scripts/ui/button_factory.gd")
	BF2.add_hover_anim(wrapper, bg, np_btn_blue_prs.texture, np_btn_blue.texture)
	btn.mouse_entered.connect(_on_icon_hover.bind(mode))
	btn.mouse_exited.connect(_on_icon_unhover)
	wrapper.add_child(btn)

	container.add_child(wrapper)
	ui_buttons[mode] = wrapper


# ============================================================
# 标签页切换
# ============================================================
func _switch_tab(tab_index: int) -> void:
	active_tab = tab_index
	unit_container.visible = (tab_index == 0)
	building_container.visible = (tab_index == 1)
	if info_container:
		info_container.visible = (tab_index == 2)
		if tab_index == 2:
			_update_info_panel()
	for i in range(tab_buttons.size()):
		tab_buttons[i].button_pressed = (i == tab_index)
	# 活动标签页按钮脉冲动画
	if tab_index < tab_buttons.size():
		var btn := tab_buttons[tab_index]
		btn.scale = Vector2(1.2, 1.2)
		var tween := btn.create_tween()
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


func switch_tab_for_mode(mode: int) -> void:
	if D.is_unit_mode(mode):
		if active_tab != 0:
			_switch_tab(0)
	else:
		if active_tab != 1:
			_switch_tab(1)


func switch_tab(tab_index: int) -> void:
	_switch_tab(tab_index)


# ============================================================
# 建造模式面板高亮
# ============================================================
func set_build_panel_highlight(active: bool) -> void:
	if not panel_bg:
		return
	if active:
		var tween := panel_bg.create_tween()
		tween.tween_property(panel_bg, "modulate", Color(1.2, 1.1, 0.7, 1.0), 0.3).set_ease(Tween.EASE_OUT)
	else:
		var tween := panel_bg.create_tween()
		tween.tween_property(panel_bg, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)


# ============================================================
# F2 全选军队反馈
# ============================================================
func show_army_selected_feedback(count: int) -> void:
	var label := Label.new()
	label.anchor_left = 0.5
	label.anchor_right = 0.5
	label.anchor_top = 1.0
	label.anchor_bottom = 1.0
	label.offset_top = -175.0
	label.offset_bottom = -155.0
	label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.3, 0.7, 1.0))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.text = tr("FEEDBACK_ALL_ARMY") % count
	_ui_canvas.add_child(label)
	var tween := label.create_tween()
	tween.tween_interval(1.0)
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(label.queue_free)


# ============================================================
# Tooltip 系统
# ============================================================
func _create_tooltip() -> void:
	tooltip_timer = Timer.new()
	tooltip_timer.one_shot = true
	tooltip_timer.wait_time = 0.8
	tooltip_timer.timeout.connect(_show_tooltip)
	add_child(tooltip_timer)

	tooltip_panel = PanelContainer.new()
	tooltip_panel.z_index = 100
	tooltip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15, 0.92)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(8)
	tooltip_panel.add_theme_stylebox_override("panel", style)
	tooltip_panel.visible = false
	_ui_canvas.add_child(tooltip_panel)

	tooltip_label = Label.new()
	tooltip_label.add_theme_font_size_override("font_size", 14)
	tooltip_label.add_theme_color_override("font_color", Color(1, 1, 1))
	tooltip_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tooltip_panel.add_child(tooltip_label)


func _on_icon_hover(mode: int) -> void:
	tooltip_target_mode = mode
	tooltip_timer.start()


func _on_icon_unhover() -> void:
	tooltip_timer.stop()
	tooltip_panel.visible = false
	tooltip_target_mode = -1


func _show_tooltip() -> void:
	if tooltip_target_mode < 0:
		return
	var mode: int = tooltip_target_mode
	var mode_name: String = tr(D.MODE_NAMES.get(mode, "?"))
	var cost: int = D.COSTS.get(mode, 0)
	var hotkey: Key = D.MODE_HOTKEYS.get(mode, KEY_0)
	var hotkey_index: int = (hotkey - KEY_1 + 1) if hotkey != KEY_0 else 0
	var type_str: String = tr("TAB_UNITS") if D.is_unit_mode(mode) else tr("TAB_BUILDINGS")

	tooltip_label.text = "%s (%s)\n$%d  [%d]" % [mode_name, type_str, cost, hotkey_index]
	tooltip_panel.visible = true

	var mouse_pos := _main_node.get_viewport().get_mouse_position()
	tooltip_panel.anchor_left = 0.0
	tooltip_panel.anchor_right = 0.0
	tooltip_panel.anchor_top = 0.0
	tooltip_panel.anchor_bottom = 0.0
	tooltip_panel.offset_left = mouse_pos.x - 40
	tooltip_panel.offset_right = mouse_pos.x + 140
	tooltip_panel.offset_top = mouse_pos.y - 55
	tooltip_panel.offset_bottom = mouse_pos.y - 5


# ============================================================
# 更新方法
# ============================================================
func update_selection_info(units: Array, building = null) -> void:
	# 存储追踪数据供 info 面板使用
	_tracked_units = units.duplicate()
	_tracked_building = building
	_info_refresh_timer = 0.0  # 立即刷新

	# 有选中内容时自动切换到 Info 标签页
	if not units.is_empty() or building != null:
		if active_tab != 2:
			_switch_tab(2)
	else:
		# 无选中时切回 Units 页
		if active_tab == 2:
			_switch_tab(0)

	_update_info_panel()

	# 旧的浮动标签（保留兼容）
	if selection_info_label == null:
		return
	if units.is_empty() and building == null:
		selection_info_label.visible = false
		return

	# 旧标签：只显示单位类型统计（建筑不显示）
	if building != null:
		selection_info_label.visible = false
		return

	var type_counts := {}
	for u in units:
		var ut: int = u.unit_type
		var name_key := "ENTITY_SOLDIER"
		match ut:
			0: name_key = "ENTITY_SOLDIER"
			1: name_key = "ENTITY_ARCHER"
			2: name_key = "ENTITY_LANCER"
			3: name_key = "ENTITY_MONK"
		var name_str := tr(name_key)
		if type_counts.has(name_str):
			type_counts[name_str] += 1
		else:
			type_counts[name_str] = 1
	var parts := []
	for name_str in type_counts:
		parts.append("%s x%d" % [name_str, type_counts[name_str]])
	selection_info_label.text = " | ".join(parts) + "  (%d)" % units.size()
	selection_info_label.visible = true

func update_gold_display(current_gold: int) -> void:
	if gold_label:
		gold_label.text = tr("UI_GOLD") % current_gold
	_update_button_affordability(current_gold)


func _update_info_panel() -> void:
	if info_container == null:
		return

	# 清空右侧类型容器
	for c in _info_type_container.get_children():
		c.queue_free()

	# ---- 建筑选择 ----
	if _tracked_building != null and is_instance_valid(_tracked_building) and not _tracked_building.is_dead():
		var b = _tracked_building
		info_container.visible = true
		_info_count_label.text = tr("ENTITY_BUILDING")
		var hp_ratio := float(b.health.hp) / float(b.health.max_hp) if b.health.max_hp > 0 else 0.0
		_info_hp_bar_fill.color = Color(1.0 - hp_ratio * 0.8, 0.2 + hp_ratio * 0.6, 0.2)
		_info_hp_bar_fill.size.x = _info_hp_bar_fill.get_parent().size.x * hp_ratio
		_info_hp_label.text = "%d / %d" % [b.health.hp, b.health.max_hp]
		_info_atk_label.text = ""
		_info_spd_label.text = ""
		return

	# ---- 无选择 ----
	if _tracked_units.is_empty():
		info_container.visible = false
		return

	# ---- 单位选择 ----
	info_container.visible = true
	var total_hp := 0
	var total_max_hp := 0
	var total_atk := 0
	var total_spd := 0.0
	var type_counts := {}
	var count := 0

	for u in _tracked_units:
		if not is_instance_valid(u) or u.is_dead():
			continue
		count += 1
		if u.health:
			total_hp += u.health.hp
			total_max_hp += u.health.max_hp
		if u.stat_set:
			total_atk += u.stat_set.get_int(StatSetClass.ATTACK_DAMAGE)
			total_spd += u.stat_set.get_value(StatSetClass.MOVE_SPEED)
		var name_key := ""
		match u.unit_type:
			UnitScript.UnitType.SOLDIER: name_key = "ENTITY_SOLDIER"
			UnitScript.UnitType.ARCHER: name_key = "ENTITY_ARCHER"
			UnitScript.UnitType.LANCER: name_key = "ENTITY_LANCER"
			UnitScript.UnitType.MONK: name_key = "ENTITY_MONK"
		if not name_key.is_empty():
			var name_str := tr(name_key)
			type_counts[name_str] = type_counts.get(name_str, 0) + 1

	# 数量
	_info_count_label.text = "%d" % count

	# HP 条
	if total_max_hp > 0:
		var hp_ratio := float(total_hp) / float(total_max_hp)
		_info_hp_bar_fill.color = Color(1.0 - hp_ratio * 0.8, 0.2 + hp_ratio * 0.6, 0.2)
		_info_hp_bar_fill.size.x = _info_hp_bar_fill.get_parent().size.x * hp_ratio
	_info_hp_label.text = "%d / %d" % [total_hp, total_max_hp]

	# ATK / SPD（平均值）
	if count > 0:
		_info_atk_label.text = tr("UI_INFO_ATK") % int(total_atk / count)
		_info_spd_label.text = tr("UI_INFO_SPD") % (total_spd / count)
	else:
		_info_atk_label.text = ""
		_info_spd_label.text = ""

	# 右侧：分类型明细
	for name_str in type_counts:
		var lbl := Label.new()
		lbl.text = "%s x%d" % [name_str, type_counts[name_str]]
		lbl.add_theme_font_size_override("font_size", 14)
		lbl.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
		lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
		lbl.add_theme_constant_override("shadow_offset_x", 1)
		lbl.add_theme_constant_override("shadow_offset_y", 1)
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_info_type_container.add_child(lbl)

	# 清理已死亡的单位引用
	_tracked_units = _tracked_units.filter(func(u): return is_instance_valid(u) and not u.is_dead())


func update_upgrade_tokens(tokens: Dictionary) -> void:
	var total := 0
	var best_tier := -1
	var tier_names := {0: tr("UPGRADE_TIER_SILVER"), 1: tr("UPGRADE_TIER_GOLD"), 2: tr("UPGRADE_TIER_DIAMOND")}
	for tier in [2, 1, 0]:  # DIAMOND, GOLD, SILVER
		var count: int = tokens.get(tier, 0)
		total += count
		if count > 0 and best_tier < 0:
			best_tier = tier
	if upgrade_token_label:
		if total <= 0:
			upgrade_token_label.text = tr("UPGRADE_TOKENS") % 0
		else:
			upgrade_token_label.text = "x%d %s" % [total, tier_names.get(best_tier, "")]
	if upgrade_token_button:
		upgrade_token_button.disabled = (total <= 0)
		upgrade_token_button.modulate.a = 1.0 if total > 0 else 0.5


func _update_button_affordability(current_gold: int) -> void:
	for mode in ui_buttons:
		var btn_wrapper: Control = ui_buttons[mode]
		var cost: int = D.COSTS.get(mode, 0)
		var can_afford: bool = current_gold >= cost
		btn_wrapper.modulate.a = 1.0 if can_afford else 0.5
		var btn: Button = btn_wrapper.get_child(btn_wrapper.get_child_count() - 1)
		if btn is Button:
			btn.disabled = not can_afford


func update_wave_countdown(wave_number: int, remaining: float, total: int) -> void:
	if wave_countdown_label == null:
		return
	if remaining <= 0:
		wave_countdown_label.visible = false
		return
	var display_wave := wave_number + 1
	var secs := ceili(remaining)
	wave_countdown_label.text = tr("UI_WAVE_COUNTDOWN") % [display_wave, total, secs]
	wave_countdown_label.visible = true
	if remaining <= 5.0:
		wave_countdown_label.add_theme_color_override("font_color", Color(1, 0.1, 0.1))
	else:
		wave_countdown_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))


func hide_wave_countdown() -> void:
	if wave_countdown_label:
		wave_countdown_label.visible = false


func set_place_mode_text(text: String) -> void:
	if place_mode_label:
		place_mode_label.text = text
		place_mode_label.visible = text != ""


func hide_place_mode_label() -> void:
	if place_mode_label:
		place_mode_label.visible = false


func get_panel_screen_rect() -> Rect2:
	return panel_rect


func update_panel_rect() -> void:
	var vp_size: Vector2 = _main_node.get_viewport().get_visible_rect().size
	panel_rect = Rect2(
		vp_size.x * 0.1,
		vp_size.y - 132.0,
		vp_size.x * 0.8,
		132.0
	)


# ============================================================
# 辅助：创建九宫格风格按钮
# ============================================================
func _make_styled_button(text: String, min_size: Vector2, callback: Callable) -> Control:
	var wrapper := Control.new()
	wrapper.custom_minimum_size = min_size
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var bg := _make_ninepatch(np_btn_menu)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wrapper.add_child(bg)

	var btn := Button.new()
	btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var empty_style := StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("normal", empty_style)
	btn.add_theme_stylebox_override("hover", empty_style)
	btn.add_theme_stylebox_override("pressed", empty_style)
	btn.add_theme_stylebox_override("focus", empty_style)
	btn.pressed.connect(callback)
	wrapper.add_child(btn)

	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(1, 1, 1))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrapper.add_child(label)

	var BF := preload("res://scripts/ui/button_factory.gd")
	BF.add_hover_anim(wrapper, bg, np_btn_menu_prs.texture, np_btn_menu.texture)
	return wrapper


# ============================================================
# 辅助：创建带滑块的一行设置项
# ============================================================
func _make_slider_row(label_text: String, value: float, min_val: float, max_val: float, callback: Callable) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(100, 0)
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
	row.add_child(label)

	var slider := HSlider.new()
	slider.min_value = min_val
	slider.max_value = max_val
	slider.step = 0.01
	slider.value = value
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.custom_minimum_size = Vector2(120, 20)
	slider.value_changed.connect(callback)
	row.add_child(slider)

	var pct := Label.new()
	pct.text = "%d%%" % int(value * 100)
	pct.custom_minimum_size = Vector2(45, 0)
	pct.add_theme_font_size_override("font_size", 14)
	pct.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
	pct.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	slider.value_changed.connect(func(v: float): pct.text = "%d%%" % int(v * 100))
	row.add_child(pct)

	return row


# ============================================================
# 暂停菜单（九宫格风格）
# ============================================================
func _create_pause_menu() -> void:
	pause_canvas = CanvasLayer.new()
	pause_canvas.layer = 100
	pause_canvas.process_mode = Node.PROCESS_MODE_ALWAYS
	_main_node.add_child(pause_canvas)

	var overlay := ColorRect.new()
	overlay.anchor_left = 0.0
	overlay.anchor_right = 1.0
	overlay.anchor_top = 0.0
	overlay.anchor_bottom = 1.0
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_canvas.add_child(overlay)
	_pause_overlay = overlay

	var input_handler := Control.new()
	input_handler.set_script(load("res://scripts/ui/pause_input_handler.gd"))
	input_handler.main_node = _main_node
	input_handler.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	input_handler.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pause_canvas.add_child(input_handler)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.name = "PauseMenuCenter"
	overlay.add_child(center)

	# WoodTable 九宫格面板
	var panel_wrapper := Control.new()
	panel_wrapper.custom_minimum_size = Vector2(300, 460)
	center.add_child(panel_wrapper)

	var bg := _make_ninepatch(np_wood_table)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel_wrapper.add_child(bg)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 30
	vbox.offset_right = -30
	vbox.offset_top = 28
	vbox.offset_bottom = -28
	vbox.add_theme_constant_override("separation", 14)
	panel_wrapper.add_child(vbox)

	var title := Label.new()
	title.text = tr("UI_PAUSED")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	title.add_theme_constant_override("shadow_offset_x", 2)
	title.add_theme_constant_override("shadow_offset_y", 2)
	vbox.add_child(title)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spacer)

	var btn_data := [
		[tr("UI_RESUME"), _close_pause_menu],
		[tr("UI_RESTART"), _on_pause_restart],
		[tr("UI_LEVEL_SELECT"), _on_pause_level_select],
		[tr("UI_SETTINGS"), _open_settings_page],
		[tr("UI_MAIN_MENU"), _on_pause_quit],
	]
	for data in btn_data:
		var btn_wrapper := _make_styled_button(data[0], Vector2(0, 44), data[1])
		vbox.add_child(btn_wrapper)

	var hint := Label.new()
	hint.text = tr("UI_PRESS_ESC_RESUME")
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	vbox.add_child(hint)

	pause_canvas.visible = false


func open_pause_menu() -> void:
	pause_menu_open = true
	pause_canvas.visible = true
	_main_node.get_tree().paused = true


func _close_pause_menu() -> void:
	pause_menu_open = false
	pause_canvas.visible = false
	_main_node.get_tree().paused = false


func _on_pause_restart() -> void:
	_main_node.get_tree().paused = false
	_main_node.get_tree().reload_current_scene()


func _on_pause_level_select() -> void:
	_main_node.get_tree().paused = false
	_main_node.get_tree().change_scene_to_file("res://scenes/level_select.tscn")


func _on_pause_quit() -> void:
	_main_node.get_tree().paused = false
	_main_node.get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


# ============================================================
# 设置回调
# ============================================================
func _save_setting(section: String, key: String, value) -> void:
	var config := ConfigFile.new()
	config.load("user://settings.cfg")
	config.set_value(section, key, value)
	config.save("user://settings.cfg")


func _on_damage_numbers_toggled(pressed: bool) -> void:
	_main_node.show_damage_numbers = pressed
	_save_setting("game", "show_damage_numbers", pressed)


func _on_path_lines_toggled(pressed: bool) -> void:
	Unit.show_path_lines = pressed
	_save_setting("game", "show_path_lines", pressed)


func _on_resolution_selected(index: int) -> void:
	var new_size := RESOLUTION_PRESETS[index]
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_size(new_size)
	_save_setting("display", "resolution_width", new_size.x)
	_save_setting("display", "resolution_height", new_size.y)


func _on_display_mode_selected(index: int) -> void:
	match index:
		0: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		1: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			var config := ConfigFile.new()
			if config.load("user://settings.cfg") == OK:
				var w: int = config.get_value("display", "resolution_width", 1280)
				var h: int = config.get_value("display", "resolution_height", 720)
				DisplayServer.window_set_size(Vector2i(w, h))
	_save_setting("display", "display_mode", index)
	# 分辨率选项仅在窗口模式下可用
	if _settings_res_option:
		_settings_res_option.disabled = (index != 2)


func _on_brightness_changed(value: float) -> void:
	if _main_node.canvas_modulate:
		_main_node.canvas_modulate.color = Color(value, value, value, 1.0)
	_save_setting("display", "brightness", value)


func _on_fps_toggled(pressed: bool) -> void:
	if _fps_label:
		_fps_label.visible = pressed
	_main_node.show_fps = pressed
	_save_setting("display", "show_fps", pressed)


func _on_master_volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))
	AudioServer.set_bus_mute(0, value <= 0.0)
	_save_setting("audio", "master_volume", value)


func _on_music_volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1, linear_to_db(value))
	AudioServer.set_bus_mute(1, value <= 0.0)
	_save_setting("audio", "music_volume", value)


func _on_sfx_volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(2, linear_to_db(value))
	AudioServer.set_bus_mute(2, value <= 0.0)
	_save_setting("audio", "sfx_volume", value)


func _on_camera_sensitivity_changed(value: float) -> void:
	if _main_node.camera_module:
		_main_node.camera_module.speed_multiplier = value
	_save_setting("gameplay", "camera_sensitivity", value)


# ============================================================
# 设置子页面（九宫格风格，分区布局）
# ============================================================
func _open_settings_page() -> void:
	var BF := preload("res://scripts/ui/button_factory.gd")
	# 隐藏暂停主菜单
	for child in _pause_overlay.get_children():
		if child.name == "PauseMenuCenter":
			child.visible = false

	# 加载当前设置
	var config := ConfigFile.new()
	config.load("user://settings.cfg")

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.name = "SettingsPage"
	_pause_overlay.add_child(center)

	# WoodTable 面板
	var panel_wrapper := Control.new()
	panel_wrapper.custom_minimum_size = Vector2(500, 560)
	center.add_child(panel_wrapper)

	var bg := _make_ninepatch(np_wood_table)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel_wrapper.add_child(bg)

	# ScrollContainer 防止内容溢出
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 20
	scroll.offset_right = -20
	scroll.offset_top = 15
	scroll.offset_bottom = -15
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel_wrapper.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(vbox)

	# --- 标题 ---
	var title := Label.new()
	title.text = tr("UI_SETTINGS")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	title.add_theme_constant_override("shadow_offset_x", 2)
	title.add_theme_constant_override("shadow_offset_y", 2)
	vbox.add_child(title)

	var spacer1 := Control.new()
	spacer1.custom_minimum_size = Vector2(0, 6)
	vbox.add_child(spacer1)

	# === 显示区域 ===
	vbox.add_child(_make_section_label(tr("UI_DISPLAY")))

	# 分辨率
	var res_row := HBoxContainer.new()
	res_row.add_theme_constant_override("separation", 8)
	var res_label := Label.new()
	res_label.text = tr("UI_RESOLUTION")
	res_label.custom_minimum_size = Vector2(100, 0)
	res_label.add_theme_font_size_override("font_size", 14)
	res_label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
	res_row.add_child(res_label)
	_settings_res_option = OptionButton.new()
	_settings_res_option.custom_minimum_size = Vector2(160, 30)
	var current_size := DisplayServer.window_get_size()
	var selected_idx := 0
	for i in RESOLUTION_PRESETS.size():
		_settings_res_option.add_item(tr(RESOLUTION_KEYS[i]), i)
		if RESOLUTION_PRESETS[i] == current_size:
			selected_idx = i
	_settings_res_option.selected = selected_idx
	_settings_res_option.item_selected.connect(_on_resolution_selected)
	res_row.add_child(_settings_res_option)
	vbox.add_child(res_row)

	# 显示模式
	var dm_row := HBoxContainer.new()
	dm_row.add_theme_constant_override("separation", 8)
	var dm_label := Label.new()
	dm_label.text = tr("UI_DISPLAY_MODE")
	dm_label.custom_minimum_size = Vector2(100, 0)
	dm_label.add_theme_font_size_override("font_size", 14)
	dm_label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
	dm_row.add_child(dm_label)
	_settings_display_mode_option = OptionButton.new()
	_settings_display_mode_option.add_item(tr("UI_MODE_FULLSCREEN"), 0)
	_settings_display_mode_option.add_item(tr("UI_MODE_BORDERLESS"), 1)
	_settings_display_mode_option.add_item(tr("UI_MODE_WINDOWED"), 2)
	var current_mode := DisplayServer.window_get_mode()
	match current_mode:
		DisplayServer.WINDOW_MODE_FULLSCREEN: _settings_display_mode_option.selected = 0
		DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN: _settings_display_mode_option.selected = 1
		_: _settings_display_mode_option.selected = 2
	_settings_display_mode_option.item_selected.connect(_on_display_mode_selected)
	_settings_res_option.disabled = (current_mode != DisplayServer.WINDOW_MODE_WINDOWED)
	dm_row.add_child(_settings_display_mode_option)
	vbox.add_child(dm_row)

	# 亮度
	var brightness_val: float = config.get_value("display", "brightness", 1.0)
	vbox.add_child(_make_slider_row(tr("UI_BRIGHTNESS"), brightness_val, 0.3, 1.5, _on_brightness_changed))

	# FPS 显示
	var fps_row := HBoxContainer.new()
	fps_row.add_theme_constant_override("separation", 8)
	var fps_label := Label.new()
	fps_label.text = tr("UI_SHOW_FPS")
	fps_label.add_theme_font_size_override("font_size", 14)
	fps_label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
	fps_row.add_child(fps_label)
	var fps_toggle := CheckButton.new()
	fps_toggle.button_pressed = _main_node.show_fps
	fps_toggle.toggled.connect(_on_fps_toggled)
	fps_row.add_child(fps_toggle)
	vbox.add_child(fps_row)

	var spacer2 := Control.new()
	spacer2.custom_minimum_size = Vector2(0, 6)
	vbox.add_child(spacer2)

	# === 音频区域 ===
	vbox.add_child(_make_section_label(tr("UI_AUDIO")))

	var master_val: float = config.get_value("audio", "master_volume", 1.0)
	vbox.add_child(_make_slider_row(tr("UI_MASTER_VOLUME"), master_val, 0.0, 1.0, _on_master_volume_changed))

	var music_val: float = config.get_value("audio", "music_volume", 1.0)
	vbox.add_child(_make_slider_row(tr("UI_MUSIC_VOLUME"), music_val, 0.0, 1.0, _on_music_volume_changed))

	var sfx_val: float = config.get_value("audio", "sfx_volume", 1.0)
	vbox.add_child(_make_slider_row(tr("UI_SFX_VOLUME"), sfx_val, 0.0, 1.0, _on_sfx_volume_changed))

	var spacer3 := Control.new()
	spacer3.custom_minimum_size = Vector2(0, 6)
	vbox.add_child(spacer3)

	# === 游戏区域 ===
	vbox.add_child(_make_section_label(tr("UI_GAMEPLAY")))

	# 伤害飘字
	var dmg_row := HBoxContainer.new()
	dmg_row.add_theme_constant_override("separation", 8)
	var dmg_label := Label.new()
	dmg_label.text = tr("UI_DAMAGE_NUMBERS")
	dmg_label.add_theme_font_size_override("font_size", 14)
	dmg_label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
	dmg_row.add_child(dmg_label)
	var dmg_toggle := CheckButton.new()
	dmg_toggle.button_pressed = _main_node.show_damage_numbers
	dmg_toggle.toggled.connect(_on_damage_numbers_toggled)
	dmg_row.add_child(dmg_toggle)
	vbox.add_child(dmg_row)

	# 寻路路径线
	var path_row := HBoxContainer.new()
	path_row.add_theme_constant_override("separation", 8)
	var path_label := Label.new()
	path_label.text = tr("UI_PATH_LINES")
	path_label.add_theme_font_size_override("font_size", 14)
	path_label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
	path_row.add_child(path_label)
	var path_toggle := CheckButton.new()
	path_toggle.button_pressed = config.get_value("game", "show_path_lines", true)
	path_toggle.toggled.connect(_on_path_lines_toggled)
	path_row.add_child(path_toggle)
	vbox.add_child(path_row)

	# 鼠标灵敏度
	var sens_val: float = config.get_value("gameplay", "camera_sensitivity", 1.0)
	vbox.add_child(_make_slider_row(tr("UI_MOUSE_SENSITIVITY"), sens_val, 0.2, 3.0, _on_camera_sensitivity_changed))

	var spacer4 := Control.new()
	spacer4.custom_minimum_size = Vector2(0, 8)
	vbox.add_child(spacer4)

	# 查看按键绑定按钮
	vbox.add_child(_make_styled_button(tr("UI_VIEW_KEYBINDS"), Vector2(0, 40), _open_keybinds_page))

	# === Language section ===
	var spacer5 := Control.new()
	spacer5.custom_minimum_size = Vector2(0, 6)
	vbox.add_child(spacer5)
	vbox.add_child(_make_section_label(tr("UI_LANGUAGE")))
	var lang_hbox := HBoxContainer.new()
	lang_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	lang_hbox.add_theme_constant_override("separation", 8)
	var _supported_locales := ["en", "zh", "ja"]
	var current_locale := TranslationServer.get_locale()
	for locale_code in _supported_locales:
		var btn := Button.new()
		btn.text = tr("LANG_" + locale_code.to_upper())
		btn.custom_minimum_size = Vector2(90, 28)
		btn.add_theme_font_size_override("font_size", 14)
		btn.set_meta("locale", locale_code)
		btn.add_theme_color_override("font_color", Color(1, 0.85, 0.0) if locale_code == current_locale or locale_code == current_locale.substr(0, 2) else Color(0.8, 0.8, 0.8))
		btn.pressed.connect(_on_settings_language_selected.bind(locale_code))
		lang_hbox.add_child(btn)
		BF.add_hover_anim_button(btn)
	vbox.add_child(lang_hbox)

	# 返回按钮
	vbox.add_child(_make_styled_button(tr("UI_BACK"), Vector2(0, 40), _close_settings_page))


func _make_section_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	return label


func _close_settings_page() -> void:
	for child in _pause_overlay.get_children():
		if child.name == "SettingsPage":
			child.queue_free()
	for child in _pause_overlay.get_children():
		if child.name == "PauseMenuCenter":
			child.visible = true


# ============================================================
# 按键展示子页面（只读）
# ============================================================
func _on_settings_language_selected(locale_code: String) -> void:
	TranslationServer.set_locale(locale_code)
	var config := ConfigFile.new()
	config.load("user://settings.cfg")
	config.set_value("game", "locale", locale_code)
	config.save("user://settings.cfg")
	_close_settings_page()
	_open_settings_page()


func _open_keybinds_page() -> void:
	# 隐藏设置页
	for child in _pause_overlay.get_children():
		if child.name == "SettingsPage":
			child.visible = false

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.name = "KeybindsPage"
	_pause_overlay.add_child(center)

	var panel_wrapper := Control.new()
	panel_wrapper.custom_minimum_size = Vector2(400, 500)
	center.add_child(panel_wrapper)

	var bg := _make_ninepatch(np_wood_table)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel_wrapper.add_child(bg)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 20
	vbox.offset_right = -20
	vbox.offset_top = 15
	vbox.offset_bottom = -15
	vbox.add_theme_constant_override("separation", 6)
	panel_wrapper.add_child(vbox)

	var title := Label.new()
	title.text = tr("UI_KEYBINDS_TITLE")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	title.add_theme_constant_override("shadow_offset_x", 2)
	title.add_theme_constant_override("shadow_offset_y", 2)
	vbox.add_child(title)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	vbox.add_child(spacer)

	# 展示所有快捷键
	var hotkeys: Dictionary = D.MODE_HOTKEYS
	var names: Dictionary = D.MODE_NAMES
	var sorted_modes: Array = D.DISPLAY_ORDER
	for mode in sorted_modes:
		if not hotkeys.has(mode):
			continue
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		row.alignment = BoxContainer.ALIGNMENT_CENTER

		var name_label := Label.new()
		name_label.text = tr(names.get(mode, "?"))
		name_label.add_theme_font_size_override("font_size", 16)
		name_label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
		name_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.4))
		name_label.add_theme_constant_override("shadow_offset_x", 1)
		name_label.add_theme_constant_override("shadow_offset_y", 1)
		name_label.custom_minimum_size = Vector2(120, 0)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(name_label)

		var arrow := Label.new()
		arrow.text = "->"
		arrow.add_theme_font_size_override("font_size", 16)
		arrow.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		row.add_child(arrow)

		var key: Key = hotkeys[mode]
		var key_index: int = (key - KEY_1 + 1) if key != KEY_0 else 0
		var key_label := Label.new()
		key_label.text = str(key_index)
		key_label.add_theme_font_size_override("font_size", 18)
		key_label.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
		key_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.4))
		key_label.add_theme_constant_override("shadow_offset_x", 1)
		key_label.add_theme_constant_override("shadow_offset_y", 1)
		key_label.custom_minimum_size = Vector2(40, 0)
		key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row.add_child(key_label)

		vbox.add_child(row)

	var spacer2 := Control.new()
	spacer2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer2)

	# 返回设置按钮
	vbox.add_child(_make_styled_button(tr("UI_BACK_TO_SETTINGS"), Vector2(0, 40), _close_keybinds_page))


func _close_keybinds_page() -> void:
	for child in _pause_overlay.get_children():
		if child.name == "KeybindsPage":
			child.queue_free()
	for child in _pause_overlay.get_children():
		if child.name == "SettingsPage":
			child.visible = true


func close_pause_menu() -> void:
	_close_pause_menu()

# ============================================================
# 目标面板
# ============================================================

func _create_objectives_panel() -> void:
	if objectives_panel != null:
		return

	objectives_panel = Node.new()
	objectives_panel.set_script(load("res://scripts/ui/objectives_panel.gd"))
	add_child(objectives_panel)
	objectives_panel.initialize(_main_node)
