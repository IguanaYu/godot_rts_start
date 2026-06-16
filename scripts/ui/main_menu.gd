extends Control

## 主菜单界面：开始游戏、设置、退出 + 语言选择

const PATH_WOOD_TABLE := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Wood Table/WoodTable.png"
const PATH_BTN_BLUE_REG := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigBlueButton_Regular.png"
const PATH_BTN_BLUE_PRS := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigBlueButton_Pressed.png"
const PATH_BTN_RED_REG := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigRedButton_Regular.png"
const PATH_BTN_RED_PRS := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigRedButton_Pressed.png"
const PATH_SPECIAL_PAPER := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Papers/SpecialPaper.png"

const SETTINGS_PATH := "user://settings.cfg"
const RESOLUTION_PRESETS: Array[Vector2i] = [
	Vector2i(1280, 720), Vector2i(1366, 768),
	Vector2i(1600, 900), Vector2i(1920, 1080),
]
const RESOLUTION_KEYS: Array[String] = [
	"RES_1280x720", "RES_1366x768", "RES_1600x900", "RES_1920x1080",
]

var _supported_locales := ["en", "zh", "ja"]
var _lang_option: OptionButton
var _settings_overlay: Control = null
var _settings_res_option: OptionButton
var _settings_display_mode_option: OptionButton
var _title_label: Label
var _start_label: Label
var _settings_label: Label
var _quit_label: Label

var np_wood_table: Dictionary
var np_btn_blue: Dictionary
var np_btn_blue_prs: Dictionary
var np_btn_red: Dictionary
var np_btn_red_prs: Dictionary
var np_paper: Dictionary


func _ready() -> void:
	_ensure_translations_loaded()
	_load_language_preference()

	var CursorManagerScene := preload("res://scenes/cursor_manager.tscn")
	var cm := CursorManagerScene.instantiate()
	add_child(cm)

	_process_all_textures()
	_create_title()
	_create_buttons()
	_create_language_option()


func _process_all_textures() -> void:
	np_wood_table = _process_ninepatch(PATH_WOOD_TABLE,
		[[43, 127], [192, 255], [320, 422]],
		[[44, 127], [192, 255], [320, 403]])
	np_btn_blue = _process_ninepatch(PATH_BTN_BLUE_REG,
		[[17, 63], [128, 191], [256, 302]],
		[[19, 63], [128, 191], [256, 300]])
	np_btn_blue_prs = _process_ninepatch(PATH_BTN_BLUE_PRS,
		[[28, 63], [128, 191], [256, 304]],
		[[14, 63], [128, 191], [256, 305]])
	np_btn_red = _process_ninepatch(PATH_BTN_RED_REG,
		[[17, 63], [128, 191], [256, 302]],
		[[19, 63], [128, 191], [256, 300]])
	np_btn_red_prs = _process_ninepatch(PATH_BTN_RED_PRS,
		[[28, 63], [128, 191], [256, 304]],
		[[14, 63], [128, 191], [256, 305]])
	np_paper = _process_ninepatch(PATH_SPECIAL_PAPER,
		[[20, 63], [128, 191], [256, 298]],
		[[9, 63], [128, 191], [256, 310]])


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


func _create_title() -> void:
	_title_label = Label.new()
	_title_label.text = tr("MAIN_MENU_TITLE")
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 52)
	_title_label.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
	_title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	_title_label.add_theme_constant_override("shadow_offset_x", 3)
	_title_label.add_theme_constant_override("shadow_offset_y", 3)
	_title_label.anchor_left = 0.0
	_title_label.anchor_right = 1.0
	_title_label.anchor_top = 0.15
	_title_label.anchor_bottom = 0.28
	_title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_title_label)


