extends Control

## 存档选择界面：3 个存档位，选择后进入关卡选择

const PATH_WOOD_TABLE := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Wood Table/WoodTable.png"
const PATH_BTN_BLUE_REG := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigBlueButton_Regular.png"
const PATH_BTN_BLUE_PRS := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigBlueButton_Pressed.png"
const PATH_BTN_RED_REG := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigRedButton_Regular.png"
const PATH_BTN_RED_PRS := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigRedButton_Pressed.png"
const PATH_SPECIAL_PAPER := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Papers/SpecialPaper.png"
const PATH_SMALL_RIBBONS := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Ribbons/SmallRibbons.png"

const SAVE_SLOTS := 3
const SETTINGS_PATH := "user://settings.cfg"

var _supported_locales := ["en", "zh", "ja"]
var _lang_buttons: Array[Button] = []
var _slot_wrappers: Array[Control] = []
var _slot_name_labels: Array[Label] = []
var _slot_score_labels: Array[Label] = []
var _slot_progress_labels: Array[Label] = []
var _slot_date_labels: Array[Label] = []
var _slot_delete_buttons: Array[Button] = []
var _slot_enter_buttons: Array[Button] = []
var _slot_bgs: Array[NinePatchRect] = []
var _delete_confirm_slot: int = -1
var _confirm_dialog: Control = null

# 九宫格纹理
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
	_create_language_buttons()
	_create_slot_list()
	_create_hint_label()
	_refresh_all_slots()


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
	var title := Label.new()
	title.text = tr("SAVE_SELECT_TITLE")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(0.95, 0.9, 0.8))
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	title.add_theme_constant_override("shadow_offset_x", 2)
	title.add_theme_constant_override("shadow_offset_y", 2)
	title.anchor_left = 0.0
	title.anchor_right = 1.0
	title.anchor_top = 0.02
	title.anchor_bottom = 0.08
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(title)


func _create_language_buttons() -> void:
	var BF := preload("res://scripts/ui/button_factory.gd")
	var hbox := HBoxContainer.new()
	hbox.anchor_left = 0.0
	hbox.anchor_right = 1.0
	hbox.anchor_top = 0.08
	hbox.anchor_bottom = 0.11
	hbox.add_theme_constant_override("separation", 8)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(hbox)

	var current_locale := TranslationServer.get_locale()
	for locale_code in _supported_locales:
		var btn := Button.new()
		btn.text = tr("LANG_" + locale_code.to_upper())
		btn.custom_minimum_size = Vector2(90, 28)
		btn.add_theme_font_size_override("font_size", 14)
		btn.set_meta("locale", locale_code)
		btn.add_theme_color_override("font_color", Color(1, 0.85, 0.0) if locale_code == current_locale else Color(0.8, 0.8, 0.8))
		btn.pressed.connect(_on_language_selected.bind(locale_code))
		hbox.add_child(btn)
		BF.add_hover_anim_button(btn)
		_lang_buttons.append(btn)


func _create_slot_list() -> void:
	var vbox := VBoxContainer.new()
	vbox.anchor_left = 0.1
	vbox.anchor_right = 0.9
	vbox.anchor_top = 0.14
	vbox.anchor_bottom = 0.92
	vbox.add_theme_constant_override("separation", 16)
	add_child(vbox)

	for i in range(SAVE_SLOTS):
		vbox.add_child(_create_slot_card(i))


