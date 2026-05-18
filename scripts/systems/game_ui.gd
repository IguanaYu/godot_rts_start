extends Node
## UI 模块：底部建造面板、金币显示、放置模式提示、波次倒计时、暂停菜单

const D := preload("res://scripts/systems/game_data.gd")

# === 素材路径常量 ===
const PATH_WOOD_TABLE := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Wood Table/WoodTable.png"
const PATH_BTN_BLUE_REG := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigBlueButton_Regular.png"
const PATH_BTN_BLUE_PRS := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigBlueButton_Pressed.png"

signal place_mode_requested(mode: int)
signal restart_requested
signal level_select_requested
signal quit_requested

# UI 引用
var ui_buttons: Dictionary = {}  # mode -> Control wrapper
var place_mode_label: Label
var gold_label: Label
var wave_countdown_label: Label

# 暂停菜单
var pause_menu_open: bool = false
var pause_canvas: CanvasLayer

# Key mapping
var key_to_mode: Dictionary = {}

# 外部引用
var _main_node: Node2D

# 面板矩形（用于相机豁免）
var panel_rect: Rect2

# 九宫格纹理
var np_wood_table: Dictionary
var np_btn_blue: Dictionary
var np_btn_blue_prs: Dictionary

func initialize(main_node: Node2D, map_config: Resource, gold: int) -> void:
	_main_node = main_node
	_preprocess_textures()
	_create_ui(map_config, gold)
	_create_pause_menu()


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
	# WoodTable (448x448)
	np_wood_table = _process_ninepatch(PATH_WOOD_TABLE,
		[[43, 127], [192, 255], [320, 422]],
		[[44, 127], [192, 255], [320, 403]])
	# BigBlueButton Regular (320x320)
	np_btn_blue = _process_ninepatch(PATH_BTN_BLUE_REG,
		[[17, 63], [128, 191], [256, 302]],
		[[19, 63], [128, 191], [256, 300]])
	# BigBlueButton Pressed (320x320)
	np_btn_blue_prs = _process_ninepatch(PATH_BTN_BLUE_PRS,
		[[28, 63], [128, 191], [256, 304]],
		[[14, 63], [128, 191], [256, 305]])


# ============================================================
# 主 UI 创建
# ============================================================
func _create_ui(map_config: Resource, current_gold: int) -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 10
	_main_node.add_child(canvas)

	# --- 底部建造面板 ---
	var panel_wrapper := Control.new()
	panel_wrapper.anchor_left = 0.05
	panel_wrapper.anchor_right = 0.95
	panel_wrapper.anchor_top = 1.0
	panel_wrapper.anchor_bottom = 1.0
	panel_wrapper.offset_top = -80.0
	panel_wrapper.offset_bottom = -8.0
	panel_wrapper.grow_vertical = Control.GROW_DIRECTION_BEGIN
	canvas.add_child(panel_wrapper)

	# WoodTable 九宫格底板
	var panel_bg := _make_ninepatch(np_wood_table)
	panel_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel_wrapper.add_child(panel_bg)

	# 按钮容器（居中）
	var hbox := HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.offset_left = 12
	hbox.offset_right = -12
	hbox.offset_top = 8
	hbox.offset_bottom = -8
	hbox.add_theme_constant_override("separation", 6)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel_wrapper.add_child(hbox)

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

	# --- 生成按钮 ---
	for mode in sorted_items:
		var hotkey: Key = D.MODE_HOTKEYS.get(mode, KEY_0)
		var hotkey_index: int = (hotkey - KEY_1 + 1) if hotkey != KEY_0 else 0
		var cost: int = D.COSTS.get(mode, 0)
		var mode_name: String = tr(D.MODE_NAMES.get(mode, "ENTITY_UNIT"))
		var icon_path: String = D.MODE_ICONS.get(mode, "")

		var btn_wrapper := _create_build_button(mode, mode_name, hotkey_index, cost, icon_path)
		hbox.add_child(btn_wrapper)
		ui_buttons[mode] = btn_wrapper

		# 固定快捷键映射
		key_to_mode[hotkey] = mode

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

	# --- 放置模式提示（屏幕顶部偏下）---
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
	wave_countdown_label.offset_top = -95.0
	wave_countdown_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	wave_countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wave_countdown_label.add_theme_font_size_override("font_size", 20)
	wave_countdown_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	wave_countdown_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	wave_countdown_label.add_theme_constant_override("shadow_offset_x", 1)
	wave_countdown_label.add_theme_constant_override("shadow_offset_y", 1)
	wave_countdown_label.visible = false
	canvas.add_child(wave_countdown_label)