func _create_buttons() -> void:
	var vbox := VBoxContainer.new()
	vbox.anchor_left = 0.35
	vbox.anchor_right = 0.65
	vbox.anchor_top = 0.35
	vbox.anchor_bottom = 0.70
	vbox.add_theme_constant_override("separation", 20)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(vbox)

	# Start Game - 红色按钮
	_start_label = _make_menu_button(tr("MAIN_MENU_START"), np_btn_red, np_btn_red_prs, Vector2(0, 60), _on_start_pressed)
	vbox.add_child(_start_label.get_parent())

	# Settings - 蓝色按钮
	_settings_label = _make_menu_button(tr("UI_SETTINGS"), np_btn_blue, np_btn_blue_prs, Vector2(0, 60), _on_settings_pressed)
	vbox.add_child(_settings_label.get_parent())

	# Quit - 蓝色按钮
	_quit_label = _make_menu_button(tr("UI_QUIT_GAME"), np_btn_blue, np_btn_blue_prs, Vector2(0, 60), _on_quit_pressed)
	vbox.add_child(_quit_label.get_parent())

	# Multiplayer - 蓝色按钮
	var mp_label = _make_menu_button(tr("UI_MULTIPLAYER"), np_btn_blue, np_btn_blue_prs, Vector2(0, 60), _on_multiplayer_pressed)
	vbox.add_child(mp_label.get_parent())


func _make_menu_button(text: String, np: Dictionary, np_prs: Dictionary, min_size: Vector2, callback: Callable) -> Label:
	var wrapper := Control.new()
	wrapper.custom_minimum_size = min_size
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var bg := _make_ninepatch(np)
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
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color(1, 1, 1))
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrapper.add_child(label)

	var BF := preload("res://scripts/ui/button_factory.gd")
	BF.add_hover_anim(wrapper, bg, np_prs.texture, np.texture)
	return label


func _create_language_option() -> void:
	var hbox := HBoxContainer.new()
	hbox.anchor_left = 0.0
	hbox.anchor_right = 1.0
	hbox.anchor_top = 0.88
	hbox.anchor_bottom = 0.93
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 10)
	add_child(hbox)

	var lang_label := Label.new()
	lang_label.text = tr("UI_LANGUAGE")
	lang_label.add_theme_font_size_override("font_size", 16)
	lang_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	hbox.add_child(lang_label)

	_lang_option = OptionButton.new()
	var current_locale := TranslationServer.get_locale()
	for i in _supported_locales.size():
		var locale_code: String = _supported_locales[i]
		_lang_option.add_item(tr("LANG_" + locale_code.to_upper()), i)
		if locale_code == current_locale or locale_code == current_locale.substr(0, 2):
			_lang_option.selected = i
	_lang_option.custom_minimum_size = Vector2(140, 32)
	_lang_option.item_selected.connect(_on_language_selected)
	hbox.add_child(_lang_option)


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/save_select.tscn")


func _on_settings_pressed() -> void:
	_show_settings_overlay()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_multiplayer_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/room_browser.tscn")


func _on_language_selected(index: int) -> void:
	var locale_code: String = _supported_locales[index]
	TranslationServer.set_locale(locale_code)
	_save_language_preference(locale_code)
	_refresh_ui()


func _refresh_ui() -> void:
	_title_label.text = tr("MAIN_MENU_TITLE")
	_start_label.text = tr("MAIN_MENU_START")
	_settings_label.text = tr("UI_SETTINGS")
	_quit_label.text = tr("UI_QUIT_GAME")
	# 更新语言下拉框项文字
	for i in _supported_locales.size():
		_lang_option.set_item_text(i, tr("LANG_" + _supported_locales[i].to_upper()))


func _save_language_preference(locale_code: String) -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value("game", "locale", locale_code)
	config.save(SETTINGS_PATH)


func _load_language_preference() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		var saved_locale: String = config.get_value("game", "locale", "en")
		TranslationServer.set_locale(saved_locale)


