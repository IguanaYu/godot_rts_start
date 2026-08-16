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
var panel_bg: NinePatchRect  # 底部面板背景，用于高亮

# 倍速控制
var _game_speed: float = 1.0
const SPEED_OPTIONS: Array[float] = [1.0, 2.0, 4.0]
var _speed_button: Button
var _speed_label: Label
var _speed_wrapper: Control

# T2 PR-3: 底部横排 UI 条
var _bottom_bar: Control
var _floating_text_layer: CanvasLayer

# PR-T2-5: 时代锁状态记录（检测 锁→解锁 翻转做高亮闪烁）
var _prev_era_locked: Dictionary = {}

# 标签页
var active_tab: int = 0  # T2 PR-3: 0=单位, 1=建筑, 2=据点（已移除 INFO tab）
var tab_buttons: Array[Button] = []
var unit_container: VBoxContainer  # QW 改造：VBox 包 2 行 HBox，模拟 4×2 Grid
var building_container: VBoxContainer
var outpost_container: VBoxContainer  # PR-4 据点建筑容器
var _grid_rows: Dictionary = {}  # container → [HBox row0, HBox row1]
var unit_modes_ordered: Array = []      # 玩家选中的单位，按显示顺序
var building_modes_ordered: Array = []  # 玩家选中的建筑，按显示顺序

var _tracked_units: Array = []
var _tracked_building = null

# Tooltip
var tooltip_panel: PanelContainer
var tooltip_label: Label
var tooltip_timer: Timer
var tooltip_target_mode: int = -1

# 暂停菜单
var pause_menu_open: bool = false
var pause_canvas: CanvasLayer

# ESC 分层状态跟踪
var _settings_active: bool = false
var _keybinds_active: bool = false

var objectives_panel: Node = null
# 选择信息
var selection_info_label: Label
var _pause_overlay: ColorRect  # 用于切换主菜单/设置页


