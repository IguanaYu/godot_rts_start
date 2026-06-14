extends Control

const PATH_WOOD_TABLE := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Wood Table/WoodTable.png"
const PATH_BTN_BLUE_REG := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigBlueButton_Regular.png"
const PATH_BTN_BLUE_PRS := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigBlueButton_Pressed.png"
const PATH_BTN_RED_REG := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigRedButton_Regular.png"
const PATH_BTN_RED_PRS := "res://assets/Tiny Swords (Free Pack)/Tiny Swords (Free Pack)/UI Elements/UI Elements/Buttons/BigRedButton_Pressed.png"

var _np_wood_table: Dictionary
var _np_btn_blue: Dictionary
var _np_btn_blue_prs: Dictionary
var _np_btn_red: Dictionary
var _np_btn_red_prs: Dictionary
var _room_code_label: Label
var _player1_label: Label
var _player2_label: Label
var _ready_btn: Button
var _start_btn: Button
var _back_btn: Button
var _guest_ready := false
var _map_buttons: Array[Button] = []
var _selected_map_label: Label

# 多人可用地图列表
var _mp_maps := [
	{"name": "map_1", "label": "Map 1"},
	{"name": "map_2", "label": "Map 2"},
	{"name": "map_3", "label": "Map 3"},
	{"name": "map_4", "label": "Map 4"},
	{"name": "map_5", "label": "Map 5"},
	{"name": "map_6", "label": "Map 6"},
	{"name": "map_7", "label": "Map 7"},
	{"name": "map_8", "label": "Map 8"},
	{"name": "map_9", "label": "Map 9"},
	{"name": "map_10", "label": "Map 10"},
	{"name": "map_11", "label": "Map 11"},
	{"name": "map_12", "label": "Map 12"},
	{"name": "map_13", "label": "Map 13"},
	{"name": "map_14", "label": "Map 14"},
	{"name": "map_15", "label": "Map 15"},
	{"name": "map_16", "label": "Map 16"},
	{"name": "mp_test", "label": "MP Co-op Test"},
]

func _ready():
	var CursorManagerScene := preload("res://scenes/cursor_manager.tscn")
	var cm := CursorManagerScene.instantiate()
	add_child(cm)
	_process_textures()
	_build_ui()
	RelayManager.player_joined.connect(_on_player_joined)
	RelayManager.player_left.connect(_on_player_left)
	RelayManager.player_ready.connect(_on_player_ready)
	RelayManager.game_starting.connect(_on_game_starting)
	RelayManager.map_changed.connect(_on_map_changed)

	_update_selected_map_display(RelayManager._map_name)

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
	return {"texture": ImageTexture.create_from_image(new_img), "patch_margin_left": tw[0], "patch_margin_top": th[0], "patch_margin_right": tw[2], "patch_margin_bottom": th[2]}

func _make_ninepatch(np: Dictionary, tile_center := true) -> NinePatchRect:
	var npr := NinePatchRect.new()
	npr.texture = np.texture
	npr.patch_margin_left = np.patch_margin_left
	npr.patch_margin_top = np.patch_margin_top
	npr.patch_margin_right = np.patch_margin_right
	npr.patch_margin_bottom = np.patch_margin_bottom
	if tile_center:
		npr.axis_stretch_horizontal = NinePatchRect.AXIS_STRETCH_MODE_TILE
		npr.axis_stretch_vertical = NinePatchRect.AXIS_STRETCH_MODE_TILE
	npr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return npr