# ============================================================
# 设置覆盖层
# ============================================================
func _show_settings_overlay() -> void:
	if _settings_overlay != null:
		return
	_settings_overlay = Control.new()
	_settings_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_settings_overlay.mouse_filter = Control.MOUSE_FILTER_STOP

	var overlay := ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_settings_overlay.add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_settings_overlay.add_child(center)

	var panel_wrapper := Control.new()
	panel_wrapper.custom_minimum_size = Vector2(500, 480)
	center.add_child(panel_wrapper)

	var bg := _make_ninepatch(np_wood_table)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel_wrapper.add_child(bg)

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

	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)

	# 标题
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

	# 显示区域
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
	_settings_res_option.item_selected.connect(_on_settings_resolution_selected)
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
	_settings_display_mode_option.item_selected.connect(_on_settings_display_mode_selected)
	_settings_res_option.disabled = (current_mode != DisplayServer.WINDOW_MODE_WINDOWED)
	dm_row.add_child(_settings_display_mode_option)
	vbox.add_child(dm_row)

	# 亮度
	var brightness_val: float = config.get_value("display", "brightness", 1.0)
	vbox.add_child(_make_slider_row(tr("UI_BRIGHTNESS"), brightness_val, 0.3, 1.5, _on_settings_brightness_changed))

	# FPS 显示
	var fps_row := HBoxContainer.new()
	fps_row.add_theme_constant_override("separation", 8)
	var fps_label := Label.new()
	fps_label.text = tr("UI_SHOW_FPS")
	fps_label.add_theme_font_size_override("font_size", 14)
	fps_label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
	fps_row.add_child(fps_label)
	var fps_toggle := CheckButton.new()
	fps_toggle.button_pressed = config.get_value("display", "show_fps", false)
	fps_toggle.toggled.connect(_on_settings_fps_toggled)
	fps_row.add_child(fps_toggle)
	vbox.add_child(fps_row)

	var spacer2 := Control.new()
	spacer2.custom_minimum_size = Vector2(0, 6)
	vbox.add_child(spacer2)

	# 音频区域
	vbox.add_child(_make_section_label(tr("UI_AUDIO")))

	var master_val: float = config.get_value("audio", "master_volume", 1.0)
	vbox.add_child(_make_slider_row(tr("UI_MASTER_VOLUME"), master_val, 0.0, 1.0, _on_settings_master_volume_changed))

	var music_val: float = config.get_value("audio", "music_volume", 1.0)
	vbox.add_child(_make_slider_row(tr("UI_MUSIC_VOLUME"), music_val, 0.0, 1.0, _on_settings_music_volume_changed))

	var sfx_val: float = config.get_value("audio", "sfx_volume", 1.0)
	vbox.add_child(_make_slider_row(tr("UI_SFX_VOLUME"), sfx_val, 0.0, 1.0, _on_settings_sfx_volume_changed))

	var spacer3 := Control.new()
	spacer3.custom_minimum_size = Vector2(0, 6)
	vbox.add_child(spacer3)

	# 游戏区域
	vbox.add_child(_make_section_label(tr("UI_GAMEPLAY")))

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
	path_toggle.toggled.connect(_on_settings_path_lines_toggled)
	path_row.add_child(path_toggle)
	vbox.add_child(path_row)

	# 碰撞区域显示
	var col_row := HBoxContainer.new()
	col_row.add_theme_constant_override("separation", 8)
	var col_label := Label.new()
	col_label.text = tr("UI_SHOW_COLLISIONS")
	col_label.add_theme_font_size_override("font_size", 14)
	col_label.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
	col_row.add_child(col_label)
	var col_toggle := CheckButton.new()
	col_toggle.button_pressed = config.get_value("game", "show_collisions", false)
	col_toggle.toggled.connect(_on_settings_collisions_toggled)
	col_row.add_child(col_toggle)
	vbox.add_child(col_row)

	var spacer4 := Control.new()
	spacer4.custom_minimum_size = Vector2(0, 8)
	vbox.add_child(spacer4)

	# 返回按钮
	vbox.add_child(_make_styled_button(tr("UI_BACK"), Vector2(0, 44), _close_settings_overlay))

	add_child(_settings_overlay)


