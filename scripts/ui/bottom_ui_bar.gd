extends Control
## T2 PR-3: 底部横排 UI 条 — 三段式（QW 建造栏 + 详情面板 + 小地图）

var detail_panel: Control
var _qw_section: Control
var _detail_section: Control
var _minimap_section: Control
var _minimap_panel: Control


func initialize(main_node: Node2D) -> void:
	# 锚点：屏幕底部全宽，固定高度 ~220px
	anchor_left = 0.0
	anchor_right = 1.0
	anchor_top = 1.0
	anchor_bottom = 1.0
	offset_top = -220
	offset_bottom = 0
	offset_left = 0
	offset_right = 0
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# 主 HBox（三段横排），不加背景底板
	var hbox := HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.offset_left = 4
	hbox.offset_right = -4
	hbox.offset_top = 4
	hbox.offset_bottom = -4
	hbox.add_theme_constant_override("separation", 4)
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hbox)

	# === 左段 ~30%：QW 建造栏区 ===
	_qw_section = Control.new()
	_qw_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_qw_section.size_flags_stretch_ratio = 0.30
	_qw_section.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(_qw_section)

	# === 中段 ~40%：详情面板 ===
	_detail_section = Control.new()
	_detail_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail_section.size_flags_stretch_ratio = 0.40
	_detail_section.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(_detail_section)

	detail_panel = preload("res://scripts/ui/detail_panel.gd").new()
	detail_panel.initialize(main_node)
	_detail_section.add_child(detail_panel)
	detail_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# === 右段 ~20%：小地图区（CenterContainer 让固定尺寸小地图居中，不拉伸） ===
	_minimap_section = CenterContainer.new()
	_minimap_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_minimap_section.size_flags_stretch_ratio = 0.20
	_minimap_section.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hbox.add_child(_minimap_section)


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

## 给详情区段加 WoodTable 底板（由 game_ui 调用）
func add_detail_background(bg: NinePatchRect) -> void:
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_detail_section.add_child(bg)
	_detail_section.move_child(bg, 0)


## 给小地图区段加 WoodTable 底板（由 game_ui 调用）
func add_minimap_background(bg: NinePatchRect) -> void:
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_minimap_section.add_child(bg)
	_minimap_section.move_child(bg, 0)