func get_floating_text_layer() -> CanvasLayer:
	return _floating_text_layer

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

	# 跳字专用 CanvasLayer：盖过底部 UI(10) 和倍速按钮(50)，仅次于暂停菜单(100)
	# 必须挂在 _main_node 下与其它 CanvasLayer 平级，不能挂在 canvas 内（嵌套会失效）
	_floating_text_layer = CanvasLayer.new()
	_floating_text_layer.name = "FloatingTextLayer"
	_floating_text_layer.layer = 15
	_main_node.add_child(_floating_text_layer)

	# T2 PR-3: 底部横排 UI 条（QW + 详情 + 小地图）
	var bottom_bar := preload("res://scripts/ui/bottom_ui_bar.gd").new()
	bottom_bar.name = "BottomUIBar"
	bottom_bar.initialize(_main_node)
	# UI Revamp P1: 统一 WoodTable 背景（覆盖整条底部），替代三段独立底板
	bottom_bar.set_unified_background(np_wood_table)
	canvas.add_child(bottom_bar)
	_bottom_bar = bottom_bar
	# panel_bg 引用迁移到统一背景，供 set_build_panel_highlight() 使用
	panel_bg = bottom_bar.get_unified_background()

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
	# 暴露给 main.gd 做槽位快捷键查询
	unit_modes_ordered = unit_modes
	building_modes_ordered = building_modes

	# --- 底部建造面板 ---
	var panel_wrapper := Control.new()
	panel_wrapper.anchor_left = 0.2
	panel_wrapper.anchor_right = 0.8
	panel_wrapper.anchor_top = 1.0
	panel_wrapper.anchor_bottom = 1.0
	panel_wrapper.offset_top = -140.0
	panel_wrapper.offset_bottom = -8.0
	panel_wrapper.grow_vertical = Control.GROW_DIRECTION_BEGIN
	# T2 PR-3: 嵌入底部 UI 条左段
	_bottom_bar.embed_qw_panel(panel_wrapper)

	# UI Revamp P1: QW 段不再单独加 WoodTable 底板，由 bottom_bar 统一背景提供

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
	unit_tab.text = "TAB_UNITS"
	unit_tab.custom_minimum_size = Vector2(100, 28)
	unit_tab.toggle_mode = true
	unit_tab.pressed.connect(func(): _switch_tab(0))
	BF4.add_hover_anim_button(unit_tab)
	tab_row.add_child(unit_tab)
	tab_buttons.append(unit_tab)

	# 建筑标签
	var build_tab := Button.new()
	build_tab.text = "TAB_BUILDINGS"
	build_tab.custom_minimum_size = Vector2(100, 28)
	build_tab.toggle_mode = true
	build_tab.pressed.connect(func(): _switch_tab(1))
	BF4.add_hover_anim_button(build_tab)
	tab_row.add_child(build_tab)
	tab_buttons.append(build_tab)

	# PR-4 据点标签（占领前隐藏）
	var outpost_tab := Button.new()
	outpost_tab.text = "TAB_OUTPOST"
	outpost_tab.custom_minimum_size = Vector2(100, 28)
	outpost_tab.toggle_mode = true
	outpost_tab.pressed.connect(func(): _switch_tab(2))
	BF4.add_hover_anim_button(outpost_tab)
	outpost_tab.visible = false  # 默认隐藏，占领后 show_outpost_category() 显示
	tab_row.add_child(outpost_tab)
	tab_buttons.append(outpost_tab)

	# --- 单位图标容器（4×2 Grid：VBox 包 2 HBox，槽位 = QWER ASDF）---
	unit_container = _make_grid_4x2()
	content.add_child(unit_container)

	# --- 建筑图标容器 ---
	building_container = _make_grid_4x2()
	content.add_child(building_container)

	# --- PR-4 据点建筑容器（占领前隐藏）---
	outpost_container = _make_grid_4x2()
	outpost_container.visible = false
	content.add_child(outpost_container)

	# --- 生成按钮（按槽位 0-7 分配 GRID_KEYS: Q W E R / A S D F）---
	# 硬上限：每个 Tab 同时显示 ≤ 8 个，超出裁掉并警告（设计约束）
	if unit_modes.size() > D.GRID_MAX_SLOTS:
		push_warning("QW 单位栏超过 %d 个槽位（%d 个），多余将被裁掉" % [D.GRID_MAX_SLOTS, unit_modes.size()])
	if building_modes.size() > D.GRID_MAX_SLOTS:
		push_warning("QW 建筑栏超过 %d 个槽位（%d 个），多余将被裁掉" % [D.GRID_MAX_SLOTS, building_modes.size()])
	for i in range(min(unit_modes.size(), D.GRID_MAX_SLOTS)):
		_add_icon_button(unit_modes[i], unit_container, D.GRID_KEYS[i], i)
	for i in range(min(building_modes.size(), D.GRID_MAX_SLOTS)):
		_add_icon_button(building_modes[i], building_container, D.GRID_KEYS[i], i)
	# PR-4：据点分类的 ALTAR_ARCHER 按钮（占领后才能切到此 tab）
	_add_icon_button(D.PlaceMode.ALTAR_ARCHER, outpost_container, D.GRID_KEYS[0], 0)

	# 默认显示单位页
	_switch_tab(0)

	# --- 资源栏面板（左上角）---
	var resource_panel := PanelContainer.new()
	resource_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	resource_panel.offset_left = 6.0
	resource_panel.offset_top = 6.0
	resource_panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	resource_panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var res_style := StyleBoxFlat.new()
	res_style.bg_color = Color(0, 0, 0, 0.5)
	res_style.set_corner_radius_all(6)
	res_style.set_content_margin_all(10)
	res_style.set_border_width_all(1)
	res_style.border_color = Color(1, 1, 1, 0.08)
	resource_panel.add_theme_stylebox_override("panel", res_style)
	canvas.add_child(resource_panel)

	var res_vbox := VBoxContainer.new()
	res_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	res_vbox.add_theme_constant_override("separation", 6)
	res_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	resource_panel.add_child(res_vbox)

	# 金币显示
	gold_label = Label.new()
	gold_label.add_theme_font_size_override("font_size", 22)
	gold_label.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
	gold_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	gold_label.add_theme_constant_override("shadow_offset_x", 1)
	gold_label.add_theme_constant_override("shadow_offset_y", 1)
	gold_label.text = tr("UI_GOLD") % current_gold
	res_vbox.add_child(gold_label)

	# 科技等级显示（暗线，仅显示当前等级）
	_tech_label = Label.new()
	_tech_label.name = "TechLevelLabel"
	_tech_label.add_theme_font_size_override("font_size", 14)
	_tech_label.add_theme_color_override("font_color", Color(0.3, 0.7, 1.0))
	_tech_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	_tech_label.add_theme_constant_override("shadow_offset_x", 1)
	_tech_label.add_theme_constant_override("shadow_offset_y", 1)
	_tech_label.text = "Tech: 0"
	res_vbox.add_child(_tech_label)

	# PR-3：统一游戏时间 HUD（受加速影响，与波次时间对齐）
	_time_label = Label.new()
	_time_label.name = "GameTimeLabel"
	_time_label.add_theme_font_size_override("font_size", 14)
	_time_label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.95))
	_time_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	_time_label.add_theme_constant_override("shadow_offset_x", 1)
	_time_label.add_theme_constant_override("shadow_offset_y", 1)
	_time_label.text = "Time: 0:00"
	res_vbox.add_child(_time_label)


	# 升级币按钮
	var upgrade_wrapper := Control.new()
	upgrade_wrapper.custom_minimum_size = Vector2(120, 28)
	res_vbox.add_child(upgrade_wrapper)

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

	# FPS 显示
	_fps_label = Label.new()
	_fps_label.add_theme_font_size_override("font_size", 14)
	_fps_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	_fps_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	_fps_label.add_theme_constant_override("shadow_offset_x", 1)
	_fps_label.add_theme_constant_override("shadow_offset_y", 1)
	_fps_label.visible = _main_node.show_fps
	res_vbox.add_child(_fps_label)

	# T2 PR-3: 小地图还原原造型（固定尺寸 + 内部细描边），嵌入底部 UI 条右段
	# UI Revamp P1: 移除独立 WoodTable 底板，由 bottom_bar 统一背景提供木质衬底
	var minimap_wrapper := Control.new()
	minimap_wrapper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# 固定尺寸：172×172 内部小地图 + 7px 边距 × 2 = 186×186（CenterContainer 居中需要明确尺寸）
	minimap_wrapper.custom_minimum_size = Vector2(186, 186)

	var minimap := Control.new()
	minimap.set_script(preload("res://scripts/ui/minimap_panel.gd"))
	minimap.name = "MinimapPanel"
	minimap.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	minimap.offset_left = 7
	minimap.offset_top = 7
	minimap.offset_right = -7
	minimap.offset_bottom = -7
	minimap_wrapper.add_child(minimap)
	minimap.initialize(_main_node, _main_node.camera_module, _main_node.map_bounds)

	_bottom_bar.embed_minimap(minimap_wrapper)

	# 连接 ping 信号到小地图
	AllyCommander.attack_order_issued.connect(_on_attack_ping.bind(minimap))
	AllyCommander.defend_order_issued.connect(_on_defend_ping.bind(minimap))

	# NOTE: 相机豁免矩形已移至 main.gd Step 4（camera_module 创建后），
	# 使用 D.BOTTOM_UI_PX。原在此处（ui_module.initialize 阶段 camera_module 尚为 null）的
	# 228px 豁免块从未生效，已删除。
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
	# PR-3：统一游戏时间 HUD（每帧更新，跟 main._game_time 同步走加速）
	if _time_label and _main_node and _main_node.has_method("get_game_time"):
		var t: float = _main_node.get_game_time()
		var m := int(t) / 60
		var s := int(t) % 60
		_time_label.text = "Time: %d:%02d" % [m, s]
	# T2 PR-3: 信息面板已迁移到详情面板，不再需要定期刷新