func _close_settings_overlay() -> void:
	if _settings_overlay:
		_settings_overlay.queue_free()
		_settings_overlay = null


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

	var val_label := Label.new()
	val_label.text = "%.0f%%" % (value * 100.0)
	val_label.custom_minimum_size = Vector2(45, 0)
	val_label.add_theme_font_size_override("font_size", 13)
	val_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	slider.value_changed.connect(func(v: float): val_label.text = "%.0f%%" % (v * 100.0))
	row.add_child(val_label)

	return row


func _make_styled_button(text: String, min_size: Vector2, callback: Callable) -> Control:
	var wrapper := Control.new()
	wrapper.custom_minimum_size = min_size
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var bg := _make_ninepatch(np_btn_blue)
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
	BF.add_hover_anim(wrapper, bg, np_btn_blue_prs.texture, np_btn_blue.texture)
	return wrapper


func _save_setting(section: String, key: String, value) -> void:
	var config := ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value(section, key, value)
	config.save(SETTINGS_PATH)


# === 设置回调 ===

func _on_settings_resolution_selected(index: int) -> void:
	var new_size := RESOLUTION_PRESETS[index]
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_size(new_size)
	_save_setting("display", "resolution_width", new_size.x)
	_save_setting("display", "resolution_height", new_size.y)


func _on_settings_display_mode_selected(index: int) -> void:
	match index:
		0: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		1: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			var config := ConfigFile.new()
			if config.load(SETTINGS_PATH) == OK:
				var w: int = config.get_value("display", "resolution_width", 1280)
				var h: int = config.get_value("display", "resolution_height", 720)
				DisplayServer.window_set_size(Vector2i(w, h))
	_save_setting("display", "display_mode", index)
	if _settings_res_option:
		_settings_res_option.disabled = (index != 2)


func _on_settings_brightness_changed(value: float) -> void:
	_save_setting("display", "brightness", value)


func _on_settings_fps_toggled(pressed: bool) -> void:
	_save_setting("display", "show_fps", pressed)


func _on_settings_path_lines_toggled(pressed: bool) -> void:
	Unit.show_path_lines = pressed
	_save_setting("game", "show_path_lines", pressed)


func _on_settings_collisions_toggled(pressed: bool) -> void:
	get_tree().debug_collisions_hint = pressed
	_save_setting("game", "show_collisions", pressed)


func _on_settings_master_volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))
	AudioServer.set_bus_mute(0, value <= 0.0)
	_save_setting("audio", "master_volume", value)


func _on_settings_music_volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(1, linear_to_db(value))
	AudioServer.set_bus_mute(1, value <= 0.0)
	_save_setting("audio", "music_volume", value)


func _on_settings_sfx_volume_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(2, linear_to_db(value))
	AudioServer.set_bus_mute(2, value <= 0.0)
	_save_setting("audio", "sfx_volume", value)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if _settings_overlay:
			_close_settings_overlay()
			return


# ============================================================
# 手动加载 CSV 翻译
# ============================================================
var _translations_loaded := false

func _ensure_translations_loaded() -> void:
	if _translations_loaded:
		return
	_translations_loaded = true
	var csv_path := "res://locales/translations.csv"
	var file := FileAccess.open(csv_path, FileAccess.READ)
	if file == null:
		return
	var header_line := file.get_line()
	var headers := header_line.split(",")
	if headers.size() < 2:
		return
	var locale_codes: PackedStringArray = []
	for i in range(1, headers.size()):
		locale_codes.append(headers[i].strip_edges())
	var translations: Array[Translation] = []
	for locale in locale_codes:
		var t := Translation.new()
		t.locale = locale
		translations.append(t)
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
	for t in translations:
		TranslationServer.add_translation(t)


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
