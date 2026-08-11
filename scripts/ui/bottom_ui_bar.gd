extends Control
## T2 PR-3: 底部横排 UI 条 — 三段式（QW 建造栏 + 详情面板 + 小地图）
## UI Revamp P1: 三段视觉合并为统一 WoodTable 背景，段间细分割线

var detail_panel: Control
var _qw_section: Control
var _detail_section: Control
var _minimap_section: Control
var _minimap_panel: Control
var _unified_bg: NinePatchRect  # 统一背景，供 game_ui 高亮动画访问


func initialize(main_node: Node2D) -> void:
	# 锚点：屏幕底部全宽，固定高度 215px（720p 下 29.9%，符合 SC2/Dota2 顶+底 ~30% 基准）
	anchor_left = 0.0
	anchor_right = 1.0
	anchor_top = 1.0
	anchor_bottom = 1.0
	offset_top = -215
	offset_bottom = 0
	offset_left = 0
	offset_right = 0
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# 主 HBox（三段横排），不带背景；背景由 set_unified_background() 注入到 root Control
	var hbox := HBoxContainer.new()
	hbox.name = "BottomBarHBox"
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.offset_left = 4
	hbox.offset_right = -4
	hbox.offset_top = 4
	hbox.offset_bottom = -4
	hbox.add_theme_constant_override("separation", 4)
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hbox)

	# === 左段 ~35%：QW 建造栏区（QW 改造：30→35 容纳 4×2 Grid）===
	_qw_section = Control.new()
	_qw_section.name = "QWSection"
	_qw_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_qw_section.size_flags_stretch_ratio = 0.35
	_qw_section.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(_qw_section)

	# 段间分割线 1（QW | 详情）
	hbox.add_child(_make_divider())

	# === 中段 ~49%：详情面板（QW 改造：40→49，更宽敞）===
	_detail_section = Control.new()
	_detail_section.name = "DetailSection"
	_detail_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_section.size_flags_stretch_ratio = 0.49
	_detail_section.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(_detail_section)

	detail_panel = preload("res://scripts/ui/detail_panel.gd").new()
	detail_panel.initialize(main_node)
	_detail_section.add_child(detail_panel)
	detail_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# 段间分割线 2（详情 | 小地图）
	hbox.add_child(_make_divider())

	# === 右段 ~16%：小地图区（QW 改造：20→16，原 20% 浪费 ~35px×2）===
	_minimap_section = CenterContainer.new()
	_minimap_section.name = "MinimapSection"
	_minimap_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_minimap_section.size_flags_stretch_ratio = 0.16
	_minimap_section.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(_minimap_section)


## 段间细分割线：2px 宽，深棕弱化于 WoodTable 边框
func _make_divider() -> ColorRect:
	var divider := ColorRect.new()
	divider.custom_minimum_size = Vector2(2, 0)
	divider.size_flags_vertical = Control.SIZE_EXPAND_FILL
	divider.color = Color(0.18, 0.11, 0.05, 0.55)
	divider.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return divider


## 设置统一 WoodTable 背景（由 game_ui 在 initialize 后调用，注入预处理过的九宫格数据）
func set_unified_background(np: Dictionary) -> void:
	_unified_bg = NinePatchRect.new()
	_unified_bg.name = "UnifiedBackground"
	_unified_bg.texture = np.texture
	_unified_bg.patch_margin_left = np.margin_left
	_unified_bg.patch_margin_right = np.margin_right
	_unified_bg.patch_margin_top = np.margin_top
	_unified_bg.patch_margin_bottom = np.margin_bottom
	_unified_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_unified_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_unified_bg)
	move_child(_unified_bg, 0)  # 置底，HBox 在它之上


## QW 建造栏嵌入左段（由 game_ui 调用）
func embed_qw_panel(panel: Control) -> void:
	_qw_section.add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


## 小地图嵌入右段（由 game_ui 调用），CenterContainer 自动居中保持原始尺寸
func embed_minimap(minimap: Control) -> void:
	_minimap_panel = minimap
	_minimap_section.add_child(_minimap_panel)


func get_detail_panel() -> Control:
	return detail_panel


## 暴露统一背景供 game_ui 高亮动画使用
func get_unified_background() -> NinePatchRect:
	return _unified_bg