## PR-3：暴露 MinimapPanel 引用给 main.gd（wave_warning_triggered 时打红点）
func get_minimap() -> Node:
	if _ui_canvas == null:
		return null
	return _ui_canvas.find_child("MinimapPanel", true, false)


## PR-4：据点占领后调用，显示据点分类 tab 按钮
func show_outpost_category() -> void:
	# T2 PR-3: tab_buttons 顺序: [0]unit [1]building [2]outpost（已移除 INFO tab）
	if tab_buttons.size() > 2:
		tab_buttons[2].visible = true


## PR-4 修复：祭坛建完后据点 tab 无剩余内容 → 隐藏；若正停在该 tab 则退回建筑 tab
func hide_outpost_category() -> void:
	if tab_buttons.size() > 2:
		tab_buttons[2].visible = false
	if active_tab == 2:
		_switch_tab(1)




func _on_attack_ping(world_pos: Vector2, minimap: Control) -> void:
	if not is_instance_valid(minimap):
		return
	minimap.send_ping(world_pos, Color(1.0, 0.4, 0.3), MinimapMarkerData.Shape.CROSS, 1.5)


func _on_defend_ping(world_pos: Vector2, minimap: Control) -> void:
	if not is_instance_valid(minimap):
		return
	minimap.send_ping(world_pos, Color(0.4, 0.8, 1.0), MinimapMarkerData.Shape.CROSS, 1.5)



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

# QW 改造：构造 4×2 网格容器（VBox 包 2 个 HBox，避免 GridContainer 拉伸子节点到 90×94 撑破 QW 段）
func _make_grid_4x2() -> VBoxContainer:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var row0 := HBoxContainer.new()
	row0.add_theme_constant_override("separation", 8)
	row0.alignment = BoxContainer.ALIGNMENT_CENTER
	row0.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var row1 := HBoxContainer.new()
	row1.add_theme_constant_override("separation", 8)
	row1.alignment = BoxContainer.ALIGNMENT_CENTER
	row1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(row0)
	vbox.add_child(row1)
	_grid_rows[vbox] = [row0, row1]
	return vbox


# QW 改造：把按钮加到 4×2 网格的对应槽位（0-3 = row0，4-7 = row1）
func _add_to_grid(grid: Container, slot_index: int, child: Control) -> void:
	if not _grid_rows.has(grid):
		grid.add_child(child)
		return
	var rows: Array = _grid_rows[grid]
	var target_row: HBoxContainer = rows[1] if slot_index >= 4 else rows[0]
	target_row.add_child(child)