# ============================================================
# 建造按钮工厂
# ============================================================
func _create_build_button(mode: int, mode_name: String, hotkey_index: int, cost: int, icon_path: String) -> Control:
	var wrapper := Control.new()
	wrapper.custom_minimum_size = Vector2(100, 56)

	# 九宫格按钮底板
	var bg := _make_ninepatch(np_btn_blue)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.name = "ButtonBG"
	wrapper.add_child(bg)

	# 内容容器（水平布局：图标 + 文字）
	var content := HBoxContainer.new()
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.offset_left = 4
	content.offset_right = -4
	content.offset_top = 4
	content.offset_bottom = -4
	content.add_theme_constant_override("separation", 2)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrapper.add_child(content)

	# 图标
	if icon_path != "":
		var icon := TextureRect.new()
		icon.texture = load(icon_path)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(28, 28)
		icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(icon)

	# 文字区域（垂直布局）
	var text_col := VBoxContainer.new()
	text_col.add_theme_constant_override("separation", 0)
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(text_col)

	var name_label := Label.new()
	name_label.text = "%d:%s" % [hotkey_index, mode_name]
	name_label.add_theme_font_size_override("font_size", 13)
	name_label.add_theme_color_override("font_color", Color(1, 1, 1))
	name_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	name_label.add_theme_constant_override("shadow_offset_x", 1)
	name_label.add_theme_constant_override("shadow_offset_y", 1)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_col.add_child(name_label)

	var cost_label := Label.new()
	cost_label.text = "$%d" % cost
	cost_label.add_theme_font_size_override("font_size", 12)
	cost_label.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
	cost_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	cost_label.add_theme_constant_override("shadow_offset_x", 1)
	cost_label.add_theme_constant_override("shadow_offset_y", 1)
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	text_col.add_child(cost_label)

	# 透明 Button 接收点击
	var btn := Button.new()
	btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var empty_style := StyleBoxEmpty.new()
	btn.add_theme_stylebox_override("normal", empty_style)
	btn.add_theme_stylebox_override("hover", empty_style)
	btn.add_theme_stylebox_override("pressed", empty_style)
	btn.add_theme_stylebox_override("focus", empty_style)
	btn.pressed.connect(func(): place_mode_requested.emit(mode))
	btn.button_down.connect(func(): bg.texture = np_btn_blue_prs.texture)
	btn.button_up.connect(func(): bg.texture = np_btn_blue.texture)
	wrapper.add_child(btn)

	return wrapper


# ============================================================
# 更新方法
# ============================================================
func update_gold_display(current_gold: int) -> void:
	if gold_label:
		gold_label.text = tr("UI_GOLD") % current_gold
	_update_button_affordability(current_gold)


func _update_button_affordability(current_gold: int) -> void:
	for mode in ui_buttons:
		var btn_wrapper: Control = ui_buttons[mode]
		var cost: int = D.COSTS.get(mode, 0)
		var can_afford: bool = current_gold >= cost
		btn_wrapper.modulate.a = 1.0 if can_afford else 0.5
		# 禁用/启用内部按钮
		var btn: Button = btn_wrapper.get_child(btn_wrapper.get_child_count() - 1)
		if btn is Button:
			btn.disabled = not can_afford


func update_wave_countdown(wave_number: int, remaining: float, total: int) -> void:
	if wave_countdown_label == null:
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


## 获取面板在屏幕上的矩形（用于相机豁免）
func get_panel_screen_rect() -> Rect2:
	return panel_rect


## 每帧更新面板矩形位置
func update_panel_rect() -> void:
	# 底部面板区域估算：屏幕底部 8px ~ 80px
	var vp_size: Vector2 = _main_node.get_viewport().get_visible_rect().size
	panel_rect = Rect2(
		vp_size.x * 0.05,
		vp_size.y - 80.0,
		vp_size.x * 0.9,
		72.0
	)


# ============================================================
# 暂停菜单
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

	# ESC input handler (runs while paused)
	var input_handler := Control.new()
	input_handler.set_script(load("res://scripts/ui/pause_input_handler.gd"))
	input_handler.main_node = _main_node
	input_handler.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	input_handler.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pause_canvas.add_child(input_handler)

	var panel_bg := ColorRect.new()
	panel_bg.anchor_left = 0.5
	panel_bg.anchor_right = 0.5
	panel_bg.anchor_top = 0.5
	panel_bg.anchor_bottom = 0.5
	panel_bg.offset_left = -120.0
	panel_bg.offset_right = 120.0
	panel_bg.offset_top = -140.0
	panel_bg.offset_bottom = 140.0
	panel_bg.color = Color(0.1, 0.1, 0.15, 0.95)
	overlay.add_child(panel_bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	center.add_child(vbox)

	var title := Label.new()
	title.text = tr("UI_PAUSED")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	vbox.add_child(title)

	var btn_data := [
		[tr("UI_RESUME"), _close_pause_menu],
		[tr("UI_RESTART"), _on_pause_restart],
		[tr("UI_LEVEL_SELECT"), _on_pause_level_select],
		[tr("UI_QUIT_GAME"), _on_pause_quit],
	]
	for data in btn_data:
		var btn := Button.new()
		btn.text = data[0]
		btn.custom_minimum_size = Vector2(200, 40)
		btn.pressed.connect(data[1])
		vbox.add_child(btn)

	var hint := Label.new()
	hint.text = tr("UI_PRESS_ESC_RESUME")
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 14)
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
	_main_node.get_tree().quit()


func close_pause_menu() -> void:
	_close_pause_menu()
