extends Control

const PATH_WOOD_TABLE := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Wood Table/WoodTable.png"
const PATH_BTN_BLUE_REG := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigBlueButton_Regular.png"
const PATH_BTN_BLUE_PRS := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigBlueButton_Pressed.png"
const PATH_BTN_RED_REG := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigRedButton_Regular.png"
const PATH_BTN_RED_PRS := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigRedButton_Pressed.png"
const PATH_SPECIAL_PAPER := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Papers/SpecialPaper.png"

var _room_list_container: VBoxContainer
var _room_name_input: LineEdit
var _np_wood_table: Dictionary
var _np_btn_blue: Dictionary
var _np_btn_blue_prs: Dictionary
var _np_btn_red: Dictionary
var _np_btn_red_prs: Dictionary
var _back_btn: Button

func _ready():
	var CursorManagerScene := preload("res://scenes/cursor_manager.tscn")
	var cm := CursorManagerScene.instantiate()
	add_child(cm)
	_process_textures()
	_build_ui()
	RelayManager.ws_client.connected.connect(_on_ws_connected)
	RelayManager.room_list_received.connect(_on_room_list)
	RelayManager.room_created.connect(_on_room_created)
	RelayManager.room_joined.connect(_on_room_joined)
	RelayManager.connect_to_server()

func _process_textures():
	_np_wood_table = _process_ninepatch(PATH_WOOD_TABLE,
		[[43, 127], [192, 255], [320, 422]],
		[[44, 127], [192, 255], [320, 403]])
	_np_btn_blue = _process_ninepatch(PATH_BTN_BLUE_REG,
		[[17, 63], [128, 191], [256, 302]],
		[[19, 63], [128, 191], [256, 300]])
	_np_btn_blue_prs = _process_ninepatch(PATH_BTN_BLUE_PRS,
		[[28, 63], [128, 191], [256, 304]],
		[[14, 63], [128, 191], [256, 305]])
	_np_btn_red = _process_ninepatch(PATH_BTN_RED_REG,
		[[17, 63], [128, 191], [256, 302]],
		[[19, 63], [128, 191], [256, 300]])
	_np_btn_red_prs = _process_ninepatch(PATH_BTN_RED_PRS,
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
	return {"texture": ImageTexture.create_from_image(new_img), "patch_margin_left": content_cols[0][1] - content_cols[0][0], "patch_margin_top": content_rows[0][1] - content_rows[0][0], "patch_margin_right": content_cols[2][1] - content_cols[2][0], "patch_margin_bottom": content_rows[2][1] - content_rows[2][0]}

func _make_ninepatch(np: Dictionary) -> NinePatchRect:
	var npr := NinePatchRect.new()
	npr.texture = np.texture
	npr.patch_margin_left = np.patch_margin_left
	npr.patch_margin_top = np.patch_margin_top
	npr.patch_margin_right = np.patch_margin_right
	npr.patch_margin_bottom = np.patch_margin_bottom
	npr.axis_stretch_horizontal = NinePatchRect.AXIS_STRETCH_MODE_TILE
	npr.axis_stretch_vertical = NinePatchRect.AXIS_STRETCH_MODE_TILE
	return npr

func _build_ui():
	# Background
	var bg := _make_ninepatch(_np_wood_table)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Title
	var title := Label.new()
	title.text = tr("UI_MULTIPLAYER")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 40)
	title.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
	title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	title.add_theme_constant_override("shadow_offset_x", 3)
	title.add_theme_constant_override("shadow_offset_y", 3)
	title.anchor_left = 0.1
	title.anchor_right = 0.9
	title.anchor_top = 0.05
	title.anchor_bottom = 0.14
	add_child(title)

	# Room list scroll
	var scroll := ScrollContainer.new()
	scroll.anchor_left = 0.1
	scroll.anchor_right = 0.9
	scroll.anchor_top = 0.16
	scroll.anchor_bottom = 0.70
	add_child(scroll)

	_room_list_container = VBoxContainer.new()
	_room_list_container.add_theme_constant_override("separation", 8)
	scroll.add_child(_room_list_container)

	# Bottom controls
	var bottom := HBoxContainer.new()
	bottom.anchor_left = 0.1
	bottom.anchor_right = 0.9
	bottom.anchor_top = 0.73
	bottom.anchor_bottom = 0.85
	bottom.add_theme_constant_override("separation", 10)
	add_child(bottom)

	_room_name_input = LineEdit.new()
	_room_name_input.placeholder_text = tr("MAIN_MENU_START")
	_room_name_input.custom_minimum_size = Vector2(200, 40)
	_room_name_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(_room_name_input)

	var create_btn := _make_styled_button(tr("UI_MULTIPLAYER"), _np_btn_blue, _np_btn_blue_prs)
	create_btn.pressed.connect(_on_create_room)
	create_btn.custom_minimum_size = Vector2(150, 40)
	bottom.add_child(create_btn)

	var refresh_btn := _make_styled_button("Refresh", _np_btn_blue, _np_btn_blue_prs)
	refresh_btn.pressed.connect(_on_refresh)
	refresh_btn.custom_minimum_size = Vector2(120, 40)
	bottom.add_child(refresh_btn)

	# Back button
	_back_btn = _make_styled_button(tr("ESC_BACK_MAIN_MENU"), _np_btn_red, _np_btn_red_prs)
	_back_btn.anchor_left = 0.35
	_back_btn.anchor_right = 0.65
	_back_btn.anchor_top = 0.88
	_back_btn.anchor_bottom = 0.95
	_back_btn.pressed.connect(_on_back)
	add_child(_back_btn)

func _make_styled_button(text: String, np: Dictionary, np_prs: Dictionary) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.add_theme_font_size_override("font_size", 20)
	btn.add_theme_color_override("font_color", Color(1, 1, 1))
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var BF := preload("res://scripts/ui/button_factory.gd")
	BF.add_hover_anim_button(btn)
	return btn

func _on_ws_connected():
	RelayManager.request_room_list()

func _on_refresh():
	RelayManager.request_room_list()

func _on_room_list(rooms: Array):
	for child in _room_list_container.get_children():
		child.queue_free()
	for room in rooms:
		var row := _create_room_row(room)
		_room_list_container.add_child(row)

func _create_room_row(room: Dictionary) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)

	var name_label := Label.new()
	name_label.text = room.get("name", "")
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color(1, 1, 1))
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_label)

	var map_label := Label.new()
	map_label.text = room.get("map", "")
	map_label.add_theme_font_size_override("font_size", 16)
	map_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	row.add_child(map_label)

	var count_label := Label.new()
	count_label.text = str(room.get("playerCount", 1)) + "/2"
	count_label.add_theme_font_size_override("font_size", 16)
	count_label.add_theme_color_override("font_color", Color(0.7, 1.0, 0.7))
	row.add_child(count_label)

	var join_btn := Button.new()
	join_btn.text = "Join"
	join_btn.add_theme_font_size_override("font_size", 16)
	join_btn.custom_minimum_size = Vector2(80, 30)
	join_btn.pressed.connect(func(): _on_join_room(room.get("code", "")))
	row.add_child(join_btn)

	return row

func _on_create_room():
	var name := _room_name_input.text.strip_edges()
	if name == "": name = "Game"
	RelayManager.create_room(name)

func _on_join_room(code: String):
	RelayManager.join_room(code)

func _on_room_created(code: String):
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")

func _on_room_joined(code: String):
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")

func _on_back():
	RelayManager.disconnect_from_server()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