func _add_icon_button(mode: int, container: Container, slot_key: Key, slot_index: int = 0) -> void:
	var hotkey: Key = slot_key
	var hotkey_label: String = OS.get_keycode_string(hotkey) if hotkey != KEY_0 else ""
	var cost: int = D.COSTS.get(mode, 0)
	var mode_name: String = tr(D.MODE_NAMES.get(mode, "ENTITY_UNIT"))
	var icon_tex: Texture2D = D.ICON_TEXTURES.get(mode, null) as Texture2D
	# QW 改造：key_to_mode 改为切 Tab 时动态重建（_rebuild_key_to_mode_for_tab），不在按钮工厂填

	var wrapper := Control.new()
	# QW 改造：56×56（4×2 总高 = 2×56+8=120，加 Tab 28+sep 4=160 ≤ QW 段可用 163）
	wrapper.custom_minimum_size = Vector2(56, 56)
	wrapper.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	wrapper.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	var bg := _make_ninepatch(np_btn_blue)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.name = "ButtonBG"
	# QW 改造：覆盖 patch_margin，避免 NinePatchRect 自报 minimum_size = 94×94 撑大 wrapper
	# 56×56 按钮只需 ~10px 边框 patch，边框照样能画完整
	bg.patch_margin_left = 10
	bg.patch_margin_right = 10
	bg.patch_margin_top = 10
	bg.patch_margin_bottom = 10
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
	key_label.text = hotkey_label
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

	# PR-T2-5: 灰色锁图标（时代未解锁时显示，右上角），由 _update_button_affordability 切换显隐
	var lock_icon := preload("res://scripts/ui/lock_icon.gd").new()
	lock_icon.name = "LockIcon"
	lock_icon.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	lock_icon.offset_left = -20
	lock_icon.offset_right = -2
	lock_icon.offset_top = 2
	lock_icon.offset_bottom = 20
	lock_icon.visible = false
	wrapper.add_child(lock_icon)

	# T1 PR-2: SC2 风格右下角造价数字（够=白，不够=红，其他=灰），由 _update_button_affordability 实时改色
	var cost_label := Label.new()
	cost_label.name = "CostLabel"
	cost_label.text = str(cost)
	cost_label.add_theme_font_size_override("font_size", 14)
	cost_label.add_theme_color_override("font_color", Color.WHITE)
	cost_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	cost_label.add_theme_constant_override("shadow_offset_x", 1)
	cost_label.add_theme_constant_override("shadow_offset_y", 1)
	cost_label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	cost_label.offset_left = -28
	cost_label.offset_right = -4
	cost_label.offset_top = -18
	cost_label.offset_bottom = -2
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	cost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrapper.add_child(cost_label)

	# QW 改造：加到 4×2 网格的对应 row（0-3 row0，4-7 row1）
	if container is VBoxContainer and _grid_rows.has(container):
		_add_to_grid(container, slot_index, wrapper)
	else:
		container.add_child(wrapper)
	ui_buttons[mode] = wrapper


# ============================================================
# 标签页切换
# ============================================================
func _switch_tab(tab_index: int) -> void:
	active_tab = tab_index
	unit_container.visible = (tab_index == 0)
	building_container.visible = (tab_index == 1)
	if outpost_container:
		outpost_container.visible = (tab_index == 2)
	for i in range(tab_buttons.size()):
		tab_buttons[i].button_pressed = (i == tab_index)
	# 活动标签页按钮脉冲动画
	if tab_index < tab_buttons.size():
		var btn := tab_buttons[tab_index]
		btn.scale = Vector2(1.2, 1.2)
		var tween := btn.create_tween()
		tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	# QW 改造：切 Tab 时重建 key_to_mode，让 QWER ASDF 对应当前 Tab 的前 8 个槽位
	_rebuild_key_to_mode_for_tab(tab_index)
	# QW 改造：切 Tab 时自动进入对应 QW 模式（让 QWER ASDF 立刻可用）
	# 注意：避免与 main._on_input_mode_changed 形成循环 —— 仅在模式不一致时切换
	var im: Node = _main_node.get("input_mode") if _main_node else null
	if im != null:
		match tab_index:
			0:
				if not im.is_unit_production():
					im.enter_unit_production()
			1, 2:
				# 建筑/据点 tab 都进 building_placement（据点生产路径特殊复用此模式）
				if not im.is_building_placement():
					im.enter_building_placement()


# QW 改造：根据当前 Tab 重建 GRID_KEYS → PlaceMode 映射
# 单位 Tab：QWER ASDF → unit_modes_ordered[0..7]
# 建筑 Tab：QWER ASDF → building_modes_ordered[0..7]
# 据点 Tab：Q → ALTAR_ARCHER（只 1 个），其他键无映射
func _rebuild_key_to_mode_for_tab(tab_index: int) -> void:
	key_to_mode.clear()
	var modes: Array = []
	match tab_index:
		0:
			modes = unit_modes_ordered
		1:
			modes = building_modes_ordered
		2:
			# PR-4 据点：只一个 ALTAR_ARCHER，绑定到 Q（GRID_KEYS[0]）
			key_to_mode[D.GRID_KEYS[0]] = D.PlaceMode.ALTAR_ARCHER
			return
		_:
			return
	for i in range(min(modes.size(), D.GRID_MAX_SLOTS)):
		key_to_mode[D.GRID_KEYS[i]] = modes[i]