func _create_slot_card(index: int) -> Control:
	var BF := preload("res://scripts/ui/button_factory.gd")
	var wrapper := Control.new()
	wrapper.custom_minimum_size = Vector2(0, 140)
	_slot_wrappers.append(wrapper)

	# 背景面板
	var bg := _make_ninepatch(np_wood_table)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wrapper.add_child(bg)
	_slot_bgs.append(bg)

	# 内容层
	var content := HBoxContainer.new()
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.offset_left = 24
	content.offset_right = -24
	content.offset_top = 12
	content.offset_bottom = -12
	content.add_theme_constant_override("separation", 20)
	wrapper.add_child(content)

	# 左侧：存档信息
	var info_vbox := VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 4)
	content.add_child(info_vbox)

	var name_label := Label.new()
	name_label.add_theme_font_size_override("font_size", 22)
	name_label.add_theme_color_override("font_color", Color(1, 0.95, 0.8))
	name_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	name_label.add_theme_constant_override("shadow_offset_x", 1)
	name_label.add_theme_constant_override("shadow_offset_y", 1)
	info_vbox.add_child(name_label)
	_slot_name_labels.append(name_label)

	var score_label := Label.new()
	score_label.add_theme_font_size_override("font_size", 18)
	score_label.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
	score_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.4))
	score_label.add_theme_constant_override("shadow_offset_x", 1)
	score_label.add_theme_constant_override("shadow_offset_y", 1)
	info_vbox.add_child(score_label)
	_slot_score_labels.append(score_label)

	var progress_label := Label.new()
	progress_label.add_theme_font_size_override("font_size", 16)
	progress_label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	progress_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.4))
	progress_label.add_theme_constant_override("shadow_offset_x", 1)
	progress_label.add_theme_constant_override("shadow_offset_y", 1)
	info_vbox.add_child(progress_label)
	_slot_progress_labels.append(progress_label)

	var date_label := Label.new()
	date_label.add_theme_font_size_override("font_size", 14)
	date_label.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))
	date_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.3))
	date_label.add_theme_constant_override("shadow_offset_x", 1)
	date_label.add_theme_constant_override("shadow_offset_y", 1)
	info_vbox.add_child(date_label)
	_slot_date_labels.append(date_label)

	# 右侧：操作按钮
	var btn_hbox := HBoxContainer.new()
	btn_hbox.size_flags_horizontal = Control.SIZE_SHRINK_END
	btn_hbox.add_theme_constant_override("separation", 12)
	btn_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_child(btn_hbox)

	# 进入/新建 按钮
	var enter_wrapper := Control.new()
	enter_wrapper.custom_minimum_size = Vector2(160, 44)
	var enter_bg := _make_ninepatch(np_btn_blue)
	enter_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	enter_wrapper.add_child(enter_bg)

	var enter_btn := Button.new()
	enter_btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	enter_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var empty_style := StyleBoxEmpty.new()
	enter_btn.add_theme_stylebox_override("normal", empty_style)
	enter_btn.add_theme_stylebox_override("hover", empty_style)
	enter_btn.add_theme_stylebox_override("pressed", empty_style)
	enter_btn.add_theme_stylebox_override("focus", empty_style)
	enter_btn.pressed.connect(_on_slot_selected.bind(index))
	enter_wrapper.add_child(enter_btn)

	var enter_label := Label.new()
	enter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	enter_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	enter_label.add_theme_font_size_override("font_size", 18)
	enter_label.add_theme_color_override("font_color", Color(1, 1, 1))
	enter_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	enter_label.add_theme_constant_override("shadow_offset_x", 1)
	enter_label.add_theme_constant_override("shadow_offset_y", 1)
	enter_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	enter_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	enter_wrapper.add_child(enter_label)

	var BF2 := preload("res://scripts/ui/button_factory.gd")
	BF2.add_hover_anim(enter_wrapper, enter_bg, np_btn_blue_prs.texture, np_btn_blue.texture)
	btn_hbox.add_child(enter_wrapper)
	_slot_enter_buttons.append(enter_btn)
	# 存储按钮标签和背景引用用于更新
	enter_btn.set_meta("label", enter_label)
	enter_btn.set_meta("bg", enter_bg)

	# 删除按钮（仅已有存档时显示）
	var del_wrapper := Control.new()
	del_wrapper.custom_minimum_size = Vector2(100, 36)
	var del_bg := _make_ninepatch(np_btn_red)
	del_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	del_wrapper.add_child(del_bg)

	var del_btn := Button.new()
	del_btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var empty_style2 := StyleBoxEmpty.new()
	del_btn.add_theme_stylebox_override("normal", empty_style2)
	del_btn.add_theme_stylebox_override("hover", empty_style2)
	del_btn.add_theme_stylebox_override("pressed", empty_style2)
	del_btn.add_theme_stylebox_override("focus", empty_style2)
	del_btn.pressed.connect(_on_delete_pressed.bind(index))
	del_wrapper.add_child(del_btn)

	var del_label := Label.new()
	del_label.text = tr("SAVE_DELETE")
	del_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	del_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	del_label.add_theme_font_size_override("font_size", 15)
	del_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.5))
	del_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	del_label.add_theme_constant_override("shadow_offset_x", 1)
	del_label.add_theme_constant_override("shadow_offset_y", 1)
	del_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	del_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	del_wrapper.add_child(del_label)

	BF.add_hover_anim(del_wrapper, del_bg, np_btn_red_prs.texture, np_btn_red.texture)
	btn_hbox.add_child(del_wrapper)
	del_btn.set_meta("wrapper", del_wrapper)
	_slot_delete_buttons.append(del_btn)

	return wrapper