func _build_ui():
	# Background
	var bg := _make_ninepatch(_np_wood_table, false)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Title
	var title := Label.new()
	title.text = "Lobby"
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

	# Room code
	_room_code_label = Label.new()
	_room_code_label.text = "Room: " + RelayManager.room_code
	_room_code_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_room_code_label.add_theme_font_size_override("font_size", 22)
	_room_code_label.add_theme_color_override("font_color", Color(1, 1, 1))
	_room_code_label.anchor_left = 0.2
	_room_code_label.anchor_right = 0.8
	_room_code_label.anchor_top = 0.15
	_room_code_label.anchor_bottom = 0.21
	add_child(_room_code_label)

	# Player 1 slot (host)
	_player1_label = Label.new()
	_player1_label.text = "Player 1 (You) - Ready" if RelayManager.is_host else "Player 1 (Host) - Ready"
	_player1_label.add_theme_font_size_override("font_size", 20)
	_player1_label.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5))
	_player1_label.anchor_left = 0.2
	_player1_label.anchor_right = 0.8
	_player1_label.anchor_top = 0.25
	_player1_label.anchor_bottom = 0.31
	add_child(_player1_label)

	# Player 2 slot (guest)
	_player2_label = Label.new()
	_player2_label.text = "Player 2 - Waiting..."
	_player2_label.add_theme_font_size_override("font_size", 20)
	_player2_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	_player2_label.anchor_left = 0.2
	_player2_label.anchor_right = 0.8
	_player2_label.anchor_top = 0.34
	_player2_label.anchor_bottom = 0.40
	add_child(_player2_label)

	# Selected map display
	_selected_map_label = Label.new()
	_selected_map_label.add_theme_font_size_override("font_size", 18)
	_selected_map_label.add_theme_color_override("font_color", Color(1, 0.85, 0.0))
	_selected_map_label.anchor_left = 0.15
	_selected_map_label.anchor_right = 0.85
	_selected_map_label.anchor_top = 0.43
	_selected_map_label.anchor_bottom = 0.48
	add_child(_selected_map_label)

	if RelayManager.is_host:
		# Host: map selection list
		var map_title := Label.new()
		map_title.text = "Select Map:"
		map_title.add_theme_font_size_override("font_size", 16)
		map_title.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		map_title.anchor_left = 0.15
		map_title.anchor_right = 0.85
		map_title.anchor_top = 0.49
		map_title.anchor_bottom = 0.53
		add_child(map_title)

		var scroll := ScrollContainer.new()
		scroll.anchor_left = 0.15
		scroll.anchor_right = 0.85
		scroll.anchor_top = 0.54
		scroll.anchor_bottom = 0.78
		add_child(scroll)

		var map_vbox := VBoxContainer.new()
		map_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		scroll.add_child(map_vbox)

		for mp in _mp_maps:
			var btn := _make_button(mp.label, _np_btn_blue, _np_btn_blue_prs)
			btn.custom_minimum_size = Vector2(0, 34)
			btn.add_theme_font_size_override("font_size", 15)
			var map_name: String = mp.name
			btn.pressed.connect(_on_map_button_pressed.bind(map_name))
			map_vbox.add_child(btn)
			_map_buttons.append(btn)

		# Start button (host only) — below map list
		_start_btn = _make_button("Start Game", _np_btn_red, _np_btn_red_prs)
		_start_btn.anchor_left = 0.3
		_start_btn.anchor_right = 0.7
		_start_btn.anchor_top = 0.81
		_start_btn.anchor_bottom = 0.88
		_start_btn.pressed.connect(_on_start_pressed)
		_start_btn.disabled = true
		add_child(_start_btn)
	else:
		# Guest: ready button
		_ready_btn = _make_button("Ready", _np_btn_blue, _np_btn_blue_prs)
		_ready_btn.anchor_left = 0.3
		_ready_btn.anchor_right = 0.7
		_ready_btn.anchor_top = 0.50
		_ready_btn.anchor_bottom = 0.58
		_ready_btn.pressed.connect(_on_ready_pressed)
		add_child(_ready_btn)

	# Back button
	_back_btn = _make_button("Back", _np_btn_blue, _np_btn_blue_prs)
	_back_btn.anchor_left = 0.35
	_back_btn.anchor_right = 0.65
	_back_btn.anchor_top = 0.91
	_back_btn.anchor_bottom = 0.97
	_back_btn.pressed.connect(_on_back)
	add_child(_back_btn)

func _make_button(text: String, np: Dictionary, np_prs: Dictionary) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.add_theme_font_size_override("font_size", 22)
	btn.add_theme_color_override("font_color", Color(1, 1, 1))
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	return btn

func _on_player_joined(player_id: int):
	_player2_label.text = "Player 2 - Joined"
	_player2_label.add_theme_color_override("font_color", Color(0.5, 1.0, 0.5))

func _on_player_left():
	_player2_label.text = "Player 2 - Left"
	_player2_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	_guest_ready = false
	if is_instance_valid(_start_btn):
		_start_btn.disabled = true

func _on_player_ready(ready: bool):
	_guest_ready = ready
	if RelayManager.is_host:
		_player2_label.text = "Player 2 - Ready" if ready else "Player 2 - Joined"
		if is_instance_valid(_start_btn):
			_start_btn.disabled = not ready

func _on_ready_pressed():
	RelayManager.send_ready()
	_ready_btn.disabled = true
	_ready_btn.text = "Waiting..."

func _on_map_button_pressed(map_name: String):
	RelayManager.update_map(map_name)

func _on_map_changed(map_name: String):
	_update_selected_map_display(map_name)

func _update_selected_map_display(map_name: String):
	var label := "MP Co-op Test" if map_name == "mp_test" else "Map " + map_name.replace("map_", "")
	_selected_map_label.text = "Selected: " + label

func _on_start_pressed():
	RelayManager.send_start_game()

func _on_game_starting():
	var mp_scene := "res://scenes/maps/" + RelayManager._map_name + ".tscn"
	LoadRouter.request_load(mp_scene, true)

func _on_back():
	RelayManager.leave_room()
	get_tree().change_scene_to_file("res://scenes/room_browser.tscn")