func switch_tab_for_mode(mode: int) -> void:
	if D.is_unit_mode(mode):
		if active_tab != 0:
			_switch_tab(0)
	else:
		if active_tab != 1:
			_switch_tab(1)


func switch_tab(tab_index: int) -> void:
	_switch_tab(tab_index)


# QW 改造：Tab 键循环切换菜单（单位 → 建筑 → 据点[可见时] → 单位）
func cycle_tab() -> void:
	var next_tab: int = active_tab + 1
	# 跳过不可见的 tab（据点 tab 默认隐藏）
	while next_tab < tab_buttons.size() and not tab_buttons[next_tab].visible:
		next_tab += 1
	if next_tab >= tab_buttons.size():
		next_tab = 0
	_switch_tab(next_tab)


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
	label.add_theme_font_size_override("font_size", 16)
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
	# T1 PR-2: 灰显按钮（disabled）不弹 tooltip 也不触发动效，避免误导
	var btn_wrapper: Control = ui_buttons.get(mode, null)
	if btn_wrapper != null:
		for c in btn_wrapper.get_children():
			if c is Button:
				if c.disabled:
					return
				break
	tooltip_target_mode = mode
	tooltip_timer.start()
	# T2 PR-3: hover 时详情面板临时切换
	if _bottom_bar != null:
		var dp = _bottom_bar.get_detail_panel()
		if dp != null:
			dp.show_temporary_mode(mode)


func _on_icon_unhover() -> void:
	tooltip_timer.stop()
	tooltip_panel.visible = false
	tooltip_target_mode = -1
	# T2 PR-3: 移开恢复
	if _bottom_bar != null:
		var dp = _bottom_bar.get_detail_panel()
		if dp != null:
			dp.restore_previous()


func _show_tooltip() -> void:
	if tooltip_target_mode < 0:
		return
	var mode: int = tooltip_target_mode
	var mode_name: String = tr(D.MODE_NAMES.get(mode, "?"))
	# T1: 动态造价（农场递增）—— 通过 building_placer.get_current_cost 取
	var cost: int = _main_node.building_placer.get_current_cost(mode) if _main_node.get("building_placer") else D.COSTS.get(mode, 0)
	# QW 改造：键 → mode 映射在 key_to_mode（动态），反查 mode → 键
	var hotkey_label: String = ""
	for k in key_to_mode.keys():
		if key_to_mode[k] == mode:
			hotkey_label = OS.get_keycode_string(k)
			break
	var type_str: String = tr("TAB_UNITS") if D.is_unit_mode(mode) else tr("TAB_BUILDINGS")

	tooltip_label.text = "%s (%s)\n$%d  [%s]" % [mode_name, type_str, cost, hotkey_label]
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
func update_selection_info(units: Array, buildings: Array = [], peek_building = null) -> void:
	# T2 PR-3 + PR-T2-5: 转发给详情面板（L1-L9 分派）
	if _bottom_bar != null:
		var dp = _bottom_bar.get_detail_panel()
		if dp != null:
			if peek_building != null:
				dp.show_building(peek_building, true)  # L9 peek（保留单位选中）
			elif not units.is_empty() and not buildings.is_empty():
				# L8 混选防御：只显示单位（最新选中优先，建筑忽略）
				if units.size() == 1:
					dp.show_unit(units[0])
				else:
					dp.show_units_multi(units)
			elif not buildings.is_empty():
				if buildings.size() == 1:
					dp.show_building(buildings[0])  # L2
				else:
					dp.show_buildings_multi(buildings)  # L7
			elif units.size() == 1:
				dp.show_unit(units[0])  # L3
			elif units.size() > 1:
				dp.show_units_multi(units)  # L6
			else:
				dp.show_default()  # L1

	# 旧的浮动标签（保留兼容）
	if selection_info_label == null:
		return
	if units.is_empty() and buildings.is_empty() and peek_building == null:
		selection_info_label.visible = false
		return

	# 旧标签：建筑选中 / peek 时不显示单位统计
	if not buildings.is_empty() or peek_building != null:
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


func update_gold_display(current_gold: int) -> void:
	if gold_label:
		gold_label.text = tr("UI_GOLD") % current_gold
	_update_button_affordability(current_gold)


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


var _tech_label: Label = null
var _tech_level: int = 1
var _time_label: Label = null

func update_tech_level(level: int) -> void:
	_tech_level = level
	if _tech_label:
		_tech_label.text = tr("UI_TECH_LEVEL") % level


func update_tech_points(points: int) -> void:
	if _tech_label:
		_tech_label.text = "Tech: %d" % points