func _refresh_all_slots() -> void:
	var sm := _get_save_manager()
	for i in range(SAVE_SLOTS):
		var exists: bool = sm.slot_exists(i)
		var data: Dictionary = sm.load_slot(i)
		var enter_btn: Button = _slot_enter_buttons[i]
		var enter_label: Label = enter_btn.get_meta("label")
		var del_btn: Button = _slot_delete_buttons[i]

		if exists:
			_slot_name_labels[i].text = tr("SAVE_SLOT_N") % (i + 1) + " - " + str(data.get("slot_name", "Commander"))
			var total: int = sm.calc_total_score(data)
			_slot_score_labels[i].text = tr("SAVE_SCORE") % [total, 100]
			var completed: int = sm.get_completed_count(data)
			_slot_progress_labels[i].text = tr("SAVE_PROGRESS") % [completed, 4]
			var last: String = str(data.get("last_played", ""))
			_slot_date_labels[i].text = tr("SAVE_LAST_PLAYED") % sm.format_date(last)
			enter_label.text = tr("SAVE_CONTINUE")
			del_btn.get_meta("wrapper").visible = true
		else:
			_slot_name_labels[i].text = tr("SAVE_SLOT_N") % (i + 1) + " - " + tr("SAVE_EMPTY")
			_slot_score_labels[i].text = ""
			_slot_progress_labels[i].text = ""
			_slot_date_labels[i].text = ""
			enter_label.text = tr("SAVE_NEW_GAME")
			del_btn.get_meta("wrapper").visible = false


func _on_slot_selected(slot: int) -> void:
	var sm := _get_save_manager()
	sm.set_current_slot(slot)
	# 如果是新存档，先初始化
	if not sm.slot_exists(slot):
		sm.save_slot(slot, sm.load_slot(slot))
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")


func _on_delete_pressed(slot: int) -> void:
	_delete_confirm_slot = slot
	_show_delete_confirm(slot)


