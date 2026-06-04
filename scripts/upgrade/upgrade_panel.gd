extends Node
## 升级三选一面板：暂停游戏、展示3张升级卡片、点击选择

const UD := preload("res://scripts/upgrade/upgrade_data.gd")

const PATH_WOOD_TABLE := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Wood Table/WoodTable.png"
const PATH_BTN_BLUE_REG := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigBlueButton_Regular.png"
const PATH_BTN_BLUE_PRS := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigBlueButton_Pressed.png"

var _main_node: Node2D
var _upgrade_manager: Node
var _ui_canvas: CanvasLayer
var _panel: Control
var _card_row: HBoxContainer

# 预处理后的九宫格数据
var np_wood_table: Dictionary
var np_btn_blue: Dictionary
var np_btn_blue_prs: Dictionary


func initialize(main_node: Node2D, upgrade_manager: Node) -> void:
	_main_node = main_node
	_upgrade_manager = upgrade_manager
	_preprocess_textures()
	_create_ui()


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


func _create_ui() -> void:
	_ui_canvas = CanvasLayer.new()
	_ui_canvas.layer = 100
	_ui_canvas.process_mode = Node.PROCESS_MODE_ALWAYS
	_main_node.add_child(_ui_canvas)
	_ui_canvas.visible = false

	# 半透明遮罩
	var overlay := ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.5)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_ui_canvas.add_child(overlay)

	# 面板居中
	_panel = Control.new()
	_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_panel.offset_left = -280
	_panel.offset_right = 280
	_panel.offset_top = -200
	_panel.offset_bottom = 200
	_ui_canvas.add_child(_panel)

	# 木质背景
	var bg := _make_ninepatch(np_wood_table)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_panel.add_child(bg)

	# 标题
	var title := Label.new()
	title.name = "TitleLabel"
	title.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	title.offset_top = 20
	title.offset_bottom = 55
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	title.add_theme_constant_override("shadow_offset_x", 2)
	title.add_theme_constant_override("shadow_offset_y", 2)
	_panel.add_child(title)

	# 卡片行
	_card_row = HBoxContainer.new()
	_card_row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_card_row.offset_left = 30
	_card_row.offset_right = -30
	_card_row.offset_top = 60
	_card_row.offset_bottom = -15
	_card_row.add_theme_constant_override("separation", 20)
	_card_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_panel.add_child(_card_row)


func is_panel_visible() -> bool:
	return _ui_canvas != null and _ui_canvas.visible


func show_selection(tier: int) -> void:
	var choices: Array = _upgrade_manager.get_random_choices(tier, 3)
	if choices.is_empty():
		return

	var tier_color: Color = UD.TIER_COLORS.get(tier, Color.WHITE)
	var tier_name: String = tr(UD.TIER_NAMES.get(tier, ""))
	var title: Label = _panel.get_node("TitleLabel")
	title.text = tier_name + " " + tr("UPGRADE_SELECT_TITLE")
	title.add_theme_color_override("font_color", tier_color)

	for child in _card_row.get_children():
		child.queue_free()

	for upgrade_id in choices:
		_create_upgrade_card(upgrade_id, tier_color)

	_ui_canvas.visible = true
	_main_node.get_tree().paused = true


func _create_upgrade_card(upgrade_id: int, tier_color: Color) -> void:
	var config: Dictionary = UD.CONFIGS[upgrade_id]

	var card := Control.new()
	card.custom_minimum_size = Vector2(150, 200)
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_card_row.add_child(card)

	# 蓝色按钮背景（用预处理的九宫格）
	var card_bg := _make_ninepatch(np_btn_blue)
	card_bg.name = "CardBG"
	card_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	card_bg.modulate = Color(tier_color.r * 0.3 + 0.7, tier_color.g * 0.3 + 0.7, tier_color.b * 0.3 + 0.7, 1.0)
	card.add_child(card_bg)

	# 图标
	var icon_path: String = config.get("icon", "")
	if icon_path != "":
		var icon := TextureRect.new()
		icon.texture = load(icon_path)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
		icon.offset_left = -24
		icon.offset_right = 24
		icon.offset_top = -60
		icon.offset_bottom = -12
		card.add_child(icon)

	# 名称
	var name_label := Label.new()
	name_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	name_label.offset_top = 65
	name_label.offset_bottom = 90
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", Color(1, 1, 1, 1.0))
	name_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	name_label.text = tr(config.get("name", ""))
	card.add_child(name_label)

	# 描述
	var desc_label := Label.new()
	desc_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	desc_label.offset_left = 8
	desc_label.offset_right = -8
	desc_label.offset_top = 92
	desc_label.offset_bottom = -8
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	desc_label.add_theme_font_size_override("font_size", 13)
	desc_label.add_theme_color_override("font_color", tier_color)
	desc_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.text = tr(config.get("desc", ""))
	card.add_child(desc_label)

	# 点击按钮
	var btn := Button.new()
	btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var empty_style := StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("normal", empty_style)
	btn.add_theme_stylebox_override("hover", empty_style)
	btn.add_theme_stylebox_override("pressed", empty_style)
	btn.add_theme_stylebox_override("focus", empty_style)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.pressed.connect(_on_upgrade_clicked.bind(upgrade_id))
	btn.mouse_entered.connect(func(): card_bg.texture = np_btn_blue_prs.texture)
	btn.mouse_exited.connect(func(): card_bg.texture = np_btn_blue.texture)
	card.add_child(btn)


func _on_upgrade_clicked(upgrade_id: int) -> void:
	_upgrade_manager.purchase_upgrade(upgrade_id)
	close()


func close() -> void:
	_ui_canvas.visible = false
	_main_node.get_tree().paused = false