func _update_button_affordability(current_gold: int) -> void:
	for mode in ui_buttons:
		var btn_wrapper: Control = ui_buttons[mode]
		# T1 PR-2: 改用统一 check_build_block（金币/上限/前置），按 reason 决定颜色
		# 注：建造栏按钮无位置概念，不传 click_pos → OUT_OF_RANGE 不会在此触发
		var reason: int = BuildingPlacer.BuildBlockReason.OK
		if _main_node.get("building_placer"):
			reason = _main_node.building_placer.check_build_block(mode)
		var ok: bool = reason == BuildingPlacer.BuildBlockReason.OK
		# T2 PR-1: ERA_LOCKED 单独分支（视觉灰显但按钮不 disable，让点击能触发"需要 T2 时代"飘字）
		var era_locked: bool = reason == BuildingPlacer.BuildBlockReason.ERA_LOCKED
		btn_wrapper.modulate.a = 1.0 if ok else 0.5
		# PR-T2-5: 灰色锁图标显隐 + 解锁高亮闪烁（锁→解锁 翻转时）
		var lock: Control = btn_wrapper.get_node_or_null("LockIcon")
		if lock:
			lock.visible = era_locked
		var was_locked: bool = _prev_era_locked.get(mode, false)
		if was_locked and not era_locked:
			_flash_unlock_button(btn_wrapper)
		_prev_era_locked[mode] = era_locked
		# T1 PR-2: 实时刷新右下角造价数字（农场递增时数字会变）
		var cost_now: int = D.COSTS.get(mode, 0)
		if _main_node.get("building_placer"):
			cost_now = _main_node.building_placer.get_current_cost(mode)
		var cl: Label = btn_wrapper.get_node_or_null("CostLabel")
		if cl:
			cl.text = str(cost_now)
			var col := Color.WHITE
			if not ok:
				if era_locked:
					col = Color(0.6, 0.4, 0.8)  # 紫灰：时代锁定
				elif reason == BuildingPlacer.BuildBlockReason.NO_GOLD:
					col = Color(1.0, 0.3, 0.3)
				else:
					col = Color(0.6, 0.6, 0.6)
			cl.add_theme_color_override("font_color", col)
		# btn 是 wrapper 里的 Button 节点（鼠标响应层，可能不在最末位）
		var btn: Button = null
		for c in btn_wrapper.get_children():
			if c is Button:
				btn = c
				break
		if btn != null:
			# T2 PR-1: 时代锁定时不 disable（让点击能触发拦截飘字），其他 reason 正常 disable
			btn.disabled = not ok and not era_locked


# PR-T2-5: 时代解锁极简反馈——按钮高亮闪烁一下（不弹窗）
func _flash_unlock_button(wrapper: Control) -> void:
	wrapper.modulate = Color(1.25, 1.2, 0.7, wrapper.modulate.a)
	var tween := wrapper.create_tween()
	tween.tween_property(wrapper, "modulate", Color(1, 1, 1, wrapper.modulate.a), 0.5)


func update_wave_countdown(wave_number: int, remaining: float, total: int) -> void:
	if objectives_panel != null and objectives_panel.has_method("update_wave_countdown"):
		objectives_panel.update_wave_countdown(wave_number, remaining, total)


func hide_wave_countdown() -> void:
	if objectives_panel != null and objectives_panel.has_method("hide_wave_countdown"):
		objectives_panel.hide_wave_countdown()


func set_place_mode_text(text: String) -> void:
	if place_mode_label:
		place_mode_label.text = text
		place_mode_label.visible = text != ""


func hide_place_mode_label() -> void:
	if place_mode_label:
		place_mode_label.visible = false


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
	label.add_theme_font_size_override("font_size", 16)
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
	title.text = "UI_PAUSED"
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
		["UI_RESUME", _close_pause_menu],
		["UI_RESTART", _on_pause_restart],
		["UI_LEVEL_SELECT", _on_pause_level_select],
		["UI_SETTINGS", _open_settings_page],
		["UI_MAIN_MENU", _on_pause_quit],
	]
	for data in btn_data:
		var btn_wrapper := _make_styled_button(data[0], Vector2(0, 44), data[1])
		vbox.add_child(btn_wrapper)

	var hint := Label.new()
	hint.text = "UI_PRESS_ESC_RESUME"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	vbox.add_child(hint)

	pause_canvas.visible = false


func open_pause_menu() -> void:
	pause_menu_open = true
	pause_canvas.visible = true
	_main_node.get_tree().paused = true


func handle_pause_esc() -> void:
	"""Close topmost layer: keybinds -> settings -> full pause menu."""
	if _keybinds_active:
		_close_keybinds_page()
		return
	if _settings_active:
		_close_settings_page()
		return
	_close_pause_menu()


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


func _on_collisions_toggled(pressed: bool) -> void:
	_main_node.show_collisions = pressed
	_main_node.refresh_collision_debug()
	_save_setting("game", "show_collisions", pressed)