func _show_delete_confirm(slot: int) -> void:
	if _confirm_dialog != null:
		_confirm_dialog.queue_free()
	_confirm_dialog = Control.new()
	_confirm_dialog.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_confirm_dialog.mouse_filter = Control.MOUSE_FILTER_STOP

	# 半透明遮罩
	var overlay := ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_confirm_dialog.add_child(overlay)

	# 对话框面板
	var panel_wrapper := Control.new()
	panel_wrapper.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel_wrapper.offset_left = -200
	panel_wrapper.offset_right = 200
	panel_wrapper.offset_top = -80
	panel_wrapper.offset_bottom = 80
	_confirm_dialog.add_child(panel_wrapper)

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

	var msg := Label.new()
	msg.text = tr("SAVE_DELETE_CONFIRM")
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg.add_theme_font_size_override("font_size", 20)
	msg.add_theme_color_override("font_color", Color(1, 0.95, 0.8))
	msg.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	msg.add_theme_constant_override("shadow_offset_x", 1)
	msg.add_theme_constant_override("shadow_offset_y", 1)
	vbox.add_child(msg)

	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 20)
	vbox.add_child(hbox)

	# 确认按钮
	var yes_wrapper := Control.new()
	yes_wrapper.custom_minimum_size = Vector2(100, 40)
	var yes_bg := _make_ninepatch(np_btn_red)
	yes_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	yes_wrapper.add_child(yes_bg)
	var yes_btn := Button.new()
	yes_btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var es := StyleBoxEmpty.new()
	yes_btn.add_theme_stylebox_override("normal", es)
	yes_btn.add_theme_stylebox_override("hover", es)
	yes_btn.add_theme_stylebox_override("pressed", es)
	yes_btn.add_theme_stylebox_override("focus", es)
	yes_btn.pressed.connect(_confirm_delete)
	yes_wrapper.add_child(yes_btn)
	var yes_label := Label.new()
	yes_label.text = tr("SAVE_DELETE")
	yes_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	yes_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	yes_label.add_theme_font_size_override("font_size", 16)
	yes_label.add_theme_color_override("font_color", Color(1, 1, 1))
	yes_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	yes_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	yes_wrapper.add_child(yes_label)
	hbox.add_child(yes_wrapper)

	# 取消按钮
	var no_wrapper := Control.new()
	no_wrapper.custom_minimum_size = Vector2(100, 40)
	var no_bg := _make_ninepatch(np_btn_blue)
	no_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	no_wrapper.add_child(no_bg)
	var no_btn := Button.new()
	no_btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var es2 := StyleBoxEmpty.new()
	no_btn.add_theme_stylebox_override("normal", es2)
	no_btn.add_theme_stylebox_override("hover", es2)
	no_btn.add_theme_stylebox_override("pressed", es2)
	no_btn.add_theme_stylebox_override("focus", es2)
	no_btn.pressed.connect(_cancel_delete)
	no_wrapper.add_child(no_btn)
	var no_label := Label.new()
	no_label.text = tr("UI_BACK")
	no_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	no_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	no_label.add_theme_font_size_override("font_size", 16)
	no_label.add_theme_color_override("font_color", Color(1, 1, 1))
	no_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	no_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	no_wrapper.add_child(no_label)
	hbox.add_child(no_wrapper)

	add_child(_confirm_dialog)


func _confirm_delete() -> void:
	if _delete_confirm_slot >= 0:
		_get_save_manager().delete_slot(_delete_confirm_slot)
	_delete_confirm_slot = -1
	if _confirm_dialog:
		_confirm_dialog.queue_free()
		_confirm_dialog = null
	_refresh_all_slots()


func _cancel_delete() -> void:
	_delete_confirm_slot = -1
	if _confirm_dialog:
		_confirm_dialog.queue_free()
		_confirm_dialog = null


func _create_hint_label() -> void:
	var hint := Label.new()
	hint.text = tr("LEVEL_PRESS_ESC_QUIT")
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	hint.anchor_left = 0.0
	hint.anchor_right = 1.0
	hint.anchor_top = 0.94
	hint.anchor_bottom = 0.98
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(hint)


func _on_language_selected(locale_code: String) -> void:
	TranslationServer.set_locale(locale_code)
	_save_language_preference(locale_code)
	_refresh_ui()


func _refresh_ui() -> void:
	# 更新语言按钮高亮
	var current_locale := TranslationServer.get_locale()
	for btn in _lang_buttons:
		var bl: String = btn.get_meta("locale")
		btn.add_theme_color_override("font_color", Color(1, 0.85, 0.0) if bl == current_locale else Color(0.8, 0.8, 0.8))
		btn.text = tr("LANG_" + bl.to_upper())
	_refresh_all_slots()


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


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if _confirm_dialog:
			_cancel_delete()
			return
		get_tree().quit()


func _get_save_manager() -> Node:
	return get_node_or_null("/root/SaveManager")


# === 手动加载 CSV 翻译 ===
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