func _on_build_range_toggled(pressed: bool) -> void:
	if _main_node.get("building_placer"):
		_main_node.building_placer.show_build_range = pressed
	_save_setting("game", "show_build_range", pressed)


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
	_settings_active = true
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
	title.text = "UI_SETTINGS"
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
	vbox.add_child(_make_section_label("UI_DISPLAY"))

	# 分辨率
	var res_row := HBoxContainer.new()
	res_row.add_theme_constant_override("separation", 8)
	var res_label := Label.new()
	res_label.text = "UI_RESOLUTION"
	res_label.custom_minimum_size = Vector2(100, 0)
	res_label.add_theme_font_size_override("font_size", 14)
	res_label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
	res_row.add_child(res_label)
	_settings_res_option = OptionButton.new()
	_settings_res_option.custom_minimum_size = Vector2(160, 30)
	var current_size := DisplayServer.window_get_size()
	var selected_idx := 0
	for i in RESOLUTION_PRESETS.size():
		_settings_res_option.add_item(RESOLUTION_KEYS[i], i)
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
	dm_label.text = "UI_DISPLAY_MODE"
	dm_label.custom_minimum_size = Vector2(100, 0)
	dm_label.add_theme_font_size_override("font_size", 14)
	dm_label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
	dm_row.add_child(dm_label)
	_settings_display_mode_option = OptionButton.new()
	_settings_display_mode_option.add_item("UI_MODE_FULLSCREEN", 0)
	_settings_display_mode_option.add_item("UI_MODE_BORDERLESS", 1)
	_settings_display_mode_option.add_item("UI_MODE_WINDOWED", 2)
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
	vbox.add_child(_make_slider_row("UI_BRIGHTNESS", brightness_val, 0.3, 1.5, _on_brightness_changed))

	# FPS 显示
	var fps_row := HBoxContainer.new()
	fps_row.add_theme_constant_override("separation", 8)
	var fps_label := Label.new()
	fps_label.text = "UI_SHOW_FPS"
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
	vbox.add_child(_make_section_label("UI_AUDIO"))

	var master_val: float = config.get_value("audio", "master_volume", 1.0)
	vbox.add_child(_make_slider_row("UI_MASTER_VOLUME", master_val, 0.0, 1.0, _on_master_volume_changed))

	var music_val: float = config.get_value("audio", "music_volume", 1.0)
	vbox.add_child(_make_slider_row("UI_MUSIC_VOLUME", music_val, 0.0, 1.0, _on_music_volume_changed))

	var sfx_val: float = config.get_value("audio", "sfx_volume", 1.0)
	vbox.add_child(_make_slider_row("UI_SFX_VOLUME", sfx_val, 0.0, 1.0, _on_sfx_volume_changed))

	var spacer3 := Control.new()
	spacer3.custom_minimum_size = Vector2(0, 6)
	vbox.add_child(spacer3)

	# === 游戏区域 ===
	vbox.add_child(_make_section_label("UI_GAMEPLAY"))

	# 伤害飘字
	var dmg_row := HBoxContainer.new()
	dmg_row.add_theme_constant_override("separation", 8)
	var dmg_label := Label.new()
	dmg_label.text = "UI_DAMAGE_NUMBERS"
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
	path_label.text = "UI_PATH_LINES"
	path_label.add_theme_font_size_override("font_size", 14)
	path_label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
	path_row.add_child(path_label)
	var path_toggle := CheckButton.new()
	path_toggle.button_pressed = config.get_value("game", "show_path_lines", true)
	path_toggle.toggled.connect(_on_path_lines_toggled)
	path_row.add_child(path_toggle)
	vbox.add_child(path_row)

	# 碰撞区域显示
	var col_row := HBoxContainer.new()
	col_row.add_theme_constant_override("separation", 8)
	var col_label := Label.new()
	col_label.text = "UI_SHOW_COLLISIONS"
	col_label.add_theme_font_size_override("font_size", 14)
	col_label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
	col_row.add_child(col_label)
	var col_toggle := CheckButton.new()
	col_toggle.button_pressed = config.get_value("game", "show_collisions", false)
	col_toggle.toggled.connect(_on_collisions_toggled)
	col_row.add_child(col_toggle)
	vbox.add_child(col_row)

	# T1 D5: 显示建造范围（主基地 6 格圆环）
	var build_row := HBoxContainer.new()
	build_row.add_theme_constant_override("separation", 8)
	var build_label := Label.new()
	build_label.text = "UI_SHOW_BUILD_RANGE"
	build_label.add_theme_font_size_override("font_size", 14)
	build_label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
	build_row.add_child(build_label)
	var build_toggle := CheckButton.new()
	build_toggle.button_pressed = config.get_value("game", "show_build_range", false)
	build_toggle.toggled.connect(_on_build_range_toggled)
	build_row.add_child(build_toggle)
	vbox.add_child(build_row)

	# 鼠标灵敏度
	var sens_val: float = config.get_value("gameplay", "camera_sensitivity", 1.0)
	vbox.add_child(_make_slider_row("UI_MOUSE_SENSITIVITY", sens_val, 0.2, 3.0, _on_camera_sensitivity_changed))

	var spacer4 := Control.new()
	spacer4.custom_minimum_size = Vector2(0, 8)
	vbox.add_child(spacer4)

	# 查看按键绑定按钮
	vbox.add_child(_make_styled_button("UI_VIEW_KEYBINDS", Vector2(0, 40), _open_keybinds_page))

	# === Language section ===
	var spacer5 := Control.new()
	spacer5.custom_minimum_size = Vector2(0, 6)
	vbox.add_child(spacer5)
	vbox.add_child(_make_section_label("UI_LANGUAGE"))
	var lang_hbox := HBoxContainer.new()
	lang_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	lang_hbox.add_theme_constant_override("separation", 8)
	var _supported_locales := ["en", "zh", "ja"]
	var current_locale := TranslationServer.get_locale()
	for locale_code in _supported_locales:
		var btn := Button.new()
		btn.text = "LANG_" + locale_code.to_upper()
		btn.custom_minimum_size = Vector2(90, 28)
		btn.add_theme_font_size_override("font_size", 14)
		btn.set_meta("locale", locale_code)
		btn.add_theme_color_override("font_color", Color(1, 0.85, 0.0) if locale_code == current_locale or locale_code == current_locale.substr(0, 2) else Color(0.8, 0.8, 0.8))
		btn.pressed.connect(_on_settings_language_selected.bind(locale_code))
		lang_hbox.add_child(btn)
		BF.add_hover_anim_button(btn)
	vbox.add_child(lang_hbox)

	# 返回按钮
	vbox.add_child(_make_styled_button("UI_OK", Vector2(0, 40), _close_settings_page))


func _make_section_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)
	return label


func _close_settings_page() -> void:
	_settings_active = false
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
	_save_setting("game", "locale", locale_code)
	_refresh_language_button_colors()


func _refresh_language_button_colors() -> void:
	var current_locale := TranslationServer.get_locale()
	_refresh_lang_buttons_recursive(_pause_overlay, current_locale)


func _refresh_lang_buttons_recursive(node: Node, current_locale: String) -> void:
	if node is Button and node.has_meta("locale"):
		var btn_locale: String = node.get_meta("locale")
		var is_active: bool = btn_locale == current_locale or btn_locale == current_locale.substr(0, 2)
		node.add_theme_color_override("font_color", Color(1, 0.85, 0.0) if is_active else Color(0.8, 0.8, 0.8))
	for child in node.get_children():
		_refresh_lang_buttons_recursive(child, current_locale)


func _open_keybinds_page() -> void:
	_keybinds_active = true
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
	title.text = "UI_KEYBINDS_TITLE"
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

	# QW 改造：展示快捷键总览（1-9=编队 / QWER ASDF=QW 栏槽位 / Tab=切菜单）
	var keybind_rows: Array = [
		["1-9", "UI_KEYBINDS_CONTROL_GROUP"],
		["Q W E R / A S D F", "UI_KEYBINDS_QW_SLOTS"],
		["Tab", "UI_KEYBINDS_CYCLE_TAB"],
		["A / S / H / P", "UI_KEYBINDS_UNIT_COMMANDS"],
		["Z X C V", "UI_KEYBINDS_COMMANDER_SKILLS"],
		["Y", "UI_KEYBINDS_RALLY"],
		["U", "UI_KEYBINDS_AGE_UPGRADE"],
		["Space", "UI_KEYBINDS_JUMP_BASE"],
		["G", "UI_KEYBINDS_TOGGLE_GRID"],
		["ESC", "UI_KEYBINDS_CANCEL"],
	]
	for row_data in keybind_rows:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		row.alignment = BoxContainer.ALIGNMENT_CENTER

		var name_label := Label.new()
		name_label.text = tr(row_data[1])
		name_label.add_theme_font_size_override("font_size", 16)
		name_label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
		name_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.4))
		name_label.add_theme_constant_override("shadow_offset_x", 1)
		name_label.add_theme_constant_override("shadow_offset_y", 1)
		name_label.custom_minimum_size = Vector2(280, 0)
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(name_label)

		var arrow := Label.new()
		arrow.text = "->"
		arrow.add_theme_font_size_override("font_size", 16)
		arrow.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		row.add_child(arrow)

		var key_label := Label.new()
		key_label.text = row_data[0]
		key_label.add_theme_font_size_override("font_size", 16)
		key_label.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
		key_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.4))
		key_label.add_theme_constant_override("shadow_offset_x", 1)
		key_label.add_theme_constant_override("shadow_offset_y", 1)
		key_label.custom_minimum_size = Vector2(180, 0)
		key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row.add_child(key_label)

		vbox.add_child(row)

	var spacer2 := Control.new()
	spacer2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer2)

	# 返回设置按钮
	vbox.add_child(_make_styled_button("UI_BACK_TO_SETTINGS", Vector2(0, 40), _close_keybinds_page))


func _close_keybinds_page() -> void:
	_keybinds_active = false
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
